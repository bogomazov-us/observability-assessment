# Getting started

The shortest route from "we have a request" to a finished assessment, for a lead who has not run
one with this kit before. Read [the worked example](../example/worked-example.md) first: it shows
what every step below produces, on a fictional client.

## 1. Before the first meeting (day 0)

1. Pick the format with the buyer: focused (2–3 weeks) or full (6 weeks) — see
   [offerings.md](../offerings.md). Deliver the format they asked for, not the one you prefer.
2. Copy into a new, private engagement repository:
   - `templates/intake-questionnaire.md` and `templates/data-request.md` — send both in week one;
   - `templates/finding.md` — one file or one section per finding;
   - `templates/report.md` and `templates/roadmap.md` — fill in during the last week;
   - `templates/spec-set/` — only if a Blueprint follows.
3. Create a facts ledger: a table with ID, fact, status, source, date. Any tool works — a
   Markdown file in the repository is enough. A full 00–09 knowledge-base structure helps on
   long engagements but is optional.
4. Read [lessons.md](lessons.md). Most of them are about the first two weeks.

## 2. What to fill first

| Order | File | Why first |
|---|---|---|
| 1 | Data request | Access and exports take the longest; ask on day one |
| 2 | Facts ledger | Everything the client says goes in as an assumption until shown |
| 3 | Journey list (top 3–5 journeys, decomposed into functions) | Every later artefact is keyed by function |
| 4 | Findings | Written as they appear, not in the last week |
| 5 | Maturity table | Scored once the evidence is in, week 3 of 6 at the earliest |
| 6 | Report and roadmap | Last; the decision request is the last page |

## 3. Meetings

| Week (of 6) | Meeting | With | Output |
|---|---|---|---|
| 1 | Kick-off | Sponsor, product, platform, monitoring-tool owner | Goals, journeys in scope, access dates |
| 1–2 | Interviews, 5–8 | Owners of monitoring tool, platform, on-call, product, a developer per tier-1 service | Answers, exports, first findings |
| 2–3 | Journey walk-through | Product and a developer | Functions and their failures |
| 4 | Findings preview | Sponsor and technical owners | No surprises in the report; disputes recorded |
| 6 | Read-out | Sponsor and decision makers | Next-step decision |

For the focused format: kick-off, three or four interviews, read-out.

## 4. Who does what

| Role | Focused | Full |
|---|---|---|
| Lead (accountable, writes the report) | full time | full time |
| Observability engineer (tool and code evidence) | full time | full time |
| Architect | review of findings | part time, from week 2 |

Calibrate the effort on your own engagements: the kit does not yet carry an estimation model
(backlog).

## 5. What "finished" looks like

- Every finding has a status, a source and a "what follows".
- The maturity table has a level, the evidence and a confidence for each scored dimension.
- The report answers the buyer's question on its first page, and its last page asks for a
  decision.
- The roadmap has milestones closed by demonstration, each with one accountable owner.
- The facts ledger shows what was confirmed, what is still an assumption, and what was refuted.

The worked example ends in exactly this state.
