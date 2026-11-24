#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/harness-metrics.py on a fictional engagement built here: 14 findings, 12 with a
# verdict, 7 of them unchanged in the strict reading; two review rounds at stage 4; hours
# recorded, absent and zero; the same records laid out for an observability and an SRE assessment.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../harness-metrics.py"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
ok() { echo "✓ $*"; }
ko() { echo "✗ $*"; fail=1; }
run() { set +e; out="$("$@" 2>&1)"; code=$?; set -e; }

# build ROOT STATE_DIR MODEL: the state file, reviews and progress in STATE_DIR, findings in ROOT/findings
build() {
  python3 - "$@" <<'PY'
import os, sys
root, sd, model = sys.argv[1:4]
for d in (f"{sd}/reviews", f"{sd}/progress", f"{root}/findings"):
    os.makedirs(d, exist_ok=True)
kind = "" if model == "observability" else f"assessment: {model}\n"
open(f"{sd}/engagement-state.yml", "w").write(kind + """scope: {decision_ref: D-01, access_granted_on: 2027-01-04}
stages:
  - {number: 1, status: confirmed, confirmed_by: lead, confirmed_on: 2027-01-08, decision_ref: D-02, reviews: []}
  - {number: 2, status: confirmed, confirmed_by: lead, confirmed_on: 2027-01-12, decision_ref: D-03, rework_hours: 0,
     reviews: [{date: 2027-01-12, by: lead, file: reviews/stage-2-round-1.md}]}
  - {number: 3, status: confirmed, confirmed_by: lead, confirmed_on: 2027-01-15, decision_ref: D-04, rework_hours: 1.5,
     reviews: [{date: 2027-01-15, by: lead, file: reviews/stage-3-round-1.md, review_hours: 0}]}
  - {number: 4, status: confirmed, confirmed_by: lead, confirmed_on: 2027-01-22, decision_ref: D-05, rework_hours: 2,
     reviews: [{date: 2027-01-20, by: lead, file: reviews/stage-4-round-1.md, review_hours: 4},
               {date: 2027-01-22, by: lead, file: reviews/stage-4-round-2.md, review_hours: 1.5}]}
  - {number: 5, status: not_started, reviews: []}
  - {number: 6, status: not_started, reviews: []}
""")
for r in ("stage-2-round-1", "stage-3-round-1"):
    open(f"{sd}/reviews/{r}.md", "w").write(f"# Review {r}\n\nNo finding outcomes at this stage.\n")
open(f"{sd}/reviews/stage-4-round-1.md", "w").write("""# Review stage 4, round 1

## Finding outcomes (stage 4)

| Finding | Outcome | Note |
|---|---|---|
| F-001 | unchanged | |
| F-002 | unchanged | |
| F-003 | unchanged | |
| F-004 | unchanged | |
| F-005 | unchanged | |
| F-006 | split_merge | split in two by the reviewer |
| F-007 | bounded | window added |
| F-008 | new_input | the owner's answer, D-05 |
| F-009 | corrected | |
| F-010 | severity_changed | P1 to P2 |
| F-011 | split_merge | |
| F-012 | unchanged | |
| F-013 | unchanged | still an assumption |

## Re-checks

| Evidence | Result | How |
|---|---|---|
| E-401 | reproduced | query re-run in the tool's own interface |
| E-402 | reproduced | |
| E-403 | not reproduced | too little data in the window |
""")
open(f"{sd}/reviews/stage-4-round-2.md", "w").write("""# Review stage 4, round 2

| Finding | Outcome |
|---|---|
| F-011 | corrected |
| F-012 | unchanged |

## Second reading

| Finding | Rule | Excerpt | Reason | Flag | Reviewer |
|---|---|---|---|---|---|
| F-007 | claims 1 | "no alert exists" | one folder exported | needs_revision | acted |
| F-009 | claims 7 | "caused by" | a difference only | needs_revision | disagreed |
| F-010 | finding.md | "P1" | reason unclear | needs_human_review | open |
| F-011 | claims 2 | "all services" | one service read | needs_revision | agreed_no_change |
| F-012 | - | - | nothing found | pass | open |
""")
open(f"{sd}/progress/stage-4.md", "w").write("""# progress, stage 4

```
2027-01-18
09:00 plan — 3 steps
17:30 step 3/3 — done
2027-01-19
08:15 commit abc1234 — findings
09:45 step 3/3 — handed over
```
""")
verdict = {i: "confirmed" for i in range(1, 13)}
verdict.update({4: "disputed", 9: "refuted", 11: "inconclusive", 12: "resolved", 13: "assumption", 14: "assumption"})
for i, v in verdict.items():
    open(f"{root}/findings/F-{i:03d}.md", "w").write(f"""# F-{i:03d} · fictional finding {i}

| Status | Date | Source | Evidence level |
|---|---|---|---|
| {v} | 2027-01-20 | query | agent |

**Severity:** P2, because a fictional reason. **Model:** {model}
""")
other = "sre" if model == "observability" else "observability"
open(f"{root}/findings/F-050.md", "w").write(f"""# F-050 · a finding of the other model

| Status | Date | Source | Evidence level |
|---|---|---|---|
| confirmed | 2027-01-20 | query | agent |

**Model:** {other}
""")
PY
}

O="$T/obs"; build "$O" "$O" observability
S="$T/sre-report"; build "$S" "$S/sre" sre

run "$tool" "$O/engagement-state.yml"
[ $code -eq 0 ] && ok "fictional engagement measured, exit 0" || ko "exit $code: $out"
grep -q "strict unchanged:  7/12 (58.3%; 95% interval 32–81%)" <<<"$out" && ok "strict 7/12 (58.3%) with its 95% interval; pending out of the denominator" || ko "strict: $out"
grep -q "lenient unchanged: 9/12 (75.0%; 95% interval 47–91%)" <<<"$out" && ok "bounded and new_input fail strict, pass lenient" || ko "lenient: $out"
grep -q "pending (assumption) 2" <<<"$out" && ok "two pending findings reported apart" || ko "pending: $out"
grep -q "split or merged 2 (granularity" <<<"$out" && ok "split_merge counted apart" || ko "split_merge: $out"
grep -q "^4 Findings .* 5.5 h .* 2 h " <<<"$out" && ok "stage 4: review hours of both rounds summed, rework 2 h" || ko "stage 4 hours: $out"
grep -q "^3 Gap .* 0 h  .* 1.5 h " <<<"$out" && ok "explicit 0 review hours is 0, not 'not measured'" || ko "zero: $out"
grep -q "^2 Target model .* not measured .* 0 h " <<<"$out" && ok "absent review_hours: not measured" || ko "absent review: $out"
grep -q "^1 Inventory .* no review .* not measured " <<<"$out" && ok "absent rework_hours: not measured" || ko "absent rework: $out"
grep -q "2 of 3 selected reproduced" <<<"$out" && grep -q "not how accurate the whole output is" <<<"$out" \
  && ok "re-checks as n of n selected, with the caveat" || ko "re-checks: $out"
grep -q "^4 Findings .* 24h45 " <<<"$out" && ok "agent span read from the progress log across two days" || ko "agent span: $out"
grep -q "Second reading (optional, recommendations only): 4 flags; the reviewer acted on 1, agreed without a change on 1, disagreed with 1, left open 1. Not a precision" <<<"$out" \
  && ok "second reading: flags and the reviewer's four dispositions counted; a pass is not a flag; not called a precision" || ko "second reading: $out"
grep -q "strict unchanged:  7/12" <<<"$out" && ok "second reading changes no rate" || ko "rates moved: $out"

"$tool" "$O/engagement-state.yml" --json > "$T/obs.json"
"$tool" "$S/sre/engagement-state.yml" --json > "$T/sre.json"
python3 - "$T/obs.json" "$T/sre.json" <<'PY' && ok "same records in sre/engagement-state.yml: same measures; the other model's finding left out" || ko "sre differs"
import json, sys
a, b = (json.load(open(p)) for p in sys.argv[1:3])
assert a["assessment"] == "observability" and b["assessment"] == "sre"
for d in (a, b):
    d.pop("assessment"); d.pop("inputs_at")
assert a == b, (a, b)
assert a["findings"]["total"] == 14 and a["findings"]["classified"] == 12
PY
"$tool" "$O/engagement-state.yml" --json > "$T/again.json"
cmp -s "$T/obs.json" "$T/again.json" && ok "deterministic output" || ko "output differs between runs"

# a verdict without an outcome stays in the denominator: never unchanged, the share a range,
# the record incomplete; for both layouts
for st in "$O/engagement-state.yml" "$S/sre/engagement-state.yml"; do
  d="$(dirname "$st")"; m="$T/miss-$(basename "$(dirname "$d")")-$(basename "$d")"
  rm -rf "$m"; cp -R "$(cd "$d/.." && pwd)" "$m"
  rel="${st#$(cd "$d/.." && pwd)/}"
  perl -ni -e 'print unless /^\| F-00[12] \| unchanged \|/' "$m/$(dirname "$rel")/reviews/stage-4-round-1.md"
  run "$tool" "$m/$rel"
  grep -q "strict unchanged:  at least 5/12 (41.7%), at most 7/12 (58.3%): outcomes missing" <<<"$out" \
    && grep -q "of them without an outcome 2 (F-001, F-002)" <<<"$out" && grep -q "INCOMPLETE: 2 finding" <<<"$out" \
    && ok "verdict without outcome ($(basename "$d")): in the denominator, a range, marked incomplete" \
    || ko "missing outcomes ($(basename "$d")): $out"
  "$tool" "$m/$rel" --json | python3 -c 'import json,sys; f=json.load(sys.stdin)["findings"]; assert f["denominator"]==12 and f["outcomes_complete"] is False and f["strict_unchanged"]==5 and f["strict_interval_95"] is None' \
    && ok "JSON ($(basename "$d")): denominator 12, outcomes_complete false, no interval" || ko "JSON missing outcomes ($(basename "$d"))"
done
"$tool" "$O/engagement-state.yml" --json | python3 -c 'import json,sys; assert json.load(sys.stdin)["findings"]["outcomes_complete"] is True' \
  && ok "complete record: outcomes_complete true" || ko "complete record not marked complete"

# a finding whose first table is not the status table: the verdict is still read
m="$T/firsttable"; rm -rf "$m"; cp -R "$O" "$m"
perl -0pi -e 's/^(# F-001[^\n]*\n)/$1\n| Field | Value |\n|---|---|\n| a | b |\n/m' "$m/findings/F-001.md"
"$tool" "$m/engagement-state.yml" --json | python3 -c 'import json,sys; f=json.load(sys.stdin)["findings"]; assert f["with_verdict"]==12, f' \
  && ok "status read from the first table with a Status column" || ko "status table after another table not read"

# rule violations: printed measures, exit 1, a stable id
cp -R "$O" "$T/bad"
cat >> "$T/bad/reviews/stage-4-round-2.md" <<'EOF'

| Finding | Outcome |
|---|---|
| F-002 | unchanged, corrected |
| F-003 | rewritten |
| F-099 | unchanged |
| X-1 | unchanged |

| Evidence | Result |
|---|---|
| E-404 | maybe |

| Finding | Rule | Excerpt | Reason | Flag | Reviewer |
|---|---|---|---|---|---|
| F-001 | claims 1 | x | y | confirmed | open |
EOF
sed -i.bak 's/review_hours: 1.5}/review_hours: -1}/' "$T/bad/engagement-state.yml"
run "$tool" "$T/bad/engagement-state.yml"
[ $code -eq 1 ] && grep -q "strict unchanged" <<<"$out" && ok "violations: measures still printed, exit 1" || ko "violations: exit $code"
for rule in "H03 F-002: unchanged cannot stand with corrected" "H02 F-003" "H01 F-099 has an outcome but no" \
            "H01 an outcome row names one finding id" "H04 a re-check row" "H05 review_hours must be hours" \
            "H07 a second-reading row"; do
  grep -qF "$rule" <<<"$out" && ok "${rule%% *}: ${rule#* }" || ko "missing: $rule: $out"
done
rm "$T/bad/reviews/stage-3-round-1.md"
run "$tool" "$T/bad/engagement-state.yml"
grep -q "H06 review file not found" <<<"$out" && ok "H06 a review file the state names is missing" || ko "H06: $out"

run "$tool" "$T/none.yml"
[ $code -eq 2 ] && ok "unreadable state file exits 2" || ko "unreadable: exit $code"

exit $fail
