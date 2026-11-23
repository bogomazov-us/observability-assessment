# Harness measures

`tools/harness-metrics.py` computes the [harness measures](../method/agent-harness.md#measuring-the-harness)
of one engagement from the records the engagement already keeps. It reads and never writes; it
does not set a verdict, a status or a gate.

```
tools/harness-metrics.py engagement-state.yml          # observability, or the combined report root
tools/harness-metrics.py sre/engagement-state.yml      # the SRE assessment's own state file
tools/harness-metrics.py engagement-state.yml --json   # the same, as JSON
tools/harness-metrics.py engagement-state.yml --findings path/to/findings
```

Exit 0: measured (some values may read "not measured"). Exit 1: the records break a rule below;
the measures are still printed, the violations go to standard error as `where: RULE message`.
Exit 2: the state file cannot be read. Needs Python 3.9+ and PyYAML. The first line names the
git commit the inputs were read at, and says when an input has uncommitted changes, so a
reported number can be traced to the records it came from.

## What it reads

| Measure | Record | Written by, when |
|---|---|---|
| Review hours per stage | `review_hours` on each review block of the state file; summed over the rounds | The reviewer, when the round is appended |
| Rework hours per stage | `rework_hours` with the stage's confirmation | The lead, when confirming |
| Agent span | First and last clock time in `progress/stage-N.md` beside the state file, across its date lines | The agent, as it works ([progress log](agent/rules/progress-log.md)) |
| Re-checks | "Re-checks" table of each review file: `E-` id, reproduced or not reproduced | The reviewer ([review.md](../templates/review.md#re-checks)) |
| Finding outcomes | "Finding outcomes" table of the stage 4 review files: `F-` id and labels | The reviewer ([review.md](../templates/review.md#finding-outcomes-stage-4)) |
| Second reading (optional) | "Second reading" table of the stage 4 review files: flag and the reviewer's disposition | The reading writes it ([review-findings.md](agent/review-findings.md)); the reviewer sets acted or not_acted |
| Verdict | The Status cell of the finding's first table, `findings/F-NNN.md` | The owner of the verdict |

Review files are found from the paths the review blocks name, beside the state file or one
folder up. Findings are read from `findings/` beside the state file or one folder up (an SRE
assessment keeps its state in `sre/` and shares the report's `findings/`), or from `--findings`.
In a combined report a finding counts for the model its `**Model:**` line names; a finding
without one counts for both.

## How it counts

- **On findings with a verdict only** (confirmed, disputed, refuted, inconclusive, resolved).
  Findings still `assumption` are reported as pending and left out of the rates. A finding with
  a verdict but no outcome row is listed by id and left out too: its outcome was not measured.
- **One finding, one count.** A finding reviewed in several rounds counts once, with the labels
  of all its rows.
- **Strict unchanged:** none of bounded, new_input, corrected, severity_changed.
  **Lenient unchanged:** neither corrected nor severity_changed. `split_merge` is a change of
  granularity: counted apart, it does not by itself take a finding out of either reading.
- **Hours:** absent reads "not measured", never zero; an explicit 0 reads "0 h". When only some
  rounds of a stage carry hours, the sum says how many of how many.
- **Re-checks** read "n of n selected reproduced": a sample, not the accuracy of the output.
- **A second reading** is counted apart: its flags (a `pass` is not a flag) and how many the
  reviewer acted on, did not act on, or left open. It moves no rate. The reviewer's time on it
  is part of the review hours, so a reading that costs more than it saves shows there.
- **Outcomes are recorded at stage 4 only.** Stages 1 to 3 and 5 to 6 report hours, span and
  re-checks.

## Rules

| ID | Check |
|---|---|
| H01 | An outcome row names one finding id, and that finding exists for this assessment |
| H02 | An outcome is one or more of unchanged, bounded, new_input, corrected, severity_changed, split_merge |
| H03 | `unchanged` stands alone in its row (a later round may still record a change) |
| H04 | A re-check row is an `E-` id and reproduced or not reproduced |
| H05 | Hours are a number, 0 or more |
| H06 | A review file the state file names exists |
| H07 | A second-reading row is a finding id, a flag (pass, needs_revision, needs_human_review) and the reviewer's disposition (open, acted, not_acted) |

[`tools/stagegate.py`](stagegate.md) checks the hours in the state file too (G15) and warns when
the file records hours and one is missing (W02).

## Limits

The measures are as good as the records: a review not written down, or hours added afterwards
from memory, are not detected. The rates on one engagement rest on few findings: report the
numerator and the denominator with them, and read 70 % on a dozen findings as a direction, not
a result.

Tests: `tools/tests/test_harness_metrics.sh` (a fictional engagement of 14 findings in both
layouts; every rule has a case).
