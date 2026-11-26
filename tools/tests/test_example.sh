#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# The worked example passes the kit's tools, so it cannot fall behind the method silently.
# A failure names the example file and the tool's own output.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2
# The PDF build needs pandoc, weasyprint and poppler; without them the test says so and skips,
# unless KIT_REQUIRE_PDF_TOOLS is set (CI), where a missing tool is a failure.
pdf_tools() {
  local t; for t in pandoc weasyprint pdftotext pdffonts; do
    command -v "$t" >/dev/null && continue
    [ -n "${KIT_REQUIRE_PDF_TOOLS:-}" ] && { echo "✗ $t not found, and KIT_REQUIRE_PDF_TOOLS is set"; return 2; }
    echo "- skipped: $1: $t not found (needs pandoc, weasyprint, pdftotext, pdffonts)"; return 1
  done
}
FAIL=0
check() {  # file, description, command...
  local file="$1" what="$2"; shift 2
  local out code
  out="$("$@" 2>&1)"; code=$?
  if [ $code -eq 0 ]; then echo "✓ $file: $what"
  else echo "✗ $file: $what (exit $code)"; sed 's/^/    /' <<<"$out"; FAIL=1; fi
}

check example/worked-example.spec.yml "speclint --strict" \
  python3 tools/speclint.py --strict example/worked-example.spec.yml
check example/maturity.yml "maturity.py" \
  python3 tools/maturity.py example/maturity.yml
check example/agent/engagement-state.yml "stagegate lint" \
  python3 tools/stagegate.py lint example/agent/engagement-state.yml
check example/agent/engagement-state.yml "stagegate check 4 opens at stage 3 confirmed" \
  python3 tools/stagegate.py check example/agent/engagement-state.yml 4

# lint prints warnings with exit 0; the example carries none
out="$(python3 tools/stagegate.py lint example/agent/engagement-state.yml 2>&1)"
[ -z "$out" ] && echo "✓ example/agent/engagement-state.yml: no warnings" \
  || { echo "✗ example/agent/engagement-state.yml: warnings"; sed 's/^/    /' <<<"$out"; FAIL=1; }

# The harness measures read from the example's records: the re-checks as a selected sample
for s in example/agent/engagement-state.yml sre/example/agent/engagement-state.yml; do
  check "$s" "harness-metrics.py" python3 tools/harness-metrics.py "$s"
  python3 tools/harness-metrics.py "$s" 2>&1 | grep -q "2 of 2 selected reproduced" \
    && echo "✓ $s: re-checks 2 of 2 selected" || { echo "✗ $s: re-checks not read"; FAIL=1; }
done

# The SRE example: its profile alone and beside the observability one, its state file, and its
# baseline as the tool prints it on the exports exports.sh writes.
check sre/example/maturity.yml "maturity.py" \
  python3 tools/maturity.py sre/example/maturity.yml
check sre/example/maturity.yml "maturity.py --pair with example/maturity.yml" \
  python3 tools/maturity.py --pair example/maturity.yml sre/example/maturity.yml
check sre/example/agent/engagement-state.yml "stagegate lint" \
  python3 tools/stagegate.py lint sre/example/agent/engagement-state.yml
check sre/example/agent/engagement-state.yml "stagegate check 2 opens at stage 1 confirmed" \
  python3 tools/stagegate.py check sre/example/agent/engagement-state.yml 2
out="$(python3 tools/stagegate.py lint sre/example/agent/engagement-state.yml 2>&1)"
[ -z "$out" ] && echo "✓ sre/example/agent/engagement-state.yml: no warnings" \
  || { echo "✗ sre/example/agent/engagement-state.yml: warnings"; sed 's/^/    /' <<<"$out"; FAIL=1; }

# baseline.md from "## Incidents" up to "## Counted from other exports", without the ID column,
# is the tool's output without its "# Baseline" title and the blank line after it.
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
ROOT="$PWD"
bash sre/example/exports.sh "$TMP"
( cd "$TMP" && python3 "$ROOT/tools/baseline.py" sre/exports/incidents-2027-06-08.csv \
    --map severity=priority --deploys sre/exports/deploys-2027-06-08.csv \
    --pages sre/exports/pages-2027-06-08.csv ) | sed '1,2d' > "$TMP/tool.md"
awk '/^## Incidents/{on=1} /^## Counted from other exports/{on=0} on' sre/example/baseline.md \
  | sed -E 's/^\|[^|]*\|/|/' | sed '${/^$/d;}' > "$TMP/file.md"
check sre/example/baseline.md "reproduced by baseline.py from exports.sh" \
  diff "$TMP/file.md" "$TMP/tool.md"

# The SRE example's catalogue and targets as the report carries them: the narrow tables in the
# report, the full files in the evidence bundle, with no wide-table note on either.
pdf_tools "sre/example: report build"; pt=$?
[ $pt -eq 2 ] && FAIL=1
if [ $pt -eq 0 ]; then
  mkdir -p "$TMP/pdf"
  cp sre/example/worked-example.md sre/example/service-catalogue.md sre/example/reliability-targets.md "$TMP/pdf/"
  printf 'assessment sre\nreport    worked-example.md  Catalogue\nevidence  service-catalogue.md\nevidence  reliability-targets.md\n' \
    > "$TMP/pdf/manifest.txt"
  out="$(tools/assessment-pdf.sh --manifest "$TMP/pdf/manifest.txt" --project Example --version test \
    --out-dir "$TMP/pdf/out" 2>&1)"; code=$?
  if [ $code -eq 0 ] && ! grep -q "columns; at most four\|no section matches" <<<"$out"; then
    echo "✓ sre/example: catalogue and targets build narrow in the report, whole in the bundle"
  else echo "✗ sre/example: report build (exit $code)"; sed 's/^/    /' <<<"$out"; FAIL=1; fi
fi

# E- ids are one sequence per engagement across types (method/records.md): the SRE example
# continues each stage's block after the observability example's ids, never reuses one.
ids() { grep -rhoE '\bE-[0-9]{3}\b' "$1" | sort -u; }
dup="$(comm -12 <(ids example) <(ids sre/example) | tr '\n' ' ')"
[ -z "$dup" ] && echo "✓ sre/example: no E- id shared with example/" \
  || { echo "✗ sre/example: E- ids also used in example/: $dup"; FAIL=1; }

exit $FAIL
