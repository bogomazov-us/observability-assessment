# Kick-off note

Filled at the kick-off ([calendar](../method/getting-started.md#3-calendar)) and kept at `[working folder]/kickoff-note.md`
(`assessment/kickoff-note.md` by default): the agent stages read their scope from it. What the
client states enters the facts ledger as an assumption until shown; what is agreed enters the
decision register, and this note cites its ids.

Engagement: [name] · Date: [date] · Format: [focused or full] · Present: [roles]

## The sponsor's question

[One question, in the sponsor's words; the report answers it on its first page.]

## Goals

| # | Goal | How we know it is met |
|---|---|---|
| 1 | [goal] | [evidence or decision at the read-out] |

## Journeys in scope

| Journey (client's words) | Owner | Mandatory at the next go-live | [Golden journey proof](golden-journey-proof.md) |
|---|---|---|---|
| [journey] | [name, role] | [yes / no] | [yes / no] |

## Services

| Service | Journeys | Tier | Owner | Code repository |
|---|---|---|---|---|
| [service] | [journeys] | [1 / 2] | [name] | [repository] |

## Monitoring tools

| Tool class | Signals it holds | Owner | Read-only route |
|---|---|---|---|
| [APM suite, metrics-and-logs stack, pipeline, cloud monitoring] | [traces, RUM, logs, metrics, synthetics, alerts] | [name] | [token, MCP server, export] |

## Access dates

| Access or export | Data request row | Client provider | Promised by (date) |
|---|---|---|---|
| [access] | [#] | [name] | [date] |

## Who decides what

Roles as defined in the [roles table](../method/records.md#roles).

| Decision | Role | Name |
|---|---|---|
| Scope change (journeys, services, tools) | Sponsor | [name] |
| SLO targets per journey | Technical owner | [name] |
| Verdict on a finding | Owner of the finding's verdict | [name] |
| Acceptance of the report | Sponsor | [name] |

## Agreed scope in the decision register

| Decision id | What was agreed | Date |
|---|---|---|
| [D-NN] | Format, journeys, services and tools in scope | [date] |
| [D-NN] | Golden journey proof: in scope or not; stage access and developer if it is | [date] |

Questions left open go to `owner-questions.md`, each with an owner and a date.
