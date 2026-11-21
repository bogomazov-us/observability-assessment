# Getting started

The shortest route from "we have a request" to a finished assessment, for a lead who has not run
one with this kit before. Read [the worked example](../example/worked-example.md) first: it shows
what every step below produces, on a fictional client.

## 1. Before the first meeting (day 0)

1. Pick the format with the buyer: focused (2–3 weeks) or full (6 weeks) — see
   [offerings.md](../offerings.md). Deliver the format they asked for, not the one you prefer.
2. Copy into a new, private engagement repository:
   - `templates/intake-questionnaire.md` and `templates/data-request.md` — send both on day one;
   - `templates/kickoff-note.md` and `templates/interview-guide.md` — for the kick-off and the
     interviews;
   - `templates/finding.md` — one file per finding, in `findings/`;
   - `templates/report.md` — the summary chapter, rewritten at each accepted stage; and
     `templates/roadmap.md`;
   - [`templates/adr.md`](../templates/adr.md) — for an architecture decision only;
   - `templates/spec-set/observability-spec.yml` — journeys, functions, error taxonomy and
     signal states; the rest of `templates/spec-set/` is the Blueprint's;
   - `templates/review.md` — one copy per deliverable and review round.
3. Create a facts ledger: a table with ID, fact, status, source, date. Any tool works — a
   Markdown file in the repository is enough (a full knowledge base: playbook, working rules).
   Running the agent stages? Section 6 sets up the ledger,
   the register and the agent's files in one command. Ids, statuses and where a decision is
   written: [records.md](records.md).
4. Read [lessons.md](lessons.md). Most of them are about the first two weeks.

## 2. What to fill first

| Order | File | Why first |
|---|---|---|
| 1 | Data request | Access and exports take the longest; ask on day one |
| 2 | Facts ledger | Everything the client says goes in as an assumption until shown |
| 3 | Journey list (top 3–5 journeys, decomposed into functions) | Every later artefact is keyed by function |
| 4 | Findings | Written by people as they appear (`findings/`, status assumption), not in the last week; stage 4 reconciles them, never redrafts |
| 5 | Maturity table | A provisional baseline first; final once the findings have their verdicts (stage 5) |
| 6 | Summary and roadmap | Last; the decision request is the last page |

## 3. Calendar

Other files link here for a week. "Stage": the [agent stage](../tools/agent/README.md)'s
state by the end of the week; without the agent, the steps keep their weeks. "Client
delivers": the [data request](../templates/data-request.md)'s "Needed by".

**Full format, six weeks**

| Week | Offering phase | Playbook steps | Stage | Meetings | Client delivers |
|---|---|---|---|---|---|
| 1 | 1 Align & baseline | 1 client documents, 2 intake, 3 code, 4 inventory, 5 provisional maturity baseline | 1 handed over | Kick-off; interviews begin | Tool and code access, alert export, architecture, earlier investigations |
| 2 | 2 Observe & trace | 4 reconciled, 6 journeys | 1 confirmed; 2 handed over and confirmed | Interviews end (5–8 in all); journey walk-through | Journey captures, tickets, incident timelines, error codes, dashboards, billing |
| 3 | 3 Diagnose | 7 signals, 8 diagnose | 3 handed over and confirmed | — | Owner answers that block stages 3–4 |
| 4 | 3 Diagnose; 4 Golden journey proof | 8 diagnose, 9 golden journey | 4 handed over before the preview; confirmed after it | Findings preview, which sends the verdict batch | Stage access and the developer, if the proof is in scope |
| 5 | 4 Golden journey proof; 5 Executive roadmap | 9 demonstrated, 5 final maturity | 5 confirmed; 6 handed over with its confirmation batch | Proof demonstration; review round 1 | Verdicts on the batch |
| 6 | 5 Executive roadmap | 11 report and roadmap, 12 baseline if continuing | 6 confirmed | Review round 2; read-out | The next-step decision |

**Focused format, two to three weeks.** Every data-request item is needed in week 1. Skipped: the
golden journey proof and its demonstration, the journey walk-through (journeys come from the
interviews), review round 2. In two weeks, weeks 2 and 3 run as one.

| Week | Playbook steps | Stage | Meetings |
|---|---|---|---|
| 1 | 1–4, 5 provisional | 1 confirmed; 2 handed over | Kick-off; 3–4 interviews |
| 2 | 6–8 | 2 and 3 confirmed; 4 handed over | Findings preview |
| 3 | 5 final, 11 | 4, 5 and 6 confirmed | Review round; read-out |

| Meeting | With | Output |
|---|---|---|
| Kick-off | Sponsor, product, platform, monitoring-tool owner | Goals, journeys in scope, access dates ([kick-off note](../templates/kickoff-note.md)) |
| Interviews | Owners of monitoring tool, platform, on-call, product, a developer per tier-1 service ([interview guide](../templates/interview-guide.md)) | Answers, exports, first findings |
| Journey walk-through | Product and a developer | Functions and their failures |
| Findings preview | Sponsor and technical owners | No surprises in the report; disputes recorded; the verdict batch |
| Read-out | Sponsor and decision makers | Next-step decision |

Review rounds and stage reviews: [playbook](playbook.md), working rules. The Operationalize
option ([offerings](../offerings.md)), when taken, runs in weeks 5–6 beside the roadmap.

## 4. Who does what

The lead is full time, accountable and writes the report; the observability engineer (tool and
code evidence) and the architect join by scope, through the capacity check in
[estimation.md](estimation.md) — in the full format the engineer usually from week 1, the
architect part time when the lead does not read the code. Who sets what:
[records.md](records.md). Effort by role and phase is a starting calibration: record your
actual days and feed them back. A first assessment led by someone new runs as a
[pilot](../practice/pilot.md), in whichever format was sold.

## 5. What "finished" looks like

- Every finding has a status, a source and a "what follows".
- The maturity table has a level, the evidence and a confidence for each scored dimension.
- The report answers the buyer's question on its first page, and its last page asks for a
  decision.
- The roadmap has milestones closed by demonstration, each with one accountable owner.
- The facts ledger shows what was confirmed, what is still an assumption, and what was refuted.

The report is assembled from chapters per accepted stage; see
[stage-report.md](../templates/stage-report.md). The worked example ends in exactly this state.

## 6. With the agent stages

A person starts each [agent stage](../tools/agent/README.md) and confirms its result. What the drafts
count for until the harness targets hold: [agent-harness.md](agent-harness.md), "Measuring the
harness".

The person, per stage (the agent's side is in its [rules](../tools/agent/rules/)):

1. **Once:** runs `tools/agent/init-engagement.sh` and finishes what it leaves
   ([README](../tools/agent/README.md), "Setting up"); records the scope in the decision
   register and in `engagement-state.yml`; commits on the assessment branch.
2. **Start:** by name (`prompt.sh N`, or the skill `oa-stage-N-…`), with the inputs the prompt
   lists. The agent checks the gate first and names a missing input instead of substituting it.
3. **While it runs:** reads `progress/stage-N.md`, not the transcript.
4. **Hand-over:** receives the draft, what could not be cited and the open owner questions as
   one batch; sends the questions in the format of `templates/owner-questions.md` and records
   each answer in the decision register with date and who decided.
5. **Confirm:** checks what the prompt's last section names, in the tool and by another path
   than the agent's query; records the result in the ledger and the register; sets the stage
   `confirmed` with who, when and the decision id; runs
   `tools/stagegate.py lint engagement-state.yml --since REV` against the last confirmation's
   commit — on the first, the commit that added the file
   (`git log --diff-filter=A --format=%h -- engagement-state.yml`). Only then starts the next.

At each accepted stage the person rewrites `summary.md` (from `templates/report.md`), adds the
stage's lines to `manifest.txt` and builds with `tools/assessment-pdf.sh`; after stage 6 they
finish the summary and the roadmap from the confirmed results (section 5), and record the
agent's time and the person's hours per stage, as [the harness](agent-harness.md) asks.
