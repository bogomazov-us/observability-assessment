# Observability stage 4 — findings

*Task prompt. Assemble it with `tools/agent/prompt.sh 4`, which appends the rule files it
names, and paste the result as is; replace the bracketed values.*

---

You draft the findings of an observability assessment from a confirmed target model and a
confirmed gap. You draft; a person re-runs the evidence and sets the status. Until both quality
targets hold on two engagements, every stage runs as a draft to compare against, and people
write the findings ([agent-harness.md](../../method/agent-harness.md), "Measuring the
harness"): you reconcile your drafts with theirs.

## Rules

The rule files in [`rules/`](rules/) apply to this stage: [boundaries](rules/boundaries.md),
[evidence](rules/evidence.md), [claims](rules/claims.md),
[owner questions](rules/owner-questions.md) and the [progress log](rules/progress-log.md),
with N = 4. The boundaries below are this stage's own and add to the common ones.

## Boundaries

- Read-only on the client's estate: code checkout, monitoring tool, exports. You may run read
  queries in the tool; you never change its configuration, the code or tickets.
- One claim per finding. Every statement under *What we see* cites its evidence: the query text
  and its time range, file:line, the export file and row, or the inventory row id.
- Every finding is drafted with status **assumption**. You never write *confirmed*.
- Expected refusals are not failures; a metric that is not collected is a gap, not a green.

## Inputs

| Input | Where |
|---|---|
| Spec with gap results (stages 2–3, confirmed) | `spec/observability-spec.yml` |
| Gap notes: which signals are live, by what evidence; the detection matrix | `stage-3-gap.md` |
| Code scan report and estate export by class | `scan.md`, `exports/` |
| Findings people already wrote, status assumption | `findings/` |
| Facts ledger | instructions file |
| Finding template | `templates/finding.md` |
| The client's own investigation or tools, if any | [folder] |

## Method

0. Read the findings already in `findings/`. A candidate one of them covers is not drafted
   again: list it in `stage-4-notes.md` under that finding's id, with what it adds or where it
   differs, for the person to merge. A new finding takes the next free id; no id is reused.
1. Walk the chain per function: function → signal → SLI → alert → owner → runbook. Each broken
   or unproven link is a candidate finding.
2. Check the estate for the classic failures: alerts on pooled rates or hosts, alerts without
   owner or runbook, refusals inside HTTP 200 counted as success, dashboards that count page
   views instead of outcomes, signals nobody can query.
3. For each candidate, get the evidence: run the query, open the code path, find the export
   row. No evidence, no finding.
4. Write *Why it matters* as a customer or business consequence. Write *What follows* as an
   action, the role that owns it, and the maturity dimension it moves.
5. Where the client's own work already covers a point, say so and build on it.
6. Bound each claim before you write it: its window and its scope; "not shown" rather than
   "none exists"; a cause only for the window read; an absence read in part of the estate
   says what was not checked ("other accounts not checked"). A decision record that adopted a
   reading is not evidence for it: cite the code and its version, or a query.

## Output

The stage report, `stage-4-notes.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log, the decision register and the full spec
travel with it as files at a stated commit, cited, not reprinted.

1. One file per finding, `findings/F-NNN.md`, in the `templates/finding.md` format: status
   *assumption*, today's date, source, evidence level (browser / agent / tenant / document
   only), severity with its reason, the three statuses, confidence and limits, the closing
   criterion, and under each claim its `E-` ids. Candidates whose fixes differ are separate
   findings.
2. `stage-4-notes.md`: one page of result first (findings by severity, the five to seven that
   matter most and their consequence, what was not evidenced, the next step); the evidence
   catalog (`E-` id: source, window, method, result, limits); the facts-ledger rows these findings rest on (proposed, status
   assumption), and "Could not evidence" (claim, what is missing, who can provide it).

## Self-check before handing over

- [ ] Every claim has an Evidence line a reviewer can re-run without asking.
- [ ] Every finding is status *assumption*; none says *confirmed*.
- [ ] Every *What follows* names an action, an owning role and a maturity dimension.
- [ ] No finding rests on an interview or a slide alone (evidence level *document only* is
      stated when that is all there is).
- [ ] No other client's name, figure or system appears.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../../method/getting-started.md#3-calendar) gives, re-runs each cited query or opens each cited line, then sets the verdict, one of the five in
[`finding.md`](../../templates/finding.md): confirmed, disputed (with the reason), refuted,
inconclusive or resolved. A check that did not reproduce is not a refutation: too little data,
expired history or a changed configuration gives inconclusive or disputed, and true then but
fixed since gives resolved. The re-checks are read-only and recorded as evidence with their own
`E-` ids; a reviewer's reading is a recommendation, and the owner sets the verdict
([records.md](../../method/records.md)), in writing,
through the verdict batch of [`owner-questions.md`](../../templates/owner-questions.md). An anomaly
seen during a re-check that nothing explains stays an observation of unknown cause, not a new
finding. Refuted drafts are kept with the reason; they count against the harness in the
measures. The stage is confirmed once every draft is re-checked and its verdict recorded or
sent in the batch: a finding still waiting stays *assumption*, and stage 5 marks a level
resting on it provisional.

---

# Rule: boundaries common to every stage

*Applies to every stage; N = 4. Each stage adds what it may read, query and
write.*

- Before anything else, run `python3 tools/stagegate.py check engagement-state.yml 4`.
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

*Applies to every stage. N = 4.*

Keep `progress/stage-4.md` in the engagement repository while you work, so a person can see
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
