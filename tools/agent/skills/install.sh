#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Installs the stage and rule skills into an engagement's skills directory.
#   tools/agent/skills/install.sh [--force] [--from DIR] SKILLS_DIR
# Copies each skill folder into SKILLS_DIR and writes this kit's absolute path where the skill
# names it, so the skill points at the kit's prompts and rules instead of copying them.
# An existing skill of the same name is left alone unless --force is given.
# --from names an assessment type's skills folder (default: this one, observability); a folder
# that does not exist yet is skipped with a note.
set -euo pipefail

usage() { echo "usage: $0 [--force] [--from DIR] SKILLS_DIR" >&2; exit 2; }
FORCE="" FROM=""
[ "${1:-}" = "--force" ] && { FORCE=1; shift; }
[ "${1:-}" = "--from" ] && { [ $# -ge 2 ] || usage; FROM="$2"; shift 2; }
[ $# -eq 1 ] || usage
HERE="$(cd "$(dirname "$0")" && pwd)"
KIT="$(cd "$HERE/../../.." && pwd)"
case "$KIT" in *'|'*) echo "kit path contains '|': not supported" >&2; exit 1 ;; esac
if [ -n "$FROM" ]; then
  [ -d "$FROM" ] || { echo "no skills in $FROM yet; skipped"; exit 0; }
  HERE="$(cd "$FROM" && pwd)"
fi
mkdir -p "$1"
DEST="$(cd "$1" && pwd)"

n=0; kept=0
for src in "$HERE"/oa-*/; do
  [ -d "$src" ] || continue
  name="$(basename "$src")"
  if [ -e "$DEST/$name" ] && [ -z "$FORCE" ]; then
    echo "kept: $name (exists; --force replaces it)"; kept=$((kept + 1)); continue
  fi
  rm -rf "${DEST:?}/$name"; mkdir -p "$DEST/$name"
  sed "s|__KIT__|$KIT|g" "$src/SKILL.md" > "$DEST/$name/SKILL.md"
  n=$((n + 1))
done
msg="installed $n skills into $DEST"; [ "$kept" -gt 0 ] && msg="$msg, kept $kept"
echo "$msg"
