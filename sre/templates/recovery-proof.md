# Recovery proof

Full SRE assessment, optional and priced; its weeks are in the
[calendar](../../method/getting-started.md#3-calendar). The client chooses one variant, run on
stage with the client's people:

- **Restore drill**: one tier-1 data store restored from a backup; RTO and RPO measured
  against their targets. The restore counts only from the backups the RPO relies on (the
  scheduled ones), never from a one-off copy made for another purpose, such as a migration.
- **Game day**: one tier-1 dependency failed on purpose; the detection, the degradation and
  the recovery observed.

The record is evidence for dimension 9 (restore tested) or 7 (game days on stage) of the
[maturity model](../maturity-model.md).

**Who runs it.** The client's people run the drill: they start the restore or inject the
fault, and stop it. The assessment team plans it with them, observes and records. The agent
never runs the drill and never changes the client's systems; it may draft the plan and this
record from the evidence.

**Design only.** Without stage access and a client operator, the proof is delivered as a
design and a checklist: fill "Scope" and "Plan", mark the record **design only**, and leave
"Run" and "Measured" as the checklist to run later. The proposal states that the proof is a
design, what would be run, and which targets it would check.

Engagement: [name] · Variant: [restore drill or game day] · Record status: [demonstrated or
design only] · Date: [date]

## Scope

| Variant | Service (`S-`) | Data store or dependency | Targets checked (`T-`) | Why this one | Decision that put it in scope |
|---|---|---|---|---|---|
| [restore drill] | [S-NN] | [data store, client's words] | [T-NN RTO, T-NN RPO] | [tier-1, restore never tried] | [D-NN] |

## Plan

| Item | Restore drill | Game day |
|---|---|---|
| What is failed or restored | [data store; backup used: kind, time taken, its age] | [dependency; how it fails: stopped, blocked, slowed] |
| Where | [isolated stage instance] | [stage; which callers are affected] |
| Expected | [restored data consistent; RTO and RPO within targets] | [alert fires and reaches the rota; degradation as designed (user impact: blocked · degraded · unaffected · unknown); recovery within target] |
| How it is measured | [RTO: start declared to service usable; RPO: last write in the backup to the failure point] | [time to detect, time to recover, from alert and log timestamps] |
| Stop condition and rollback | [who calls it off; how stage is put back] | [who calls it off; how the fault is removed] |

## Hand-over

When a test is agreed (a restore by a date, a `D-` row) and the assessment cannot run it — a
read-only agent never can — this section hands it to the client's people. It is filled when
the test is agreed, and the run fills "Run" and "Measured" below.

| Item | Holds |
|---|---|
| Who runs it | [client role and team; one accountable person] |
| Runbook draft | [the steps of the Plan, drafted from the evidence (`E-` ids); the operator corrects them before the run] |
| Done when | [the Measured rows filled and each read against its `T-` row; a stop or a failure recorded counts as a run] |
| What to record, and where | [start and end timestamps, the backup used and its age, the output or screenshots; in the engagement repository at [path], cited as a new `E-` id by whoever ran it] |
| Deadline | [date, from `D-NN`]; not run by then, the finding stays *untested* and the `V-` task or milestone names it |

## Run

| Run by | Observed by | Date and time window | Environment | Change reference | Recording |
|---|---|---|---|---|---|
| [client role, e.g. database operator] | [lead, SRE engineer] | [date, start–end] | [stage] | [client change or ticket id] | [screenshots or recording in the engagement repository] |

## Measured

| # | Target (`T-`) | Target value | Measured | Source (timestamps, query) | Evidence id | Result |
|---|---|---|---|---|---|---|
| 1 | [T-NN RTO] | [value] | [value] | [restore log, start and end] | [E-NNN] | within target / missed |
| 2 | [T-NN RPO] | [value] | [value] | [last write in the backup] | [E-NNN] | within target / missed |

For a game day the rows are time to detect, the degradation seen and time to recover.

## Acceptance

| Criterion | Evidence | Accepted by | Decision |
|---|---|---|---|
| [the data store restored on stage within its RTO and RPO] | [E-NNN] | [technical owner] | [D-NN] |

The deliverable's acceptance is recorded in [acceptance.md](../../templates/acceptance.md).

**Not shown, and why** — each gap with what would show it, its owner and where it goes (a
finding, a `V-` task or a roadmap item).
