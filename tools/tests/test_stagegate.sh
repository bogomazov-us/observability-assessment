#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/stagegate.py: the sound fixture passes; each rule has a fixture that trips it;
# the gate opens and stays shut as the state says; --since catches edited reviews, review files and confirmations.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../stagegate.py"
fx="$here/fixtures/stagegate"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
ok() { echo "✓ $*"; }
ko() { echo "✗ $*"; fail=1; }
run() { set +e; out="$("$@" 2>&1)"; code=$?; set -e; }

run "$tool" lint "$fx/ok-stage3.yml"
[ $code -eq 0 ] && [ -z "$out" ] && ok "sound file lints clean" || ko "sound file: exit $code: $out"

for f in "$fx"/fail-G*.yml; do
  rule="$(basename "$f" .yml)"; rule="${rule#fail-}"
  run "$tool" lint "$f"
  [ $code -eq 1 ] && grep -q " $rule " <<<"$out" && ok "$rule" || ko "$rule: exit $code: $out"
done

# assessment: absent is observability; observability and sre are accepted (G13 above: any other)
for kind in observability sre; do
  { echo "assessment: $kind"; cat "$fx/ok-stage3.yml"; } > "$T/$kind.yml"
  run "$tool" lint "$T/$kind.yml"
  [ $code -eq 0 ] && [ -z "$out" ] && ok "assessment: $kind lints clean" || ko "assessment: $kind: exit $code: $out"
done
run "$tool" check "$T/sre.yml" 3
[ $code -eq 0 ] && ok "gate unchanged for assessment: sre" || ko "sre gate: exit $code: $out"
! grep -q "^assessment:" "$fx/ok-stage3.yml" && ok "sound file has no assessment field" || ko "sound file declares assessment"

# recheck: optional on both types; done, or not_done with a reason (G14 above: neither)
for kind in observability sre; do
  sed "s/decision_ref: D-04,/decision_ref: D-04, recheck: not_done, recheck_reason: one-message confirmation,/; s/decision_ref: D-07,/decision_ref: D-07, recheck: done,/" \
    "$fx/ok-stage3.yml" | { echo "assessment: $kind"; cat; } > "$T/recheck-$kind.yml"
  run "$tool" lint "$T/recheck-$kind.yml"
  grep -q "recheck: done" "$T/recheck-$kind.yml" && [ $code -eq 0 ] && [ -z "$out" ] \
    && ok "recheck accepted, not required ($kind)" || ko "recheck ($kind): exit $code: $out"
done
sed "s/decision_ref: D-07,/decision_ref: D-07, recheck: maybe,/" "$fx/ok-stage3.yml" > "$T/recheck-bad.yml"
run "$tool" lint "$T/recheck-bad.yml"
[ $code -eq 1 ] && grep -q "G14 recheck must be done or not_done" <<<"$out" && ok "G14 unknown recheck value" || ko "G14 value: exit $code: $out"

# the gate, on the sound file: stage 3 may start; stage 4 may not (stage 3 draft, Q-02 open)
run "$tool" check "$fx/ok-stage3.yml" 3
[ $code -eq 0 ] && grep -q "stage 3 (Gap) may start" <<<"$out" && ok "gate open for stage 3" || ko "stage 3: exit $code: $out"
run "$tool" check "$fx/ok-stage3.yml" 4
[ $code -eq 1 ] && grep -q "stage 3 (Gap) is draft, not confirmed" <<<"$out" && grep -q "question Q-02 is open" <<<"$out" \
  && ok "gate shut for stage 4: stage 3 draft, Q-02 open" || ko "stage 4: exit $code: $out"
run "$tool" check "$fx/ok-stage3.yml" 1
[ $code -eq 0 ] && ok "gate open for stage 1: scope agreed, access recorded" || ko "stage 1: exit $code: $out"
sed 's/access_granted_on: 2026-01-05/access_granted_on: null/' "$fx/ok-stage3.yml" > "$T/noaccess.yml"
run "$tool" check "$T/noaccess.yml" 1
[ $code -eq 1 ] && grep -q "read-only access not recorded" <<<"$out" && ok "gate shut for stage 1 without access" || ko "stage 1 no access: exit $code: $out"
run "$tool" check "$fx/fail-G05.yml" 3
[ $code -eq 1 ] && grep -q "confirmation lacks one of" <<<"$out" \
  && ok "gate shut when the previous confirmation is incomplete" || ko "incomplete confirmation: exit $code: $out"
run "$tool" check "$fx/ok-stage3.yml" 7
[ $code -eq 2 ] && ok "stage 7 refused" || ko "stage 7: exit $code"
run "$tool" lint "$fx/does-not-exist.yml"
[ $code -eq 2 ] && ok "unreadable file exits 2" || ko "unreadable file: exit $code"

# hours: optional; recorded anywhere, a missing one warns (W02) and blocks nothing
python3 - "$fx/ok-stage3.yml" "$T" <<'PY'
import sys, yaml
d = yaml.safe_load(open(sys.argv[1])); T = sys.argv[2]
d["stages"][0]["reviews"][0]["review_hours"] = 2.5
d["stages"][0]["rework_hours"] = 0
yaml.safe_dump(d, open(f"{T}/hours.yml", "w"), sort_keys=False)
d["stages"][0]["reviews"][0]["review_hours"] = 0.5
d["stages"][1]["reviews"].append({"date": "2026-01-18", "by": "reviewer", "file": "reviews/stage-2.md", "review_hours": 1})
d["stages"][1]["rework_hours"] = 1.25
yaml.safe_dump(d, open(f"{T}/hours-full.yml", "w"), sort_keys=False)
d["stages"][2]["rework_hours"] = 1
yaml.safe_dump(d, open(f"{T}/hours-draft.yml", "w"), sort_keys=False)
d["stages"][2].pop("rework_hours"); d["stages"][0]["rework_hours"] = "two"
yaml.safe_dump(d, open(f"{T}/hours-text.yml", "w"), sort_keys=False)
PY
run "$tool" lint "$T/hours.yml"
[ $code -eq 0 ] && grep -q "stage 2: W02 confirmed without rework_hours" <<<"$out" \
  && ! grep -q "stage 1: W02" <<<"$out" && ok "W02 a confirmed stage without rework_hours, when hours are recorded" || ko "W02 rework: exit $code: $out"
run "$tool" lint "$T/hours-full.yml"
[ $code -eq 0 ] && [ -z "$out" ] && ok "hours recorded everywhere: clean, explicit 0 accepted" || ko "full hours: exit $code: $out"
run "$tool" lint "$T/hours-draft.yml"
[ $code -eq 1 ] && grep -q "stage 3: G05" <<<"$out" && ok "G05 rework_hours on a stage not confirmed" || ko "G05 rework on draft: exit $code: $out"
run "$tool" lint "$T/hours-text.yml"
[ $code -eq 1 ] && grep -q "stage 1: G15 rework_hours" <<<"$out" && ok "G15 rework_hours not a number" || ko "G15 rework: exit $code: $out"
run "$tool" check "$T/hours.yml" 3
[ $code -eq 0 ] && ok "missing hours do not shut a gate" || ko "gate with missing hours: exit $code: $out"

# --since: reviews only grow; a confirmation is not rewritten
R="$T/repo"; mkdir -p "$R"; git -C "$R" init -q
git -C "$R" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
cp "$fx/ok-stage3.yml" "$R/state.yml"; mkdir -p "$R/reviews"; echo "# Review stage 1" > "$R/reviews/stage-1.md"
git -C "$R" add state.yml reviews
git -C "$R" -c user.name=t -c user.email=t@t commit -q -m state
python3 - "$R/state.yml" <<'PY'
import sys, yaml
p = sys.argv[1]; d = yaml.safe_load(open(p))
d["stages"][0]["reviews"].append({"date": "2026-01-20", "by": "reviewer", "file": "reviews/stage-1-r2.md"})
yaml.safe_dump(d, open(p, "w"), sort_keys=False)
PY
run "$tool" lint "$R/state.yml" --since HEAD
[ $code -eq 0 ] && ok "appended review passes --since; its new file is not checked" || ko "appended review: exit $code: $out"
python3 - "$R/state.yml" <<'PY'
import sys, yaml
p = sys.argv[1]; d = yaml.safe_load(open(p))
d["stages"][0]["reviews"][0]["file"] = "reviews/other.md"
d["stages"][1]["decision_ref"] = "D-99"
yaml.safe_dump(d, open(p, "w"), sort_keys=False)
PY
run "$tool" lint "$R/state.yml" --since HEAD
grep -q " G11 " <<<"$out" && ok "G11 edited review" || ko "G11: exit $code: $out"
grep -q " G12 " <<<"$out" && ok "G12 rewritten confirmation" || ko "G12: exit $code: $out"
run "$tool" lint "$R/state.yml" --since no-such-rev
[ $code -eq 2 ] && ok "unknown revision exits 2" || ko "unknown revision: exit $code"
# --since a revision before the file existed: a clear message naming the commit to pass
run "$tool" lint "$R/state.yml" --since HEAD~1
[ $code -eq 2 ] && grep -q "did not exist at HEAD~1" <<<"$out" && grep -q "diff-filter=A" <<<"$out" \
  && ! grep -q "Traceback" <<<"$out" && ok "file absent at the revision: clear message" || ko "file absent at the revision: exit $code: $out"
first="$(git -C "$R" log --diff-filter=A --format=%h -- state.yml)"
git -C "$R" checkout -q -- state.yml
run "$tool" lint "$R/state.yml" --since "$first"
[ $code -eq 0 ] && ok "first confirmation: --since the commit that added the file" || ko "--since the adding commit: exit $code: $out"
# rework_hours is part of the confirmation: added afterwards, it is a rewrite (G12)
python3 - "$R/state.yml" <<'PY'
import sys, yaml
p = sys.argv[1]; d = yaml.safe_load(open(p))
d["stages"][1]["rework_hours"] = 3
yaml.safe_dump(d, open(p, "w"), sort_keys=False)
PY
run "$tool" lint "$R/state.yml" --since HEAD
grep -q "G12 confirmation rewritten since HEAD: rework_hours" <<<"$out" && ok "G12 rework_hours added after the confirmation" || ko "G12 rework: exit $code: $out"

# G16: a review file the state named at REV is what it was at REV; only with --since
c() { git -C "$1" -c user.name=t -c user.email=t@t commit -q -am "$2"; }
git -C "$R" checkout -q -- state.yml
run "$tool" lint "$R/state.yml" --since HEAD
[ $code -eq 0 ] && ! grep -q " G16 " <<<"$out" && ok "G16 recorded review unchanged: passes" || ko "G16 unchanged: exit $code: $out"
echo "outcome changed afterwards" >> "$R/reviews/stage-1.md"
run "$tool" lint "$R/state.yml" --since HEAD
[ $code -eq 1 ] && grep -q "stage 1 review reviews/stage-1.md: G16 recorded at HEAD and since edited" <<<"$out" \
  && ok "G16 recorded review edited" || ko "G16 edited: exit $code: $out"
run "$tool" check "$R/state.yml" 2
[ $code -eq 0 ] && ! grep -q "G16" <<<"$out" && ok "G16 not part of check: no history read" || ko "check with edited review: exit $code: $out"
run "$tool" lint "$R/state.yml"
[ $code -eq 0 ] && ok "G16 not part of lint without --since" || ko "lint without --since: exit $code: $out"
rm "$R/reviews/stage-1.md"
run "$tool" lint "$R/state.yml" --since HEAD
[ $code -eq 1 ] && grep -q "G16 recorded at HEAD and since deleted" <<<"$out" && ok "G16 recorded review deleted" || ko "G16 deleted: exit $code: $out"
git -C "$R" checkout -q -- reviews
python3 - "$R/state.yml" <<'PY2'
import sys, yaml
p = sys.argv[1]; d = yaml.safe_load(open(p))
d["stages"][1]["reviews"].append({"date": "2026-01-21", "by": "reviewer", "file": "reviews/stage-2-r1.md"})
yaml.safe_dump(d, open(p, "w"), sort_keys=False)
PY2
c "$R" "a review named, its file not committed"
run "$tool" lint "$R/state.yml" --since HEAD
[ $code -eq 1 ] && grep -q "review reviews/stage-2-r1.md: G16 named at HEAD, but git cannot show it" <<<"$out" \
  && ok "G16 fails closed: a file named at REV that git cannot show is not taken for new" || ko "G16 fail closed: exit $code: $out"
echo "# Review stage 2" > "$R/reviews/stage-2-r1.md"; git -C "$R" add reviews; c "$R" "review file committed"
python3 - "$R/state.yml" <<'PY2'
import sys, yaml
p = sys.argv[1]; d = yaml.safe_load(open(p))
d["stages"][1]["reviews"].append({"date": "2026-01-22", "by": "reviewer", "file": "reviews/stage-2-r2.md"})
yaml.safe_dump(d, open(p, "w"), sort_keys=False)
PY2
echo "# Review stage 2, round 2" > "$R/reviews/stage-2-r2.md"
run "$tool" lint "$R/state.yml" --since HEAD
[ $code -eq 0 ] && ok "G16 a new round appended with its new file passes" || ko "G16 new round: exit $code: $out"

# G16 on an SRE layout: the state file in sre/, run from elsewhere; paths read relative to it
S="$T/sre-repo"; mkdir -p "$S/report/sre/reviews"; git -C "$S" init -q
{ echo "assessment: sre"; cat "$fx/ok-stage3.yml"; } > "$S/report/sre/engagement-state.yml"
echo "# SRE review stage 1" > "$S/report/sre/reviews/stage-1.md"
git -C "$S" add report; git -C "$S" -c user.name=t -c user.email=t@t commit -q -m state
run "$tool" lint "$S/report/sre/engagement-state.yml" --since HEAD
[ $code -eq 0 ] && ok "G16 sre/ layout: recorded review unchanged passes" || ko "G16 sre unchanged: exit $code: $out"
echo "edited" >> "$S/report/sre/reviews/stage-1.md"
run "$tool" lint "$S/report/sre/engagement-state.yml" --since HEAD
[ $code -eq 1 ] && grep -q "G16 recorded at HEAD and since edited" <<<"$out" && ok "G16 sre/ layout: edited review caught" || ko "G16 sre edited: exit $code: $out"
git -C "$S" checkout -q -- report
mkdir -p "$S/report/reviews"; git -C "$S" mv report/sre/reviews/stage-1.md report/reviews/stage-1.md
git -C "$S" -c user.name=t -c user.email=t@t commit -q -m "reviews one folder up"
run "$tool" lint "$S/report/sre/engagement-state.yml" --since HEAD
[ $code -eq 0 ] && ok "G16 review one folder up (sre/ inside a report), as harness-metrics reads it" || ko "G16 one up: exit $code: $out"
echo "edited" >> "$S/report/reviews/stage-1.md"
run "$tool" lint "$S/report/sre/engagement-state.yml" --since HEAD
[ $code -eq 1 ] && grep -q " G16 " <<<"$out" && ok "G16 one folder up: edited review caught" || ko "G16 one up edited: exit $code: $out"

exit $fail
