# Error taxonomy

*Spec-set skeleton for `error-taxonomy.md`. What each outcome means. Every code or condition gets exactly one class; unknown counts as bad until it is classified.*

## Classes

| Class | Meaning | Counts against the SLI | What follows |
|---|---|---|---|
| expected | The product working as designed: a refusal the customer can act on | per SLI — see `slo-alerts.md` | nothing |
| failure | We failed the customer, and we know the operation did not take effect | yes | alert |
| caller_defect | A bug in our own caller (front end, partner integration) | yes | to the owning team |
| ambiguous | The outcome of the business operation is not known: it may or may not have taken effect (timeout after the request was sent, lost response, no confirmation) | yes, until reconciled | reconciliation; the runbook's "unknown state" section |
| unknown | The code or condition is not classified yet | yes | classify |

**Ambiguous is about the outcome, not about the code.** A code that means different things in
different contexts (an *overloaded* code) is not a class: classify it by context — by an
attribute, by the calling function, or by splitting the code. Until that is done it stays
`unknown` and is listed under "Gaps found".

## Codes by function

| Function | Code or condition | HTTP status | Context | Class | Customer sees | Confirmed by |
|---|---|---|---|---|---|---|
| [J1.1] | [INVALID_CREDENTIALS] | [200 or 401] | [any] | expected | ["wrong password"] | [code path, date] |
| [J1.2] | [timeout from the downstream after the request was sent] | [504] | [write operation] | ambiguous | [error page] | [code path, date] |

## Gaps found

| # | Gap | Effect | Fix |
|---|---|---|---|
| [1] | [refusals returned inside HTTP 200 without an error class] | [failures invisible to status-based alerts] | [outcome and error_class on every response] |
| [2] | [overloaded code: one code for a refusal and for a timeout] | [cannot be classified; counted as unknown] | [split the code or add a reason attribute] |

## Still to confirm

| Code | Question | Owner | Due |
|---|---|---|---|
