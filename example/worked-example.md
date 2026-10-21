# Worked example — Larkfield Grocer

**Fictional.** Larkfield Grocer, its systems, people and numbers are invented to show the method
end to end. Any resemblance to a real company is accidental. The example follows one journey
through every artefact: findings → error taxonomy → signals → SLO and alert → roadmap →
acceptance.

## The request

Larkfield sells groceries online with a delivery slot. The head of engineering asks for a
six-week assessment: "Our checkout dashboard is green, but every Monday the support queue fills
with customers whose order did not go through. Where are we blind, and what do we fix first?"

In scope: the checkout journey, three services (web front end, `checkout`, `payments`), one
monitoring tool, stage and production.

## Journey and functions

| # | Function | Route or call | What success means |
|---|---|---|---|
| C1 | Reserve delivery slot | `POST /api/slots/hold` | Slot held for 20 minutes |
| C2 | Authorise payment | `POST /api/payments/authorise` (to the payment provider) | Authorisation approved |
| C3 | Place order | `POST /api/orders` | Order created and confirmed to the customer |

A checkout **attempt** is C1 → C2 → C3 for one basket. A customer may retry C2 several times
within one attempt.

## Findings (week 2–4)

**F-03 · Payment declines and payment failures are counted together.**

| Status | Date | Source | Evidence level |
|---|---|---|---|
| confirmed | week 3 | `payments` error handler; query over 7 days of spans | tenant |

*What we see.* `payments` returns HTTP 200 with `{"status":"DECLINED"}` for a card decline and
HTTP 502 for a provider timeout. The dashboard's "payment errors" tile counts only 5xx, so
timeouts are visible; declines are not errors and that is right. But when the provider is slow,
`checkout` retries and the third timeout comes back as `DECLINED` with reason `PROVIDER_TIMEOUT`
— a failure reported as a decline. Over 7 days, 4 % of "declines" carry that reason.

*Why it matters.* On a slow-provider Monday, failed payments look like customers' cards being
declined. The dashboard stays green while orders are lost.

*What follows.* Split the code (taxonomy), emit the outcome per attempt (signals), alert on the
failure class only (SLO). Moves maturity dimension "error semantics" from 2 to 3.

**F-05 · An order can be paid and not placed.** If C3 fails after C2 approved, nothing records
the attempt as unknown; reconciliation is a weekly manual export. (confirmed, code path in
`checkout`, tenant query.)

**F-07 · The checkout dashboard counts page views of the confirmation page.** It measures
customers who reached the page, not orders placed; a cached page counts as success. (confirmed,
dashboard definition export.)

## Error taxonomy (extract)

| Function | Code or condition | HTTP | Class | Customer sees |
|---|---|---|---|---|
| C1 | `SLOT_TAKEN` | 409 | expected | "Choose another slot" |
| C1 | timeout from `slots` | 504 | failure | Spinner, then error |
| C2 | `DECLINED` reason `CARD` | 200 | expected | "Your card was declined" |
| C2 | `DECLINED` reason `PROVIDER_TIMEOUT` | 200 | **failure** (was counted as expected) | "Your card was declined" — wrongly |
| C2 | provider 5xx | 502 | failure | Error page |
| C3 | `BASKET_CHANGED` | 409 | expected | "Your basket changed" |
| C3 | duplicate submit with same attempt_id | 409 | caller_defect | Nothing (front-end double click) |
| C3 | any 5xx after C2 approved | 5xx | failure, attempt **unknown** until reconciled | Error page; money held |

## Signals (extract)

| Function | Event | Attributes | State after week 6 |
|---|---|---|---|
| C2 | `checkout.payment.result` | attempt_id, operation_id, outcome, error_class, reason | to build (M2) |
| C3 | `checkout.order.result` | attempt_id, outcome, error_class, order_id | to build (M2) |
| attempt | `checkout.attempt.result` | attempt_id, outcome (placed / refused / failed / unknown) | to build (M2) |

Two-level model: the attempt outcome is decided by C3 if it ran, otherwise by the last C2; an
attempt with C2 approved and no C3 result after 10 minutes is `unknown` and counts as bad.

## SLO and alert

| Function | SLI | Target | Owner |
|---|---|---|---|
| Checkout attempt | placed ÷ (placed + failed + unknown), 28 days; refusals excluded | 99.0 % | Head of e-commerce |

P1 alert "checkout failures": failed + unknown attempts > 3 % for 10 minutes with at least 50
attempts; grouped per function; runbook `runbooks/checkout.md`; starts in shadow.

## Roadmap (extract)

| Milestone | Done when (demonstrated) | Accountable |
|---|---|---|
| M2 — Business outcomes observable | `PROVIDER_TIMEOUT` returns `error_class=failure`; the three events emitted on stage | Checkout tech lead |
| M3 — Measurements validated | Harness replays slow provider, decline, basket change, double click; SLI counts equal the harness log | Observability engineer |
| M4 — Operational acceptance | Test P1 delivered, acknowledged, escalated; runbook exercised; go decision | Lead |

## Acceptance evidence

| Claim | Evidence |
|---|---|
| A slow provider shows as failure, not decline | Harness run on stage: 20 injected timeouts → 20 `failure` attempts in the SLI query |
| Paid-but-not-placed attempts are visible | 5 injected C3 failures after approval → 5 `unknown` attempts on the dashboard within 10 minutes |
| The alert reaches a person | Test P1 acknowledged by on-call in 4 minutes, escalated after timeout as configured |

## What the buyer read on page one

"Your checkout is not measured: the dashboard counts confirmation pages, and a slow payment
provider is reported as customers' cards being declined. Three changes in `checkout`, one
alert and one reconciliation report close this in five weeks. Decision needed: who owns the
checkout SLO target."
