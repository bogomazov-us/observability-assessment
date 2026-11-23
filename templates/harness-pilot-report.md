# Harness pilot report — [engagement], [observability / SRE / combined]

The measured result of one engagement run on the [agent route](../tools/agent/README.md), and
the owner's decision on what to rely on next. Kept in the engagement repository: client names,
systems and figures stay there. What generalises goes to the kit's backlog, rewritten without
them ([practice/pilot.md](../practice/pilot.md)).

| Engagement | Assessment type | Stages run | Dates | Lead | Reviewer | Report version |
|---|---|---|---|---|---|---|
| [code name] | [observability / sre / both] | [1–6] | [YYYY-MM-DD to YYYY-MM-DD] | [role] | [role; the same person as the lead? yes / no] | [commit] |

## 1. What was run

| Item | Value |
|---|---|
| Kit version | [vX.Y.Z, from the README of the checkout the prompts were assembled from] |
| Agent tool and model, as run | [name and version per stage; a change mid-engagement is a row of its own] |
| Second reading | [not run / run at stage 4 with (tool and model)] |
| Inputs of the measures | `tools/harness-metrics.py … --json` at commit [hash]; the output file beside this report |
| Hours recorded as the work happened | [yes, from stage N / partly: which / no] |

## 2. Measures

Copied from the tool's output, never retyped by hand. Every share with its numerator, its
denominator and its interval; every value not recorded as "not measured".

| Stage | Review hours (person) | Rework hours (person) | Agent span | Re-checks |
|---|---|---|---|---|
| 1 Inventory | | | | [n of n selected reproduced] |
| 2 Target model | | | | |
| 3 Gap | | | | |
| 4 Findings | | | | |
| 5 Maturity | | | | |
| 6 Recommendations | | | | |

| Stage 4 findings | Value |
|---|---|
| Strict unchanged | [k/n (p %; 95 % interval a–b %)] |
| Lenient unchanged | [k/n (p %; 95 % interval a–b %)] |
| With a verdict / pending / verdict without an outcome | [n / n / n] |
| Split or merged; severity changed; changed on new input | [n; n; n] |
| Cited evidence that did not reproduce | [n of n selected; how they were selected] |
| Second reading: flags, acted on, not acted on | [n, n, n; or not run] |

## 3. How to read them

- **Sample.** [n] findings with a verdict on one engagement. State the interval and say what
  it allows: a share of 70 % on a dozen findings is consistent with much lower and much higher
  rates.
- **Selection.** How the re-checks were chosen (by the reviewer, at random, the riskiest), and
  what that does to "n of n reproduced".
- **Reviewer.** Whether the reviewer knew the drafts before reviewing them; a reviewer who
  reviews the same drafts twice remembers them. A comparison on the same inputs needs another
  reviewer, or a blind one, and the client's written leave to keep the data for it.
- **Comparison with earlier engagements.** Descriptive only, and only on measures recorded the
  same way. Hours rebuilt afterwards are not compared with hours recorded as the work happened:
  no time saved is claimed from them.

## 4. Where the drafts went wrong

One row per class of change, from the outcome rows and the review items, with the rule it
falls under. This is what decides whether a check or a second reading would have helped.

| Class | Findings | Rule | Would a check have caught it? |
|---|---|---|---|
| [a window or scope added] | [n: F-…] | [claims 1, 2] | [recordcheck RC04 / second reading / neither: a reviewer's judgement] |

## 5. Decision

The targets in [agent-harness.md](../method/agent-harness.md#measuring-the-harness): at least
70 % of drafted findings accepted without change of substance, and no cited evidence that did
not reproduce, on two engagements. A target missed, or one engagement only, keeps the agent's
stages as drafts and people writing the findings.

| Question | Answer | Decided by, date | Decision |
|---|---|---|---|
| Do the targets hold on this engagement? | [yes / no, which] | [owner] | [D- id] |
| Do they hold on two engagements, recorded the same way? | [yes / no / first engagement measured this way] | | |
| What runs differently next time? | [e.g. the finding check before hand-over; the second reading kept or dropped, with its acted share] | | |
| What goes to the kit's backlog? | [items, rewritten without client details] | | |

No tool sets these answers; the owner does, with the measures above in front of them.
