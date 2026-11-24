#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/recordcheck.py on the fictional records in fixtures/records/: both assessment
# types pass as written; each rule is tripped by breaking a copy, one change at a time; the
# catalog check that tools/report-pdf.sh runs and the finding check agree on the same catalog.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../recordcheck.py"
fx="$here/fixtures/records"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
ok() { echo "✓ $*"; }
ko() { echo "✗ $*"; fail=1; }
run() { set +e; out="$("$@" 2>&1)"; code=$?; set -e; }
full() {  # full DIR: the finding check with every record given
  run "$tool" findings "$1"/findings/F-*.md --catalog "$1/catalog.md" --gaps "$1/gaps.md" \
    --owner-questions "$1/owner-questions.md" --decisions "$1/decisions.md"
}
# case NAME RULE FILE PERL-EXPRESSION: break a copy of the observability records, expect RULE
case_() {
  local name="$1" rule="$2" file="$3" expr="$4" d="$T/$1"
  rm -rf "$d"; cp -R "$fx/observability" "$d"
  perl -0pi -e "$expr" "$d/$file"
  full "$d"
  [ $code -eq 1 ] && grep -q " $rule " <<<"$out" && ok "$rule $name" || ko "$rule $name: exit $code: $out"
}

for kind in observability sre; do
  full "$fx/$kind"
  [ $code -eq 0 ] && grep -q "This does not confirm any claim" <<<"$out" && ! grep -q "^note:" <<<"$out" \
    && ok "$kind records pass with every record given, and say a pass confirms no claim" || ko "$kind: exit $code: $out"
done
grep -q "D-21" "$fx/sre/owner-questions.md" && [ "$(grep -c '| D-21 |$' "$fx/sre/owner-questions.md")" -eq 2 ] \
  && ok "one D- id may cover a batch of findings (sre fixture)" || ko "sre fixture: D-21 not shared"

run "$tool" findings "$fx"/sre/findings/F-*.md
[ $code -eq 0 ] && grep -q "note: D- references not verifiable" <<<"$out" \
  && grep -q "note: confirmed findings: the decision behind the verdict is not verifiable" <<<"$out" \
  && ok "no registers given: not verifiable, said, not passed silently" || ko "no registers: exit $code: $out"

case_ "file name and title differ"         RC01 findings/F-002.md 's/^# F-002/# F-020/m'
case_ "status not one of the six"          RC02 findings/F-002.md 's/\| assumption \|/| agreed |/'
case_ "status table without a date"        RC02 findings/F-002.md 's/\| 2027-04-28 \|/| last week |/'
case_ "no status table at all"             RC02 findings/F-002.md 's/\| Status \|/| State |/'
case_ "status table after another, broken" RC02 findings/F-002.md 's/^(# F-002[^\n]*\n)/$1\n| Field | Value |\n|---|---|\n| a | b |\n/m; s/\| assumption \|/| agreed |/'
case_ "severity without its reason"        RC03 findings/F-002.md 's/P2, because[^·]*·/P2 ·/'
case_ "no severity line"                   RC03 findings/F-002.md 's/^\*\*Severity:\*\*.*\n//m'
case_ "what we see cites no evidence"      RC04 findings/F-002.md 's/ \(E-303\)//'
case_ "confidence and limits empty"        RC04 findings/F-002.md 's/(\*\*Confidence and limits\.\*\*)[^\n]*/$1 Medium./'
case_ "dangling G- reference"              RC05 findings/F-002.md 's/Gap G-03/Gap G-09/'
case_ "dangling F- reference"              RC05 findings/F-002.md 's/\*\*Links\.\*\* F-001/**Links.** F-007/'
case_ "dangling D- reference"              RC05 findings/F-001.md 's/F-002; D-08/F-002; D-99/'
case_ "E- id cited without a catalog entry" RC05 findings/F-002.md 's/\(E-303\)/(E-309)/'
case_ "verdict batch names a D- id the register lacks" RC05 owner-questions.md 's/\| D-08 \|/| D-98 |/'
case_ "catalog entry without its limits"   RC06 catalog.md 's/\nLimits: one payment provider[^\n]*//'
case_ "confirmed with no D- id in the batch" RC07 owner-questions.md 's/\| D-08 \|/| |/'
case_ "confirmed, not in the batch at all" RC07 owner-questions.md 's/\| F-001 \|/| F-005 |/'
case_ "status disagrees with the batch"    RC08 findings/F-001.md 's/\| confirmed \| 2027-05-03/| disputed | 2027-05-03/'
case_ "gap id defined twice"               RC09 gaps.md 's/\| G-03 \|/| G-01 |/'

# A reason in another language is a reason; a status table after another table is still found
d="$T/lang"; rm -rf "$d"; cp -R "$fx/observability" "$d"
perl -0pi -CSD -e 's/P2, because[^·]*·/P2, потому что плитка считает просмотры ·/; s/^(# F-002[^\n]*\n)/$1\n| Field | Value |\n|---|---|\n| a | b |\n/m' "$d/findings/F-002.md"
full "$d"
[ $code -eq 0 ] && ok "a severity reason in Cyrillic passes RC03; the status table found after another table" || ko "non-Latin reason or later status table: exit $code: $out"
d="$T/digits"; rm -rf "$d"; cp -R "$fx/observability" "$d"
perl -0pi -e 's/P2, because[^·]*·/P2 — 42 ·/' "$d/findings/F-002.md"
full "$d"
[ $code -eq 1 ] && grep -q " RC03 " <<<"$out" && ok "RC03 a reason of punctuation and digits only" || ko "digits-only reason: exit $code: $out"

# One implementation: the catalog check of report-pdf.sh and the finding check see the same entry.
d="$T/shared"; rm -rf "$d"; cp -R "$fx/observability" "$d"
perl -0pi -e 's/ \| Sampled traces only \|/ | |/' "$d/catalog.md"
run "$tool" catalog "$d/catalog.md" "$d/findings/F-001.md"
a=$code; grep -q "E-302 (no limits)" <<<"$out" && ca=1 || ca=0
full "$d"
[ $a -eq 1 ] && [ $ca -eq 1 ] && [ $code -eq 1 ] && grep -q "RC06 evidence entry E-302 lacks limits" <<<"$out" \
  && ok "catalog and finding checks agree on an incomplete entry" || ko "shared catalog check: $a/$ca/$code: $out"
run "$tool" catalog "$fx/observability/catalog.md" "$fx/observability/findings/F-001.md"
[ $code -eq 0 ] && [ -z "$out" ] && ok "catalog check: a sound catalog prints nothing" || ko "catalog clean: exit $code: $out"
run "$tool" catalog "$fx/observability/findings/F-001.md"
[ $code -eq 0 ] && ok "catalog check: sources without a catalog are not checked, as before" || ko "no catalog: exit $code: $out"
run "$tool" catalog "$fx/observability/findings/F-001.md" --external "$fx/observability/catalog.md"
[ $code -eq 0 ] && ok "catalog check: citations resolve in an external catalog" || ko "external: exit $code: $out"

run "$tool" findings "$T/none/F-001.md"
[ $code -eq 2 ] && ok "unreadable finding exits 2" || ko "unreadable: exit $code"

exit $fail
