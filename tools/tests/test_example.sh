#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# The worked example passes the kit's tools, so it cannot fall behind the method silently.
# A failure names the example file and the tool's own output.
set -uo pipefail
cd "$(dirname "$0")/../.."
FAIL=0
check() {  # file, description, command...
  local file="$1" what="$2"; shift 2
  local out code
  out="$("$@" 2>&1)"; code=$?
  if [ $code -eq 0 ]; then echo "✓ $file: $what"
  else echo "✗ $file: $what (exit $code)"; sed 's/^/    /' <<<"$out"; FAIL=1; fi
}

check example/worked-example.spec.yml "speclint --strict" \
  python3 tools/speclint.py --strict example/worked-example.spec.yml
check example/maturity.yml "maturity.py" \
  python3 tools/maturity.py example/maturity.yml
check example/agent/engagement-state.yml "stagegate lint" \
  python3 tools/stagegate.py lint example/agent/engagement-state.yml
check example/agent/engagement-state.yml "stagegate check 4 opens at stage 3 confirmed" \
  python3 tools/stagegate.py check example/agent/engagement-state.yml 4

# lint prints warnings with exit 0; the example carries none
out="$(python3 tools/stagegate.py lint example/agent/engagement-state.yml 2>&1)"
[ -z "$out" ] && echo "✓ example/agent/engagement-state.yml: no warnings" \
  || { echo "✗ example/agent/engagement-state.yml: warnings"; sed 's/^/    /' <<<"$out"; FAIL=1; }

exit $FAIL
