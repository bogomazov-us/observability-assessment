# Stage 2 reference — SRE target model

*Reference for [SRE stage 2](../stage-2-target-model.md). `prompt.sh --assessment sre 2` does
not append it; the prompt names a section here at each step, and the agent reads that section
before doing the step. A rule here binds as if it were in the prompt.*

## Method

### 0. Sources agree first

The sources: the journeys agreed at kick-off, the catalogue, the stated needs (contracts,
regulatory or internal policies, interview notes). Where they disagree on what is critical or
on a value (two documents with two availability figures), hand the person a table — source,
what it says, its date, file or `E-` id — and draft after the owner's answer is in the decision
register. A document's figure is quoted with its date ([claims](../../../tools/agent/rules/claims.md)
item 9).

### 1. Tiers from journeys

| Tier | Proposed when |
|---|---|
| 1 | The service serves a critical journey in scope: its failure stops or corrupts the journey |
| 2 | It serves a journey in scope, and the journey degrades but completes without it |
| 3 | Everything else in the catalogue |

The Tier cell reads `1, proposed` (the catalogue template's form), and the reason goes in the
notes with the journey and the source. Where the tiers were decided at scope, the reason cites
that `D-` row instead of a new proposal. A service whose role the sources do not show stays
untiered, with a question.

### 2. Dependencies follow the tier

For each tier-1 service, read Upstream in the catalogue. A dependency that is not in the
catalogue, untiered, or of a lower tier is a line in the gap list: the service, the
dependency, what the sources show. Accepting it is the owner's decision (a `D-` row), never
yours. External dependencies (a payment provider) are listed with the contract figure, if one
was given, as a reading.

### 3. Defaults first

From the [SRE maturity model](../../maturity-model.md#dimensions), default thresholds:

| Kind | Applies to | Value | Dimension |
|---|---|---|---|
| on-call limit | tier 1 | at most two incidents per 12-hour shift | 5 |
| toil cap | each team in scope | at most 50% of engineering time | 10 |
| actionable alert share | tier 1 | none; the client sets the target | 3 |

Default or agreed reads *default, to confirm*. In the focused format, dimensions 3, 5 and 10
are not in scope: their rows stay default with no question (a question that blocks nothing is
not sent) and are listed under "Not agreed" as not in scope.

### 4. Targets per tier

SLO, RTO, RPO and rollout policy have no kit default. Value reads `[owner sets: Q-NN]`;
Default or agreed stays empty until the owner answers. The candidates go into the question:
each stated need with its source, and for the rollout policy the level-4 criterion of
dimension 6 (progressive delivery with automatic halt), marked as the model's criterion, not a
default. A value you would derive (an RTO from a contract's monthly downtime) is a candidate
marked as a reading, with the derivation.

**Which workloads.** A change-safety target (rollout policy) covers every tier-1 workload that
is deployed, not one kind of it. The question lists each workload kind in tier 1 — services,
workers, scheduled tasks, tunnels or agents — with its `S-` rows, and the owner says per kind
whether the policy applies; a kind left out is a separate row or a `D-` row that accepts it. A
policy phrased by kind ("canary for each service") leaves a scheduled task with no target.

**Target level per dimension.** One row per dimension in scope, kind *target level*, Applies to
the dimension ("dimension 4"), Value `[owner sets: Q-NN]`. The candidates are the model's
levels above the current reading, each with what it would ask. Stage 3 measures the
dimension's gap against it. The owner may choose no target level: that is a `D-` row too, and
the row says *none, by the owner's choice*.

**Premise.** A value agreed on a premise (a store holds only files that can be rebuilt) names
it in the Premise column, with its source; stage 3 checks the premise against the estate.

### 5. A service where it differs

A service row (`S-` id in Applies to) only when a stated need for it differs from its tier, or
for RTO and RPO: one row per tier-1 data store, since a restore is per store. A service row
names the tier row it departs from.

### 6. SLOs cite, not redefine

- **SRE only.** The targets file holds a table "SLO definitions", one row per SLO `T-` row, in
  the columns of the SLOs table in [slo-alerts.md](../../../templates/spec-set/slo-alerts.md),
  with Service in place of Function. Budget in the SLI's units, the window, volume per window.
- **Combined format.** The SLO is the observability spec's row, by the overlap rule in the
  [SRE model](../../maturity-model.md#overlaps-in-the-combined-format); the `T-` Value cites its
  spec id and the `T-` row adds the error-budget policy only; the targets file has no SLO
  definition. An SLO the spec lacks is a question to the
  observability stage, not a new definition here. The error-budget policy (what happens at 50%
  and 100% spent) is SRE's own: a question for the product and engineering owners together.

### 7. Measurable or not

A target is measurable at stage 3 when an export of stage 1 holds its inputs: incidents per
shift from the paging export, recovery times from the incident tracker, restore age from the
backup history, deploy outcomes from the pipeline. Name the export file; otherwise *no source*,
which stage 3 reports as a gap in measurement, not as a missed target.

### 8. Names first

The glossary in the targets file: each service, tier and data store named in a `T-` row, in
the client's words, with one line of meaning. A name the client uses differently in two
places is a question.

### 9. One question per value

Batch order: the tier-1 set first (one question listing the proposed services, each with its
reason; a contested service gets its own), then tier-1 SLO, RTO, RPO, rollout policy, then the
target levels, then the default rows, then lower tiers. About ten per batch; the rest waits for the next, ordered by
what it blocks. Each question names the `T-` or `S-` rows it blocks and its owner role: product
owner for an SLO, service or data owner for RTO and RPO, release owner for rollout, on-call
owner, engineering manager for toil, alert owner, sponsor or engineering lead for a target
level.

## Output

### The targets file

`sre/targets/reliability-targets.md`, from the [template](../../templates/reliability-targets.md):
its columns, sections Defaults, Targets, SLO definitions (SRE only), Glossary, Not agreed. Each
row adds its source and measuring export in a comment under the table, by `T-` id. Status is
`proposed` on every row; Decision is empty.

### The notes

`sre/target-model.md` follows the [stage report](../../../templates/stage-report.md) skeleton:

1. Result: services by proposed tier, summed; targets by kind, how many default and how many
   waiting on the owner; what is measurable today; each withdrawn id, with the reason.
2. Scope and method: the journeys, the sources and their dates.
3. Main results: the tier map (service, tier, reason, journey) and the target table per tier,
   each at most five short columns (the templates' "In the report"); the full tables go to the
   evidence bundle.
4. Records: the gap list of step 2, the disagreements of step 0, "Could not evidence".
5. Decisions and open questions: the batch's `Q-` ids and any `D-` rows cited.
