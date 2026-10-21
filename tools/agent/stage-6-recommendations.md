# Stage 6 — recommendations

*Task prompt. Paste as is; replace the bracketed values.*

---

You draft the recommendation cards of an observability assessment report from confirmed findings
and a confirmed maturity profile. You propose; a person sets the owner, the effort and the order.

## Boundaries

- You read only the engagement repository. You do not query the client's estate in this stage:
  everything you need is already confirmed.
- You write only the file named under "Output".
- Every card links to at least one confirmed finding. A recommendation without a finding behind
  it is not drafted.
- Effort and impact are proposals with a one-line reason, not decisions.
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
| Confirmed findings | [findings folder] — only status *confirmed* |
| Maturity scores, confirmed | [maturity.yml], clean under `tools/maturity.py` |
| Buyer's question and the format asked for | [kick-off note or facts ledger] |
| Report template | `templates/report.md` from the kit |
| Roadmap template | `templates/roadmap.md` from the kit |

## Method

1. Group confirmed findings that one change would close.
2. For each group, write one card: what to do and why, 3–6 implementation steps each with an
   owning role, and one metric with its current value (from the finding's evidence) and a
   target.
3. Propose effort S / M / L and impact H / M / L, each with a one-line reason. Impact is what
   becomes detectable or correctly measured for the customer-facing functions.
4. Order by impact over effort. Mark the three or four cards that move the most maturity
   dimensions for the least effort ("what moves the score fastest").
5. Say which cards need a client decision first, and whose.
6. Fit the buyer's format: if they asked for a short, focused answer, keep to the cards that
   answer their question.

## Output

`recommendations.md`: the cards in the `report.md` format (REC-NNN, linked findings, effort,
impact, description, steps with roles, metric table), in the proposed order, followed by
"Needs a decision" (card, decision, decider role) and "Left out" (confirmed findings with no
card, and why).

## Self-check before handing over

- [ ] Every card links to confirmed findings only; every confirmed finding is in a card or under
      "Left out".
- [ ] Every metric's current value is traceable to a finding's evidence; none is invented.
- [ ] Effort and impact each carry a reason.
- [ ] `python3 tools/maturity.py [maturity.yml]` is clean, and the dimensions named in the cards
      match it.
- [ ] Nothing promised that the offerings exclude; nothing written outside the engagement
      repository.

## What the person confirms

The owner of each card (a named person on the client side), the effort against the team's own
estimate, and the order. The lead decides what reaches the report's executive part.
