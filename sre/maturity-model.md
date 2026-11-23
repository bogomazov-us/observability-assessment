# SRE maturity model

Five levels per dimension, as in the [observability model](../method/maturity-model.md). The
model scores what the organisation can do to keep its services reliable, not which tools it
uses. Report it as a profile, never as one number.

## Scoring rules

The [scoring rules](../method/maturity-model.md#scoring-rules) of the observability model apply
as they are: scope first, evidence per score, not scored is not level 1, N/A only by agreement,
a confidence per score, no overall average. No SRE dimension is optional; N/A follows rule 5.

A criterion met only on paper (a support mode agreed in a contract, no page or rota in the
window showing it ran) is documented, not in place: the level it would give reads partial.

"Tier-1" means the services in scope that serve critical journeys, with the tiers agreed in
dimension 1.

Record the scores in `maturity.yml` with `model: sre`; the [maturity calculator](../tools/maturity.md)
checks them and prints the profile.

## Dimensions

| # | Dimension | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 1 | Service catalogue and criticality | No list of services; dependencies known by people | Services listed, no tiers or owners | Tier-1 services with owners; tiers agreed; dependencies recorded | Catalogue checked against deploys or infrastructure; no tier-1 service on an untiered dependency without a recorded decision | Tier drives paging, change rules and review depth |
| 2 | SLOs and error budgets | None | Targets in contracts only | SLOs on some tier-1 services, measured | SLOs on all tier-1 services; budgets tracked; error-budget policy agreed by product and engineering | The policy has changed decisions, on record |
| 3 | Monitoring and alerting (light) | Host and threshold alerts, noisy | Per-service alerts, no owners | Symptom alerts on tier-1 with owners and runbooks | Burn-rate alerts on SLOs; actionable share measured | Actionable share held at an agreed target. Depth: the observability assessment |
| 4 | Incidents and learning | Ad hoc; customers report outages | On-call exists; no roles or severity levels; reviews for some major incidents | Severity levels and roles; incidents recorded; a blameless review above an agreed severity, with action items that have owners and dates | Detection and recovery times measured per severity, and outages apart from data-correctness defects; a way to detect a data-correctness defect, its detection time measured; action-item closure and recurrence measured; overdue items escalated | Process exercised; times at target; themes across incidents drive the roadmap; known causes do not recur |
| 5 | On-call health | Nobody on call, or always one person | A rotation exists; load unknown | Rotation with backup and handover; pages counted per shift | Load within the agreed limit (default: at most two incidents per 12-hour shift); off-hours pages reviewed and reduced | Load reviewed regularly; rotation size follows the load |
| 6 | Change safety | Manual releases; no rollback path | Automated deploy; rollback manual and untested | Rollback or roll-forward tested; change failure rate known | Progressive delivery on tier-1 with automatic halt; DORA four keys measured | Release decisions use SLO and budget data; recovery from a failed deployment within target |
| 7 | Resilience architecture and testing | Single points of failure unknown | Known, not addressed | Tier-1 redundant across failure domains; timeouts and retries with backoff on tier-1 calls | Failure modes of tier-1 dependencies analysed; degradation designed (circuit breakers, fallbacks, load shedding); game days on stage | Dependency failures contained without customer impact, shown by regular fault injection |
| 8 | Capacity and performance | Capacity found out in incidents | Utilisation watched; scaling by hand | Autoscaling or headroom on tier-1; quotas and limits known | Demand forecast for tier-1; load tests before major changes and peaks | Capacity planned from business forecasts; load tests in the delivery pipeline |
| 9 | Backup and disaster recovery | Backups unknown | Backups exist; restore never tried | RTO and RPO set per tier-1 service; backups monitored; restore tested for some data stores; a restore counts only from the backups the RPO relies on | Restore tested for every tier-1 data store within RPO and RTO, on a schedule; DR plan written | DR exercised end to end (region or account loss) within target |
| 10 | Operations model: readiness, ownership, toil | Services go live unchecked; toil not recognised | Readiness checklist not enforced; repeated manual work known by people | Readiness review for new tier-1 services; toil inventoried, with owners for the biggest items | Review repeated for major changes; responsibilities written down; toil share measured and under the agreed cap (default 50%) | SRE support tied to meeting SLOs, with handback; toil automation is budgeted work and trends down |

**Default thresholds.** The client confirms or replaces each in stage 2; the agreed value is a
row in the decision register.

| Threshold | Dimension | Default |
|---|---|---|
| Incidents per 12-hour on-call shift | 5 | at most two |
| Toil share of engineering time | 10 | at most 50% |
| Actionable alert share | 3 | none; the client sets the target |

**DORA keys.** Level 4 of dimension 6 asks for the four keys. DORA now publishes a fifth metric,
deployment rework rate; record it when the data allows, but it does not gate the level.

## Evidence per dimension

The agent reads exports, read-only. People confirm whatever the agent cannot see.

| # | Primary evidence (tool) | Cross-check (another path) |
|---|---|---|
| 1 | Service registry or CMDB export; infrastructure as code; deploy targets | Owners named in interviews; a paging route per service |
| 2 | SLO definitions in the monitoring tool; SLO reports | Error-budget policy document; a release decision that cites it |
| 3 | Alert rules export; paging history | Runbook links resolve; owners confirm |
| 4 | Incident tracker export (severity, start, detection, mitigation, resolution); postmortems; action-item tickets with dates and state | Status-page history and chat timelines for a sample; incidents that cite the same cause |
| 5 | Paging export (pages per shift, off-hours share); rotation schedule | Interviews with on-call engineers |
| 6 | CI/CD history (deploys, failures, rollbacks); deployment configuration (rollout strategy) | Change failure rate checked against incidents linked to changes |
| 7 | Infrastructure as code (zones, replicas, failover); client code (timeouts, retries, circuit breakers); game-day and fault-injection records | Architecture review with the client's architect; an incident that tested it; test findings tracked to closure |
| 8 | Utilisation and scaling metrics; autoscaling configuration; quota usage | Load-test reports; peak-event history |
| 9 | Backup job configuration and history; restore test records | A restore drill observed or run with the client's people (optional proof in the full format) |
| 10 | Readiness checklist and its completed reviews; tickets and runbooks showing repeated manual tasks; time tracking if any | The last tier-1 launch checked against the list; team interviews or a toil survey |

## Mapping to external frameworks

Names checked on 2026-11-22 against the DORA metrics guide (last updated 5 January 2026), the
DORA capabilities list, and the reliability pillar of the AWS Well-Architected Framework (pillar
whitepaper last revised 6 November 2024; its guidance now lives in the Framework whitepaper).
The mapping orients a reader; it does not change a score.

| # | DORA | AWS Well-Architected, reliability pillar |
|---|---|---|
| 1 | — | Workload architecture: design your workload service architecture |
| 2 | Reliability (operational performance, not a delivery metric) | Change management: monitor workload resources |
| 3 | Capabilities: monitoring and observability; proactive failure notification | Change management: monitor workload resources |
| 4 | Failed deployment recovery time (incidents caused by a change) | Failure management: test reliability (post-incident analysis) |
| 5 | Capability: well-being | — |
| 6 | Change lead time, deployment frequency, change fail rate, failed deployment recovery time, deployment rework rate | Change management: implement change |
| 7 | — | Workload architecture: design interactions to prevent, and to mitigate or withstand, failures; failure management: fault isolation, withstand component failures, test reliability |
| 8 | — | Foundations: manage service quotas and constraints; change management: adapt to changes in demand |
| 9 | — | Failure management: back up data; plan for disaster recovery |
| 10 | — | (Operational excellence pillar: operational readiness reviews) |

## Overlaps in the combined format

A topic present in both models is scored once, in the dimension with the deeper criteria; the
other profile says "see …" and adds only what is its own. The maturity calculator applies this
table when both profiles are checked together.

| Topic | Observability | SRE | Combined |
|---|---|---|---|
| SLOs | 6: SLIs and SLOs defined and measured | 2: error budget governs decisions | Scored in observability 6; SRE 2 adds the policy and the decisions only |
| Alerts | 7 | 3 (light) | SRE 3 not scored; refers to observability 7 |
| Incidents | 8 | 4 | Scored in SRE 4; observability 8 refers to it |
| Releases | 10: a release proves its signals | 6: rollout, rollback, DORA | Different angles; both scored |

## Example row

| Dimension | Level | Coverage | Evidence | Confidence |
|---|---|---|---|---|
| 9 Backup and disaster recovery | 2 (partial 3) | RTO and RPO set for 2 of 4 tier-1 services; one restore test on record | backup job history export; restore ticket | high |
