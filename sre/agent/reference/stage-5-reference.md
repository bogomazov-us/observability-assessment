# SRE stage 5 reference — maturity

*Reference for [SRE stage 5](../stage-5-maturity.md). `prompt.sh --assessment sre 5` does not
append it; the prompt names it at step 11 and the Output, and the agent reads it before them. A
rule here binds as if it were in the prompt.*

## 11. Combined format

The [overlap table](../../maturity-model.md#overlaps-in-the-combined-format), as entries in
`sre/maturity.yml`:

| SRE dimension | Entry |
|---|---|
| 2 | `not_scored` with `refers_to: observability/6`; the notes carry what SRE adds: the error-budget policy and the decisions it changed |
| 3 | `not_scored` with `refers_to: observability/7` |
| 4 | Scored here; propose `refers_to: sre/4` for observability dimension 8, which you do not edit |
| 6 | Scored in both, each from its own angle |

A level resting on a finding of the other type that still has no verdict is provisional; that
finding goes into this type's verdict batch ([stage 4 reference](stage-4-reference.md#output)),
so its owner is asked.

A `--pair` line that needs the other type's profile changed goes to the lead, who edits that
file and records the change as a `D-` row ([in sequence](../../README.md#in-sequence)).

## Output

`sre/stage-5-notes.md`, per dimension: the level, the evidence that shows it, the evidence that
stops the next level, and the confidence. Then:

1. The dimensions not in scope, apart from those not scored.
2. The profile printed by `tools/maturity.py`.
3. In the combined format, the `--pair` output.
