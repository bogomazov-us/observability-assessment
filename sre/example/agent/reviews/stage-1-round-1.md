# Review — SRE stage 1 inventory, round 1

Larkfield Grocer, fictional. Format: [review.md](../../../../templates/review.md). The lead's
check before confirming, recorded as a round so that the
[harness measures](../../../../method/agent-harness.md#measuring-the-harness) count what changed.

| Deliverable | Version or commit | Round | Reviewer | Author | Date |
|---|---|---|---|---|---|
| `sre/inventory.md`, `sre/service-catalogue.md`, `sre/baseline.md` | `4b8d2f6` | 1 of 2 | Engagement lead | Agent | 2027-06-10 |

| # | Where | Check failed or remark | Severity | Verdict on the item | Answer (author) |
|---|---|---|---|---|---|
| R1 | `baseline.md`, B-32; L-09 | Drafted 50% (1 of 2): the orders database's restore of 2026-10-14 was counted, but the window starts 2026-12-05 (E-105). A restore outside the window is not on record for it ([stage 1 reference](../../../agent/reference/stage-1-reference.md#6-baseline)) | blocking | closed | Changed to 0% (0 of 2), and L-09 extended to the orders database, in `c71e0a4` |

**Round verdict:** rework. Round 2, the same day at `c71e0a4`: R1 closed by the change;
approved. Blind spots L-09 and L-14 registered as R-03 and R-04. Stage 1 confirmed by D-11.

**For the harness measures:** 18 `L-`, 7 `S-` and 36 `B-` rows handed over; B-01 to B-31
reproduced by re-running `tools/baseline.py` on the same exports; 1 row changed in substance
(B-32, a wrong count, carried into L-09); 2 of 2 selected checks reproduced through the tools'
own interfaces (E-101, E-104). Agent elapsed time 2027-06-08 09:12 to 2027-06-09 14:25
([progress log](../progress/stage-1.md)); the lead's hours confirming, 3.
