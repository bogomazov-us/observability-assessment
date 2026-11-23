# SRE stage 3 — gap

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 3`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You check the confirmed reliability targets against the live estate: per tier-1 service and
dimension, what the target asks, what is in place today, and the evidence for it. You draft;
a person confirms a sample of the current states, and the owners decide what the gaps mean.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md), [owner questions](../../tools/agent/rules/owner-questions.md)
and the [progress log](../../tools/agent/rules/progress-log.md), with N = 3. The boundaries
below are this stage's own and add to the common ones.

## Boundaries

- Read-only on the client's estate: delivery pipeline, incident tracker, paging tool,
  infrastructure as code, backup console, monitoring tool, exports. You may run read queries;
  you never restore, fail over, roll back, scale, send a test page or run a load test. A drill
  is run on a stage by the client's people, by agreement; you write the scenario, you do not
  run it.
- Count and classify incidents, postmortems and pages by their fields; quote no incident text.
- A window read for an event starts before it, with margin.

## Inputs

| Input | Where |
|---|---|
| Service catalogue, tiers confirmed at stage 2 | `sre/service-catalogue.md` |
| Target model and targets, confirmed at stage 2 | `sre/target-model.md`, `sre/targets/` |
| Inventory and baseline, confirmed at stage 1 | `sre/inventory.md`, `sre/baseline.md` |
| Exports made at stage 1 | `sre/exports/` |
| Read-only access to the pipeline, incident tracker, paging tool, infrastructure as code, backup console | [tokens, profiles or MCP servers; named, never pasted] |
| Completed readiness reviews and launch tickets, if any | [location, or none] |
| Readiness checklist | `sre/templates/readiness-review.md` |
| Open questions carried from stage 2 | `sre/target-model.md`, "Open questions" |
| Facts ledger, decision and risk registers, owner questions | instructions file |

## Method

Every step has its full rule and cases under its number in the
[stage 3 reference](reference/stage-3-reference.md) (in the kit, `sre/agent/reference/`).
Read it before the step; it binds as if it were here.

1. **Scope.** The format and the dimensions in scope; those not in scope get no rows.
   Combined: an overlap topic scored in observability is referenced, not gapped again.
2. **Targets.** Per dimension in scope, the `T-` rows and its target level; a default
   is used only when the row says so; a missing target is never invented.
3. **Current state.** Per tier-1 service, or dimension-wide, what is in place today: `L-` rows,
   `B-` numbers, exports and read queries, each read a new `E-` check.
4. **Gap rows.** One `G-` row per service × dimension, or dimension-wide: target, current with
   evidence, one implementation status.
5. **Monitoring, light.** Dimension 3 at the depth of its criteria only.
6. **Readiness.** Dimension 10: the last tier-1 launch checked against the readiness
   checklist.
7. **Open questions carried.** Each answered from evidence or "not established".
8. **Blind spots.** Each handed to the person for the risk register now.

## Output

The stage report, `sre/stage-3-gap.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log and the decision register travel with it as
files at a stated commit, cited, not reprinted. Nothing in the targets changes: a target the
gap shows unreachable is an open question for its owner, not an edit.

`sre/stage-3-gap.md`:

- first, five to seven results and their consequences;
- scope: the format, the dimensions in scope, each dimension not in scope by name, and in the
  combined format each overlap topic with the observability dimension it refers to;
- gap rows: id, service (`S-`) or dimension-wide, dimension, target (`T-`, or the target
  model's level), current with its evidence (`E-`, from `L-`, `B-` and exports), status
  absent / partial / implemented ([records.md](../../method/records.md)); counts that sum to
  the rows, per dimension;
- could not evidence: each target whose current state could not be read, with its owner
  question;
- the readiness check of the last tier-1 launch, item by item, when dimension 10 is in scope;
- carried questions, blind spots;
- stage-4 candidates: each gap with the evidence a finding would cite; gaps whose fixes differ
  are separate candidates.

## Self-check before handing over

- [ ] Every row has a stable id and one status; the counts sum to the number of rows.
- [ ] Every gap row names its target and cites evidence from the estate or an earlier row in a
      stated window; nothing is implemented because a document or the code says so.
- [ ] No dimension not in scope has a row; each is listed by name.
- [ ] In the combined format, no overlap topic scored in observability is gapped again.
- [ ] Every baseline number compared with a target is labelled a reading, with its window;
      none is reported as met.
- [ ] No drill, restore, failover, test page or load test was run.
- [ ] No target, owner or threshold was changed; what the gap questions is an open question.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives, checks a sample of the gap rows,
chosen by them, through another path than the agent's query: the tool's own interface, a
record the owner shows, or a query they write. Checks the readiness check of the last tier-1
launch with its service owner. Agrees the owners of the blind spots and registers them.
Decides which scenarios are run, where and by whom. Confirms the gap as the input to stage 4,
or returns it. On confirmation the lead rewrites the summary and adds this stage's lines to the
manifest ([report](../README.md#report)).

---

# Rule: boundaries common to every stage

*Applies to every stage; N = 3. Each stage adds what it may read, query and
write.*

- Before anything else, run `python3 tools/stagegate.py check sre/engagement-state.yml 3`.
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

*Applies to every stage. N = 3.*

Keep `sre/progress/stage-3.md` in the engagement repository while you work, so a person can see
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
