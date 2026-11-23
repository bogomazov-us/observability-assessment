# SRE stage 4 reference — findings

*Reference for [SRE stage 4](../stage-4-findings.md). `prompt.sh --assessment sre 4` does not
append it; the prompt names it, and the agent reads it before steps 2, 5 and 8 and the Output. A
rule here binds as if it were in the prompt.*

## Checks per dimension

The usual failures, as places to look. Each is a candidate only with evidence, and only against
a target or level the client has confirmed, or against none by the owner's choice (below). The
dimensions are those of the [SRE maturity model](../../maturity-model.md); in the focused
format, look only in the mandatory ones (1, 2, 4, 6, 9) unless a finding there leads elsewhere.

| # | Look for |
|---|---|
| 1 | A tier-1 service with no owner; a deploy target or infrastructure resource missing from the catalogue; a tier-1 service on an untiered dependency with no recorded decision |
| 2 | An SLO that is not measured; budgets not tracked; no error-budget policy, or one no release decision has cited |
| 3 | Tier-1 alerts without an owner or a runbook; host and threshold alerts only; a runbook link that does not resolve |
| 4 | Incidents without severity or roles; detection or recovery times not recorded, read per class (outage, data correctness), never over both; no way to detect a data-correctness defect; postmortem action items without owner or date, or overdue; the same cause recurring |
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

**Examples.**
- *Process absent, recovery met anyway.* One operator restores by hand, with no runbook and
  no second person, and every outage in the window ended inside the RTO. The target was met,
  so not P1; a condition for keeping it is missing: P2. *What we see* cites the outages and
  their times and says that the result rests on one person.
- *On-call agreed on paper.* A support mode (hours, rota, escalation) is agreed in a contract
  or a policy, and no page answered, rota or escalation in the window shows it ran. On-call
  cover is unproven: P2, P1 only when a failure reached customers with no one paged. For
  dimension 4, level 2 ("on-call exists") rests on a record that it ran; the agreement alone
  is *documented* (stage 3), and the level reads 1 (partial 2), the agreement cited.

## A gap with no target, by the owner's choice

A gap row whose Target reads *none, by the owner's choice* (`D-NN`) has no target to miss;
never write it as a gap against a target nobody set. Write it one of two ways:
- **A finding**, when the current state carries a risk: *What we see* gives the current state
  and cites the `D-` row; the severity is read against the risk with the table above (data
  lost, an outage that lasts, a change reaching customers), not against a target; the closing
  criterion is the practice in place or a target agreed.
- **A recorded decision**, when the owner accepted the state knowingly and nothing new is
  shown: no finding; the notes list the dimension under "Accepted by the owner" with the `D-`
  row.

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

## Output

`sre/stage-4-notes.md`:

1. One page of result: findings by severity and by dimension, the five to seven that matter
   most, what was not evidenced, the next step.
2. The reconciliation (step 0).
3. The evidence catalog: `E-` id, source, window, method, result, limits.
4. The facts-ledger rows these findings rest on, proposed, status assumption.
5. "Could not evidence": claim, what is missing, who can provide it.
6. The verdict batch, drafted in the format of
   [`owner-questions.md`](../../../templates/owner-questions.md), no verdict filled in; each
   finding's options are the five verdicts.
   - **About ten per batch**
     ([owner-questions.md](../../../templates/owner-questions.md)). When separate findings
     exceed it, split the batch by verdict owner, most blocking first; or group findings that
     rest on one evidence read and one owner as one item with a verdict per id
     (`F-014, F-015: confirmed`). Never merge findings to fit a batch.
   - **Combined format.** The batch also carries the other type's findings still without a
     verdict that an SRE finding or a stage-5 level rests on, each marked with its type: their
     owner gives the verdict here, or the level stays provisional.

The counts state each withdrawn id, with the reason.
