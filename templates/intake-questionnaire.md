# Intake questionnaire

Send by owner, not as one block. Ask for an **export or screenshot** wherever possible. For a
short first meeting use the questions marked ★. Section G only for the tool classes the client
runs.

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

## G. By tool class (monitoring tool team, platform)

Ask only the sets that match the client's estate; most estates need two. Every question asks
for an export by object class (`tools/collect.md`), not a description.

**Full-stack APM suite** (agents, RUM, synthetics and alerting in one product)

32. Export of monitored entities with the last time each was seen, and of the agent or process
    groups that are excluded from monitoring.
33. Export of the automatic detection and baselining settings, and of every rule that overrides
    them for a tier-1 service.
34. Export of the request and error naming rules: which requests are grouped, renamed or
    ignored, and which failure detection rules treat an error as success.
35. Export of the problem or alert notification profiles and their integrations to paging and
    ticketing.
36. Licence or consumption report by data type for the last three months.

**Metrics-and-logs stack** (a time-series store, a log store, dashboards and alert rules)

37. Export of the alert rules with their queries, thresholds, windows and labels used for
    routing.
38. Export of the scrape or ingest targets, and of the services that have no target.
39. Label and field conventions: the list of labels on request metrics and the cardinality
    limits applied.
40. Log ingest and parsing rules: which fields are extracted, dropped or masked, and the
    retention per index or stream.
41. Which request metrics exist per service (rate, errors, duration) and which are derived from
    logs; one sample query per tier-1 function.

**OpenTelemetry-native pipeline** (SDKs and collectors feeding one or more backends)

42. Collector configuration files for every collector tier: receivers, processors, exporters.
43. Sampling: head or tail, the rules and rates, and where they are configured.
44. SDK and instrumentation versions per service; services with manual spans or without any.
45. Resource attributes and semantic conventions in use; who changes them and how.
46. Backends per signal (traces, metrics, logs), and what is dropped or transformed between
    the collector and each backend.

**Cloud provider monitoring** (the provider's own metrics, logs, alarms and dashboards)

47. Export of alarms or alert policies per account or project, with their notification targets.
48. Export of log routing and retention settings per account or project.
49. Which managed services in the tier-1 path have request-level metrics, and which only
    resource-level ones.
50. How cloud monitoring data reaches the main monitoring tool, if at all, and with what delay.

**Several tools at once**

51. ★ For each signal type (traces, front-end, logs, metrics, synthetics, alerts), which tool
    is the source of truth?
52. Export of alert rules from every tool that pages the same rota; which incidents paged twice.
53. Which identifiers link records across the tools (trace ID, request ID, service name), and
    where the names differ.
54. Which tool is being retired or introduced, and by when.
