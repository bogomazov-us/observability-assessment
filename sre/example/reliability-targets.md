# Reliability targets — Larkfield Grocer

**Fictional.** `sre/targets/reliability-targets.md` of the [SRE worked example](worked-example.md),
in the [template](../templates/reliability-targets.md)'s format, as stage 3 read it. A row is
`confirmed` once its owner's answer is a decision row.

## Defaults

The focused format leaves dimensions 3, 5 and 10 out of scope: their rows stay default and
were not asked.

| ID | Applies to | Kind | Value | Premise | Default or agreed | Decision | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| T-01 | tier 1 | on-call limit | at most two incidents per 12-hour shift | | default, to confirm | | On-call lead | `proposed` |
| T-02 | each team in scope | toil cap | at most 50% of engineering time | | default, to confirm | | Head of engineering | `proposed` |
| T-03 | tier 1 | actionable alert share | none; the client sets the target | | default, to confirm | | Alert owner | `proposed` |

## Targets

| ID | Applies to | Kind | Value | Premise | Default or agreed | Decision | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| T-04 | S-02 | SLO | `SLO-checkout` of the observability spec: 99.0% of checkout attempts over 28 days | | | | Head of e-commerce | `proposed` |
| T-05 | S-05 | RTO | 1 hour | | agreed | D-13 | Platform technical owner | `confirmed` |
| T-06 | S-05 | RPO | 5 minutes of data | | agreed | D-13 | Platform technical owner | `confirmed` |
| T-07 | S-03 (payments ledger) | RTO | 1 hour | | agreed | D-13 | Payments technical owner | `confirmed` |
| T-08 | S-03 (payments ledger) | RPO | 5 minutes of data | | agreed | D-13 | Payments technical owner | `confirmed` |
| T-09 | tier 1: services; no worker, scheduled task or agent in tier 1 | rollout policy | canary to 10% of traffic with an automatic halt on errors; rollback within 15 minutes | | agreed | D-14 | Release technical owner | `confirmed` |
| T-10 | dimension 1 | target level | 3 | | agreed | D-12 | Head of engineering | `confirmed` |
| T-11 | dimension 4 | target level | 4 | | agreed | D-12 | Head of engineering | `confirmed` |
| T-12 | dimension 6 | target level | 4 | | agreed | D-12 | Head of engineering | `confirmed` |
| T-13 | dimension 9 | target level | 3 | | agreed | D-12 | Head of engineering | `confirmed` |

Measured by: T-05 to T-08, restore records and backup history (E-104, E-105); T-09, the
deploy export (`sre/exports/deploys-2027-06-08.csv`) and the pipeline configuration (E-108);
T-04, the observability spec's SLI, not yet measured; T-10 to T-13, each dimension's
criteria in the [model](../maturity-model.md).

**Combined format.** T-04 cites the observability spec's SLO and has no definition here. The
error-budget policy, SRE's own part, is Q-08 to the head of e-commerce and the head of
engineering together. Dimension 2 has no target level here: observability 6 scores it.

## Glossary

| Name | Meaning |
|---|---|
| orders database | The data store of orders and slot holds, written by `checkout` and `slots` |
| payments ledger | The data store of `payments`: authorisations and their state |
| tier 1 | A service the checkout journey cannot complete without (D-12) |

## Not agreed

| Target | Why | Question | Date |
|---|---|---|---|
| T-01, T-02, T-03 | Not in scope (focused format) | none sent | 2027-06-15 |
| T-04 | The SLO target is the observability spec's, still proposed; the error-budget policy is unanswered | Q-08 | 2027-06-15 | |
