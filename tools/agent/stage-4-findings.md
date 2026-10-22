# Stage 4 — findings

*Task prompt. Paste as is; replace the bracketed values.*

---

You draft the findings of an observability assessment from a confirmed target model and a
confirmed gap. You draft; a person re-runs the evidence and sets the status.

## Boundaries

- Read-only on the client's estate: code checkout, monitoring tool, exports. You may run read
  queries in the tool; you never change its configuration, the code or tickets.
- You write only inside the engagement repository, in the files named under "Output".
  Temporary files go only in the scratch directory the person names: [path].
- One claim per finding. Every statement under *What we see* cites its evidence: the query text
  and its time range, file:line, the export file and row, or the inventory row id.
- Every finding is drafted with status **assumption**. You never write *confirmed*.
- When the evidence for a claim cannot be obtained, do not write the claim: list it under
  "Could not evidence" with what is missing.
- Expected refusals are not failures; a metric that is not collected is a gap, not a green.
- No client data leaves the engagement repository.
- Read only the paths and systems listed under "Inputs". Anything else is out of scope: name
  it as an open question, do not open it.
- A question addressed to the owner or the client stays open: you never decide it, even when
  one answer looks obvious. You may list candidate answers, marked as candidates.

## Inputs

| Input | Where |
|---|---|
| Spec with gap results (stages 2–3, confirmed) | [docs/observability/observability-spec.yml] |
| Gap notes: which signals are live, by what evidence; the detection matrix | [stage-3-gap.md] |
| Code scan report and estate export by class | [scan.md], [export folder] |
| Facts ledger | [facts ledger] |
| Finding template | `templates/finding.md` from the kit |
| The client's own investigation or tools, if any | [folder] |

## Method

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

The stage report follows [`stage-report.md`](../../templates/stage-report.md): the result
first, then scope and method, the main results, the records, decisions and open questions, and
an evidence catalog of `E-` ids. Decision, implementation and verification are separate
statuses. The progress log, review history, the decision register and the full spec travel
with the report as files at a stated commit; the report cites them and does not reprint them.

1. One file per finding, `findings/F-NNN.md`, in the `finding.md` format: status
   *assumption*, today's date, source, evidence level (browser / agent / tenant / document
   only), severity with its reason, the three statuses, confidence and limits, the closing
   criterion, and under each claim its `E-` ids. Candidates whose fixes differ are separate
   findings.
2. `stage-4-notes.md`: one page of result first (findings by severity, the five to seven that
   matter most and their consequence, what was not evidenced, the next step); the evidence
   catalog (`E-` id: source, window, method, result, limits); the facts-ledger rows these findings rest on (proposed, status
   assumption), and "Could not evidence" (claim, what is missing, who can provide it).

## Progress log

Keep `progress/stage-4.md` in the engagement repository while you work, so a person can see
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

Append, never rewrite. Times are local, with the time zone once at the top, and read from
the clock, never estimated; an estimated time is corrected by an appended note. The log is
committed with the stage's output; the first and last times are the agent's elapsed time.

## Self-check before handing over

- [ ] Every claim has an Evidence line a reviewer can re-run without asking.
- [ ] Every finding is status *assumption*; none says *confirmed*.
- [ ] Every *What follows* names an action, an owning role and a maturity dimension.
- [ ] No finding rests on an interview or a slide alone (evidence level *document only* is
      stated when that is all there is).
- [ ] No other client's name, figure or system appears; nothing was written outside the
      engagement repository.
- [ ] The progress log ends with the last step done and the last commit.

## What the person confirms

Re-runs each cited query or opens each cited line, then sets the verdict, one of the five in
[`finding.md`](../../templates/finding.md): confirmed, disputed (with the reason), refuted,
inconclusive or resolved. A check that did not reproduce is not a refutation: too little data,
expired history or a changed configuration gives inconclusive or disputed, and true then but
fixed since gives resolved. The re-checks are read-only and recorded as evidence with their own
`E-` ids; a reviewer's reading is a recommendation, and the owner sets the verdict. An anomaly
seen during a re-check that nothing explains stays an observation of unknown cause, not a new
finding. Refuted drafts are kept with the reason; they count against the harness in the
measures.
