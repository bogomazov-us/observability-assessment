# Owner questions — SRE stage 1 batch

Larkfield Grocer, fictional. Format: [owner-questions.md](../../../templates/owner-questions.md).
The agent drafted the questions and candidates at hand-over; the lead sent them and recorded
each answer in the [decision register](../worked-example.md#decision-register-extract) before
writing its id here. The ids continue the observability sequence (to Q-04). The questions
block stage 3, not stage 2: stage 2 drafts the targets around them, and the owners answered at
its targets review. [`engagement-state.yml`](engagement-state.yml) shows them open, on the day
stage 1 was confirmed.

Batch: SRE stage 1 hand-over · sent 2027-06-09 to the head of engineering and the platform,
payments and release technical owners · answers by 2027-06-14

| Q | Question | Blocks | Candidates (none chosen) | Rests on | Answer | Decided by, date | Decision |
|---|---|---|---|---|---|---|---|
| Q-05 | Can checkout go on without promotions when `promo-rules` fails? If so, `promo-rules` can be tier 2. | Stage 3; S-06's tier | (a) yes, tier 2 on that condition · (b) no, tier 1 · (c) another answer | L-14; incident 114 in the export | "Yes; tier 2 on that condition." | Head of engineering, with the service owners, 2027-06-14 | D-12 |
| Q-06 | How long may the orders database and the payments ledger take to restore, and how much data may be lost? | Stage 3; the RTO and RPO targets | (a) 1 hour and 5 minutes · (b) 4 hours and 1 hour · (c) another answer | Backup policy, E-102; incident 107, 3 h 40 min | "1 hour and 5 minutes, for both." | Platform and payments technical owners, 2027-06-14 | D-13 |
| Q-07 | How far may a bad tier-1 deploy spread, and how fast must it be rolled back? | Stage 3; the rollout target | (a) canary to 10% with an automatic halt; rollback within 15 minutes · (b) all at once; rollback within 1 hour · (c) another answer | B-24 to B-26; pipeline configuration, E-108 | "(a), as written." | Release technical owner, 2027-06-15 | D-14 |
