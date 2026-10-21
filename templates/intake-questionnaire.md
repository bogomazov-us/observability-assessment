# Intake questionnaire

Send by owner, not as one block. Ask for an **export or screenshot** wherever possible. For a
short first meeting use the top 10 (marked ★).

## A. Business and scope (product owner, delivery lead)

1. ★ Which customer journeys are critical? Which are mandatory at the next go-live?
2. Who owns each journey's health? Who decides SLO targets?
3. What counts as good service: a correct business refusal, a completed transaction, or both?
4. What has the business already agreed (dashboards, KPIs, contract SLAs)?
5. ★ Which recent incidents hurt most, and how were they detected (by customers, by alerts)?
6. What has already been investigated (tiger teams, internal tools, vendors)? Can we see it?

## B. Monitoring estate (monitoring tool team)

7. ★ Which tools are in use (APM, RUM, logs, synthetics, incident management, analytics)? Export of applications, services, hosts.
8. Agent coverage by layer: apps, infra, APIs, integrations, journeys — as a percentage, and how it is measured.
9. Is RUM on every customer-facing front end? Source maps? Which application-detection rules?
10. Sampling, retention, ingest latency (real time or batch) per data type.
11. Licence model and headroom: business events, logs, synthetics, custom metrics.
12. Who can create applications, alerts, dashboards; API tokens and their scopes.

## C. Alerts and response (SRE / NOC / operations)

13. ★ Export of alert rules per tool with severity, owner and routing.
14. ★ Alert volume per app, tool, severity and source; how the non-actionable share is calculated.
15. Share of alerts that auto-resolve, are duplicates, or need action.
16. Current MTTD, MTTR, recurrence and reopen rates — and how each is measured.
17. On-call model, hours, escalation, incident roles; ticketing integration.
18. Runbook coverage: share of alerts mapped to a runbook.
19. Timelines of the last 10 major incidents.

## D. Application and code (architects, developers)

20. ★ How do services return business refusals: HTTP status, or 200 with an error body?
21. Error codes: is there a list? Who owns it? Are downstream codes passed through or collapsed?
22. ★ Correlation: which ID links browser, services and downstream? Is it logged?
23. Logging: pattern, levels, where logs go, retention, PII scrubbing.
24. Front-end error reporting: one adapter, or scattered console errors?
25. Release process: how is a release checked for its signals? Feature flags?

## E. Data, privacy, cost (security, platform)

26. Which identifiers may appear in telemetry, who may see them, for how long?
27. Where are URLs and sensitive fields cleaned?
28. What does telemetry cost today and who owns that budget?

## F. Targets (where an RFP or contract exists)

29. ★ Target SLAs: monitoring platform availability, alert noise, coverage, MTTD per tier.
30. How is blast radius defined and evidenced?
31. Which anomaly-detection or correlation capabilities are live, and with what results?
