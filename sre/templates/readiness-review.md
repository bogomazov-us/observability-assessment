# Readiness review

A production readiness checklist, run once per tier-1 launch and again for each major change
to a tier-1 service (new dependency, new data store, new region, a change of architecture).
The client's service owner runs it; the assessment checks the last tier-1 launch against it
(SRE maturity dimension 10) and hands it over as a recommendation where none exists. An item
without evidence is not met.

Service: [S-NN, name] · Tier: [1] · Change: [launch, or the major change] · Date: [date] ·
Reviewed by: [service owner, SRE] · Decision: [D-NN]

| # | Area | Item | Evidence (link, ticket, `E-` id) | Met (yes, no, n/a with the reason) |
|---|---|---|---|---|
| 1 | Monitoring | SLOs agreed for the service's journeys (`T-` rows) and measured | [dashboard, T-NN] | [yes] |
| 2 | Monitoring | Symptom alerts on the SLOs, each with an owner; telemetry health monitored apart from the service | [alert rules export] | |
| 3 | Runbooks | Every paging alert links a runbook that resolves; the runbook was followed once on stage | [runbook links] | |
| 4 | On-call | A rotation with backup answers the service's pages; escalation path tested; the expected load fits the on-call limit (`T-` row) | [rotation schedule, test page] | |
| 5 | Capacity | Load tested at the forecast peak with headroom; quotas and limits known; autoscaling configured | [load-test report] | |
| 6 | Backups and restore | Backups of every data store monitored; a restore tested within the agreed RPO and RTO (`T-` rows) | [restore record] | |
| 7 | Rollback | Rollback or roll-forward tested; rollout follows the tier's policy (automatic halt) | [deploy history] | |
| 8 | Dependencies | Every dependency in the service catalogue with a tier and owner; timeouts and retries with backoff on its calls; a tier-1 service on a lower-tier dependency accepted in a `D-` row | [catalogue rows S-NN] | |

**Outcome** — recorded as the decision row: go, go with exceptions, or no-go. Each exception is
a risk (`R-`) with an owner and a date to close it; a no-go names the items to meet before the
next review.
