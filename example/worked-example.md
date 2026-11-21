# Worked example — Larkfield Grocer

**Fictional.** Larkfield Grocer, its systems, people and numbers are invented to show the method
end to end. Any resemblance to a real company is accidental. The example follows one journey
through every artefact: request → registers → findings → maturity → error taxonomy → signals →
SLO and alert → roadmap with effort → acceptance → report. It shows the state after the
read-out; [the agent thread](#the-agent-thread-at-stage-3) shows one stage's records as they
were handed over and confirmed. Weeks: the [calendar](../method/getting-started.md#3-calendar).
Ids, roles and statuses: [records.md](../method/records.md).

## The request

Larkfield sells groceries online with a delivery slot: about 6,000 checkout attempts a day,
twice that on Mondays. The head of engineering asks for a six-week assessment: "Our checkout
dashboard shows 99.6 % success, but every Monday support gets 30–50 tickets from customers
whose order did not go through. Where are we blind, and what do we fix first?"

In scope (D-01): the checkout journey; three services (web front end, `checkout`, `payments`);
one monitoring tool; stage and production; two review rounds.

## Journey and functions

| # | Function | Route or call | What success means |
|---|---|---|---|
| C1 | Reserve delivery slot | `POST /api/slots/hold` | Slot held for 20 minutes |
| C2 | Authorise payment | `POST /api/payments/authorise` (to the payment provider) | Authorisation approved |
| C3 | Place order | `POST /api/orders` | Order created and confirmed to the customer |

A checkout **attempt** (A1) is C1 → C2 → C3 for one basket. A customer may retry C2 several
times within one attempt. The names are the spec's glossary (D-03).

## Decision register (extract)

Every decision is a row here before a document cites it. None of these needed an ADR file.

| ID | Decision | Decided by | Date | Evidence | Status |
|---|---|---|---|---|---|
| D-01 | Scope as above | Sponsor (head of engineering) | 2027-04-05 | Kick-off note | accepted |
| D-02 | Stage 1 confirmed | Lead | 2027-04-13 | `inventory.md` at `b04f6c3` | accepted |
| D-03 | Names of J1, C1–C3, A1 as in the glossary (Q-01) | Product owner | 2027-04-14 | Written answer | accepted |
| D-04 | Card declines and basket changes excluded from the checkout SLI (Q-02) | Head of e-commerce | 2027-04-15 | Written answer | accepted |
| D-05 | Stage 2 confirmed | Lead | 2027-04-16 | Spec at `a3c90e1` | accepted |
| D-06 | Stage 3 confirmed, G-02 changed before | Lead | 2027-04-22 | `stage-3-gap.md` at `5e8a2d7` | accepted |
| D-07 | The provider's status call answers in production, 10 a second (Q-03) | Payments technical owner | 2027-04-22 | Written answer | accepted |
| D-08 | R-02 owned and accepted until the reconciliation job runs (Q-04) | Sponsor | 2027-04-22 | Written answer | accepted |
| D-09 | Verdicts: F-003, F-005, F-007 confirmed | Checkout technical owner | 2027-05-04 | Verdict batch; re-checks E-401 to E-403 | accepted |

## Facts ledger (extract)

| # | Fact | Status | Source | Date |
|---|---|---|---|---|
| O-04 | The checkout success tile counts views of the confirmation page | confirmed | Dashboard definition export, E-303 | 2027-04-08 |
| O-07 | "Every timeout is retried three times" | refuted by O-09 | Interview, platform lead | 2027-04-06 |
| O-09 | `checkout` retries a provider timeout twice, then returns `DECLINED` with reason `PROVIDER_TIMEOUT` | confirmed | `checkout` payment client, code path; E-301 | 2027-04-19 |
| O-11 | Reconciliation of paid-but-not-placed orders is a weekly manual export | assumption | Interview, finance | 2027-04-13 |

## Risk register (extract)

| ID | Risk | Source | Owner | Status | Date | Decision |
|---|---|---|---|---|---|---|
| R-01 | A slow provider is shown to customers as a decline while money may be held, and no alert reaches anyone | Residual risk, stage 3, G-01 | Head of e-commerce, *proposed* | open | 2027-04-22 | |
| R-02 | An order paid for and not placed is seen only at the weekly export | Residual risk, stage 3, G-04 | Head of e-commerce | accepted | 2027-04-22 | D-08 |

## Findings

People wrote the findings as they appeared ([agent-harness.md](../method/agent-harness.md#measuring-the-harness));
each is a file `findings/F-NNN.md` in [finding.md](../templates/finding.md)'s format. Verdicts
came from the batch sent at the findings preview (D-09).

**F-003 · Payment timeouts are reported to the customer and to monitoring as card declines.**

| Status | Date | Source | Evidence level |
|---|---|---|---|
| confirmed | 2027-05-04 | Code path; span query E-301, re-run E-401 | tenant |

**Severity:** P1: a failure of C2 is reported wrongly to the customer and reaches no alert. ·
**Decision:** proposed · **Implementation:** absent · **Verification:** untested.

**What we see.** `payments` returns HTTP 200 with `{"status":"DECLINED"}` for a card decline.
When the provider is slow, `checkout` retries twice and then also returns `DECLINED`, with
reason `PROVIDER_TIMEOUT` (O-09). In 2027-04-12 → 04-18, 4 % of declines carry that reason,
9 % on the Monday (E-301); the re-run over the next week gave 5 % and 8 % (E-401).

**Confidence and limits.** High for the windows read. Whether the provider authorised any of
these payments is not shown: its side was not read.

**Why it matters.** On a slow-provider Monday, failed — or possibly taken — payments look like
customers' cards being declined. The dashboard stays green.

**What follows.** Ask the provider for the status after a timeout (D-07) and classify by the
answer; emit the outcome per attempt; alert on failed and ambiguous attempts. Checkout tech
lead, M-2. Moves dimension 3 from 2 to 3.

**Closing criterion.** The first two rows of the acceptance evidence pass on stage.

**Links.** G-01, G-02; R-01; F-005.

**F-005 · An order can be paid for and not placed.** confirmed, 2027-05-04, tenant · P1: a
write can be reported wrongly · proposed, absent, untested. *What we see:* if C3 does not
answer after C2 approved, nothing records the attempt (code path, E-304, re-checked E-402).
Reconciliation is said to be a weekly manual export (O-11, an assumption). *Limits:* how often
it happens is not shown: nothing records it. *Why it matters:* money held without an order.
*What follows:* the reconciliation job (checkout tech lead, M-2); dimension 5. *Closing
criterion:* the acceptance row "Paid-but-not-placed is visible" passes. *Links:* G-04, R-02.

**F-007 · The checkout dashboard measures page views, not orders.** confirmed, 2027-05-04,
tenant · P2: measurement is wrong for a function in scope · proposed, absent, untested. *What
we see:* the success tile counts views of the confirmation page, so a cached page counts as a
success (O-04, E-303, re-checked E-403). *Limits:* other dashboards not read. *Why it
matters:* the 99.6 % is not a checkout success rate. *What follows:* the tile reads the SLI
(observability engineer, M-3); dimension 6. *Closing criterion:* the tile matches the SLI query
on the harness run. *Links:* G-03.

## Maturity profile (extract)

Final at stage 5; the baseline set in phase 1 was provisional. As a file:
[maturity.yml](maturity.yml), checked by `tools/maturity.py`.

| Dimension | Level | Coverage | Evidence | Confidence |
|---|---|---|---|---|
| 1 Business-function model | 2 | journeys listed, no functions | product wiki; interviews | medium |
| 3 Error semantics | 2 (partial 3) | classified on C1 only | `slots` and `payments` error handlers | high |
| 5 Business outcome data | 2 | outcomes reconstructable from the orders database by hand | ad-hoc query | high |
| 6 SLOs | 1 | none | SLO export from the tool: empty; contracts and wiki: none | high |
| 7 Alert quality | 2 | per-service 5xx alerts, no owners | alert export | high |
| 12 Operational analytics | N/A | client does not intend to use it this year | sponsor, kick-off | — |

Block the next step: 3, 5 and 6.

## Error taxonomy (extract)

As a file, with user impact per row: [worked-example.spec.yml](worked-example.spec.yml).

| Function | Code or condition | HTTP | Class | Customer sees |
|---|---|---|---|---|
| C1 | `SLOT_TAKEN` | 409 | expected | "Choose another slot" |
| C1 | `slots` rejects with a definite error, no hold created | 5xx with `hold_created=false` | failure | Error, retry offered |
| C1 | timeout from `slots`; read-back by attempt_id finds no hold | 504 | failure | Error, retry offered |
| C1 | timeout from `slots`; read-back finds the hold | 504 | none: the hold exists, checkout continues | Nothing |
| C1 | timeout from `slots`; read-back not possible | 504 | ambiguous | Error; slot may be held for 20 minutes |
| C2 | `DECLINED`, reason `CARD` | 200 | expected | "Your card was declined" |
| C2 | timeout; provider status says *not authorised* | 200 today (`PROVIDER_TIMEOUT`) | failure | today: "card declined" — wrongly |
| C2 | timeout; provider status not available | 200 today (`PROVIDER_TIMEOUT`) | ambiguous | today: "card declined" — wrongly |
| C3 | `BASKET_CHANGED` (authorisation voided) | 409 | expected | "Your basket changed" |
| C3 | rejected with a definite error, authorisation voided | 4xx / 5xx with `order_created=false` | failure | Error; no money held |
| C3 | timeout or no answer after C2 approved | 5xx / none | ambiguous | Error; money may be held |
| C3 | duplicate submit with the same attempt_id | 409 | caller_defect | Nothing (double click) |

The hold call is not proven idempotent, so a C1 timeout is read back before any retry.
`PROVIDER_TIMEOUT` was an overloaded code, split by the provider's status answer.

## Signals (extract)

| Function | Event | Attributes | State at stage 3 (D-06) |
|---|---|---|---|
| C1 | `checkout.slot.result` | attempt_id, operation_id, outcome, error_class, reason | to build (M-2) |
| C2 | `checkout.payment.result` | attempt_id, operation_id, outcome, error_class, reason | differs: no attempt_id, error_class (G-02); M-2 |
| C3 | `checkout.order.result` | attempt_id, outcome, error_class, order_id | to build (M-2) |
| attempt | `checkout.attempt.result` | attempt_id, outcome (placed / refused / failed / ambiguous / unclassified) | to build (M-2) |

**Attempt outcome** — the two-level model, decided by the last operation that ran:

| Last operation and its result | Attempt outcome |
|---|---|
| C3 created the order | placed |
| C1, C2 or C3 ended in an `expected` refusal and the customer left | refused |
| C1, C2 or C3 ended in a `failure` (no hold, no money taken, or authorisation voided) | failed |
| C1, C2 or C3 ended `ambiguous`, or C2 approved and no C3 result within 10 minutes | ambiguous |
| C1, C2 or C3 ended in an `unknown` (not yet classified) code | unclassified: kept apart for diagnosis |
| `caller_defect` on a duplicate submit | ignored; the original submit decides |

A job every 10 minutes reconciles an ambiguous attempt from the hold, the provider's payment
status and the orders database, sets placed or failed, and releases a hold or voids an
authorisation the attempt left behind; until then it counts as bad. An unclassified attempt is
recounted once its code is classified. The full rules: the spec's `attempts`.

## SLO and alert

| Function | SLI (good ÷ valid) | Expected refusals | Target | Owner |
|---|---|---|---|---|
| Checkout attempt | placed ÷ (placed + failed + ambiguous + unclassified), real users, 28 days | excluded (D-04) | 99.0 %, *proposed* | Head of e-commerce |

Bad attempts are failed + ambiguous + unclassified, each reported separately on the dashboard.
P1 alert "checkout failures": bad attempts above 3 % of attempts for 10 minutes, with at least
50 attempts; grouped per function; runbook `runbooks/checkout.md`. It starts in shadow and
stays there until its owner is decided with Larkfield and its
[paging gate](../templates/spec-set/slo-alerts.md) is shown.

## Roadmap with effort

| Milestone | Done when (demonstrated) | Accountable | Weeks |
|---|---|---|---|
| M-1 — Decisions | SLO target signed; alert owner set | Lead | 1 |
| M-2 — Business outcomes observable | `PROVIDER_TIMEOUT` split by status; four events emitted on stage; reconciliation job on stage | Checkout tech lead | 2 |
| M-3 — Measurements validated | Harness cases below reproduce exactly in the SLI query; the tile reads the SLI | Observability engineer | 1 |
| M-4 — Operational acceptance | Test P1 delivered, acknowledged, escalated; runbook exercised; go decision | Lead | 1 |

**Five weeks, on these assumptions** (each one goes into the facts ledger as an assumption and
into the decision request):

- two checkout developers at half time for M-2 (about 10 developer-days: status call and split
  1–2, four events 3, reconciliation job 4, tests 2);
- the provider's sandbox can inject timeouts and answer status calls;
- the head of e-commerce signs the target during M-1;
- one observability engineer full time from M-2 to M-4, the lead half time.

If the sandbox cannot inject timeouts, M-3 needs a stub of the provider: plus one week.

## Acceptance evidence

| Claim | Harness on stage | Expected in the SLI query |
|---|---|---|
| A slow provider is not a decline | 20 timeouts, provider status *not authorised* | 20 failed attempts, 0 refused |
| An unanswered payment is visible | 10 timeouts, provider status unavailable | 10 ambiguous attempts within 10 min, then reconciled to failed |
| Paid-but-not-placed is visible | 5 approved C2, C3 does not answer | 5 ambiguous within 10 min; reconciled to placed or failed per the orders database |
| A lost hold answer is not retried blindly | 10 `slots` timeouts after the hold was written | 10 holds found by read-back, checkout continues, 0 duplicate holds |
| A definite order rejection is a failure | 5 approved C2, C3 rejects, authorisation voided | 5 failed attempts |
| Refusals stay out of the SLI | 30 card declines, 10 basket changes | 40 refused, not in the denominator |
| The alert reaches a person | test P1 | acknowledged by on-call, escalated after the configured timeout |

## The report

One report ([stage-report.md](../templates/stage-report.md#one-report-for-the-whole-assessment)):
the summary chapter, rewritten at each accepted stage, then a chapter per stage —
`inventory.md`, `stage-2-notes.md`, [`stage-3-gap.md`](agent/stage-3-gap.md),
`stage-4-notes.md`, `stage-5-notes.md`, `recommendations.md`. Page one of the summary:

"Your checkout is not measured: the dashboard counts confirmation pages, and a slow payment
provider is reported to customers as their card being declined — some of those payments may
have been taken (F-003, F-005, F-007). Three changes in `checkout`, a reconciliation job and
one alert close this in about five weeks, on the assumptions listed. Decision needed: the
checkout SLO target, signed by the head of e-commerce, and two checkout developers at half
time for two weeks."

## The agent thread at stage 3

What the lead held on 2027-04-22, when stage 3 was confirmed, at the
[artifact paths](../tools/agent/README.md#artifact-paths) of the working folder:

| Path | Record |
|---|---|
| [`engagement-state.yml`](agent/engagement-state.yml) | Stages 1–3 confirmed with their decision ids; questions answered; `stagegate.py check … 4` opens |
| [`progress/stage-3.md`](agent/progress/stage-3.md) | The agent's log, clock-read times, plan, commits, the step blocked on Q-03 |
| [`owner-questions.md`](agent/owner-questions.md) | The stage-3 batch, answers recorded as D-07 and D-08 |
| `spec/observability-spec.yml` | [worked-example.spec.yml](worked-example.spec.yml): the glossary, signal states set by stage 3 |
| [`stage-3-gap.md`](agent/stage-3-gap.md) | The stage report chapter |
| [`reviews/stage-3-round-1.md`](agent/reviews/stage-3-round-1.md) | The draft the lead changed before confirming: G-02 drafted `live`, read through the trace view, changed to `differs`; counted for the harness measures |

`tools/tests/test_example.sh` runs speclint, maturity and stagegate on these files in CI.
