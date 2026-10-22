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
- Every P1 alert has an owner, a runbook and a delivery test. A P1 pages on the bad predicate;
  routing follows **impact, not class**. caller_defect goes to the owning team as a ticket while
  it is below the P1 threshold, and pages like any failure when it blocks customers at P1
  scale (a front-end bug that stops checkout is a P1, whoever fixes it). Ambiguous, unknown
  and unclassified are kept as separate series, so the cause stays visible.
- **The budget is counted in what the SLI counts.** A request SLI's budget is bad requests; a
  window-share SLI's budget is bad windows, which is neither minutes of downtime nor a share
  of failed requests. Alerts on the budget are burn-rate pairs: a fast burn (short and long
  window, pages) and a slow burn (ticket).
- **Volume decides the window.** Each SLI states the events expected per evaluation window; a
  percentile over a handful of events, or a synthetic that runs less often than the window,
  is not evidence for that window.
- **Telemetry health is its own signal.** Missing telemetry must not read as no traffic or as
  healthy: an export heartbeat, ingestion and recording-rule health, and a delivery test of
  the notification path are monitored apart from the service.
- **Missing data is set per input**, not once per alert. Missing expected evaluations (a
  synthetic that did not run, a heartbeat that stopped) are a fault; a missing sparse failure
  counter may just mean no errors.
- New alerts start in shadow: they fire into a review channel, not to the pager.
- **Who owns an alert is decided with the client**, by their maturity and organisation: the team
  that owns the service, a platform SRE team, or an operations centre that escalates. Until it
  is decided, the alert stays in shadow and the owner is an open question with a date.

## SLOs

| Function | SLI (good ÷ valid) | Bad | Expected refusals | Traffic | Volume per window | Target | Budget (in SLI units) | Window | Owner (signs the target) |
|---|---|---|---|---|---|---|---|---|---|
| [J1.1] | [successful ÷ valid attempts] | [failure + caller_defect + ambiguous + unknown] | [excluded / counted as good, and why] | [real users] | [~400 attempts per 5 min] | [99.5 %] | [0.5 % of valid attempts] | 28 days | [product owner] |
| [J1.1 synthetic] | [passed ÷ run checks] | [failed checks] | not applicable | [synthetic] | [1 check per 5 min] | [99.9 %] | [8 failed checks] | 28 days | [operations] |

## P1 alerts

| Alert | Condition | Grouping | Notifies | Runbook | State |
|---|---|---|---|---|---|
| [J1.1 failure burst] | [bad ÷ valid above 5 % for 10 min, at least 30 attempts; caller_defect alone below 5 % → ticket to the owning team] | [per function] | [on-call rota] | `runbooks/<function>.md` | shadow / paging |

## Burn-rate alerts

| SLO | Fast burn (pages) | Slow burn (ticket) | State |
|---|---|---|---|
| [J1.1] | [14× budget rate over 1 h and 5 min] | [6× over 6 h and 30 min; 1× over 3 days] | shadow |

## Telemetry health

| Failure of the telemetry | How it shows | Detected by | Reads today as |
|---|---|---|---|
| [exporter drops data] | [series stop, service healthy] | [export heartbeat, to build] | [no traffic] |

## Paging gate

Paging is admitted **per alert**, not by a common maturity level. An alert moves from shadow to
paging only when each part of its gate is shown, not stated.

| Part | Shown when |
|---|---|
| Alert quality | Firing, missing data, recovery and delivery are checked for this alert. For a counter, a failure before its first export and a failure after a delivered zero are checked separately |
| Response | A primary and a backup person, the hours they cover, acknowledgement and escalation are named |
| Outside-in (synthetic alerts) | The check reads the user path it stands for; an edge-blocked check is not a success; a failure of the synthetic itself is told apart from a failure of the product |
| Independent delivery | A backup delivery path is tested before any alert pages. A watchdog may serve when a test shows it detects the loss of the main path and notifies independently of it; a fallback subscriber alone does not prove that. A second channel to the same person is delivery backup, not escalation |

- **One responsible person** is not a rota. With one person, alerts stay out of paging, unless
  a separate exception is decided that explicitly accepts the risk of no response.
- **A recorded test is not a passed gate.** Where a test shows a requirement missed, the alert
  needs an extra mechanism, or a limitation accepted explicitly for that alert, before it pages.
- **Where tests run.** Failure scenarios run in an isolated temporary environment with test
  data. A test of production delivery is a controlled notification, authorised separately,
  with no application failure. An isolated test proves only its own route.
- Paging readiness of a function is the gate of each of its alerts; one alert passing does not
  lift the others.

## Suppression

[Maintenance windows, dependency-down suppression, how a suppressed alert is still recorded.]

## Synthetic alerts

[Which synthetics page, and after how many consecutive failures.]

- A base condition to start from: two consecutive failed one-minute checks, with *blocked* and
  *missing* handled separately from *failed*.
- **Blocked counts as bad** in the synthetic SLI. It may raise a notification of its own that
  does not page; then a full block at the edge is not detected by paging — say so, and test a
  separate escalation scenario for it.
- **Signed-in probes** use a dedicated synthetic identity: minimal rights, test data, the secret
  in a managed store, rotation and an owner. A probe that starts from a session or an API token
  does not check the identity provider's sign-in; say which it does.

## Hypercare

[Period, rota, exit criteria: share of actionable firings, runbooks exercised, on-call owns the alerts.]

## Firing review

[Weekly: every firing marked actionable / noise / duplicate; noise has an owner and a fix date.]

## Error-budget policy

| Budget spent | Action | Decided by |
|---|---|---|
| [50 % in the window] | [review of the top causes; risky changes need a second look] | [owner] |
| [100 %] | [feature changes paused for the function until the budget recovers, except fixes] | [owner] |
