# SRE stage 1 — inventory

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 1`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You draft the inventory of an SRE assessment: what the catalogue, code and configuration say
should exist, checked against the exports and the live systems. You draft; a person confirms.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md),
[owner questions](../../tools/agent/rules/owner-questions.md) and the
[progress log](../../tools/agent/rules/progress-log.md), with N = 1. The boundaries below are
this stage's own and add to the common ones.

## Boundaries

- Read-only. You read the code checkout and the infrastructure as code, and query the client's
  systems through read-only tokens, profiles or MCP servers: list, describe, get and read-only queries only.
- You never run a deploy, rollback, restore, failover, load test, page or drill.

## Inputs

| Input | Where |
|---|---|
| Scope: services and critical journeys, as agreed at kick-off | `kickoff-note.md`, decision register |
| Code checkout and infrastructure as code (read-only) | [paths] |
| Read-only access: delivery pipeline, incident tracker, paging tool, backup console, estate | [tokens, profiles or MCP servers; named, never pasted] |
| Client exports for the SRE data request | [path] |
| Facts ledger, risk register | instructions file |

## Method

Steps 1, 4, 5 and 6 have their classes, checks and methods under their number in the
[stage 1 reference](reference/stage-1-reference.md). Read it before the step; it binds as if it were here.

1. List each object by the reference's object classes: what should exist, from its source.
2. Read the export or query the system for each object: does it exist, and does it match?
   Record the export file or the query and its time range.
3. One row per object, each with a stable id (`L-01`, `L-02` …) that later stages cite. Ids are
   never renumbered: a row split later keeps its id on one part and gives the other a new one;
   a row withdrawn keeps its id with the reason. Give every row exactly one status, comparing
   the live object with the catalogue, code or configuration (never with your own draft):

   | Status | Means |
   |---|---|
   | confirmed | exists as the source says; a live fact that contradicts nothing (a count, a last run) is stated in the row |
   | differs | exists, but differs from the source, or exists live with no source behind it |
   | not found | no object, or no data, in the checked window |
   | not verifiable | not attempted or not possible: outside the access granted, the export not received, or the system is down; say which |

   The statuses do not overlap (status sets: [records.md](../../method/records.md)). The
   summary gives each count and their sum, and the sum equals the number of rows. An error in
   your own draft is corrected in the draft, not recorded as a difference.
4. Reconcile the classes with each other: a service with no rotation, a data store with no
   restore on record, a running resource no code describes.
5. Draft the service catalogue from [the template](../templates/service-catalogue.md): one
   `S-` row per service; tiers stay *proposed* for stage 2.
6. Run [`tools/baseline.py`](../../tools/baseline.md) on the sanitized exports. A number the
   data cannot support stays *not measured* with its reason, never estimated.

## Output

The stage report, `sre/inventory.md`, follows
[`stage-report.md`](../../templates/stage-report.md) and its chain for this stage; the progress
log, the decision register and the exports travel with it as files at a stated commit, cited,
not reprinted.

1. `sre/inventory.md`: one page of result (scope, objects by status and class, material
   differences, what was not checked), then the sections of the
   [reference, Output](reference/stage-1-reference.md#output).
2. `sre/service-catalogue.md`: the `S-` rows and the template's checks answered.
3. `sre/baseline.md`: the `B-` rows as the tool prints them, with their source export.
4. A list of **confirmed blind spots** (the reference's checks in bold, such as a restore
   never tested), handed to the person for the risk register now, each as a row of its columns: risk, source (blind spot,
   stage 1, row id), proposed owner, status *open*, date. They do not wait for the findings of
   stage 4; the finding is written there and links the risk.
5. `sre/exports/`: what you read, a file per object class named with the class and export date
   (`sre/exports/incidents-2027-03-01.csv`), sanitized per the
   [privacy checklist](../../templates/privacy-checklist.md) and the
   [data request](../templates/data-request.md) rules, each stating its query or call, time
   and count.

## Self-check before handing over

- [ ] Every row has a stable id and one status; the counts sum to the number of rows.
- [ ] Every inventory row cites an export file or a query.
- [ ] Every `B-` row has its method, window and source, or *not measured* with the reason.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives, checks that the exports reconcile
(counts, names) and the statuses sum to the rows; re-runs a sample of the cited checks, chosen
by them, and records each result; re-runs `tools/baseline.py` on the same exports. An object
confirmed by a live fact is checked through another path than the agent's query (the tool's own
interface, a browser, or a query they write). A sample that reproduces says those claims hold;
it is not an estimate of the accuracy of the whole inventory. Registers the confirmed blind
spots as risks with owners. Confirms the inventory as the baseline for stage 2, or returns it;
on confirmation the document's own status line is updated, so it never says "assumption" after
it was confirmed. On confirmation the lead rewrites the
summary and adds this stage's lines to the manifest ([report](../README.md#report)).
