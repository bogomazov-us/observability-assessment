# F-NNN · [one-line finding]

| Status | Date | Source | Evidence level |
|---|---|---|---|
| assumption / confirmed / disputed / refuted / inconclusive / resolved | YYYY-MM-DD | code path, query, export, interview | browser / agent / tenant / document only |

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

## Verdicts

A drafted finding is an *assumption*. After a re-check its owner gives it one of five verdicts:

| Verdict | When |
|---|---|
| confirmed | The evidence, re-run, shows the claim as bounded |
| disputed | The evidence does not settle it, and someone holds another reading; the reason is written |
| refuted | The evidence shows the claim is wrong for the window and scope it names |
| inconclusive | The check could not be made: too little data, history expired, the configuration changed since |
| resolved | The claim was true in its window and has since been fixed; the fix is cited |

- **Bound the claim before the verdict.** It names its window and its scope, and says "not
  shown" rather than "none exists". A cause is bounded to the window read. An absence read in
  part of the estate says so ("other accounts not checked").
- **Did not reproduce is not refuted.** Insufficient data, expired history or a changed
  configuration give *inconclusive* or *disputed*; true then and fixed since gives *resolved*.
- **A decision record is not technical evidence.** A record that adopted a reading shows the
  decision, not the system; cite the code and its version, or a query.
- **Confirmed is about the claim only.** It does not mean the fix is implemented, or that any
  alert passed the paging gate; those are the separate statuses above.
- **An anomaly seen during a re-check** that nothing explains is recorded as an observation of
  unknown cause, not as a new finding.
- **Verdicts are the owner's.** A reviewer's reading of the evidence is a recommendation. A
  re-check is read-only, is recorded as evidence with its own `E-` id, and sets no verdict by
  itself.

---

# ADR-NNN · [decision]

**Status:** proposed / accepted / superseded by ADR-MMM · **Date:** YYYY-MM-DD

**Context.** What forced the decision.

**Decision.** One paragraph.

**Alternatives.** What else was considered and why not.

**Consequences.** What becomes easier, what becomes harder, what we must now do.
