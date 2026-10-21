# Specification set — `docs/observability/` in the client repository

The Blueprint output. Lives in the client's repository next to the architecture docs, so it
changes with the code. Nine documents; a skeleton for each sits next to this file
(`spec-readme.md` becomes the client's `README.md`, `runbooks/function.md` one runbook per
function). The [worked example](../../example/worked-example.md) shows them filled in for one journey.

| File | Answers | Reader | Must contain |
|---|---|---|---|
| `README.md` | Why, goals, scope, architecture of signal sources, plan, dependencies, glossary, readiness and open questions | everyone | Goals = commitment baseline with measures; signal architecture with live / to-build state per component; dependency list with owners; acceptance evidence table |
| `userjourneys.md` | Which journeys and functions, with what SLI | product, QA | Per function: route or call, signal, typed failures, SLI, draft threshold |
| `signals.md` | How each function is measured | engineers | Tool configuration; event registry (function → event name); identity (attempt, operation, request IDs; test traffic flag); two-level model where a business attempt spans several operations; headers and attributes; logs; queries; telemetry health |
| `error-taxonomy.md` | What each error code means | engineers, operations | Classes (expected / failure / caller defect / ambiguous / unknown); codes by function; gaps found; classes still to confirm |
| `slo-alerts.md` | What we promise and when we wake someone | product, operations | Rules; SLO table (good ÷ valid, rolling 28 days); P1 alerts with sample rules, grouping, playbook; suppression; synthetic alerts; hypercare; firing review; error-budget policy |
| `instrumentation-contract.md` | What every story must emit | developers | Story template section; code rules; release check: controlled scenarios as test traffic, detector checks with volumes, notification delivery test, passive checks |
| `synthetics.md` | What runs continuously | operations | Monitors, frequency, locations, test users |
| `dashboards.md` | What people look at | everyone | Journeys, function detail (with telemetry health), daily health |
| `runbooks/<function>.md` | What to do when it fires | responder | Six sections: what the customer sees; first five minutes; mitigate; risky switches; customers left in an unknown state (reconciliation); close |

The chain itself — functions, taxonomy, signals, SLOs, alerts, runbooks — is also kept as
`observability-spec.yml` ([skeleton](observability-spec.yml)) and checked by the
[spec linter](../../tools/speclint.md) before each review round.

Review practice: several written rounds; the reviewer closes the architecture review with an
explicit verdict, and acceptance moves to evidence on stage.
