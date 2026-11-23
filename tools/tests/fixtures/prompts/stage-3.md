# Stage 3 — gap

*Task prompt. Assemble it with `tools/agent/prompt.sh 3`, which appends the rule files it
names, and paste the result as is; replace the bracketed values.*

---

You check a confirmed target model against the live estate: which of its signals exist and
work, which SLIs could be computed today, which alerts could detect what they are meant to,
and what stands between each alert and a person who acts on it. You draft; a person confirms
a sample of the "live" signals and each "proven" detection.

## Rules

The rule files in [`rules/`](rules/) apply to this stage: [boundaries](rules/boundaries.md),
[evidence](rules/evidence.md), [claims](rules/claims.md),
[owner questions](rules/owner-questions.md) and the [progress log](rules/progress-log.md),
with N = 3. The boundaries below are this stage's own and add to the common ones.

## Boundaries

- Read-only on the client's estate: code checkout, monitoring tool, exports, logs. You may run
  read queries; you never change configuration, code or tickets, and you never inject a fault
  or send test traffic to production. A fault is reproduced on a stage, by the client's
  developer, or during implementation — you write the scenario, you do not run it there.
- Count and classify log lines; quote none.
- A window read for an event starts before it, with margin: a window that starts at the
  event's minute can miss it, and a counter that buckets by period reports at the end of its
  bucket.

## Inputs

| Input | Where |
|---|---|
| Spec, confirmed at stage 2 | `spec/observability-spec.yml` |
| Stage 2 notes and the decision register | `stage-2-notes.md`, decision register |
| Inventory, confirmed at stage 1 | `inventory.md` |
| Code checkout (read-only) | [path] |
| Read-only access to the monitoring estate and its logs | [token, profile or MCP server; named, never pasted] |
| A system without read access for the agent (an edge, a SaaS console) | [none, or: read by the person in its own console under an owner decision recorded first] |
| Open questions carried from stage 2 | `stage-2-notes.md`, "Open questions" |
| Facts ledger, risk register | instructions file |

## Method

Every step has its full rule and cases under its number in the
[stage 3 reference](reference/stage-3-reference.md) (in the kit, `tools/agent/reference/`).
Read it before the step; it binds as if it were here.

1. **Signals.** Each spec signal `live` (estate evidence over a stated window), `to_build`,
   `differs` or `not_verifiable`.
2. **SLIs.** Per SLO, good and valid from live signals alone, as a reading; else the missing
   signal.
3. **Alerts.** Per alert: live rule, inputs present, grouping, state as evaluated.
4. **Detection matrix.** Per P1 alert, the chain fault to acknowledgement: proven, scenario
   written or residual risk.
5. **Paging readiness.** Per alert, each part of the paging gate shown or not shown.
6. **Telemetry health.** Per failure in stage 2's table: detecting signal live, and how it
   reads today.
7. **Open questions carried.** Each answered from evidence or "not established".
8. **Blind spots.** Each handed to the person for the risk register now.

## Output

The stage report, `stage-3-gap.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log, the decision register and the full spec
travel with it as files at a stated commit, cited, not reprinted.

1. Updated `spec/observability-spec.yml`: each signal's `state` and `evidence` from step 1; nothing
   else in the target changes. A target the gap shows unreachable is an open question for
   the owner, not an edit.
2. `stage-3-gap.md`:
   - first, five to seven results and their consequences;
   - signals: live / to build / differs / not verifiable ([records.md](../../method/records.md)), with counts that sum to the
     signals and a line on what the count counts (signal rows bound to functions, not
     necessarily distinct series), and the evidence per row; absent, differs, not verified
     and an observed failure are separate fields;
   - SLIs computable today, with their readings, and the missing signals for the rest;
   - alerts: rule, inputs present, grouping, state;
   - the detection matrix (proven / scenario written / residual risk) and the scenarios;
   - the paging readiness table (shown / not shown per item);
   - telemetry health, carried questions, blind spots;
   - stage-4 candidates: each gap with the evidence a finding would cite; gaps whose fixes
     differ are separate candidates.
3. `python3 tools/speclint.py spec/observability-spec.yml`: no errors. A paging alert on a signal that is not live
   fails SL011.

## Self-check before handing over

- [ ] Every `live` has evidence from the estate in a stated window; nothing is live because the
      code defines it.
- [ ] Signal counts sum to the signals in the spec.
- [ ] Every SLI reading is labelled a reading, with its window; none is reported as met.
- [ ] Every P1 alert is in the detection matrix as proven, scenario written or residual risk;
      no fault was injected and no test traffic sent to production.
- [ ] Every paging item is shown with a citation or marked not shown, per alert.
- [ ] No target, owner or threshold was changed; what the gap questions is an open question.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../../method/getting-started.md#3-calendar) gives, checks a sample of the "live" signals, chosen by them, through another path than the
agent's query: the tool's own interface, a browser, or a query they write. Re-running the
agent's query shows that it repeats, not that the signal is live. Checks each "proven" in the
detection matrix the same way. Agrees the owners of the residual risks and registers the blind spots. Decides which
scenarios are run, where and by whom. Confirms the gap as the input to stage 4, or returns it.

---

# Rule: boundaries common to every stage

*Applies to every stage; N = 3. Each stage adds what it may read, query and
write.*

- Before anything else, run `python3 tools/stagegate.py check engagement-state.yml 3`.
  If it reports the stage blocked, stop: log what it reports and hand it to the person. Never
  work around a closed gate.
- In `engagement-state.yml` you may set this stage to `draft` when you start and to
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
  `engagement-state.yml`, without an answer.
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

*Applies to every stage. N = 3.*

Keep `progress/stage-3.md` in the engagement repository while you work, so a person can see
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
