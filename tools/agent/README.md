# Agent stages

**What is here:** the six stage prompts, the rules they share, how to run a stage, its gates
and what to measure. **Read it when:** you run or confirm a stage. Setting up the engagement
repository and the artifact paths: [setup.md](setup.md).

All six stages of the [agent harness](../../method/agent-harness.md) packaged as prompts. Each
file is a task prompt that any agent able to read files and run the kit's tools can take as is.
The prompts name files and tools, never a product or a model.

| Stage | Prompt | Drafts | Gate before it starts (confirmed by the [calendar](../../method/getting-started.md#3-calendar)'s week) |
|---|---|---|---|
| 1 Inventory | [stage-1-inventory.md](stage-1-inventory.md) | `inventory.md`: objects with one status each, reconciliation, confirmed blind spots | Scope agreed; read-only access granted |
| 2 Target model | [stage-2-target-model.md](stage-2-target-model.md) | `observability-spec.yml`: journeys, functions, error taxonomy | Stage 1 inventory reconciled and confirmed |
| 3 Gap | [stage-3-gap.md](stage-3-gap.md) | `stage-3-gap.md`: signal states with evidence, SLIs computable today, the detection matrix, paging readiness | Stage 2 spec confirmed; owner answers recorded |
| 4 Findings | [stage-4-findings.md](stage-4-findings.md) | Findings in the `finding.md` format, status *assumption* | Stage 3 gap confirmed: a sample of "live" signals and each "proven" detection checked by a person through another path than the agent's query |
| 5 Maturity | [stage-5-maturity.md](stage-5-maturity.md) | `maturity.yml`: a level per dimension with its evidence and confidence, no overall number | Stage 4 confirmed: every draft re-checked and its verdict recorded or sent in the verdict batch; a finding still waiting stays *assumption*, and a level resting on it is provisional |
| 6 Recommendations | [stage-6-recommendations.md](stage-6-recommendations.md) | A confirmation batch, `REC-` cards on confirmed findings per `report.md`, `V-` verification tasks, `W-` work items | Stage 5 confirmed: `maturity.yml` clean under `tools/maturity.py`; findings still *assumption* go into the confirmation batch first |

**Optional second reading.** After stage 4 a person may run
[review-findings.md](review-findings.md): a second reader of the drafts against the claim rules,
writing recommendations into the review file and nothing else. It is not a stage and not
evidence; whether it earns its review time is measured, not assumed.

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
assembles stage N with the rule files into one prompt; `--assessment sre` before N takes the
stage file from `sre/agent/` instead.

For agent tools that load skills, [`skills/`](skills/README.md) has thin wrappers: a skill per
stage that only the person starts, and a skill per rule that the agent reaches for itself.
They point at these files and copy nothing.

## How to run a stage

The person's steps are in [getting-started.md](../../method/getting-started.md) §6. Beyond
the prompt:

- Work in the engagement repository, never in this kit, on the assessment's own branch or
  worktree; access is enforced by the agent's permissions, not the prompt alone
  ([boundaries](../../method/agent-harness.md#boundaries)).
- The prompt names one scratch directory for temporary files (lint output, rendered pages); a
  temporary file anywhere else is a write outside the boundary, written in the progress log.
  The person checks for stray files (`git status`, the scratch directory) before confirming.
- When the agent's SDK cannot refresh a single-sign-on session the CLI can, the agent takes
  short-lived credentials in-process from the CLI's own export of the session, never printed
  or written, and says so in the progress log. Settle this before the run: on the first one a
  helper lost minutes to it.

## Gates

The gates are kept in `engagement-state.yml` (skeleton:
[`templates/engagement-state.yml`](../../templates/engagement-state.yml)) and checked by
[`tools/stagegate.py`](../stagegate.md): the agent runs its `check` before it starts and stops
when the gate is shut.

A stage starts only on confirmed output of the stage before it, and only when the open
questions that block it have answers recorded in the client's decision register
([records.md](../../method/records.md); the [owner-questions rule](rules/owner-questions.md)).
A finding drafted from an unconfirmed inventory, or a recommendation drafted from an unconfirmed finding, is not
reviewed: it is discarded and the stage re-run.

## Measuring

Record, per stage and engagement, from the progress logs and the review records: drafts handed
over, drafts accepted without a change of substance, cited evidence that did not reproduce,
agent elapsed time, and the person's hours confirming, at the end of the stage's review record
([example](../../example/agent/reviews/stage-3-round-1.md)). The
targets, how to count them and what the drafts count for until they hold:
[agent-harness.md](../../method/agent-harness.md), "Measuring the harness".
