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

## Output

1. `docs/observability/observability-spec.yml`, from the skeleton: `journeys` and `taxonomy`
   filled; for each function one `signals` entry with state `to_build` and a placeholder name;
   `slos` and `alerts` left as skeleton placeholders, or drafted with `status: proposed`. A
   YAML comment on each row cites its source. For every function in scope:
   - a stable id (keep the ids of the client's journey model when it has them) and
     `requirement`, the source of the requirement;
   - `current`: what exists today, with links to the confirmed inventory rows, kept apart from
     the target; unknown stays `unknown`;
   - a signal is `live` only with production evidence from the inventory.
   No target, owner or threshold is `confirmed` by the agent.
2. `stage-2-notes.md`: a table per journey (function, route, service, source), then "Open
   questions" (item, what is missing, who can answer).

## Self-check before handing over

- [ ] `python3 tools/speclint.py docs/observability/observability-spec.yml` reports no errors;
      only SL016 placeholder warnings remain. Say in the notes that this shows the spec is
      structurally complete, not that it is right.
- [ ] Every function in scope is present, with a requirement source and its current state.
- [ ] Every SLO and alert is `proposed`.
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
