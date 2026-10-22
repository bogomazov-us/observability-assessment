# Stage 5 — maturity

*Task prompt. Paste as is; replace the bracketed values.*

---

You draft the maturity profile of an observability assessment from confirmed findings and the
confirmed gap. You draft; a person sets each level and its confidence.

## Boundaries

- Read-only on the client's estate. You score from evidence already gathered in stages 1–4; a
  new query is allowed only to look for the evidence of a level, and is cited like any other.
- You write only inside the engagement repository, in the files named under "Output".
  Temporary files go only in the scratch directory the person names: [path].
- Every level names its evidence, per [maturity-model.md](../../method/maturity-model.md). Level
  1 names the search that came back empty. A level nobody looked for is `not_scored`, never 1.
- No overall number: no average, no total, no single score.
- Nothing you write is a fact. Every level is a proposal until the person sets it.
- Read only the paths and systems listed under "Inputs". Anything else is out of scope: name
  it as an open question, do not open it.
- A question addressed to the owner or the client stays open: you never decide it. N/A outside
  dimension 12 needs the client's agreement — propose it, do not set it.

## Inputs

| Input | Where |
|---|---|
| Findings, confirmed | [findings/] |
| Gap, confirmed: signal states, detection matrix, paging readiness | [stage-3-gap.md] |
| Spec, inventory, facts ledger | [paths] |
| Maturity model and skeleton | `method/maturity-model.md`, `templates/maturity.yml` from the kit |

## Method

1. Copy `templates/maturity.yml` and fill the scope: the journeys and services assessed.
2. For each dimension, read its levels in the model and find the highest level fully shown by
   evidence: a confirmed finding, an inventory row, a gap row, a query. A level shown for part
   of the scope is `partial`, with the coverage written out.
3. Above level 2, at least one piece of tool evidence: an export, a query, a trace, code or
   configuration. A slide or an interview alone stops at level 2.
4. Give each score a confidence (high, medium, low) and say why; low confidence above level 2
   is not allowed.
5. A dimension without evidence either way is `not_scored`, with the reason and what would
   score it.
6. Mark the dimensions that block the next step, and what would move the profile fastest, as
   proposals for the person.

## Output

1. `maturity.yml`, clean under `python3 tools/maturity.py --check maturity.yml`.
2. `stage-5-notes.md`: per dimension, the level, the evidence that shows it, the evidence that
   stops the next level, and the confidence; the profile printed by `tools/maturity.py`.

## Progress log

Keep `progress/stage-5.md` in the engagement repository while you work, so a person can see
where the stage is without asking you. Its first line is the plan: the steps, numbered, and
their count. Then one line when a step starts and one when it ends, one per commit with its
hash, and one when you stop on something:

```
14:05 plan — 4 steps: 1 scope, 2 dimensions 1-6, 3 dimensions 7-12, 4 check and notes
14:07 step 1/4 scope — started
14:10 step 1/4 scope — done
14:41 step 2/4 dimensions 1-6 — blocked: no finding covers dimension 5 (open question 2)
14:55 commit 3f2a1c9 — dimensions 1-6
```

Append, never rewrite. Times are local, with the time zone once at the top. The log is
committed with the stage's output; the first and last times are the agent's elapsed time.

## Self-check before handing over

- [ ] `python3 tools/maturity.py --check maturity.yml` exits 0.
- [ ] Every level names its evidence; every level 1 names the empty search.
- [ ] No dimension is scored without having been looked for; those are `not_scored`.
- [ ] No overall number anywhere.
- [ ] Nothing was written outside the engagement repository.
- [ ] The progress log ends with the last step done and the last commit.

## What the person confirms

Each level and its confidence, against the cited evidence; each N/A with the client; which
dimensions block the next step. Only the confirmed profile goes into stage 6.
