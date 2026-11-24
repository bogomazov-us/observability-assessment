# Record check

`tools/recordcheck.py` checks that the records of an engagement hang together: the evidence
catalog of a report, and each finding against the records it cites. It reads Markdown in the
kit's own formats; no record carries extra metadata for it. A clean run says the form is right
and every cited id leads to a record. It never says a claim is true: that is the re-check and the
owner's verdict.

```
tools/recordcheck.py catalog report.md [more sources] [--external other-stage.md]
tools/recordcheck.py findings findings/F-*.md \
    --catalog stage-4-evidence.md --gaps stage-3-gap.md \
    --owner-questions owner-questions.md --decisions decisions.md
```

`catalog` is the check [`report-pdf.sh`](../templates/stage-report.md) runs on its sources: every
cited `E-` id has an entry (in the sources or an `--external` catalog), no id is defined twice,
and every entry states its window, result and limits. Entries are headings `### E-NNN — name` with
"Checked at" or "window", "Result" and "Limits" lines, or table rows whose first cell is the id
under Window (or Checked at), Result and Limits columns. Sources without a catalog and no
`--external` are not checked.

`findings` checks each finding file and what it cites. Every option is optional; a record not
given is not guessed: the run prints a note that those references are "not verifiable" and
passes nothing in its place. `--findings` defaults to the folder of the first file.

Exit 0: clean (notes allowed). Exit 1: violations, one line each on standard error as
`file:line: RULE message`. Exit 2: a file cannot be read. Needs Python 3.9+.

## Rules

| ID | Check | Where the rule is written |
|---|---|---|
| RC01 | The file is `F-NNN.md` and its title starts with the same id | [records.md](../method/records.md) |
| RC02 | The status table (the first table with a Status column; none is an error) gives a status (assumption or one of the five verdicts) and a date, YYYY-MM-DD | [finding.md](../templates/finding.md) |
| RC03 | A `**Severity:**` line: P1, P2 or P3, and a reason on the same line: any text with a letter, in any language. Whether the reason is good stays the reviewer's call | finding.md, "Severity" |
| RC04 | *What we see* cites at least one `E-` id; *Confidence and limits* has text after its level (high, medium, low): what the evidence does not establish, in any language | finding.md |
| RC05 | Every F-, G-, E- and D- id cited resolves to a record given; the D- ids of the verdict batch resolve in the register | [evidence rule](agent/rules/evidence.md) |
| RC06 | Every catalog entry given states its window, result and limits | [stage-report.md](../templates/stage-report.md) |
| RC07 | A confirmed finding has a row in the verdict batch confirming it with a D- id; one D- id may cover several findings | finding.md, "Verdicts" |
| RC08 | The finding's status agrees with its verdict in the batch | finding.md, "Verdicts" |
| RC09 | No E-, G- or D- id is defined twice in the records given | records.md |

## What it does not do

- It does not judge a claim, a severity or a window: a well-formed wrong finding passes.
- The D- id shows that a decision was recorded, not who wrote the file or that the evidence
  holds.
- It reads records by their ids. A record kept in another format (a ticket system, a
  spreadsheet) is not seen: export it, or leave the option out and read the note.

Tests: `tools/tests/test_recordcheck.sh` (fictional records of both types in
`tools/tests/fixtures/records/` pass; a broken copy trips each rule; the catalog check and the
finding check agree on the same catalog) and `tools/tests/test_report_pdf.sh`.
