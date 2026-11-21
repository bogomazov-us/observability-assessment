# Stage 3 reference — gap

*Reference for [stage 3](../stage-3-gap.md). `prompt.sh 3` does not append it; the prompt
names it at the Method, and the agent reads a step's section here before doing the step. A
rule here binds as if it were in the prompt.*

## Method

### 1. Signals

For each signal in the spec, query the estate over a stated window: does the series or event
exist, with the attributes the spec names, at the volume stage 2 expected? Mark it `live` only
with that evidence; otherwise `to_build`, `differs` (exists, does not match, and how) or
`not_verifiable` (and why) — the four `state` values speclint accepts.

### 2. SLIs

For each SLO, can good and valid be computed today from live signals alone? Run the query when
it can, over the SLO's window or the longest available, and record the result as a reading, not
a verdict. When it cannot, name the missing signal. Check the window states: can no traffic be
told from telemetry unknown?

### 3. Alerts

For each alert, the live rule or none; its input series present or not over the window; grouped
per function or on a pooled rate or host; its state as evaluated. An alert whose input series
never existed in the window can say nothing either way.

### 4. Detection matrix

For each P1 alert, the chain fault → signal → evaluation → firing → notification →
acknowledgement, and how each link is shown:

- **proven**: a recorded firing or reproduction, with date and source;
- **scenario written**: steps, expected firing and time, who runs it, where — never production
  by you;
- **residual risk**: why it cannot be shown now; a proposed owner.

No-data and recovery are part of the scenario.

### 5. Paging readiness

Per alert, never by a common level: the parts of the paging gate in
[slo-alerts](../../../templates/spec-set/slo-alerts.md), each **shown** (cite it) or
**not shown**:

- alert quality: firing, missing data, recovery, delivery; for a counter, a failure before its
  first export apart from one after a delivered zero;
- response: primary and backup person, hours of cover, acknowledgement, escalation;
- outside-in for synthetics;
- a tested independent delivery path.

Stated in a document is not shown, and a recorded test that missed a requirement is not a pass.
A second channel to the same person is delivery backup, not escalation. Missing-data behaviour
is read per input: missing expected evaluations are a fault, a missing sparse failure counter
may mean no errors.

### 6. Telemetry health

Walk the telemetry failure table from stage 2: for each failure, is its detecting signal live,
and what would the failure read as today?

### 7. Open questions carried

Answer from evidence the questions stage 2 moved here; for each, the evidence or "not
established" with what would establish it. A layer you cannot read is `not verifiable` with an
owner question; when the owner allows a read in the system's own console, the person does it
read-only and records status, path template, host class and time only, as a dated addition to
your draft, not as your evidence.

### 8. Blind spots

A check that cannot fire, a route that reaches nobody, an alert that reads no data as healthy,
and each residual risk of step 4: hand each to the person for the risk register now, as a row of
its columns: risk, source (stage 3, row id), proposed owner, status *open*, date.
