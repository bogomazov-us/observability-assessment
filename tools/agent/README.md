# Agent stages

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

## Setting up the engagement repository

Once per engagement, before stage 1:

```
tools/agent/init-engagement.sh --repo ENGAGEMENT_REPO --code CODE_CHECKOUT [--code ...] \
    [--skills SKILLS_DIR] [--instructions PATH] [--assessment observability|sre ...] \
    [--facts PATH] [--decisions PATH] [--risks PATH] [--work PATH] [--scratch DIR]
```

It commits nothing. It writes the agent's standing instructions, from
[`templates/agent-instructions.md`](../../templates/agent-instructions.md) with the paths
filled in, to `AGENTS.md` (or `--instructions PATH`, the file your agent tool reads, a subpath such as
`.claude/CLAUDE.md` included), every path relative to the repository; the
client and the monitoring tool are left for the person. It makes what the path table marks
*init*, its folders, and the scratch directory `.scratch/`, added to `.gitignore`.
`--assessment sre` (repeatable; the default is observability) adds `sre/` in the working folder:
its own state file, `progress/`, `exports/` and `targets/`. Owner questions and findings stay
shared; with SRE alone, the observability state file and folders are not made. The
instructions file then lists each type's folder, state file and prompt command. A host
knowledge base keeps its own registers: a register named by `--facts`, `--decisions` (a file,
or a folder of ADRs) or `--risks` is never created or written to, and a missing one is reported.

With `--skills SKILLS_DIR` it also installs the [stage and rule skills](skills/README.md) of
each type.
A re-run keeps what exists; `--force` replaces the instructions and the skills (after a kit
upgrade), never a state file, a register, the questions or a progress log. The agent's read-only
boundary is set in the agent tool's own permissions as well: the instructions file alone does
not enforce it. Tests: `tools/tests/test_init_engagement.sh`.

## Artifact paths

Stages read and write at these paths, relative to the working folder (`assessment/`, or
`--work`); `tools/`, `templates/` and `method/` are in the kit. The facts ledger and the
decision and risk registers are at the repository root (`facts.md`, `decisions.md`,
`risks.md`, created only when absent), or where `--facts`, `--decisions`, `--risks` point;
the instructions file names them. Rows marked *every type* are shared by the assessment types
of an engagement; "SRE N" reads the observability file in the combined format; the SRE type's
own paths are in the second table.

| Path | Made by | Read by |
|---|---|---|
| `engagement-state.yml` | init | every stage, `tools/stagegate.py` |
| `owner-questions.md` (every type) | init; every stage adds | the person |
| `progress/stage-N.md` | stage N | the person |
| `kickoff-note.md` (every type; scope, journeys, buyer's question) | the person, from `templates/kickoff-note.md` | 1, 2, 6 |
| `captures/` (sanitized journey captures) | the person | 2 |
| `scan.md` (code scan) | 1 | 2, 4 |
| `exports/` (a file per object class and date) | 1 | 2, 4 |
| `inventory.md` | 1 | 2, 3, 5, report |
| `spec/observability-spec.yml` | 2; 3 sets the signal states | 3, 4, 5; SRE 2 |
| `stage-2-notes.md` | 2 | 3, report |
| `stage-3-gap.md` | 3 | 4, 5, report |
| `findings/F-NNN.md` (every type, one `F-` sequence) | the person, as findings appear; 4 | 4, 5, 6 |
| `stage-4-notes.md` | 4 | report |
| `maturity.yml` | the person (provisional baseline); 5 | 5, 6, report; SRE 5, 6 |
| `stage-5-notes.md` | 5 | 6, report |
| `recommendations.md` | 6 | report; SRE 6 |
| `summary.md` (from `templates/report.md`), `manifest.txt` (every type) | the person, at each accepted stage | `tools/assessment-pdf.sh` |

The SRE type (`--assessment sre`) works in `sre/` under the working folder; stage numbers here
are the SRE stages.

| Path | Made by | Read by |
|---|---|---|
| `sre/engagement-state.yml` | init | every stage, `tools/stagegate.py` |
| `sre/progress/stage-N.md` | stage N | the person |
| `sre/exports/` (a file per object class and date) | 1 | 2, 3, 4, `tools/baseline.py` |
| `sre/inventory.md` | 1 | 2, 3, 4, 5, report |
| `sre/service-catalogue.md` (`S-` rows) | 1; 2 sets the tiers | 2, 3, 4, 6 |
| `sre/baseline.md` (`B-` rows, from `tools/baseline.py`) | 1 | 3, 4, 5, 6, report |
| `sre/target-model.md` | 2 | 3, report |
| `sre/targets/reliability-targets.md` (`T-` rows) | 2 | 3, 4, 5, 6 |
| `sre/stage-3-gap.md` | 3 | 4, 5, report |
| `sre/stage-4-notes.md` | 4 | report |
| `sre/maturity.yml` (`model: sre`) | the person (provisional baseline); 5 | 5, 6, report |
| `sre/stage-5-notes.md` | 5 | 6, report |
| `sre/recommendations.md` | 6 | report |
| `summary.md`, `manifest.txt` (every type; in the working folder itself) | the person, at each accepted stage | `tools/assessment-pdf.sh` |

The spec is drafted here; the person takes the confirmed spec set to the client's
`docs/observability/`.
`tools/tests/test_paths.sh` checks the prompts against this table.
Engagement paths in the instructions file and the installed skills are relative to the main
checkout's root, also when the agent works in a worktree.

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
