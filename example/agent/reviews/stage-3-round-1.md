# Observability example: review — stage 3 gap, round 1

Larkfield Grocer, fictional. Format: [review.md](../../../templates/review.md). The lead's
check before confirming, recorded as a round so that the
[harness measures](../../../method/agent-harness.md#measuring-the-harness) count what changed.

| Deliverable | Version or commit | Round | Reviewer | Author | Date |
|---|---|---|---|---|---|
| `stage-3-gap.md`, signal states in the spec | `1d9b0f4` | 1 of 2 | Engagement lead | Agent | 2027-04-22 |

| # | Where | Check failed or remark | Severity | Verdict on the item | Answer (author) |
|---|---|---|---|---|---|
| R1 | G-02; spec, signal of C2 | Drafted `live` because the spans exist; read in the trace view (E-306) they lack `attempt_id` and `error_class`. Live needs the attributes the spec names ([stage 3](../../../tools/agent/stage-3-gap.md), method step 1) | blocking | closed | Changed to `differs` with E-306 in `5e8a2d7` |

**Round verdict:** rework. Round 2, the same day at `5e8a2d7`: R1 closed by the change;
approved. Stage 3 confirmed by D-06.

**For the harness measures:** 5 `G-` records handed over, 4 accepted without change of substance,
1 changed in substance (G-02, a wrong state, not a change of granularity); 2 of 2 selected
checks reproduced (E-301, E-302): the query repeated, its reading was wrong. Agent elapsed
time 09:04–15:01 ([progress log](../progress/stage-3.md)); the lead's hours confirming, 3.5.
