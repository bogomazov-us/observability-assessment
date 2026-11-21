# Stage report — skeleton

One skeleton for the report of every stage. It gives two levels of reading from one set of
sources: the **main report**, read in order, supports a decision; the **evidence bundle** lets
a reviewer check each claim by its id. The current state comes first. How the document got
there (review rounds, earlier answers, the progress log) is history, kept in an appendix or a
file of its own and never needed to read the result.

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
| Q-01 | … | … | open, or the D- id of its answer |
| D-NN | … | … | proposed / accepted / superseded by D-NN |

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

The client reads two documents, not one per stage and per round: the **assessment report** and
the **evidence bundle**.

| Chapter | File ([path table](../tools/agent/README.md#artifact-paths)) | Written by | Accepted when |
|---|---|---|---|
| Summary, first | `summary.md`, from [report.md](report.md) | The lead, rewritten at each accepted stage | The sponsor accepts the report |
| One per stage, in order | The stage's notes file (table below) | The agent drafts it at stage N, or the lead writes it from this skeleton | The lead sets the stage `confirmed` and its document status `accepted` |

Sources stay per stage, each fixed at its commit. At each accepted stage the lead adds its lines
to `manifest.txt` in the working folder, rewrites `summary.md`, and builds both documents with
`tools/assessment-pdf.sh`; after stage 6 that build is the final report. The manifest then:

```text
report    summary.md
report    inventory.md            1 2 3 5
report    stage-2-notes.md        1 2 3 5
report    stage-3-gap.md          1 2 3 5
report    stage-4-notes.md        1 2 3 5
report    stage-5-notes.md        1 2 3 5
report    recommendations.md      1 2 3 5
evidence  inventory.md            4 A
evidence  stage-2-notes.md        4 A
evidence  stage-3-gap.md          4 A
evidence  stage-4-notes.md        4 A
evidence  findings/F-001.md
evidence  stage-5-notes.md        4 A
evidence  recommendations.md      4 A
```

- **The report** takes sections 1, 2, 3 and 5 of each chapter; only the summary is rewritten.
- **The bundle** holds the records (section 4; at stage 4, a line per finding file) and every
  evidence catalog (Appendix A). Stages keep their own `E-` ranges (stage 1 E-1xx, stage 2
  E-2xx …), so the catalogs join without renumbering; an id cited in the report must resolve in
  the bundle, or the build fails.
- **Neither** carries section 6 or Appendix B: the conditions serve the review, and the change
  history is one table in `summary.md`, a row per stage and per accepted change. Working files —
  question lists, confirmation batches, drafts, review rounds — stay in the engagement's
  repository as history; they reach the client through the result they produced.
- The version of both is the commit in the footer. The roadmap is a document of its own
  ([roadmap.md](roadmap.md)).

## Statuses and ids

Status values, who sets each, and the id prefixes are in
[records.md](../method/records.md); one word never stands for two, and at stage 3 a signal's
absence, difference, verification and an observed failure are separate fields. A baseline's ids
stay and new `E-` ids are added after them. Section 5 cites the decision register's `D-` ids and
the owner questions' `Q-` ids; a stage does not number decisions of its own.

## Per stage

Every notes file carries the skeleton's sections under their numbers, for the manifest to select:

| Stage | Notes file | The chain the document follows | 3 Main results (report) | 4 Records (bundle) |
|---|---|---|---|---|
| 1 Inventory | `inventory.md` | object → defined state → observed state → evidence | Objects by status, summed; material differences | `L-` rows, reconciliation, code-scan leads, what was not inventoried |
| 2 Target model | `stage-2-notes.md` | function → success criterion → signal → SLI and SLO → detection | The map of the functions | A table per journey (open questions: section 5) |
| 3 Gap | `stage-3-gap.md` | requirement → observation → difference → confidence → how to check | Five to seven results and their consequences, first; signal counts; the detection matrix | `G-` records: signals, SLIs, alerts, paging readiness, telemetry health, candidates |
| 4 Findings | `stage-4-notes.md` | finding → impact → severity → recommendation → closing criterion | Findings by severity; the five to seven that matter | Ledger rows they rest on, "could not evidence"; the `findings/` files |
| 5 Maturity | `stage-5-notes.md` | dimension → level → evidence → what stops the next level → confidence | The profile | A record per dimension |
| 6 Recommendations | `recommendations.md` | confirmed finding → recommendation → owner role → effort and impact → metric → done when | The order; the decisions needed | The confirmation batch, `REC-` cards, `V-` tasks, `W-` items, "left out" |

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
- **Stage 3.** The detection matrix keeps statuses and E-ids. A count of signals says what it
  counts (signal rows bound to functions, not necessarily distinct series). Candidates whose
  fixes differ are separate candidates.
- **Stage 4.** Per finding: severity on the scale in [`finding.md`](finding.md) with its reason,
  confidence and limits, the closing criterion, and the decision, implementation and
  verification statuses. The claim is bounded (window, scope, "not shown"); its verdict, one
  of five, is the owner's.
- **Stage 5.** Levels set before their findings' verdicts are marked provisional and re-read
  by a dated entry when the verdicts come. Per dimension a level, `not_scored` or N/A, never an
  overall number. Each record: the level, the evidence that shows it (`E-` ids, findings), the
  empty search behind a level 1, what stops the next level, the confidence and why; N/A with
  the client's agreement. Required: the scope assessed, every dimension present, the dimensions
  that block the next step marked.
- **Stage 6.** Each record (`REC-` id): the confirmed findings it answers, the `W-` items that
  deliver it, the action and the owning role, effort and impact, the metric with its current
  and target values, done when. Required: every confirmed finding has a recommendation or a line under
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

A reviewer checks the set against the stage report form checklist in [review.md](review.md).
