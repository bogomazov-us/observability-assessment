# Stage 3 — gap

*Task prompt. Paste as is; replace the bracketed values.*

---

You check a confirmed target model against the live estate: which of its signals exist and
work, which SLIs could be computed today, which alerts could detect what they are meant to,
and what stands between each alert and a person who acts on it. You draft; a person confirms
each "live" and each detection claim.

## Boundaries

- Read-only on the client's estate: code checkout, monitoring tool, exports, logs. You may run
  read queries; you never change configuration, code or tickets, and you never inject a fault
  or send test traffic to production. A fault is reproduced on a stage, by the client's
  developer, or during implementation — you write the scenario, you do not run it there.
- You write only inside the engagement repository, in the files named under "Output".
  Temporary files go only in the scratch directory the person names: [path].
- Never print or write secrets, credentials, account identifiers, notification endpoints,
  IP addresses or log bodies. Count and classify log lines; quote none.
- Every claim cites what it rests on: the query or call with its time range, file:line, or the
  inventory row id. The claim rules of the [stage 1 prompt](stage-1-inventory.md) apply: name
  the window and the place; evaluation is not detection; absence is not a defect; defined is
  not emitted; a mechanism is described per way it runs; absence in every layer read is not a
  location; a remedy is stated with the case it leaves.
- A window read for an event starts before it, with margin: a window that starts at the
  event's minute can miss it, and a counter that buckets by period reports at the end of its
  bucket.
- Nothing you write is a fact. It enters the facts ledger as an assumption.
- Read only the paths and systems listed under "Inputs". Anything else is out of scope: name
  it as an open question, do not open it.
- A question addressed to the owner or the client stays open: you never decide it. You may
  list candidate answers, marked as candidates.

## Inputs

| Input | Where |
|---|---|
| Spec, confirmed at stage 2 | [docs/observability/observability-spec.yml] |
| Stage 2 notes and the decision register | [stage-2-notes.md], [decision register] |
| Inventory, confirmed at stage 1 | [inventory.md] |
| Code checkout (read-only) | [path] |
| Read-only access to the monitoring estate and its logs | [token, profile or MCP server; named, never pasted] |
| A system without read access for the agent (an edge, a SaaS console) | [none, or: read by the person in its own console under an owner decision recorded first] |
| Open questions carried from stage 2 | [list] |
| Facts ledger, risk register | [paths] |

## Method

1. **Signals.** For each signal in the spec, query the estate over a stated window: does the
   series or event exist, with the attributes the spec names, at the volume stage 2 expected?
   Mark it `live` only with that evidence; otherwise `to_build`, `differs` (exists, does not
   match, and how) or `not_verifiable` (and why) — the four `state` values speclint accepts.
2. **SLIs.** For each SLO, can good and valid be computed today from live signals alone? Run
   the query when it can, over the SLO's window or the longest available, and record the
   result as a reading, not a verdict. When it cannot, name the missing signal. Check the
   window states: can no traffic be told from telemetry unknown?
3. **Alerts.** For each alert, the live rule or none; its input series present or not over the
   window; grouped per function or on a pooled rate or host; its state as evaluated. An alert
   whose input series never existed in the window can say nothing either way.
4. **Detection matrix.** For each P1 alert, the chain fault → signal → evaluation → firing →
   notification → acknowledgement, and how each link is shown:
   **proven** (a recorded firing or reproduction, with date and source), **scenario written**
   (steps, expected firing and time, who runs it, where — never production by you), or
   **residual risk** (why it cannot be shown now; a proposed owner). No-data and recovery are
   part of the scenario.
5. **Paging readiness.** For each alert meant to page: owner, on-call rota, acknowledgement,
   escalation, runbook, a delivery test of this alert's route, and a fallback route — each
   **shown** (cite it) or **not shown**. Stated in a document is not shown.
6. **Telemetry health.** Walk the telemetry failure table from stage 2: for each failure, is
   its detecting signal live, and what would the failure read as today?
7. **Open questions carried.** Answer from evidence the questions stage 2 moved here; for each,
   the evidence or "not established" with what would establish it. A layer you cannot read is
   `not verifiable` with an owner question; when the owner allows a read in the system's own
   console, the person does it read-only and records status, path template, host class and
   time only, as a dated addition to your draft, not as your evidence.
8. **Blind spots.** A check that cannot fire, a route that reaches nobody, an alert that reads
   no data as healthy: hand each to the person for the risk register now, with a proposed
   owner.

## Output

The stage report follows [`stage-report.md`](../../templates/stage-report.md): the result
first, then scope and method, the main results, the records, decisions and open questions, and
an evidence catalog of `E-` ids. Decision, implementation and verification are separate
statuses. The progress log, review history, the decision register and the full spec travel
with the report as files at a stated commit; the report cites them and does not reprint them.

1. Updated `observability-spec.yml`: each signal's `state` and `evidence` from step 1; nothing
   else in the target changes. A target the gap shows unreachable is an open question for
   the owner, not an edit.
2. `stage-3-gap.md`:
   - first, five to seven results and their consequences;
   - signals: live / to build / differs / not verifiable, with counts that sum to the
     signals and a line on what the count counts (signal rows bound to functions, not
     necessarily distinct series), and the evidence per row; absent, differs, not verified
     and an observed failure are separate fields;
   - SLIs computable today, with their readings, and the missing signals for the rest;
   - alerts: rule, inputs present, grouping, state;
   - the detection matrix (proven / scenario written / residual risk) and the scenarios;
   - the paging readiness table (shown / not shown per item);
   - telemetry health, carried questions, blind spots;
   - stage-4 candidates: each gap with the evidence a finding would cite; gaps whose fixes
     differ are separate candidates.
3. `python3 tools/speclint.py <spec>`: no errors. A paging alert on a signal that is not live
   fails SL011.

## Progress log

Keep `progress/stage-3.md` in the engagement repository while you work, so a person can see
where the stage is without asking you. Its first line is the plan: the steps, numbered, and
their count. Then one line when a step starts and one when it ends, one per commit with its
hash, and one when you stop on something:

```
14:05 plan — 8 steps: 1 signals, 2 SLIs, 3 alerts, 4 detection, 5 paging, 6 telemetry, 7 questions, 8 blind spots
14:07 step 1/8 signals — started
14:52 step 1/8 signals — done; 14 live, 30 to build, 2 differ, 1 not verifiable
14:53 step 2/8 SLIs — blocked: no read access to the log store (open question 3)
15:10 commit 3f2a1c9 — signal states
```

Append, never rewrite. Times are local, with the time zone once at the top. The log is
committed with the stage's output; the first and last times are the agent's elapsed time.

## Self-check before handing over

- [ ] Every `live` has evidence from the estate in a stated window; nothing is live because the
      code defines it.
- [ ] Signal counts sum to the signals in the spec.
- [ ] Every SLI reading is labelled a reading, with its window; none is reported as met.
- [ ] Every P1 alert is in the detection matrix as proven, scenario written or residual risk;
      no fault was injected and no test traffic sent to production.
- [ ] Every paging item is shown with a citation or marked not shown.
- [ ] No target, owner or threshold was changed; what the gap questions is an open question.
- [ ] Nothing secret or identifying was printed or written; nothing was written outside the
      engagement repository.
- [ ] The progress log ends with the last step done and the last commit.

## What the person confirms

Re-runs a sample of the "live" checks, chosen by them, and each "proven" in the detection
matrix. Agrees the owners of the residual risks and registers the blind spots. Decides which
scenarios are run, where and by whom. Confirms the gap as the input to stage 4, or returns it.
