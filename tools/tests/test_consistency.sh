#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for scripts/consistency.py: the kit and the sound fixture pass; each failing fixture is
# the sound one with one file replaced, and trips its check at the named file and line.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../../scripts/consistency.py"
fx="$here/fixtures/consistency"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
ok() { echo "✓ $*"; }
ko() { echo "✗ $*"; fail=1; }
run() { set +e; out="$("$@" 2>&1)"; code=$?; set -e; }

run python3 "$tool"
[ $code -eq 0 ] && [ -z "$out" ] && ok "the kit passes" || ko "the kit: exit $code: $out"
run python3 "$tool" --root "$fx/pass"
[ $code -eq 0 ] && [ -z "$out" ] && ok "sound fixture passes" || ko "sound fixture: exit $code: $out"

# fixture -> text the failure must contain (check, file:line)
expect() {
  local name="$1" want="$2"
  rm -rf "$T/$name"; cp -R "$fx/pass" "$T/$name"; cp -R "$fx/$name/." "$T/$name/"
  run python3 "$tool" --root "$T/$name"
  [ $code -eq 1 ] && grep -qF -- "$want" <<<"$out" && ok "$name: $want" || ko "$name: exit $code: $out"
}
expect fail-weeks "weeks: templates/week.md:3: week number outside the calendar"
expect fail-playbook-week "weeks: method/playbook.md:7: step 3: Week [3] differs from the calendar's [2]"
expect fail-prefix "prefix: templates/prefix.md:3: id prefix 'AC-' not in the registry"
expect fail-status "status: templates/status.md:3: 'proposed / accepted / rejected' differs from the status set 'Decision'"
expect fail-gate "gate: tools/agent/stage-3-gap.md:3: 'What the person confirms' lacks the phrase the stage 4 gate states: another path than the agent's query"
expect fail-allow-stale "allow-list entry matches nothing: consistency-allow.yml:4"

# the allow-list is what lets the sound fixture pass: without it, the staffing line fails
cp -R "$fx/pass" "$T/noallow"; rm "$T/noallow/scripts/consistency-allow.yml"
run python3 "$tool" --root "$T/noallow"
[ $code -eq 1 ] && grep -qF "weeks: method/getting-started.md:18:" <<<"$out" \
  && ok "without the allow-list the excepted line fails" || ko "no allow-list: exit $code: $out"
exit $fail
