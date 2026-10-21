# Estimation model

How to estimate an engagement in person-days by role without the authors. The limits per format
are in [offerings.md](../offerings.md); this model turns a scope inside those limits into effort,
and checks that the effort fits the calendar. Prices are not part of the kit: a day rate belongs
to the contract, not the method.

> **Starting values.** The numbers below are a first calibration, not measured actuals; the
> staffing rule (the lead full time, other roles by scope) and the per-journey increment were
> set by the owner on 2026-10-21. Record actual
> days per phase on every engagement (see "Calibrating") and replace them after the pilot.

## How to estimate

1. **Fix the scope** in the units below: journeys, services, monitoring tools, environments,
   review rounds. Anything above the format's limit is a change request, not a bigger estimate.
2. **Take the base** for the format: effort for the smallest scope it is sold for.
3. **Add the increments** for each unit above the base.
4. **Check capacity and staff by scope.** The lead is full time and does the work of any role
   that is not staffed. Add the observability engineer, then the architect, only when the lead's
   days exceed the calendar or the work needs their skill; otherwise lengthen the calendar —
   never compress the evidence work.
5. **Add contingency** for our own risks only (an unfamiliar tool, a new lead). A client
   obligation that is missed moves the date, not the price (offerings, client obligations).
6. **Write the assumptions down** in the proposal: the scope units, the allocations, the
   obligations the plan relies on.

## Base effort, person-days

Base scope: **1 journey, 3 services, 1 monitoring tool**; environments and review rounds as the
format states.

### Focused assessment (2–3 weeks; production read-only; 1 review round)

| Phase | Lead | Obs. engineer | Architect |
|---|--:|--:|--:|
| Align: document review, intake, interviews | 2 | 1 | 0 |
| Inventory: tenant export, code read, journey capture | 1 | 3 | 0.5 |
| Diagnose: taxonomy on the journey, findings, maturity | 1 | 2 | 0.5 |
| Report, plan, one review round | 2 | 1 | 0 |
| **Base** | **6** | **7** | **1** |

### Full assessment (6 weeks; stage and production; 2 review rounds)

| Phase | Lead | Obs. engineer | Architect |
|---|--:|--:|--:|
| 1 Align & baseline | 4 | 2 | 0 |
| 2 Observe & trace | 2 | 6 | 1 |
| 3 Diagnose | 3 | 5 | 1 |
| 4 Golden journey proof (only with stage access and a client developer) | 1 | 4 | 2 |
| 5 Operationalize | 2 | 3 | 1 |
| 6 Executive roadmap, two review rounds | 5 | 2 | 1 |
| **Base** | **17** | **22** | **6** |

Without the golden-journey obligations the proof is a design and a checklist: take phase 4 as
lead 1, engineer 1, architect 2.

### Blueprint (3–4 weeks; 2 review rounds)

| Phase | Lead | Obs. engineer | Architect |
|---|--:|--:|--:|
| Journeys, error taxonomy, two-level model | 1 | 1 | 2 |
| Signals, SLOs and alerts, instrumentation contract | 1 | 2 | 3 |
| Synthetics, dashboards, runbooks, acceptance scenarios | 0.5 | 1.5 | 0.5 |
| Roadmap with milestones, two review rounds | 2.5 | 0.5 | 1.5 |
| **Base** | **5** | **5** | **7** |

### Implementation and hypercare

Not estimated by formula: the Blueprint's roadmap cards carry the effort (see the worked
example, "Roadmap with effort"). Add on top of the cards: lead at 20 % of the observability
engineer's days; architect 1 day per milestone for review. Hypercare, 4 weeks: observability
engineer 10, lead 4. Client developers are the client's effort and appear in the proposal as an
obligation, not in our days.

## Increments per unit above the base

| Unit | Lead | Obs. engineer | Architect | Applies to |
|---|--:|--:|--:|---|
| Each journey after the first | 1 | 1 | 0.5 | assessments |
| Each journey after the first | 0.5 | 1.5 | 2 | Blueprint |
| Each service after the third | 0 | 0.5 | 0 | all |
| Second monitoring tool | 0.5 | 3 | 0 | all |
| Extra review round (by change request) | 1.5 | 0 | 1 | all |

## Capacity check

The lead is full time: the calendar's working days. Roles are added in this order, each only
when the days before it do not fit:

1. **Lead alone** — the lead does all the work.
2. **Lead and observability engineer** — the engineer takes the engineer's days; the lead keeps
   the lead's and the architect's.
3. **Lead, engineer and architect** — the architect takes the architect's days, part time.
4. A second engineer for a few days, when the engineer's days alone exceed the calendar.

With these starting values:

| Scope | Total days | Calendar | Staffing that fits |
|---|--:|--:|---|
| Focused, base, 3 weeks | 14 | 15 | lead alone |
| Focused, base, 2 weeks | 14 | 10 | lead and engineer (lead 7, engineer 7) |
| Focused at the limit (3 journeys, 5 services), 3 weeks | 20 | 15 | lead and engineer (lead 10, engineer 10) |
| Full assessment, base | 45 | 30 | lead and engineer (lead 23, engineer 22) |
| Full assessment at the limit (5 journeys, 10 services, 2 tools) | 62 | 30 | lead, engineer and architect (lead 21.5, engineer 32.5, architect 8): the engineer is 2.5 days over, covered by a second engineer for 3 days; the limit is kept (owner, 2026-10-21) |
| Blueprint, base, 4 weeks | 17 | 20 | lead alone |
| Blueprint at the limit (5 journeys, 10 services, 2 tools), 4 weeks | 39.5 | 20 | lead, engineer and architect (lead 7, engineer 17.5, architect 15) |

The golden-journey proof and a Blueprint's instrumentation contract need someone who reads the
client's code; when the lead does not, the architect joins whatever the days say.

## Contingency

| Risk on our side | Add |
|---|---|
| Monitoring tool the team has not assessed before | 10 % of engineer days |
| Lead running their first assessment alone | 10 % of lead days (review time) |
| Code in a language or framework the team does not read | 2 engineer days |

## Check against the worked example

Larkfield (full assessment): 1 journey, 3 services, 1 tool, stage and production, 2 rounds,
golden-journey proof with a client developer. That is the base: lead 17, engineer 22,
architect 6 — 45 person-days: the lead full time and an engineer, the lead taking the architect's
days (lead 23 and engineer 22 of 30).

## Calibrating

Each engagement records actual days per role and phase in its knowledge base, next to the
estimate. After the pilot (and then every second engagement) the lead compares the two and
updates this file; the change goes into the kit's changelog with the engagements it rests on.
