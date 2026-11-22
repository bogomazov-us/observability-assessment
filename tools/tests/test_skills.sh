#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/agent/skills: every skill is well formed and points at a file that exists;
# stage skills are started by the person only, rule skills by the agent; install.sh writes the
# kit's path, keeps existing skills unless --force, and leaves no placeholder behind; --from
# installs a type's skills folder and skips one that does not exist yet. The SRE stage skills
# (sre/agent/skills/) point at the SRE prompts and install with --from, also through init.
set -euo pipefail
cd "$(dirname "$0")/../.."
KIT="$(pwd)"
SK=tools/agent/skills
SRE=sre/agent/skills
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

# SRE stage skills: the same checks against the SRE prompts; the rule skills are shared.
srecount=0
for d in "$SRE"/*/; do
  name="$(basename "$d")"; f="$d/SKILL.md"; srecount=$((srecount + 1))
  [ -f "$f" ] || { ko "$name: no SKILL.md"; continue; }
  [ "$(field "$f" name)" = "$name" ] && ok "$name: name matches folder" || ko "$name: name field differs from folder"
  desc="$(field "$f" description)"
  [ ${#desc} -ge 40 ] && [ ${#desc} -le 1024 ] && ok "$name: description" || ko "$name: description missing or out of length"
  [ "$(field "$f" disable-model-invocation)" = true ] && ok "$name: started by the person only" || ko "$name: an agent could start it"
  n="${name#oa-sre-stage-}"
  [ -f "sre/agent/stage-$n.md" ] && grep -qF "prompt.sh --assessment sre ${n%%-*}\`" "$f" \
    && ok "$name: points at SRE stage ${n%%-*}" || ko "$name: not an SRE stage skill pointing at its prompt"
done
[ $srecount -eq "$(ls sre/agent/stage-*.md | wc -l)" ] && ok "one SRE skill per SRE stage ($srecount)" \
  || ko "SRE skills ($srecount) do not match SRE stages"

out="$("$SK/install.sh" "$T/skills")"
grep -q "installed $count skills" <<<"$out" && ok "install: all skills" || ko "install: $out"
grep -q "kept" <<<"$out" && ko "install: kept 0 reported" || ok "install: no kept count when nothing kept"
grep -rq "__KIT__" "$T/skills" && ko "install: placeholder left" || ok "install: no placeholder left"
grep -qF "bash $KIT/tools/agent/prompt.sh 1" "$T/skills/oa-stage-1-inventory/SKILL.md" \
  && ok "install: kit path written" || ko "install: kit path not written"
grep -qF "$KIT/tools/agent/rules/claims.md" "$T/skills/oa-rule-claims/SKILL.md" \
  && ok "install: rule path written" || ko "install: rule path not written"
echo "local change" >> "$T/skills/oa-rule-claims/SKILL.md"
out="$("$SK/install.sh" "$T/skills")"
grep -q ", kept 1" <<<"$out" && ok "install: kept count reported" || ko "install: kept count missing"
grep -q "kept: oa-rule-claims" <<<"$out" && grep -q "local change" "$T/skills/oa-rule-claims/SKILL.md" \
  && ok "install: existing skill kept" || ko "install: existing skill overwritten"
"$SK/install.sh" --force "$T/skills" >/dev/null
grep -q "local change" "$T/skills/oa-rule-claims/SKILL.md" && ko "install --force: not replaced" || ok "install --force: replaced"
out="$("$SK/install.sh" --from "$T/none" "$T/skills")"
grep -q "no skills in $T/none yet; skipped" <<<"$out" && ok "install --from: a missing folder skipped with a note" || ko "install --from: $out"
mkdir -p "$T/type/oa-x-stage-1"; printf 'bash __KIT__/tools/agent/prompt.sh --assessment x 1\n' > "$T/type/oa-x-stage-1/SKILL.md"
out="$("$SK/install.sh" --from "$T/type" "$T/skills")"
grep -q "installed 1 skills" <<<"$out" && grep -qF "bash $KIT/tools/agent/prompt.sh" "$T/skills/oa-x-stage-1/SKILL.md" \
  && ok "install --from: a type's skills, kit path written" || ko "install --from: $out"
out="$("$SK/install.sh" --from "$SRE" "$T/skills")"
grep -q "installed $srecount skills" <<<"$out" && ! grep -rq "__KIT__" "$T/skills" \
  && grep -qF "bash $KIT/tools/agent/prompt.sh --assessment sre 1\`" "$T/skills/oa-sre-stage-1-inventory/SKILL.md" \
  && ok "install --from: SRE skills, kit path written" || ko "install --from SRE: $out"

E="$T/eng"; mkdir -p "$E" "$T/code"; git -C "$E" init -q
tools/agent/init-engagement.sh --repo "$E" --code "$T/code" --assessment sre --skills skills >/dev/null
[ "$(ls -d "$E"/skills/oa-sre-stage-* | wc -l | tr -d ' ')" -eq "$srecount" ] \
  && ! grep -rq "__KIT__" "$E/skills" && ok "init --assessment sre: SRE skills installed" || ko "init --assessment sre: SRE skills missing"

set +e; "$SK/install.sh" >/dev/null 2>&1; code=$?; set -e
[ $code -eq 2 ] && ok "install: no argument refused" || ko "install: no argument, exit $code"

exit $fail
