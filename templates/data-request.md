# Data we ask for first

Send on day one. Every item is an export or read access, not a meeting. "Needed by" is the week
of the engagement (`method/getting-started.md` §3) by which the stage that uses the item starts;
"Client provider" is a named person, filled in at kick-off.

| # | Item | Why | Client provider | Needed by (week) | Received |
|---|---|---|---|---|---|
| 1 | Read-only access to the monitoring tool (UI and API token with read scopes), per object class below | Inventory, queries, evidence | Monitoring tool team | 1 | [date] |
| 2 | Read access to the code repositories of tier-1 front ends and services | Error path, correlation, logging, RUM | Engineering lead | 1 | [date] |
| 3 | Export of alert rules, alerting profiles, notification integrations | Alert quality | SRE / NOC | 1 | [date] |
| 4 | Ticket history for 3–6 months (incidents, severity, timestamps) | MTTD / MTTR baseline | Operations | 2 | [date] |
| 5 | Timelines of the last 10 major incidents | Detection and diagnosis gaps | Operations | 2 | [date] |
| 6 | Existing dashboards and reports used by business | What is already agreed | Product | 2 | [date] |
| 7 | Architecture diagrams (C4 or similar), integration list | Signal sources | Architecture | 1 | [date] |
| 8 | Error code lists, API contracts | Error taxonomy | Engineering | 2 | [date] |
| 9 | Previous investigations, strategies, tool evaluations | Build on them | Delivery lead | 1 | [date] |
| 10 | Certificate, domain and synthetic monitor inventory | Availability blind spots | Platform | 2 | [date] |
| 11 | Sanitized HAR captures, one per journey in scope (below) | Journeys decomposed into functions (stage 2) | Product, with a tester | 2 | [date] |
| 12 | Billing export for monitoring and telemetry, by month and by service, with the budget it is paid from (lesson 19) | Cost before telemetry work is sized | Platform or finance | 2 | [date] |
| 13 | Golden journey proof only: stage environment access with write rights to the monitoring configuration | Instrument one journey end to end | Platform | 4 | [date] |
| 14 | Golden journey proof only: one client developer for 5 days, who makes the code change | The client owns the change | Engineering lead | 4 | [date] |

Rules: tokens go to a secret store, never a file or chat; HAR captures are sanitized before they
are stored. Rows 13–14 are struck out when the proof is not in scope; without them the proof is
delivered as a design and a checklist.

## Monitoring access by object class

One row per class in `tools/collect.md`. A class that could not be exported keeps its row, with
the reason, an owner and a date to retry.

| Class | Route (API token, MCP server, UI export, admin export) | Date | Not exported: reason, owner, retry by |
|---|---|---|---|
| Monitored entities | | | |
| Real-user monitoring | | | |
| Synthetic checks | | | |
| Alert rules and detectors | | | |
| Notification routing | | | |
| SLOs | | | |
| Dashboards | | | |
| Telemetry pipelines | | | |
| Integrations | | | |
| Consumption and licence | | | |

## HAR captures per journey

Captured with a test account, never a real customer; sanitized by the steps in
`templates/privacy-checklist.md` before they reach the engagement repository.

| Journey | Captured by | Environment | Test account (named; credentials via the secret store) | Sanitized by | Date |
|---|---|---|---|---|---|
| [journey] | [client tester or developer] | [stage or production] | [account name] | [person] | [date] |
