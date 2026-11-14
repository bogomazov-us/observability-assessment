#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/agent/skills: every skill is well formed and points at a file that exists;
# stage skills are started by the person only, rule skills by the agent; install.sh writes the
# kit's path, keeps existing skills unless --force, and leaves no placeholder behind.
set -euo pipefail
cd "$(dirname "$0")/../.."
KIT="$(pwd)"
SK=tools/agent/skills
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
ok() { echo "✓ $*"; }
ko() { echo "✗ $*"; fail=1; }
field() { awk -v k="$2" 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1&&index($0,k": ")==1{sub(k": ","");print}' "$1"; }

count=0
for d in "$SK"/oa-*/; do
  name="$(basename "$d")"; f="$d/SKILL.md"; count=$((count + 1))
  [ -f "$f" ] || { ko "$name: no SKILL.md"; continue; }
  [ "$(field "$f" name)" = "$name" ] && ok "$name: name matches folder" || ko "$name: name field differs from folder"
  desc="$(field "$f" description)"
  [ ${#desc} -ge 40 ] && [ ${#desc} -le 1024 ] && ok "$name: description" || ko "$name: description missing or out of length"
  manual="$(field "$f" disable-model-invocation)"
  case "$name" in
    oa-stage-*) [ "$manual" = true ] && ok "$name: started by the person only" || ko "$name: an agent could start it"
                n="${name#oa-stage-}"; n="${n%%-*}"
                ls tools/agent/stage-"$n"-*.md >/dev/null 2>&1 && grep -qF "prompt.sh $n\`" "$f" \
                  && ok "$name: points at stage $n" || ko "$name: does not point at stage $n" ;;
    oa-rule-*)  [ -z "$manual" ] && ok "$name: the agent may use it" || ko "$name: closed to the agent"
                r="${name#oa-rule-}"
                [ -f "tools/agent/rules/$r.md" ] && grep -qF "rules/$r.md" "$f" \
                  && ok "$name: points at rules/$r.md" || ko "$name: does not point at an existing rule" ;;
    *) ko "$name: neither a stage nor a rule skill" ;;
  esac
done
[ $count -eq $(( $(ls tools/agent/stage-*.md | wc -l) + $(ls tools/agent/rules/*.md | wc -l) )) ] \
  && ok "one skill per stage and per rule ($count)" || ko "skills ($count) do not match stages and rules"

out="$("$SK/install.sh" "$T/skills")"
grep -q "installed $count skills" <<<"$out" && ok "install: all skills" || ko "install: $out"
grep -rq "__KIT__" "$T/skills" && ko "install: placeholder left" || ok "install: no placeholder left"
grep -qF "bash $KIT/tools/agent/prompt.sh 1" "$T/skills/oa-stage-1-inventory/SKILL.md" \
  && ok "install: kit path written" || ko "install: kit path not written"
grep -qF "$KIT/tools/agent/rules/claims.md" "$T/skills/oa-rule-claims/SKILL.md" \
  && ok "install: rule path written" || ko "install: rule path not written"
echo "local change" >> "$T/skills/oa-rule-claims/SKILL.md"
out="$("$SK/install.sh" "$T/skills")"
grep -q "kept: oa-rule-claims" <<<"$out" && grep -q "local change" "$T/skills/oa-rule-claims/SKILL.md" \
  && ok "install: existing skill kept" || ko "install: existing skill overwritten"
"$SK/install.sh" --force "$T/skills" >/dev/null
grep -q "local change" "$T/skills/oa-rule-claims/SKILL.md" && ko "install --force: not replaced" || ok "install --force: replaced"
set +e; "$SK/install.sh" >/dev/null 2>&1; code=$?; set -e
[ $code -eq 2 ] && ok "install: no argument refused" || ko "install: no argument, exit $code"

exit $fail
