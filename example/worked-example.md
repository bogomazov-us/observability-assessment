# Worked example — Larkfield Grocer

**Fictional.** Larkfield Grocer, its systems, people and numbers are invented to show the method
end to end. Any resemblance to a real company is accidental. The example follows one journey
through every artefact: request → facts → findings → maturity → error taxonomy → signals →
SLO and alert → roadmap with effort → acceptance.

## The request

Larkfield sells groceries online with a delivery slot: about 6,000 checkout attempts a day,
twice that on Mondays. The head of engineering asks for a six-week assessment: "Our checkout
dashboard shows 99.6 % success, but every Monday support gets 30–50 tickets from customers
whose order did not go through. Where are we blind, and what do we fix first?"

In scope: the checkout journey; three services (web front end, `checkout`, `payments`); one
monitoring tool; stage and production; two review rounds.

## Journey and functions

| # | Function | Route or call | What success means |
|---|---|---|---|
| C1 | Reserve delivery slot | `POST /api/slots/hold` | Slot held for 20 minutes |
| C2 | Authorise payment | `POST /api/payments/authorise` (to the payment provider) | Authorisation approved |
| C3 | Place order | `POST /api/orders` | Order created and confirmed to the customer |

A checkout **attempt** is C1 → C2 → C3 for one basket. A customer may retry C2 several times
within one attempt.

## Facts ledger (extract)

| # | Fact | Status | Source | Date |
|---|---|---|---|---|
| O-04 | The checkout success tile counts views of the confirmation page | confirmed | dashboard definition export | week 2 |
| O-07 | "Every timeout is retried three times" | refuted by O-09 | interview, platform lead | week 1 |
| O-09 | `checkout` retries a provider timeout twice, then returns `DECLINED` with reason `PROVIDER_TIMEOUT` | confirmed | `checkout` payment client, code path; span query | week 3 |
| O-11 | Reconciliation of paid-but-not-placed orders is a weekly manual export | assumption | interview, finance | week 3 |

## Findings (weeks 2–4)

**F-03 · Payment timeouts are reported to the customer and to monitoring as card declines.**

| Status | Date | Source | Evidence level |
|---|---|---|---|
| confirmed | week 3 | O-09; query over 7 days of spans | tenant |

*What we see.* `payments` returns HTTP 200 with `{"status":"DECLINED"}` for a card decline. When
the provider is slow, `checkout` retries twice and then also returns `DECLINED`, with reason
`PROVIDER_TIMEOUT`. Over 7 days, 4 % of "declines" carry that reason, 9 % on the Monday. Whether
the provider authorised the payment is not checked.

*Why it matters.* On a slow-provider Monday, failed — or possibly taken — payments look like
customers' cards being declined. The dashboard stays green.

*What follows.* Ask the provider for the status after a timeout and classify by the answer
(taxonomy); emit the outcome per attempt (signals); alert on failed and ambiguous attempts
(SLO). Moves dimension 3 from 2 to 3.

**F-05 · An order can be paid and not placed.** If C3 does not answer after C2 approved, nothing
records the attempt; reconciliation is by hand once a week (O-11). (confirmed, code path in
`checkout`.)

**F-07 · The checkout dashboard measures page views, not orders** (O-04). A cached confirmation
page counts as a success.

## Maturity profile (extract)

| Dimension | Level | Coverage | Evidence | Confidence |
|---|---|---|---|---|
| 1 Business-function model | 2 | journeys listed, no functions | product wiki; interviews | medium |
| 3 Error semantics | 2 (partial 3) | classified on C1 only | `slots` and `payments` error handlers | high |
| 5 Business outcome data | 2 | outcomes reconstructable from the orders database by hand | ad-hoc query | high |
| 6 SLOs | 1 | none | — | high |
| 7 Alert quality | 2 | per-service 5xx alerts, no owners | alert export | high |
| 12 Operational analytics | N/A | client does not intend to use it this year | sponsor, kick-off | — |

## Error taxonomy (extract)

| Function | Code or condition | HTTP | Class | Customer sees |
|---|---|---|---|---|
| C1 | `SLOT_TAKEN` | 409 | expected | "Choose another slot" |
| C1 | timeout from `slots` (read-only hold, safe to retry) | 504 | failure | Error, retry offered |
| C2 | `DECLINED`, reason `CARD` | 200 | expected | "Your card was declined" |
| C2 | timeout; provider status says *not authorised* | 200 today (`PROVIDER_TIMEOUT`) | failure | today: "card declined" — wrongly |
| C2 | timeout; provider status not available | 200 today (`PROVIDER_TIMEOUT`) | ambiguous | today: "card declined" — wrongly |
| C3 | `BASKET_CHANGED` (authorisation voided) | 409 | expected | "Your basket changed" |
| C3 | rejected with a definite error, authorisation voided | 4xx / 5xx with `order_created=false` | failure | Error; no money held |
| C3 | timeout or no answer after C2 approved | 5xx / none | ambiguous | Error; money may be held |
| C3 | duplicate submit with the same attempt_id | 409 | caller_defect | Nothing (double click) |

`PROVIDER_TIMEOUT` was an overloaded code: one code for two different outcomes. It is split by
the provider's status answer.

## Signals (extract)

| Function | Event | Attributes | State after week 6 |
|---|---|---|---|
| C2 | `checkout.payment.result` | attempt_id, operation_id, outcome, error_class, reason | to build (M2) |
| C3 | `checkout.order.result` | attempt_id, outcome, error_class, order_id | to build (M2) |
| attempt | `checkout.attempt.result` | attempt_id, outcome (placed / refused / failed / ambiguous) | to build (M2) |

**Attempt outcome** — the two-level model, decided by the last operation that ran:

| Last operation and its result | Attempt outcome |
|---|---|
| C3 created the order | placed |
| C1, C2 or C3 ended in an `expected` refusal and the customer left | refused |
| C2 or C3 ended in a `failure` (no money taken, or authorisation voided) | failed |
| C2 or C3 ended `ambiguous`, or C2 approved and no C3 result within 10 minutes | ambiguous |
| `caller_defect` on a duplicate submit | ignored; the original submit decides |

An ambiguous attempt is reconciled by a job every 10 minutes: provider status and orders
database → placed or failed (and the authorisation voided). Until then it counts as bad.

## SLO and alert

| Function | SLI (good ÷ valid) | Expected refusals | Target | Owner |
|---|---|---|---|---|
| Checkout attempt | placed ÷ (placed + failed + ambiguous), real users, 28 days | excluded: the customer's card or basket, not our service | 99.0 % | Head of e-commerce |

P1 alert "checkout failures": failed + ambiguous above 3 % of attempts for 10 minutes, with at
least 50 attempts; grouped per function; runbook `runbooks/checkout.md`; starts in shadow.

## Roadmap with effort

| Milestone | Done when (demonstrated) | Accountable | Weeks |
|---|---|---|---|
| M0 — Decisions | SLO target signed; provider status call confirmed available in sandbox | Lead | 1 |
| M2 — Business outcomes observable | `PROVIDER_TIMEOUT` split by status; three events emitted on stage; reconciliation job on stage | Checkout tech lead | 2 |
| M3 — Measurements validated | Harness cases below reproduce exactly in the SLI query | Observability engineer | 1 |
| M4 — Operational acceptance | Test P1 delivered, acknowledged, escalated; runbook exercised; go decision | Lead | 1 |

**Five weeks, on these assumptions** (each one goes into the facts ledger as an assumption and
into the decision request):

- two checkout developers at half time for M2 (about 10 developer-days: status call and split
  1–2, three events 3, reconciliation job 4, tests 2);
- the provider's sandbox can inject timeouts and answer status calls;
- the product owner signs the target in week 1;
- one observability engineer full time from M2 to M4, the lead half time.

If the sandbox cannot inject timeouts, M3 needs a stub of the provider: plus one week.

## Acceptance evidence

| Claim | Harness on stage | Expected in the SLI query |
|---|---|---|
| A slow provider is not a decline | 20 timeouts, provider status *not authorised* | 20 failed attempts, 0 refused |
| An unanswered payment is visible | 10 timeouts, provider status unavailable | 10 ambiguous attempts within 10 min, then reconciled to failed |
| Paid-but-not-placed is visible | 5 approved C2, C3 does not answer | 5 ambiguous within 10 min; reconciled to placed or failed per the orders database |
| A definite order rejection is a failure | 5 approved C2, C3 rejects, authorisation voided | 5 failed attempts |
| Refusals stay out of the SLI | 30 card declines, 10 basket changes | 40 refused, not in the denominator |
| The alert reaches a person | test P1 | acknowledged by on-call, escalated after the configured timeout |

## What the buyer read on page one

"Your checkout is not measured: the dashboard counts confirmation pages, and a slow payment
provider is reported to customers as their card being declined — some of those payments may
have been taken. Three changes in `checkout`, a reconciliation job and one alert close this in
about five weeks, on the assumptions listed. Decision needed: who owns the checkout SLO target,
and two checkout developers at half time for two weeks."
