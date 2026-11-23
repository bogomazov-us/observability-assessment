# Observability example: stage 3 report — gap

Project: Larkfield Grocer, checkout (fictional) · Version: `5e8a2d7` · Date: 2027-04-22 (CEST)
Document status: accepted · Baseline: stage 1 accepted at `b04f6c3`, stage 2 at `a3c90e1`

Skeleton: [stage-report.md](../../templates/stage-report.md). Travel with it at `5e8a2d7`: the
spec ([worked-example.spec.yml](../worked-example.spec.yml), the engagement's
`spec/observability-spec.yml`), the [progress log](progress/stage-3.md) and the
[decision register](../worked-example.md#decision-register-extract).

## 1. Result

No checkout outcome can be measured or alerted on today. A slow payment provider is reported
as a card decline, which hides it from every alert that reads errors; the dashboard counts
confirmation pages; an order paid for and not placed leaves no record.

| | |
|---|---|
| Checked | 4 signal rows, 1 SLO, 1 proposed P1 alert and 6 live alert rules; production, 2027-04-12 → 04-18 |
| Main limits | The provider's side was not read; the status call is answered in production by the owner (D-07), not shown |
| Next step | Stage 4, findings from G-01 to G-04 |

## 2. Scope and method

- In scope: journey J1, functions C1–C3, attempt A1 (spec at `a3c90e1`); production.
- Observation window: 2027-04-12 00:00 → 04-19 00:00 CEST.
- Sources: trace store and alert rules of the monitoring tool, read-only; `checkout` at
  `9f21c0a`; the dashboard definition export of 2027-04-08.
- Limits of the check: no traffic was sent and no fault injected; the provider was not read.

## 3. Main results

Signals, counted as signal rows bound to a function or attempt: 0 live, 1 differs, 3 to build,
0 not verifiable (4).

| ID | Object or function | Result | Evidence |
|---|---|---|---|
| G-01 | C2 authorise payment | A provider timeout is returned as `DECLINED`: 4 % of declines in the window, 9 % on Monday 04-12 | E-301 |
| G-02 | `checkout.payment.result` | Differs: the spans carry outcome and reason, not `attempt_id` or `error_class` | E-302, E-306 |
| G-03 | Checkout success tile | Counts confirmation page views, not orders | E-303 |
| G-04 | C3 after C2 approved | No record when C3 does not answer; residual risk R-02 | E-304 |
| G-05 | Live alerts | 6 rules on 5xx per service; none reads C2, which answers 200 | E-305 |

SLO-checkout: not computable from live signals, and continuous computation is not implemented;
without `attempt_id` (G-02) attempts cannot be told apart, so no reading was taken.

Detection matrix, P1-checkout-failures: **residual risk** until its signals are built
(R-01, owner proposed); **scenario written**, S1: 20 provider timeouts in the provider's
sandbox, the alert in shadow fires within 10 minutes; run by the checkout developer in M-3.
Paging readiness: owner, runbook and delivery test **not shown**.

## 4. Records

### G-02 — The payment signal exists but cannot be tied to an attempt

- **Observed:** `payments.authorise` spans carry `outcome` and `reason`; none of 5 sampled
  spans of Monday 04-12 carries `attempt_id`, and the retries of one payment are separate
  traces (E-302, E-306).
- **Expected:** `checkout.payment.result` with `attempt_id`, `operation_id`, `outcome`,
  `error_class`, `reason` (spec, signals; D-05).
- **Difference:** two attributes missing; retries cannot be counted per attempt.
- **Consequence:** the attempt outcome, and so the SLO, cannot be built from it as it is.
- **Evidence:** E-302, E-306
- **Confidence:** high
- **Limits:** a sample of 5 spans of one day; other days not read by the lead.
- **Next action:** add the attributes in `checkout` (M-2).
- **Done when:** a harness run on stage shows each C2 retry under one `attempt_id`.

G-01, G-03, G-04 and G-05 have records of the same form; this extract shows one.

## 5. Decisions and open questions

| ID | Question or decision | Owner | Status |
|---|---|---|---|
| Q-03 | Does the provider answer a status call in production? | Payments technical owner | D-07 |
| Q-04 | Who owns R-02 until the reconciliation job runs? | Sponsor | D-08 |
| D-06 | Stage 3 confirmed as the input to stage 4 | Lead | accepted |

## 6. Conditions to complete the stage

- A sample of signals checked by the lead through another path than the agent's query (E-306).
- R-01 and R-02 in the risk register with proposed owners.

## Appendix A. Evidence catalog (extract)

### E-302 — Attributes on the payment spans

- Source: trace store, production · Checked at: 2027-04-19 09:40 CEST
- Data window: 2027-04-12 → 04-18 · Code version: `checkout` at `9f21c0a`
- Method: count of `payments.authorise` spans by attribute present (agent's query)
- Result: `outcome` and `reason` on all; `attempt_id` and `error_class` on none
- Limits: presence counted, not values

### E-306 — Payment spans read in the tool's trace view

- Source: the monitoring tool's trace view, by the lead · Checked at: 2027-04-21 16:05 CEST
- Data window: Monday 2027-04-12 · Method: 5 spans chosen by the lead, 3 with reason
  `PROVIDER_TIMEOUT`, read with their parent traces
- Result: no `attempt_id`; each retry a trace of its own
- Limits: 5 spans

E-301, E-303, E-304 and E-305 are recorded in the same form.

## Appendix B. Changes in this version

| Version | What changed |
|---|---|
| `1d9b0f4` | Draft handed over by the agent |
| `5e8a2d7` | G-02: `live` → `differs` after E-306, by the lead before confirming ([review](reviews/stage-3-round-1.md), R1) |
