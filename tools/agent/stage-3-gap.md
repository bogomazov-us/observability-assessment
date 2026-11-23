# Observability stage 3 — gap

*Task prompt. Assemble it with `tools/agent/prompt.sh 3`, which appends the rule files it
names, and paste the result as is; replace the bracketed values.*

---

You check a confirmed target model against the live estate: which of its signals exist and
work, which SLIs could be computed today, which alerts could detect what they are meant to,
and what stands between each alert and a person who acts on it. You draft; a person confirms
a sample of the "live" signals and each "proven" detection.

## Rules

The rule files in [`rules/`](rules/) apply to this stage: [boundaries](rules/boundaries.md),
[evidence](rules/evidence.md), [claims](rules/claims.md),
[owner questions](rules/owner-questions.md) and the [progress log](rules/progress-log.md),
with N = 3. The boundaries below are this stage's own and add to the common ones.

## Boundaries

- Read-only on the client's estate: code checkout, monitoring tool, exports, logs. You may run
  read queries; you never change configuration, code or tickets, and you never inject a fault
  or send test traffic to production. A fault is reproduced on a stage, by the client's
  developer, or during implementation — you write the scenario, you do not run it there.
- Count and classify log lines; quote none.
- A window read for an event starts before it, with margin: a window that starts at the
  event's minute can miss it, and a counter that buckets by period reports at the end of its
  bucket.

## Inputs

| Input | Where |
|---|---|
| Spec, confirmed at stage 2 | `spec/observability-spec.yml` |
| Stage 2 notes and the decision register | `stage-2-notes.md`, decision register |
| Inventory, confirmed at stage 1 | `inventory.md` |
| Code checkout (read-only) | [path] |
| Read-only access to the monitoring estate and its logs | [token, profile or MCP server; named, never pasted] |
| A system without read access for the agent (an edge, a SaaS console) | [none, or: read by the person in its own console under an owner decision recorded first] |
| Open questions carried from stage 2 | `stage-2-notes.md`, "Open questions" |
| Facts ledger, risk register | instructions file |

## Method

Every step has its full rule and cases under its number in the
[stage 3 reference](reference/stage-3-reference.md) (in the kit, `tools/agent/reference/`).
Read it before the step; it binds as if it were here.

1. **Signals.** Each spec signal `live` (estate evidence over a stated window), `to_build`,
   `differs` or `not_verifiable`.
2. **SLIs.** Per SLO, good and valid from live signals alone, as a reading; else the missing
   signal.
3. **Alerts.** Per alert: live rule, inputs present, grouping, state as evaluated.
4. **Detection matrix.** Per P1 alert, the chain fault to acknowledgement: proven, scenario
   written or residual risk.
5. **Paging readiness.** Per alert, each part of the paging gate shown or not shown.
6. **Telemetry health.** Per failure in stage 2's table: detecting signal live, and how it
   reads today.
7. **Open questions carried.** Each answered from evidence or "not established".
8. **Blind spots.** Each handed to the person for the risk register now.

## Output

The stage report, `stage-3-gap.md`, follows [`stage-report.md`](../../templates/stage-report.md)
and its chain for this stage; the progress log, the decision register and the full spec
travel with it as files at a stated commit, cited, not reprinted.

1. Updated `spec/observability-spec.yml`: each signal's `state` and `evidence` from step 1; nothing
   else in the target changes. A target the gap shows unreachable is an open question for
   the owner, not an edit.
2. `stage-3-gap.md`:
   - first, five to seven results and their consequences;
   - signals: live / to build / differs / not verifiable ([records.md](../../method/records.md)), with counts that sum to the
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
3. `python3 tools/speclint.py spec/observability-spec.yml`: no errors. A paging alert on a signal that is not live
   fails SL011.

## Self-check before handing over

- [ ] Every `live` has evidence from the estate in a stated window; nothing is live because the
      code defines it.
- [ ] Signal counts sum to the signals in the spec.
- [ ] Every SLI reading is labelled a reading, with its window; none is reported as met.
- [ ] Every P1 alert is in the detection matrix as proven, scenario written or residual risk;
      no fault was injected and no test traffic sent to production.
- [ ] Every paging item is shown with a citation or marked not shown, per alert.
- [ ] No target, owner or threshold was changed; what the gap questions is an open question.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../../method/getting-started.md#3-calendar) gives, checks a sample of the "live" signals, chosen by them, through another path than the
agent's query: the tool's own interface, a browser, or a query they write. Re-running the
agent's query shows that it repeats, not that the signal is live. Checks each "proven" in the
detection matrix the same way. Agrees the owners of the residual risks and registers the blind spots. Decides which
scenarios are run, where and by whom. Confirms the gap as the input to stage 4, or returns it.
