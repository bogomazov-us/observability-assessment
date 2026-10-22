#!/usr/bin/env bash
# Build one stage report (or its evidence bundle) into a PDF with the kit's report style,
# then check it. See templates/stage-report.md.
#
#   tools/report-pdf.sh --project NAME --stage "3 Gap" --version COMMIT --out FILE.pdf \
#       [--title TITLE] [--landscape] [--no-toc] [--ids REGEX] [--external FILE]...
#       FILE.md [FILE.md ...]
#
# Sources are plain Markdown, concatenated in order. Relative links keep their text only
# (the target is not in the PDF); web links stay live. The footer carries project, stage,
# version and page; the build history goes to the PDF metadata.
# Checks: every id the sources cite (default: L-, E-, G-, F-, D-, REC- with two or three
# digits) is found in the PDF's text; every font is embedded; no HTML in the Markdown. When the
# sources hold an evidence catalog — headings "### E-NNN — name", or table rows whose first cell
# is the id — every cited E- id resolves to an entry here or in an --external file (another
# stage's report, not rendered), no entry id is repeated, and each entry states its window
# ("Checked at" or "window"), "Result" and "Limits" (for a table: those columns, filled).
# Needs pandoc, weasyprint, pdftotext, pdffonts.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PROJECT=""; STAGE=""; VERSION=""; OUT=""; TITLE=""; LANDSCAPE=""; TOC="--toc"
IDS='\b(L|E|G|F|D|REC)-[0-9]{2,3}\b'
FILES=(); EXTERNAL=()
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
    --external) EXTERNAL+=("$2"); shift 2 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) FILES+=("$1"); shift ;;
  esac
done
[ -n "$PROJECT" ] && [ -n "$STAGE" ] && [ -n "$VERSION" ] && [ -n "$OUT" ] && [ ${#FILES[@]} -gt 0 ] || {
  echo "usage: report-pdf.sh --project NAME --stage STAGE --version COMMIT --out FILE.pdf FILE.md..." >&2; exit 2; }
for f in "${FILES[@]}"; do [ -f "$f" ] || { echo "missing source: $f" >&2; exit 2; }; done
# The footer and the title say "stage" themselves; "--stage 'Stage 5'" would print it twice.
STAGE="${STAGE#[Ss]tage }"
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
"$HERE/wide-tables.pl" "$TMP/report.html"
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
# Evidence catalog: references resolve, ids are unique, entries carry their fields.
catalog_ids() { perl -ne 'print "$1\n" if /^#{2,4} (E-\d{2,3})\b/ || /^\|\s*(E-\d{2,3})\s*\|/' "$@"; }
CAT="$(catalog_ids "${FILES[@]}")"
if [ -n "$CAT" ]; then
  DUP="$(echo "$CAT" | sort | uniq -d)"
  [ -n "$DUP" ] && { echo "✗ evidence ids defined more than once: $(echo $DUP)"; FAIL=1; }
  DEFINED="$(printf '%s\n' "$CAT"; if [ ${#EXTERNAL[@]} -gt 0 ]; then catalog_ids "${EXTERNAL[@]}"; fi)"
  UNRES="$(grep -ohE '\bE-[0-9]{2,3}\b' "${FILES[@]}" | sort -u | grep -vxF -f <(echo "$DEFINED" | sort -u) || true)"
  [ -n "$UNRES" ] && { echo "✗ evidence ids cited without a catalog entry: $(echo $UNRES | head -c 300)"; FAIL=1; }
  BAD="$(perl -ne 'if (/^#{2,4} (E-\d{2,3})\b/) { check(); $id=$1; $b=""; next } if (/^#{1,4} /) { check(); $id=""; next } $b.=$_ if $id;
      sub check { return unless $id; my @m; push @m,"window" unless $b=~/checked at|window/i; push @m,"result" unless $b=~/\bresult\b/i; push @m,"limits" unless $b=~/\blimits?\b/i; print "$id (no ".join(", ",@m).")\n" if @m }
      END { check() }' "${FILES[@]}")
$(perl -ne 'chomp; my @c = map { s/^\s+|\s+$//gr } split /\|/, $_, -1; shift @c; pop @c;
      if (/^\|[\s:|-]+\|\s*$/) { @h = @prev; next } @prev = @c;
      next unless @c && $c[0] =~ /^E-\d{2,3}$/ && @h;
      my %i; for my $k (0..$#h) { my $n = lc $h[$k]; $i{w} //= $k if $n =~ /window|checked/; $i{r} //= $k if $n =~ /^result/; $i{l} //= $k if $n =~ /^limits?/ }
      my @m; for (["w","window"],["r","result"],["l","limits"]) { my ($k,$n)=@$_; push @m,$n if !defined $i{$k} || ($c[$i{$k}] // "") !~ /\S/ }
      print "$c[0] (no ".join(", ",@m).")\n" if @m' "${FILES[@]}")"
  BAD="$(printf '%s\n' "$BAD" | sed '/^[[:space:]]*$/d')"
  [ -n "$BAD" ] && { echo "✗ evidence entries missing a field:"; echo "$BAD" | head -10; FAIL=1; }
fi
TEXT="$(pdftotext "$OUT" - | tr -s ' \n' ' ')"
MISSING="$(grep -ohE "$IDS" "$TMP/src.md" | sort -u | while read -r id; do
  printf '%s' "$TEXT" | grep -qF -- "$id" || echo "$id"; done)"
[ -n "$MISSING" ] && { echo "✗ ids cited in the sources but not found in the PDF text:"; echo "$MISSING" | head -20; FAIL=1; }
pdffonts "$OUT" | awk 'NR>2 && $(NF-4)!="yes" {bad=1} END {exit bad}' || { echo "✗ a font is not embedded"; FAIL=1; }
[ $FAIL -eq 0 ] && echo "✓ $OUT"
exit $FAIL
