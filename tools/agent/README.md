# Agent stages

Stages 2, 4 and 6 of the [agent harness](../../method/agent-harness.md) packaged as prompts. Each
file is a task prompt that any agent able to read files and run the kit's tools can take as is.
The prompts name files and tools, never a product or a model.

| Stage | Prompt | Drafts | Gate before it starts |
|---|---|---|---|
| 2 Target model | [stage-2-target-model.md](stage-2-target-model.md) | `observability-spec.yml`: journeys, functions, error taxonomy | Stage 1 inventory reconciled and confirmed |
| 4 Findings | [stage-4-findings.md](stage-4-findings.md) | Findings in the `finding.md` format, status *assumption* | Stage 3 gap confirmed: each "live" signal checked by a person |
| 6 Recommendations | [stage-6-recommendations.md](stage-6-recommendations.md) | Recommendation cards per `report.md` | Findings confirmed; `maturity.yml` confirmed and clean under `tools/maturity.py` |

Stages 1, 3 and 5 are run with the tools directly ([collect.md](../collect.md),
[speclint.md](../speclint.md), [maturity.md](../maturity.md)).

## How to run a stage

1. Work in the engagement repository, never in this kit. The agent gets read-only access to the
   code checkout and to the monitoring tool, and write access to the engagement repository only.
2. Give the agent the prompt file and the inputs it lists. Missing inputs are not substituted:
   the agent stops and names them.
3. The agent drafts, runs its self-check, and hands over a list of what it could not cite.
4. A person confirms what the prompt's last section names, in the tool, and records the result
   in the facts ledger. Only then does the next stage start.

## Gates

A stage starts only on confirmed output of the stage before it. A finding drafted from an
unconfirmed inventory, or a recommendation drafted from an unconfirmed finding, is not
reviewed: it is discarded and the stage re-run.

## Measuring

Record, per stage and engagement: drafts handed over, drafts accepted without a change of
substance, cited evidence that did not reproduce, and hours the person spent confirming. The
targets and the rule for relying on the harness are in
[agent-harness.md](../../method/agent-harness.md), "Measuring the harness". Until they hold on two
engagements, people write the findings and the agent drafts only the target model.
