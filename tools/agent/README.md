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
| 5 Maturity | [stage-5-maturity.md](stage-5-maturity.md) | `maturity.yml`: a level per dimension with its evidence and confidence, no overall number | Findings confirmed |
| 6 Recommendations | [stage-6-recommendations.md](stage-6-recommendations.md) | Recommendation cards per `report.md` | Findings confirmed; `maturity.yml` confirmed and clean under `tools/maturity.py` |

Stage 1 uses [collect.md](../collect.md), stages 2 and 3 check the spec with
[speclint.md](../speclint.md), and stage 5 checks the profile with [maturity.md](../maturity.md).

## How to run a stage

1. Work in the engagement repository, never in this kit, on a branch or worktree of the
   assessment's own from the first stage: other work in the same repository must not sweep up
   the drafts, nor the drafts sweep up other work. The agent gets read-only access to the code
   checkout and to the monitoring tool, and write access to the engagement repository only.
   The prompt lists the paths it may read; access outside them is refused by the agent's
   permissions as well, not by the prompt alone.
2. Give the agent the prompt file and the inputs it lists. Missing inputs are not substituted:
   the agent stops and names them.
3. The agent drafts, keeps a progress log (`progress/stage-N.md`: the plan, each step started
   and done, each commit, each stop), runs its self-check, and hands over a list of what it
   could not cite. While it runs, the person reads the log, not the agent's transcript.
4. A person confirms what the prompt's last section names, in the tool, and records the result
   in the facts ledger. Only then does the next stage start.

## Gates

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
