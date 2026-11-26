#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Lints the code: shellcheck on every tracked shell script (warnings and errors), ruff on the Python
# tools (rules in ruff.toml: syntax errors and pyflakes). In CI a missing linter is a failure;
# locally it is skipped with a note.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2
FAIL=0
ok() { echo "✓ $*"; }
missing() { if [ -n "${CI:-}" ]; then echo "✗ $1 not installed"; FAIL=1; else echo "! $1 not installed locally: skipped"; fi; }

SH=(); while IFS= read -r f; do SH+=("$f"); done < <(git ls-files '*.sh')
if command -v shellcheck >/dev/null; then
  shellcheck -S warning "${SH[@]}" && ok "shellcheck: ${#SH[@]} scripts" || FAIL=1
else missing shellcheck; fi

if command -v ruff >/dev/null; then
  ruff check --no-cache --quiet . && ok "ruff: Python tools" || FAIL=1
else missing ruff; fi
exit $FAIL
