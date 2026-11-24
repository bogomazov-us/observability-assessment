# Second reading of drafted findings (optional)

*Task prompt, started only by a person, after stage 4 drafts are handed over and before or
during the review round. Optional: an engagement without it is complete, and its measures are
too. It is not a stage: it opens no gate, and no gate waits for it. Both assessment types.*

**What it is.** A second reader of each drafted finding against the claim rules, so the reviewer
starts from a list of places to look. **What it is not.** Evidence, a re-check or a verdict. A
reader run on the same model as the drafter tends to share its blind spots: a finding it passes
is not shown sound, and its notes are recommendations the reviewer accepts or rejects.

## Boundaries

- Read only the files the person names below. Do not query the client's systems, re-run a
  check, or open a path that is not listed; a claim you cannot judge from them is
  `needs_human_review`, with what is missing.
- Write only the "Second reading" table of the review file the person names, and only in a
  round still in progress: a file not yet named by a review in the state file. If the file is
  named there already, it is a recorded round: stop and ask for a new round's file. Never edit a
  finding, its status or severity, the state file, the verdict batch, the decision register or
  another review; never write `confirmed`, a verdict or a D- id.
- Nothing secret or identifying is printed or written, as in
  [boundaries](rules/boundaries.md) (the gate check of that rule does not apply here).

## Inputs (named by the person)

| Input | Path |
|---|---|
| The findings to read, one file each | `findings/F-NNN.md` [list] |
| The gap records they cite | [`stage-3-gap.md`] |
| The evidence entries they cite, and nothing more | [the stage's evidence catalog] |
| The claim rules | [`<kit>/tools/agent/rules/claims.md`](rules/claims.md) |
| The finding format | [`<kit>/templates/finding.md`](../../templates/finding.md) |
| The review file to write in | [`reviews/stage-4-round-N.md`] |

## Method

For each finding, read *What we see*, *Confidence and limits* and the severity line against the
cited evidence entries and gap rows, and look for these, each tied to its rule:

| Look for | Rule |
|---|---|
| A claim wider than what was looked at: all services, all accounts, "no alert exists" from part of the estate | claims 1, 2 |
| Evaluation read as detection: a rule that evaluates, with no firing, delivery or acknowledgement shown | claims 3 |
| Missing data read as a defect, or as its absence | claims 4 |
| A cause where only a difference was shown | claims 7, 12 |
| Defined in code read as live | claims 8 |
| A dated document carried into the current state | claims 9 |
| A severity whose reason does not follow from what was seen, or the scale in `finding.md` | finding.md, "Severity" |
| An evidence entry that does not say what the sentence citing it says | evidence |

For each place found, one row. A finding with nothing found gets one row `pass`, which says only
that this reading found nothing.

## Output

Append under `## Second reading` in the review file, creating the heading if absent:

```
Read by: [tool and model, as named by the person] on YYYY-MM-DD. A second reading; recommendations only.

| Finding | Rule | Excerpt | Reason | Flag | Reviewer |
|---|---|---|---|---|---|
| F-NNN | claims 1 | "[the words, quoted]" | [why it may overreach, citing E-/G- ids] | needs_revision | open |
```

- **Flag:** `pass`, `needs_revision` (the text says more than its evidence), or
  `needs_human_review` (the reading cannot tell from the files given).
- **Reviewer:** always `open` when you write it. Before the round is recorded, the reviewer sets
  `acted` (changed something because of it), `agreed_no_change` (right, nothing to change) or
  `disagreed` (the flag was wrong); [harness-metrics.md](../harness-metrics.md) counts them.
- Quote the finding's words exactly, at most one sentence; no client data beyond what the
  finding itself holds.

If the reading could not run (no access to the files, a limit reached), write one row per
finding with `needs_human_review` and the reason, or nothing at all: the review goes on as if it
had not run.

## Self-check before handing back

- [ ] Only the "Second reading" table changed; `git diff` shows no other file.
- [ ] The review file is not named by any review in the state file: the round is still open.
- [ ] Every row names a finding, a rule and the excerpt it rests on; every Reviewer cell is `open`.
- [ ] No row says a claim is true, confirmed or proven.
