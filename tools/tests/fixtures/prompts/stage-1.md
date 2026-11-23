# Stage 1 — inventory

*Task prompt. Assemble it with `tools/agent/prompt.sh 1`, which appends the rule files it
names, and paste the result as is; replace the bracketed values.*

---

You draft the inventory of an observability assessment: what the code and the configuration say
is collected, alerted on and routed, checked against what the monitoring estate shows live. You
draft; a person confirms.

## Rules

The rule files in [`rules/`](rules/) apply to this stage: [boundaries](rules/boundaries.md),
[evidence](rules/evidence.md), [claims](rules/claims.md),
[owner questions](rules/owner-questions.md) and the [progress log](rules/progress-log.md),
with N = 1. The boundaries below are this stage's own and add to the common ones.

## Boundaries

- Read-only. You read the code checkout and query the monitoring estate through a read-only
  token, profile or MCP server: list, describe, get and read-only queries only.

## Inputs

| Input | Where |
|---|---|
| Scope: journeys and services, as agreed at kick-off | `kickoff-note.md`, decision register |
| Code checkout (read-only) | [path] |
| Read-only access to the monitoring estate | [token, profile or MCP server; named, never pasted] |
| Facts ledger, risk register | instructions file |

## Method

1. From code and configuration, list each object by the classes of
   [collect.md](../collect.md), "Estate export by object class": what should exist.
2. Query the estate for each object: does it exist, and does it match? Record the query and its
   time range.
3. One row per object, each with a stable id (`L-01`, `L-02` …) that later stages cite. Ids are
   never renumbered: a row split later keeps its id on one part and gives the other a new one;
   a row withdrawn keeps its id with the reason. Give every row exactly one status, comparing the live object with the
   code or configuration (never with your own draft):

   | Status | Means |
   |---|---|
   | confirmed | exists as the code or configuration says; a live fact that contradicts nothing (a count, a last run) is stated in the row |
   | differs | exists, but differs from the code or configuration, or exists live with no code or configuration behind it |
   | not found | no object, or no data, in the checked window |
   | not verifiable | not attempted or not possible: outside the access granted, the system is down, or the comparison needs an attribution not yet done; say which |

   The statuses do not overlap (status sets: [records.md](../../method/records.md)). The summary gives each count and their sum, and the sum equals
   the number of rows. An error in your own draft is corrected in the draft, not recorded as
   a difference.
4. Reconcile the classes with each other: an alert with no route to a person, a metric no alert
   reads, a route with no subscriber.

## Output

The stage report, `inventory.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log, the decision register and the full spec
travel with it as files at a stated commit, cited, not reprinted.

1. `inventory.md`: one page of result (scope, objects by status, material differences, what
   was not checked), then the live verification table (class, object, status, evidence by
   `E-` id — the commands and their output go to the evidence catalog), sources read as an
   appendix, each snapshot with its commit or configuration revision, the status summary with its sum, the reconciliation, the code scan leads, and
   what could not be inventoried with the reason.
   In the reconciliation, a claim may cite the row id that holds its evidence instead of
   repeating the query; a claim with neither is not written.
2. A list of **confirmed blind spots** — a check that cannot fire, a notification that reaches
   nobody, a check the design or the journey definitions rely on that does not exist — handed to the person for the risk register now, each as a row of its columns: risk, source (blind spot, stage 1, row id), proposed owner, status *open*, date. They do
   not wait for the findings of stage 4; the finding is written there and links the risk.
3. `scan.md`: the report of `tools/collect/code-scan.sh` on the code checkout, unless the
   person has run it already.
4. `exports/`: what you read from the estate, a file per object class named with the class
   and export date (`exports/alert-rules-2027-03-01.json`), sanitized per the
   [privacy checklist](../../templates/privacy-checklist.md), stating its query or call, time
   and count ([collect.md](../collect.md)).

## Self-check before handing over

- [ ] Every row has a stable id and one status; the counts sum to the number of rows.
- [ ] Every inventory row cites an export file or a query.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../../method/getting-started.md#3-calendar) gives, checks that the
exports reconcile (counts, names) and the statuses sum to the rows; re-runs a sample of the cited checks, chosen by them, and records each result; an object
confirmed by a live fact is checked through another path than the agent's query (the tool's
own interface, a browser, or a query they write). A sample that
reproduces says those claims hold; it is not an estimate of the accuracy of the whole
inventory. Registers the confirmed blind spots as risks with owners. Confirms the inventory as
the baseline for stage 2, or returns it; on confirmation the document's own status line is
updated, so it never says "assumption" after it was confirmed.

---

# Rule: boundaries common to every stage

*Applies to every stage; N = 1. Each stage adds what it may read, query and
write.*

- Before anything else, run `python3 tools/stagegate.py check engagement-state.yml 1`.
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

*Applies to every stage. N = 1.*

Keep `progress/stage-1.md` in the engagement repository while you work, so a person can see
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
