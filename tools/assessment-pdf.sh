#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Build the two documents of a whole assessment from its stage sources (templates/stage-report.md,
# "One report for the whole assessment"): the assessment report — the summary chapter, then a
# chapter per accepted stage — and the evidence bundle. Each is built and checked by
# tools/report-pdf.sh.
#
#   tools/assessment-pdf.sh --manifest FILE --project NAME --version COMMIT --out-dir DIR \
#       [--name PREFIX]
#
# The manifest lists the sources in reading order, one per line, paths relative to the manifest:
#
#   report    summary.md
#   report    inventory.md         1 2 3 5
#   evidence  inventory.md         4 A
#   evidence  findings/F-001.md
#
# The first word is the document (report | evidence); the optional words after the file select
# its "## " sections by the start of their heading ("1" takes "## 1. Result", "A" takes
# "## Appendix A. …"); none takes the whole file. A file's "# " heading becomes its chapter
# title, without "Observability assessment — " or "SRE assessment — ". Blank lines and "#"
# comments are ignored.
#
#   assessment  sre
#
# names a type of the report (repeat for both). Without such a line the types follow the
# sources: one under sre/ makes it SRE, one elsewhere (other than summary.md, findings/ and
# owner-questions.md, which are shared) observability. The types set the title ("Observability",
# "SRE" or "Observability and SRE assessment") and the default --name (observability-assessment,
# sre-assessment or observability-sre-assessment).
# The evidence bundle's catalog is checked by tools/report-pdf.sh: an entry is a heading
# "### E-NNN — name" with "Checked at:" or "Data window:", "Result:" and "Limits:" lines, or a
# table row whose first cell is the E- id under columns named Window (or Checked at), Result
# and Limits, each filled.
# Evidence ids cited in the report resolve against the evidence bundle. The file names are those of
# the path table in tools/agent/README.md ("Artifact paths").
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
MANIFEST=""; PROJECT=""; VERSION=""; OUTDIR=""; NAME=""
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
n=0; REPORT=(); EVIDENCE=(); TYPES=" "; SEEN=" "
while read -r part file sel; do
  case "$part" in
    ''|\#*) continue ;;
    assessment) case "$file" in observability|sre) TYPES="$TYPES$file " ;; *) echo "manifest: assessment is observability or sre, not '$file'" >&2; exit 2 ;; esac; continue ;;
    report|evidence) ;;
    *) echo "manifest: unknown document '$part'" >&2; exit 2 ;;
  esac
  case "$file" in sre/*) SEEN="${SEEN}sre " ;; summary.md|owner-questions.md|findings/*) ;; *) SEEN="${SEEN}observability " ;; esac
  [ -f "$BASE/$file" ] || { echo "manifest: missing source $file" >&2; exit 2; }
  n=$((n+1)); ch="$TMP/$(printf '%02d' $n)-$part-${file##*/}"
  SEL="$sel" perl -CSD -Mutf8 -e '
    my @sel = split " ", ($ENV{SEL} // ""); my ($title, $keep, $out) = ("", !@sel, "");
    while (<>) {
      if (!$title && /^# (.*)/) { ($title = $1) =~ s/^(Observability|SRE)( and SRE)? assessment\s*[,—-]\s*//i; $title = ucfirst $title; next }
      if (/^## (.*)/) { my $h = $1; $keep = !@sel || grep { $h =~ /^(Appendix\s+)?\Q$_\E\b/ } @sel }
      $out .= $_ if $keep;
    }
    print "# $title\n\n$out";' "$BASE/$file" > "$ch"
  if [ "$part" = report ]; then REPORT+=("$ch"); else EVIDENCE+=("$ch"); fi
done < "$MANIFEST"
[ ${#REPORT[@]} -gt 0 ] || { echo "manifest: no report sources" >&2; exit 2; }
[ "$TYPES" != " " ] || TYPES="$SEEN"
case "$TYPES" in
  *" observability "*" sre "*|*" sre "*" observability "*) KIND="Observability and SRE assessment"; DEF="observability-sre-assessment" ;;
  *" sre "*) KIND="SRE assessment"; DEF="sre-assessment" ;;
  *) KIND="Observability assessment"; DEF="observability-assessment" ;;
esac
NAME="${NAME:-$DEF}"

# report-pdf.sh drops the first heading of its sources as the title; give it one to drop.
printf '# title\n' > "$TMP/00-title.md"
mkdir -p "$OUTDIR"
FAIL=0
EXT=()
if [ ${#EVIDENCE[@]} -gt 0 ]; then
  "$HERE/report-pdf.sh" --project "$PROJECT" --stage "evidence" --part "evidence" --version "$VERSION" \
    --title "$KIND — evidence" --out "$OUTDIR/$NAME-evidence-$VERSION.pdf" \
    "$TMP/00-title.md" "${EVIDENCE[@]}" || FAIL=1
  for f in "${EVIDENCE[@]}"; do EXT+=(--external "$f"); done
fi
"$HERE/report-pdf.sh" --project "$PROJECT" --stage "report" --part "assessment report" --version "$VERSION" \
  --title "$KIND — $PROJECT" --out "$OUTDIR/$NAME-report-$VERSION.pdf" \
  ${EXT[@]+"${EXT[@]}"} "$TMP/00-title.md" "${REPORT[@]}" || FAIL=1
exit $FAIL
