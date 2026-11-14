#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Assembles a stage's task prompt: the stage file, then the rule files every stage names.
#   tools/agent/prompt.sh N [OUT.md]
# Writes to stdout when OUT.md is omitted. N is the stage number, 1 to 6.
set -euo pipefail

usage() { echo "usage: $0 N [OUT.md]" >&2; exit 2; }
[ $# -ge 1 ] && [ $# -le 2 ] || usage
N="$1"
case "$N" in [1-6]) ;; *) usage ;; esac
DIR="$(cd "$(dirname "$0")" && pwd)"
STAGE=("$DIR"/stage-"$N"-*.md)
[ -f "${STAGE[0]}" ] || { echo "no prompt for stage $N" >&2; exit 1; }
RULES=(boundaries evidence claims owner-questions progress-log)

assemble() {
  cat "${STAGE[0]}"
  for r in "${RULES[@]}"; do
    [ -f "$DIR/rules/$r.md" ] || { echo "missing rule file: rules/$r.md" >&2; exit 1; }
    printf '\n---\n\n'
    sed "s/stage-N\.md/stage-$N.md/g; s/N is the stage's number\./N = $N./; s/check engagement-state\.yml N\`/check engagement-state.yml $N\`/" "$DIR/rules/$r.md"
  done
}

if [ $# -eq 2 ]; then assemble > "$2"; else assemble; fi
