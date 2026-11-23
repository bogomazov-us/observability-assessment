#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Build the two documents of a whole assessment from its stage sources (method/report.md,
# "One report for the whole assessment"): the assessment report — the summary chapter, then a
# chapter per accepted stage — and the evidence bundle. Each is built and checked by
# tools/report-pdf.sh.
#
#   tools/assessment-pdf.sh --manifest FILE --project NAME --version COMMIT --out-dir DIR \
#       [--name PREFIX]
#
# The manifest format is a contract: other renderers read it too, so a change here is a change
# of the format, documented here and in method/report.md ("The manifest").
#
#   # a comment                         blank lines and lines starting with "#" are ignored
#   assessment  sre                      the report's type: observability or sre; repeat for both
#   report      summary.md               a whole file
#   report      inventory.md   1 2 3 5   its sections 1, 2, 3 and 5
#   evidence    inventory.md   4 A       its section 4 and Appendix A
#   evidence    findings/F-001.md
#
# - A line is whitespace-separated words: the document (report | evidence), the source path
#   relative to the manifest's folder (no spaces), then the selectors, if any. Any other first
#   word, an "assessment" value other than observability or sre, or a missing source is an
#   error (exit 2), as is a manifest with no report line.
# - Each line is one chapter of its document, in the order listed; a file may be listed on
#   several lines. The two documents are the assessment report and the evidence bundle.
# - Selection: no selector takes the whole file. A selector takes each "## " section whose
#   heading starts with it, after an optional "Appendix ", as a whole word: "1" takes
#   "## 1. Result" and not "## 10. …"; "A" takes "## Appendix A. …". A section runs to the next
#   "## " heading, its "### " subsections with it. With selectors, text before the first "## "
#   is dropped; a file without "## " sections gives a chapter of its title only, so it is
#   listed without selectors. A selector that matches no section is reported (not an error).
# - Title: the file's first "# " heading is the chapter title, with a leading
#   "Observability assessment", "SRE assessment" or "Observability and SRE assessment" and its
#   separator (an em dash, a comma or a hyphen) removed, case aside, and the first letter
#   raised: "# SRE assessment — stage 1: inventory" gives "Stage 1: inventory". The title is
#   read before any selection; a file without a "# " heading has an empty title.
# - Types: "assessment" lines, anywhere in the file, name them. Without one the types follow
#   the sources: a path under sre/ makes it SRE, any other path observability, except
#   summary.md, owner-questions.md and findings/, which are shared. The types set the title
#   ("Observability", "SRE" or "Observability and SRE assessment") and the default --name
#   (observability-assessment, sre-assessment or observability-sre-assessment); the files are
#   NAME-report-VERSION.pdf and NAME-evidence-VERSION.pdf.
#
# Checks: the evidence bundle's catalog is checked by tools/report-pdf.sh: an entry is a heading
# "### E-NNN — name" with "Checked at:" or "Data window:", "Result:" and "Limits:" lines, or a
# table row whose first cell is the E- id under columns named Window (or Checked at), Result
# and Limits, each filled. Evidence ids cited in the report resolve against the evidence bundle.
# A table wider than five columns is noted in the report, which keeps running text; the bundle
# holds records, set landscape, and is built without that note. The file names are those of
# the path table in tools/agent/setup.md ("Artifact paths").
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
  SEL="$sel" SRC="$file" perl -CSD -Mutf8 -e '
    my @sel = split " ", ($ENV{SEL} // ""); my ($title, $keep, $out, %hit) = ("", !@sel, "");
    while (<>) {
      if (!$title && /^# (.*)/) { ($title = $1) =~ s/^(Observability|SRE)( and SRE)? assessment\s*[,—-]\s*//i; $title = ucfirst $title; next }
      if (/^## (.*)/) { my $h = $1; my @m = grep { $h =~ /^(Appendix\s+)?\Q$_\E\b/ } @sel; $hit{$_}++ for @m; $keep = !@sel || @m }
      $out .= $_ if $keep;
    }
    print STDERR "manifest: $ENV{SRC}: no section matches \"$_\"\n" for grep { !$hit{$_} } @sel;
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
  # The bundle's records keep their columns: report-pdf.sh's note on wide tables is for the report.
  "$HERE/report-pdf.sh" --project "$PROJECT" --stage "evidence" --part "evidence" --version "$VERSION" \
    --title "$KIND — evidence" --out "$OUTDIR/$NAME-evidence-$VERSION.pdf" \
    "$TMP/00-title.md" "${EVIDENCE[@]}" > "$TMP/evidence.log" || FAIL=1
  grep -v 'columns; at most four of running text$' "$TMP/evidence.log" || true
  for f in "${EVIDENCE[@]}"; do EXT+=(--external "$f"); done
fi
"$HERE/report-pdf.sh" --project "$PROJECT" --stage "report" --part "assessment report" --version "$VERSION" \
  --title "$KIND — $PROJECT" --out "$OUTDIR/$NAME-report-$VERSION.pdf" \
  ${EXT[@]+"${EXT[@]}"} "$TMP/00-title.md" "${REPORT[@]}" || FAIL=1
exit $FAIL
