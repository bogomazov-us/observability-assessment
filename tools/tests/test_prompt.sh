#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/agent/prompt.sh and the rule files the stage prompts name.
# The six assembled prompts are pinned byte for byte in tools/tests/fixtures/prompts/.
# After a deliberate prompt change, refresh them: UPDATE_GOLDEN=1 tools/tests/test_prompt.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
P=tools/agent/prompt.sh
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
FAIL=0
BUDGET=2500 # words per assembled stage prompt, every stage
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

# a long stage keeps its reference in a file the prompt links, not one prompt.sh appends
for n in 2 3; do
  R=tools/agent/reference/stage-$n-reference.md
  [ -f "$R" ] && grep -qF "(reference/stage-$n-reference.md)" tools/agent/stage-$n-*.md \
    && pass "stage $n links its reference" || fail "stage $n: reference missing or not linked"
  grep -qF "# Stage $n reference" "$T/s$n.md" && fail "stage $n: reference appended" || pass "stage $n: reference not appended"
done

# size budget: every assembled prompt fits
for n in 1 2 3 4 5 6; do
  w=$(( $(wc -w < "$T/s$n.md") ))
  [ "$w" -le "$BUDGET" ] && pass "stage $n prompt $w words (≤ $BUDGET)" || fail "stage $n prompt $w words (> $BUDGET)"
done

# golden files: any change to an assembled prompt is deliberate
G=tools/tests/fixtures/prompts
for n in 1 2 3 4 5 6; do
  if [ "${UPDATE_GOLDEN:-}" = 1 ]; then mkdir -p "$G"; cp "$T/s$n.md" "$G/stage-$n.md"; fi
  if cmp -s "$G/stage-$n.md" "$T/s$n.md"; then pass "stage $n prompt matches $G/stage-$n.md"
  else fail "stage $n prompt differs from $G/stage-$n.md (refresh: UPDATE_GOLDEN=1 $0)"
       diff -u "$G/stage-$n.md" "$T/s$n.md" || true; fi
done

"$P" 7 >/dev/null 2>&1 && fail "stage 7 accepted" || pass "stage 7 refused"
"$P" >/dev/null 2>&1 && fail "no argument accepted" || pass "no argument refused"
"$P" 1 > "$T/out.md" && cmp -s "$T/out.md" "$T/s1.md" && pass "stdout equals file output" || fail "stdout differs from file output"

exit $FAIL
