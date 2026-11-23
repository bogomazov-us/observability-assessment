# Observability stage 2 reference — target model

*Reference for [stage 2](../stage-2-target-model.md). `prompt.sh 2` does not append it; the
prompt names a section here at each step that needs it, and the agent reads that section
before doing the step. A rule here binds as if it were in the prompt. A step the prompt
states in full (step 2) has no section here.*

## Method

### 0. Sources agree first

Find every source of requirements: the journey model agreed at kick-off, journey or function
definitions in the code or the product documents, the code itself. If they disagree (ids, the
cut into functions, what success means, what is built), stop and hand the disagreements to the
person as a table — source, what it says, file:line. Draft only after the owner has said how
they are reconciled: one source governs, or all are brought to one current state.

### 1. Names first

Take the names of journeys and business steps in the client's own words, from the journey
model and the kick-off notes, and keep them: they go into the spec's `glossary`, and every
later stage uses them. Where two sources name one thing differently, the name is an open
question for the owner, not your choice.

For each journey, list the calls a customer's attempt makes, in order, from the captures. Group
them into business functions: one function per business step that can fail on its own
(reserve, authorise, place), not one per endpoint.

### 3. Error path

For each function, read the error path in code: every code or condition it can return, with
its HTTP status. Watch for refusals returned inside HTTP 200.

### 4. Classes

Classify each row: expected, failure, caller_defect, ambiguous, unknown, or none (looked like
an error, the operation took effect). Ambiguous means the business outcome is unknown — give
its reconciliation path or mark it open. A code that means different things in different
contexts gets one row per context, or stays unknown.

### 5. Attempt model

If one business attempt spans several functions, draft the attempt model: which operation
decides the outcome, after how long an attempt with no result is ambiguous.

### 6. Success is checkable

Write each function's success so that a browser or API assertion can decide it: the states that
count (success, degraded, failure), what an empty result means, and the time bound. Where the
owner has not decided one of these, it is an open question for the owner, not a default.

### 7. Reconciliation is per operation type

For each ambiguous outcome say, per create, update and delete, what evidence proves the
operation took effect, and whether the outcome of the attempt and of its audit record are
settled together. "Run it on a schedule" is not a reconciliation path.

The evidence must link the change to **this** operation — its key, or a stamp it wrote and
kept: a timestamp, equal fields or a deletion that any other writer (a person in the source of
truth, an import) could have produced proves the state, not the operation, and leaves the
outcome undetermined. An operation of several mutations is settled per mutation, and succeeds
only when every one is proven.

Draft the acceptance scenarios:

- response lost after the operation landed (per type);
- the source of truth unavailable during reconciliation;
- the record changed by someone else;
- a composite operation whose first mutation landed and second did not;
- a re-run that leaves the result unchanged.

### 8. Layers are mapped, not merged

When the client keeps business functions apart from monitoring functions (or synthetic steps
apart from both), keep the layers and draft an explicit mapping. The mapping is checked by
exact ids in both directions — every monitoring function is mapped, every mapped id exists —
not by searching text. Metric ids and function ids are kept apart. A complete mapping says the
references are complete, not that the signals work.

### 9. Names have a history

Where an alert or metric has several names across sources, draft a legacy → current table with
the state of each (live, removed, never existed); do not pick a spelling. A list of alerts or
checks separates live (seen in the estate), historical (removed, when) and planned (required,
not built); a planned one is never listed as running.

### 10. No traffic is not missing telemetry

An SLI over counts has three window states: traffic present, no traffic (confirmed by a
telemetry health signal), telemetry unknown. A window with telemetry unknown is neither good
nor valid and is counted apart; with no valid window the SLO reads "no estimate", not 100 %.
Draft the health signal.

### 11. Readings are marked

Where an owner's decision leaves a parameter open and you fill it from another source, mark the
value as your reading, cite the source, and list it for the owner. A decision fixes what was
decided; it does not make weak evidence sufficient, and the reviewer still checks the evidence.

### 12. Impact on the person

Give each taxonomy row a `user_impact`: blocked, degraded, unaffected or unknown — what the
person can still do, which the class alone does not say. A response that succeeds technically
but leaves the journey wrong (an empty list that should not be empty) is not unaffected. Not
every function needs its own SLO: propose which do and which are covered by another, as a
question for the owner.

### 13. The budget in the SLI's own units

For each SLO compute the error budget in what the SLI counts — bad requests, or bad windows of
a window-share SLI — and say what it is not (a window-share budget is not minutes of downtime
nor a share of failed requests). Draft burn-rate alerts, a fast and a slow pair, in shadow.
Draft the error-budget policy as a skeleton: what happens at which share spent is the owner's
decision.

### 14. Telemetry fails too

Draft a table of how the telemetry itself fails. For each row: how it would show, which signal
detects it (live, with the inventory row, or to build), and whether today it would read as "no
traffic" or "OK".

| Where it fails | Typical failure |
|---|---|
| Emitter | no series |
| Exporter or collector | dropped exports |
| Ingestion | lag, rejects |
| Labels | drift, cardinality |
| Recording rules | |
| Alert evaluation | |
| Notification delivery | |

### 15. Volume decides the window

For each SLO and alert, estimate the volume per evaluation window from the inventory (requests,
beacons, synthetic cadence). Where a percentile or a short window has too few events to mean
anything, mark it insufficient and give the owner candidates: a longer window, a count instead
of a percentile, a denser synthetic.

## Output

### The spec

`spec/observability-spec.yml`, from the skeleton:

- `journeys` and `taxonomy` filled;
- for each function one `signals` entry with state `to_build` and a placeholder name;
- `slos` and `alerts` left as skeleton placeholders, or drafted with `status: proposed`;
- a YAML comment on each row cites its source.

For every function in scope:

- a stable id (keep the ids of the client's journey model when it has them) and
  `requirement`, the source of the requirement;
- `current`: what exists today, citing the confirmed inventory by row id (`L-07`), never by line
  number, kept apart from the target; unknown stays `unknown`;
- a signal is `live` only with production evidence from the inventory.

No target, owner or threshold is `confirmed` by the agent. A field of the engagement's own is
prefixed `x_` (SL019).

`glossary`: one entry per journey, function and attempt, its term equal to the item's `name`
(SL021, SL022), with a one-line meaning in the client's words; domain words that name no item
may be added without `names`.

A clean `speclint` run (no errors, only SL016 placeholder warnings) shows that the spec is
structurally complete, not that it is right; say so in the notes ([claims](../rules/claims.md)
item 18).

### The notes

`stage-2-notes.md` is written around the resulting contract, not the rounds that produced it:

1. a compact map of the functions: purpose, success criterion, measurable today, target
   coverage;
2. a table per journey: function, route, service, source;
3. "Open questions": item, what is missing, who can answer.

A superseded decision is marked where it is cited. Review rounds and earlier answers go to an
appendix or a file of their own.
