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

## Checklist — inventory (stage 1)

- [ ] One object per row, each with exactly one status (confirmed, differs, not found, not
      verifiable) against the code or configuration; the counts sum to the rows.
- [ ] Every reconciliation claim cites a query or the table row that holds its evidence.
- [ ] No secret, account identifier, endpoint or IP address is written.
- [ ] Every claim names its window and place, and says no more than its check: evaluation is
      not detection, absence is not a defect, an OK by the missing-data setting says so, a total
      is not attributed, a difference is not a cause.
- [ ] Confirmed blind spots are in the risk register with owners.
- [ ] The re-run sample is reported as "n of n selected checks reproduced", not as accuracy.

## Checklist — stage report form (`stage-report.md`)

- [ ] A reader understands the result from the first page.
- [ ] Every material claim leads to its evidence (`E-` id) and its window.
- [ ] Current decisions are read in the report, not rebuilt from its history; superseded ones
      are marked where cited.
- [ ] Decision, implementation and verification are stated apart.
- [ ] The decision register, the full spec and the progress log are cited by commit, not
      reprinted; earlier ids are kept, new ones added without renumbering.
- [ ] The Markdown reads without a special renderer; the PDF reads at normal zoom.
- [ ] The PDF was looked at: ids not broken across lines, tables, symbols, links, page
      numbers, headings, no cut text; `tools/report-pdf.sh` passed.

## Checklist — finding (`finding.md`)

- [ ] One finding, one claim; the title states it.
- [ ] Status and date; the source is an artefact (query, file:line, export), or the status is
      an assumption.
- [ ] Evidence level stated; "present" is backed by browser, agent or tenant evidence, not an
      inventory or a slide.
- [ ] *What we see* holds facts only; opinions are in *why it matters*.
- [ ] *Why it matters* names a customer or business consequence, not a tool property.
- [ ] *What follows* has an action, an owner and the maturity dimension it moves.
- [ ] Severity with its reason, confidence and limits, a closing criterion, and the three
      statuses (decision, implementation, verification).
- [ ] The claim is bounded before its verdict: window, scope, "not shown" rather than "none
      exists"; an absence read in part of the estate says what was not checked; a cause is
      bounded to the window read.
- [ ] The verdict is one of the five (confirmed, disputed with a reason, refuted, inconclusive,
      resolved) and set by the owner; "did not reproduce" is not read as refuted.
- [ ] No decision record stands as technical evidence; code with its version, or a query, is
      cited.
- [ ] Confirmed is not read as fixed, nor as an alert that passed the paging gate.
- [ ] Re-checks are read-only and in the evidence catalog with their own ids; an unexplained
      anomaly from a re-check is an observation of unknown cause, not a new finding.
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
- [ ] A level set before its findings' verdicts is marked provisional and re-read by a dated
      entry.
- [ ] Dimension 8 is read against the support mode the owner agreed; an unanswered question is
      "not confirmed by the evidence", not "no on-call".
- [ ] Wording stays within the evidence: "with at least partial telemetry", "continuous
      computation and tracking not shown".

## Checklist — journeys, error taxonomy, signals

- [ ] Every journey is decomposed into business functions; nothing is measured at journey level
      only.
- [ ] Every code or condition has exactly one class; overloaded codes are split or still
      `unknown`, and listed under gaps.
- [ ] Ambiguous means the outcome is unknown, and each ambiguous outcome has a reconciliation
      path.
- [ ] Refusals returned inside HTTP 200 are recognised.
- [ ] Each signal has a state (live / differs / to build / not verifiable) and the evidence
      for every state but "to build".
- [ ] No threshold on a metric that is not collected.
- [ ] Every function has a stable id, its requirement source and its current state with
      inventory evidence; unknowns are kept.
- [ ] Success is checkable: states (success, degraded, failure), the empty case and a time
      bound are written, or open with the owner.
- [ ] Each ambiguous outcome is reconciled per operation type, with acceptance scenarios
      (response lost after landing, source of truth unavailable, concurrent change, re-run).
- [ ] Layers (business, monitoring, synthetic) are mapped by exact ids in both directions;
      "defined in code" is not shown as live; dated document statements are not current state.
- [ ] Alert and check lists separate live, historical and planned.
- [ ] Every owner decision the document relies on is cited from the decision register; a
      decision does not stand in for evidence — the proof it relies on is checked too.
- [ ] Proof that an operation took effect links the change to that operation (key, own
      stamp); composite operations are settled per mutation and have their own scenario.
- [ ] Count SLIs separate no traffic from telemetry unknown; zero valid windows is "no
      estimate".
- [ ] The review bundle is built from the committed versions the document cites, each with
      its commit, and includes the confirmed baseline it cites.
- [ ] Each taxonomy row has a user impact; the functions with their own SLO were chosen by the
      owner.
- [ ] Each SLO has its budget in its own units, burn-rate alerts and a volume per window; an
      insufficient volume is marked; the budget policy is the owner's.
- [ ] The telemetry failure table says what each failure reads as today.
- [ ] Each P1 alert's detection is proven, has a written scenario, or is a residual risk with
      an owner; paging readiness is shown, not stated.
- [ ] Unagreed targets, owners and thresholds are `proposed`; a clean lint is not taken as
      acceptance.

## Checklist — SLOs and alerts (`spec-set/slo-alerts.md`)

- [ ] Good and valid are written per SLI; expected refusals are either good or excluded, with
      the reason.
- [ ] One bad predicate per SLI; ambiguous and unknown are bad until reconciled or classified.
- [ ] Every target has an owner who signs it, from the product side.
- [ ] Every P1 has an owner, a runbook, a delivery test, a minimum volume and a grouping; none
      fires on a pooled rate or on a host.
- [ ] New alerts start in shadow.
- [ ] Paging is admitted per alert, by its gate: alert quality (firing, missing data, recovery,
      delivery), response (primary and backup person, hours, acknowledgement, escalation),
      outside-in for synthetics, and a tested independent delivery path. A recorded test that
      missed a requirement is not a pass.
- [ ] With one responsible person, nothing pages unless an exception accepting the risk of no
      response is decided.
- [ ] Missing-data behaviour is set per input; blocked counts as bad in a synthetic SLI.

## Checklist — report (`report.md`)

- [ ] Page one answers the buyer's question in the buyer's words, in the format they asked for.
- [ ] The last page asks for a decision, with who decides and by when.
- [ ] Every statement in the executive part traces to a finding.
- [ ] Limitations say what the data cannot tell us.
- [ ] Recommendations are ordered by impact over effort and each links to findings.
- [ ] `REC-` only on confirmed findings; `V-` for assumptions, with the fix only as a
      conditional option; `W-` cites an accepted decision; no `REC-` repeats its `W-` items'
      work or size; no dependency cycle.
- [ ] Each recommendation closes on a reproducible test and a verified configuration, not on a
      production event; S, M and L are not read as durations.
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
