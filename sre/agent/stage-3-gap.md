# Stage 3 — SRE gap

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 3`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You check the confirmed reliability targets against the live estate: per tier-1 service and
dimension, what the target asks, what is in place today, and the evidence for it. You draft;
a person confirms a sample of the current states, and the owners decide what the gaps mean.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md), [owner questions](../../tools/agent/rules/owner-questions.md)
and the [progress log](../../tools/agent/rules/progress-log.md), with N = 3. The boundaries
below are this stage's own and add to the common ones.

## Boundaries

- Read-only on the client's estate: delivery pipeline, incident tracker, paging tool,
  infrastructure as code, backup console, monitoring tool, exports. You may run read queries;
  you never restore, fail over, roll back, scale, send a test page or run a load test. A drill
  is run on a stage by the client's people, by agreement; you write the scenario, you do not
  run it.
- Count and classify incidents, postmortems and pages by their fields; quote no incident text.
- A window read for an event starts before it, with margin.

## Inputs

| Input | Where |
|---|---|
| Service catalogue, tiers confirmed at stage 2 | `sre/service-catalogue.md` |
| Target model and targets, confirmed at stage 2 | `sre/target-model.md`, `sre/targets/` |
| Inventory and baseline, confirmed at stage 1 | `sre/inventory.md`, `sre/baseline.md` |
| Exports made at stage 1 | `sre/exports/` |
| Read-only access to the pipeline, incident tracker, paging tool, infrastructure as code, backup console | [tokens, profiles or MCP servers; named, never pasted] |
| Completed readiness reviews and launch tickets, if any | [location, or none] |
| Readiness checklist | `sre/templates/readiness-review.md` |
| Open questions carried from stage 2 | `sre/target-model.md`, "Open questions" |
| Facts ledger, decision and risk registers, owner questions | instructions file |

## Method

Every step has its full rule and cases under its number in the
[stage 3 reference](reference/stage-3-reference.md) (in the kit, `sre/agent/reference/`).
Read it before the step; it binds as if it were here.

1. **Scope.** The format and the dimensions in scope. Focused: dimensions 1, 2, 4, 6 and 9;
   each other dimension is listed as not in scope and gets no rows. Combined: an overlap topic
   scored in observability is referenced, not gapped again.
2. **Targets.** Per dimension in scope, the `T-` rows and the target model's level; a default
   is used only when the row says so. A dimension without a target is an open question.
3. **Current state.** Per tier-1 service, or dimension-wide, what is in place today: `L-` rows,
   `B-` numbers, exports and read queries, each read an `E-3xx` evidence check.
4. **Gap rows.** One `G-` row per service × dimension, or dimension-wide: target, current with
   evidence, one implementation status.
5. **Monitoring, light.** Dimension 3 at the depth of its criteria only.
6. **Readiness.** Dimension 10: the last tier-1 launch checked against the readiness
   checklist.
7. **Open questions carried.** Each answered from evidence or "not established".
8. **Blind spots.** Each handed to the person for the risk register now.

## Output

The stage report, `sre/stage-3-gap.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log and the decision register travel with it as
files at a stated commit, cited, not reprinted. Nothing in the targets changes: a target the
gap shows unreachable is an open question for its owner, not an edit.

`sre/stage-3-gap.md`:

- first, five to seven results and their consequences;
- scope: the format, the dimensions in scope, each dimension not in scope by name, and in the
  combined format each overlap topic with the observability dimension it refers to;
- gap rows: id, service (`S-`) or dimension-wide, dimension, target (`T-`, or the target
  model's level), current with its evidence (`E-`, from `L-`, `B-` and exports), status
  absent / partial / implemented ([records.md](../../method/records.md)); counts that sum to
  the rows, per dimension;
- could not evidence: each target whose current state could not be read, with its owner
  question;
- the readiness check of the last tier-1 launch, item by item, when dimension 10 is in scope; it has no path of its own and
  lives in these notes;
- carried questions, blind spots;
- stage-4 candidates: each gap with the evidence a finding would cite; gaps whose fixes differ
  are separate candidates.

## Self-check before handing over

- [ ] Every row has a stable id and one status; the counts sum to the number of rows.
- [ ] Every gap row names its target and cites evidence from the estate or an earlier row in a
      stated window; nothing is implemented because a document or the code says so.
- [ ] No dimension not in scope has a row; each is listed by name.
- [ ] In the combined format, no overlap topic scored in observability is gapped again.
- [ ] Every baseline number compared with a target is labelled a reading, with its window;
      none is reported as met.
- [ ] No drill, restore, failover, test page or load test was run.
- [ ] No target, owner or threshold was changed; what the gap questions is an open question.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives, checks a sample of the gap rows,
chosen by them, through another path than the agent's query: the tool's own interface, a
record the owner shows, or a query they write. Checks the readiness check of the last tier-1
launch with its service owner. Agrees the owners of the blind spots and registers them.
Decides which scenarios are run, where and by whom. Confirms the gap as the input to stage 4,
or returns it.
