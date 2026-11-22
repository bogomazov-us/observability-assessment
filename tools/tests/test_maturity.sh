#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/maturity.py: the worked example passes; each rule has a fixture that trips it.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../maturity.py"
fx="$here/fixtures/maturity"
fail=0

out="$("$tool" "$here/../../example/maturity.yml")" || { echo "✗ worked example: expected exit 0"; exit 1; }
grep -q '^\*\*Distribution:\*\* 1 dimension at 1, 4 at 2, 6 not scored$' <<<"$out" \
  || { echo "✗ worked example: distribution line"; fail=1; }
grep -qi 'average' <<<"$out" && { echo "✗ worked example: prints an average"; fail=1; }
grep -q '| 3 Error semantics | 2 (partial 3) |' <<<"$out" || { echo "✗ worked example: partial cell"; fail=1; }
grep -q 'Operational analytics |' <<<"$out" && { echo "✗ worked example: N/A shown in the profile"; fail=1; }
grep -q '^\*\*Block the next step:\*\* 3 Error semantics; 5 Business outcome data; 6 SLOs$' <<<"$out" \
  || { echo "✗ worked example: blocks line"; fail=1; }
[ $fail -eq 0 ] && echo "✓ worked example"

for f in "$fx"/fail-M*.yml; do
  rule="$(basename "$f" .yml)"; rule="${rule#fail-}"
  set +e; err="$("$tool" --check "$f" 2>&1)"; code=$?; set -e
  if [ $code -eq 1 ] && grep -q " $rule " <<<"$err"; then echo "✓ $rule"
  else echo "✗ $rule: exit $code, output: $err"; fail=1; fi
done

set +e; err="$("$tool" --check "$fx/warn-W01.yml" 2>&1)"; code=$?; set -e
if [ $code -eq 0 ] && grep -q ' W01 ' <<<"$err"; then echo "✓ W01 (warning, exit 0)"
else echo "✗ W01: exit $code, output: $err"; fail=1; fi

# model: sre (tools/maturity.md, "Models")
out="$("$tool" "$fx/sre-pass.yml")" || { echo "✗ sre: expected exit 0"; fail=1; }
grep -q '^| 6 Change safety | 3 |' <<<"$out" && echo "✓ sre: SRE names in the profile" || { echo "✗ sre: profile"; fail=1; }
set +e; err="$("$tool" --check "$fx/sre-fail-M02.yml" 2>&1)"; code=$?; set -e
[ $code -eq 1 ] && grep -q ' M02 number must be 1-10' <<<"$err" && echo "✓ sre: M02 above 10" || { echo "✗ sre M02: $err"; fail=1; }
set +e; err="$("$tool" --check "$fx/sre-warn-W01.yml" 2>&1)"; code=$?; set -e
[ $code -eq 0 ] && grep -q ' W01 ' <<<"$err" && echo "✓ sre: W01 on any N/A" || { echo "✗ sre W01: exit $code, $err"; fail=1; }

# --pair: the overlap table
set +e; err="$("$tool" --pair "$fx/pair-obs.yml" "$fx/pair-sre.yml" 2>&1)"; code=$?; set -e
[ $code -eq 0 ] && echo "✓ pair: clean (releases scored in both)" || { echo "✗ pair clean: exit $code, $err"; fail=1; }
for rule in P01 P02; do
  set +e; err="$("$tool" --pair "$fx/pair-obs.yml" "$fx/pair-fail-$rule.yml" 2>&1)"; code=$?; set -e
  if [ $code -eq 1 ] && grep -q " $rule " <<<"$err" && [ "$(wc -l <<<"$err")" -eq 1 ]; then echo "✓ $rule"
  else echo "✗ $rule: exit $code, output: $err"; fail=1; fi
done
set +e; "$tool" --pair "$fx/pair-obs.yml" "$fx/fail-M15.yml" 2>/dev/null; code=$?; set -e
[ $code -eq 2 ] && echo "✓ pair: two observability files exit 2" || { echo "✗ pair same model: exit $code"; fail=1; }

set +e; "$tool" --check "$fx/does-not-exist.yml" 2>/dev/null; code=$?; set -e
[ $code -eq 2 ] && echo "✓ unreadable file exits 2" || { echo "✗ unreadable file: exit $code"; fail=1; }

exit $fail
