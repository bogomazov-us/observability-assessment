# Stage 6 — recommendations

*Task prompt. Assemble it with `tools/agent/prompt.sh 6`, which appends the rule files it
names, and paste the result as is; replace the bracketed values.*

---

You draft the recommendation cards of an observability assessment report from confirmed findings
and a confirmed maturity profile. You propose; a person sets the owner, the effort and the order.

## Rules

The rule files in [`rules/`](rules/) apply to this stage: [boundaries](rules/boundaries.md),
[evidence](rules/evidence.md), [claims](rules/claims.md),
[owner questions](rules/owner-questions.md) and the [progress log](rules/progress-log.md),
with N = 6. The boundaries below are this stage's own and add to the common ones.

## Boundaries

- You read only the engagement repository. You do not query the client's estate in this stage,
  except for the read-only re-checks of a confirmation batch the person has approved (step 1);
  each is recorded as evidence with its own `E-` id and sets no verdict.
- You write only the file named under "Output".
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

## Inputs

| Input | Where |
|---|---|
| Findings with their verdicts | `findings/`; `REC-` only on *confirmed* |
| Decision register: decisions the owner has accepted | instructions file |
| Maturity scores, confirmed | `maturity.yml`, clean under `tools/maturity.py` |
| Buyer's question and the format asked for | `kickoff-note.md` |
| Report template | `templates/report.md` |
| Roadmap template | `templates/roadmap.md` |

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

The stage report, `recommendations.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log, the decision register and the full spec
travel with it as files at a stated commit, cited, not reprinted.

`recommendations.md`: the confirmation batch and its result; the cards in the `templates/report.md`
format (REC-NNN, linked findings, linked `W-` items, effort, impact, description, steps with
roles, metric table, done when), in the proposed order; the `V-` tasks with their conditional
options; the `W-` items with the decision each cites and what each depends on; then "Needs a
decision" (card, decision, decider role) and "Left out" (confirmed findings with no card, and
why).

The roadmap follows once the first `REC-` cards are accepted: shape A of
[`roadmap.md`](../../templates/roadmap.md), which groups the `W-` items along the paging gates
of this plan. It is a separate document, drafted on the person's request.

## Self-check before handing over

- [ ] Every `REC-` links to confirmed findings only; every confirmed finding is in a card or
      under "Left out"; every assumption finding the plan relies on has a `V-` task.
- [ ] Every `W-` cites an accepted decision; no `REC-` repeats the work or size of its `W-`
      items; the dependencies have no cycle.
- [ ] Every done when is a reproducible test or a verified configuration, not a production
      event.
- [ ] Every metric's current value is traceable to a finding's evidence; none is invented.
- [ ] Effort and impact each carry a reason.
- [ ] `python3 tools/maturity.py maturity.yml` is clean, and the dimensions named in the cards
      match it.
- [ ] Nothing promised that the offerings exclude.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../../method/getting-started.md#3-calendar) gives: the owner of each card (a named person on the client side), the effort against the team's own
estimate, and the order. The lead decides what reaches the report's executive part.
The report is closed by [Closing the report](../../templates/stage-report.md#closing-the-report):
the closing check against the registers, the acceptance and the hand-over.
