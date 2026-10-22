# Maturity model

Five levels: **1 Opportunistic · 2 Developing · 3 Engaging · 4 Sustainable · 5 Transformative**.
The model scores **what the organisation can do**, not which technology it uses: any source
that produces the capability counts (business events, structured logs, spans, database records).
Report it as a profile, never as one number.

## Scoring rules

1. **Scope first.** Write down the journeys and services in scope before scoring. "Tier-1" in
   the table below means the functions in that scope.
2. **The score is the highest level whose criteria are fully evidenced** for the functions in
   scope, provided the capabilities of the levels below it still hold. Cells that describe an
   absence ("none", "no owners") are starting points, not requirements. Criteria that hold for
   only some functions give **partial**: score the level below and write the coverage
   ("level 3 on 2 of 5 functions").
3. **Evidence per score.** Each score names its evidence: an export, a query, a trace, a code
   path, a configuration. Level 1 too: the export or query that came back empty — a level
   nobody looked for is *not scored* (rule 4), not level 1. Interviews and documents alone are not enough to go above level 2.
4. **Not scored** when the evidence could not be obtained (no access, no answer in time). It is
   not level 1; it is a gap, and it goes into the findings with the reason.
5. **N/A** when the dimension does not apply and the client agrees, with one sentence why
   (for example dimension 12 when the client does not intend to use operational analytics).
   N/A dimensions are left out of the profile.
6. **Confidence** per score:
   - **high** — tool evidence (export, query, trace) covering all functions in scope;
   - **medium** — tool evidence for a sample, or one source not cross-checked;
   - **low** — interviews or documents only (caps the score at 2, rule 3).
7. **No overall average.** Show the profile. If a summary is asked for, give the distribution
   ("4 dimensions at 2, 6 at 3, 1 not scored") and the three dimensions that block the next
   step; if a single number is unavoidable, state the weights and have the client agree them.

Report per dimension: level, coverage, evidence, confidence, and Highlights / Keep an eye on /
Lowlights.

Record the scores in `templates/maturity.yml`; the [maturity calculator](../tools/maturity.md)
checks them against these rules and prints the profile.

## Dimensions

| # | Dimension | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 1 | Business-function model | No journeys defined; faults reported by customers | Journeys listed, no functions or owners | Tier-1 journeys decomposed into functions with owners | Every function has a signal, SLI and threshold | Model maintained with the code (story template, release check) |
| 2 | Telemetry coverage | Infrastructure metrics only | Some services and the front end partly covered | All tier-1 components emit telemetry | Coverage measured: share of tier-1 calls linked end to end in a controlled run, with the denominator stated | Coverage is a release gate |
| 3 | Error semantics | HTTP status only | Some codes logged | Codes classified expected / failure on critical paths | Full taxonomy, ambiguous outcomes identified; refusals inside HTTP 200 recognised | Taxonomy enforced in code review |
| 4 | Correlation | None | Request IDs in some logs | Correlation ID end to end on tier-1 | Front end → service → downstream linked for tier-1 functions | Investigations that cross services use the linkage routinely (sampled in post-incident reviews) |
| 5 | Business outcome data | No outcome data outside the database | Outcomes reconstructable by hand (analytics, ad-hoc queries) | Outcome per critical step available to monitoring from some source | Outcome, error class and IDs per attempt, used in SLIs | Outcome data drives product and operations decisions |
| 6 | SLOs | None | Availability targets in contracts only | SLOs on some journeys | SLOs on all tier-1 functions, valid and good defined per SLI, error budgets tracked | Error-budget policy changes release decisions |
| 7 | Alert quality | Host and threshold alerts, noisy | Some per-service alerts; no owners | Per-function alerts with owners | Every alert has owner, sample rule, runbook; actionable share measured | Actionable share at the agreed target; reviewed weekly |
| 8 | Incident response | Ad hoc | On-call exists, no roles | Roles, severity levels, post-incident reviews | Blameless reviews with deadlines; detection and recovery times measured | Exercises run; recurrence tracked |
| 9 | Outside-in checks | None | Uptime checks | Synthetic check on tier-1 entry; real-user data on the main app | Synthetic per tier-1 journey from two locations | Synthetic and real-user results tied to SLOs |
| 10 | Release observability | None | Deploy markers | Release compared before / after | Release check: every release proves its signals | Automated gate |
| 11 | Data governance and cost | Retention, sampling, personal data unknown | Known but undocumented | Documented; personal data scrubbed | Cost and sampling managed per signal | Telemetry budget is a product decision |
| 12 | Operational analytics (optional, N/A allowed) | None | Vendor anomaly detection on defaults | Anomaly detection tuned; correlation used | Assisted investigation with read-only tool access | Assisted remediation on proven alert quality |

Dimension 12 is not required for reliable operations; score it only when the client wants it.

**Dimension 8 is read against the agreed support mode.** Ask the hours of use and who is
responsible in them (intake, question 17). A service used in working hours only, with
off-hours notifications reviewed the next working day, has no off-hours on-call by agreement,
and that is not a defect; the mode is reviewed if the hours widen. Until the owner answers,
the absence of on-call is "not confirmed by the evidence", not a fact.

**Levels before the verdicts.** Stage 5 may set levels provisionally before the findings they
rest on have their verdicts. A verdict can change a level's scope, confidence or the level
itself; the level is re-read and the change recorded as a dated entry, not overwritten.

**Wording that stays within the evidence.**

- Telemetry that covers part of a success criterion is not coverage of it: write "with at
  least partial telemetry".
- No rules and no dashboards for an SLO do not exclude another implementation: write
  "continuous computation and tracking not shown", not "nothing computes an SLO".

**Dimension 12 in sequence.** Analytics is only as good as its inputs, so:

1. Fix and check the chosen input series first, with only that series' own dependencies.
   Start with one or two series whose density and meaning are stable; a longer list is
   candidates, not a commitment.
2. A heartbeat shows that telemetry arrives; it does not replace anomaly detection. For
   functions with little traffic, add deterministic synthetics.
3. A defect in an input reaches a model only if the model uses that computation; say which.
   Deploy windows may be treated apart when a model is trained, but are never removed from a
   user SLI.
4. Level 2 is done when the inputs, their missing-data behaviour, firing and delivery in shadow
   are checked, the history is reviewed and the limits are written.
5. Four weeks of history is a starting window, not proof of level 3; level 3 needs breaches
   that were classified and a shown use of correlation.
6. Do not call the cost small before the spend is attributed to the series and the models.

## Example row

| Dimension | Level | Coverage | Evidence | Confidence |
|---|---|---|---|---|
| 3 Error semantics | 2 (partial 3) | expected / failure classified on 1 of 3 functions | payment service error handler; 7-day span query | high |

**What moves the score fastest** — list, for the client, the three or four actions that lift the
most dimensions for the least effort (typically: error classification, correlation ID, per-function
alerts with owners, a release check).
