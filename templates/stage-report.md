# Stage report — skeleton

One skeleton for the report of every stage. It gives two levels of reading from one set of
sources: the **main report**, read in order, supports a decision; the **evidence bundle** lets
a reviewer check each claim by its id. The current state comes first. How the document got
there (review rounds, earlier answers, the progress log) is history, kept in an appendix or a
file of its own and never needed to read the result.

| Main report | Evidence bundle |
|---|---|
| Result, conclusions, decisions, limits | Queries and their output, inventory rows, scenarios |
| Read in order; short tables | Navigated by stable ids |
| Markdown and PDF | Markdown and YAML; PDF when asked |
| The current version of the model | History, reviews, technical detail |

The decision register, the full spec (YAML) and the progress log travel **with** the report as
files at a stated commit. The report cites them; it does not reprint them.

---

```markdown
# Observability assessment — stage N: [name]

Project: [name] · Version: [commit] · Date: [date, time zone]
Document status: draft | accepted · Baseline: [versions of the earlier stages it relies on]

## 1. Result

[What was established and what decision the document supports. The reader understands the
result from this section alone.]

| | |
|---|---|
| Checked | [what, how many, in which window] |
| Main limits | [what this stage could not establish] |
| Next step | [the decision or stage that follows] |

## 2. Scope and method

- In scope: …
- Out of scope: …
- Observation window: …
- Sources and their versions: [commits, configuration revisions, snapshot times]
- Limits of the check: …

## 3. Main results

| ID | Object or function | Result | Evidence |
|---|---|---|---|
| G-01 | … | … | E-001, E-002 |

## 4. Records

### G-01 — [one specific claim]

- **Observed:** [what was established directly]
- **Expected:** [the requirement, with its spec row or decision]
- **Difference:** [how the observation departs from it]
- **Consequence:** [for the user or the operator]
- **Evidence:** E-001, E-002
- **Confidence:** high | medium | low
- **Limits:** [what the evidence does not establish]
- **Next action:** [a check, a decision or a recommendation]
- **Done when:** [the observable result]

## 5. Decisions and open questions

| ID | Question or decision | Owner | Status |
|---|---|---|---|
| D-01 | … | … | proposed / accepted / superseded by D-NN |

## 6. Conditions to complete the stage

- [a condition someone can check]

## Appendix A. Evidence catalog

### E-001 — [name of the check]

- Source: …
- Checked at: [timestamp]
- Data window: …
- Code or configuration version: …
- Method: …
- Result: …
- Limits: …

    [the short query or command, without secrets]

## Appendix B. Changes in this version

| Version | What changed |
|---|---|
```

## A filled example

What a filled report looks like, in short. The project is fictional.

> **Observability assessment — stage 3: gap** · Project: Shopfront · Report version: `4e1a9c2`
> · Content version: `4e1a9c2` · Date: 2027-03-04 (CET) · Document status: draft · Baseline:
> stage 2 accepted at `b71d0e5`
>
> **1. Result.** Of the 9 signals of checkout, 4 are live, 3 differ and 2 are to build. The
> P1 alert on payment failures cannot fire on a first failure, so a payment outage shorter than
> one scrape reaches no one. Checked: production, 2027-02-25 → 03-04. Main limit: the payment
> provider's own status was not readable. Next step: findings (stage 4).
>
> | ID | Function | Result | Evidence |
> |---|---|---|---|
> | G-01 | `checkout.pay` | Alert reads a counter created by its first failure; never fired | E-301, E-302 |
> | G-02 | `checkout.confirm` | Signal differs: no outcome attribute | E-303 |
>
> **G-01 — The payment alert cannot see a first failure.** *Observed:* 3 payment failures on
> 02-27, each the first sample of its series; the rule did not fire (E-301). *Expected:* a P1
> on any payment failure (decision D-04). *Difference:* the first event is the baseline.
> *Consequence:* a short payment outage reaches no one. *Confidence:* high. *Limits:* a
> second failure in the same series was not observed. *Next action:* initialise the counter at
> 0; scenario S2 on staging. *Done when:* S2's first failure fires the alert.
>
> **E-301 — Payment failure series and the rule's state.** Source: metrics store. Checked at:
> 2027-03-04 10:12 CET. Window: 7 d. Method: raw series and `increase()` per 5 min. Result:
> 3 series, each first seen at value 1; `increase()` 0 at every step. Limits: one store; the
> provider's side not read.

## One report for the whole assessment

The client reads two documents, not one per stage and per round: the **assessment report**,
which grows by a chapter as each stage is accepted, and the **evidence bundle**. The sources stay
per stage — agents write and reviewers accept them stage by stage, and a stage is fixed at its
commit — and the two documents are built from them by `tools/assessment-pdf.sh` with a manifest:

```text
report    summary.md
report    stage-1-report.md    1 2 3 5
report    stage-2-report.md    1 2 3 5
report    recommendations.md
evidence  stage-1-report.md    4 A
evidence  stage-2-report.md    4 A
evidence  stage-6-rechecks.md
```

- **The report** opens with the current state, in a short file of its own (`summary.md`): the
  profile, the confirmed findings, the recommendations, the decisions waiting on the client. It
  is rewritten at each stage; the chapters below it are not. Each stage gives its result, main
  results and decisions (sections 1, 2, 3, 5); records and catalog go to the bundle.
- **The bundle** holds the records and every evidence catalog. Stages keep their own `E-` ranges
  (stage 1 E-1xx, stage 2 E-2xx …), so the catalogs join without renumbering; an id cited in the
  report must resolve in the bundle, or the build fails.
- **Working files** — question lists, confirmation batches, drafts, review rounds — stay in the
  engagement's repository as history. They reach the client through the result they produced.
- The version of both is the commit in the footer; the change history is one table in
  `summary.md`, a row per stage and per accepted change.

## Statuses are kept apart

| Dimension | Values |
|---|---|
| Decision | proposed / accepted / superseded |
| Implementation | absent / partial / implemented |
| Verification | untested / observed / reproduced |

An accepted decision is not an implemented function, and an implemented function is not a
proven detection. A row states each dimension it has; one word never stands for two. The same
holds for a signal at stage 3: absent, differs, not verified and an observed failure are
different fields, not one status.

## Ids

Ids are stable across versions: an id is never renumbered or reused, and a superseded row keeps
its id with a link to what replaced it. One prefix per kind: `L-` inventory rows, `E-` evidence
checks, `G-` gap results, `F-` findings, `D-` decisions of the stage, `REC-` recommendations, `V-` verification tasks,
`W-` work towards an accepted decision.
A baseline's ids stay as they are; new `E-` ids are added without renumbering it. Every id
cited in a document appears in its evidence bundle, and a text search of the PDF finds it.

## Per stage

| Stage | The chain the document follows |
|---|---|
| 1 Inventory | object → defined state → observed state → evidence |
| 2 Target model | function → success criterion → signal → SLI and SLO → detection |
| 3 Gap | requirement → observation → difference → confidence → how to check |
| 4 Findings | finding → impact → severity → recommendation → closing criterion |
| 5 Maturity | dimension → level → evidence → what stops the next level → confidence |
| 6 Recommendations | confirmed finding → recommendation → owner role → effort and impact → metric → done when |

- **Stage 1.** One page of result first: scope, objects by status, material differences, what
  was not checked. The object, the claim about it and its evidence are separate; one row does
  not hide several independent checks. Commands go to the evidence catalog; the table cites
  E-ids. The list of files read is an appendix; each snapshot names its commit or
  configuration revision.
- **Stage 2.** Written around the resulting contract, not the rounds that produced it. A compact
  map of the functions: purpose, success criterion, measurable today, target coverage. A
  superseded decision is marked where it is cited ("item 23 applies; item 14 is superseded in
  this part"). A contract that needs its own reasoning (an ambiguous write, a reconciliation)
  is a document of its own. The full YAML is published as a file at its commit; the report
  shows the key rows.
- **Stage 3.** Five to seven results and their consequences first. The detection matrix keeps
  statuses and E-ids; the detail goes to the records. A count of signals says what it counts
  (signal rows bound to functions, not necessarily distinct series). Candidates whose fixes
  differ are separate candidates.
- **Stage 4.** Per finding: severity on the scale in [`finding.md`](finding.md) with its reason,
  confidence and limits, the closing criterion, and the three statuses above. The claim is
  bounded (window, scope, "not shown"); its verdict, one of five, is the owner's.
- **Stage 5.** Levels set before their findings' verdicts are marked provisional and re-read
  by a dated entry when the verdicts come. The result is the profile: per dimension a level, `not_scored` or N/A, never an
  overall number. Each record: the level, the evidence that shows it (`E-` ids, findings), the
  empty search behind a level 1, what stops the next level, the confidence and why; N/A with
  the client's agreement. Required: the scope assessed, every dimension present, the dimensions
  that block the next step marked.
- **Stage 6.** The result is the order of the recommendations and the decisions they need. Each
  record (`REC-` id): the confirmed findings it answers, the `W-` items that deliver it, the
  action and the owning role, effort and impact, the metric with its current and target
  values, done when. Required: every confirmed finding has a recommendation or a line under
  "left out" with the reason; every decision needed names its decider; a recommendation cites
  only confirmed findings, provisional or not. Three kinds of record are kept apart: `REC-` on
  confirmed findings; `V-`, a verification task for a finding still an assumption, whose fix
  is only a conditional option ("if F-012 is confirmed"); `W-`, work towards an accepted
  decision, citing it. A `REC-` never repeats the work or size of its `W-` items, and the work
  items have no dependency cycle (split implementation, integration scenario, delivery
  check). The first `REC-` follows a small confirmation batch, its read-only re-checks
  recorded as evidence, and the owner's verdicts. Done when is a reproducible test and a
  verified configuration; a production event is a later validation. Paging is admitted per
  alert, by its gate in [slo-alerts](spec-set/slo-alerts.md), not by a maturity level. S, M
  and L are sizes, not durations.

## Layout

The export is set once, in `tools/report.css`, and the sources stay plain Markdown: headings,
short tables, lists, fenced code. No HTML inside the text for print effects.

- A4 portrait for the report; landscape only for a document of wide matrices.
- Body text 10.5–11 pt, tables at least 9 pt, margins 18–22 mm.
- At most four columns of running text in a table; split a larger table or turn it into
  records. Cells hold short results; commands, explanations and limits go under the table.
- Colour adds to a text status and never carries it alone; so do emoji and checkboxes.
- Contents, PDF bookmarks and live links; table headers repeat on each page; a heading is not
  left at the foot of a page.
- Footer: project, stage, version, page. Long paths and build history go to the metadata.
- One language of narrative; technical ids and names are not translated.

Build with `tools/report-pdf.sh`, then look at the result: ids broken across lines, tables,
fonts and symbols, links, page numbers, headings, cut text. The script fails when an id cited
in the sources cannot be found in the PDF's text, when a font is not embedded, or when the
Markdown carries HTML for print effects; it names tables of more than five columns.

A good set: the reader understands the result from the first page; every material claim leads
to its evidence and window; current decisions are not rebuilt from history; the Markdown reads
without a special renderer and the PDF at normal zoom; what is decided, built and verified is
clear apart.
