# Stage 3 reference — SRE gap

*Reference for [SRE stage 3](../stage-3-gap.md). `prompt.sh --assessment sre 3` does not append
it; the prompt names it at the Method, and the agent reads a step's section here before doing
the step. A rule here binds as if it were in the prompt.*

## Method

### 1. Scope

Read the format from the state file and the target model. Focused: dimensions 1, 2, 4, 6 and 9
of the [SRE model](../../maturity-model.md); every other dimension is "not in scope", listed by
number and name, with no rows. Not in scope is not "not scored" and not N/A: it says nothing
about the dimension. Full: all ten.

Combined format, per the [overlap table](../../maturity-model.md#overlaps-in-the-combined-format):

| Topic | This stage |
|---|---|
| SLOs | Rows for dimension 2 cover the error-budget policy and the decisions it changed only; SLO definition and measurement: "see observability 6" |
| Alerts | No rows for dimension 3: "see observability 7" |
| Incidents | Dimension 4 is gapped here in full; the observability gap refers to it |
| Releases | Dimension 6 is gapped here: rollout, rollback, DORA; the release signals stay with observability 10 |

Owner questions and findings share one sequence with the observability type; read the shared
`owner-questions.md` before proposing one, so a question already asked is cited, not repeated.

### 2. Targets

Per dimension in scope: the `T-` rows that apply to each tier-1 service (by service, else by
its tier), and the dimension's *target level* row. Measure against the agreed value; against a
default only when the row says it is a default, and the gap row says so too. A dimension's
gap is read against the criteria of its target level. A dimension or service with no target
gets no invented one: an open question to its owner.

**None, by the owner's choice.** When the target level row reads *none, by the owner's choice*,
the dimension's gap rows record the current state and the status of the practice, with the
Target cell "none, by the owner's choice (`D-NN`)"; they are not an open question, and a
stage-4 candidate from them says so.

**Premise.** A `T-` row with a premise: check the premise against the estate (code, configuration,
exports). A premise the estate contradicts is an open question to the target's owner, with the
evidence; the target is not edited.

### 3. Current state

Per tier-1 service, or dimension-wide when the practice is shared (one rotation, one pipeline,
one backup tool), read what is in place, with the evidence of the model's
[evidence table](../../maturity-model.md#evidence-per-dimension):

- an earlier row: an `L-` inventory row or a `B-` baseline number, cited by id, not re-queried;
- an export in `sre/exports/`, by file and row;
- a read query, with its window: a new `E-` check, numbered by the one-sequence rule of
  [records.md](../../../method/records.md#id-prefixes).

A `B-` number marked *not measured* is carried as it is: the current state is "not measured",
and the gap row cites it. A practice stated only in a document is "documented", with the
document's date, and becomes current only with a record that it ran (a restore ticket, a
rollback in the deploy history, a postmortem with dated action items). A restore counts only
from the backups the RPO relies on: a one-off copy made for a migration is not one.
Incidents are read per class (outage, data correctness), never as one population.
An agreed test you cannot run (a restore by a date) is handed over in the
[recovery proof's hand-over](../../templates/recovery-proof.md#hand-over), not run.

### 4. Gap rows

| Column | Holds |
|---|---|
| ID | `G-01`, `G-02` …; never renumbered |
| Service | `S-` id, or *dimension-wide* |
| Dimension | Number and name |
| Target | `T-` id and value, or the target model's level |
| Current | What is in place, with its window |
| Evidence | `E-`, `L-`, `B-` ids and export rows |
| Status | absent · partial · implemented |

**implemented**: the target's practice is in place and shown by a record in the window.
**partial**: in place for some services, data stores or shifts, or in place but not shown
(rollback configured, never run). **absent**: not found where it would be. A number against a
target (pages per shift, change failure rate, SLO attainment) is a reading in its window, never
"met" or "missed"; the status speaks of the practice. A target whose current state cannot be
read gets no row: it goes under "Could not evidence" with its owner question. The counts state
each withdrawn id, with the reason.

### 5. Monitoring, light

Dimension 3 only at its criteria: per tier-1 service, symptom alerts with owners and runbooks,
burn-rate alerts, the actionable share if a `B-` number holds it. Alert quality, delivery and
detection are not tested here: a weak dimension 3 is a stage-4 candidate whose remedy is the
observability assessment.

### 6. Readiness

Only when dimension 10 is in scope. Find the last tier-1 launch from the catalogue, the deploy history or launch tickets. Check it
against each item of [readiness-review.md](../../templates/readiness-review.md): met yes, no, or
n/a with the reason, and the evidence per item; an item without evidence is not met. No review
on record is itself the result. You do not run the review or set its outcome: the service
owner does. This check has no path of its own; it is a section of `sre/stage-3-gap.md`, and the
gap rows for dimension 10 cite it.

### 7. Open questions carried

Answer from evidence the questions stage 2 moved here; for each, the evidence or "not
established" with what would establish it.

### 8. Blind spots

A tier-1 service on an untiered dependency, a backup that is not monitored, a pipeline with no
rollback path, a rotation without backup, a data store never restored: hand each to the person
for the risk register now, as a row of its columns: risk, source (stage 3, row id), proposed
owner, status *open*, date.
