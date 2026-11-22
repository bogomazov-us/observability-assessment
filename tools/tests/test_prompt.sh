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

# size budget: every assembled prompt fits, for every type and stage that has a file
for n in 1 2 3 4 5 6; do
  w=$(( $(wc -w < "$T/s$n.md") ))
  [ "$w" -le "$BUDGET" ] && pass "stage $n prompt $w words (≤ $BUDGET)" || fail "stage $n prompt $w words (> $BUDGET)"
done
for f in sre/agent/stage-[1-6]-*.md; do
  [ -f "$f" ] || continue
  n="${f#sre/agent/stage-}"; n="${n%%-*}"
  if "$P" --assessment sre "$n" "$T/sre$n.md"; then
    w=$(( $(wc -w < "$T/sre$n.md") ))
    [ "$w" -le "$BUDGET" ] && pass "sre stage $n prompt $w words (≤ $BUDGET)" || fail "sre stage $n prompt $w words (> $BUDGET)"
  else fail "sre stage $n: prompt.sh failed"; fi
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

# --assessment: the default is observability; sre takes the stage file from sre/agent/
"$P" --assessment observability 1 > "$T/obs1.md" && cmp -s "$T/obs1.md" "$T/s1.md" \
  && pass "--assessment observability equals the default" || fail "--assessment observability differs from the default"
"$P" --assessment sre 1 > "$T/sre1.md"
[ "$(head -1 sre/agent/stage-1-*.md)" = "$(head -1 "$T/sre1.md")" ] \
  && pass "sre stage 1 first" || fail "sre stage 1: stage file not first"
for h in "boundaries common to every stage" "every claim cites its evidence" \
         "claims stay within what was checked" "owner questions stay open" "progress log"; do
  grep -qF "# Rule: $h" "$T/sre1.md" && pass "sre stage 1 has rule: $h" || fail "sre stage 1 lacks rule: $h"
done
grep -qF "check engagement-state.yml 1\`" "$T/sre1.md" && pass "sre stage 1 gate check" || fail "sre stage 1: gate check not set"
grep -qF "stage-N.md" "$T/sre1.md" && fail "sre stage 1: N left in place" || pass "sre stage 1: N replaced"
"$P" --assessment nosuch 1 >/dev/null 2>"$T/err" && fail "unknown type accepted" \
  || { grep -qF "nosuch" "$T/err" && pass "unknown type refused, named" || fail "unknown type: message does not name it"; }
missing=""; for n in 1 2 3 4 5 6; do ls sre/agent/stage-"$n"-*.md >/dev/null 2>&1 || { missing=$n; break; }; done
if [ -n "$missing" ]; then
  "$P" --assessment sre "$missing" >/dev/null 2>"$T/err" && fail "sre stage $missing accepted without a file" \
    || { grep -q "sre.*stage $missing" "$T/err" && pass "missing sre stage $missing refused, named" || fail "missing sre stage: message does not name it"; }
fi
"$P" --assessment >/dev/null 2>&1 && fail "--assessment without a type accepted" || pass "--assessment without a type refused"

exit $FAIL
