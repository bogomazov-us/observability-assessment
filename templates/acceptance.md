# Acceptance record

One record per deliverable named in the statement of work ([sow.md](sow.md), section 3). It
states what was delivered, the evidence for each criterion, and what was accepted as a known
limitation. A criterion is met by evidence someone can re-run, not by a document saying so.

## Deliverable

| | |
|---|---|
| Engagement | [name] |
| Deliverable | [report / specification set / implementation / hypercare] |
| Version or commit | [v or hash] |
| SOW reference | [section and line] |
| Delivered on | YYYY-MM-DD |
| Review rounds | [n, with links to the round records (`review.md`)] |

## Criteria and evidence

| # | Criterion (from the SOW) | Evidence | Where | Met |
|---|---|---|---|---|
| C1 | [report accepted after two review rounds] | [final round record] | [link] | yes / no / with limitation |
| C2 | [failure scenario detected within the target time] | [harness run id, query output, demo recording] | [link] | yes / no / with limitation |

Evidence kinds: a demonstration (recorded, with date), a query and its output, a harness run on
stage, an export, a signed document (only for decisions: an SLO target, a scope).

A criterion about a signal, an SLO or an alert says which it is: **spec validated** (the model
is agreed and lints clean) or **runtime validated** (it was seen working in the estate, or a
reproduced fault fired it and the notification was acknowledged). The first is never reported
as the second.

## Known limitations accepted

Each one is visible to the buyer and has an owner and a date; none hides an unmet criterion
that the buyer did not agree to.

| # | Limitation | Compensating measure | Owner | Date |
|---|---|---|---|---|
| L1 | [a coarser SLI from server spans until the back-end change lands] | [shadow alert on server errors] | [role] | YYYY-MM-DD |

## Decision

Pick the block for the deliverable.

**Assessment, Blueprint:** accepted · accepted with the limitations above · rejected (criteria
not met: [#]).

**Implementation — go / no-go:**

- **Go** — every criterion met.
- **Go with exceptions** — the limitations above, each with a compensating measure, an owner
  and a date.
- **No-go** — the key outcome cannot be determined reliably, or a critical signal does not
  reach the person on duty.

**Hypercare — closed separately from Implementation:**

| Exit criterion, over the last two weeks of production traffic | Measured | Met |
|---|---|---|
| Actionable P1 firings, share of all P1 firings | [n of m, %] — target at least 80 % | yes / no |
| Every P1 alert has a runbook used at least once in a drill or an incident | [list] | yes / no |
| The client's on-call owns the alerts in the rota | [rota link] | yes / no |

- **BAU readiness accepted** — all three met.
- **Period ended first** — residual risks written below; the client decides: extend by
  [weeks], or hand over with these risks.

| Residual risk | Effect | Owner | Date |
|---|---|---|---|
| [P1 actionable share 70 %, two noisy detectors] | [on-call fatigue] | [role] | YYYY-MM-DD |

## Signatures

| Role | Name | Decision | Signature | Date |
|---|---|---|---|---|
| Client sponsor | [name] | [accepted / go / …] | | |
| Client operations (hypercare only) | [name] | [BAU readiness] | | |
| Supplier lead | [name] | delivered as above | | |
