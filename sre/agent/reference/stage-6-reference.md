# SRE stage 6 reference — recommendations

*Reference for [SRE stage 6](../stage-6-recommendations.md). `prompt.sh --assessment sre 6` does
not append it; the prompt names it at steps 6–9 and the Output, and the agent reads a step's
section here before doing the step. A rule here binds as if it were in the prompt.*

## 6. Roadmap

Shape A of [roadmap.md](../../../templates/roadmap.md), its rules as they are. For SRE:

- **A milestone holds what one target needs,** in the cards' order: for example, the restore
  tests of the tier-1 data stores, or progressive delivery with automatic halt on one service.
  The targets are the `T-` rows; a target with no agreed value waits on its decision.
- **Every `W-` item sits in exactly one milestone;** dependencies point only to earlier ones;
  one accountable role per milestone.
- **The exit result is checkable:** a recorded test with its date (a restore within RTO and
  RPO, a rollback, a game day), or a configuration read. A drill is run by the client's people;
  the roadmap never assigns it to the agent.
- **Effort is a range of engineer-days** per milestone, from a size mapping stated in the scope
  as an assumption (for example S, M, L to day ranges). No dates until the executor's
  availability is known: the status is "draft; no dates".
- **What each milestone moves** on the profile, with the model: "SRE dimension 9: restore
  untested for two of four data stores". No level change one milestone alone cannot show.
- **Verification tasks** (`V-`) go into a milestone or a track of their own, and say which later
  milestone their verdict can change.

## 7. The other assessment type

Propose a full observability assessment when SRE dimension 3 is at level 2 or below in the
confirmed profile, or not scored for want of monitoring evidence:

- as an option of the decision request, not as a `REC-` card;
- citing the dimension-3 level and the confirmed findings behind it;
- saying what it would answer that this assessment could not (alert quality, SLIs, telemetry
  coverage), and that its own estimate comes from the [offerings](../../../offerings.md).

Not in the combined format: the observability assessment is already part of it.

## 8. Decision request

As in section 8 of [report.md](../../../templates/report.md), on a page of its own: the decision
in one sentence; the options, if there are several (for example: start the first milestones,
take the recovery proof, commission the other assessment type); who decides; by when. For a
buyer who asked for a short, focused answer, keep to the cards that answer the question.

## 9. Combined format

- **One roadmap and one decision request for both types,** drafted in this file once the
  observability `REC-` cards are confirmed. Until then, draft the SRE part and say what the
  rest waits on.
- **One sequence per id type:** take the next free `REC-`, `V-` and `W-` ids after those in the
  observability `recommendations.md`, so no id appears twice in the report.
- **Milestones may hold items of both types;** each names the dimensions it moves with their
  model ("observability dimension 7", "SRE dimension 6").
- The summary carries this roadmap and decision request; the observability recommendations do
  not repeat them.

## Output

`sre/recommendations.md`, in this order:

1. The confirmation batch and its result.
2. The cards in the `templates/report.md` format, in the proposed order.
3. The `V-` tasks with their conditional options.
4. The `W-` items with the decision each cites and what each depends on.
5. The roadmap: the two tables and a card per milestone of
   [roadmap.md](../../../templates/roadmap.md).
6. The decision request.
7. "Needs a decision": card, decision, decider role.
8. "Left out": confirmed findings with no card, and why.
