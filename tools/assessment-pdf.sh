#!/usr/bin/env bash
# Build the two documents of a whole assessment from its stage sources (templates/stage-report.md,
# "One report for the whole assessment"): the assessment report, which grows by a chapter per
# stage, and the evidence bundle. Each is built and checked by tools/report-pdf.sh.
#
#   tools/assessment-pdf.sh --manifest FILE --project NAME --version COMMIT --out-dir DIR \
#       [--name PREFIX]
#
# The manifest lists the sources in reading order, one per line, paths relative to the manifest:
#
#   report    summary.md
#   report    stage-1-report.md    1 2 3 5
#   evidence  stage-1-report.md    4 A
#   evidence  stage-6-rechecks.md
#
# The first word is the document (report | evidence); the optional words after the file select
# its "## " sections by the start of their heading ("1" takes "## 1. Result", "A" takes
# "## Appendix A. …"); none takes the whole file. A file's "# " heading becomes its chapter
# title, without "Observability assessment — ". Blank lines and "#" comments are ignored.
# Evidence ids cited in the report resolve against the evidence bundle.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
MANIFEST=""; PROJECT=""; VERSION=""; OUTDIR=""; NAME="observability-assessment"
while [ $# -gt 0 ]; do
  case "$1" in
    --manifest) MANIFEST="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --version) VERSION="$2"; shift 2 ;;
    --out-dir) OUTDIR="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
[ -n "$MANIFEST" ] && [ -n "$PROJECT" ] && [ -n "$VERSION" ] && [ -n "$OUTDIR" ] || {
  echo "usage: assessment-pdf.sh --manifest FILE --project NAME --version COMMIT --out-dir DIR" >&2; exit 2; }
BASE="$(cd "$(dirname "$MANIFEST")" && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# One temporary chapter file per manifest line, holding the selected sections.
n=0; REPORT=(); EVIDENCE=()
while read -r part file sel; do
  case "$part" in ''|\#*) continue ;; report|evidence) ;; *) echo "manifest: unknown document '$part'" >&2; exit 2 ;; esac
  [ -f "$BASE/$file" ] || { echo "manifest: missing source $file" >&2; exit 2; }
  n=$((n+1)); ch="$TMP/$(printf '%02d' $n)-$part-${file##*/}"
  SEL="$sel" perl -CSD -Mutf8 -e '
    my @sel = split " ", ($ENV{SEL} // ""); my ($title, $keep, $out) = ("", !@sel, "");
    while (<>) {
      if (!$title && /^# (.*)/) { ($title = $1) =~ s/^Observability assessment\s*[—-]\s*//i; next }
      if (/^## (.*)/) { my $h = $1; $keep = !@sel || grep { $h =~ /^(Appendix\s+)?\Q$_\E\b/ } @sel }
      $out .= $_ if $keep;
    }
    print "# $title\n\n$out";' "$BASE/$file" > "$ch"
  if [ "$part" = report ]; then REPORT+=("$ch"); else EVIDENCE+=("$ch"); fi
done < "$MANIFEST"
[ ${#REPORT[@]} -gt 0 ] || { echo "manifest: no report sources" >&2; exit 2; }

# report-pdf.sh drops the first heading of its sources as the title; give it one to drop.
printf '# title\n' > "$TMP/00-title.md"
mkdir -p "$OUTDIR"
FAIL=0
EXT=()
if [ ${#EVIDENCE[@]} -gt 0 ]; then
  "$HERE/report-pdf.sh" --project "$PROJECT" --stage "evidence" --part "evidence" --version "$VERSION" \
    --title "Observability assessment — evidence" --out "$OUTDIR/$NAME-evidence-$VERSION.pdf" \
    "$TMP/00-title.md" "${EVIDENCE[@]}" || FAIL=1
  for f in "${EVIDENCE[@]}"; do EXT+=(--external "$f"); done
fi
"$HERE/report-pdf.sh" --project "$PROJECT" --stage "report" --part "assessment report" --version "$VERSION" \
  --title "Observability assessment — $PROJECT" --out "$OUTDIR/$NAME-report-$VERSION.pdf" \
  ${EXT[@]+"${EXT[@]}"} "$TMP/00-title.md" "${REPORT[@]}" || FAIL=1
exit $FAIL
