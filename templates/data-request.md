# Data we ask for first

Send on day one. Every item is an export or read access, not a meeting.

| # | Item | Why | Owner |
|---|---|---|---|
| 1 | Read-only access to the monitoring tool (UI and API token with read scopes) | Inventory, queries, evidence | Monitoring tool team |
| 2 | Read access to the code repositories of tier-1 front ends and services | Error path, correlation, logging, RUM | Engineering lead |
| 3 | Export of alert rules, alerting profiles, notification integrations | Alert quality | SRE / NOC |
| 4 | Ticket history for 3–6 months (incidents, severity, timestamps) | MTTD / MTTR baseline | Operations |
| 5 | Timelines of the last 10 major incidents | Detection and diagnosis gaps | Operations |
| 6 | Existing dashboards and reports used by business | What is already agreed | Product |
| 7 | Architecture diagrams (C4 or similar), integration list | Signal sources | Architecture |
| 8 | Error code lists, API contracts | Error taxonomy | Engineering |
| 9 | Previous investigations, strategies, tool evaluations | Build on them | Delivery lead |
| 10 | Certificate, domain and synthetic monitor inventory | Availability blind spots | Platform |

Rules: tokens go to a secret store, never a file or chat; HAR captures are sanitized before they
are stored.
