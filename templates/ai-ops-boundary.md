# AI-ops boundary checklist

Many clients already run anomaly detection, event correlation or assisted investigation — built
in-house or part of their monitoring tool. The assessment builds on that work (playbook,
principle 6); it does not compete with it or duplicate it. This checklist draws the line in
week one and keeps it drawn in the Blueprint. Scores maturity dimension 12 when the client wants
it scored.

## Inventory — what the client has

| Capability | Present | What it decides | Who owns it | Evidence |
|---|---|---|---|---|
| Anomaly detection on metrics | [yes / no] | [opens problems, pages, only shows] | [team] | [export, screenshot] |
| Event correlation and deduplication | | | | |
| Root-cause suggestion | | | | |
| Assisted investigation (chat, query generation) | | | | |
| Auto-remediation | | | | |
| In-house models or scripts | | | | |

"What it decides" is the key column: a tool that only shows is a different boundary from one
that pages or acts.

## Where the line runs

- [ ] **We build on:** its detections as an input to the gap analysis; its incident history as
      evidence of what was caught and what was missed.
- [ ] **We do not duplicate:** detection, correlation or remediation it already does on the
      functions in scope. Where it is weak, that is a finding with evidence, not a replacement.
- [ ] **Our harness only reads:** read-only access, as in `method/agent-harness.md`; it never
      writes to the client's AI-ops configuration or trains its models.
- [ ] **Data it uses:** which signals feed it; whether the signals we specify (per-function
      outcomes, error class) would feed it too, and who decides that.
- [ ] **Alert ownership:** its alerts and our P1s are mapped to each other; one condition pages
      once. Where both fire on the same failure, one becomes the P1 and the other context.
- [ ] **Runbooks:** any of its outputs that page has a runbook and an owner, like any P1.

## Positioning

Say in the proposal and on the report's first pages what the tool already does and what the
assessment adds: "builds on the anomaly detection you run; adds per-function outcomes it can
learn from", never "replaces". If the client commissioned the tool recently, review its scope
with its owner before the findings preview (getting started, week 4).

## Questions for the owner

1. What does it detect today on the journeys in scope, and how do you know (a recent incident it
   caught, one it missed)?
2. Does it page anyone, or only open problems? Who acknowledges them?
3. Which signals and how much history does it rely on? What happens when a signal goes silent?
4. What share of its alerts were actionable last month? How is that measured?
5. Does it act on its own anywhere (restart, scale, roll back)? Under what guard?
6. What would you like it to learn from, that it does not see today?

## Red flags

| Seen | Why it matters |
|---|---|
| Anomaly alerts paging without runbook or owner | Pages nobody can act on; alert fatigue spreads to real P1s |
| Opaque detections nobody can explain | Responders cannot judge a firing; trust erodes |
| Auto-remediation without proven alert quality | Actions fire on noise; incidents caused by the fix |
| The tool and per-service alerts both page on one failure | Double paging; two teams on one incident |
| Detection on pooled rates or hosts only | Same blind spots as threshold alerts (lessons 2) |
| Actionable share not measured | The client cannot say whether it helps |

## Findings and maturity

Record what holds as findings with evidence. Dimension 12: vendor defaults only is level 2;
tuned detection with correlation used is level 3; assisted investigation with read-only access
is level 4; assisted remediation on proven alert quality is level 5. Mark it N/A when the client
does not intend to use it, with one sentence why.
