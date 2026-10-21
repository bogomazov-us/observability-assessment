# Skeleton — `slo-alerts.md`

What we promise and when we wake someone.

---

# SLOs and alerts

## Rules

- SLI = good ÷ valid, rolling 28 days. Test traffic and expected refusals are not valid events.
- Every P1 alert has an owner, a runbook and a delivery test.
- New alerts start in shadow: they fire into a review channel, not to the pager.

## SLOs

| Function | SLI | Target | Window | Owner (signs the target) |
|---|---|---|---|---|
| <J1.1> | <successful ÷ valid attempts> | <99.5 %> | 28 days | <product owner> |

## P1 alerts

| Alert | Condition | Grouping | Notifies | Runbook | State |
|---|---|---|---|---|---|
| <J1.1 failure burst> | <failure ratio > 5 % for 10 min, ≥ 30 attempts> | <per function> | <on-call rota> | `runbooks/<function>.md` | shadow / paging |

## Suppression

<Maintenance windows, dependency-down suppression, how a suppressed alert is still recorded.>

## Synthetic alerts

<Which synthetics page, and after how many consecutive failures.>

## Hypercare

<Period, rota, exit criteria: share of actionable firings, runbooks exercised, on-call owns the
alerts.>

## Firing review

<Weekly: every firing marked actionable / noise / duplicate; noise has an owner and a fix date.>

## Error-budget policy

<What happens when the budget is spent: who decides, what is paused.>
