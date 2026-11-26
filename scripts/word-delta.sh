#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Word delta of the Markdown in method/, tools/agent/, sre/ and README.md against a base ref.
# Informational: prints the counts and always exits 0 (except on a bad ref).
#   scripts/word-delta.sh [BASE]    BASE defaults to origin/main, else main
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2
BASE="${1:-}"
if [ -z "$BASE" ]; then
  for b in origin/main main; do git rev-parse -q --verify "$b^{commit}" >/dev/null && { BASE="$b"; break; }; done
fi
[ -n "$BASE" ] && git rev-parse -q --verify "$BASE^{commit}" >/dev/null \
  || { echo "word-delta: base ref not found: ${BASE:-origin/main or main}" >&2; exit 2; }

PATHS=(method tools/agent sre README.md)
words_base() { git ls-tree -r --name-only "$BASE" -- "${PATHS[@]}" | grep '\.md$' \
  | while IFS= read -r f; do git show "$BASE:$f"; done | wc -w; }
words_head() { git ls-files --cached --others --exclude-standard -- "${PATHS[@]}" | grep '\.md$' \
  | while IFS= read -r f; do [ -f "$f" ] && cat "$f"; done | wc -w; }

echo "Word delta against $BASE ($(git rev-parse --short "$BASE")):"
for p in "${PATHS[@]}"; do
  b=$(( $(PATHS=("$p"); words_base) )); h=$(( $(PATHS=("$p"); words_head) ))
  printf '  %-14s %6d → %6d  (%+d)\n' "$p" "$b" "$h" $(( h - b ))
done
b=$(( $(words_base) )); h=$(( $(words_head) ))
printf '  %-14s %6d → %6d  (%+d)\n' total "$b" "$h" $(( h - b ))
exit 0
