# SRE assessment

The second assessment type of the kit. It asks whether the client's services stay reliable,
and how they recover when they do not. It covers observability lightly, in one dimension; the
[observability assessment](../offerings.md) is the deep one. Sell either type alone, or both
as the combined format.

The method, records, evidence rules, report model, review and acceptance are the kit's core.
This page holds what is SRE's own: formats, calendar, estimation and the combined format. The
model is [maturity-model.md](maturity-model.md).

## Formats

| | **Focused** | **Full** | **Combined** |
|---|---|---|---|
| Question answered | How reliable are the critical services, and what do we fix first? | The same, across every dimension, with recovery proven if the client wants it | Both questions, in one report |
| Duration | 2–3 weeks | 6 weeks | 6 weeks (both full) or 3 weeks (both focused) |
| Inputs from the client | Read-only access to the delivery pipeline, infrastructure as code, incident tracker, paging tool and backup console; the SRE rows of the data request; 3–4 interviews | The same; 5–8 interviews. Recovery proof: stage access and the client's people to run it | The inputs of both types |
| Outputs | Baseline numbers (`B-`); profile of the mandatory dimensions; top findings with evidence; roadmap with milestones and effort ranges | The same for all 10 dimensions; the recovery proof record when taken | One report: shared summary, findings and roadmap; a profile chapter per type |
| Dimensions | 1, 2, 4, 6, 9 mandatory; the rest "not in scope" (not the same as "not scored") | All 10 | Both models; overlaps scored once ([below](#combined-format)) |
| Done when | Report accepted; decision on the next step taken ([acceptance](../templates/acceptance.md)) | The same | The same |
| Scope limits (starting values; beyond them is a change request) | Up to 5 tier-1 services, 1 delivery pipeline system, 1 cloud or hosting estate, production read-only, 1 review round | Up to 10 tier-1 services, 2 pipeline systems, 2 estates, stage and production, 2 review rounds | The limits of both, capped by the calendar |
| Roles | Lead full time; SRE engineer and architect by scope ([estimation](#estimation), capacity check) | The same; the architect carries resilience, capacity and recovery | Both engineers; one person may be both when the days fit (the capacity check decides) |
| Templates | Core: intake-questionnaire, data-request, kickoff-note, interview-guide, finding, report, roadmap. SRE: [service-catalogue](templates/service-catalogue.md), [reliability-targets](templates/reliability-targets.md), [readiness-review](templates/readiness-review.md), [data-request](templates/data-request.md) and [interview-guide](templates/interview-guide.md) (rows added to the core ones) | The same; recovery proof: [recovery-proof](templates/recovery-proof.md) | Both types' templates |
| Options | — | Recovery proof | Recovery proof and/or [Operationalize](../offerings.md#full-assessment-six-weeks) |

The unit of scope is a tier-1 service: a service in scope that serves a critical journey, with
the tiers agreed in dimension 1. The roadmap may recommend the other assessment type.

**Recovery proof** (full format, priced option; it takes the place of the observability
golden journey proof). On stage, with the client's people, by agreement, the client's choice of:
- **Restore drill**: one tier-1 data store restored, then RTO and RPO measured against the
  targets.
- **Game day**: one tier-1 dependency failure injected, then detection, degradation and
  recovery observed.

The client's people run it; the agent never does. Without stage access it is delivered as a
design and a checklist, and the proposal says so. Record: [recovery-proof](templates/recovery-proof.md).

## Calendar

As in the [core calendar](../method/getting-started.md#3-calendar). "Stage": the SRE stage's
state by the end of the week. "Client delivers": the SRE data request's "Needed by". SRE has
no playbook column; its phases are:
1 Align & baseline, 2 Catalogue & targets, 3 Diagnose, 4 Recovery proof, 5 Executive roadmap.

**SRE full format, six weeks**

| Week | Offering phase | Stage | Meetings | Client delivers |
|---|---|---|---|---|
| 1 | 1 Align & baseline | 1 handed over | Kick-off; interviews begin | Read-only access; incident, paging (with the rotation) and deploy exports; architecture |
| 2 | 2 Catalogue & targets | 1 confirmed; 2 handed over and confirmed | Interviews end (5–8 in all); targets review with the owners | Postmortems and action items, backup job history and restore records |
| 3 | 3 Diagnose | 3 handed over and confirmed | — | Capacity metrics and quotas, load-test reports; owner answers that block stages 3–4 |
| 4 | 3 Diagnose; 4 Recovery proof | 4 handed over before the preview; confirmed after it | Findings preview, which sends the verdict batch | Stage access and the client's people, if the proof is in scope |
| 5 | 4 Recovery proof; 5 Executive roadmap | 5 confirmed; 6 handed over with its confirmation batch | Recovery proof run; review round 1 | Verdicts on the batch |
| 6 | 5 Executive roadmap | 6 confirmed | Review round 2; read-out | The next-step decision |

**SRE focused format, two to three weeks.** Every data-request item is needed in week 1.
Skipped: the recovery proof, the separate targets review (targets come from the interviews),
review round 2. In two weeks, weeks 2 and 3 run as one.

| Week | Stage | Meetings |
|---|---|---|
| 1 | 1 confirmed; 2 handed over | Kick-off; 3–4 interviews |
| 2 | 2 and 3 confirmed; 4 handed over | Findings preview |
| 3 | 4, 5 and 6 confirmed | Review round; read-out |

**Combined format.** Each type keeps its own calendar's stage weeks, in separate sessions;
the meetings are held once for both. Focused: the focused tables of both types, three weeks.

| Week | Offering phase | Stage | Meetings | Client delivers |
|---|---|---|---|---|
| 1 | 1 Align & baseline | 1 handed over, per type | One kick-off; one interview series for both types' owners | Week-1 rows of both data requests |
| 2 | 2 Observe & trace; 2 Catalogue & targets | 1 confirmed; 2 handed over and confirmed, per type | Interviews end; journey walk-through; targets review | Week-2 rows of both |
| 3 | 3 Diagnose | 3 handed over and confirmed, per type | — | Week-3 rows of the SRE data request; owner answers that block stages 3–4 |
| 4 | 3 Diagnose; 4 Golden journey proof; 4 Recovery proof | 4 handed over before the preview, per type | One findings preview and verdict batch | Stage access and the people for the proofs in scope |
| 5 | 4 the proofs; 5 Executive roadmap | 5 confirmed; 6 handed over, per type | Proof demonstrations; review round 1 | Verdicts on the batch |
| 6 | 5 Executive roadmap | 6 confirmed, per type | Review round 2; read-out | The next-step decision |

## Estimation

The [estimation model](../method/estimation.md) applies: its steps, staffing rule and
calibration. Below are SRE's own numbers.

> **Starting values.** Every number in this section is a first guess, not a measured actual.
> It is calibrated on the test run (the first SRE engagement) and then as in the model's
> "Calibrating".

Base scope: **3 tier-1 services, 1 delivery pipeline system, 1 cloud or hosting estate**;
environments and review rounds as the format states. Assumptions: the exports in the SRE data
request exist; the client's people run the recovery proof. The architect carries more than in
observability: dependencies and tiers, resilience, capacity, backup and DR.

**Focused (2–3 weeks; production read-only; 1 review round; dimensions 1, 2, 4, 6, 9)**

| Phase | Lead | SRE engineer | Architect |
|---|--:|--:|--:|
| Align & baseline: document review, intake, interviews, exports | 2 | 2 | 0 |
| Catalogue & targets: tiers, dependencies, targets from the interviews | 1 | 1 | 0.5 |
| Diagnose: findings, maturity of the mandatory dimensions | 1 | 2 | 1 |
| Report, roadmap, one review round | 2 | 1 | 0.5 |
| **Base** | **6** | **6** | **2** |

**Full (6 weeks; stage and production; 2 review rounds; all 10 dimensions)**

| Phase | Lead | SRE engineer | Architect |
|---|--:|--:|--:|
| 1 Align & baseline | 4 | 3 | 0 |
| 2 Catalogue & targets | 2 | 4 | 1 |
| 3 Diagnose | 3 | 6 | 3 |
| 5 Executive roadmap, two review rounds | 5 | 2 | 2 |
| **Base** | **14** | **15** | **6** |
| Option: 4 Recovery proof, restore drill or game day (stage access and the client's people) | +1 | +4 | +2 |
| Option: 4 Recovery proof as a design and a checklist (no stage access) | +1 | +1 | +2 |

**Increments per unit above the base**

| Unit | Lead | SRE engineer | Architect | Applies to |
|---|--:|--:|--:|---|
| Each tier-1 service after the third | 0.5 | 1 | 0.5 | focused and full |
| Second pipeline system | 0.5 | 2 | 0 | full |
| Second estate (cloud or hosting) | 0.5 | 2 | 1 | full |
| Extra review round (by change request) | 1.5 | 0 | 1 | focused and full |

**Capacity check.** Roles are added in the model's order: lead alone; lead and SRE engineer;
then the architect; a second engineer for a few days.

| Scope | Total days | Calendar | Staffing that fits |
|---|--:|--:|---|
| Focused, base, 3 weeks | 14 | 15 | lead alone |
| Focused, base, 2 weeks | 14 | 10 | lead and engineer (lead 8 with the architect's 2, engineer 6) |
| Focused at the limit (5 services), 3 weeks | 18 | 15 | lead and engineer (lead 10 with the architect's 3, engineer 8) |
| Full, base | 35 | 30 | lead and engineer (lead 20 with the architect's 6, engineer 15) |
| Full, base, with the recovery proof | 42 | 30 | lead and engineer (lead 23 with the architect's 8, engineer 19) |
| Full at the limit (10 services, 2 pipeline systems, 2 estates) | 55 | 30 | lead and engineer (lead 29 with the architect's 10.5, engineer 26) |
| Full at the limit, with the recovery proof | 62 | 30 | lead, engineer and architect (lead 19.5, engineer 30, architect 12.5) |

Resilience, capacity and recovery design need someone who reads the client's architecture
and infrastructure code; when the lead does not, the architect joins whatever the days say.

**Combined format.** Combined = observability base + SRE base − the shared work, counted
once. Each type keeps its own units and increments: journeys for observability, tier-1
services for SRE. Options are priced from their own rows.

| Shared work, counted once | Focused | Full |
|---|---|---|
| Align: one kick-off, one interview series | lead −1 | lead −2, SRE engineer −1 |
| Summary, roadmap and decision request | lead −1 | lead −2, architect −0.5 |
| One set of review rounds | lead −1 | lead −2, architect −1 |
| **Less** | **−3** | **−8.5** |

Worked at both base scopes:

| Format | Lead | Obs. engineer | SRE engineer | Architect | Total | Staffing that fits |
|---|--:|--:|--:|--:|--:|---|
| Focused, 3 weeks: 14 + 14 − 3 | 9 | 7 | 6 | 3 | 25 | lead and one engineer for both types (lead 12 with the architect's 3, engineer 13 of 15) |
| Full: 39 + 35 − 8.5 | 23 | 19 | 14 | 9.5 | 65.5 | lead, both engineers and the architect (the engineers' 33 days do not fit one person) |

**Contingency** (SRE rows; the model's rows also apply)

| Risk on our side | Add |
|---|---|
| Delivery pipeline, incident or paging tool the team has not assessed before | 10 % of engineer days |
| A tool known at proposal time to have no export: incidents, pages or deploys collected by hand | 2 engineer days per source |

## Combined format

One engagement, both types, one report. Adding the SRE type to an observability engagement
later is the combined format too, run in sequence: the shared sequences continue.

| Shared (once) | Per type |
|---|---|
| `summary.md` and `manifest.txt`; findings (one `F-` sequence); owner questions (one `Q-` sequence); facts, decisions and risks registers | State file and gates (`engagement-state.yml`, `sre/engagement-state.yml`) |
| Kick-off, interviews, findings preview, review rounds, read-out | Stage prompts, run in separate sessions; two types are never in one prompt |
| Summary, roadmap and decision request | `maturity.yml` and `sre/maturity.yml`, a profile chapter each |
| Align and the review rounds, counted once in the estimate | Data request and interview rows, templates, estimation rows |

**Overlap rule.** A topic in both models is scored once, in the dimension with the deeper
criteria; the other profile refers to it and adds only what is its own. The topics are in
the [overlap table](maturity-model.md#overlaps-in-the-combined-format). Check both files
together before the profile chapters go out:

```
tools/maturity.py --pair maturity.yml sre/maturity.yml
```

It fails when a topic is scored (or partial) in both files (P01), or when a `refers_to`
points at a dimension the other file does not score (P02). See [maturity.md](../tools/maturity.md).

## Setup and prompts

```
# SRE only
tools/agent/init-engagement.sh --repo REPO --code CODE --assessment sre
# combined
tools/agent/init-engagement.sh --repo REPO --code CODE --assessment observability --assessment sre
# stage N of the SRE type (no flag: observability)
tools/agent/prompt.sh --assessment sre N [OUT.md]
```

SRE files go in `sre/` under the working folder; the paths are in the
[agent README](../tools/agent/README.md#artifact-paths). In the combined format, run each stage
once per type.
