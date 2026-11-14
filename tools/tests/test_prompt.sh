#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/agent/prompt.sh and the rule files the stage prompts name.
set -euo pipefail
cd "$(dirname "$0")/../.."
P=tools/agent/prompt.sh
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
FAIL=0
pass() { echo "✓ $*"; }
fail() { echo "✗ $*"; FAIL=1; }

for n in 1 2 3 4 5 6; do
  "$P" "$n" "$T/s$n.md"
  head -1 "$T/s$n.md" | grep -q "^# Stage $n " && pass "stage $n first" || fail "stage $n: stage file not first"
  for h in "boundaries common to every stage" "every claim cites its evidence" \
           "claims stay within what was checked" "owner questions stay open" "progress log"; do
    grep -qF "# Rule: $h" "$T/s$n.md" && pass "stage $n has rule: $h" || fail "stage $n lacks rule: $h"
  done
  grep -qF "progress/stage-$n.md" "$T/s$n.md" && pass "stage $n log path" || fail "stage $n: log path not set"
  grep -qF "check engagement-state.yml $n\`" "$T/s$n.md" && pass "stage $n gate check" || fail "stage $n: gate check not set to $n"
  grep -qF "stage-N.md" "$T/s$n.md" && fail "stage $n: N left in place" || pass "stage $n: N replaced"
  grep -qF "prompt.sh $n\`" "tools/agent/stage-$n-"*.md && pass "stage $n names its command" || fail "stage $n: header does not name prompt.sh $n"
  # a rule must live in one place: the stage file does not repeat it
  for s in "## Progress log" "## Claims stay within what was checked" "No client data leaves the engagement repository"; do
    grep -qF "$s" tools/agent/stage-"$n"-*.md && fail "stage $n repeats: $s" || pass "stage $n does not repeat: $s"
  done
done

"$P" 7 >/dev/null 2>&1 && fail "stage 7 accepted" || pass "stage 7 refused"
"$P" >/dev/null 2>&1 && fail "no argument accepted" || pass "no argument refused"
"$P" 1 > "$T/out.md" && cmp -s "$T/out.md" "$T/s1.md" && pass "stdout equals file output" || fail "stdout differs from file output"

exit $FAIL
