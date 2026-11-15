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
   - `templates/spec-set/` — only if a Blueprint follows;
   - `templates/review.md` — one copy per deliverable and review round.
3. Create a facts ledger: a table with ID, fact, status, source, date. Any tool works — a
   Markdown file in the repository is enough. A full 00–09 knowledge-base structure helps on
   long engagements but is optional. Running the agent stages? Section 6 sets up the ledger,
   the register and the agent's files in one command.
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
| Lead (accountable, writes the report; does the work of any role not staffed) | full time | full time |
| Observability engineer (tool and code evidence) | when the scope needs one | from week 1 |
| Architect | rarely | part time, at the limit or when the lead does not read the code |

Which roles a scope needs is decided by the capacity check in the estimation model.

Effort by role and phase, and how it grows with journeys, services and tools, is in
[estimation.md](estimation.md). Its values are a starting calibration: record your actual days
and feed them back. A first assessment led by someone new runs as a [pilot](../practice/pilot.md).

## 5. What "finished" looks like

- Every finding has a status, a source and a "what follows".
- The maturity table has a level, the evidence and a confidence for each scored dimension.
- The report answers the buyer's question on its first page, and its last page asks for a
  decision.
- The roadmap has milestones closed by demonstration, each with one accountable owner.
- The facts ledger shows what was confirmed, what is still an assumption, and what was refuted.

The worked example ends in exactly this state.

## 6. With the agent stages

The six [agent stages](../tools/agent/README.md) draft inventory, target model, gap, findings,
maturity and recommendations; a person starts each one and confirms its result. Until the
quality targets in [agent-harness.md](agent-harness.md) hold on two engagements, the agent
speeds up the inventory only, and people write the findings: run the later stages as drafts
to compare against, not as the deliverable.

| Step | The person | The agent |
|---|---|---|
| Set up, once | Runs `tools/agent/init-engagement.sh --repo … --code …` (add `--skills DIR` if the agent tool loads skills); fills in the client and the monitoring tool in the instructions file; grants read-only access to the code and the tool in the agent tool's own permissions; records the scope in the decision register and in `engagement-state.yml`; commits on the assessment branch | — |
| Start a stage | Starts it by name (`prompt.sh N`, or the skill `oa-stage-N-…`) and gives the inputs the prompt lists | Runs the gate check first and stops if the stage before is not confirmed; names any missing input instead of substituting it |
| While it runs | Reads `progress/stage-N.md`, not the transcript | Drafts, keeps the progress log, cites every claim, sets its stage `draft`, then `handed_over` |
| Hand-over | Receives the draft, the list of what could not be cited, and the open owner questions as one batch | Stops; decides no owner question |
| Owner questions | Sends the batch in the format of `templates/owner-questions.md`; records each answer in the decision register with date and who decided | Cites the register id, never "the owner said" |
| Confirm | Checks what the prompt's last section names, in the tool and by another path than the agent's query; records the result in the ledger and the register; sets the stage `confirmed` with who, when and the decision id; runs `tools/stagegate.py lint … --since REV` | — |
| Next stage | Starts it only now | — |

After stage 6 the person writes the report and the roadmap from the confirmed results
(section 5), and records the agent's time and the person's hours per stage, as
[the harness](agent-harness.md) asks.
