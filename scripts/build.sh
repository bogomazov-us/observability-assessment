#!/usr/bin/env bash
# Build the kit into one PDF: dist/observability-assessment-kit-v<version>.pdf
#   scripts/build.sh                       build into dist/
#   scripts/build.sh --downloads           build and copy to ~/Downloads (local use)
#   scripts/build.sh --config FILE [--downloads]
#       build an edition defined outside this repository: FILE is a bash file that may set
#       KIT_TITLE, KIT_SUBTITLE, KIT_AUTHOR, KIT_LICENCE, KIT_FOOTER, KIT_NAME, KIT_OUT_DIR
#       and KIT_FILES (paths relative to this repository, or absolute). CONFIG_DIR is set to
#       the directory of FILE before it is read.
# Needs pandoc and weasyprint. Same script runs locally and in CI.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG=""; DOWNLOADS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --config) CONFIG="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"; shift 2 ;;
    --downloads) DOWNLOADS=1; shift ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done
cd "$ROOT"
source scripts/files.sh

KIT_TITLE="Observability Assessment Kit"
KIT_SUBTITLE="Method, templates and practice for observability and SRE assessments"
KIT_AUTHOR="Ivan Bogomazov · bogomazov.us"
KIT_LICENCE="CC BY 4.0"
KIT_FOOTER="Observability Assessment Kit · CC BY 4.0"
KIT_NAME="observability-assessment-kit"
KIT_OUT_DIR="$ROOT/dist"
if [ -n "$CONFIG" ]; then CONFIG_DIR="$(dirname "$CONFIG")"; source "$CONFIG"; fi

VERSION="$(scripts/version.sh)"
DATE="$(date -u +%Y-%m-%d)"
mkdir -p "$KIT_OUT_DIR"
OUT="$KIT_OUT_DIR/${KIT_NAME}-v${VERSION}.pdf"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

: > "$TMP/kit.md"
for f in "${KIT_FILES[@]}"; do
  # relative links do not work inside one PDF: keep the link text only.
  # Spec-set skeletons are demoted one level so they run on under the spec-set page
  # instead of each starting a new, mostly empty page.
  demote=0
  case "$f" in templates/spec-set/README.md) ;; templates/spec-set/*) demote=1 ;; esac
  perl -pe 's/\[([^\]]+)\]\((?!https?:)[^)]*\)/$1/g;
    if (/^\s*```/) { $c = !$c } elsif (!$c && '"$demote"' && /^#{1,5} /) { s/^/#/ }' "$f" >> "$TMP/kit.md"
  printf '\n\n' >> "$TMP/kit.md"
done

pandoc "$TMP/kit.md" -f gfm -t html5 -s --toc --toc-depth=1 \
  --metadata title="$KIT_TITLE" -M document-css=false \
  --metadata subtitle="$KIT_SUBTITLE" \
  --metadata author="$KIT_AUTHOR" \
  --metadata date="v${VERSION} · ${DATE}${KIT_LICENCE:+ · $KIT_LICENCE}" \
  -o "$TMP/kit.html"
printf '@page { @bottom-left { content: "%s"; } }\n@page :first { @bottom-left { content: none; } }\n' "$KIT_FOOTER" > "$TMP/footer.css"
weasyprint -s scripts/pdf.css -s "$TMP/footer.css" "$TMP/kit.html" "$OUT"

if [ -n "$DOWNLOADS" ]; then cp "$OUT" "$HOME/Downloads/"; echo "$HOME/Downloads/$(basename "$OUT")"; else echo "$OUT"; fi
