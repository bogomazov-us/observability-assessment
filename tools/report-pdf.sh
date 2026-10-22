#!/usr/bin/env bash
# Build one stage report (or its evidence bundle) into a PDF with the kit's report style,
# then check it. See templates/stage-report.md.
#
#   tools/report-pdf.sh --project NAME --stage "3 Gap" --version COMMIT --out FILE.pdf \
#       [--title TITLE] [--landscape] [--no-toc] [--ids REGEX] FILE.md [FILE.md ...]
#
# Sources are plain Markdown, concatenated in order. Relative links keep their text only
# (the target is not in the PDF); web links stay live. The footer carries project, stage,
# version and page; the build history goes to the PDF metadata.
# Checks after the build: every id the sources cite (default: L-, E-, G-, F-, D-, REC- with
# two or three digits) is found in the PDF's text; every font is embedded.
# Needs pandoc, weasyprint, pdftotext, pdffonts.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PROJECT=""; STAGE=""; VERSION=""; OUT=""; TITLE=""; LANDSCAPE=""; TOC="--toc"
IDS='\b(L|E|G|F|D|REC)-[0-9]{2,3}\b'
FILES=()
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --stage) STAGE="$2"; shift 2 ;;
    --version) VERSION="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --landscape) LANDSCAPE=1; shift ;;
    --no-toc) TOC=""; shift ;;
    --ids) IDS="$2"; shift 2 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) FILES+=("$1"); shift ;;
  esac
done
[ -n "$PROJECT" ] && [ -n "$STAGE" ] && [ -n "$VERSION" ] && [ -n "$OUT" ] && [ ${#FILES[@]} -gt 0 ] || {
  echo "usage: report-pdf.sh --project NAME --stage STAGE --version COMMIT --out FILE.pdf FILE.md..." >&2; exit 2; }
for f in "${FILES[@]}"; do [ -f "$f" ] || { echo "missing source: $f" >&2; exit 2; }; done
[ -n "$TITLE" ] || TITLE="Observability assessment — stage $STAGE"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
: > "$TMP/src.md"
for f in "${FILES[@]}"; do
  perl -pe 's/\[([^\]]+)\]\((?!https?:)[^)]*\)/$1/g' "$f" >> "$TMP/src.md"
  printf '\n\n' >> "$TMP/src.md"
done
# The first heading of the sources is the title; the title block repeats it otherwise.
perl -0pi -e 's/\A\s*# [^\n]*\n//' "$TMP/src.md"

pandoc "$TMP/src.md" -f gfm -t html5 -s $TOC --toc-depth=2 -M document-css=false \
  --metadata title="$TITLE" --metadata date="$PROJECT · version $VERSION" \
  --metadata keywords="built $(date -u +%Y-%m-%dT%H:%MZ) from ${FILES[*]##*/}" \
  -o "$TMP/report.html"
{
  printf '@page { @bottom-left { content: "%s · stage %s · %s"; font: 8.5pt "IBM Plex Sans", Helvetica, Arial, sans-serif; color: #4b5563; } }\n' \
    "$PROJECT" "$STAGE" "$VERSION"
  [ -n "$LANDSCAPE" ] && printf '@page { size: A4 landscape; }\n'
} > "$TMP/page.css"
mkdir -p "$(dirname "$OUT")"
weasyprint -q -s "$HERE/report.css" -s "$TMP/page.css" "$TMP/report.html" "$OUT"

FAIL=0
# Form checks on the sources: no HTML for print effects; wide tables are named.
HTML="$(perl -ne '$c=!$c if /^\s*```/; print "$ARGV:$.: $_" if !$c && /<\/?(div|span|br|p|table|font|style)\b/i' "${FILES[@]}")"
[ -n "$HTML" ] && { echo "✗ HTML in the Markdown (print effects belong in the export style):"; echo "$HTML" | head -5; FAIL=1; }
perl -ne '$c=!$c if /^\s*```/; if (!$c && /^\|.*\|\s*$/ && !/^\|[\s:|-]+\|\s*$/) { $n=()=/\|/g; print "! $ARGV:$.: table of ".($n-1)." columns; at most four of running text\n" if $n-1>5 && !$seen{"$ARGV"}{$n}++ }' "${FILES[@]}"
TEXT="$(pdftotext "$OUT" - | tr -s ' \n' ' ')"
MISSING="$(grep -ohE "$IDS" "$TMP/src.md" | sort -u | while read -r id; do
  printf '%s' "$TEXT" | grep -qF -- "$id" || echo "$id"; done)"
[ -n "$MISSING" ] && { echo "✗ ids cited in the sources but not found in the PDF text:"; echo "$MISSING" | head -20; FAIL=1; }
pdffonts "$OUT" | awk 'NR>2 && $(NF-4)!="yes" {bad=1} END {exit bad}' || { echo "✗ a font is not embedded"; FAIL=1; }
[ $FAIL -eq 0 ] && echo "✓ $OUT"
exit $FAIL
