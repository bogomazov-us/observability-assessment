# Skeleton — `signals.md`

How each function is measured, in enough detail that an engineer can implement it and a
reviewer can check it.

---

# Signals

## Tool configuration

<Monitoring tool, environments, how test traffic is separated, data retention.>

## Event registry

| Function | Event or span name | Emitted by | Attributes | State |
|---|---|---|---|---|
| <J1.1> | `<domain.function.result>` | <service> | outcome, error_class, error_code, attempt_id, operation_id | live / to build |

## Identity

| ID | Created by | Carried in | Purpose |
|---|---|---|---|
| attempt_id | <client or service> | header / attribute | one business attempt across retries and operations |
| operation_id | <service> | attribute | one call inside the attempt |
| request_id | <edge> | header | correlation with logs |
| test traffic flag | <harness> | header | excluded from SLIs, counted in release checks |

## Two-level model

<Only when one business attempt spans several operations. Define the attempt outcome from the
operation outcomes: which operation decides success, how retries are counted, what "unknown"
means and how long it may last.>

## Headers, attributes and logs

<Required fields, naming, what must never be logged (personal data, secrets).>

## Queries

| SLI | Query | Verified on | Result |
|---|---|---|---|
| <J1.1 success> | `<query>` | <controlled scenario, date> | <expected vs counted> |

## Telemetry health

<How we know the signal itself is arriving: volume floors, missing-attribute rates, agent
coverage. A silent signal must not look green.>
