#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/agent/init-engagement.sh: it writes the instructions with every path filled
# in, the state file the gate reads, the ledger and registers; keeps what exists unless
# --force, never replaces a ledger or register, and refuses bad arguments. Without --assessment
# the result is the one pinned in fixtures/init/default.md; --assessment sre adds WORK/sre/.
# --skills installs the rule skills always, each type's stage skills only for that type.
# Paths written are relative to the repository; registers named by flag are the host's, never
# created or written; the owner-questions copy links into the kit.
set -euo pipefail
cd "$(dirname "$0")/../.."
KIT="$(pwd)"
INIT=tools/agent/init-engagement.sh
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
ok() { echo "✓ $*"; }
ko() { echo "✗ $*"; fail=1; }

R="$T/eng"; mkdir -p "$R" "$T/code-a" "$T/code-b"; git -C "$R" init -q
out="$("$INIT" --repo "$R" --code "$T/code-a" --code "$T/code-b" --skills skills)"
rel() { python3 -c 'import os,sys; R=os.path.realpath; print(os.path.relpath(R(sys.argv[1]), R(sys.argv[2])))' "$1" "$2"; }
K="$(rel "$KIT" "$R")"  # the kit as the instructions name it: relative to the repository
snapshot() {  # snapshot DIR STDOUT: what init wrote and printed, kit and temporary paths masked
  { echo "## stdout"; printf '%s\n' "$2"
    echo "## files"; (cd "$1" && find . -path ./.git -prune -o -print | LC_ALL=C sort)
    for f in AGENTS.md facts.md decisions.md .gitignore; do echo "## $f"; cat "$1/$f"; done
  } | sed "s|$KIT|[kit]|g; s|$K|[kit]|g; s|$T|[tmp]|g"
}
links() {  # links FILE: every relative Markdown link in FILE resolves from FILE's folder
  python3 - "$1" <<'PY'
import os, re, sys
f = sys.argv[1]; d = os.path.dirname(f)
bad = [l for l in re.findall(r"\]\(([^)#]+)(?:#[^)]*)?\)", open(f).read())
       if not re.match(r"[a-z]+:", l) and not os.path.exists(os.path.join(d, l))]
sys.exit(1 if bad else 0)
PY
}
snapshot "$R" "$out" | diff - tools/tests/fixtures/init/default.md >/dev/null \
  && ok "no --assessment: output as pinned" || ko "no --assessment: output differs from fixtures/init/default.md"
cmp -s "$R/assessment/engagement-state.yml" templates/engagement-state.yml \
  && cmp -s "$R/risks.md" templates/risk-register.md && ok "no --assessment: templates copied as they are" \
  || ko "no --assessment: a template copy differs"
grep -q "](" "$R/assessment/owner-questions.md" && links "$R/assessment/owner-questions.md" \
  && ok "owner questions: links resolve from the engagement" || ko "owner questions: a link breaks in the engagement"
diff <(sed 's/](.*)/]()/g' templates/owner-questions.md) <(sed 's/](.*)/]()/g' "$R/assessment/owner-questions.md") >/dev/null \
  && ok "owner questions: only the links differ from the template" || ko "owner questions: text changed"
absolute() {  # absolute DIR: the files init wrote that name the kit or a code checkout by an absolute path
  find "$1" -path "$1/.git" -prune -o -type f -print | while read -r f; do
    sed "s|$(rel "$KIT" "$(dirname "$f")")||g; s|$(rel "$KIT" "$1")||g" "$f" | grep -qF -e "$KIT" -e "$T" && echo "$f"
  done; true
}
[ -z "$(absolute "$R")" ] && ok "no absolute machine-local path in the files written" \
  || ko "an absolute machine-local path written: $(absolute "$R")"

[ -f "$R/AGENTS.md" ] && ok "instructions written" || ko "no AGENTS.md: $out"
grep -q "__[A-Z]*__" "$R/AGENTS.md" && ko "placeholder left in AGENTS.md" || ok "no placeholder left"
grep -qF "\`bash $K/tools/agent/prompt.sh N\`" "$R/AGENTS.md" && [ -f "$R/$K/tools/agent/prompt.sh" ] \
  && ok "kit path written, relative" || ko "kit path missing"
grep -qF "\`../code-a\`" "$R/AGENTS.md" && grep -qF "\`../code-b\`" "$R/AGENTS.md" \
  && ok "every code checkout listed" || ko "code checkout missing"
grep -qF "assessment/engagement-state.yml" "$R/AGENTS.md" && ok "state file path written" || ko "state path missing"
grep -q '\[client\]' "$R/AGENTS.md" && ok "client left for the person" || ko "client row filled or lost"
python3 tools/stagegate.py check "$R/assessment/engagement-state.yml" 2 >/dev/null 2>&1 \
  && ko "gate open for stage 2 on a fresh state" || ok "gate shut for stage 2 on a fresh state"
[ -f "$R/assessment/owner-questions.md" ] && [ -d "$R/assessment/progress" ] \
  && ok "owner questions and progress folder" || ko "working folder incomplete"
grep -q "| ID | Fact | Status | Source | Date |" "$R/facts.md" && ok "facts ledger" || ko "facts ledger"
grep -q "| ID | Decision |" "$R/decisions.md" && ok "decision register" || ko "decision register"
grep -q '`O-01`' "$R/facts.md" && ok "ledger names O- ids" || ko "ledger header without O- ids"
grep -q "ADR file, cited under Evidence" "$R/decisions.md" && ok "register points architecture decisions to an ADR" || ko "register header without the ADR rule"
grep -q "| ID | Risk | Source | Owner | Status | Date | Decision |" "$R/risks.md" && ok "risk register created" || ko "risk register not created"
grep -qF "| \`risks.md\` |" "$R/AGENTS.md" && ok "risk register named in the instructions" || ko "risk register not named"
[ "$(ls -d "$R"/skills/oa-* | wc -l | tr -d ' ')" -eq "$(ls -d tools/agent/skills/oa-* | wc -l | tr -d ' ')" ] \
  && ok "skills installed" || ko "skills not installed"
skills() { ls -d "$1"/skills/$2 2>/dev/null | wc -l | tr -d ' '; }  # skills REPO GLOB: how many installed
[ "$(skills "$R" 'oa-sre-*')" -eq 0 ] && ok "observability alone: no SRE stage skills" || ko "observability alone: SRE stage skills installed"
grep -qx ".scratch/" "$R/.gitignore" && [ -d "$R/.scratch" ] && ok "scratch ignored" || ko "scratch not ignored"
[ -z "$(git -C "$R" log --oneline 2>/dev/null)" ] && ok "nothing committed" || ko "something committed"

echo "| F-1 | kept | assumption | x | 2026-01-01 |" >> "$R/facts.md"
echo "| R-01 | kept | blind spot | x | open | 2026-01-01 | |" >> "$R/risks.md"
echo "local" >> "$R/AGENTS.md"
echo "# confirmed" >> "$R/assessment/engagement-state.yml"
out="$("$INIT" --repo "$R" --code "$T/code-a")"
grep -q "F-1" "$R/facts.md" && grep -q "^local$" "$R/AGENTS.md" && ok "re-run keeps what exists" || ko "re-run replaced a file"
grep -q "R-01" "$R/risks.md" && ok "re-run keeps the risk register" || ko "re-run replaced the risk register"
[ "$(grep -c "^.scratch/$" "$R/.gitignore")" -eq 1 ] && ok "gitignore line added once" || ko "gitignore line repeated"
"$INIT" --repo "$R" --code "$T/code-a" --force >/dev/null
grep -q "^local$" "$R/AGENTS.md" && ko "--force: instructions not replaced" || ok "--force replaces instructions"
grep -q "F-1" "$R/facts.md" && ok "--force never replaces the ledger" || ko "--force replaced the ledger"
grep -q "R-01" "$R/risks.md" && ok "--force never replaces the risk register" || ko "--force replaced the risk register"
grep -q "^# confirmed$" "$R/assessment/engagement-state.yml" && ok "--force never replaces the state file" || ko "--force replaced the state file"

"$INIT" --repo "$R" --code "$T/code-a" --instructions OTHER.md --work work >/dev/null
[ -f "$R/OTHER.md" ] && grep -qF "work/engagement-state.yml" "$R/OTHER.md" \
  && ok "instructions name and working folder chosen" || ko "--instructions or --work ignored"

mkdir -p "$R/04-risks"; echo "existing" > "$R/04-risks/risk-register.md"
"$INIT" --repo "$R" --code "$T/code-a" --instructions THIRD.md --risks 04-risks/risk-register.md >/dev/null
grep -qx "existing" "$R/04-risks/risk-register.md" && grep -qF "04-risks/risk-register.md" "$R/THIRD.md" \
  && ok "--risks points at an existing register" || ko "--risks ignored or the register replaced"

"$INIT" --repo "$R" --code "$T/code-a" --instructions .claude/CLAUDE.md >/dev/null
[ -f "$R/.claude/CLAUDE.md" ] && ok "--instructions takes a subpath" || ko "--instructions subpath not written"

# A host knowledge base: registers named by flag are never created or written.
H="$T/host"; mkdir -p "$H/adr" "$H/kb"; git -C "$H" init -q
printf '# ADR 1\n\nStatus: accepted\n' > "$H/adr/0001-scope.md"; cp "$H/adr/0001-scope.md" "$T/adr.md"
out="$("$INIT" --repo "$H" --code "$T/code-a" --decisions adr --facts kb/facts.md --risks kb/risks.md)"
[ "$(ls "$H/adr")" = "0001-scope.md" ] && cmp -s "$H/adr/0001-scope.md" "$T/adr.md" \
  && ok "host: a folder of ADRs left as it is" || ko "host: the ADR folder written to"
[ ! -e "$H/kb/facts.md" ] && [ ! -e "$H/kb/risks.md" ] && grep -q "missing kb/facts.md (given by --facts): not created" <<<"$out" \
  && grep -q "missing kb/risks.md (given by --risks)" <<<"$out" && ok "host: a missing register reported, not created" \
  || ko "host: a missing register created or not reported"
"$INIT" --repo "$H" --code "$T/code-a" --decisions adr/0001-scope.md --instructions B.md --force >/dev/null
cmp -s "$H/adr/0001-scope.md" "$T/adr.md" && grep -qF "| \`adr/0001-scope.md\` |" "$H/B.md" \
  && ok "host: an ADR file as the decisions file, nothing written to it" || ko "host: the ADR file changed"
"$INIT" --repo "$H" --code "$T/code-a" --scratch "$T/scr" --instructions C.md >/dev/null
grep -qF "| \`../scr\` |" "$H/C.md" && ! grep -qF "$T" "$H/C.md" && ! grep -qxF "../scr/" "$H/.gitignore" \
  && ok "host: a scratch folder outside the repository written relative" || ko "host: scratch path absolute"

S="$T/both"; mkdir -p "$S"; git -C "$S" init -q
"$INIT" --repo "$S" --code "$T/code-a" --assessment sre >/dev/null
[ -f "$S/assessment/sre/engagement-state.yml" ] && grep -qx "assessment: sre" "$S/assessment/sre/engagement-state.yml" \
  && ok "sre: state file names its type" || ko "sre: no state file, or no assessment: sre"
python3 tools/stagegate.py lint "$S/assessment/sre/engagement-state.yml" >/dev/null 2>&1 \
  && ok "sre: state file passes the linter" || ko "sre: state file fails the linter"
for d in progress exports targets; do [ -f "$S/assessment/sre/$d/.gitkeep" ] || ko "sre: no sre/$d/"; done
[ -f "$S/assessment/owner-questions.md" ] && [ -d "$S/assessment/findings" ] \
  && ok "sre: owner questions and findings shared at the working folder" || ko "sre: shared files missing"
[ ! -e "$S/assessment/engagement-state.yml" ] && [ ! -e "$S/assessment/captures" ] && [ ! -e "$S/assessment/progress" ] \
  && ok "sre alone: no observability state or folders" || ko "sre alone: observability files made"
grep -qF "| sre | \`assessment/sre\` | \`assessment/sre/engagement-state.yml\` | \`bash $(rel "$KIT" "$S")/tools/agent/prompt.sh --assessment sre N\` |" "$S/AGENTS.md" \
  && ok "sre: types block row" || ko "sre: types block row missing"
! grep -qE "assessment/engagement-state.yml|assessment/progress/|prompt.sh N\`|\`oa-stage-" "$S/AGENTS.md" \
  && grep -qF "assessment/sre/progress/stage-N.md" "$S/AGENTS.md" && grep -qF "\`oa-sre-stage-N-" "$S/AGENTS.md" \
  && grep -qF "check
   assessment/sre/engagement-state.yml N" "$S/AGENTS.md" \
  && ok "sre alone: the steps name only SRE paths" || ko "sre alone: an observability path in the steps"
grep -q "__[A-Z]*__" "$S/AGENTS.md" && ko "sre: placeholder left" || ok "sre: no placeholder left"
grep -q "^| observability |" "$S/AGENTS.md" && ko "sre alone: observability row" || ok "sre alone: no observability row"
[ "$(grep -c "^## Types in this engagement$" templates/agent-instructions.md)" -eq 1 ] \
  && ! grep -qiE "^\| (observability|sre) \|" templates/agent-instructions.md \
  && ok "template: the block once, no per-type rows" || ko "template: block missing, repeated or per-type"
grep -q "^## Types in this engagement$" "$R/AGENTS.md" && ko "no --assessment: types block shown" || ok "no --assessment: no types block"

"$INIT" --repo "$S" --code "$T/code-a" --assessment sre --skills skills >/dev/null
[ "$(skills "$S" 'oa-rule-*')" -eq "$(ls -d tools/agent/skills/oa-rule-* | wc -l | tr -d ' ')" ] \
  && ok "sre alone: rule skills installed" || ko "sre alone: rule skills missing"
[ "$(skills "$S" 'oa-sre-stage-*')" -eq "$(ls -d sre/agent/skills/oa-sre-stage-* | wc -l | tr -d ' ')" ] \
  && ok "sre alone: SRE stage skills installed" || ko "sre alone: SRE stage skills missing"
[ "$(skills "$S" 'oa-stage-*')" -eq 0 ] && ok "sre alone: no observability stage skills" || ko "sre alone: observability stage skills installed"

echo "| F-2 | kept | assumption | x | 2026-01-01 |" >> "$S/facts.md"
echo "# sre confirmed" >> "$S/assessment/sre/engagement-state.yml"
echo "sre step" >> "$S/assessment/sre/progress/stage-1.md"
echo "| Q-01 | kept |" >> "$S/assessment/owner-questions.md"
out="$("$INIT" --repo "$S" --code "$T/code-a" --assessment sre --assessment observability --skills skills --force)"
grep -q "^# sre confirmed$" "$S/assessment/sre/engagement-state.yml" && grep -qx "sre step" "$S/assessment/sre/progress/stage-1.md" \
  && grep -q "F-2" "$S/facts.md" && grep -q "Q-01" "$S/assessment/owner-questions.md" \
  && ok "both, --force: sre state, progress log, ledger and questions kept" || ko "both, --force: a record replaced"
grep -qx "assessment: sre" "$S/assessment/engagement-state.yml" && ko "both: observability state file names sre" \
  || { [ -f "$S/assessment/engagement-state.yml" ] && [ -d "$S/assessment/captures" ] \
       && ok "both: observability state and folders added" || ko "both: observability files missing"; }
[ "$(grep -A5 "^## Types in this engagement$" "$S/AGENTS.md" | grep -cE "^\| (observability|sre) \|")" -eq 2 ] \
  && grep -q "^# Observability and SRE assessment" "$S/AGENTS.md" && ok "both: two rows, observability first" || ko "both: types block or title wrong"
grep -q "no skills in .*sre/agent/skills" <<<"$out" || [ -d sre/agent/skills ] \
  && ok "both: missing SRE skills skipped with a note" || ko "both: no note for missing SRE skills"
[ -d "$S/skills/oa-stage-1-inventory" ] && ok "both: observability skills installed" || ko "both: observability skills missing"
[ "$(skills "$S" 'oa-*')" -eq $(( $(ls -d tools/agent/skills/oa-* sre/agent/skills/oa-* | wc -l) )) ] \
  && ok "both: rule, observability and SRE stage skills installed" || ko "both: a skill set missing"
echo "local" >> "$S/assessment/sre/engagement-state.yml"
"$INIT" --repo "$S" --code "$T/code-a" --assessment sre >/dev/null
grep -qx "local" "$S/assessment/sre/engagement-state.yml" && ok "sre: re-run keeps the state file" || ko "sre: re-run replaced the state file"

refused() { set +e; "$INIT" "$@" >/dev/null 2>&1; local c=$?; set -e; [ $c -ne 0 ]; }
refused --code "$T/code-a" && ok "refused: no --repo" || ko "accepted: no --repo"
refused --repo "$R" && ok "refused: no --code" || ko "accepted: no --code"
refused --repo "$R" --code "$T/none" && ok "refused: missing code dir" || ko "accepted: missing code dir"
refused --repo "$R" --code "$T/code-a" --assessment other && ok "refused: unknown type" || ko "accepted: unknown type"
refused --repo "$R" --code "$T/code-a" --work ../out && ok "refused: path leaves the repo" || ko "accepted: path leaves the repo"
mkdir -p "$T/plain"
refused --repo "$T/plain" --code "$T/code-a" && ok "refused: not a git repository" || ko "accepted: not a git repository"
refused --repo "$KIT/tools" --code "$T/code-a" && ok "refused: repo inside the kit" || ko "accepted: repo inside the kit"

exit $fail
