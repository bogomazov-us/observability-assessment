# SLOs and alerts

*Spec-set skeleton for `slo-alerts.md`. What we promise and when we wake someone.*

## Rules

- SLI = good ÷ valid, rolling 28 days. **What counts as valid and as good is decided per SLI and
  written in the SLO table**, not assumed:
  - an expected refusal (wrong password, card declined) is either a *good* response of the
    service — it answered correctly — or *excluded* from the denominator when the SLI is about
    the customer's success. Choose one per SLI and say why;
  - `ambiguous` and `unknown` outcomes count as bad until reconciled or classified;
  - real-user SLIs exclude test traffic; synthetic results may feed their own availability SLO,
    kept separate from real-user SLIs.
- Every P1 alert has an owner, a runbook and a delivery test.
- New alerts start in shadow: they fire into a review channel, not to the pager.

## SLOs

| Function | SLI (good ÷ valid) | Expected refusals | Traffic | Target | Window | Owner (signs the target) |
|---|---|---|---|---|---|---|
| [J1.1] | [successful ÷ valid attempts] | [excluded / counted as good, and why] | [real users] | [99.5 %] | 28 days | [product owner] |
| [J1.1 synthetic] | [passed ÷ run checks] | not applicable | [synthetic] | [99.9 %] | 28 days | [operations] |

## P1 alerts

| Alert | Condition | Grouping | Notifies | Runbook | State |
|---|---|---|---|---|---|
| [J1.1 failure burst] | [failure + ambiguous ratio above 5 % for 10 min, at least 30 attempts] | [per function] | [on-call rota] | `runbooks/<function>.md` | shadow / paging |

## Suppression

[Maintenance windows, dependency-down suppression, how a suppressed alert is still recorded.]

## Synthetic alerts

[Which synthetics page, and after how many consecutive failures.]

## Hypercare

[Period, rota, exit criteria: share of actionable firings, runbooks exercised, on-call owns the alerts.]

## Firing review

[Weekly: every firing marked actionable / noise / duplicate; noise has an owner and a fix date.]

## Error-budget policy

[What happens when the budget is spent: who decides, what is paused.]
