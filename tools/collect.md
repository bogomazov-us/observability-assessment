# Collection — week one

Two ways to speed up playbook steps 3 (read the code) and 4 (inventory the tenant and tools):
a code scan, and an export of the monitoring estate by object class. They gather; they do not
judge. Every line they produce is input to a finding, never a finding by itself (playbook,
evidence levels).

The kit is tool-agnostic. It names classes of capability and of configuration object, never a
product: the client may run a full-stack APM suite, a metrics-and-logs stack, an
OpenTelemetry pipeline, a cloud provider's monitoring, or several at once.

## Where the output goes

Into the engagement repository, never into this kit. Exports carry service names, hostnames,
tags and sometimes personal data in names or queries: sanitize before committing, and keep raw
exports outside version control if the engagement's rules say so. Credentials stay in the
environment of whoever runs the export, never in a file in a repository.

## Code scan

```
tools/collect/code-scan.sh [--signatures FILE] [path to the client repository] [scan.md]
```

Greps the repository and writes a Markdown report with `file:line` for every hit, in seven
classes:

| Class | Built-in patterns look for |
|---|---|
| RUM / browser SDK | real-user monitoring initialisation, browser agents, beacons, OpenTelemetry web tracing |
| Correlation headers | W3C trace context (`traceparent`, `tracestate`), request and correlation IDs, B3 |
| Server-side agents and instrumentation | agent attach flags, OpenTelemetry SDKs and variables, APM agents, auto-instrumentation |
| Source maps | bundler source-map settings and upload steps |
| Errors inside HTTP 200 | success responses that carry an error, a refusal status or a GraphQL error |
| Logging libraries and structure | logging libraries, structured and JSON layouts, mapped diagnostic context |
| Retries and timeouts | retry and backoff calls and settings, timeouts, circuit breakers (not the word "retry" in labels or prose) |

The built-in patterns are vendor-neutral. When the client's tool is known, put its signatures —
package names, init calls, agent names — in a signatures file in the engagement repository and
pass it with `--signatures`. One line per pattern, `Class name|regex`: a known class is
extended, a new name adds a class.

Dependencies, build output, minified and generated files, lock files and source maps are
skipped; so are files above 512 KB (`SCAN_MAX_KB` changes it), which in a code repository are
data — dumps, backups, fixtures — and only slow the scan down. The report counts each class
separately in code, tests and docs, and lists code first: a lead in a test or a design note says
what someone intended, not what runs. A class with no hits is listed with "nothing found": that
is a question for the owner, not a conclusion — an application may log through the platform's
console rather than a logging library. Read
the report next to the code: a missing RUM hit may mean the snippet is injected by an agent at
the edge, and a hand-rolled one (web vitals posted with a beacon to the application's own
endpoint) is still real-user monitoring.

## Estate export by object class

Whatever the tool, the same classes of object are exported. Ask for each class; reconcile the
classes with each other and with the intake answers.

| Object class | Export | Why | Reconcile with |
|---|---|---|---|
| Monitored entities | Applications, services, hosts or containers, process groups, with the last time each was seen | Coverage: what is instrumented at all | Service list from the architecture and the code scan |
| Real-user monitoring | Front-end applications, their domains, sampling, session replay and privacy settings | Outside-in view and its blind spots | RUM class in the code scan |
| Synthetic checks | Each check: target, steps, frequency, locations, alerting | What runs continuously | Journeys in scope |
| Alert rules and detectors | Each rule: metric or query, threshold, window, minimum volume, scope, state | Alert quality; rules on pooled rates or hosts; rules on deprecated metrics | Signals per function |
| Notification routing | Profiles, integrations to paging and ticketing, escalation, maintenance windows | Whether a firing reaches a person | On-call rota from the intake |
| SLOs | Each SLO: SLI definition, target, window, owner | Whether targets exist and what they count | SLO candidates per function |
| Dashboards | List with owner and last view or change | What people look at; dead dashboards | Interviews |
| Telemetry pipelines | Ingest and processing rules, sampling, retention, drop and mask rules | What an SLI can rely on; personal data (privacy checklist) | Data governance (maturity dimension 11) |
| Integrations | Cloud accounts, CI/CD and deploy markers, ticketing | Release observability; context in incidents | Release process from the intake |
| Consumption and licence | Units consumed against entitlement, by data type | Headroom for business events and synthetics | Intake, licence question |

**How to get it, in order of preference:** a read-only API token used by the engagement team; a
read-only MCP server the agent harness can query; a configuration export from the tool's
interface; an export run by the client's administrator. Record the route and the date for each
class in the data request (`templates/data-request.md`); a class that could not be exported is a
gap with a reason, not an empty class.

**Scripts for a specific tool** are written in the engagement repository, read-only by
construction (GET or read-only queries, credentials from the environment, a failed request fails
the run so that a missing permission never looks like an empty estate). What generalises comes
back into the kit as a change to this table, not as a product-specific script.

## How the results are used

| Output | Playbook step | Goes into |
|---|---|---|
| Code scan report | 3 Read the code | Code findings; questions for the developer interviews |
| Estate export by class | 4 Inventory the tenant and tools | Inventory; reconciliation; findings |
| Classes that could not be exported | 2 Intake | The data request, as an access item with an owner and a date |

## Tests

`tools/tests/test_collect.sh` builds a fake repository at run time and checks the classes, the
split into code, tests and docs, the exclusions (generated files, large files), a signatures
file that extends a class and adds one, and that the scanned repository is left untouched.
