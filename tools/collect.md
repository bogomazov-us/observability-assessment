# Collection scripts — week one

Three scripts that speed up playbook steps 3 (read the code) and 4 (inventory the tenant). They
gather; they do not judge. Every line they produce is input to a finding, never a finding by
itself (playbook, evidence levels).

> **Status.** `code-scan.sh` is tested on a generated source tree. The vendor exporters are
> written against the vendors' public API documentation and tested against a stub; they have
> **not yet been run against a live tenant**. The first engagement that uses them verifies them
> and fixes what the documentation got wrong. New Relic and OpenTelemetry-native exporters are
> still in the backlog.

## Where the output goes

Into the engagement repository, never into this kit. Exports carry service names, hostnames,
tags and sometimes personal data in names or queries: sanitize before committing, and keep raw
exports outside version control if the engagement's rules say so. Credentials come only from
environment variables; the scripts pass them to `curl` through a private temporary file, so they
do not appear in the process list or in logs.

## Code scan

```
tools/collect/code-scan.sh [path to the client repository] [scan.md]
```

Greps the repository and writes a Markdown report with `file:line` for every hit, in seven
groups: RUM and browser SDKs; correlation headers; server-side agents and OpenTelemetry;
source maps; errors inside HTTP 200 (including GraphQL errors); logging libraries and
structure; retries and timeouts. Dependencies, build output, minified files, lock files and
source maps are skipped. A group with no hits is listed with "nothing found": that is a question
for the owner, not a conclusion.

Read the report next to the code: a hit on `traceparent` may be a test; a missing RUM hit may
mean the snippet is injected by the agent. Each confirmed lead becomes a finding with its
evidence (`templates/finding.md`).

## Dynatrace inventory

```
DT_ENV_URL=https://[environment] DT_API_TOKEN=[token] tools/collect/dynatrace.sh [out dir]
```

| Export | API | Token scope (read only) |
|---|---|---|
| Entities: applications, mobile applications, services, hosts, process groups, HTTP checks, synthetic tests (seen in the last 72 hours) | `/api/v2/entities` | `entities.read` |
| Alerting profiles, metric events, problem notifications | `/api/v2/settings/objects` | `settings.read` |
| SLOs | `/api/v2/slo` | `slo.read` |
| Synthetic monitors | `/api/v1/synthetic/monitors` | `ReadSyntheticData` |
| Dashboards (list) | `/api/config/v1/dashboards` | `ReadConfig` |

## Datadog inventory

```
DD_API_KEY=[key] DD_APP_KEY=[key] DD_SITE=[site, default datadoghq.com] tools/collect/datadog.sh [out dir]
```

| Export | API | Application key scope (read only) |
|---|---|---|
| Monitors | `/api/v1/monitor` | `monitors_read` |
| Dashboards (list) | `/api/v1/dashboard` | `dashboards_read` |
| SLOs | `/api/v1/slo` | `slos_read` |
| Synthetic tests | `/api/v1/synthetics/tests` | `synthetics_read` |
| RUM applications | `/api/v2/rum/applications` | `rum_apps_read` |
| Service definitions | `/api/v2/services/definitions` | `apm_service_catalog_read` |

Both exporters page through the API, write one JSON file per export and a `summary.md` with the
counts, and use GET only. A request that fails stops the run: a missing scope must not look like
an empty estate.

## How the results are used

| Output | Playbook step | Goes into |
|---|---|---|
| Code scan report | 3 Read the code | Code findings; questions for the developer interviews |
| Exports and summary | 4 Inventory the tenant and tools | Inventory; reconciliation of exports with each other and with the intake answers; findings |
| Missing scopes or blocked requests | 2 Intake | The data request (`templates/data-request.md`), as an access item with an owner and a date |

The exporters replace the export items of the data request only when the client grants an API
token; otherwise ask for the same exports through the data request.

## Tests

`tools/tests/test_collect.sh` runs without network: it builds a fake repository and a stub
`curl` at run time and checks the scan groups, the exclusions, paging, the summaries, that a
failed request fails the run, and that credentials stay off the command line.
