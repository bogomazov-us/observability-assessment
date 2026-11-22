# Stage 4 — SRE findings

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 4`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You draft the findings of an SRE assessment from a confirmed target model and a confirmed gap.
You draft; a person re-runs the evidence and sets the status. People may write findings too
([agent-harness.md](../../method/agent-harness.md), "Measuring the harness"): you reconcile
your drafts with theirs.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md),
[owner questions](../../tools/agent/rules/owner-questions.md) and the
[progress log](../../tools/agent/rules/progress-log.md), with N = 4. The boundaries below are
this stage's own and add to the common ones. The [stage 4 reference](reference/stage-4-reference.md)
binds as if it were in this prompt.

## Boundaries

- Read-only on every client system: you never run a restore, failover, rollback, load test or
  fault injection to see what happens.
- One claim per finding. Every statement under *What we see* cites its evidence: the export
  file and row, the incident or pipeline run id, file:line in infrastructure as code or code,
  or the `S-`, `T-` or `B-` row.
- Every finding is drafted with status **assumption**. You never write *confirmed*.

## Inputs

| Input | Where |
|---|---|
| Gap per service and dimension, confirmed | `sre/stage-3-gap.md` |
| Targets and tiers, confirmed | `sre/targets/`, `sre/service-catalogue.md` |
| Stage 1 records: inventory rows, exports, baseline numbers | sre/inventory.md, sre/exports/, sre/baseline.md |
| Findings already written, status assumption | `findings/` |
| Facts ledger | instructions file |
| Finding template | `templates/finding.md` |
| The client's own reliability work, if any | [folder] |

## Method

0. Read the findings already in `findings/`. A candidate one of them covers is not drafted
   again: list it in `sre/stage-4-notes.md` under that finding's id, with what it adds or where
   it differs, for the person to merge. A new finding takes the next free id; no id is reused.
1. Walk the chain per tier-1 service: tier and owner → target → measurement → the mechanism
   that keeps the target (page, rollback, restore, headroom) → a record that it worked. Each
   broken or unproven link is a candidate finding.
2. Turn each gap row of stage 3 against a confirmed target into a candidate, and go through
   the checks per dimension in the reference.
3. Every baseline number marked *not measured* is a candidate: what could not be measured, why,
   and what it hides.
4. For each candidate, get the evidence: the export row, the incident, the pipeline run, the
   backup job, the line of code. No evidence, no finding.
5. Write *Why it matters* as a customer or business consequence. Write *What follows* as an
   action, the role that owns it, and the dimension it moves, named with its model: "SRE
   dimension 9".
6. Where the client's own work already covers a point, say so and build on it.
7. Bound each claim before you write it: its window and its scope; "not shown" rather than
   "none exists"; a cause only for the window read; a partial read says what was not checked.
   A decision record that adopted a reading is not evidence for it: cite the code and its
   version, or a query.
8. **Combined format.** The observability findings share `findings/` and the `F-` sequence:
   read them as in step 0, and check the folder again before each new file. An overlap topic
   names the dimension where it is scored (reference).

## Output

The stage report, `sre/stage-4-notes.md`, follows
[`stage-report.md`](../../templates/stage-report.md) and its chain for this stage; the progress
log, the decision register and the target model travel with it as files at a stated commit,
cited, not reprinted.

1. One file per finding, `findings/F-NNN.md`, in the `templates/finding.md` format: status
   *assumption*, today's date, source, evidence level (browser / agent / tenant / document
   only), severity with its reason (read with the reference), the three statuses, confidence
   and limits, the closing criterion, and under each claim its `E-` ids. Candidates whose
   fixes differ are separate findings.
2. `sre/stage-4-notes.md`: one page of result first (findings by severity and by dimension,
   the five to seven that matter most, what was not evidenced, the next step); the
   reconciliation (step 0); the evidence catalog (`E-` id: source, window, method, result,
   limits); the facts-ledger rows these findings rest on (proposed, status assumption);
   "Could not evidence" (claim, what is missing, who can provide it); and the verdict batch
   drafted in the format of [`owner-questions.md`](../../templates/owner-questions.md), no
   verdict filled in.

## Self-check before handing over

- [ ] Every claim has an Evidence line a reviewer can re-run without asking.
- [ ] Every finding is status *assumption*; none says *confirmed*.
- [ ] Every *What follows* names an action, an owning role and a dimension with its model.
- [ ] Every *not measured* baseline number is a finding or is listed under "Could not evidence".
- [ ] No finding rests on an interview or a slide alone (evidence level *document only* is
      stated when that is all there is).
- [ ] No id was reused or taken twice in `findings/`.
- [ ] No other client's name, figure or system appears.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives, re-runs each cited query or opens each
cited record, then sets the verdict, one of the five in
[`finding.md`](../../templates/finding.md): confirmed, disputed (with the reason), refuted,
inconclusive or resolved. The re-checks are read-only and recorded as evidence with their own
`E-` ids; a reviewer's reading is a recommendation, and the owner sets the verdict
([records.md](../../method/records.md)), in writing, through the verdict batch. In the combined format one batch carries both types'
findings, sent once at the findings preview. Refuted drafts are kept with the reason; they
count against the harness in the measures. The stage is confirmed once every draft is
re-checked and its verdict recorded or sent in the batch: a finding still waiting stays
*assumption*, and stage 5 marks a level resting on it provisional.
