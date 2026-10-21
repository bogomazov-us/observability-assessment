# SLOs and alerts

*Spec-set skeleton for `slo-alerts.md`. What we promise and when we wake someone.*

## Rules

- SLI = good ÷ valid, rolling 28 days. **What counts as valid and as good is decided per SLI and
  written in the SLO table**, not assumed:
  - an expected refusal (wrong password, card declined) is either a *good* response of the
    service — it answered correctly — or *excluded* from the denominator when the SLI is about
    the customer's success. Choose one per SLI and say why;
  - **one bad predicate per SLI**, written in the table: by default bad = failure +
    caller_defect + ambiguous + unknown; ambiguous and unknown stay bad until reconciled or
    classified;
  - real-user SLIs exclude test traffic; synthetic results may feed their own availability SLO,
    kept separate from real-user SLIs.
- Every P1 alert has an owner, a runbook and a delivery test. A P1 pages on the bad predicate
  minus the classes routed elsewhere, and the table says which: caller_defect usually goes to
  the owning team as a ticket, not to the pager.
- New alerts start in shadow: they fire into a review channel, not to the pager.

## SLOs

| Function | SLI (good ÷ valid) | Bad | Expected refusals | Traffic | Target | Window | Owner (signs the target) |
|---|---|---|---|---|---|---|---|
| [J1.1] | [successful ÷ valid attempts] | [failure + caller_defect + ambiguous + unknown] | [excluded / counted as good, and why] | [real users] | [99.5 %] | 28 days | [product owner] |
| [J1.1 synthetic] | [passed ÷ run checks] | [failed checks] | not applicable | [synthetic] | [99.9 %] | 28 days | [operations] |

## P1 alerts

| Alert | Condition | Grouping | Notifies | Runbook | State |
|---|---|---|---|---|---|
| [J1.1 failure burst] | [(failure + ambiguous + unknown) ÷ valid above 5 % for 10 min, at least 30 attempts; caller_defect routed to the owning team] | [per function] | [on-call rota] | `runbooks/<function>.md` | shadow / paging |

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
