# Roadmap template — assessment to BAU

Each milestone closes with a **demonstrated** result and has **one accountable owner** by name.
Client decisions stay with the client role that takes them; the accountable owner makes sure they
are asked and answered in time. Every milestone names the commitments it delivers.

| Milestone | Typical offset | Done when (demonstrated) | Accountable |
|---|---|---|---|
| M0 — Blocking decisions | week 1–2 | Version / scope of what goes live chosen; back-end changes estimated and in a sprint; licence or budget for business events confirmed or fallback chosen; test users requested; tier-1 journeys and SLO owners approved at a product review | Lead |
| M1 — Technical visibility on stage | +1 week | RUM, error adapter, source maps; agent on the active back end; a trace from a browser action to the outbound downstream call; ≥95% of calls linked, measured on a harness run | Observability engineer |
| M2 — Business outcomes observable | +1 week | Refusals in 200 responses recognised; IDs, outcome, error class on every critical response; error codes classified one by one; observability section in the story template | Architect |
| M3 — Measurements validated | +1 week | SLI queries verified in the tool; worked examples reproduced on stage (retries, missing IDs, late results); telemetry health; synthetics | Observability engineer |
| M4 — Operational acceptance (go/no-go) | +1 week | Dashboard with baselines and control limits; P1 detectors in shadow with runbooks; release harness on every release; test P1 delivered, acknowledged, escalated; hypercare rota | Lead |
| M5 — Delivery-ready | +1–2 weeks | Production configuration checked; test traffic separated; contacts and access ready | Client delivery lead |
| M6 — Live baseline | go-live + 7 days | Baseline; thresholds reviewed; SLO targets confirmed by product; weekly firing review | Observability engineer |
| M7 — Handover to BAU | when criteria met | ≥80% of firings actionable; critical break detected within the agreed time; paging through the client's on-call | Client operations |

**Critical path:** M0 → back-end contract (M2) → proof the calculations are right (M3) → M4.

**Go/no-go decision:** Go · Go with exceptions (each limitation written down with a compensating
measure, an owner and a date) · No-go (the key outcome cannot be determined reliably, or a
critical signal does not reach the person on duty).

**Name the schedule risk and its fallback** — usually the back-end change; the fallback is a
coarser SLI from server spans, taken to go/no-go as an exception.

Milestone card for the tracker:

```
Milestone:   M2 — Business outcomes observable
Accountable: <one name>
Date:        <date>
Depends on:  M0
Done when:   <criteria>
Evidence:    <demo recording, query output, harness run id>
Status:      not started / in progress / demonstrated
```
