# Stage 1 — inventory

*Task prompt. Paste as is; replace the bracketed values.*

---

You draft the inventory of an observability assessment: what the code and the configuration say
is collected, alerted on and routed, checked against what the monitoring estate shows live. You
draft; a person confirms.

## Boundaries

- Read-only. You read the code checkout and query the monitoring estate through a read-only
  token, profile or MCP server: list, describe, get and read-only queries only.
- You write only inside the engagement repository, in the files named under "Output".
  Temporary files go only in the scratch directory the person names: [path].
- Never print or write secrets, credentials, account identifiers, notification endpoints,
  IP addresses (private ones included) or log bodies. Record that a value exists, not the
  value. Resource and profile names may be written; they stay in the engagement repository.
- Every claim cites what it rests on: file:line, or the query or call with its time range.
- Nothing you write is a fact. It enters the facts ledger as an assumption.
- No client data leaves the engagement repository.
- Read only the paths and systems listed under "Inputs". Anything else is out of scope: name
  it as an open question, do not open it.
- A question addressed to the owner or the client stays open: you never decide it, even when
  one answer looks obvious. You may list candidate answers, marked as candidates.

## Inputs

| Input | Where |
|---|---|
| Scope: journeys and services, as agreed at kick-off | [facts ledger or kick-off note] |
| Code checkout (read-only) | [path] |
| Code scan report | output of `tools/collect/code-scan.sh` ([scan.md]) |
| Read-only access to the monitoring estate | [token, profile or MCP server; named, never pasted] |
| Facts ledger, risk register | [paths] |

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

## Claims stay within what was checked

Each claim says what was looked at, and no more:

- **Name the window and the place.** For a point-in-time read (a configuration, an alarm's
  current state) the time of the check is the window. "0 traces in the trace store in the checked 24 h", not
  "traces are not delivered": another backend, or another window, was not checked.
- **Evaluation is not detection.** A rule that evaluates without error and is inactive shows
  that the expression runs. Whether it fires on a failure needs a scenario test.
- **Absence of data is not a defect by itself.** An error series that does not exist may mean
  no such error happened. Say what would tell the two apart.
- **Say how a state was reached.** An alarm that is OK because missing data is treated as not
  breaching is "no data, OK by the missing-data setting", not "OK".
- **Totals are not attributions.** A cost or volume read at account or service level is
  labelled so; attribution to the scope is a separate step, done or not done.
- **A difference is not a cause.** "Counter above the expected number of scheduled runs; cause
  not established" until the cause is shown.
- **Defined is not emitted.** A metric, label or alert defined in code is "defined in code";
  it is live only when the series or rule was seen in the estate.
- **A document's statement has a date.** Client documents mix past and present. Quote a
  statement with the document's date, and never carry it into the current state without
  live evidence.
- **A mechanism runs in more than one way.** "Each run writes a record" holds only after every
  way it runs was read: full, partial or filtered runs, stop on the first error, continue on
  error, dry run, offline, killed. List the modes from the options and the error branches,
  and say per mode what is written; when a mode was not read, say so.
- **A measurement names its method.** Say which tool and settings produced a number when they
  change it — sampling, a default depth, a window. An explanation that goes beyond what was
  measured ("only a restart would help") is a hypothesis until something shows it.
- **Absence everywhere is not a location.** When no layer's counters show an event, say that;
  it does not place the source in the layer that was not read, and it does not exclude a layer
  whose counters could miss it. A missing header or field alone does not establish where a
  response came from: that takes the full request record, correlated in each layer.
- **A remedy narrows; say what it leaves.** A proposed or decided fix is described with the
  case it does not cover and the test that would show it, not as closing the gap.
- **A health signal vouches for its own stream.** A heartbeat shows that its stream arrives,
  not that any other input exists; each input is checked on its own.
- **Not built is not impossible.** "Continuous computation is not implemented" when a value
  was computed once by hand; "cannot be computed" only when the inputs do not exist.
- **A passing check shows what it ran.** A green pipeline or test suite covers the paths it
  exercised; say which. What a pipeline runs is read from its steps, not from a job name.

## Output

The stage report follows [`stage-report.md`](../../templates/stage-report.md): the result
first, then scope and method, the main results, the records, decisions and open questions, and
an evidence catalog of `E-` ids. Decision, implementation and verification are separate
statuses. The progress log, review history, the decision register and the full spec travel
with the report as files at a stated commit; the report cites them and does not reprint them.

1. `inventory.md`: one page of result (scope, objects by status, material differences, what
   was not checked), then the live verification table (class, object, status, evidence by
   `E-` id — the commands and their output go to the evidence catalog), sources read as an
   appendix, each snapshot with its commit or configuration revision, the status summary with its sum, the reconciliation, the code scan leads, and
   what could not be inventoried with the reason.
   In the reconciliation, a claim may cite the row id that holds its evidence instead of
   repeating the query; a claim with neither is not written.
2. A list of **confirmed blind spots** — a check that cannot fire, a notification that reaches
   nobody, a check the design or the journey definitions rely on that does not exist — handed to the person for the risk register now, each with a proposed owner. They do
   not wait for the findings of stage 4; the finding is written there and links the risk.

## Progress log

Keep `progress/stage-1.md` in the engagement repository while you work, so a person can see
where the stage is without asking you. Its first line is the plan: the steps, numbered, and
their count. Then one line when a step starts and one when it ends, one per commit with its
hash, and one when you stop on something:

```
14:05 plan — 6 steps: 1 sources, 2 functions, 3 error paths, 4 taxonomy, 5 lint, 6 notes
14:07 step 1/6 sources — started
14:31 step 1/6 sources — done; disagreements handed to the person
14:32 step 2/6 functions — blocked: no capture for J3 (open question 4)
14:40 commit 3f2a1c9 — functions J1, J2
```

Append, never rewrite. Times are local, with the time zone once at the top. The log is
committed with the stage's output; the first and last times are the agent's elapsed time.

## Self-check before handing over

- [ ] Every row has a stable id and one status; the counts sum to the number of rows.
- [ ] Every claim names its window and place, and its source.
- [ ] No claim says more than its check: evaluation, absence, missing-data states, totals,
      causes, modes of a mechanism, measurement methods and passing checks are worded as above.
- [ ] Nothing secret or identifying was printed or written.
- [ ] Nothing was written outside the engagement repository.
- [ ] The progress log ends with the last step done and the last commit.

## What the person confirms

Re-runs a sample of the cited checks, chosen by them, and records each result. A sample that
reproduces says those claims hold; it is not an estimate of the accuracy of the whole
inventory. Registers the confirmed blind spots as risks with owners. Confirms the inventory as
the baseline for stage 2, or returns it; on confirmation the document's own status line is
updated, so it never says "assumption" after it was confirmed.
