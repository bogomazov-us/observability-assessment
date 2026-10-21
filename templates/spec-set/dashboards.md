# Dashboards

*Spec-set skeleton for `dashboards.md`. What people look at. Three levels; each tile says which function it belongs to.*

## Journeys (everyone)

| Tile | Shows | Source |
|---|---|---|
| [J1 health] | SLI per function, budget left | [SLI queries] |

## Function detail (engineers, on-call)

| Tile | Shows | Source |
|---|---|---|
| [J1.1 outcomes] | attempts by class (expected / failure / caller_defect / ambiguous / unknown) | [event query] |
| [J1.1 telemetry health] | volume vs floor, missing attributes | [query] |

## Daily health (operations)

[Baselines with control limits; last day's firings; open noise items.]
