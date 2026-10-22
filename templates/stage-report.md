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
checks, `G-` gap results, `F-` findings, `D-` decisions of the stage, `REC-` recommendations.
A baseline's ids stay as they are; new `E-` ids are added without renumbering it. Every id
cited in a document appears in its evidence bundle, and a text search of the PDF finds it.

## Per stage

| Stage | The chain the document follows |
|---|---|
| 1 Inventory | object → defined state → observed state → evidence |
| 2 Target model | function → success criterion → signal → SLI and SLO → detection |
| 3 Gap | requirement → observation → difference → confidence → how to check |
| 4 Findings | finding → impact → severity → recommendation → closing criterion |

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
- **Stage 4.** Per finding: severity with its reason, confidence and limits, the closing
  criterion, and the three statuses above.

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
in the sources cannot be found in the PDF's text.
