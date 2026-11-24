# Stage gate check

`tools/stagegate.py` reads the engagement state file (skeleton:
`templates/engagement-state.yml`) and answers two questions: may a stage start, and is the file
itself sound. It only reads: a person confirms or returns a stage by editing the file, and
records the confirmation in the client's decision register first.

```
tools/stagegate.py check engagement-state.yml N          # may stage N start?
tools/stagegate.py lint engagement-state.yml             # is the file sound?
tools/stagegate.py lint engagement-state.yml --since REV # ... and was nothing rewritten since REV?
```

`check` exits 0 and says the stage may start, or exits 1 with one line per reason it may not:
the stage before it is not confirmed, or its confirmation lacks who, when or the decision
reference, or an owner question that blocks it is still open. Stage 1 needs the agreed scope
(`scope.decision_ref`) and the date read-only access was granted. A state file with errors
blocks every stage.

`lint` exits 0 when clean (warnings may be printed), 1 on rule violations, one line each as
`file: where: RULE message`. Exit 2: the file or the revision cannot be read. Needs Python 3.9+
and PyYAML; `--since` needs git and the file under version control.

## Rules

| ID | Check | Gate rule (tools/agent/README.md, "Gates") |
|---|---|---|
| G01 | A scope block records the agreement and the access | stage 1: scope agreed, read-only access granted |
| G02 | All six stages listed, numbered 1–6 | one state per stage |
| G03 | No stage listed twice | one state per stage |
| G04 | Status is not_started, draft, handed_over, returned or confirmed | — |
| G05 | A confirmed stage names who confirmed it, the date and the decision-register id; no other status carries them | an answer is recorded before any document cites it |
| G06 | A stage is confirmed only when the stage before it is | a stage starts only on confirmed output of the stage before it |
| G07 | No stage confirmed on a date before the stage before it | same |
| G08 | A review has a date, who reviewed and the review file | a review appends a record |
| G09 | A question has an id and the question; it blocks stages 1–6; its answer is a decision-register id | owner questions |
| G10 | No stage is confirmed while a question that blocks it is open | open questions that block a stage need answers |
| G11 | With `--since`: reviews only grow; none edited or removed | a review never rewrites history |
| G12 | With `--since`: a confirmation is not rewritten; re-opening a stage is a new decision | a decision nobody can find is read as a proposal |
| G13 | `assessment`, when present, is observability or sre; absent means observability | a stage is checked against its own type's file |
| G14 | `recheck`, when present, is done or not_done; not_done carries `recheck_reason` | a stage confirmed without the sample re-check says so |
| G15 | `review_hours` on a review and `rework_hours` on a confirmation are a number of hours, 0 or more; `rework_hours` only on a confirmed stage (else G05), and not added or changed after the confirmation (G12) | the harness is measured on person hours recorded as the work happens |
| G16 | With `--since`: every review file the state file named at REV is unchanged since REV, byte for byte; one deleted, edited, or that git cannot show at REV (not committed with the state) is an error. New rounds and their new files pass. Paths are read beside the state file, or one folder up (`sre/` inside a report). `check` and `lint` without `--since` read no history | a recorded review is part of the record: G11 keeps the list, G16 its content |
| W01 | Warning: a stage in draft, handed over or returned while the stage before it is not confirmed | work started before its gate opened |
| W02 | Warning: the file records hours, but a review lacks `review_hours` or a confirmed stage `rework_hours`; reads "not measured" in [harness-metrics.md](harness-metrics.md) | same |

## In a stage run

The agent runs `check` for its stage before anything else and stops when it is blocked, naming
what it reports ([`rules/boundaries.md`](agent/rules/boundaries.md)). It may set its own stage
to `draft` and then `handed_over`; it never sets `returned` or `confirmed`. Before confirming,
the person runs `lint --since` against the commit of the last confirmation, so that an edited
review, an edited review file or a rewritten confirmation is seen. Review files are committed
with the state file that names them; a later change to a round goes in a new round's file. On the first confirmation there is none: pass the
commit that added the file (`git log --diff-filter=A --format=%h -- engagement-state.yml`), so
the command is the same at every stage; there is no earlier confirmation to protect. A
revision at which the file did not exist exits 2 and names that command.

Tests: `tools/tests/test_stagegate.sh` (a sound file passes; one fixture per rule fails; the
gate opens and stays shut as the state says; `--since` catches edits, to review files too, in both layouts).
