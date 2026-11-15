# Observability assessment — [client]

Instructions for an agent working in this engagement repository. The agent drafts the
assessment stages of the Observability Assessment Kit; a person confirms every result.
`tools/agent/init-engagement.sh` writes this file into the repository with the paths filled in,
under the name the agent tool reads (`AGENTS.md` unless told otherwise); the person fills in
the rows still in square brackets.

## Where things are

| What | Path | Access |
|---|---|---|
| This repository | `.` | read and write, on the assessment branch only |
| The client's code | __CODE__ | read only |
| The kit | `__KIT__` | read only: prompts in `tools/agent/`, templates in `templates/`, tools in `tools/` |
| The assessment's working folder | `__WORK__` | the stage drafts, `engagement-state.yml`, `progress/` |
| Facts ledger | `__FACTS__` | agent rows enter as *assumption* |
| Decision register | `__DECISIONS__` | written by the person, read by the agent |
| Scratch | `__SCRATCH__` | temporary files only; nothing else is written outside this repository |
| Monitoring tool | [tool] through [read-only token, profile or server; named, never pasted] | read only |

Not read, even when present: `.env`, `*.tfstate`, `*.tfvars`, credential folders, backups, and
the client's raw data exports unless the stage prompt lists them.

## How a stage runs

1. The person starts a stage, never the agent. The stage prompt is printed by
   `bash __KIT__/tools/agent/prompt.sh N`: the stage file and the rule files every stage
   shares. Where the agent tool loads skills, the person may start it as the skill
   `oa-stage-N-…` instead; it prints the same prompt. Inputs the prompt lists and the person
   has not given are named and not substituted.
2. Before anything else: `python3 __KIT__/tools/stagegate.py check
   __WORK__/engagement-state.yml N`. When it reports the stage blocked, stop and hand over
   what it reports. Set this stage to `draft` when you start and `handed_over` when you hand
   over; never `returned` or `confirmed`, and never another stage.
3. Work on the assessment branch or the worktree made for it, never on the main branch.
4. Keep `__WORK__/progress/stage-N.md`: the plan, each step started and done, each commit,
   each stop. Times are read from the clock (`date -u`), never estimated.
5. Commit only your own files, by path. Pull before you push.
6. Stop at the end of the stage and hand over the list of what you could not cite, and the
   open owner questions as one batch. The next stage starts only when a person has confirmed
   this one in `engagement-state.yml`.

## Rules

- **Read only outside this repository.** No change to the client's code, monitoring
  configuration, tickets or cloud account. No apply, deploy, delete or write call of any kind.
- **Every claim cites its evidence:** the query and its time range, `file:line`, or the export
  file. A claim says no more than its check (`__KIT__/tools/agent/rules/claims.md`).
- **Agent output is an assumption** in the facts ledger until a person has confirmed it.
- **A signal reported as live is confirmed by the person through another path** (the tool's
  own interface, a browser, a query the person writes), never by re-running the agent's query.
- **Owner questions are not decided here.** Candidate answers are marked as candidates, and
  open questions are handed over as a batch in the format of
  `__KIT__/templates/owner-questions.md`. An owner's answer is recorded in the decision
  register with the date and who decided before any document cites it.
- **Names come from the glossary** in `observability-spec.yml` (stage 2 fixes it). A name it
  lacks, or a thing it names differently, is an open question.
- **Secrets and personal data are never printed or written:** no token, key, password, cookie,
  account id, IP address, user email or name, and no log body. From logs: counts and
  classifications only.
- **A permission refusal is reported, never worked around.** The person does the blocked step.
- **Nothing from here leaves this repository** except what the person sends. Generic lessons
  go to the kit's backlog only rewritten without the client's names.

The agent's permissions enforce the read-only boundary as well; this file alone does not.
