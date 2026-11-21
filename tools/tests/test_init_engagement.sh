#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/agent/init-engagement.sh: it writes the instructions with every path filled
# in, the state file the gate reads, the ledger and registers; keeps what exists unless
# --force, never replaces a ledger or register, and refuses bad arguments.
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

[ -f "$R/AGENTS.md" ] && ok "instructions written" || ko "no AGENTS.md: $out"
grep -q "__[A-Z]*__" "$R/AGENTS.md" && ko "placeholder left in AGENTS.md" || ok "no placeholder left"
grep -qF "$KIT/tools/agent/prompt.sh" "$R/AGENTS.md" && ok "kit path written" || ko "kit path missing"
grep -qF "$T/code-a" "$R/AGENTS.md" && grep -qF "$T/code-b" "$R/AGENTS.md" \
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

refused() { set +e; "$INIT" "$@" >/dev/null 2>&1; local c=$?; set -e; [ $c -ne 0 ]; }
refused --code "$T/code-a" && ok "refused: no --repo" || ko "accepted: no --repo"
refused --repo "$R" && ok "refused: no --code" || ko "accepted: no --code"
refused --repo "$R" --code "$T/none" && ok "refused: missing code dir" || ko "accepted: missing code dir"
refused --repo "$R" --code "$T/code-a" --work ../out && ok "refused: path leaves the repo" || ko "accepted: path leaves the repo"
mkdir -p "$T/plain"
refused --repo "$T/plain" --code "$T/code-a" && ok "refused: not a git repository" || ko "accepted: not a git repository"
refused --repo "$KIT/tools" --code "$T/code-a" && ok "refused: repo inside the kit" || ko "accepted: repo inside the kit"

exit $fail
