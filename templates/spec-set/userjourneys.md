# User journeys

*Spec-set skeleton for `userjourneys.md`. Which journeys and functions are measured, and by what. One section per journey; one row per business function. A function is the smallest step the business would name when it fails.*

## J1 · [journey name]

[One sentence: who does what, and what counts as success.]

| # | Function | Route or call | Signal | Typed failures | SLI | Draft threshold |
|---|---|---|---|---|---|---|
| J1.1 | [e.g. sign-in authenticate] | `POST /api/session` | [business event / span / RUM action] | [wrong password (expected), identity provider down (failure)] | [successful ÷ valid attempts] | [99.5 % over 28 days] |
| J1.2 | | | | | | |

Notes: [where one business attempt spans several calls; retries; asynchronous steps].

## J2 · [journey name]

| # | Function | Route or call | Signal | Typed failures | SLI | Draft threshold |
|---|---|---|---|---|---|---|
