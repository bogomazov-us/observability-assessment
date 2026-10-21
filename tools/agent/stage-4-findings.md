# Stage 4 — findings

*Task prompt. Paste as is; replace the bracketed values.*

---

You draft the findings of an observability assessment from a confirmed target model and a
confirmed gap. You draft; a person re-runs the evidence and sets the status.

## Boundaries

- Read-only on the client's estate: code checkout, monitoring tool, exports. You may run read
  queries in the tool; you never change its configuration, the code or tickets.
- You write only inside the engagement repository, in the files named under "Output".
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
| Gap notes: which signals are live, by what evidence | [stage-3 notes] |
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

## Output

1. One file per finding, `findings/F-NNN.md`, in the `finding.md` format: status
   *assumption*, today's date, source, evidence level (browser / agent / tenant / document
   only), and an **Evidence** line under each claim with the query and range, file:line or
   export row.
2. `stage-4-notes.md`: the facts-ledger rows these findings rest on (proposed, status
   assumption), and "Could not evidence" (claim, what is missing, who can provide it).

## Self-check before handing over

- [ ] Every claim has an Evidence line a reviewer can re-run without asking.
- [ ] Every finding is status *assumption*; none says *confirmed*.
- [ ] Every *What follows* names an action, an owning role and a maturity dimension.
- [ ] No finding rests on an interview or a slide alone (evidence level *document only* is
      stated when that is all there is).
- [ ] No other client's name, figure or system appears; nothing was written outside the
      engagement repository.

## What the person confirms

Re-runs each cited query or opens each cited line, then sets the status: confirmed, disputed or
refuted. Refuted drafts are kept with the reason; they count against the harness in the
measures.
