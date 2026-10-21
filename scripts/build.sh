#!/usr/bin/env bash
# Build the kit into one PDF: dist/observability-assessment-kit-v<version>.pdf
#   scripts/build.sh              build into dist/
#   scripts/build.sh --downloads  build and copy to ~/Downloads (local use)
# Needs pandoc and weasyprint. Same script runs locally and in CI.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
source scripts/files.sh

VERSION="$(scripts/version.sh)"
DATE="$(date -u +%Y-%m-%d)"
OUT="dist/observability-assessment-kit-v${VERSION}.pdf"
mkdir -p dist
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

: > "$TMP/kit.md"
for f in "${KIT_FILES[@]}"; do
  # relative links do not work inside one PDF: keep the link text only
  perl -pe 's/\[([^\]]+)\]\((?!https?:)[^)]*\)/$1/g' "$f" >> "$TMP/kit.md"
  printf '\n\n' >> "$TMP/kit.md"
done

pandoc "$TMP/kit.md" -f gfm -t html5 -s --toc --toc-depth=1 \
  --metadata title="Observability Assessment Kit" -M document-css=false \
  --metadata subtitle="Method, templates and practice for observability and SRE assessments" \
  --metadata author="Ivan Bogomazov · bogomazov.us" \
  --metadata date="v${VERSION} · ${DATE} · CC BY 4.0" \
  -o "$TMP/kit.html"
weasyprint -s scripts/pdf.css "$TMP/kit.html" "$OUT"

if [ "${1:-}" = "--downloads" ]; then cp "$OUT" "$HOME/Downloads/"; echo "$HOME/Downloads/$(basename "$OUT")"; else echo "$OUT"; fi
