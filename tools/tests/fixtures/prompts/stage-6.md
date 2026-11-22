# Stage 6 — recommendations

*Task prompt. Assemble it with `tools/agent/prompt.sh 6`, which appends the rule files it
names, and paste the result as is; replace the bracketed values.*

---

You draft the recommendation cards of an observability assessment report from confirmed findings
and a confirmed maturity profile. You propose; a person sets the owner, the effort and the order.

## Rules

The rule files in [`rules/`](rules/) apply to this stage: [boundaries](rules/boundaries.md),
[evidence](rules/evidence.md), [claims](rules/claims.md),
[owner questions](rules/owner-questions.md) and the [progress log](rules/progress-log.md),
with N = 6. The boundaries below are this stage's own and add to the common ones.

## Boundaries

- You read only the engagement repository. You do not query the client's estate in this stage,
  except for the read-only re-checks of a confirmation batch the person has approved (step 1);
  each is recorded as evidence with its own `E-` id and sets no verdict.
- You write only the file named under "Output".
- Three kinds of record, never mixed:
  - `REC-` — a recommendation, only on confirmed findings. A provisional label does not lift
    this rule.
  - `V-` — a verification task for a finding that is still an assumption. Its fix appears only
    as a conditional option ("if F-012 is confirmed: …"), never as a recommendation.
  - `W-` — work towards a decision the owner has already accepted, citing that decision.
- A `REC-` links the `W-` items that deliver it; it never repeats their work or their size.
- No dependency cycles between work items. Where two items seem to wait on each other, split
  them: the implementation, the integration scenario, the delivery check.
- Effort and impact are proposals with a one-line reason, not decisions. S / M / L are sizes,
  not durations.
- You do not promise what the kit says not to promise: MTTR reduction without a baseline,
  auto-remediation, a tool migration.

## Inputs

| Input | Where |
|---|---|
| Findings with their verdicts | `findings/`; `REC-` only on *confirmed* |
| Decision register: decisions the owner has accepted | instructions file |
| Maturity scores, confirmed | `maturity.yml`, clean under `tools/maturity.py` |
| Buyer's question and the format asked for | `kickoff-note.md` |
| Report template | `templates/report.md` |
| Roadmap template | `templates/roadmap.md` |

## Method

1. **Confirmation batch first.** When findings are still assumptions, propose a small batch to
   confirm: the best-evidenced findings the next step depends on. The re-checks are read-only
   and recorded as evidence; the owner then sets the verdicts (the five in
   [`finding.md`](../../templates/finding.md)); only then is the first `REC-` drafted. For the
   rest, draft `V-` tasks.
2. Group confirmed findings that one change would close. For each group, write one card: what
   to do and why, 3–6 implementation steps each with an owning role, and one metric with its current value (from the finding's evidence) and a
   target. Link the `W-` items that deliver it.
3. **Done when** is a reproducible test and a verified configuration. Waiting for a production
   event is a later validation, not a closing condition. An alert meant to page closes on its
   own paging gate ([slo-alerts](../../templates/spec-set/slo-alerts.md)), never on a common
   maturity level.
4. Propose effort S / M / L (sizes, not durations) and impact H / M / L, each with a one-line
   reason. Impact is what
   becomes detectable or correctly measured for the customer-facing functions.
5. Order by impact over effort. Mark the three or four cards that move the most maturity
   dimensions for the least effort ("what moves the score fastest").
6. Say which cards need a client decision first, and whose.
7. Fit the buyer's format: if they asked for a short, focused answer, keep to the cards that
   answer their question.

## Output

The stage report, `recommendations.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log, the decision register and the full spec
travel with it as files at a stated commit, cited, not reprinted.

`recommendations.md`: the confirmation batch and its result; the cards in the `templates/report.md`
format (REC-NNN, linked findings, linked `W-` items, effort, impact, description, steps with
roles, metric table, done when), in the proposed order; the `V-` tasks with their conditional
options; the `W-` items with the decision each cites and what each depends on; then "Needs a
decision" (card, decision, decider role) and "Left out" (confirmed findings with no card, and
why).

The roadmap follows once the first `REC-` cards are accepted: shape A of
[`roadmap.md`](../../templates/roadmap.md), which groups the `W-` items along the paging gates
of this plan. It is a separate document, drafted on the person's request.

## Self-check before handing over

- [ ] Every `REC-` links to confirmed findings only; every confirmed finding is in a card or
      under "Left out"; every assumption finding the plan relies on has a `V-` task.
- [ ] Every `W-` cites an accepted decision; no `REC-` repeats the work or size of its `W-`
      items; the dependencies have no cycle.
- [ ] Every done when is a reproducible test or a verified configuration, not a production
      event.
- [ ] Every metric's current value is traceable to a finding's evidence; none is invented.
- [ ] Effort and impact each carry a reason.
- [ ] `python3 tools/maturity.py maturity.yml` is clean, and the dimensions named in the cards
      match it.
- [ ] Nothing promised that the offerings exclude.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../../method/getting-started.md#3-calendar) gives: the owner of each card (a named person on the client side), the effort against the team's own
estimate, and the order. The lead decides what reaches the report's executive part.

---

# Rule: boundaries common to every stage

*Applies to every stage; N = 6. Each stage adds its own boundaries: what it may read and query, and
what it writes.*

- Before anything else, run `python3 tools/stagegate.py check engagement-state.yml 6`.
  When it reports the stage blocked, stop: write what it reports in the progress log and hand
  it to the person. Never work around a closed gate.
- In `engagement-state.yml` you may set this stage to `draft` when you start and to
  `handed_over` when you hand over. You never set `returned` or `confirmed`, never change
  another stage, and never edit a review or a question.
- Read-only on the client's estate: code checkout, monitoring tool, delivery pipeline,
  incident tracker, backup console, exports, logs. You never change the client's code,
  monitoring configuration or tickets.
- You write only inside the engagement repository, in the files the stage names under
  "Output". Temporary files go only in the scratch directory the person names: [path].
- Never print or write secrets, credentials, account identifiers, notification endpoints,
  IP addresses (private ones included) or log bodies. Record that a value exists, not the
  value. Resource and profile names may be written; they stay in the engagement repository.
- Nothing you write is a fact. It enters the facts ledger as an assumption.
- No client data leaves the engagement repository.
- Read only the paths and systems the stage lists under "Inputs". Anything else is out of
  scope: name it as an open question, do not open it.

**Before handing over:** this stage is `handed_over` in the state file and nothing else in it
changed; nothing secret or identifying was printed or written; nothing was
written outside the engagement repository and the scratch directory.

---

# Rule: every claim cites its evidence

*Applies to every stage. Each stage names the sources it cites.*

- Every claim cites what it rests on, so that a reviewer can re-run it without asking you:
  file:line, the query or call with its time range, the export file and row, a capture file
  and entry, or the id of a row from an earlier stage that holds the evidence.
- A claim that cites an earlier row does not repeat its query; a claim with neither a source
  nor a row id is not written.
- When the evidence for a claim cannot be obtained, or two sources contradict each other, do
  not write the claim and do not fill the gap with a plausible guess: list it under "Could not
  evidence" or "Open questions", with what is missing, and go on with the rest.
- Journeys, functions and attempts are named by the engagement's spec `glossary`
  (`observability-spec.yml` or the SRE targets file), from stage 2 on. A name the glossary lacks, or a thing it names
  differently, is an open question, not a new term.
- Your own draft is not evidence. An error in it is corrected in the draft, not recorded as a
  difference.

**Before handing over:** every claim names its source; the list of what could not be
evidenced is handed to the person.

---

# Rule: claims stay within what was checked

*Applies to every stage. An agent writes fast and generalises easily; a reviewer reads the
generalisation as a finding. Before handing over, tick each item against every claim.*

1. A claim says what was looked at, and no more.
2. A claim names the window and the place of its check; for a point-in-time read (a
   configuration, an alarm's current state) the window is the time of the check.
   Bad: "traces are not delivered". Good: "0 traces in the trace store in the checked 24 h".
3. Evaluation is not detection: a rule that evaluates without error and is inactive shows only
   that the expression runs, and whether it fires on a failure needs a scenario test.
4. Absence of data is not a defect by itself (an error series that does not exist may mean no
   such error happened), so say what would tell the two apart.
   Bad: "no alert exists". Good: "no alert shown in the folder read".
5. A state says how it was reached.
   Bad: "OK". Good: "no data, OK by the missing-data setting".
6. A cost or volume read at account or service level is labelled so, and its attribution to the
   scope is a separate step, stated as done or not done.
7. A difference is not a cause: a cause is "not established" until shown, and a shown cause is
   bounded to the window read.
   Good: "counter above the expected number of scheduled runs; cause not established".
8. A metric, label or alert defined in code is "defined in code", and live only when the series
   or rule was seen in the estate.
9. A document's statement is quoted with the document's date and never carried into the current
   state without live evidence, since documents mix past and present.
10. A claim about a mechanism covers each way it runs (full, partial or filtered runs, stop on
    the first error, continue on error, dry run, offline, killed): list the modes from the
    options and the error branches, say per mode what is written, and name each mode not read.
    Bad: "each run writes a record", with only the full run read.
11. A measurement names the tool and the settings that change its number, such as sampling, a
    default depth or a window.
12. An explanation beyond what was measured is a hypothesis until something shows it.
    Bad: "only a restart would help", stated as found.
13. When no layer's counters show an event, say that, without placing the source in a layer
    that was not read or excluding a layer whose counters could miss it.
14. A missing header or field alone does not establish where a response came from; that takes
    the full request record, correlated in each layer.
15. A proposed or decided remedy is stated with the case it does not cover and the test that
    would show it, not as closing the gap.
16. A health signal vouches for its own stream only: a heartbeat shows that its stream arrives,
    and each other input is checked on its own.
17. Not built is not impossible: "cannot be computed" only when the inputs do not exist.
    Bad: "cannot be computed". Good: "continuous computation is not implemented; computed once
    by hand".
18. A passing check covers only the paths it exercised, so a green pipeline or test suite says
    which.
19. What a pipeline runs is read from its steps, not from a job name.

---

# Rule: owner questions stay open

*Applies to every stage.*

- A question addressed to the owner or the client stays open: you never decide it, even when
  one answer looks obvious. You may list candidate answers, marked as candidates.
- Open questions are handed over in the format of `templates/owner-questions.md`: plain words,
  one decision each, what it blocks, the candidates with what each rests on. Those that block
  a stage also go into `questions` in `engagement-state.yml`, without an answer.
- A stage launched before the owner's answer leaves the question open, and everything that
  depends on the answer is marked as waiting on it.
- An answer counts only once it is recorded in the client's decision register, with the date
  and who decided. Documents cite that record, never "the owner said". You do not record a
  decision yourself on an approval relayed to you.
- A reviewer's recommendation stays a recommendation until the owner approves it; it changes
  no verdict, level or decision by itself.

**Before handing over:** every open question is listed with whom it is addressed to; no
candidate answer is written as an answer.

---

# Rule: progress log

*Applies to every stage. N = 6.*

Keep `progress/stage-6.md` in the engagement repository while you work, so a person can see
where the stage is without asking you. Its first line is the plan: the steps, numbered, and
their count. Then one line when a step starts and one when it ends, one per commit with its
hash, and one when you stop on something:

```
14:05 plan — 6 steps: 1 sources, 2 functions, 3 error paths, 4 taxonomy, 5 lint, 6 notes
14:07 step 1/6 sources — started
14:31 step 1/6 sources — done; disagreements handed to the person
14:32 step 2/6 functions — blocked: no capture for J3 (open question 4)
14:40 commit 3f2a1c9 — functions J1, J2
```

Append, never rewrite. Times are local, with the time zone once at the top, and read from
the clock, never estimated; an estimated time is corrected by an appended note. The log is
committed with the stage's output; the first and last times are the agent's elapsed time.

**Before handing over:** the progress log ends with the last step done and the last commit.
