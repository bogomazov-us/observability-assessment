# Owner questions

A written questionnaire for decisions only the owner or the client can make (roles and the
decision register: [records.md](../method/records.md)). The agent, or the
lead, gathers the open questions of a stage into one batch; the owner answers in writing; each
answer is recorded in the decision register before any document cites it. A written answer is
the evidence of the decision, so the batch replaces the "we agreed in the call" that nobody can
find later.

Use it for:

- **the intake**, alongside the [intake questionnaire](intake-questionnaire.md): the questions
  that decide scope and owners, not the data requests;
- **a stage's open questions**, whenever one blocks the next stage (the names of journeys and
  functions, what success means, an SLO target, who owns an alert);
- **the verdict batch** after stage 4: the findings re-checked so far, each waiting on one of
  the five verdicts in [finding.md](finding.md).

## Rules for the batch

1. **Plain words.** The owner is not expected to know the kit's terms or read the evidence
   bundle. One decision per question; a question that hides two is split.
2. **Asked from the registers, not the report.** Before a question goes in, its id is looked up
   in the decision register and the facts ledger. One already decided is not asked again: the
   report text that still calls it open is corrected instead.
3. **Say what it blocks.** Each question names the stage, finding or document that waits on
   it. A question that blocks nothing is not sent.
4. **Candidates are marked as candidates.** List the answers the evidence allows, each with
   what it rests on, and always leave room for another answer. Each candidate names exactly one
   recommendation card or one record; a candidate that merges two is split. The agent never
   marks one as chosen; a recommendation is labelled as the lead's.
5. **Shown in the conversation too.** The agent hands a batch over inline as well as in this
   file: per item its claim, its basis and the options, then a one-line answer template
   (`Q-07: B; Q-08: 4 hours; F-012: confirmed`).
6. **Short.** A batch the owner can answer in one sitting: about ten questions. More waits for
   the next batch, ordered by what it blocks.
7. **The answer is checked, then recorded before it is used.** The lead reads each answer
   against the earlier decisions on the same cards and targets and against the confirmed
   targets; an answer that conflicts is asked again, not recorded. The lead copies it into the
   decision register with the date and who decided, then writes the register id into the batch
   and into `engagement-state.yml` (`questions[].answer_ref`). An answer relayed by someone else is
   confirmed with the owner in writing first.
8. **No answer is not an answer.** A question left open stays open; what depends on it stays
   marked as waiting. A reminder is shorter than the question: "a word per line is enough".

## Questions

Batch: [stage or occasion] · sent [YYYY-MM-DD] to [owner role] · answers by [YYYY-MM-DD]

| Q | Question | Blocks | Candidates (none chosen) | Rests on | Answer | Decided by, date | Decision |
|---|---|---|---|---|---|---|---|
| [Q-01] | [one decision, in plain words] | [stage N, F-012, a document] | (a) [one card or record, e.g. REC-004] · (b) [another single card or record] · (c) another answer | [E- ids, file:line, or "not checked"] | [the owner's words] | [role, YYYY-MM-DD] | [D- id] |

## Verdict batch (after stage 4)

The owner sets one verdict per finding: confirmed, disputed, refuted, inconclusive or resolved
([finding.md](finding.md), "Verdicts"). The re-check result is evidence; it sets no verdict by
itself.

| Finding | The claim, in one line, with its window | Re-check | Reading (a recommendation) | Verdict | Decided by, date | Decision |
|---|---|---|---|---|---|---|
| [F-012] | [claim, window, scope] | [E- id: reproduced / did not reproduce / not re-run] | [the lead's reading, marked as such] | [one of five] | [role, YYYY-MM-DD] | [D- id] |
