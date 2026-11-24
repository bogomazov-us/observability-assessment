# Evidence catalog (fictional)

| Id | Check | Window | Result | Limits |
|---|---|---|---|---|
| E-302 | Spans of `checkout.payment.result` in the trace view | 2027-04-19 | Outcome and reason present; no `attempt_id` | Sampled traces only |
| E-303 | Checkout success tile query | 2027-04-19 | Counts confirmation page views | Dashboard as of that day |

### E-301 — declines by reason, payment service

Checked at: 2027-04-19, window 2027-04-05 to 2027-04-18.
Result: 4 % of declines carry a provider timeout as their reason; 9 % on Monday 04-12.
Limits: one payment provider; declines before 2027-04-05 not read.
