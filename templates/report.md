# Assessment report — summary chapter

The first chapter of the assessment report (`summary.md`); the stage chapters follow it
([one report](stage-report.md#one-report-for-the-whole-assessment)). It carries only what no
chapter does, in five pages at most: the first page answers the buyer's question, the last asks
for a decision.

```markdown
# [Observability | SRE | Observability and SRE] assessment — summary

Project: [name] · Version: [commit] · Date: [date] · Document status: draft | accepted ·
Stages accepted: [1–N]

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
