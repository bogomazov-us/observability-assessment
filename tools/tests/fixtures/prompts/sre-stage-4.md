# SRE stage 4 — findings

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 4`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You draft the findings of an SRE assessment from a confirmed target model and a confirmed gap.
You draft; a person re-runs the evidence and sets the status. People may write findings too
([agent-harness.md](../../method/agent-harness.md), "Measuring the harness"): you reconcile
your drafts with theirs.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md),
[owner questions](../../tools/agent/rules/owner-questions.md) and the
[progress log](../../tools/agent/rules/progress-log.md), with N = 4. The boundaries below are
this stage's own and add to the common ones. The [stage 4 reference](reference/stage-4-reference.md)
binds as if it were in this prompt.

## Boundaries

- Read-only on every client system: you never run a restore, failover, rollback, load test or
  fault injection to see what happens.
- One claim per finding. Every statement under *What we see* cites its evidence: the export
  file and row, the incident or pipeline run id, file:line in infrastructure as code or code,
  or the `S-`, `T-` or `B-` row.
- Every finding is drafted with status **assumption**. You never write *confirmed*.

## Inputs

| Input | Where |
|---|---|
| Gap per service and dimension, confirmed | `sre/stage-3-gap.md` |
| Targets and tiers, confirmed | `sre/targets/`, `sre/service-catalogue.md` |
| Stage 1 records: inventory rows, exports, baseline numbers | `sre/inventory.md`, `sre/exports/`, `sre/baseline.md` |
| Findings already written, status assumption | `findings/` |
| Facts ledger | instructions file |
| Finding template | `templates/finding.md` |
| The client's own reliability work, if any | [folder] |

## Method

0. Read the findings already in `findings/`. A candidate one of them covers is not drafted
   again: list it in `sre/stage-4-notes.md` under that finding's id, with what it adds or where
   it differs, for the person to merge. A new finding takes the next free id; no id is reused.
1. Walk the chain per tier-1 service: tier and owner → target → measurement → the mechanism
   that keeps the target (page, rollback, restore, headroom) → a record that it worked. Each
   broken or unproven link is a candidate finding.
2. Turn each gap row of stage 3 against a confirmed target into a candidate, and go through
   the checks per dimension in the reference.
3. Every baseline number marked *not measured* is a candidate: what could not be measured, why,
   and what it hides.
4. For each candidate, get the evidence: the export row, the incident, the pipeline run, the
   backup job, the line of code. No evidence, no finding.
5. Write *Why it matters* as a customer or business consequence. Write *What follows* as an
   action, the role that owns it, and the dimension it moves, named with its model: "SRE
   dimension 9".
6. Where the client's own work already covers a point, say so and build on it.
7. Bound each claim before you write it: its window and its scope; "not shown" rather than
   "none exists"; a cause only for the window read; a partial read says what was not checked.
   A decision record that adopted a reading is not evidence for it: cite the code and its
   version, or a query.
8. **Combined format.** The observability findings share `findings/` and the `F-` sequence:
   read them as in step 0, and check the folder again before each new file. An overlap topic
   names the dimension where it is scored (reference).

## Output

The stage report, `sre/stage-4-notes.md`, follows
[`stage-report.md`](../../templates/stage-report.md) and its chain for this stage; the progress
log, the decision register and the target model travel with it as files at a stated commit,
cited, not reprinted.

1. One file per finding, `findings/F-NNN.md`, in the `templates/finding.md` format: status
   *assumption*, today's date, source, evidence level (browser / agent / tenant / document
   only), severity with its reason (read with the reference), the three statuses, confidence
   and limits, the closing criterion, and under each claim its `E-` ids. Candidates whose
   fixes differ are separate findings.
2. `sre/stage-4-notes.md`: one page of result first, then the sections of the
   [reference, Output](reference/stage-4-reference.md#output), ending with the verdict batch,
   no verdict filled in.

## Self-check before handing over

- [ ] Every claim has an Evidence line a reviewer can re-run without asking.
- [ ] Every finding is status *assumption*; none says *confirmed*.
- [ ] Every *What follows* names an action, an owning role and a dimension with its model.
- [ ] Every *not measured* baseline number is a finding or is listed under "Could not evidence".
- [ ] No finding rests on an interview or a slide alone (evidence level *document only* is
      stated when that is all there is).
- [ ] No id was reused or taken twice in `findings/`.
- [ ] No other client's name, figure or system appears.
- [ ] `tools/recordcheck.py findings` passes on `findings/` with the stage's evidence catalog and
      gap records given: form, severity reasons and every cited id resolve.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives, re-runs each cited query or opens each
cited record, then sets the verdict, one of the five in
[`finding.md`](../../templates/finding.md): confirmed, disputed (with the reason), refuted,
inconclusive or resolved. The re-checks are read-only and recorded as evidence with their own
`E-` ids; a reviewer's reading is a recommendation, and the owner sets the verdict
([records.md](../../method/records.md)), in writing, through the verdict batch. In the combined format one batch carries both types'
findings, sent once at the findings preview. Refuted drafts are kept with the reason; they
count against the harness in the measures. The stage is confirmed once every draft is
re-checked and its verdict recorded or sent in the batch: a finding still waiting stays
*assumption*, and stage 5 marks a level resting on it provisional. On confirmation the lead rewrites the
summary and adds this stage's lines to the manifest ([report](../README.md#report)).

---

# Rule: boundaries common to every stage

*Applies to every stage; N = 4. Each stage adds what it may read, query and
write.*

- Before anything else, run `python3 tools/stagegate.py check sre/engagement-state.yml 4`.
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

*Applies to every stage. N = 4.*

Keep `sre/progress/stage-4.md` in the engagement repository while you work, so a person can see
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
