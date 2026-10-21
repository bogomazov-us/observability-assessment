# Assessment playbook

How an assessment is actually run. Each step names its output and the template behind it.

## Principles

1. **Diagnosis over outcome count.** A start/outcome pair per journey tells you *that* something
   broke, not *where*. Signals are defined per business function (sign-in authenticate, search
   request, booking hold, booking complete…), each with typed failures.
2. **Expected is not failure.** Many "errors" are the product working: wrong password, no
   availability, a business refusal. Classify every code: expected / failure / caller defect /
   ambiguous / unknown. Unknown counts as bad until classified.
3. **Evidence levels.** A signal is *present* only with evidence: seen in the browser, seen in the
   beacon / agent, or queried in the tenant. An inventory or a slide is not evidence.
4. **No threshold on a gap.** A metric that is not collected cannot be green.
5. **Facts carry a status and a date.** Confirmed / disputed / refuted, never deleted. Decisions
   go into ADRs; changes of understanding go into a changelog ("what we thought, what turned out,
   what we had to redo").
6. **Build on the client's work.** Most clients already ran an investigation or have an internal
   tool. Position the assessment as building on it, or it is seen as a repeat. Boundary checklist: `templates/ai-ops-boundary.md`.

## Week by week (six-week full format; compress for the focused one)

| # | Step | How | Output | Template |
|---|---|---|---|---|
| 1 | Read the client's documents and challenge them | Review their strategy against code and tenant before accepting it: keep / major challenges / smaller notes / recommendation | Review note | `templates/finding.md` |
| 2 | Intake | Questionnaire by owner (monitoring tool team, platform, SRE/NOC, product); ask for exports and screenshots, not opinions | Answers + exports | `templates/intake-questionnaire.md`, `templates/data-request.md` |
| 3 | Read the code | RUM coverage, error handling path, source maps, correlation headers, logging pattern, how business refusals are returned (HTTP 200 with errors?) | Code findings | `templates/finding.md` |
| 4 | Inventory the tenant and tools | Export apps, hosts, services, RUM apps, alerts, dashboards, alerting profiles, integrations; reconcile exports with each other | Inventory + findings | `templates/finding.md` |
| 5 | Score maturity | 12 dimensions, 5 levels, each score justified with evidence; name the actions that move the score fastest | Maturity table | `method/maturity-model.md` |
| 6 | Capture journeys | Real journeys as HAR captures (sanitized — a raw HAR is a credential dump), decomposed into business functions | Journey catalog | `templates/spec-set/userjourneys.md` |
| 7 | Map signals | Function → signal → SLI → threshold → alert → owner → playbook; three evidence levels; verification backlog grouped by type of work | Signal matrix | `templates/spec-set/signals.md` |
| 8 | Diagnose | Per function: what is seen, what is missing, how errors travel, what is pooled | Findings with evidence | `templates/finding.md` |
| 9 | Prove one golden journey | Instrument one journey end to end on stage | Demo + evidence | — |
| 10 | Operating model | Alert ownership, severity, hypercare, release check, firing review | Alert and ownership model | `templates/spec-set/slo-alerts.md` |
| 11 | Report and roadmap | In the format the buyer asked for; decision request on the last page | Report, roadmap, 30/60/90 | `templates/report.md`, `templates/roadmap.md` |
| 12 | Commitment baseline (if continuing) | Quantified deliverables and an explicit "not promised" list | Baseline | `templates/commitment-baseline.md` |

## Working rules for the team

- **One knowledge base per engagement** (00–09 structure: engagement, state, findings,
  decisions, risks, actions, deliverables, client input, technical, comms) with a status-carrying
  facts ledger. A Markdown table in the engagement repository is enough to start; see
  [getting-started.md](getting-started.md).
- **Every finding has a source and a "why it matters / what follows".**
- **Reviews in rounds.** Significant deliverables go through written review rounds with verdicts;
  the final round states what is approved and what is still evidence to collect. Round record
  and checklists: `templates/review.md`.
- **Client confidentiality.** Nothing from one client goes into another client's deliverable;
  reuse goes through this kit, sanitized.
