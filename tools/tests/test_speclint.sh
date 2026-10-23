#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# speclint: the worked example and the template pass; every fixture fails with its own rule.
# Each fixture names what it expects in its header: "# expect: SLnnn" or "# expect: clean",
# and optional "# args: ..." for the linter.
set -euo pipefail
cd "$(dirname "$0")/../.."
LINT=(python3 tools/speclint.py)
FAIL=0
pass() { echo "ok   $*"; }
fail() { echo "FAIL $*"; FAIL=1; }

"${LINT[@]}" --strict example/worked-example.spec.yml >/dev/null 2>&1 \
  && pass "worked example lints clean (--strict)" || fail "worked example"

out="$("${LINT[@]}" templates/spec-set/observability-spec.yml 2>/dev/null)" \
  && ! grep -v ' SL016 ' <<<"$out" | grep -q . \
  && pass "template: placeholders only" || fail "template has findings other than SL016"

for f in tools/tests/fixtures/speclint/*.yml; do
  expect="$(sed -n 's/^# expect: //p' "$f")"
  read -r -a args <<<"$(sed -n 's/^# args: //p' "$f")"
  set +e
  out="$("${LINT[@]}" ${args[@]+"${args[@]}"} "$f" 2>/dev/null)"; code=$?
  set -e
  if [ "$expect" = clean ]; then
    [ $code -eq 0 ] && [ -z "$out" ] && pass "$f" || fail "$f: expected clean, got exit $code: $out"
  else
    [ $code -eq 1 ] && grep -q " $expect " <<<"$out" && pass "$f" \
      || fail "$f: expected $expect and exit 1, got exit $code: $out"
  fi
done

set +e; "${LINT[@]}" /nonexistent.yml >/dev/null 2>&1; code=$?; set -e
[ $code -eq 2 ] && pass "missing file exits 2" || fail "missing file exited $code"

exit $FAIL
