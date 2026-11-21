# Agent harness

How AI agents take part in an assessment and in a release check without weakening the evidence
rule. The agent drafts; a person confirms in the tool. Nothing an agent produces is a fact until
someone has looked at the evidence it cites.

## Boundaries

| Rule | Why |
|---|---|
| Read-only access only: code checkout, monitoring tool through a read-only token or a read-only MCP server, exports already in the engagement repository; no writes to the client's monitoring configuration, code or tickets | An assessment never changes the client's estate; write access is a separate, client-owned decision |
| Everything the agent reads and writes stays in the engagement repository and the client's tool | Client confidentiality (playbook, working rules) |
| Agent output enters the facts ledger as an assumption, never as confirmed | "Confirmed means there is an artefact" — the agent's summary is not one |
| Every drafted claim cites its evidence: the query text and its time range, file:line, or the export file | A reviewer can re-run it without asking the agent |
| The client's own AI-ops tools are inputs, not competitors | Build on the client's work (playbook, principle 6) |
| The agent reads only the paths and systems its prompt lists and makes no network call it does not list; its permissions enforce both | Scope is a boundary, not a suggestion; a prompt alone was ignored once |
| Owner questions stay open and answers count once in the decision register, recorded by the session the owner spoke to; a reviewer's recommendation decides nothing ([rule](../tools/agent/rules/owner-questions.md), [records.md](records.md)) | A plausible guess is read as an answer; a decision nobody can find is read as a proposal; a relayed approval cannot be checked; the owner decides |
| Assessment work runs on its own branch or worktree from the first stage | Drafts and other work must not sweep each other up |
| Each stage keeps a [progress log](../tools/agent/rules/progress-log.md), times read from the clock | The log is the pilot's time record; an estimated time spoils it without showing it |
| Agents working in parallel commit only their own files, named by path, and pull before they push | A broad commit sweeps up another agent's half-written work |

## Pipeline: inputs → model → gap → recommendations

Each stage's prompt, tool, gate and what the person confirms are in
[tools/agent/](../tools/agent/README.md); its weeks are in the
[calendar](getting-started.md#3-calendar).

| # | Stage | Agent does | Playbook step |
|---|---|---|---|
| 1 | Inventory | Runs the code scan; exports the estate by object class through the tool's read-only API or MCP server; gives each object one status | 3, 4 |
| 2 | Target model | Drafts journeys → functions from HAR captures, routes and code; drafts the error taxonomy from error handlers; links each function to its requirement and to its current state in the inventory | 6, 7 |
| 3 | Gap | Checks the drafted model against the estate: which signals are live, which SLIs could be computed today, which alerts sit on pooled rates or hosts; for each P1 alert, how its detection is shown | 7, 8 |
| 4 | Findings | Drafts findings in the `finding.md` format, status *assumption*, with the cited evidence | 8 |
| 5 | Maturity | Drafts `maturity.yml` from confirmed findings; a level that waits on a verdict is provisional | 5 |
| 6 | Recommendations | Proposes a confirmation batch, then `REC-` cards on confirmed findings, `V-` verification tasks and `W-` work items, ordered by impact over effort | 11 |

## Claims stay within what was checked

An agent generalises easily and a reviewer reads the generalisation as a finding, so every stage
prompt names one checklist of wording rules that keeps each claim within its check:
[`rules/claims.md`](../tools/agent/rules/claims.md).

## Two levels of reading, from one set of sources

Each stage's notes file has a main part that supports a decision and an evidence part that lets
a reviewer check each claim by a stable id; the current state comes first, and the rounds that
produced it are history, never needed to read the result
([`stage-report.md`](../templates/stage-report.md)). The client receives two documents for the
whole assessment, built by `tools/assessment-pdf.sh` from the per-stage sources: a report — the
lead's summary (`summary.md`, from [`report.md`](../templates/report.md)), then a chapter per
stage, drafted by the agent and accepted when the lead confirms the stage — and an evidence
bundle of their records and catalogs. Working files stay in the repository as history. This came from the review of the first
engagement's stages 1–3, whose content was ahead of their form: the client had to rebuild the
current state from the edit history, wide tables and appendices.

## The review bundle is built from what is cited

A reviewer checks a chain: the target cites an inventory row, the row cites its evidence. The
documents handed for review are generated from the committed versions they cite, each states
its commit, and the bundle includes the confirmed baseline the document relies on. A bundle
with an older baseline cannot be checked and is returned.

## Detection is shown, or its absence is a risk

An alert that evaluates is not an alert that detects. For each P1 alert the gap stage records
how the chain fault → signal → evaluation → firing → notification → acknowledgement is shown:
**proven** (a recorded reproduction, with date), **scenario written** (steps, expected firing,
who runs it), or **residual risk** with an owner. The assessment is read-only, so faults are
reproduced on a stage with the client's developer or during implementation, never injected in
production by the assessment. Recovery and no-data are part of the scenario. Paging needs the
per-alert gate in [slo-alerts](../templates/spec-set/slo-alerts.md): shown, not stated, and
passed by each alert on its own.

## Blind spots are registered when they are confirmed

A confirmed blind spot — a check that cannot fire, a notification that reaches nobody — goes
into the client's risk register with an owner as soon as a person confirms it, in whatever
stage. The finding that explains it is still written in stage 4 and links the risk.

## Target and current state in the spec

The drafted spec describes the target. Each function keeps a stable id, the source of its
requirement and, apart from the target, its current state with links to the inventory; unknown
stays unknown. Targets, owners and thresholds nobody has agreed are `proposed`. A clean linter
run means the spec is structurally complete; acceptance of its content is a separate check
([speclint.md](../tools/speclint.md)).

## Release check (Implementation and after)

The same harness runs on every release, against stage:

1. Replay the acceptance scenarios of the spec set as test traffic (the test traffic flag set).
2. Query each SLI and compare with the expected counts in the acceptance table.
3. Check each detector saw the volume it needs; check a test notification reached the rota.
4. Lint the spec (`speclint`) so the release does not ship an alert on a signal that is not
   live.
5. Report pass or fail per claim, with the query output, into the release record.

A failed claim blocks the release only where the client has made the release check a gate
(maturity dimension 10, level 5); otherwise it is a finding for the firing review.

## Measuring the harness

| Measure | Target before relying on it | How |
|---|---|---|
| Drafted findings accepted without change of substance | at least 70 % | Review rounds (`templates/review.md`) |
| Drafted claims whose cited evidence did not reproduce | 0 | Reviewer re-runs every cited query in the first two engagements |
| Days from access to reconciled inventory | lower than the estimate's inventory phase | Actuals log (`practice/pilot.md`) |

**Until both quality targets hold on two engagements, every stage runs as a draft to compare
against, and people write the findings.** Stage 4 reconciles its drafts with the findings people
wrote, never redrafting one.

**First engagements are pilot measurements.** Record agent elapsed time and person hours
separately, per stage. Agent elapsed time is not compared with the person-days of the
estimation model: those include preparation, human review and acceptance, and the scope
differs. The comparison is made on time recorded for the same work. A reviewer's re-run of a
sample of checks says that those claims hold; it is not an estimate of the accuracy of the
whole output — report it as "n of n selected checks reproduced". When a row is split or merged during review (the inventory
changes granularity), count it apart from drafts corrected in substance: it is a change of
granularity, not an error of the draft.

## Status

Specification. All six stages have been run once on a real engagement and reviewed; the rules
above came from those reviews, each named in the changelog.

**First pilot measurement.** On findings with a verdict, the share accepted without change of
substance was far below the 70 % target: nearly every one was bounded (a window or a scope
added) or corrected, and the review reset several severities; over all drafts it looked close,
because most had no verdict yet. Count the measure on findings with a verdict, and report a
strict reading (bounds and changes from new input count) beside a lenient one (corrections and
severities only). The selected evidence checks all reproduced. Person hours, rebuilt afterwards
from message timestamps, spanned a factor of two, with reading and outside review rounds
invisible: record them as the stage runs. Not yet measured on a second engagement.
