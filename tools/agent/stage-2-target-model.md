# Stage 2 — target model

*Task prompt. Assemble it with `tools/agent/prompt.sh 2`, which appends the rule files it
names, and paste the result as is; replace the bracketed values.*

---

You draft the target model of an observability assessment: the journeys in scope, decomposed
into business functions, and the error taxonomy of each function. You draft; a person confirms.

## Rules

The rule files in [`rules/`](rules/) apply to this stage: [boundaries](rules/boundaries.md),
[evidence](rules/evidence.md), [claims](rules/claims.md),
[owner questions](rules/owner-questions.md) and the [progress log](rules/progress-log.md),
with N = 2. The boundaries below are this stage's own and add to the common ones.

## Boundaries

- Read-only. You read the code checkout, the captures and the exports; you never write to the
  client's code, monitoring configuration or tickets.
- Every function and every taxonomy row cites its source: a captured request (capture file and
  entry), a route in code (file:line), or an error handler (file:line).

## Inputs

| Input | Where |
|---|---|
| Journeys in scope, as agreed at kick-off | `kickoff-note.md`, decision register |
| Sanitized captures of each journey ([what is captured](../../templates/data-request.md#har-captures-per-journey)) | `captures/` |
| Code checkout (read-only) | [path] |
| Code scan report (stage 1) | `scan.md` |
| Estate export by object class (stage 1, confirmed) | `exports/` |
| Facts ledger | instructions file |
| Spec skeleton | `templates/spec-set/observability-spec.yml` |

## Method

Every step but 2 has its full rule, cases and tables under its number in the
[stage 2 reference](reference/stage-2-reference.md) (in the kit, `tools/agent/reference/`).
Read it before the step; it binds as if it were here.

0. **Sources agree first.** Where the sources of requirements disagree, stop and hand the
   person a table; draft only after the owner has reconciled them.
1. **Names first.** Keep the client's names for the `glossary`. Group each journey's captured
   calls into business functions, one per business step that can fail on its own.
2. Confirm each function's route in code; note the service that handles it.
3. Read each function's error path in code, refusals inside HTTP 200 included.
4. Classify each row by the error class set in [records](../../method/records.md#status-sets).
5. If one business attempt spans several functions, draft the attempt model.
6. **Success is checkable** by a browser or API assertion.
7. **Reconciliation is per operation type**, the evidence linked to this operation, with
   acceptance scenarios.
8. **Layers are mapped, not merged**, by exact ids both ways.
9. **Names have a history**: a legacy → current table; live, historical and planned apart.
10. **No traffic is not missing telemetry**: three window states and a health signal.
11. **Readings are marked**, cited and listed.
12. **Impact on the person**: a `user_impact` per taxonomy row.
13. **The budget in the SLI's own units**; burn-rate alerts in shadow.
14. **Telemetry fails too**: a table of its failures.
15. **Volume decides the window.**

## Output

The stage report, `stage-2-notes.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log, the decision register and the full spec
travel with it as files at a stated commit, cited, not reprinted. Field rules and columns are
in the [reference, Output](reference/stage-2-reference.md#output).

1. `spec/observability-spec.yml`, from the skeleton: `journeys`, `taxonomy` and `glossary`
   filled, `signals` at `to_build`, `slos` and `alerts` as placeholders or `proposed`, a
   source comment on each row.
2. `stage-2-notes.md`, around the resulting contract, not the rounds that produced it: the
   function map, a table per journey, "Open questions".

## Self-check before handing over

- [ ] `python3 tools/speclint.py spec/observability-spec.yml` reports no errors; only SL016
      placeholder warnings remain, and the notes bound that result by claims item 18.
- [ ] Every function in scope is present, with a requirement source and its current state.
- [ ] Every journey, function and attempt has its glossary entry, under its name (no SL021,
      SL022 or SL023).
- [ ] Every SLO and alert is `proposed`.
- [ ] Every function's success names its states, the empty case and the time bound, or an open
      question for the owner.
- [ ] Every ambiguous outcome is reconciled per operation type, with acceptance scenarios; the
      evidence links the change to the operation; composite operations are settled per
      mutation.
- [ ] Count SLIs separate no traffic from telemetry unknown; no valid window is "no estimate".
- [ ] Every value filled in where a decision left it open is marked as a reading.
- [ ] Every taxonomy row has a `user_impact`; which functions get their own SLO is a question
      for the owner.
- [ ] Every SLO states its budget in the SLI's units and what it is not; burn-rate alerts are
      drafted in shadow; the policy actions are open for the owner.
- [ ] The telemetry failure table covers emitter, exporter, ingestion, labels, recording rules,
      evaluation and delivery.
- [ ] Every SLO and alert has its volume per window; insufficient ones are marked.
- [ ] When an owner's decision changed a definition, every source that stated the old one was
      searched and updated; none still states it. A source outside your write paths (the
      client's own design document) is listed for the person as a follow-up change, not left
      silent.
- [ ] When a later decision changed the basis of an earlier one (a window, a unit, a cadence),
      every value derived from the earlier one was re-derived and returned to `proposed`
      with a question, not carried over.
- [ ] Every function and taxonomy row has a source comment.
- [ ] No class was given without reading the code path; unread ones are `unknown`
      (claims item 1).
- [ ] Every ambiguous row has a reconciliation path or an open question.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../../method/getting-started.md#3-calendar) gives: each function against a captured request and the code; each class against the code path;
which proposed targets, owners and thresholds the client has agreed (only those become
`confirmed`). The confirmed rows go into the facts ledger with their source; the rest stay
assumptions with an owner and a date.
