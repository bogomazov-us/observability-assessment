# Golden journey proof

Full assessment, phase 4 ([offerings.md](../offerings.md)); its weeks are in the
[calendar](../method/getting-started.md#3-calendar). One journey instrumented end to end on
stage, with the client's developer making the code change. Without stage access with write
rights to the monitoring configuration and a client developer (data request rows 13–14), the
proof is delivered as a design and a checklist: fill the same sections, mark the record
**design only**, and leave "Shown end to end" as the checklist to run later.

Engagement: [name] · Record status: demonstrated | design only · Date: [date]

## Journey

| Journey | Functions (spec ids) | Why this one | Decision that put it in scope |
|---|---|---|---|
| [journey, client's words] | [J1.1, J1.2 …] | [tier-1, worst gap, mandatory at go-live] | [D-NN] |

## Instrumentation added

| Function | Change (code, agent or tool configuration) | Where (repository, commit or configuration revision) | Made by | Signal it produces |
|---|---|---|---|---|
| [J1.1] | [event or span with attempt and operation ids; error class on failure] | [repo@commit] | [client developer, role] | [signal name] |

The client owns the code change; the assessment team writes to the monitoring configuration on
stage only, as the access granted allows.

## Shown end to end

The trace or signal followed from the user's action to the dashboard and, for a P1 alert, to
the person it reaches. One row per scenario; a failure scenario is part of the proof.

| # | Scenario | Expected | Seen (query or trace id, time range) | Evidence id | Result |
|---|---|---|---|---|---|
| 1 | [successful attempt] | [one attempt, outcome success, every function linked] | [query, window] | [E-NNN] | shown / not shown |
| 2 | [a typed failure, reproduced on stage] | [error class, alert evaluates and fires, notification reaches the rota] | [query, window] | [E-NNN] | shown / not shown |

## Demonstration

| Demonstrated by | To | Date | Where (environment, recording) |
|---|---|---|---|
| [role] | [sponsor, technical owners] | [date] | [stage; recording or screenshots in the engagement repository] |

## Acceptance

| Criterion | Evidence | Accepted by | Decision |
|---|---|---|---|
| [every function of the journey produces its signal on stage] | [E-NNN] | [technical owner] | [D-NN] |

**Not shown, and why** — each gap with what would show it, its owner and where it goes (a
finding, a `V-` task or a roadmap item).
