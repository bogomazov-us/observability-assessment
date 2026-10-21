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
- [ ] When an owner's decision changed a definition, every source that stated the old one was
      searched and updated; none still states it.
- [ ] Every function and taxonomy row has a source comment.
- [ ] No class was given without reading the code path; unread ones are `unknown`.
- [ ] Every ambiguous row has a reconciliation path or an open question.
- [ ] Nothing was written outside the engagement repository.

## What the person confirms

Each function against a captured request and the code; each class against the code path;
which proposed targets, owners and thresholds the client has agreed (only those become
`confirmed`). The
confirmed rows go into the facts ledger with their source; the rest stay assumptions with an
owner and a date.
