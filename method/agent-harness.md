# Agent harness

How AI agents take part in an assessment and in a release check without weakening the evidence
rule. The agent drafts; a person confirms in the tool. Nothing an agent produces is a fact until
someone has looked at the evidence it cites.

## Boundaries

| Rule | Why |
|---|---|
| Read-only access only: code checkout, monitoring tool through a read-only token or a read-only MCP server, exports already in the engagement repository | An assessment never changes the client's estate (offerings, not included) |
| Everything the agent reads and writes stays in the engagement repository and the client's tool | Client confidentiality (playbook, working rules) |
| Agent output enters the facts ledger as an assumption, never as confirmed | "Confirmed means there is an artefact" — the agent's summary is not one |
| Every drafted claim cites its evidence: the query text and its time range, file:line, or the export file | A reviewer can re-run it without asking the agent |
| No agent writes to the client's monitoring configuration, code or tickets | Write access is a separate, client-owned decision, outside the assessment |
| The client's own AI-ops tools are inputs, not competitors | Build on the client's work (playbook, principle 6) |
| The agent reads only the paths and systems its prompt lists, and its permissions enforce it | Scope is a boundary, not a suggestion |
| A question addressed to the owner or the client is never decided by an agent; candidate answers are marked as candidates | A plausible guess is read as an answer |
| Assessment work runs on its own branch or worktree from the first stage | Drafts and other work must not sweep each other up |

## Pipeline: inputs → model → gap → recommendations

| # | Stage | Agent does | Tool | Person confirms | Playbook step |
|---|---|---|---|---|---|
| 1 | Inventory | Runs the code scan; exports the estate by object class through the tool's read-only API or MCP server; gives each object one status | [collect.md](../tools/collect.md), [stage 1 prompt](../tools/agent/stage-1-inventory.md) | Exports reconcile with each other (counts, names); statuses sum to the rows; a sample of checks re-run | 3, 4 |
| 2 | Target model | Drafts journeys → functions from HAR captures, routes and code; drafts the error taxonomy from error handlers; links each function to its requirement and to its current state in the inventory | `observability-spec.yml` skeleton | Each function and class against code and a captured request; which proposals become confirmed | 6, 7 |
| 3 | Gap | Checks the drafted model against the estate: which signals are live, which SLIs could be computed today, which alerts sit on pooled rates or hosts | [speclint.md](../tools/speclint.md) | Each "live" by browser, agent or tenant evidence | 7, 8 |
| 4 | Findings | Drafts findings in the `finding.md` format, status *assumption*, with the cited evidence | `templates/finding.md` | Re-runs the evidence; sets the status | 8 |
| 5 | Maturity | Drafts `maturity.yml` from confirmed findings only | [maturity.md](../tools/maturity.md) | Level and confidence per dimension | 5 |
| 6 | Recommendations | Proposes recommendation cards ordered by impact over effort | `templates/report.md` | Owner, effort and order | 11 |

A stage starts only on confirmed output of the stage before it: a finding drafted from an
unconfirmed inventory is not reviewed.

## Claims stay within what was checked

An agent writes fast and generalises easily; a reviewer reads the generalisation as a finding.
Every drafted claim names its window and its place, and says no more than its check. Evaluation
is not detection; absence of data is not a defect by itself; an alarm OK by its missing-data
setting is reported as such; a total read at account or service level is not attributed to the
scope; a difference is not a cause; defined in code is not emitted; a document's statement
carries its date and is not the current state. The wording rules are in the
[stage 1 prompt](../tools/agent/stage-1-inventory.md) and apply at every stage.

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

Until both quality targets hold on two engagements, the harness speeds up inventory only, and
findings are written by people.

**First engagements are pilot measurements.** Record agent elapsed time and person hours
separately, per stage. Agent elapsed time is not compared with the person-days of the
estimation model: those include preparation, human review and acceptance, and the scope
differs. The comparison is made on time recorded for the same work. A reviewer's re-run of a
sample of checks says that those claims hold; it is not an estimate of the accuracy of the
whole output — report it as "n of n selected checks reproduced". Record the person's hours per
stage next to the agent's time. When a row is split or merged during review (the inventory
changes granularity), count it apart from drafts corrected in substance: it is a change of
granularity, not an error of the draft.

Later stages cite inventory rows by a stable id, never by line number: an edit after review
moves every line below it.

## Status

Specification. The tools behind stages 1, 3 and 5 exist in this kit; stages 1, 2, 4 and 6 are
packaged as task prompts in [tools/agent/](../tools/agent/README.md). Stage 1 has been run once
on a real engagement and reviewed; its review is behind the rules on claims, statuses, blind
spots and pilot measurement above. Not yet measured on two engagements.
