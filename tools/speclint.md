# Spec linter

`tools/speclint.py` checks `observability-spec.yml`, the checkable core of a Blueprint
specification set. The nine Markdown documents stay the documents people read; the spec file
holds the chain journey → function → signal → SLO → alert → owner → runbook in a form a machine
can check, so a broken link in the chain is found before a reviewer reads a page.

Skeleton: `templates/spec-set/observability-spec.yml`. Filled in for the fictional worked
example: `example/worked-example.spec.yml`.

## Run

```
python3 tools/speclint.py docs/observability/observability-spec.yml
python3 tools/speclint.py --strict --check-files docs/observability/observability-spec.yml
```

Python 3.9 or later with PyYAML. One line per finding: `file: path.to.item: RULE severity:
message`. Exit 0 when clean (warnings allowed), 1 on findings, 2 when the file cannot be read
or parsed. `--strict` fails on warnings too; `--check-files` checks that runbook paths exist,
relative to the spec file.

## Where it fits

- **Blueprint, review round 1:** the spec is linted clean with `--strict --check-files` before
  the first round. The reviewer spends the round on judgement, not on missing owners
  ([review.md](../templates/review.md), checklist "Specification set").
- **Implementation:** the linter runs in the client's pipeline next to the code. A signal moves
  to `live` only with its evidence, and an alert moves to `paging` only when every signal under
  its SLO is live.

## What the file holds

| Section | One entry per | Key fields |
|---|---|---|
| `journeys` | journey, with its `functions` | id, name, route, success, requirement, current (state, evidence) |
| `taxonomy` | code or condition, per context | function, code, context, http, class, customer_sees, confirmed_by |
| `signals` | event or span | function (or attempt), name, emitted_by, attributes, state, evidence |
| `attempts` | business attempt spanning several functions (optional) | functions, outcomes, ambiguous_after, reconciliation |
| `slos` | SLI | subject, good, valid, bad, expected_refusals (treatment, reason), traffic, target, window, owner, status |
| `alerts` | alert | slo, severity, condition, for, min_volume, grouping, notifies, runbook, delivery_test, state, owner, status |

**Target and current state are kept apart.** Everything except `current` describes the target.
`current` holds what exists today with its evidence from the inventory; `unknown` is a valid
state and is never replaced by a guess. A function's `requirement` names where it comes from,
and its id stays stable once confirmed.

**Proposed until confirmed.** An SLO or alert is `status: proposed` (the default) until the
client has agreed its target, owner and threshold; then `confirmed`. A drafted spec is all
proposed. Paging needs confirmed on both the alert and its SLO.

Classes are the six of the error taxonomy: `expected`, `failure`, `caller_defect`, `ambiguous`,
`unknown`, and `none` for a condition that looked like an error but the operation took effect
(the worked example's slot read-back).

## Rules

| ID | Check | Kit rule it enforces | Severity |
|---|---|---|---|
| SL000 | Sections are lists of mappings; journeys and functions have ids | — | error |
| SL001 | Every function has at least one signal | Diagnosis per function, not outcome counting (playbook, principle 1) | error |
| SL002 | A `live` signal names its evidence | "Present" requires evidence (playbook, principle 3) | error |
| SL003 | Every taxonomy row has a code and exactly one valid class | Classify every code (playbook, principle 2) | error |
| SL004 | A code is not classified twice in the same context | One class per code; overloaded codes are split by context (error taxonomy) | error |
| SL005 | Every ambiguous outcome has a reconciliation path: an attempt model with reconciliation, or `reconciliation` on the row | Ambiguous is about the outcome (error taxonomy; runbook "unknown state") | error |
| SL006 | An SLO has subject, good, valid, bad, target (a percentage), window and owner | Good and valid decided per SLI; a target is signed (slo-alerts, rules) | error |
| SL007 | Expected refusals are `excluded` or `good`, with a reason | Choose one per SLI and say why (slo-alerts, rules) | error |
| SL008 | The bad predicate includes ambiguous and unknown (or unclassified), unless `bad_reason` says why not | One bad predicate; ambiguous and unknown stay bad (slo-alerts, rules) | warning |
| SL009 | A P1 has owner, runbook, delivery test, minimum volume and grouping | No playbook, no alert (lessons 4) | error |
| SL010 | No alert grouped by host, or pooled across functions | Never alert on a pooled rate or a host (lessons 2) | error |
| SL011 | An alert in `paging` rests only on `live` signals | No threshold on a gap (playbook, principle 4) | error |
| SL012 | The runbook file exists (with `--check-files`) | Every P1 has a runbook (slo-alerts, rules) | error |
| SL013 | Every reference (function, attempt, journey, SLO) resolves | — | error |
| SL014 | Ids are unique across the file | — | error |
| SL015 | Signal state, alert state, severity and status take their allowed values | — | error |
| SL016 | No `[placeholder]` left from the skeleton | — | warning |
| SL017 | Every function names the source of its requirement | A function traces to the journey agreed with the client (playbook, step 6) | warning |
| SL018 | An alert in `paging` and its SLO are `confirmed` | Owner, target and threshold are decided with the client (slo-alerts, rules) | error |
| SL019 | No unknown key; an engagement's own field is prefixed `x_` | A misspelt field must not pass silently | warning |
| SL020 | No key repeated in one mapping | A YAML reader keeps the last value and drops the others silently; a second `good:` or `id:` would pass | error |

## What it does not check

A clean run means the spec is structurally complete. It is not acceptance: whether the spec is
right is a separate check by a person, and the summary line says so.

Whether a class is right, whether a target is sensible, whether the query behind an SLI counts
what it says. Those are the reviewer's and the acceptance harness's job: the linter makes the
chain complete, the review makes it correct, the harness on stage proves it.
