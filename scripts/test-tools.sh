#!/usr/bin/env bash
# Runs every tool test (tools/tests/test_*.sh). In CI on every push, and before every release.
set -uo pipefail
cd "$(dirname "$0")/.."
FAIL=0
LOG="$(mktemp)"; trap 'rm -f "$LOG"' EXIT
for t in tools/tests/test_*.sh; do
  [ -e "$t" ] || { echo "! no tool tests found"; exit 0; }
  if bash "$t" >"$LOG" 2>&1; then echo "✓ $t"
  else echo "✗ $t"; sed 's/^/    /' "$LOG" | tail -20; FAIL=1; fi
done
exit $FAIL
