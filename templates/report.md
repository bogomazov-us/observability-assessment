# Assessment report — summary chapter

The first chapter of the assessment report (`summary.md`); the stage chapters follow it
([one report](../method/report.md#one-report-for-the-whole-assessment)). It carries only what no
chapter does, in five pages at most: the first page answers the buyer's question, the last asks
for a decision; once accepted, the hand-over follows it.

- **Current, not history.** The summary always states the current position of every decision,
  finding and card it names. The stage chapters are history: a status a later decision
  superseded is not rewritten there; the chapter gets a dated note at its top, "Later
  (YYYY-MM-DD): D-14 closed this; see the summary."
- **A decision is cited with its record:** "D-12", "ADR-007 item 3", never a bare "item 3" or
  "the decision", in the summary and in every chapter. A bare reference is misread by anyone
  checking the text against the register.
- **Closing and acceptance** follow [Closing the report](../method/report.md#closing-the-report).

```markdown
# [Observability | SRE | Observability and SRE] assessment — summary

Project: [name] · Version: [commit] · Date: [date] · Stages accepted: [1–N] ·
Document status: draft | accepted by [name, role] on [YYYY-MM-DD] ([D- id])

## 1. Answer
[The buyer's question in their words, and the answer, in the format they asked for; the three
findings that matter; maturity at a glance ("you are here"); the decision we ask for.]

## 2. Context
[What the client asked, in their words; interviews by stream and count; dependencies; what this
data cannot tell us. Scope and method are in each chapter.]

## 3. Answers to the client's key questions
[A section per question, citing the chapter and the ids that carry it.]

## 4. Maturity by dimension
[The stage 5 profile; per dimension: Highlights / Keep an eye on / Lowlights. Combined
format: a profile per type.]

### Baseline numbers (SRE: required)
[From `sre/baseline.md`, one row per `B-` id; a number the data cannot support reads
*not measured* with the reason. Incidents per severity; time to detect and to recover;
recurrence share; deployment frequency, change lead time, change failure rate, failed
deployment recovery time; deployment rework rate when the export allows; pages per shift and
off-hours share; actionable alert share against the client's target (it has no default).]

| ID | Number | Value | n | Method | Window | Source |
|---|---|---|---|---|---|---|

## 5. Recommendations and roadmap
[The `REC-` cards of stage 6 in their order, impact over effort. Golden journey proof (full
format): what was instrumented, what it showed. The roadmap in brief: quick-fix hardening →
adoption → evolution, in sequence with effort ranges (dates once the executor is known), milestones per `roadmap.md`.]

## 6. Business impact
[What becomes detectable, how fast, and what it is worth where data allows.]

## 7. Changes
| Version | Stage or change | Date |
|---|---|---|

## 8. Decision requested
[On a page of its own: the decision in one sentence; the options if there are several; who
decides; by when.]

## 9. Hand-over (at acceptance)
[What happens next, so the owner does not have to ask. Built from the decision register and the
roadmap, not from the text above.]

### Open decisions
| D- or Q- id | Decision needed | Decider | By when |
|---|---|---|---|

### Decided, not yet scheduled
| W- id | Work, and the D- id it delivers | Owner (named person) | Next step |
|---|---|---|---|

### Only the client can do
[The assessment is read-only: every change to the client's code, configuration, tickets and
rota is the client's. List each, with its owner. Optionally the `W-` items are filed as tickets
in the client's tracker by the client, and their keys added to the table above.]
```

## Recommendation card

Stage 6 writes one per `REC-`.

| REC-NNN | Linked findings | Effort S/M/L | Impact H/M/L |
|---|---|---|---|

- **Description.** What and why.
- **Implementation steps.** 3–6 steps with owners.
- **Metric.**

| Metric | Current | Target |
|---|---|---|
| e.g. share of tier-1 calls linked end to end in a controlled run | none | 95 % |
