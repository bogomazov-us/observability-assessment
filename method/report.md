# The report: from stage to acceptance

**What is here:** how the stage chapters become one assessment report and one evidence bundle,
the manifest that assembles them, and how the report is closed, accepted and handed over. **Read it when:** a stage is accepted and its chapter joins the report, or the assessment
closes. Writing a chapter: the [stage-report skeleton](../templates/stage-report.md).

## One report for the whole assessment

The client reads two documents, not one per stage and per round: the **assessment report** and
the **evidence bundle**.

| Chapter | File ([path table](../tools/agent/setup.md#artifact-paths)) | Written by | Accepted when |
|---|---|---|---|
| Summary, first | `summary.md`, from [report.md](../templates/report.md) | The lead, rewritten at each accepted stage | The sponsor accepts the report |
| One per stage, in order | The stage's notes file ([per stage](../templates/stage-report.md#per-stage)) | The agent drafts it at stage N, or the lead writes it from the [skeleton](../templates/stage-report.md) | The lead sets the stage `confirmed` and its document status `accepted` |

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
  ([roadmap.md](../templates/roadmap.md)).

## The manifest

`manifest.txt` picks the chapters of the assessment report and the evidence bundle;
`tools/assessment-pdf.sh` builds both from it, and other renderers may read it too. Its format
is a contract, the same as in the tool's header; a change to it is a change to both.

| Rule | Format |
|---|---|
| Line | Words separated by spaces: `report` or `evidence`, the source path relative to the manifest (no spaces), then the selectors, if any. Blank lines and lines starting with `#` are ignored |
| Type | `assessment observability` or `assessment sre`, anywhere, once per type. Without one: a path under `sre/` makes it SRE, any other observability, except the shared `summary.md`, `owner-questions.md` and `findings/` |
| Order | Each line is one chapter of its document, in the order listed; a file may be listed on several lines |
| Selection | No selector: the whole file. A selector takes each `## ` section whose heading starts with it, after an optional `Appendix `, as a whole word (`1` takes `## 1. Result`, not `## 10.`; `A` takes `## Appendix A.`), up to the next `## `, its `### ` subsections included. With selectors, text before the first `## ` is dropped |
| No `## ` sections | A file without them (`summary.md`, a finding, `sre/service-catalogue.md`) is listed without selectors; with one, its chapter is its title only, and the build reports a selector that matches nothing |
| Title | The file's first `# ` heading, with a leading "Observability assessment", "SRE assessment" or "Observability and SRE assessment" and its separator (em dash, comma or hyphen) removed and the first letter raised: `# SRE assessment — stage 1: inventory` gives "Stage 1: inventory" |
| Errors | An unknown first word or type, a missing source, or no `report` line: exit 2 |

The report notes a table wider than five columns; the bundle holds records, set landscape,
without that note.

## Closing the report

The sponsor accepts the report once, after stage 6 ([roles](records.md#roles)). The
lead closes it in this order; an agent may draft steps 1 to 3 but sets no status and records no
decision.

1. **Closing check.** List every decision, question and card id the summary or a chapter calls
   open, pending or waiting, and look each up in the decision register and the facts ledger.
   For one the register has closed, correct the summary to the current position; the chapter
   is history and keeps its text, with a dated note at its top ("Later (YYYY-MM-DD): D-14
   closed this; see the summary."). Every decision reference names its record ("D-12",
   "ADR-007 item 3"); a bare "item 3" is fixed.
2. **Answers against earlier decisions.** Every answer recorded since the last accepted stage is
   read against the earlier decisions on the same cards and targets and against the confirmed
   targets. A conflict goes back to the owner as a new question, one card or record per option;
   it is never settled in the text.
3. **Hand-over.** Section 9 of the summary ([report.md](../templates/report.md)), from the register and the
   roadmap: the open decisions and their deciders; the decided `W-` items not yet scheduled,
   each with a named owner; what only the client can do, the assessment being read-only. Filing
   the `W-` items as tickets in the client's tracker is offered; the client files them.
4. **Acceptance.** The sponsor accepts in writing. The lead records it as a `D-` row, sets the
   summary's document status to accepted with who and when and that row's id, and adds a row to
   the summary's changes table.
5. **Final build.** Both PDFs are rebuilt with `tools/assessment-pdf.sh` from the merged commit
   that carries the acceptance, the version in their footer. Earlier drafts are removed from
   wherever the client reads the report, so only the accepted pair remains.

A decision taken after acceptance changes the summary by a new version and a row in its changes
table; the chapters get only a dated "Later" note.
