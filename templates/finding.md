# F-NNN · [one-line finding]

| Status | Date | Source | Evidence level |
|---|---|---|---|
| assumption / confirmed / disputed / refuted | YYYY-MM-DD | code path, query, export, interview | browser / agent / tenant / document only |

**Severity:** P1 / P2 / P3 on the scale below, and why. · **Decision:** proposed / accepted /
superseded · **Implementation:** absent / partial / implemented · **Verification:** untested /
observed / reproduced.

**What we see.** Facts only, each with its evidence id (`E-NNN` in the evidence catalog: source,
window, method, result, limits).

**Confidence and limits.** High, medium or low, and what the evidence does not establish.

**Why it matters.** The customer or business consequence: what fails silently, what is
mis-measured, who is not told.

**What follows.** The action, its owner, and which maturity dimension it moves.

**Closing criterion.** The observable result that closes the finding.

**Links.** Related findings, decisions, risks.

## Severity scale

| Severity | When |
|---|---|
| P1 | A user-facing failure of a function in scope can go undetected or unreported; or a detection or notification path is shown not to work; or a write can be reported wrongly, putting data integrity at risk |
| P2 | Detection or measurement is wrong, partial or unproven for a function in scope; or a condition required before paging (owner, acknowledgement, escalation, runbook) is missing |
| P3 | Diagnosis is slower or harder, or a document or setting is stale; detection itself is not lost |

- Severity is set by what happens when the defect meets a failure, not by whether that has been
  seen in production: no case seen does not show the path is safe.
- It is the finding's severity, not a production incident and not the paging severity of an
  alert. Confidence in the evidence, implementation priority (urgency, effort) and paging
  priority are separate fields.
- A finding whose cause or impact is not established is marked *provisional*. Linked findings
  are assessed together, so one risk is not counted twice.
- The agent proposes severity; the person sets it, and a change is recorded with its reason.

---

# ADR-NNN · [decision]

**Status:** proposed / accepted / superseded by ADR-MMM · **Date:** YYYY-MM-DD

**Context.** What forced the decision.

**Decision.** One paragraph.

**Alternatives.** What else was considered and why not.

**Consequences.** What becomes easier, what becomes harder, what we must now do.
