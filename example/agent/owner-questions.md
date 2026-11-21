# Owner questions — stage 3 batch

Larkfield Grocer, fictional. Format: [owner-questions.md](../../templates/owner-questions.md).
The agent drafted the questions and candidates at hand-over; the lead sent them and recorded
each answer in the [decision register](../worked-example.md#decision-register-extract) before
writing its id here and in [`engagement-state.yml`](engagement-state.yml). The stage 2 batch
(Q-01, Q-02) is answered by D-03 and D-04.

Batch: stage 3 hand-over · sent 2027-04-20 to the payments technical owner and the sponsor ·
answers by 2027-04-22

| Q | Question | Blocks | Candidates (none chosen) | Rests on | Answer | Decided by, date | Decision |
|---|---|---|---|---|---|---|---|
| Q-03 | Does the payment provider answer a status call for an authorisation that timed out, in production as in its sandbox? | Stage 4; F-003's closing criterion | (a) yes, the same call · (b) sandbox only · (c) another answer | Provider's sandbox documentation; not checked in production | "Yes, the same call; limited to 10 a second." | Payments technical owner, 2027-04-22 | D-07 |
| Q-04 | Until a fix, who owns the risk that an order paid for but not placed is seen only at the weekly export? | Stage 4; R-02 | (a) head of e-commerce · (b) finance operations · (c) another answer | G-04, E-304 | "Head of e-commerce; accepted until the reconciliation job runs." | Sponsor, 2027-04-22 | D-08 |
