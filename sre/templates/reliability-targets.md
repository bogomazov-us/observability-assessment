# Reliability targets

SRE stage 2 fills these rows in `sre/targets/`: the target model per tier, or per service where
a service differs from its tier. The agent proposes; a technical owner agrees each value, and
the agreement is a row in the decision register before a `T-` row cites it
([records.md](../../method/records.md)).

| Column | Holds |
|---|---|
| ID | `T-01`, `T-02` …; never renumbered or reused; a changed target is a new row that names the one it supersedes |
| Applies to | A tier (tier 1) or a service (`S-` id) |
| Kind | SLO, RTO, RPO, rollout policy, on-call limit, toil cap, actionable alert share |
| Value | The target, with its unit and window |
| Default or agreed | *default*: the kit's starting value, not yet confirmed; *agreed*: the owner's value, the same or replaced |
| Decision | The `D-` row that agreed it; empty while default |
| Owner | The technical owner who signs it |
| Status | `proposed` · `confirmed` |

A row is `confirmed` only when it is *agreed* and its decision row exists. An SLO's definition
(SLI, bad predicate, budget, window) follows the spec rules in
[slo-alerts.md](../../templates/spec-set/slo-alerts.md); in the combined format the SLO is the
observability spec's row and this row cites its spec id.

## Defaults

From the [SRE maturity model](../maturity-model.md). Stage 2 enters them as default rows; the
client confirms or replaces each.

| ID | Applies to | Kind | Value | Default or agreed | Decision | Owner | Status |
|---|---|---|---|---|---|---|---|
| [T-01] | tier 1 | on-call limit | at most two incidents per 12-hour shift | default | | [on-call owner] | `proposed` |
| [T-02] | [team or tier] | toil cap | at most 50% of engineering time | default | | [engineering manager] | `proposed` |
| [T-03] | tier 1 | actionable alert share | none; the client sets the target | default | | [alert owner] | `proposed` |

## Targets

| ID | Applies to | Kind | Value | Default or agreed | Decision | Owner | Status |
|---|---|---|---|---|---|---|---|
| [T-04] | [S-01] | SLO | [J1.1 availability 99.5% over 28 days] | agreed | [D-NN] | [product owner] | `confirmed` |
| [T-05] | [S-01] | RTO | [1 hour] | agreed | [D-NN] | [service owner] | `confirmed` |
| [T-06] | [S-01] | RPO | [15 minutes of data] | [agreed] | [D-NN] | [data owner] | [status] |
| [T-07] | tier 1 | rollout policy | [progressive delivery with automatic halt on SLO burn] | [agreed] | [D-NN] | [release owner] | [status] |

**Not agreed** — each target still default or proposed at the end of stage 2, with its owner
question (`Q-`) and date. Stage 3 measures against the agreed value, and against a default only
when it says so.
