# Observability — [system name]

*Spec-set skeleton for `docs/observability/README.md`. Copy as `README.md` into `docs/observability/` in the client repository.*

| Version | Status | Owner | Last review |
|---|---|---|---|
| 0.1 | draft / in review / approved for implementation | [name] | YYYY-MM-DD |

## Why

[Two or three sentences: what the business cannot see today and what it costs.]

## Goals

| # | Goal | Measure | Committed by |
|---|---|---|---|
| G1 | [e.g. checkout failures are detected before the support queue sees them] | [P1 fires within 10 min of an agreed failure scenario on stage] | [date] |

Not promised: [explicit list].

## Scope

In scope: [journeys, services, environments]. Out of scope: [list].

## Signal architecture

| Component | Source of signal | State |
|---|---|---|
| Browser | RUM | live / to build |
| [service] | agent traces, business events | live / to build |

## Plan and dependencies

Milestones: see `roadmap.md` or the tracker. Dependencies:

| # | Dependency | Owner | Needed by |
|---|---|---|---|

## Acceptance evidence

| Claim | Evidence | Where kept |
|---|---|---|
| [SLI query returns the right count on a controlled scenario] | [query output + scenario run id] | [link] |

## Glossary · Open questions

| # | Question | Owner | Due |
|---|---|---|---|
