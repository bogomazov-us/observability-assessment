# Assessment report — skeleton

Combines a performance-assessment skeleton with per-dimension maturity reporting. Keep the
executive part to five pages; everything else is appendix.

1. **Executive summary** — three findings that matter, maturity at a glance ("you are here"),
   the decision we ask for.
2. **Context and objectives** — what the client asked, in their words.
3. **Approach** — scope, interviews (by stream, count), tools and queries used, limitations and
   dependencies, what this data cannot tell us.
4. **Answers to the client's key questions** — one slide or section per question.
5. **Maturity by dimension** — table from `method/maturity-model.md`; per dimension: Highlights /
   Keep an eye on / Lowlights.
6. **Findings by layer** — user experience, application and integration, code, data, runtime,
   cross-cutting. Each finding in the `finding.md` format.
7. **Recommendations** — cards (below), ordered by impact over effort.
8. **Golden journey proof** (full format) — what was instrumented, what it showed.
9. **Target model** — journey → function → signal → SLI → threshold → owner for tier-1.
10. **Roadmap** — quick-fix hardening → adoption → evolution; 30/60/90; milestones per
    `roadmap.md`.
11. **Business impact** — what becomes detectable, how fast, and what it is worth where data allows.
12. **Appendix** — inputs received, inventory exports, question log.

## Recommendation card

| REC-NNN | Linked findings | Effort S/M/L | Impact H/M/L |
|---|---|---|---|

- **Description.** What and why.
- **Implementation steps.** 3–6 steps with owners.
- **Metric.**

| Metric | Current | Target |
|---|---|---|
| e.g. share of tier-1 calls linked end to end in a controlled run | none | 95 % |
