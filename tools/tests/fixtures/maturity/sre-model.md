# SRE maturity model (test fixture)

Stands in for `sre/maturity-model.md` until that page exists: the dimension names of the PRD
(section 4) and the overlap table of the brief (decision 7), in the shapes the page uses.

| # | Dimension | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 1 | Service catalogue and criticality | | | | | |
| 2 | SLOs and error budgets | | | | | |
| 3 | Monitoring and alerting (light) | | | | | |
| 4 | Incidents and learning | | | | | |
| 5 | On-call health | | | | | |
| 6 | Change safety | | | | | |
| 7 | Resilience architecture and testing | | | | | |
| 8 | Capacity and performance | | | | | |
| 9 | Backup and disaster recovery | | | | | |
| 10 | Operations model: readiness, ownership, toil | | | | | |

| Topic | Observability | SRE | Combined |
|---|---|---|---|
| SLOs | 6: SLIs and SLOs defined and measured | 2: error budget governs decisions | Scored in observability 6; SRE 2 adds the policy and the decisions only |
| Alerts | 7 | 3 (light) | SRE 3 not scored; refers to observability 7 |
| Incidents | 8 | 4 | Scored in SRE 4; observability 8 refers to it |
| Releases | 10: a release proves its signals | 6: rollout, rollback, DORA | Different angles; both scored |
