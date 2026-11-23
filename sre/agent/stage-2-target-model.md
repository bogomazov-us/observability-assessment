# Stage 2 — SRE target model

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 2`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You draft the target model of an SRE assessment: the tier of each service in scope and the
reliability targets (`T-` rows) per tier, or per service where one differs. You draft; a person
confirms.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md),
[owner questions](../../tools/agent/rules/owner-questions.md) and the
[progress log](../../tools/agent/rules/progress-log.md), with N = 2. The boundaries below are this stage's
own and add to the common ones.

## Boundaries

- Read-only. You never write to the client's delivery pipeline, incident tracker, paging
  tool, backup console or monitoring configuration, and you run no drill or load test.
- You set no tier and no target. Every row enters as `proposed`; a kit default is marked
  *default, to confirm*; every value an owner must set is an owner question.
- Every tier and every candidate value cites its source: a catalogue row (`S-`), a stated need
  (the kick-off note, an interview `E-` id, a contract or policy with its date), or the
  [SRE maturity model](../maturity-model.md#dimensions) for a default.

## Inputs

| Input | Where |
|---|---|
| Critical journeys and scope, as agreed at kick-off | `kickoff-note.md`, decision register |
| Service catalogue (stage 1, confirmed) | `sre/service-catalogue.md` |
| Inventory and exports by object class (stage 1) | `sre/inventory.md`, `sre/exports/` |
| The client's stated needs: contracts, policies, interview notes | decision register, facts ledger, [path] |
| Targets template | `sre/templates/reliability-targets.md` |
| Combined format: the observability spec and its SLO rows | `spec/observability-spec.yml` |
| Facts ledger | instructions file |

## Method

Every step has its full rule, cases and tables under its number in the
[stage 2 reference](reference/stage-2-reference.md) (in the kit, `sre/agent/reference/`).
Read it before the step; it binds as if it were here.

0. **Sources agree first.** Where the sources disagree on what is critical, stop and hand
   the person a table; draft only after the owner has reconciled them.
1. **Tiers from journeys.** Propose a tier for every `S-` row, with the reason: tier 1 serves a
   critical journey in scope.
2. **Dependencies follow the tier.** Every dependency of a tier-1 service gets a proposed tier;
   a tier-1 service on a lower-tier or untiered dependency is listed as a gap.
3. **Defaults first.** Enter the default rows (on-call limit, toil cap, actionable alert
   share), each *default, to confirm*.
4. **Targets per tier.** SLO, RTO, RPO and rollout policy have no default: the value is the
   owner's, the stated needs are its candidates. So is a target level per dimension in scope.
5. **A service where it differs**, and RTO and RPO per tier-1 data store.
6. **SLOs cite, not redefine.** Each SLO follows the spec rules; in the combined format it
   cites the observability spec's SLO id.
7. **Measurable or not.** Each target names the export that measures it, or *no source*.
8. **Names first.** Service and tier names go into the glossary in the client's words.
9. **One question per value** the owner must set, in the batch format, tiers first.

## Output

The stage report, `sre/target-model.md`, follows [`stage-report.md`](../../templates/stage-report.md)
with the chain service → tier → target → owner → decision; the progress log, the decision
register and the targets file travel with it as files at a stated commit, cited, not
reprinted. Field rules and columns are in the
[reference, Output](reference/stage-2-reference.md#output).

1. `sre/targets/reliability-targets.md`, from the template: default rows, target rows, the
   SLO definitions (SRE only), the glossary and "Not agreed", every row `proposed`.
2. `sre/service-catalogue.md`: the Tier column set to *proposed* values; no other column
   changed.
3. `sre/target-model.md`, around the resulting model, not the rounds that produced it.
4. The owner question batch, added to the engagement's owner questions file.

**Combined format.** The owner questions, the findings and the decision register are shared:
one `Q-` sequence, one batch, one targets review.

## Self-check before handing over

- [ ] Every `S-` row in scope has a *proposed* tier, with its reason and source.
- [ ] Every tier-1 dependency has a proposed tier or a line in the gap list.
- [ ] Tier 1 has a row of each kind: SLO, RTO, RPO, rollout policy, on-call limit, toil cap,
      actionable alert share.
- [ ] Every `T-` row is `proposed`, with an empty Decision; a default is *default, to
      confirm*; no other value is filled in by you.
- [ ] Every value the owner must set has an owner question: plain words, one decision, what it
      blocks, candidates none chosen, each with its source.
- [ ] Every SLO states its SLI, budget and window by the spec rules, or cites the observability
      spec's id; no SLO is defined twice.
- [ ] Every value filled in where a decision left it open is marked as a reading.
- [ ] When a later decision changed the basis of an earlier one (a window, a unit, a cadence),
      every value derived from the earlier one was re-derived and returned to `proposed`
      with a question, not carried over.
- [ ] No row is renumbered; a changed target is a new row naming the one it supersedes.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives: each tier against the journeys and its
owner's answer; each target against its decision register row (only rows with a `D-` row become
`confirmed`, set by the lead). The confirmed rows go into the facts ledger with their source;
the rest stay assumptions with an owner and a date. On confirmation the lead rewrites the
summary and adds this stage's lines to the manifest ([report](../README.md#report)).
