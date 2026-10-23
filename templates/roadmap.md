# Roadmap template

Each milestone closes with a **demonstrated** result and has **one accountable owner**. Client
decisions stay with the client role that takes them; the accountable owner makes sure they are
asked and answered in time. Every milestone names what it delivers.

Two shapes, by where the estate is:

- **A. From the stage-6 plan,** for an estate already in production. The milestones group the
  plan's work items along its per-alert paging gates. This is the usual case after a full
  assessment.
- **B. Assessment to BAU,** when the assessment comes before a launch and the milestones lead
  to go-live and handover.

## A. From the stage-6 plan

**Inputs:** the stage-6 plan (`W-` work items, `V-` verification tasks, their order and the
gate sequence), the `REC-` cards, the owner's accepted decisions, the stage-5 profile.

**Rules**

1. **A milestone holds what one gate needs,** in the plan's order: the first alert's gate
   first, then the next. Targets that no gate waits on go into a milestone of their own at the
   end. Split a gate in two when its first half needs neither a missing environment nor an open
   decision: that half can start now.
2. **Every `W-` item sits in exactly one milestone.** An item several gates share goes into the
   first milestone that needs it; later milestones depend on it and do not repeat it. Check
   this with a script and say so in the scope.
3. **Dependencies point only to earlier milestones.** Name the critical path, and the
   milestones that can run beside it when the executor has the room.
4. **The exit result is checkable:** a recorded test with its date, or a configuration read.
   "Work done" is not an exit result. A production event is a later validation, not a closing
   condition.
5. **Confirmed is not fixed.** A `REC-` is delivered only when the exit results of all its
   `W-` items are recorded; the roadmap says in which milestone each closes. A milestone built
   on findings that are still assumptions delivers no `REC-`.
6. **One accountable role per milestone;** the items keep the roles the plan gives them. Names
   follow once staffing is known.
7. **No dates until the executor's availability is known.** Until then the document status is
   "draft; no dates". Effort is a range of engineer-days from a size mapping stated in the scope
   (for example S, M, L to day ranges); the mapping is an assumption and says so. Sizes are not
   durations, and the kit's estimation model sizes the assessment, not its implementation. If
   the practice takes part in the implementation, add its lead and review time as separate
   lines.
8. **Say what each milestone moves on the profile:** the dimensions, and the blocker each one
   removes. Do not claim a level change that one milestone alone cannot show.
9. **Say what each milestone changes in the architecture,** so the target picture can be drawn
   per milestone and the reader sees where each piece of work lands.
10. **State the limits that hold for every milestone once,** at the top: for example, no alert
    pages while one responsible person carries it, or no urgent notification while the
    independent channel is undecided.
11. **Verification tasks** (`V-`) go into a milestone or a track of their own. A verdict they
    produce can change a later milestone; say which.
12. **Open decisions are dependencies,** each with its decider. The roadmap does not decide
    them.

**Structure:** 1 Result (the milestones in one paragraph, the total effort range, the limits of
rule 10, then checked / main limits / next step); 2 Scope and method (what is in and out, the
grouping rule, the size mapping, the owner roles, the check script); 3 Main results (the two
tables below); 4 Records (one card per milestone); 5 Decisions and open questions; 6 Conditions;
changes in this version.

| Milestone | Items, and the `REC-` they deliver | Exit result (checkable) | Effort, engineer-days |
|---|---|---|---|
| M-1 · [the first half of gate A] | W-.., W-.. · REC-.. | [recorded test or configuration read] | [range] |
| M-2 · [gate A] | W-.., W-.. · REC-.. | […] | [range] |

| Milestone | Accountable | Depends on | Moves on the profile | Architecture delta |
|---|---|---|---|---|
| M-1 | [role] | none; [decision] | [dimension: blocker removed] | [components or paths that change] |
| M-2 | [role] | M-1; [decision, open] | […] | […] |

The check of rule 2, for a roadmap whose first table lists items in its second column:

```
for i in $(seq -w 1 <n>); do
  awk -F'|' '/^\| M-[0-9]+ /{print $3}' roadmap.md | grep -o "W-$i" | wc -l
done            # every line must print 1
```

## B. Assessment to BAU

| Milestone | Typical offset | Done when (demonstrated) | Accountable |
|---|---|---|---|
| M0 — Blocking decisions | week 1–2 | Version / scope of what goes live chosen; back-end changes estimated and in a sprint; licence or budget for business events confirmed or fallback chosen; test users requested; tier-1 journeys and SLO owners approved at a product review | Lead |
| M1 — Technical visibility on stage | +1 week | RUM, error adapter, source maps; agent on the active back end; a trace from a browser action to the outbound downstream call; ≥95% of calls linked, measured on a harness run | Observability engineer |
| M2 — Business outcomes observable | +1 week | Refusals in 200 responses recognised; IDs, outcome, error class on every critical response; error codes classified one by one; observability section in the story template | Architect |
| M3 — Measurements validated | +1 week | SLI queries verified in the tool; worked examples reproduced on stage (retries, missing IDs, late results); telemetry health; synthetics | Observability engineer |
| M4 — Operational acceptance (go/no-go) | +1 week | Dashboard with baselines and control limits; P1 detectors in shadow with runbooks; release harness on every release; test P1 delivered, acknowledged, escalated; hypercare rota | Lead |
| M5 — Delivery-ready | +1–2 weeks | Production configuration checked; test traffic separated; contacts and access ready | Client delivery lead |
| M6 — Live baseline | go-live + 7 days | Baseline; thresholds reviewed; SLO targets confirmed by product; weekly firing review | Observability engineer |
| M7 — Handover to BAU | when criteria met | ≥80% of firings actionable; critical break detected within the agreed time; paging through the client's on-call | Client operations |

**Critical path:** M0 → back-end contract (M2) → proof the calculations are right (M3) → M4.

**Go/no-go decision:** Go · Go with exceptions (each limitation written down with a compensating
measure, an owner and a date) · No-go (the key outcome cannot be determined reliably, or a
critical signal does not reach the person on duty).

**Name the schedule risk and its fallback** — usually the back-end change; the fallback is a
coarser SLI from server spans, taken to go/no-go as an exception.

## Milestone card

For the tracker, in either shape:

```
Milestone:     M-2 — Gate A for the first alert
Accountable:   <role; a name once staffing is known>
Date:          <date, or "none until the executor's availability is known">
Depends on:    M-1; <decision and its decider>
Items:         <W- ids>          Delivers: <REC- ids, or none>
Done when:     <exit result: a recorded test or a configuration read>
Effort:        <engineer-day range, from the stated size mapping>
Moves:         <dimensions, blockers removed>
Arch. delta:   <what changes>
Evidence:      <test record, query output, run id>
Status:        not started / in progress / demonstrated
```
