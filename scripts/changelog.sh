#!/usr/bin/env bash
# Prints the CHANGELOG.md section of a version (default: the README version), without its heading.
# Exit 1 when the section is missing or empty. Used by the guardrails and by the release notes.
set -euo pipefail
cd "$(dirname "$0")/.."
V="${1:-$(scripts/version.sh)}"; V="${V#v}"
OUT="$(awk -v v="$V" '
  /^## / { if (on) exit; on = ($2 == v) ; next }
  on' CHANGELOG.md | sed -e '/./,$!d' | sed -e ':a' -e '/^\n*$/{$d;N;ba' -e '}')"
[ -n "$OUT" ] || { echo "CHANGELOG.md has no section for $V" >&2; exit 1; }
printf '%s\n' "$OUT"
