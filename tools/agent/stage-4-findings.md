# Observability stage 4 — findings

*Task prompt. Assemble it with `tools/agent/prompt.sh 4`, which appends the rule files it
names, and paste the result as is; replace the bracketed values.*

---

You draft the findings of an observability assessment from a confirmed target model and a
confirmed gap. You draft; a person re-runs the evidence and sets the status. Until both quality
targets hold on two engagements, every stage runs as a draft to compare against, and people
write the findings ([agent-harness.md](../../method/agent-harness.md), "Measuring the
harness"): you reconcile your drafts with theirs.

## Rules

The rule files in [`rules/`](rules/) apply to this stage: [boundaries](rules/boundaries.md),
[evidence](rules/evidence.md), [claims](rules/claims.md),
[owner questions](rules/owner-questions.md) and the [progress log](rules/progress-log.md),
with N = 4. The boundaries below are this stage's own and add to the common ones.

## Boundaries

- Read-only on the client's estate: code checkout, monitoring tool, exports. You may run read
  queries in the tool; you never change its configuration, the code or tickets.
- One claim per finding. Every statement under *What we see* cites its evidence: the query text
  and its time range, file:line, the export file and row, or the inventory row id.
- Every finding is drafted with status **assumption**. You never write *confirmed*.
- Expected refusals are not failures; a metric that is not collected is a gap, not a green.

## Inputs

| Input | Where |
|---|---|
| Spec with gap results (stages 2–3, confirmed) | `spec/observability-spec.yml` |
| Gap notes: which signals are live, by what evidence; the detection matrix | `stage-3-gap.md` |
| Code scan report and estate export by class | `scan.md`, `exports/` |
| Findings people already wrote, status assumption | `findings/` |
| Facts ledger | instructions file |
| Finding template | `templates/finding.md` |
| The client's own investigation or tools, if any | [folder] |

## Method

0. Read the findings already in `findings/`. A candidate one of them covers is not drafted
   again: list it in `stage-4-notes.md` under that finding's id, with what it adds or where it
   differs, for the person to merge. A new finding takes the next free id; no id is reused.
1. Walk the chain per function: function → signal → SLI → alert → owner → runbook. Each broken
   or unproven link is a candidate finding.
2. Check the estate for the classic failures: alerts on pooled rates or hosts, alerts without
   owner or runbook, refusals inside HTTP 200 counted as success, dashboards that count page
   views instead of outcomes, signals nobody can query.
3. For each candidate, get the evidence: run the query, open the code path, find the export
   row. No evidence, no finding.
4. Write *Why it matters* as a customer or business consequence. Write *What follows* as an
   action, the role that owns it, and the maturity dimension it moves.
5. Where the client's own work already covers a point, say so and build on it.
6. Bound each claim before you write it: its window and its scope; "not shown" rather than
   "none exists"; a cause only for the window read; an absence read in part of the estate
   says what was not checked ("other accounts not checked"). A decision record that adopted a
   reading is not evidence for it: cite the code and its version, or a query.

## Output

The stage report, `stage-4-notes.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log, the decision register and the full spec
travel with it as files at a stated commit, cited, not reprinted.

1. One file per finding, `findings/F-NNN.md`, in the `templates/finding.md` format: status
   *assumption*, today's date, source, evidence level (browser / agent / tenant / document
   only), severity with its reason, the three statuses, confidence and limits, the closing
   criterion, and under each claim its `E-` ids. Candidates whose fixes differ are separate
   findings.
2. `stage-4-notes.md`: one page of result first (findings by severity, the five to seven that
   matter most and their consequence, what was not evidenced, the next step); the evidence
   catalog (`E-` id: source, window, method, result, limits); the facts-ledger rows these findings rest on (proposed, status
   assumption), and "Could not evidence" (claim, what is missing, who can provide it).

## Self-check before handing over

- [ ] Every claim has an Evidence line a reviewer can re-run without asking.
- [ ] Every finding is status *assumption*; none says *confirmed*.
- [ ] Every *What follows* names an action, an owning role and a maturity dimension.
- [ ] No finding rests on an interview or a slide alone (evidence level *document only* is
      stated when that is all there is).
- [ ] No other client's name, figure or system appears.
- [ ] `tools/recordcheck.py findings` passes on `findings/` with the stage's evidence catalog and
      gap records given: form, severity reasons and every cited id resolve.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../../method/getting-started.md#3-calendar) gives, re-runs each cited query or opens each cited line, then sets the verdict, one of the five in
[`finding.md`](../../templates/finding.md): confirmed, disputed (with the reason), refuted,
inconclusive or resolved. A check that did not reproduce is not a refutation: too little data,
expired history or a changed configuration gives inconclusive or disputed, and true then but
fixed since gives resolved. The re-checks are read-only and recorded as evidence with their own
`E-` ids; a reviewer's reading is a recommendation, and the owner sets the verdict
([records.md](../../method/records.md)), in writing,
through the verdict batch of [`owner-questions.md`](../../templates/owner-questions.md). An anomaly
seen during a re-check that nothing explains stays an observation of unknown cause, not a new
finding. Refuted drafts are kept with the reason; they count against the harness in the
measures. The stage is confirmed once every draft is re-checked and its verdict recorded or
sent in the batch: a finding still waiting stays *assumption*, and stage 5 marks a level
resting on it provisional.
