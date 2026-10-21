# Skeleton — `error-taxonomy.md`

What each error code means. Every code gets exactly one class; unknown counts as bad until it
is classified.

---

# Error taxonomy

## Classes

| Class | Meaning | Counts against the SLI | Alerts |
|---|---|---|---|
| expected | The product working as designed: a refusal the customer can act on | no | no |
| failure | We failed the customer | yes | yes |
| caller_defect | A bug in our own caller (front end, partner integration) | yes | to the owning team |
| ambiguous | The same code means different things in different contexts; needs a split | yes, until split | review |
| unknown | Not yet classified | yes | review |

## Codes by function

| Function | Code or condition | HTTP status | Class | Customer sees | Confirmed by |
|---|---|---|---|---|---|
| <J1.1> | <INVALID_CREDENTIALS> | <200 / 401> | expected | <"wrong password"> | <code path, date> |

## Gaps found

| # | Gap | Effect | Fix |
|---|---|---|---|
| <codes returned inside HTTP 200 without an error class> | | | |

## Still to confirm

| Code | Question | Owner | Due |
|---|---|---|---|
