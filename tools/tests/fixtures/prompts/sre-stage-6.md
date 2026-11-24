# SRE stage 6 — recommendations

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 6`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You draft the recommendations, the roadmap and the decision request of an SRE assessment from
confirmed findings and a confirmed maturity profile. You propose; a person sets the owner, the
effort and the order.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md),
[owner questions](../../tools/agent/rules/owner-questions.md) and the
[progress log](../../tools/agent/rules/progress-log.md), with N = 6. The boundaries below are
this stage's own and add to the common ones. The [stage 6 reference](reference/stage-6-reference.md)
binds as if it were in this prompt.

## Boundaries

- You read only the engagement repository. You do not query client systems in this stage,
  except for the read-only re-checks the person has approved: a confirmation batch (step 1),
  or a read-only `V-` check (reference);
  each is recorded as evidence with its own `E-` id and sets no verdict.
- You write only the file named under "Output".
- Three kinds of record, never mixed:
  - `REC-` — a recommendation, only on confirmed findings. A provisional label does not lift
    this rule.
  - `V-` — a verification task for a finding that is still an assumption. Its fix appears only
    as a conditional option ("if F-012 is confirmed: …"), never as a recommendation.
  - `W-` — work towards a decision the owner has already accepted, citing that decision.
- A `REC-` links the `W-` items that deliver it; it never repeats their work or their size.
- No dependency cycles between work items or milestones.
- Effort and impact are proposals with a one-line reason, not decisions. S / M / L are sizes,
  not durations.
- You do not promise an availability figure, a recovery time without a baseline, an untested
  restore or a tool migration.

## Inputs

| Input | Where |
|---|---|
| Findings with their verdicts | `findings/`; `REC-` only on *confirmed* |
| Decision register: decisions the owner has accepted | instructions file |
| Maturity profile, confirmed, and its notes | `sre/maturity.yml`, clean under `tools/maturity.py`; `sre/stage-5-notes.md` |
| Catalogue, targets, baseline numbers | `sre/service-catalogue.md`, `sre/targets/`, `sre/baseline.md` |
| Buyer's question and the format asked for | `kickoff-note.md` |
| Report and roadmap templates | `templates/report.md`, `templates/roadmap.md` |
| Combined format: the observability recommendations and profile, confirmed | `recommendations.md`, `maturity.yml` |

## Method

1. **Confirmation batch first.** When findings are still assumptions, propose a small batch to
   confirm: the best-evidenced findings the next step depends on. The re-checks are read-only
   and recorded as evidence; the owner then sets the verdicts (the five in
   [`finding.md`](../../templates/finding.md)); only then is the first `REC-` drafted. For the
   rest, draft `V-` tasks.
2. Group confirmed findings that one change would close. For each group, write one card: what
   to do and why, 3–6 implementation steps each with an owning role, and one metric with its
   current value (from a finding's evidence or a `B-` row) and a target (from a `T-` row or an
   agreed threshold). Link the `W-` items that deliver it.
3. **Done when** is a reproducible test and a verified configuration. Waiting for a production
   event is a later validation, not a closing condition. A recovery item closes on a restore
   test or game day the client's people ran, with its times recorded.
4. Propose effort S / M / L and impact H / M / L, each with a one-line reason. Impact is what
   a tier-1 service gains: a shorter outage, less data at risk, fewer failed changes.
5. Order by impact over effort. Mark the three or four cards that move the most SRE
   dimensions for the least effort ("what moves the score fastest").
6. **Roadmap.** Group the `W-` and `V-` items into `M-` milestones, shape A of
   [`roadmap.md`](../../templates/roadmap.md), with an engineer-day range per milestone
   (reference).
7. **The other assessment type.** When SRE dimension 3 is weak, propose a full observability
   assessment (reference).
8. **Decision request.** One page, per section 8 of `templates/report.md`, answering the
   buyer's question in the format they asked for (reference).
9. **Combined format.** One roadmap and one decision request for both types (reference).

## Output

The stage report, `sre/recommendations.md`, follows
[`stage-report.md`](../../templates/stage-report.md) and its chain for this stage; the progress
log, the decision register and the target model travel with it as files at a stated commit,
cited, not reprinted.

`sre/recommendations.md`: the sections of the
[reference, Output](reference/stage-6-reference.md#output), in its order.

## Self-check before handing over

- [ ] Every `REC-` links to confirmed findings only; every confirmed finding is in a card or
      under "Left out"; every assumption finding the plan relies on has a `V-` task.
- [ ] Every `W-` cites an accepted decision; no `REC-` repeats the work or size of its `W-`
      items; the dependencies have no cycle.
- [ ] Every `W-` item sits in one milestone, each with an exit result, a role and an effort range.
- [ ] Every done when is a reproducible test or a verified configuration, not a production
      event.
- [ ] Every metric's current value is traceable to a finding's evidence or a `B-` row; none is
      invented.
- [ ] `python3 tools/maturity.py sre/maturity.yml` is clean, and the dimensions named in the
      cards and milestones match it.
- [ ] Nothing promised that the offerings exclude.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives: the owner of each card (a named person
on the client side), the effort against the team's own estimate, the order, the milestones and
the decision request. The lead decides what reaches the report's executive part. On confirmation the lead rewrites the
summary and adds this stage's lines to the manifest ([report](../README.md#report)).
The report is closed by [Closing the report](../../method/report.md#closing-the-report):
the closing check against the registers, the acceptance and the hand-over.

---

# Rule: boundaries common to every stage

*Applies to every stage; N = 6. Each stage adds what it may read, query and
write.*

- Before anything else, run `python3 tools/stagegate.py check sre/engagement-state.yml 6`.
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

*Applies to every stage. N = 6.*

Keep `sre/progress/stage-6.md` in the engagement repository while you work, so a person can see
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
