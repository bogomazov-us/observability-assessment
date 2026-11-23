#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Assembles a stage's task prompt: the stage file, then the rule files every stage names.
#   tools/agent/prompt.sh [--assessment TYPE] N [OUT.md]
# Writes to stdout when OUT.md is omitted. N is the stage number, 1 to 6.
# TYPE is observability (the default, stage files in tools/agent/) or sre (sre/agent/); for sre
# the rules' engagement-state.yml and progress/stage-N.md become sre/engagement-state.yml and
# sre/progress/stage-N.md.
set -euo pipefail

usage() { echo "usage: $0 [--assessment TYPE] N [OUT.md]" >&2; exit 2; }
TYPE=observability
if [ "${1:-}" = --assessment ]; then [ $# -ge 2 ] || usage; TYPE="$2"; shift 2; fi
[ $# -ge 1 ] && [ $# -le 2 ] || usage
N="$1"
case "$N" in [1-6]) ;; *) usage ;; esac
DIR="$(cd "$(dirname "$0")" && pwd)"
SUB=""
case "$TYPE" in
  observability) SDIR="$DIR" ;;
  sre) SDIR="$DIR/../../sre/agent"; SUB="; s#engagement-state\.yml#sre/&#g; s#progress/stage-#sre/&#g" ;;
  *) echo "unknown assessment type: $TYPE (observability or sre)" >&2; exit 1 ;;
esac
STAGE=("$SDIR"/stage-"$N"-*.md)
[ -f "${STAGE[0]}" ] || { echo "no $TYPE prompt for stage $N" >&2; exit 1; }
RULES=(boundaries evidence claims owner-questions progress-log)

assemble() {
  cat "${STAGE[0]}"
  for r in "${RULES[@]}"; do
    [ -f "$DIR/rules/$r.md" ] || { echo "missing rule file: rules/$r.md" >&2; exit 1; }
    printf '\n---\n\n'
    sed "s/stage-N\.md/stage-$N.md/g; s/N is the stage's number\./N = $N./; s/check engagement-state\.yml N\`/check engagement-state.yml $N\`/$SUB" "$DIR/rules/$r.md"
  done
}

if [ $# -eq 2 ]; then assemble > "$2"; else assemble; fi
