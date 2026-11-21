# Agent stages

All six stages of the [agent harness](../../method/agent-harness.md) packaged as prompts. Each
file is a task prompt that any agent able to read files and run the kit's tools can take as is.
The prompts name files and tools, never a product or a model.

| Stage | Prompt | Drafts | Gate before it starts |
|---|---|---|---|
| 1 Inventory | [stage-1-inventory.md](stage-1-inventory.md) | `inventory.md`: objects with one status each, reconciliation, confirmed blind spots | Scope agreed; read-only access granted |
| 2 Target model | [stage-2-target-model.md](stage-2-target-model.md) | `observability-spec.yml`: journeys, functions, error taxonomy | Stage 1 inventory reconciled and confirmed |
| 3 Gap | [stage-3-gap.md](stage-3-gap.md) | `stage-3-gap.md`: signal states with evidence, SLIs computable today, the detection matrix, paging readiness | Stage 2 spec confirmed; owner answers recorded |
| 4 Findings | [stage-4-findings.md](stage-4-findings.md) | Findings in the `finding.md` format, status *assumption* | Stage 3 gap confirmed: each "live" signal checked by a person |
| 5 Maturity | [stage-5-maturity.md](stage-5-maturity.md) | `maturity.yml`: a level per dimension with its evidence and confidence, no overall number | Findings have their verdicts; a level that still waits on one is provisional |
| 6 Recommendations | [stage-6-recommendations.md](stage-6-recommendations.md) | A confirmation batch, `REC-` cards on confirmed findings per `report.md`, `V-` verification tasks, `W-` work items | Findings confirmed; `maturity.yml` confirmed and clean under `tools/maturity.py` |

Stage 1 uses [collect.md](../collect.md), stages 2 and 3 check the spec with
[speclint.md](../speclint.md), and stage 5 checks the profile with [maturity.md](../maturity.md).

## Rules every stage shares

What holds at every stage lives in one file each under [`rules/`](rules/), and each stage
prompt names them instead of repeating them:

| Rule | Holds |
|---|---|
| [boundaries.md](rules/boundaries.md) | Read-only on the estate, writes only in the engagement repository and the scratch directory, nothing secret printed, nothing written is a fact, read only the listed inputs |
| [evidence.md](rules/evidence.md) | Every claim cites what it rests on; what cannot be evidenced is listed, never guessed |
| [claims.md](rules/claims.md) | Claims stay within what was checked: window and place, evaluation is not detection, and the rest |
| [owner-questions.md](rules/owner-questions.md) | Owner questions stay open, candidates are marked, answers count once recorded in the decision register |
| [progress-log.md](rules/progress-log.md) | The progress log: plan, steps, commits, stops, times read from the clock |

A stage file holds only what is its own: its boundaries on top of the common ones, inputs,
method, output, self-check and what the person confirms. `tools/agent/prompt.sh N [OUT.md]`
assembles stage N with the rule files into one prompt.

For agent tools that load skills, [`skills/`](skills/README.md) has thin wrappers: a skill per
stage that only the person starts, and a skill per rule that the agent reaches for itself.
They point at these files and copy nothing.

## Setting up the engagement repository

Once per engagement, before stage 1:

```
tools/agent/init-engagement.sh --repo ENGAGEMENT_REPO --code CODE_CHECKOUT [--code ...] \
    [--skills SKILLS_DIR] [--instructions NAME]
```

It commits nothing. It writes the agent's standing instructions, from
[`templates/agent-instructions.md`](../../templates/agent-instructions.md) with the paths
filled in, to `AGENTS.md` (or `--instructions NAME`, the file your agent tool reads); the
client and the monitoring tool are left for the person. It makes what the path table marks
*init*, its folders, and the scratch directory `.scratch/`, added to `.gitignore`.

With `--skills SKILLS_DIR` it also installs the [stage and rule skills](skills/README.md).
A re-run keeps what exists; `--force` replaces the instructions and the skills (after a kit
upgrade), never the state file, a register, the questions or a progress log. The agent's read-only
boundary is set in the agent tool's own permissions as well: the instructions file alone does
not enforce it. Tests: `tools/tests/test_init_engagement.sh`.

## Artifact paths

Stages read and write at these paths, relative to the working folder (`assessment/`, or
`--work`); `tools/`, `templates/` and `method/` are in the kit. The facts ledger and the
decision and risk registers are at the repository root (`facts.md`, `decisions.md`,
`risks.md`, created only when absent), or where `--facts`, `--decisions`, `--risks` point;
the instructions file names them.

| Path | Made by | Read by |
|---|---|---|
| `engagement-state.yml` | init | every stage, `tools/stagegate.py` |
| `owner-questions.md` | init; every stage adds | the person |
| `progress/stage-N.md` | stage N | the person |
| `kickoff-note.md` (scope, journeys, buyer's question) | the person, from `templates/kickoff-note.md` | 1, 2, 6 |
| `captures/` (sanitized journey captures) | the person | 2 |
| `scan.md` (code scan) | 1 | 2, 4 |
| `exports/` (a file per object class and date) | 1 | 2, 4 |
| `inventory.md` | 1 | 2, 3, 5, report |
| `spec/observability-spec.yml` | 2; 3 sets the signal states | 3, 4, 5 |
| `stage-2-notes.md` | 2 | 3, report |
| `stage-3-gap.md` | 3 | 4, 5, report |
| `findings/F-NNN.md` | 4 | 5, 6 |
| `stage-4-notes.md` | 4 | report |
| `maturity.yml`, `stage-5-notes.md` | 5 | 6, report |
| `recommendations.md` | 6 | report |
| `summary.md` (from `templates/report.md`), `manifest.txt` | the person, at each accepted stage | `tools/assessment-pdf.sh` |

The spec is drafted here; the person takes the confirmed spec set to the client's
`docs/observability/`.
`tools/tests/test_paths.sh` checks the prompts against this table.

## How to run a stage

1. Work in the engagement repository, never in this kit, on a branch or worktree of the
   assessment's own from the first stage: other work in the same repository must not sweep up
   the drafts, nor the drafts sweep up other work. The agent gets read-only access to the code
   checkout and to the monitoring tool, and write access to the engagement repository only.
   The prompt lists the paths it may read; access outside them is refused by the agent's
   permissions as well, not by the prompt alone. The prompt also names one scratch directory
   for temporary files (lint output, rendered pages); a temporary file anywhere else is a
   write outside the boundary, written in the progress log, and the person checks for stray
   files (`git status`, the scratch directory) before confirming the stage.
   When the agent's SDK cannot refresh a single-sign-on session the CLI can, the agent takes
   short-lived credentials in-process from the CLI's own export of the session, never
   printed or written, and says so in the
   progress log. Settle this before the run: on the first one a helper lost minutes to it.
2. Assemble the prompt with `tools/agent/prompt.sh N` and give the agent the result and the
   inputs it lists. Missing inputs are not substituted:
   the agent stops and names them.
3. The agent drafts, keeps a progress log (`progress/stage-N.md`: the plan, each step started
   and done, each commit, each stop), runs its self-check, and hands over a list of what it
   could not cite. While it runs, the person reads the log, not the agent's transcript.4. A person confirms what the prompt's last section names, in the tool, and records the result
   in the facts ledger and the decision register; then sets the stage `confirmed` in
   `engagement-state.yml` and runs `tools/stagegate.py lint engagement-state.yml --since REV`
   against the last confirmation's commit; on the first, the commit that added the file
   (`git log --diff-filter=A --format=%h -- engagement-state.yml`). Only then does the next
   stage start.

## Gates

The gates are kept in `engagement-state.yml` (skeleton:
[`templates/engagement-state.yml`](../../templates/engagement-state.yml)) and checked by
[`tools/stagegate.py`](../stagegate.md): the agent runs its `check` before it starts and stops
when the gate is shut; the person confirms a stage by recording the decision and then setting
the stage `confirmed` with who, when and the decision reference.

A stage starts only on confirmed output of the stage before it, and only when the open
questions that block it have answers from the owner. A question addressed to the owner is
never decided by an agent; an agent launched before the answer leaves it open. An answer
given in a working session is recorded first — in the client's decision register, with the
date and who decided — and documents cite that record, never "the owner said": a reviewer
must be able to find it. A finding drafted from an
unconfirmed inventory, or a recommendation drafted from an unconfirmed finding, is not
reviewed: it is discarded and the stage re-run.

## Measuring

Record, per stage and engagement, from the progress logs and the review records: drafts handed over, drafts accepted without a change of
substance, cited evidence that did not reproduce, agent elapsed time, and hours the person spent
confirming. Record the person's hours per stage next to the agent's time, in the engagement's
stage table; without them there is nothing to compare. These are pilot measurements: agent time is not compared with the estimate's
person-days, and a re-run sample is not an accuracy estimate. The
targets and the rule for relying on the harness are in
[agent-harness.md](../../method/agent-harness.md), "Measuring the harness". Until they hold on two
engagements, people write the findings and the agent drafts only the target model.
