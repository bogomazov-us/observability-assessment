# Review — round record and checklists

Significant deliverables go through written review rounds with verdicts (playbook, working
rules). This file is the record of one round and the checks a reviewer runs. Copy it per
deliverable and round. A reviewer who needs the author in the room to judge a check has found a
gap in the deliverable, or in the kit.

## Round record

| Deliverable | Version or commit | Round | Reviewer | Author | Date |
|---|---|---|---|---|---|
| [report / findings / maturity / spec set / roadmap] | [v or hash] | [1 of 2] | [role] | [role] | YYYY-MM-DD |

| # | Where | Check failed or remark | Severity | Verdict on the item | Answer (author) |
|---|---|---|---|---|---|
| R1 | [file:line or section] | [what is wrong, and which check below] | blocking / non-blocking | open / closed / accepted as a known limitation | [what was changed, or why not] |

**Round verdict:** approved · approved with changes (non-blocking only; no further round) ·
rework (at least one blocking item; another round).

**Final round** states, in two lists: what is approved, and what is still evidence to collect
(with owner and date). A blocking item is never closed by argument alone: it is closed by a
change, or written down as a known limitation the buyer sees.

**Severity.** *Blocking*: the deliverable states something its evidence does not support,
misleads the buyer, or cannot be acted on. *Non-blocking*: wording, order, missing cross-links.

## Checklist — finding (`finding.md`)

- [ ] One finding, one claim; the title states it.
- [ ] Status and date; the source is an artefact (query, file:line, export), or the status is
      an assumption.
- [ ] Evidence level stated; "present" is backed by browser, agent or tenant evidence, not an
      inventory or a slide.
- [ ] *What we see* holds facts only; opinions are in *why it matters*.
- [ ] *Why it matters* names a customer or business consequence, not a tool property.
- [ ] *What follows* has an action, an owner and the maturity dimension it moves.
- [ ] Nothing in it identifies another client.
- [ ] No personal data in the evidence quoted (`templates/privacy-checklist.md`).

## Checklist — maturity profile (`method/maturity-model.md`)

- [ ] Scope (journeys, services) written before the scores.
- [ ] Each level is the highest one whose criteria are fully evidenced; partial coverage is
      scored at the level below with the coverage written out.
- [ ] Every score names its evidence; nothing above level 2 rests on interviews or documents.
- [ ] Not scored and N/A are used as defined, with the reason; neither is shown as level 1.
- [ ] Confidence per score, consistent with the evidence.
- [ ] No overall average; the three dimensions that block the next step are named.

## Checklist — journeys, error taxonomy, signals

- [ ] Every journey is decomposed into business functions; nothing is measured at journey level
      only.
- [ ] Every code or condition has exactly one class; overloaded codes are split or still
      `unknown`, and listed under gaps.
- [ ] Ambiguous means the outcome is unknown, and each ambiguous outcome has a reconciliation
      path.
- [ ] Refusals returned inside HTTP 200 are recognised.
- [ ] Each signal has a state (live / to build) and the evidence that shows "live".
- [ ] No threshold on a metric that is not collected.

## Checklist — SLOs and alerts (`spec-set/slo-alerts.md`)

- [ ] Good and valid are written per SLI; expected refusals are either good or excluded, with
      the reason.
- [ ] One bad predicate per SLI; ambiguous and unknown are bad until reconciled or classified.
- [ ] Every target has an owner who signs it, from the product side.
- [ ] Every P1 has an owner, a runbook, a delivery test, a minimum volume and a grouping; none
      fires on a pooled rate or on a host.
- [ ] New alerts start in shadow.

## Checklist — report (`report.md`)

- [ ] Page one answers the buyer's question in the buyer's words, in the format they asked for.
- [ ] The last page asks for a decision, with who decides and by when.
- [ ] Every statement in the executive part traces to a finding.
- [ ] Limitations say what the data cannot tell us.
- [ ] Recommendations are ordered by impact over effort and each links to findings.
- [ ] The client's own investigation or tool is acknowledged and built on.

## Checklist — roadmap and commitment baseline

- [ ] Every milestone has one accountable owner and closes by a demonstration, with the evidence
      named.
- [ ] Effort carries its assumptions; each assumption is in the facts ledger.
- [ ] The critical path and the schedule risk with its fallback are named.
- [ ] Every baseline line is measurable at go-live; "not promised" is explicit.

## Checklist — specification set (Blueprint)

- [ ] All nine documents exist; each "must contain" item in `spec-set/README.md` is present or
      marked open with an owner.
- [ ] The worked chain holds for every tier-1 function: journey → function → signal → SLI →
      threshold → alert → owner → runbook.
- [ ] Every claim of the spec has an acceptance scenario that can be run on stage.
- [ ] The instrumentation contract can be followed by a developer who was not in the room.
