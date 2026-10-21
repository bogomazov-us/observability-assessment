# Stage 2 — target model

*Task prompt. Paste as is; replace the bracketed values.*

---

You draft the target model of an observability assessment: the journeys in scope, decomposed
into business functions, and the error taxonomy of each function. You draft; a person confirms.

## Boundaries

- Read-only. You read the code checkout, the captures and the exports; you never write to the
  client's code, monitoring configuration or tickets.
- You write only inside the engagement repository, in the files named under "Output".
- Every function and every taxonomy row cites its source: a captured request (capture file and
  entry), a route in code (file:line), or an error handler (file:line).
- Nothing you write is a fact. It enters the facts ledger as an assumption.
- When a source is missing or contradicts another, stop on that item: write it under "Open
  questions" and go on with the rest. Never fill a gap with a plausible guess.
- No client data leaves the engagement repository.
- Read only the paths and systems listed under "Inputs". Anything else is out of scope: name
  it as an open question, do not open it.
- A question addressed to the owner or the client stays open: you never decide it, even when
  one answer looks obvious. You may list candidate answers, marked as candidates.

## Inputs

| Input | Where |
|---|---|
| Journeys in scope, as agreed at kick-off | [facts ledger or kick-off note] |
| Sanitized captures of each journey | [captures folder] |
| Code checkout (read-only) | [path] |
| Code scan report (stage 1) | [scan.md] |
| Estate export by object class (stage 1, confirmed) | [export folder] |
| Facts ledger | [facts ledger] |
| Spec skeleton | `templates/spec-set/observability-spec.yml` from the kit |

## Method

0. Find every source of requirements: the journey model agreed at kick-off, journey or
   function definitions in the code or the product documents, the code itself. If they
   disagree (ids, the cut into functions, what success means, what is built), stop and hand the
   disagreements to the person as a table — source, what it says, file:line. Draft only after
   the owner has said how they are reconciled: one source governs, or all are brought to one
   current state.
1. For each journey, list the calls a customer's attempt makes, in order, from the captures.
   Group them into business functions: one function per business step that can fail on its
   own (reserve, authorise, place), not one per endpoint.
2. Confirm each function's route in code; note the service that handles it.
3. For each function, read the error path in code: every code or condition it can return,
   with its HTTP status. Watch for refusals returned inside HTTP 200.
4. Classify each row: expected, failure, caller_defect, ambiguous, unknown, or none (looked like
   an error, the operation took effect). Ambiguous means the business outcome is unknown —
   give its reconciliation path or mark it open. A code that means different things in
   different contexts gets one row per context, or stays unknown.
5. If one business attempt spans several functions, draft the attempt model: which operation
   decides the outcome, after how long an attempt with no result is ambiguous.
6. **Success is checkable.** Write each function's success so that a browser or API assertion
   can decide it: the states that count (success, degraded, failure), what an empty result
   means, and the time bound. Where the owner has not decided one of these, it is an open
   question for the owner, not a default.
7. **Reconciliation is per operation type.** For each ambiguous outcome say, per create,
   update and delete, what evidence proves the operation took effect, and whether the outcome
   of the attempt and of its audit record are settled together. "Run it on a schedule" is not a
   reconciliation path. The evidence must link the change to **this** operation — its key, or a
   stamp it wrote and kept: a timestamp, equal fields or a deletion that any other writer (a
   person in the source of truth, an import) could have produced proves the state, not the
   operation, and leaves the outcome undetermined. An operation of several mutations is
   settled per mutation, and succeeds only when every one is proven. Draft the acceptance
   scenarios: response lost after the operation landed (per type), the source of truth
   unavailable during reconciliation, the record changed by someone else, a composite
   operation whose first mutation landed and second did not, and a re-run that leaves the
   result unchanged.
8. **Layers are mapped, not merged.** When the client keeps business functions apart from
   monitoring functions (or synthetic steps apart from both), keep the layers and draft an
   explicit mapping. The mapping is checked by exact ids in both directions — every monitoring
   function is mapped, every mapped id exists — not by searching text. Metric ids and function
   ids are kept apart. A complete mapping says the references are complete, not that the
   signals work.
9. **Names have a history.** Where an alert or metric has several names across sources, draft
   a legacy → current table with the state of each (live, removed, never existed); do not
   pick a spelling. A list of alerts or checks separates live (seen in the estate),
   historical (removed, when) and planned (required, not built); a planned one is never listed
   as running.
10. **No traffic is not missing telemetry.** An SLI over counts has three window states: traffic
    present, no traffic (confirmed by a telemetry health signal), telemetry unknown. A window
    with telemetry unknown is neither good nor valid and is counted apart; with no valid
    window the SLO reads "no estimate", not 100 %. Draft the health signal.
11. **Readings are marked.** Where an owner's decision leaves a parameter open and you fill it
    from another source, mark the value as your reading, cite the source, and list it for
    the owner. A decision fixes what was decided; it does not make weak evidence sufficient,
    and the reviewer still checks the evidence.
12. **Impact on the person.** Give each taxonomy row a `user_impact`: blocked, degraded,
    unaffected or unknown — what the person can still do, which the class alone does not say.
    A response that succeeds technically but leaves the journey wrong (an empty list that
    should not be empty) is not unaffected. Not every function needs its own SLO: propose
    which do and which are covered by another, as a question for the owner.
13. **The budget in the SLI's own units.** For each SLO compute the error budget in what the
    SLI counts — bad requests, or bad windows of a window-share SLI — and say what it is not
    (a window-share budget is not minutes of downtime nor a share of failed requests). Draft
    burn-rate alerts, a fast and a slow pair, in shadow. Draft the error-budget policy as a
    skeleton: what happens at which share spent is the owner's decision.
14. **Telemetry fails too.** Draft a table of how the telemetry itself fails: the emitter (no
    series), the exporter or collector (dropped exports), ingestion (lag, rejects), labels
    (drift, cardinality), recording rules, alert evaluation, notification delivery. For each:
    how it would show, which signal detects it (live, with the inventory row, or to build),
    and whether today it would read as "no traffic" or "OK".
15. **Volume decides the window.** For each SLO and alert, estimate the volume per evaluation
    window from the inventory (requests, beacons, synthetic cadence). Where a percentile or a
    short window has too few events to mean anything, mark it insufficient and give the owner
    candidates: a longer window, a count instead of a percentile, a denser synthetic.

## Output

1. `docs/observability/observability-spec.yml`, from the skeleton: `journeys` and `taxonomy`
   filled; for each function one `signals` entry with state `to_build` and a placeholder name;
   `slos` and `alerts` left as skeleton placeholders, or drafted with `status: proposed`. A
   YAML comment on each row cites its source. For every function in scope:
   - a stable id (keep the ids of the client's journey model when it has them) and
     `requirement`, the source of the requirement;
   - `current`: what exists today, citing the confirmed inventory by row id (`L-07`), never by
     line number, kept apart from the target; unknown stays `unknown`;
   - a signal is `live` only with production evidence from the inventory.
   No target, owner or threshold is `confirmed` by the agent. A field of the engagement's own
   is prefixed `x_` (SL019).
2. `stage-2-notes.md`: a table per journey (function, route, service, source), then "Open
   questions" (item, what is missing, who can answer).

## Progress log

Keep `progress/stage-2.md` in the engagement repository while you work, so a person can see
where the stage is without asking you. Its first line is the plan: the steps, numbered, and
their count. Then one line when a step starts and one when it ends, one per commit with its
hash, and one when you stop on something:

```
14:05 plan — 6 steps: 1 sources, 2 functions, 3 error paths, 4 taxonomy, 5 lint, 6 notes
14:07 step 1/6 sources — started
14:31 step 1/6 sources — done; disagreements handed to the person
14:32 step 2/6 functions — blocked: no capture for J3 (open question 4)
14:40 commit 3f2a1c9 — functions J1, J2
```

Append, never rewrite. Times are local, with the time zone once at the top. The log is
committed with the stage's output; the first and last times are the agent's elapsed time.

## Self-check before handing over

- [ ] `python3 tools/speclint.py docs/observability/observability-spec.yml` reports no errors;
      only SL016 placeholder warnings remain. Say in the notes that this shows the spec is
      structurally complete, not that it is right.
- [ ] Every function in scope is present, with a requirement source and its current state.
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
      searched and updated; none still states it.
- [ ] Every function and taxonomy row has a source comment.
- [ ] No class was given without reading the code path; unread ones are `unknown`.
- [ ] Every ambiguous row has a reconciliation path or an open question.
- [ ] Nothing was written outside the engagement repository.
- [ ] The progress log ends with the last step done and the last commit.

## What the person confirms

Each function against a captured request and the code; each class against the code path;
which proposed targets, owners and thresholds the client has agreed (only those become
`confirmed`). The
confirmed rows go into the facts ledger with their source; the rest stay assumptions with an
owner and a date.
