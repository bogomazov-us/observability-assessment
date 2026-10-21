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

## Pipeline: inputs → model → gap → recommendations

| # | Stage | Agent does | Tool | Person confirms | Playbook step |
|---|---|---|---|---|---|
| 1 | Inventory | Runs the code scan; exports the estate by object class through the tool's read-only API or MCP server | [collect.md](../tools/collect.md) | Exports reconcile with each other (counts, names) | 3, 4 |
| 2 | Target model | Drafts journeys → functions from HAR captures, routes and code; drafts the error taxonomy from error handlers | `observability-spec.yml` skeleton | Each function and class against code and a captured request | 6, 7 |
| 3 | Gap | Checks the drafted model against the estate: which signals are live, which SLIs could be computed today, which alerts sit on pooled rates or hosts | [speclint.md](../tools/speclint.md) | Each "live" by browser, agent or tenant evidence | 7, 8 |
| 4 | Findings | Drafts findings in the `finding.md` format, status *assumption*, with the cited evidence | `templates/finding.md` | Re-runs the evidence; sets the status | 8 |
| 5 | Maturity | Drafts `maturity.yml` from confirmed findings only | [maturity.md](../tools/maturity.md) | Level and confidence per dimension | 5 |
| 6 | Recommendations | Proposes recommendation cards ordered by impact over effort | `templates/report.md` | Owner, effort and order | 11 |

A stage starts only on confirmed output of the stage before it: a finding drafted from an
unconfirmed inventory is not reviewed.

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

## Status

Specification. The tools behind stages 1, 3 and 5 exist in this kit; stages 2, 4 and 6 are
packaged as task prompts in [tools/agent/](../tools/agent/README.md), not yet measured on an
engagement.
