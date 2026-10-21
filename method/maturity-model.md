# Maturity model

Five levels: **1 Opportunistic · 2 Developing ·
3 Engaging · 4 Sustainable · 5 Transformative**. Each score needs one line of evidence; a score
without evidence is not given. Report as a table with a "you are here" marker and, per dimension,
Highlights / Keep an eye on / Lowlights.

| # | Dimension | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 1 | Business-function model | No journeys defined; faults reported by customers | Journeys listed, no functions or owners | Tier-1 journeys decomposed into functions with owners | Every function has a signal, SLI and threshold | Model maintained with the code (story template, release check) |
| 2 | Telemetry coverage | Infra metrics only | APM agent on some services; RUM partial | Agents and RUM on all tier-1 components | Coverage measured and ≥95% of tier-1 calls traced | Coverage is a release gate |
| 3 | Error semantics | HTTP status only | Some codes logged | Codes classified expected / failure on critical paths | Full taxonomy; HTTP 200 refusals recognised | Taxonomy enforced in code review |
| 4 | Correlation and tracing | None; logs by SSH | Request IDs in some logs | Correlation ID end to end on tier-1 | Browser → service → downstream trace linked | Trace used in every incident |
| 5 | Business events | None | Analytics events only (marketing) | Named events on critical steps | Events with outcome, class and IDs; used in SLIs | Events drive product and ops decisions |
| 6 | SLOs | None | Availability targets in contracts only | SLOs on some journeys | SLOs on all tier-1 functions, error budgets tracked | Error-budget policy changes release decisions |
| 7 | Alert quality | Host and threshold alerts, noisy | Some per-service alerts; no owners | Per-function alerts with owners | Every alert has owner, sample rule, runbook; actionable share measured | ≥80% actionable; reviewed weekly |
| 8 | Incident response | Ad hoc | On-call exists, no roles | Roles, severity levels, post-mortems | Blameless reviews with deadlines; MTTD/MTTR measured | Game days; recurrence tracked |
| 9 | Synthetics and RUM | None | Uptime checks | Synthetic on tier-1 entry; RUM on main app | Synthetic per tier-1 journey, two locations | Synthetic and RUM tied to SLOs |
| 10 | Release observability | None | Deploy markers | Release compared before/after | Release check: every release proves its signals | Automated gate |
| 11 | Data governance and cost | Unknown retention, sampling, PII | Known but undocumented | Documented; PII scrubbing in place | Cost and sampling managed per signal | Telemetry budget is a product decision |
| 12 | Operational AI / AIOps | None | Vendor anomaly detection on defaults | Anomaly detection tuned; correlation used | AI-assisted investigation with read-only tool access | Assisted remediation on proven alert quality |

**What moves the score fastest** — list, for the client, the three or four actions that lift the
most dimensions for the least effort (typically: error classification, correlation ID, per-function
alerts with owners, a release check).
