## stdout
wrote AGENTS.md
wrote assessment/engagement-state.yml
wrote assessment/owner-questions.md
wrote assessment/progress/
wrote assessment/captures/
wrote assessment/exports/
wrote assessment/spec/
wrote assessment/findings/
wrote facts.md
wrote decisions.md
wrote risks.md
installed 11 skills into [tmp]/eng/skills
added .scratch/ to .gitignore

Next, by hand:
  1. Fill in the rows of AGENTS.md still in square brackets: the client and the client's tools.
  2. Give the agent read-only access to the code and the tool, and write access to this
     repository only, in the agent tool's own permissions.
  3. Record the agreed scope in decisions.md and set scope in assessment/engagement-state.yml.
  4. Review and commit these files on the assessment branch; then start stage 1.
## files
.
./.gitignore
./.scratch
./AGENTS.md
./assessment
./assessment/captures
./assessment/captures/.gitkeep
./assessment/engagement-state.yml
./assessment/exports
./assessment/exports/.gitkeep
./assessment/findings
./assessment/findings/.gitkeep
./assessment/owner-questions.md
./assessment/progress
./assessment/progress/.gitkeep
./assessment/spec
./assessment/spec/.gitkeep
./decisions.md
./facts.md
./risks.md
./skills
./skills/oa-rule-boundaries
./skills/oa-rule-boundaries/SKILL.md
./skills/oa-rule-claims
./skills/oa-rule-claims/SKILL.md
./skills/oa-rule-evidence
./skills/oa-rule-evidence/SKILL.md
./skills/oa-rule-owner-questions
./skills/oa-rule-owner-questions/SKILL.md
./skills/oa-rule-progress-log
./skills/oa-rule-progress-log/SKILL.md
./skills/oa-stage-1-inventory
./skills/oa-stage-1-inventory/SKILL.md
./skills/oa-stage-2-target-model
./skills/oa-stage-2-target-model/SKILL.md
./skills/oa-stage-3-gap
./skills/oa-stage-3-gap/SKILL.md
./skills/oa-stage-4-findings
./skills/oa-stage-4-findings/SKILL.md
./skills/oa-stage-5-maturity
./skills/oa-stage-5-maturity/SKILL.md
./skills/oa-stage-6-recommendations
./skills/oa-stage-6-recommendations/SKILL.md
## AGENTS.md
# Observability assessment — [client]

Instructions for an agent working in this engagement repository. The agent drafts the
assessment stages of the kit; a person confirms every result.
`tools/agent/init-engagement.sh` writes this file into the repository with the paths filled in,
under the name the agent tool reads (`AGENTS.md` unless told otherwise); the person fills in
the rows still in square brackets.

## Where things are

| What | Path | Access |
|---|---|---|
| This repository | `.` | read and write, on the assessment branch only; the paths below are relative to its root (in a worktree elsewhere, to the main checkout's) |
| The client's code | `../code-a`, `../code-b` | read only |
| The kit | `[kit]` | read only: prompts in `tools/agent/`, templates in `templates/`, tools in `tools/` |
| The assessment's working folder | `assessment` | what the stages read and write, laid out as the table "Artifact paths" in `[kit]/tools/agent/README.md`; a path in a stage prompt is relative to this folder, except under `tools/`, `templates/` and `method/`, which are in the kit |
| Facts ledger | `facts.md` | agent rows enter as *assumption* |
| Decision register | `decisions.md` | written by the person, read by the agent |
| Risk register | `risks.md` | written by the person; the agent hands over proposed rows |
| Scratch | `.scratch` | temporary files only; nothing else is written outside this repository |
| The client's tools | [tool] through [read-only token, profile or server; named, never pasted] | read only |

Not read, even when present: `.env`, `*.tfstate`, `*.tfvars`, credential folders, backups, and
the client's raw data exports unless the stage prompt lists them.

## How a stage runs

1. The person starts a stage, never the agent. The stage prompt is printed by
   `bash [kit]/tools/agent/prompt.sh N`: the stage file and the rule files every stage
   shares. Where the agent tool loads skills, the person may start it as the skill
   `oa-stage-N-…` instead; it prints the same prompt. Inputs the prompt lists and the person
   has not given are named and not substituted.
2. Before anything else: `python3 [kit]/tools/stagegate.py check
   assessment/engagement-state.yml N`. When it reports the stage blocked, stop and hand over
   what it reports. Set this stage to `draft` when you start and `handed_over` when you hand
   over; never `returned` or `confirmed`, and never another stage.
3. Work on the assessment branch or the worktree made for it, never on the main branch.
4. Keep `assessment/progress/stage-N.md`: the plan, each step started and done, each commit,
   each stop. Times are read from the clock (`date -u`), never estimated.
5. Commit only your own files, by path. Pull before you push.
6. Stop at the end of the stage and hand over the list of what you could not cite, and the
   open owner questions as one batch. The next stage starts only when a person has confirmed
   this one in `engagement-state.yml`.

## Rules

- **Read only outside this repository.** No change to the client's code, monitoring
  configuration, tickets or cloud account. No apply, deploy, delete or write call of any kind.
- **Every claim cites its evidence:** the query and its time range, `file:line`, or the export
  file. A claim says no more than its check (`[kit]/tools/agent/rules/claims.md`).
- **Agent output is an assumption** in the facts ledger until a person has confirmed it.
- **A signal reported as live is confirmed by the person through another path** (the tool's
  own interface, a browser, a query the person writes), never by re-running the agent's query.
- **Owner questions are not decided here.** Candidate answers are marked as candidates, and
  open questions are handed over as a batch in the format of
  `[kit]/templates/owner-questions.md`. An owner's answer is recorded in the decision
  register with the date and who decided before any document cites it.
- **Names come from the glossary** that stage 2 fixes. A name it lacks, or a thing it names
  differently, is an open question.
- **Secrets and personal data are never printed or written:** no token, key, password, cookie,
  account id, IP address, user email or name, and no log body. From logs: counts and
  classifications only.
- **A permission refusal is reported, never worked around.** The person does the blocked step.
- **Nothing from here leaves this repository** except what the person sends. Generic lessons
  go to the kit's backlog only rewritten without the client's names.

The agent's permissions enforce the read-only boundary as well; this file alone does not.
## facts.md
# Facts ledger

What is known about the estate, with a status and a source. Ids are `O-01`, `O-02` …, never
renumbered. Agent output enters as *assumption* until a person confirms it.

| ID | Fact | Status | Source | Date |
|---|---|---|---|---|
## decisions.md
# Decision register

Owner answers, scope and stage confirmations, each with who decided and when. Ids are `D-01`,
`D-02` …; documents cite them, never "the owner said". An architecture decision also gets an
ADR file, cited under Evidence.

| ID | Decision | Decided by | Date | Evidence |
|---|---|---|---|---|
## .gitignore
.scratch/
