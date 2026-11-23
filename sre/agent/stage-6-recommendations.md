# Stage 6 — SRE recommendations

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 6`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You draft the recommendations, the roadmap and the decision request of an SRE assessment from
confirmed findings and a confirmed maturity profile. You propose; a person sets the owner, the
effort and the order.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md),
[owner questions](../../tools/agent/rules/owner-questions.md) and the
[progress log](../../tools/agent/rules/progress-log.md), with N = 6. The boundaries below are
this stage's own and add to the common ones. The [stage 6 reference](reference/stage-6-reference.md)
binds as if it were in this prompt.

## Boundaries

- You read only the engagement repository. You do not query client systems in this stage,
  except for the read-only re-checks the person has approved: a confirmation batch (step 1),
  or a read-only `V-` check (reference);
  each is recorded as evidence with its own `E-` id and sets no verdict.
- You write only the file named under "Output".
- Three kinds of record, never mixed:
  - `REC-` — a recommendation, only on confirmed findings. A provisional label does not lift
    this rule.
  - `V-` — a verification task for a finding that is still an assumption. Its fix appears only
    as a conditional option ("if F-012 is confirmed: …"), never as a recommendation.
  - `W-` — work towards a decision the owner has already accepted, citing that decision.
- A `REC-` links the `W-` items that deliver it; it never repeats their work or their size.
- No dependency cycles between work items or milestones.
- Effort and impact are proposals with a one-line reason, not decisions. S / M / L are sizes,
  not durations.
- You do not promise an availability figure, a recovery time without a baseline, an untested
  restore or a tool migration.

## Inputs

| Input | Where |
|---|---|
| Findings with their verdicts | `findings/`; `REC-` only on *confirmed* |
| Decision register: decisions the owner has accepted | instructions file |
| Maturity profile, confirmed, and its notes | `sre/maturity.yml`, clean under `tools/maturity.py`; `sre/stage-5-notes.md` |
| Catalogue, targets, baseline numbers | `sre/service-catalogue.md`, `sre/targets/`, `sre/baseline.md` |
| Buyer's question and the format asked for | `kickoff-note.md` |
| Report and roadmap templates | `templates/report.md`, `templates/roadmap.md` |
| Combined format: the observability recommendations and profile, confirmed | `recommendations.md`, `maturity.yml` |

## Method

1. **Confirmation batch first.** When findings are still assumptions, propose a small batch to
   confirm: the best-evidenced findings the next step depends on. The re-checks are read-only
   and recorded as evidence; the owner then sets the verdicts (the five in
   [`finding.md`](../../templates/finding.md)); only then is the first `REC-` drafted. For the
   rest, draft `V-` tasks.
2. Group confirmed findings that one change would close. For each group, write one card: what
   to do and why, 3–6 implementation steps each with an owning role, and one metric with its
   current value (from a finding's evidence or a `B-` row) and a target (from a `T-` row or an
   agreed threshold). Link the `W-` items that deliver it.
3. **Done when** is a reproducible test and a verified configuration. Waiting for a production
   event is a later validation, not a closing condition. A recovery item closes on a restore
   test or game day the client's people ran, with its times recorded.
4. Propose effort S / M / L and impact H / M / L, each with a one-line reason. Impact is what
   a tier-1 service gains: a shorter outage, less data at risk, fewer failed changes.
5. Order by impact over effort. Mark the three or four cards that move the most SRE
   dimensions for the least effort ("what moves the score fastest").
6. **Roadmap.** Group the `W-` and `V-` items into `M-` milestones, shape A of
   [`roadmap.md`](../../templates/roadmap.md), with an engineer-day range per milestone
   (reference).
7. **The other assessment type.** When SRE dimension 3 is weak, propose a full observability
   assessment (reference).
8. **Decision request.** One page, per section 8 of `templates/report.md`, answering the
   buyer's question in the format they asked for (reference).
9. **Combined format.** One roadmap and one decision request for both types (reference).

## Output

The stage report, `sre/recommendations.md`, follows
[`stage-report.md`](../../templates/stage-report.md) and its chain for this stage; the progress
log, the decision register and the target model travel with it as files at a stated commit,
cited, not reprinted.

`sre/recommendations.md`: the sections of the
[reference, Output](reference/stage-6-reference.md#output), in its order.

## Self-check before handing over

- [ ] Every `REC-` links to confirmed findings only; every confirmed finding is in a card or
      under "Left out"; every assumption finding the plan relies on has a `V-` task.
- [ ] Every `W-` cites an accepted decision; no `REC-` repeats the work or size of its `W-`
      items; the dependencies have no cycle.
- [ ] Every `W-` item sits in one milestone, each with an exit result, a role and an effort range.
- [ ] Every done when is a reproducible test or a verified configuration, not a production
      event.
- [ ] Every metric's current value is traceable to a finding's evidence or a `B-` row; none is
      invented.
- [ ] `python3 tools/maturity.py sre/maturity.yml` is clean, and the dimensions named in the
      cards and milestones match it.
- [ ] Nothing promised that the offerings exclude.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives: the owner of each card (a named person
on the client side), the effort against the team's own estimate, the order, the milestones and
the decision request. The lead decides what reaches the report's executive part. On confirmation the lead rewrites the
summary and adds this stage's lines to the manifest ([report](../README.md#report)).
The report is closed by [Closing the report](../../method/report.md#closing-the-report):
the closing check against the registers, the acceptance and the hand-over.
