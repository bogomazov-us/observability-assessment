# Stage 1 — inventory

*Task prompt. Assemble it with `tools/agent/prompt.sh 1`, which appends the rule files it
names, and paste the result as is; replace the bracketed values.*

---

You draft the inventory of an observability assessment: what the code and the configuration say
is collected, alerted on and routed, checked against what the monitoring estate shows live. You
draft; a person confirms.

## Rules

The rule files in [`rules/`](rules/) apply to this stage: [boundaries](rules/boundaries.md),
[evidence](rules/evidence.md), [claims](rules/claims.md),
[owner questions](rules/owner-questions.md) and the [progress log](rules/progress-log.md),
with N = 1. The boundaries below are this stage's own and add to the common ones.

## Boundaries

- Read-only. You read the code checkout and query the monitoring estate through a read-only
  token, profile or MCP server: list, describe, get and read-only queries only.

## Inputs

| Input | Where |
|---|---|
| Scope: journeys and services, as agreed at kick-off | `kickoff-note.md`, decision register |
| Code checkout (read-only) | [path] |
| Read-only access to the monitoring estate | [token, profile or MCP server; named, never pasted] |
| Facts ledger, risk register | instructions file |

## Method

1. From code and configuration, list each object by the classes of
   [collect.md](../collect.md), "Estate export by object class": what should exist.
2. Query the estate for each object: does it exist, and does it match? Record the query and its
   time range.
3. One row per object, each with a stable id (`L-01`, `L-02` …) that later stages cite. Ids are
   never renumbered: a row split later keeps its id on one part and gives the other a new one;
   a row withdrawn keeps its id with the reason. Give every row exactly one status, comparing the live object with the
   code or configuration (never with your own draft):

   | Status | Means |
   |---|---|
   | confirmed | exists as the code or configuration says; a live fact that contradicts nothing (a count, a last run) is stated in the row |
   | differs | exists, but differs from the code or configuration, or exists live with no code or configuration behind it |
   | not found | no object, or no data, in the checked window |
   | not verifiable | not attempted or not possible: outside the access granted, the system is down, or the comparison needs an attribution not yet done; say which |

   The statuses do not overlap. The summary gives each count and their sum, and the sum equals
   the number of rows. An error in your own draft is corrected in the draft, not recorded as
   a difference.
4. Reconcile the classes with each other: an alert with no route to a person, a metric no alert
   reads, a route with no subscriber.

## Output

The stage report, `inventory.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log, the decision register and the full spec
travel with it as files at a stated commit, cited, not reprinted.

1. `inventory.md`: one page of result (scope, objects by status, material differences, what
   was not checked), then the live verification table (class, object, status, evidence by
   `E-` id — the commands and their output go to the evidence catalog), sources read as an
   appendix, each snapshot with its commit or configuration revision, the status summary with its sum, the reconciliation, the code scan leads, and
   what could not be inventoried with the reason.
   In the reconciliation, a claim may cite the row id that holds its evidence instead of
   repeating the query; a claim with neither is not written.
2. A list of **confirmed blind spots** — a check that cannot fire, a notification that reaches
   nobody, a check the design or the journey definitions rely on that does not exist — handed to the person for the risk register now, each as a row of its columns: risk, source (blind spot, stage 1, row id), proposed owner, status *open*, date. They do
   not wait for the findings of stage 4; the finding is written there and links the risk.
3. `scan.md`: the report of `tools/collect/code-scan.sh` on the code checkout, unless the
   person has run it already.
4. `exports/`: what you read from the estate, a file per object class named with the class
   and export date (`exports/alert-rules-2027-03-01.json`), sanitized per the
   [privacy checklist](../../templates/privacy-checklist.md), stating its query or call, time
   and count ([collect.md](../collect.md)).

## Self-check before handing over

- [ ] Every row has a stable id and one status; the counts sum to the number of rows.
- [ ] Every inventory row cites an export file or a query.
- [ ] The check at the end of each rule file holds.

## What the person confirms

Re-runs a sample of the cited checks, chosen by them, and records each result; an object
confirmed by a live fact is checked through another path than the agent's query (the tool's
own interface, a browser, or a query they write). A sample that
reproduces says those claims hold; it is not an estimate of the accuracy of the whole
inventory. Registers the confirmed blind spots as risks with owners. Confirms the inventory as
the baseline for stage 2, or returns it; on confirmation the document's own status line is
updated, so it never says "assumption" after it was confirmed.
