# Reliability targets

SRE stage 2 fills these rows in `sre/targets/`: the target model per tier, or per service where
a service differs from its tier. The agent proposes; a technical owner agrees each value, and
the agreement is a row in the decision register before a `T-` row cites it
([records.md](../../method/records.md)).

| Column | Holds |
|---|---|
| ID | `T-01`, `T-02` …; never renumbered or reused; a changed target is a new row that names the one it supersedes |
| Applies to | A tier (tier 1), a service (`S-` id), or a dimension for a target level |
| Kind | SLO, RTO, RPO, rollout policy, on-call limit, toil cap, actionable alert share, target level |
| Value | The target, with its unit and window; for a target level, the model's level, or *none, by the owner's choice* |
| Premise | What the value assumes about the estate, with its source (a store holds only files that can be rebuilt); empty when none. Stage 3 checks it |
| Default or agreed | *default, to confirm*: the kit's starting value, not yet confirmed; *agreed*: the owner's value, the same or replaced; empty while Value reads `[owner sets: Q-NN]` (no kit default; the owner question is open) |
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

| ID | Applies to | Kind | Value | Premise | Default or agreed | Decision | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| [T-01] | tier 1 | on-call limit | at most two incidents per 12-hour shift | | default, to confirm | | [on-call owner] | `proposed` |
| [T-02] | [team or tier] | toil cap | at most 50% of engineering time | | default, to confirm | | [engineering manager] | `proposed` |
| [T-03] | tier 1 | actionable alert share | none; the client sets the target | | default, to confirm | | [alert owner] | `proposed` |

## Targets

| ID | Applies to | Kind | Value | Premise | Default or agreed | Decision | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| [T-04] | [S-01] | SLO | [J1.1 availability 99.5% over 28 days] | | agreed | [D-NN] | [product owner] | `confirmed` |
| [T-05] | [S-01] | RTO | [1 hour] | | agreed | [D-NN] | [service owner] | `confirmed` |
| [T-06] | [S-01] | RPO | [owner sets: Q-NN] | | | | [data owner] | `proposed` |
| [T-07] | tier 1 | rollout policy | [progressive delivery with automatic halt on SLO burn] | | [agreed] | [D-NN] | [release owner] | [status] |
| [T-08] | [S-02] | RPO | [24 hours] | [the store holds only files that can be rebuilt: E-NNN] | agreed | [D-NN] | [data owner] | `confirmed` |
| [T-09] | dimension 9 | target level | [3, or none, by the owner's choice] | | agreed | [D-NN] | [sponsor] | `confirmed` |

**Not agreed** — each target still default or proposed at the end of stage 2, with its owner
question (`Q-`) and date. Stage 3 measures against the agreed value, and against a default only
when it says so.
