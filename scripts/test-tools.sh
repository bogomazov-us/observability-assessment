#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Runs every tool test (tools/tests/test_*.sh). In CI on every push, and before every release.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2
FAIL=0
# Without PyYAML every YAML-reading tool fails; say it once instead of a hundred times.
python3 -c 'import yaml' 2>/dev/null || { echo "✗ PyYAML not installed: pip install -r requirements.txt (CONTRIBUTING.md, \"Requirements\")"; exit 1; }
LOG="$(mktemp)"; trap 'rm -f "$LOG"' EXIT
for t in tools/tests/test_*.sh; do
  [ -e "$t" ] || { echo "! no tool tests found"; exit 0; }
  if bash "$t" >"$LOG" 2>&1; then echo "✓ $t"; grep "^- skipped" "$LOG" | sed "s/^/    /"
  else echo "✗ $t"; { grep "✗" "$LOG"; echo "    …"; tail -20 "$LOG"; } | sed "s/^/    /"; FAIL=1; fi
done
exit $FAIL
