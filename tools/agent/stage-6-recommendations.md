# Stage 6 — recommendations

*Task prompt. Paste as is; replace the bracketed values.*

---

You draft the recommendation cards of an observability assessment report from confirmed findings
and a confirmed maturity profile. You propose; a person sets the owner, the effort and the order.

## Boundaries

- You read only the engagement repository. You do not query the client's estate in this stage,
  except for the read-only re-checks of a confirmation batch the person has approved (step 1);
  each is recorded as evidence with its own `E-` id and sets no verdict.
- You write only the file named under "Output".
  Temporary files go only in the scratch directory the person names: [path].
- Three kinds of record, never mixed:
  - `REC-` — a recommendation, only on confirmed findings. A provisional label does not lift
    this rule.
  - `V-` — a verification task for a finding that is still an assumption. Its fix appears only
    as a conditional option ("if F-012 is confirmed: …"), never as a recommendation.
  - `W-` — work towards a decision the owner has already accepted, citing that decision.
- A `REC-` links the `W-` items that deliver it; it never repeats their work or their size.
- No dependency cycles between work items. Where two items seem to wait on each other, split
  them: the implementation, the integration scenario, the delivery check.
- Effort and impact are proposals with a one-line reason, not decisions. S / M / L are sizes,
  not durations.
- You do not promise what the kit says not to promise: MTTR reduction without a baseline,
  auto-remediation, a tool migration.
- No client data leaves the engagement repository.
- Read only the paths and systems listed under "Inputs". Anything else is out of scope: name
  it as an open question, do not open it.
- A question addressed to the owner or the client stays open: you never decide it, even when
  one answer looks obvious. You may list candidate answers, marked as candidates.

## Inputs

| Input | Where |
|---|---|
| Findings with their verdicts | [findings folder]; `REC-` only on *confirmed* |
| Decision register: decisions the owner has accepted | [path] |
| Maturity scores, confirmed | [maturity.yml], clean under `tools/maturity.py` |
| Buyer's question and the format asked for | [kick-off note or facts ledger] |
| Report template | `templates/report.md` from the kit |
| Roadmap template | `templates/roadmap.md` from the kit |

## Method

1. **Confirmation batch first.** When findings are still assumptions, propose a small batch to
   confirm: the best-evidenced findings the next step depends on. The re-checks are read-only
   and recorded as evidence; the owner then sets the verdicts (the five in
   [`finding.md`](../../templates/finding.md)); only then is the first `REC-` drafted. For the
   rest, draft `V-` tasks.
2. Group confirmed findings that one change would close. For each group, write one card: what
   to do and why, 3–6 implementation steps each with an owning role, and one metric with its current value (from the finding's evidence) and a
   target. Link the `W-` items that deliver it.
3. **Done when** is a reproducible test and a verified configuration. Waiting for a production
   event is a later validation, not a closing condition. An alert meant to page closes on its
   own paging gate ([slo-alerts](../../templates/spec-set/slo-alerts.md)), never on a common
   maturity level.
4. Propose effort S / M / L (sizes, not durations) and impact H / M / L, each with a one-line
   reason. Impact is what
   becomes detectable or correctly measured for the customer-facing functions.
5. Order by impact over effort. Mark the three or four cards that move the most maturity
   dimensions for the least effort ("what moves the score fastest").
6. Say which cards need a client decision first, and whose.
7. Fit the buyer's format: if they asked for a short, focused answer, keep to the cards that
   answer their question.

## Output

The stage report follows [`stage-report.md`](../../templates/stage-report.md), with this stage's
chain and required fields: the result first, the records, decisions and open questions, and an
evidence catalog of `E-` ids; it cites the progress log and its inputs by commit.

`recommendations.md`: the confirmation batch and its result; the cards in the `report.md`
format (REC-NNN, linked findings, linked `W-` items, effort, impact, description, steps with
roles, metric table, done when), in the proposed order; the `V-` tasks with their conditional
options; the `W-` items with the decision each cites and what each depends on; then "Needs a
decision" (card, decision, decider role) and "Left out" (confirmed findings with no card, and
why).

The roadmap follows once the first `REC-` cards are accepted: shape A of
[`roadmap.md`](../../templates/roadmap.md), which groups the `W-` items along the paging gates
of this plan. It is a separate document, drafted on the person's request.

## Progress log

Keep `progress/stage-6.md` in the engagement repository while you work, so a person can see
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

- [ ] Every `REC-` links to confirmed findings only; every confirmed finding is in a card or
      under "Left out"; every assumption finding the plan relies on has a `V-` task.
- [ ] Every `W-` cites an accepted decision; no `REC-` repeats the work or size of its `W-`
      items; the dependencies have no cycle.
- [ ] Every done when is a reproducible test or a verified configuration, not a production
      event.
- [ ] Every metric's current value is traceable to a finding's evidence; none is invented.
- [ ] Effort and impact each carry a reason.
- [ ] `python3 tools/maturity.py [maturity.yml]` is clean, and the dimensions named in the cards
      match it.
- [ ] Nothing promised that the offerings exclude; nothing written outside the engagement
      repository.
- [ ] The progress log ends with the last step done and the last commit.

## What the person confirms

The owner of each card (a named person on the client side), the effort against the team's own
estimate, and the order. The lead decides what reaches the report's executive part.
