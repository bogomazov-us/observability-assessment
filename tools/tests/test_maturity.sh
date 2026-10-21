#!/usr/bin/env bash
# Tests for tools/maturity.py: the worked example passes; each rule has a fixture that trips it.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../maturity.py"
fx="$here/fixtures/maturity"
fail=0

out="$("$tool" "$fx/worked-example.yml")" || { echo "✗ worked example: expected exit 0"; exit 1; }
grep -q '^\*\*Distribution:\*\* 1 dimension at 1, 4 at 2, 6 not scored$' <<<"$out" \
  || { echo "✗ worked example: distribution line"; fail=1; }
grep -qi 'average' <<<"$out" && { echo "✗ worked example: prints an average"; fail=1; }
grep -q '| 3 Error semantics | 2 (partial 3) |' <<<"$out" || { echo "✗ worked example: partial cell"; fail=1; }
grep -q 'Operational analytics |' <<<"$out" && { echo "✗ worked example: N/A shown in the profile"; fail=1; }
grep -q 'none marked' <<<"$out" || { echo "✗ worked example: blocks line should say none marked"; fail=1; }
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

set +e; "$tool" --check "$fx/does-not-exist.yml" 2>/dev/null; code=$?; set -e
[ $code -eq 2 ] && echo "✓ unreadable file exits 2" || { echo "✗ unreadable file: exit $code"; fail=1; }

exit $fail
