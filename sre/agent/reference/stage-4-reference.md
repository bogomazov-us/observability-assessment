# SRE stage 4 reference — findings

*Reference for [SRE stage 4](../stage-4-findings.md). `prompt.sh --assessment sre 4` does not
append it; the prompt names it, and the agent reads it before steps 2, 5 and 8. A rule here binds
as if it were in the prompt.*

## Checks per dimension

The usual failures, as places to look. Each is a candidate only with evidence, and only against
a target or level the client has confirmed. The dimensions are those of the
[SRE maturity model](../../maturity-model.md); in the focused format, look only in the
mandatory ones (1, 2, 4, 6, 9) unless a finding there leads elsewhere.

| # | Look for |
|---|---|
| 1 | A tier-1 service with no owner; a deploy target or infrastructure resource missing from the catalogue; a tier-1 service on an untiered dependency with no recorded decision |
| 2 | An SLO that is not measured; budgets not tracked; no error-budget policy, or one no release decision has cited |
| 3 | Tier-1 alerts without an owner or a runbook; host and threshold alerts only; a runbook link that does not resolve |
| 4 | Incidents without severity or roles; detection or recovery times not recorded; postmortem action items without owner or date, or overdue; the same cause recurring |
| 5 | One person carrying the rotation; no backup or handover; load above the agreed limit; off-hours pages never reviewed |
| 6 | Rollback never tested; change failure rate unknown; no progressive delivery or automatic halt on tier-1; a failed deployment that took long to recover |
| 7 | A single point of failure in a tier-1 path; calls without timeouts, or retries without backoff; no designed degradation; game-day findings left open |
| 8 | No headroom or autoscaling on tier-1; quotas and limits unknown; no load test before a major change or peak |
| 9 | No RTO or RPO for a tier-1 service; backups not monitored; failed backup jobs; no restore test on record, or one older than the agreed schedule |
| 10 | No readiness review for the last tier-1 launch; repeated manual work with no owner; toil share not measured or above the agreed cap |

## Severity, read for SRE

The scale in [finding.md](../../../templates/finding.md) applies; read its terms this way for
SRE findings.

| Severity | Reading |
|---|---|
| P1 | A tier-1 service can lose data beyond its RPO or stay down beyond its RTO with no tested way back; or a failure reaches customers before anyone is paged; or a recovery path (restore, rollback, failover) is shown not to work |
| P2 | A recovery or safety mechanism is missing, partial or unproven for a tier-1 service; or a condition for keeping a target (owner, measurement, backup monitoring, on-call cover) is missing |
| P3 | Recovery is slower or harder, a record or runbook is stale, or toil is high; recovery itself is not lost |

A restore never tested is P2 by default, since its result is unknown; it is P1 only with
evidence that it cannot succeed (a backup job failing for the whole RPO window, a data store
with no backup).

## Claims about recovery

"Not shown in the records" is not "does not work". A restore, failover or rollback with no test
record is unproven, not failed: the finding says "no restore test on record since [date]", and
the closing criterion is a recorded test run by the client's people.

## Why it matters, for SRE

Name what a customer or the business would feel: a longer outage, data lost beyond the agreed
RPO, a failed change reaching customers, an incident that recurs, an on-call engineer who
cannot keep up and misses a page.

## Overlap topics in the combined format

A finding on a topic of the [overlap table](../../maturity-model.md#overlaps-in-the-combined-format)
names the dimension where the topic is scored:

| Topic | Dimension named in *What follows* |
|---|---|
| Alerts | observability dimension 7 |
| SLO definition and measurement | observability dimension 6 |
| Error-budget policy and the decisions it changed | SRE dimension 2 |
| Incidents | SRE dimension 4 |
| Releases | the angle of the finding: observability dimension 10 (a release proves its signals) or SRE dimension 6 (rollout, rollback, DORA) |
