# Data we ask for first: SRE rows

When the type is SRE, these rows are added to the [core data request](../../templates/data-request.md)
and sent with it on day one. Columns and rules are the core's. "Needed by" is the week of the
engagement by which the stage that uses the item starts; the weeks are the
[calendar](../../method/getting-started.md#3-calendar)'s, read for the SRE format. "Dimension" is the
[SRE maturity model](../maturity-model.md)'s.

| # | Item | Why | Client provider | Needed by (week) | Received |
|---|---|---|---|---|---|
| S1 | Incident export for 6–12 months: id, service, severity, start, detection, mitigation, resolution, cause category, linked change | Detection and recovery times per severity; recurrence (dimension 4) | Operations | 1 | [date] |
| S2 | Postmortems above the agreed severity, and their action-item tickets with owner role, due date and state | Learning and action-item closure (dimension 4) | Incident or problem manager | 2 | [date] |
| S3 | Paging export for 3–6 months (page, service, time, responder id, acknowledged, escalated) and the rotation schedule | Pages per shift, off-hours share (dimension 5) | On-call lead | 1 | [date] |
| S4 | CI/CD deploy history for 6 months: service, start, end, result, rollback, and whether each deploy was planned or an unplanned fix of a production issue; rollout configuration | DORA keys and deployment rework rate; change safety (dimension 6) | Release or platform engineering | 1 | [date] |
| S5 | Read-only access to infrastructure as code for tier-1 services | Catalogue cross-check, redundancy, failover (dimensions 1, 7) | Platform | 1 | [date] |
| S6 | Backup job configuration and history; restore test records with date, data store, duration and result | Recovery against RPO and RTO (dimension 9) | Data store owners | 1 | [date] |
| S7 | Capacity metrics for tier-1 (utilisation, scaling events), autoscaling configuration, quotas and their usage | Headroom and limits (dimension 8) | Platform | 2 | [date] |
| S8 | Load-test reports of the last 12 months, and peak-event history | Tested capacity (dimension 8) | Performance or engineering lead | 2 | [date] |

Rules: exports are minimal and sanitized by
[the privacy checklist](../../templates/privacy-checklist.md) before they reach the engagement
repository. Only the fields listed are asked for. People are replaced by roles or opaque ids
(paging needs an id per responder to count load, never a name); free-text titles, descriptions,
chat logs and commit messages are left out or stripped of customer data and names. Access is
read-only, through a token in a secret store.
