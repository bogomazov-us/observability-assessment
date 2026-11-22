# Stage and rule skills

Optional wrappers for agent tools that load skills: one folder per skill, each with a
`SKILL.md` (a name, a description that says when it applies, and a short body). They hold no
method of their own: each points at the kit's stage prompt or rule file, which stay the only
source. An agent without skills runs a stage from `tools/agent/prompt.sh` as before.

| Skill | Started by | Points at |
|---|---|---|
| `oa-stage-1-inventory` … `oa-stage-6-recommendations` | the person only: the description says so and the skill turns off the agent starting it on its own | `tools/agent/prompt.sh N`: the stage prompt and the shared rules, the gate check first |
| `oa-sre-stage-1-inventory` … `oa-sre-stage-6-recommendations`, in `sre/agent/skills/` | the person only, as above | `tools/agent/prompt.sh --assessment sre N` |
| `oa-rule-boundaries` | the agent, before reading or querying anything | [rules/boundaries.md](../rules/boundaries.md) |
| `oa-rule-evidence` | the agent, whenever it writes a claim | [rules/evidence.md](../rules/evidence.md) |
| `oa-rule-claims` | the agent, whenever it words a claim | [rules/claims.md](../rules/claims.md) |
| `oa-rule-owner-questions` | the agent, on a question only the owner can decide | [rules/owner-questions.md](../rules/owner-questions.md) |
| `oa-rule-progress-log` | the agent, while a stage runs | [rules/progress-log.md](../rules/progress-log.md) |

The two kinds are kept apart on purpose. Starting a stage is the person's decision, so a stage
skill never starts because the conversation seems to call for it. The rules are discipline the
agent should reach for unasked, also outside a stage run: when it drafts a finding by hand, or
answers a question about an alarm.

## Installing

```
tools/agent/skills/install.sh [--force] [--from DIR] SKILLS_DIR
```

Copies the skills into the engagement's skills directory and writes this kit checkout's
absolute path into each, so the engagement uses the kit at the version checked out. A skill
that already exists there is kept unless `--force` is given. Re-run it after moving the kit or
checking out another release. `--from DIR` installs an assessment type's skills folder
instead, such as `sre/agent/skills`; `init-engagement.sh --skills` installs the folder of each
type in the engagement. The SRE folder holds stage skills only: the rule skills are shared and
come from this folder. The skills read the kit; give the agent read access to it and
no write access, as for the stage prompts.

Tests: `tools/tests/test_skills.sh`.
