#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for scripts/files.sh, the order of the kit in the PDF: the parts are all there, in order;
# in the agent route each type's stages ascend and each stage is followed by its reference when it
# has one; no chapter is listed twice; backlog.md is last; every listed chapter exists. That every
# Markdown file the kit ships is listed is checked by scripts/guardrails.sh (check 4).
set -uo pipefail
cd "$(dirname "$0")/../.."
source scripts/files.sh
FAIL=0
pass() { echo "✓ $*"; }
fail() { echo "✗ $*"; FAIL=1; }

PARTS_EXPECTED="Getting started|Method|Observability assessment|SRE assessment|Agent route|Tools|Templates|Practice"
parts=""; chapters=(); part_of=()
current=""
for e in "${KIT_FILES[@]}"; do
  case "$e" in
    "PART: "*) t="${e#PART: }"; t="${t%%|*}"; t="${t%"${t##*[![:space:]]}"}"
               [[ "$e" == *"|"?* ]] || fail "part without its sentence: $t"
               parts="${parts:+$parts|}$t"; current="$t" ;;
    *) chapters+=("$e"); part_of+=("$current") ;;
  esac
done
[ "$parts" = "$PARTS_EXPECTED" ] && pass "parts present, in order" || fail "parts: got '$parts', want '$PARTS_EXPECTED'"
[[ "${KIT_FILES[0]}" == "PART: "* ]] && pass "the list opens with a part" || fail "a chapter comes before the first part"

dups="$(printf '%s\n' "${chapters[@]}" | sort | uniq -d)"
[ -z "$dups" ] && pass "no chapter listed twice" || fail "listed twice: $(echo $dups)"
missing=""; for f in "${chapters[@]}"; do [ -f "$f" ] || missing="$missing $f"; done
[ -z "$missing" ] && pass "every listed chapter exists" || fail "listed but missing:$missing"
last="${chapters[${#chapters[@]}-1]}"
[ "$last" = backlog.md ] && pass "backlog.md last" || fail "last chapter is $last, not backlog.md"
idx() { local i; for i in "${!chapters[@]}"; do [ "${chapters[$i]}" = "$1" ] && { echo "$i"; return; }; done; echo -1; }

# Agent route: per type, stage files ascend; a stage's reference comes right after it.
for dir in tools/agent sre/agent; do
  prev=-1; n_prev=0
  for f in "$dir"/stage-[1-6]-*.md; do
    [ -f "$f" ] || continue
    n="${f#"$dir"/stage-}"; n="${n%%-*}"
    i="$(idx "$f")"
    [ "$i" -ge 0 ] || { fail "$f not listed"; continue; }
    [ "${part_of[$i]}" = "Agent route" ] || fail "$f is in part '${part_of[$i]}', not Agent route"
    [ "$i" -gt "$prev" ] && [ "$n" -gt "$n_prev" ] || fail "$f out of order"
    prev="$i"; n_prev="$n"
    r="$dir/reference/stage-$n-reference.md"
    if [ -f "$r" ]; then
      [ "${chapters[$((i + 1))]:-}" = "$r" ] && pass "$f followed by its reference" || fail "$f not followed by $r"
      prev=$((i + 1))
    fi
  done
  [ "$prev" -ge 0 ] && pass "$dir: stages in ascending order" || fail "$dir: no stage listed"
done
for r in tools/agent/reference/*.md sre/agent/reference/*.md; do
  [ "$(idx "$r")" -ge 0 ] || fail "$r not listed"
done

# Every chapter of a type's folder sits in that type's part (agent files aside: the agent route).
for i in "${!chapters[@]}"; do
  f="${chapters[$i]}"; p="${part_of[$i]}"
  case "$f" in
    example/*|templates/spec-set/*) want="Observability assessment" ;;
    sre/agent/*|tools/agent/*) want="Agent route" ;;
    sre/*) want="SRE assessment" ;;
    *) continue ;;
  esac
  [ "$p" = "$want" ] || fail "$f is in part '$p', want '$want'"
done

[ $FAIL -eq 0 ] && pass "kit order holds"
exit $FAIL
