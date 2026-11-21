#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/stagegate.py: the sound fixture passes; each rule has a fixture that trips it;
# the gate opens and stays shut as the state says; --since catches edited reviews and confirmations.
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

# --since: reviews only grow; a confirmation is not rewritten
R="$T/repo"; mkdir -p "$R"; git -C "$R" init -q
git -C "$R" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
cp "$fx/ok-stage3.yml" "$R/state.yml"; git -C "$R" add state.yml
git -C "$R" -c user.name=t -c user.email=t@t commit -q -m state
python3 - "$R/state.yml" <<'PY'
import sys, yaml
p = sys.argv[1]; d = yaml.safe_load(open(p))
d["stages"][0]["reviews"].append({"date": "2026-01-20", "by": "reviewer", "file": "reviews/stage-1-r2.md"})
yaml.safe_dump(d, open(p, "w"), sort_keys=False)
PY
run "$tool" lint "$R/state.yml" --since HEAD
[ $code -eq 0 ] && ok "appended review passes --since" || ko "appended review: exit $code: $out"
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

exit $fail
