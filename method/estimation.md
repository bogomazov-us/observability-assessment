# Estimation model

How to estimate an engagement in person-days by role without the authors. The limits per format
are in [offerings.md](../offerings.md); this model turns a scope inside those limits into effort,
and checks that the effort fits the calendar. Prices are not part of the kit: a day rate belongs
to the contract, not the method.

> **Starting values.** The numbers below are a first calibration, not measured actuals; the lead
> allocations and the per-journey increment were set by the owner on 2026-10-21. Record actual
> days per phase on every engagement (see "Calibrating") and replace them after the pilot.

## How to estimate

1. **Fix the scope** in the units below: journeys, services, monitoring tools, environments,
   review rounds. Anything above the format's limit is a change request, not a bigger estimate.
2. **Take the base** for the format: effort for the smallest scope it is sold for.
3. **Add the increments** for each unit above the base.
4. **Check capacity:** each role's days must fit the calendar at that role's allocation. If they
   do not, add a person or lengthen the calendar — never compress the evidence work.
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

| Role | Days available = working days × allocation |
|---|---|
| Lead | at most half time: full assessment 30 × ½; focused 10–15 × ½ |
| Observability engineer | calendar × 1 |
| Architect | as named in the proposal, usually part time |

If a role's days exceed what is available, add a person or lengthen the calendar. With these
starting values:

| Scope | Lead | Obs. engineer | Fits |
|---|--:|--:|---|
| Full assessment, base | 17 of 15 | 22 of 30 | no: lead 2 days over |
| Full assessment at the limit (5 journeys, 10 services, 2 tools) | 21.5 of 15 | 32.5 of 30 | no: lead 6.5 days over, engineer 2.5. The limit is kept (owner, 2026-10-21); the engineer's excess is a second engineer for 3 days. How the lead's excess is covered is open |
| Focused, base, 2 weeks | 6 of 5 | 7 of 10 | lead over by 1 day: quote 3 weeks, or the lead at ⅗ |
| Focused at the limit (3 journeys, 5 services), 3 weeks | 8 of 7.5 | 10 of 15 | lead over by half a day: within contingency |

## Contingency

| Risk on our side | Add |
|---|---|
| Monitoring tool the team has not assessed before | 10 % of engineer days |
| Lead running their first assessment alone | 10 % of lead days (review time) |
| Code in a language or framework the team does not read | 2 engineer days |

## Check against the worked example

Larkfield (full assessment): 1 journey, 3 services, 1 tool, stage and production, 2 rounds,
golden-journey proof with a client developer. That is the base: lead 17, engineer 22,
architect 6 — 45 person-days. The engineer and the architect fit six weeks; the lead, at half
time, is 2 days over (capacity check).

## Calibrating

Each engagement records actual days per role and phase in its knowledge base, next to the
estimate. After the pilot (and then every second engagement) the lead compares the two and
updates this file; the change goes into the kit's changelog with the engagements it rests on.
