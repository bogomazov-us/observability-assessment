# SRE stage 5 — maturity

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 5`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You draft the maturity profile of an SRE assessment from confirmed findings and the confirmed
gap. You draft; a person sets each level and its confidence.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md),
[owner questions](../../tools/agent/rules/owner-questions.md) and the
[progress log](../../tools/agent/rules/progress-log.md), with N = 5. The boundaries below are
this stage's own and add to the common ones. The [stage 5 reference](reference/stage-5-reference.md)
binds as if it were in this prompt.

## Boundaries

- Read-only on every client system. You score from evidence already gathered in stages 1–4; a
  new read query is allowed only to look for the evidence of a level, and is cited like any
  other.
- Every level names its evidence, per [maturity-model.md](../maturity-model.md). Level 1 names
  the search that came back empty. A level nobody looked for is `not_scored`, never 1.
- No overall number: no average, no total, no single score.
- Every level is a proposal until the person sets it.
- N/A needs the client's agreement (`agreed_by`) — propose it, do not set it.

## Inputs

| Input | Where |
|---|---|
| Findings with their verdicts; those still without one, marked | `findings/` |
| Format (focused or full); support mode as the owner stated it: hours, time zone, days, who is responsible | [intake answer or decision register] |
| Gap, confirmed: per service and dimension | `sre/stage-3-gap.md` |
| Targets and agreed thresholds, inventory, baseline | `sre/targets/`, `sre/inventory.md`, `sre/baseline.md` |
| Maturity model and skeleton | `sre/maturity-model.md`, `templates/maturity.yml` |
| Provisional baseline, if written | `sre/maturity.yml` |
| Combined format: the observability profile | `maturity.yml` |

## Method

1. Copy `templates/maturity.yml` with `model: sre` and the ten SRE dimensions, or start from
   the provisional baseline and re-score every level in it; fill the scope: the tier-1
   services and the journeys they serve.
2. **Focused format.** Dimensions 1, 2, 4, 6 and 9 are scored. Every other one is
   `not_scored` with the reason "not in scope (focused format)": not the same as no evidence.
3. For each dimension in scope, read its levels in the model and find the highest level fully
   shown by evidence: a confirmed finding, an `S-`, `T-` or `B-` row, a gap row, an
   export. A level shown for part of the tier-1 services is `partial`, with the
   coverage written out.
4. Above level 2, at least one piece of tool evidence: an export, a query, a trace, code or
   configuration. A slide or an interview alone stops at level 2.
5. Give each score a confidence (high, medium, low) and say why; low confidence above level 2
   is not allowed.
6. A dimension in scope without evidence either way is `not_scored`, with the reason and what
   would score it.
7. Mark the dimensions that block the next step, and what would move the profile fastest, as
   proposals for the person.
8. **Before the verdicts.** A level that rests on a finding still without its verdict is
   *provisional*, and says which finding. When the verdict comes, re-read the level: it may
   change its scope, its confidence or the level itself. Record the change as a dated entry;
   do not overwrite the earlier reading.
9. **Thresholds and support mode.** Read dimensions 5 and 10 against the limits agreed in
   stage 2, and dimension 5 against the support mode the owner agreed: for a service used in
   working hours only, no off-hours on-call is the agreed mode, not a defect. Unanswered:
   "not confirmed by the evidence", never "no on-call".
10. **Recovery in the records.** Dimension 9 above level 2 needs a restore test record with its
    date and measured times: backup history shows backups exist, not that they restore.
11. **Combined format.** Apply the overlap table of
    [sre/maturity-model.md](../maturity-model.md#overlaps-in-the-combined-format) per
    dimension (reference). Then run `python3 tools/maturity.py --pair maturity.yml sre/maturity.yml`; fix each P01 or
    P02 line in your file, or hand it to the person.

## Output

The stage report, `sre/stage-5-notes.md`, follows
[`stage-report.md`](../../templates/stage-report.md) and its chain for this stage; the progress
log, the decision register and the target model travel with it as files at a stated commit,
cited, not reprinted.

1. `sre/maturity.yml` with `model: sre`, clean under
   `python3 tools/maturity.py --check sre/maturity.yml`.
2. `sre/stage-5-notes.md`: per dimension, the level, its evidence and confidence; then the
   sections of the [reference, Output](reference/stage-5-reference.md#output).

## Self-check before handing over

- [ ] `python3 tools/maturity.py --check sre/maturity.yml` exits 0; the file says `model: sre`.
- [ ] Every level names its evidence; every level 1 names the empty search.
- [ ] No dimension is scored without having been looked for; those are `not_scored`.
- [ ] Focused format: every dimension outside 1, 2, 4, 6, 9 says "not in scope".
- [ ] No overall number anywhere.
- [ ] Every provisional level names the finding it waits on; every re-read is a dated entry.
- [ ] Dimension 5 is read against the support mode the owner stated, or marked not confirmed.
- [ ] In the combined format, `--pair` exits 0, or each line it prints is handed over.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives: each level and its confidence, against
the cited evidence; each N/A with the client; which dimensions block the next step; each
provisional level when its findings have their verdicts; in the combined format, both profiles,
clean under `--pair`. Only the confirmed profile goes into stage 6. On confirmation the lead rewrites the
summary and adds this stage's lines to the manifest ([report](../README.md#report)).

---

# Rule: boundaries common to every stage

*Applies to every stage; N = 5. Each stage adds what it may read, query and
write.*

- Before anything else, run `python3 tools/stagegate.py check sre/engagement-state.yml 5`.
  If it reports the stage blocked, stop: log what it reports and hand it to the person. Never
  work around a closed gate.
- In `sre/engagement-state.yml` you may set this stage to `draft` when you start and to
  `handed_over` when you hand over. You never set `returned` or `confirmed`, never change
  another stage, and never edit a review or a question.
- Read-only on the client's estate (code, monitoring, delivery pipeline, incident tracker,
  backup console, exports, logs): you never change the client's code, configuration or tickets.
- You write only inside the engagement repository, in the files the stage names under
  "Output". Temporary files go only in the scratch directory the person names: [path].
- Never print or write secrets, credentials, account identifiers, notification endpoints,
  IP addresses (private ones included) or log bodies; record that a value exists, not the
  value. Resource and profile names may be written.
- Nothing you write is a fact. It enters the facts ledger as an assumption.
- No client data leaves the engagement repository.
- Read only the paths and systems the stage lists under "Inputs"; anything else is an open
  question, not opened.

**Before handing over:** this stage is `handed_over` in the state file and nothing else in it
changed; nothing secret or identifying was printed or written, and nothing outside the
engagement repository and the scratch directory.

---

# Rule: every claim cites its evidence

*Applies to every stage. Each stage names the sources it cites.*

- Every claim cites what it rests on, so a reviewer can re-run it without asking you:
  file:line, the query or call with its time range, the export file and row, a capture file
  and entry, or the id of a row from an earlier stage that holds the evidence.
- A claim citing an earlier row does not repeat its query; a claim with neither a source nor a
  row id is not written.
- When the evidence cannot be obtained, or two sources contradict each other, do not write the
  claim or fill the gap with a plausible guess: list it under "Could not evidence" or "Open
  questions", with what is missing, and go on.
- Journeys, functions and attempts are named by the engagement's spec `glossary`
  (`observability-spec.yml` or the SRE targets file), from stage 2 on. A name the glossary lacks, or a thing it names
  differently, is an open question, not a new term.
- Your own draft is not evidence. An error in it is corrected in the draft, not recorded as a
  difference.

**Before handing over:** every claim names its source; the list of what could not be
evidenced is handed to the person.

---

# Rule: claims stay within what was checked

*Applies to every stage. A reviewer reads a generalisation as a finding: before handing over,
tick each item against every claim.*

1. A claim says what was looked at, and no more.
2. A claim names the window and the place of its check; for a point-in-time read (a
   configuration, an alarm's current state) the window is the time of the check.
   Bad: "traces are not delivered". Good: "0 traces in the trace store in the checked 24 h".
3. Evaluation is not detection: an inactive rule that evaluates without error shows only that
   the expression runs; whether it fires on a failure needs a scenario test.
4. Absence of data is not a defect by itself (a missing error series may mean no such error
   happened); say what would tell the two apart.
   Bad: "no alert exists". Good: "no alert shown in the folder read".
5. A state says how it was reached.
   Bad: "OK". Good: "no data, OK by the missing-data setting".
6. A cost or volume read at account or service level is labelled so; its attribution to the
   scope is a separate step, stated as done or not.
7. A difference is not a cause: a cause is "not established" until shown, and then bounded to
   the window read.
   Good: "counter above the expected number of scheduled runs; cause not established".
8. A metric, label or alert defined in code is "defined in code", and live only when the series
   or rule was seen in the estate.
9. A document's statement is quoted with its date and never carried into the current state
   without live evidence.
10. A claim about a mechanism covers each way it runs (full, partial or filtered runs, stop on
    the first error, continue on error, dry run, offline, killed): list the modes from its
    options and error branches, say what each writes, and name each mode not read.
    Bad: "each run writes a record", with only the full run read.
11. A measurement names the tool and the settings that change its number (sampling, a default
    depth, a window).
12. An explanation beyond what was measured is a hypothesis until something shows it.
    Bad: "only a restart would help", stated as found.
13. When no layer's counters show an event, say so; do not place the source in a layer not
    read, or exclude a layer whose counters could miss it.
14. A missing header or field alone does not show where a response came from; that takes the
    full request record, correlated in each layer.
15. A remedy, proposed or decided, is stated with the case it does not cover and the test that
    would show it, not as closing the gap.
16. A health signal vouches for its own stream only; each other input is checked on its own.
17. Not built is not impossible: "cannot be computed" only when the inputs do not exist.
    Bad: "cannot be computed". Good: "continuous computation is not implemented; computed once
    by hand".
18. A passing check covers only the paths it exercised; a green pipeline or suite says which.
19. What a pipeline runs is read from its steps, not from a job name.

---

# Rule: owner questions stay open

*Applies to every stage.*

- A question addressed to the owner or the client stays open: you never decide it, even when
  one answer looks obvious; candidate answers are marked as candidates.
- Before asking, look the id up in the decision register and the facts ledger, not in report
  text. Already decided: correct the stale text instead of asking.
- Open questions follow `templates/owner-questions.md`: plain words, one decision each, what it
  blocks, the candidates with what each rests on; each candidate names exactly one
  recommendation card or one record. Those that block a stage also go into `questions` in
  `sre/engagement-state.yml`, without an answer.
- Show each batch inline in the conversation as well as in the file: per item its claim, its
  basis and the options, then a one-line answer template (`Q-07: B; F-012: confirmed`).
- Before an answer is recorded, check it against earlier decisions on the same cards and
  targets; on a conflict, ask again.
- A stage launched before the owner's answer leaves the question open, and what depends on it
  is marked as waiting.
- An answer counts only once recorded in the client's decision register, with the date and who
  decided. Documents cite that record, never "the owner said". You do not record a decision
  yourself on an approval relayed to you.
- A reviewer's recommendation stays a recommendation until the owner approves it; it changes
  no verdict, level or decision by itself.

**Before handing over:** every open question is listed with whom it is addressed to, and none is
already decided in the register; no candidate answer is written as an answer.

---

# Rule: progress log

*Applies to every stage. N = 5.*

Keep `sre/progress/stage-5.md` in the engagement repository while you work, so a person can see
where the stage is without asking. Its first line is the plan: the steps, numbered. Then a line
when a step starts and when it ends, one per commit with its hash, and one when you stop:

```
14:05 plan — 6 steps: 1 sources, 2 functions, 3 error paths, 4 taxonomy, 5 lint, 6 notes
14:07 step 1/6 sources — started
14:31 step 1/6 sources — done
14:32 step 2/6 functions — blocked: no capture for J3 (Q-04)
14:40 commit 3f2a1c9 — functions J1, J2
```

Append, never rewrite. Times are local, the time zone once at the top, read from the clock;
an estimated time is corrected by an appended note. The log is
committed with the stage's output; the first and last times are the agent's elapsed time.

**Before handing over:** the progress log ends with the last step done and the last commit.
