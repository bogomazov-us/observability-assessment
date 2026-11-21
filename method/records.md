# Records, roles and statuses

Who decides what, where a decision is written, what each id prefix means and which values each
status takes — defined once here. Templates and prompts link to this page instead of restating
it; a list repeated elsewhere is identical to the one here.

## Roles

| Role | Who | Sets |
|---|---|---|
| Sponsor | The client's buyer of the assessment; chairs kick-off and read-out | Scope, the next-step decision, acceptance of a deliverable |
| Technical owner | The client's owner of a monitoring tool, platform, on-call rota or product function | Gives access and exports; signs an SLO target and an alert's owner and threshold |
| Owner of a finding's verdict | The technical owner of what the finding is about, named in the verdict batch | The verdict, in writing |
| Owner of a decision | Whoever has authority for that decision: the sponsor for scope and next step, a technical owner for a target, a threshold or a verdict | The decision; named under "Decided by" in the register |
| Lead | The engagement lead, accountable, writes the report; does the work of any role not staffed | Records decisions, facts and severities; returns or confirms a stage |
| Reviewer | Whoever runs a review round ([review.md](../templates/review.md)) | Item and round verdicts of the review only; a reading of evidence is a recommendation |
| Agent | An agent running a stage prompt | Its own stage `draft` or `handed_over`; everything it writes enters as an assumption or proposed |

"The owner", unqualified, is the owner of the decision at hand. A question for the owner is
never decided by the lead, a reviewer or an agent.

## Where a decision is recorded

- **Every decision is a row in the decision register** (`decisions.md`, created by
  `init-engagement.sh`): scope, an owner's answer, a verdict, a stage confirmation, an agreed
  target. The row has a `D-` id, the decision, who decided, the date and the evidence (the
  written answer). It is recorded before any document cites it; documents cite the id, never
  "the owner said".
- **An architecture decision also gets an ADR file** — one that fixes how the client's system
  or its telemetry is built, with alternatives worth keeping. It uses
  [adr.md](../templates/adr.md) (`ADR-` id); its register row cites
  the ADR id under Evidence. The ADR does not replace the row.
- **A row is never edited.** A changed decision is a new row whose status line names the row it
  supersedes; the old row is marked superseded with a link to the new one.

## Id prefixes

Ids are stable: never renumbered or reused; a superseded record keeps its id with a link to what
replaced it. One prefix, one kind of record.

| Prefix | Record | File | Written by |
|---|---|---|---|
| `O-` | Fact | Facts ledger (`facts.md`) | Lead |
| `D-` | Decision | Decision register (`decisions.md`) | Lead, for the owner of the decision |
| `ADR-` | Architecture decision | [adr.md](../templates/adr.md), cited from its `D-` row | Lead |
| `R-` | Risk | Risk register (`risks.md`, [risk-register.md](../templates/risk-register.md)) | Lead; the agent proposes |
| `Q-` | Owner question | [owner-questions.md](../templates/owner-questions.md), `engagement-state.yml` | Lead; the agent proposes |
| `L-` | Inventory row | Stage 1 `inventory.md` | Agent or lead |
| `E-` | Evidence check | Evidence catalog of each stage (stage 1 E-1xx, stage 2 E-2xx …) | Whoever ran the check |
| `G-` | Gap result | Stage 3 report | Agent or lead |
| `F-` | Finding | `findings/F-NNN.md` ([finding.md](../templates/finding.md)) | Agent or lead; verdict by its owner |
| `REC-` | Recommendation, on confirmed findings only | Stage 6, [report.md](../templates/report.md) | Agent or lead |
| `V-` | Verification task for an assumption | Stage 6 | Agent or lead |
| `W-` | Work towards an accepted decision | Stage 6, [roadmap.md](../templates/roadmap.md) | Agent or lead |
| `M-` | Milestone | [roadmap.md](../templates/roadmap.md) | Lead |
| `CR-` | Change request | [sow.md](../templates/sow.md) | Lead |
| `R` (no hyphen) | Review item | [review.md](../templates/review.md) | Reviewer |

Spec ids (journeys, functions, SLOs, alerts) are the spec's own and checked by speclint. Tool
rule ids (`G01`, `SL001`, `M04`, `W01`) have no hyphen and are not records.

## Status sets

Each set is a separate field; one word never stands for two. An accepted decision is not an
implemented function, and an implemented function is not a proven detection.

| Set | Values | Where | Set by |
|---|---|---|---|
| Stage status | `not_started` · `draft` · `handed_over` · `returned` · `confirmed` | `engagement-state.yml`; stagegate | Agent: `draft`, `handed_over`; lead: `returned`, `confirmed` |
| Inventory object | confirmed · differs · not found · not verifiable | Stage 1 | Agent; lead confirms with the stage |
| Signal state | `live` · `differs` · `to_build` · `not_verifiable` | Spec `signals`; stage 3; speclint | Agent; lead confirms with the stage |
| Spec row status | `proposed` · `confirmed` | Spec `slos`, `alerts`; speclint | `confirmed` once a technical owner agreed target, owner and threshold |
| Alert state | `shadow` · `paging` | Spec `alerts`; [slo-alerts](../templates/spec-set/slo-alerts.md) | `paging` only when its paging gate is shown |
| Error class | `expected` · `failure` · `caller_defect` · `ambiguous` · `unknown` · `none` | Spec `taxonomy`; speclint | Agent; lead checks against the code path |
| User impact | `blocked` · `degraded` · `unaffected` · `unknown` | Spec `taxonomy`; speclint | As error class |
| Severity | `P1` · `P2` · `P3` | A finding (scale in [finding.md](../templates/finding.md)); separately, an alert's paging severity; speclint | Agent proposes; lead sets, with the reason |
| Finding verdict | assumption (drafted) · confirmed · disputed · refuted · inconclusive · resolved | [finding.md](../templates/finding.md) | Owner of the finding's verdict |
| Decision | proposed · accepted · superseded | Register, finding, stage report | Owner of the decision; lead records |
| Implementation | absent · partial · implemented | Finding, stage report | Lead, from evidence |
| Verification | untested · observed · reproduced | Finding, stage report | Lead, from evidence |
| Fact | assumption · confirmed · disputed · refuted | Facts ledger | Agent output enters as assumption; lead confirms; never deleted |
| Risk | open · accepted · mitigated · closed · superseded | Risk register | Lead records; owner *proposed* until the client's owner accepts |
| Evidence level | browser · agent · tenant · document only | Finding; playbook principle 3 | Whoever cites it |
| Confidence | `high` · `medium` · `low` | Finding, stage report, maturity; maturity.py | Author, with the reason |
| Maturity score | `scored` · `partial` · `not_scored` · `na`; a level 1–5, marked provisional until its findings' verdicts | `maturity.yml`; maturity.py | Agent; lead confirms with stage 5; `na` with the client's agreement |
| Document status | draft · accepted | Stage report header | Lead |
| Review | item: open · closed · accepted as a known limitation; round: approved · approved with changes · rework | [review.md](../templates/review.md) | Reviewer |
| Acceptance | accepted · accepted with limitations · rejected; for implementation go · go with exceptions · no-go | [acceptance.md](../templates/acceptance.md) | Sponsor |

Values in `code` are what a tool accepts; `tools/tests/test_records.sh` checks them against
stagegate, speclint and maturity.
