# SRE stage 2 — target model

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 2`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You draft the target model of an SRE assessment: the tier of each service in scope and the
reliability targets (`T-` rows) per tier, or per service where one differs. You draft; a person
confirms.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md),
[owner questions](../../tools/agent/rules/owner-questions.md) and the
[progress log](../../tools/agent/rules/progress-log.md), with N = 2. The boundaries below are this stage's
own and add to the common ones.

## Boundaries

- Read-only. You never write to the client's delivery pipeline, incident tracker, paging
  tool, backup console or monitoring configuration, and you run no drill or load test.
- You set no tier and no target. Every row enters as `proposed`; a kit default is marked
  *default, to confirm*; every value an owner must set is an owner question.
- Every tier and every candidate value cites its source: a catalogue row (`S-`), a stated need
  (the kick-off note, an interview `E-` id, a contract or policy with its date), or the
  [SRE maturity model](../maturity-model.md#dimensions) for a default.

## Inputs

| Input | Where |
|---|---|
| Critical journeys and scope, as agreed at kick-off | `kickoff-note.md`, decision register |
| Service catalogue (stage 1, confirmed) | `sre/service-catalogue.md` |
| Inventory and exports by object class (stage 1) | `sre/inventory.md`, `sre/exports/` |
| The client's stated needs: contracts, policies, interview notes | decision register, facts ledger, [path] |
| Targets template | `sre/templates/reliability-targets.md` |
| Combined format: the observability spec and its SLO rows | `spec/observability-spec.yml` |
| Facts ledger | instructions file |

## Method

Every step has its full rule, cases and tables under its number in the
[stage 2 reference](reference/stage-2-reference.md) (in the kit, `sre/agent/reference/`).
Read it before the step; it binds as if it were here.

0. **Sources agree first.** Where the sources disagree on what is critical, stop and hand
   the person a table; draft only after the owner has reconciled them.
1. **Tiers from journeys.** Propose a tier for every `S-` row, with the reason: tier 1 serves a
   critical journey in scope.
2. **Dependencies follow the tier.** Every dependency of a tier-1 service gets a proposed tier;
   a tier-1 service on a lower-tier or untiered dependency is listed as a gap.
3. **Defaults first.** Enter the default rows (on-call limit, toil cap, actionable alert
   share), each *default, to confirm*.
4. **Targets per tier.** SLO, RTO, RPO and rollout policy have no default: the value is the
   owner's, the stated needs are its candidates. So is a target level per dimension in scope.
5. **A service where it differs**, and RTO and RPO per tier-1 data store.
6. **SLOs cite, not redefine.** Each SLO follows the spec rules; in the combined format it
   cites the observability spec's SLO id.
7. **Measurable or not.** Each target names the export that measures it, or *no source*.
8. **Names first.** Service and tier names go into the glossary in the client's words.
9. **One question per value** the owner must set, in the batch format, tiers first.

## Output

The stage report, `sre/target-model.md`, follows [`stage-report.md`](../../templates/stage-report.md)
with the chain service → tier → target → owner → decision; the progress log, the decision
register and the targets file travel with it as files at a stated commit, cited, not
reprinted. Field rules and columns are in the
[reference, Output](reference/stage-2-reference.md#output).

1. `sre/targets/reliability-targets.md`, from the template: default rows, target rows, the
   SLO definitions (SRE only), the glossary and "Not agreed", every row `proposed`.
2. `sre/service-catalogue.md`: the Tier column set to *proposed* values; no other column
   changed.
3. `sre/target-model.md`, around the resulting model, not the rounds that produced it.
4. The owner question batch, added to the engagement's owner questions file.

**Combined format.** The owner questions, the findings and the decision register are shared:
one `Q-` sequence, one batch, one targets review.

## Self-check before handing over

- [ ] Every `S-` row in scope has a *proposed* tier, with its reason and source.
- [ ] Every tier-1 dependency has a proposed tier or a line in the gap list.
- [ ] Tier 1 has a row of each kind: SLO, RTO, RPO, rollout policy, on-call limit, toil cap,
      actionable alert share.
- [ ] Every `T-` row is `proposed`, with an empty Decision; a default is *default, to
      confirm*; no other value is filled in by you.
- [ ] Every value the owner must set has an owner question: plain words, one decision, what it
      blocks, candidates none chosen, each with its source.
- [ ] Every SLO states its SLI, budget and window by the spec rules, or cites the observability
      spec's id; no SLO is defined twice.
- [ ] Every value filled in where a decision left it open is marked as a reading.
- [ ] When a later decision changed the basis of an earlier one (a window, a unit, a cadence),
      every value derived from the earlier one was re-derived and returned to `proposed`
      with a question, not carried over.
- [ ] No row is renumbered; a changed target is a new row naming the one it supersedes.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives: each tier against the journeys and its
owner's answer; each target against its decision register row (only rows with a `D-` row become
`confirmed`, set by the lead). The confirmed rows go into the facts ledger with their source;
the rest stay assumptions with an owner and a date. On confirmation the lead rewrites the
summary and adds this stage's lines to the manifest ([report](../README.md#report)).

---

# Rule: boundaries common to every stage

*Applies to every stage; N = 2. Each stage adds what it may read, query and
write.*

- Before anything else, run `python3 tools/stagegate.py check sre/engagement-state.yml 2`.
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

*Applies to every stage. N = 2.*

Keep `sre/progress/stage-2.md` in the engagement repository while you work, so a person can see
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
