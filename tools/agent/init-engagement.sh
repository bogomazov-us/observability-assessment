#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Sets up an engagement repository for running the agent stages.
#
#   tools/agent/init-engagement.sh --repo DIR --code DIR [--code DIR ...]
#       [--work PATH] [--facts PATH] [--decisions PATH] [--risks PATH] [--scratch DIR]
#       [--instructions NAME] [--skills PATH] [--force]
#
# --repo          the engagement repository (exists; a git repository)
# --code          a client code checkout the agent reads; repeat for several
# --work          working folder for the stages, relative to --repo (default: assessment)
# --facts         facts ledger, relative to --repo (default: facts.md; created if absent)
# --decisions     decision register, relative to --repo (default: decisions.md; created if absent)
# --risks         risk register, relative to --repo (default: risks.md; created if absent)
# --scratch       scratch directory (default: --repo/.scratch, added to .gitignore)
# --instructions  file name the agent tool reads for instructions (default: AGENTS.md)
# --skills        also install the stage and rule skills into this folder, relative to --repo
# --force         replace the instructions file and the skills
#
# Writes only inside --repo and the scratch directory, commits nothing, and never overwrites the
# state file, a facts ledger, decision or risk register, owner-questions file or progress log: they are
# records, and --force is for refreshing the instructions and skills after a kit upgrade.
set -euo pipefail
KIT="$(cd "$(dirname "$0")/../.." && pwd)"
REPO="" WORK="assessment" FACTS="facts.md" DECISIONS="decisions.md" RISKS="risks.md" SCRATCH=""
NAME="AGENTS.md" SKILLS="" FORCE=0
CODE=()
usage() { sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --code) CODE+=("${2:-}"); shift 2 ;;
    --work) WORK="${2:-}"; shift 2 ;;
    --facts) FACTS="${2:-}"; shift 2 ;;
    --decisions) DECISIONS="${2:-}"; shift 2 ;;
    --risks) RISKS="${2:-}"; shift 2 ;;
    --scratch) SCRATCH="${2:-}"; shift 2 ;;
    --instructions) NAME="${2:-}"; shift 2 ;;
    --skills) SKILLS="${2:-}"; shift 2 ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage ;;
    *) echo "unknown argument: $1" >&2; usage ;;
  esac
done
[ -n "$REPO" ] && [ -d "$REPO" ] || { echo "--repo: an existing engagement repository is required" >&2; exit 2; }
[ ${#CODE[@]} -gt 0 ] || { echo "--code: at least one client code checkout is required" >&2; exit 2; }
for p in "$WORK" "$FACTS" "$DECISIONS" "$RISKS" "$NAME" ${SKILLS:+"$SKILLS"}; do
  case "$p" in /*|*..*) echo "paths under --repo are relative and stay inside it: $p" >&2; exit 2 ;; esac
done
abs() { (cd "$1" && pwd); }
REPO="$(abs "$REPO")"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || { echo "--repo is not a git repository: $REPO" >&2; exit 2; }
case "$REPO/" in "$KIT"/*) echo "--repo is inside the kit; use a separate engagement repository" >&2; exit 2 ;; esac
for i in "${!CODE[@]}"; do
  [ -d "${CODE[$i]}" ] || { echo "--code: no such directory: ${CODE[$i]}" >&2; exit 2; }
  CODE[$i]="$(abs "${CODE[$i]}")"
done
SCRATCH="${SCRATCH:-$REPO/.scratch}"; mkdir -p "$SCRATCH"; SCRATCH="$(abs "$SCRATCH")"

say() { echo "$*"; }
put() {  # put TARGET keep|force COMMAND...: a "keep" file is never replaced, a "force" one with --force
  local target="$1" mode="$2"; shift 2
  if [ -e "$target" ]; then
    if [ "$mode" = keep ]; then say "kept ${target#$REPO/} (exists)"; return; fi
    if [ "$FORCE" = 0 ]; then say "kept ${target#$REPO/} (exists; --force replaces it)"; return; fi
  fi
  mkdir -p "$(dirname "$target")"; "$@" > "$target"; say "wrote ${target#$REPO/}"
}

instructions() {
  python3 - "$KIT/templates/agent-instructions.md" "$KIT" "$WORK" "$FACTS" "$DECISIONS" "$RISKS" "$SCRATCH" "${CODE[@]}" <<'PY'
import sys
src, kit, work, facts, decisions, risks, scratch, *code = sys.argv[1:]
t = open(src).read()
for k, v in (("__KIT__", kit), ("__WORK__", work), ("__FACTS__", facts),
             ("__DECISIONS__", decisions), ("__RISKS__", risks), ("__SCRATCH__", scratch),
             ("__CODE__", ", ".join(f"`{c}`" for c in code))):
    t = t.replace(k, v)
sys.stdout.write(t)
PY
}
facts() {
  printf '# Facts ledger\n\nWhat is known about the estate, with a status and a source. Ids are `O-01`, `O-02` …, never\nrenumbered. Agent output enters as *assumption* until a person confirms it.\n\n| ID | Fact | Status | Source | Date |\n|---|---|---|---|---|\n'
}
decisions() {
  printf '# Decision register\n\nOwner answers, scope and stage confirmations, each with who decided and when. Ids are `D-01`,\n`D-02` …; documents cite them, never "the owner said". An architecture decision also gets an\nADR file, cited under Evidence.\n\n| ID | Decision | Decided by | Date | Evidence |\n|---|---|---|---|---|\n'
}

put "$REPO/$NAME" force instructions
put "$REPO/$WORK/engagement-state.yml" keep cat "$KIT/templates/engagement-state.yml"
put "$REPO/$WORK/owner-questions.md" keep cat "$KIT/templates/owner-questions.md"
# The folders of the path table in tools/agent/README.md, "Artifact paths".
for d in progress captures exports spec findings; do
  [ -d "$REPO/$WORK/$d" ] || { mkdir -p "$REPO/$WORK/$d"; : > "$REPO/$WORK/$d/.gitkeep"; say "wrote $WORK/$d/"; }
done
put "$REPO/$FACTS" keep facts
put "$REPO/$DECISIONS" keep decisions
put "$REPO/$RISKS" keep cat "$KIT/templates/risk-register.md"

if [ -n "$SKILLS" ]; then
  if [ "$FORCE" = 1 ]; then "$KIT/tools/agent/skills/install.sh" --force "$REPO/$SKILLS"
  else "$KIT/tools/agent/skills/install.sh" "$REPO/$SKILLS"; fi
fi

case "$SCRATCH/" in
  "$REPO"/*) rel="${SCRATCH#$REPO/}/"
    grep -qxF "$rel" "$REPO/.gitignore" 2>/dev/null || { echo "$rel" >> "$REPO/.gitignore"; say "added $rel to .gitignore"; } ;;
esac

cat <<EOF

Next, by hand:
  1. Fill in the rows of $NAME still in square brackets: the client and the monitoring tool.
  2. Give the agent read-only access to the code and the tool, and write access to this
     repository only, in the agent tool's own permissions.
  3. Record the agreed scope in $DECISIONS and set scope in $WORK/engagement-state.yml.
  4. Review and commit these files on the assessment branch; then start stage 1.
EOF
