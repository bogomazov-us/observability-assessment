# Statement of work — skeleton

One skeleton for the four formats in [offerings.md](../offerings.md). Keep the section for the
format sold, delete the others. Implementation and hypercare are **two lines in one contract**,
each with its own acceptance. Every number below comes from the offerings and from
[estimation.md](../method/estimation.md); a number changed here is changed there first.

## 1. Parties and purpose

| | |
|---|---|
| Client | [legal name], represented by [sponsor role] |
| Supplier | [legal name], represented by [lead] |
| Purpose | [the buyer's question, in their words: "where are we blind, and what do we fix first?"] |
| Format | Focused assessment / Full assessment / Blueprint / Implementation + hypercare |
| Start, end | [date], [date] |

## 2. Scope in units

The fee covers the scope below and nothing larger. Fill the "Agreed" column; it may be smaller
than the limit, never larger.

| Unit | Focused | Full | Blueprint | Implementation | Agreed |
|---|---|---|---|---|---|
| Critical journeys | up to 3 | up to 5 | as assessed, up to 5 | as in the Blueprint | [n, named] |
| Services / applications | up to 5 | up to 10 | up to 10 | up to 10 | [n, named] |
| Monitoring tools | 1 | up to 2 | up to 2 | up to 2 | [n, by class] |
| Environments | production, read-only | stage, production | stage, production | stage, production | [list] |
| Review rounds | 1 | 2 | 2 | — | [n] |
| Duration | 2–3 weeks | 6 weeks | 3–4 weeks | 6–10 weeks + 4 weeks hypercare | [weeks] |

## 3. Deliverables and their acceptance

| Format | Deliverable | Accepted when |
|---|---|---|
| Assessment | Current → future → gap → plan; maturity profile; prioritised findings with evidence; 30/60/90 plan; decision request | Report accepted after the review rounds, and the next-step decision taken |
| Full assessment, additionally | Golden-journey proof on stage (only with the obligations in section 4) | Demonstrated, or delivered as a design and checklist when the obligations were not met |
| Blueprint | Specification set (journeys, error taxonomy, signals, SLOs and alerts, instrumentation contract, synthetics, dashboards, runbooks); acceptance scenarios; milestone roadmap | Spec approved for implementation after the review rounds |
| Implementation | Working chain signals → calculations → alerts → response on stage and production; acceptance evidence | Acceptance evidence demonstrated and the go decision taken |
| Hypercare | Alerts tuned on live traffic; runbooks exercised; on-call handover | See section 9: the paid period ends at its date; BAU readiness is accepted separately |

Each acceptance is recorded with [acceptance.md](acceptance.md).

## 4. Client obligations

A missed obligation **moves the date, not the price downwards**. The lead records it the day
it is missed, with the new date, and tells the sponsor.

| Format | Obligation | By |
|---|---|---|
| Assessment | Read-only access to the monitoring tool, code and ticketing | day 3 |
| Assessment | 5–8 interviews held | end of week 2 |
| Assessment | Incident history for [period] | day 3 |
| Full assessment, golden-journey proof | Stage access with write rights to the monitoring configuration; one client developer for 5 days; the client owns the code change | week [n] |
| Blueprint | A product owner who signs the SLOs; tier-1 journeys agreed | start |
| Implementation | Back-end and front-end developers per the roadmap; platform access; a hypercare rota | per milestone |

## 5. Assumptions

Each assumption is also a row in the engagement's facts ledger, with status *assumption*.

- [The tool's read-only API, or an export by the client's administrator, covers the object
  classes in `tools/collect.md`.]
- [Effort as estimated in section 7, at the allocations stated there.]
- [Anything the estimate relies on that the client controls: sandbox, test users, licence
  headroom.]

## 6. Out of scope

- For the Assessment: the specification set; any change to code or monitoring.
- For the Blueprint: working signals — the spec says what to build, not that it works.
- For Implementation: hypercare (its own line); journeys beyond the Blueprint.
- For Hypercare: new scope; incident response as on-call.
- Always: auto-remediation; MTTR reduction promised without a baseline; tool migration.

## 7. Staffing and effort

The lead is accountable for the whole engagement and works on it full time. The other roles
join when the scope needs them; the capacity check in the estimation model says when. Each
person is named here.

| Role | Name | Allocation | Days (estimate) |
|---|---|---|---|
| Lead | [name] | full time | [from estimation.md] |
| Observability engineer | [name, or "not needed at this scope"] | [allocation] | [days] |
| Architect | [name, or "not needed at this scope"] | [allocation] | [days] |
| Contingency (our own risks only) | — | — | [days, with the risk it covers] |

## 8. Change control

Anything above a limit in section 2, a new journey, tool or environment, or an extra review
round is a **change request**. It is estimated with the increments table of the estimation
model (per journey, service, tool and review round), states its effect on date and fee, and
starts only when both parties sign it.

| CR | Change | Effort by role | Date effect | Fee effect | Signed |
|---|---|---|---|---|---|
| CR-1 | [one more journey] | [lead d, engineer d, architect d] | [+ days] | [amount] | [date] |

## 9. Timeline and milestones

| Milestone | Done when (demonstrated) | Accountable | Date |
|---|---|---|---|
| [Kick-off] | [goals, journeys in scope, access dates agreed] | [lead] | [date] |
| [Findings preview] | [no surprises in the report; disputes recorded] | [lead] | [date] |
| [Read-out / spec approval / go-no-go] | [as in section 3] | [lead] | [date] |

**Hypercare:** fixed period of 4 weeks from go-live; extension priced per week. BAU readiness
is accepted only when, over the last two weeks of production traffic, at least 80 % of P1
firings are actionable, every P1 alert has a runbook used at least once in a drill or an
incident, and the client's on-call owns the alerts. If the period ends first, the residual
risks are written down and the client decides: extend, or hand over with those risks.

## 10. Acceptance procedure

1. The supplier delivers with its evidence and a filled [acceptance.md](acceptance.md).
2. The client reviews within [n] working days and returns: accepted, accepted with known
   limitations, or rejected with the reasons.
3. A rejection names the criterion not met; the supplier fixes and resubmits once within the
   fee. Silence after [n] working days is [acceptance / an escalation to the sponsor].

## 11. Fees and payment

| Line | Basis | Amount | Invoiced |
|---|---|---|---|
| [Format] | fixed fee for the scope in section 2 | [amount] | [on acceptance / by milestone] |
| Hypercare extension | per week | [amount] | [weekly] |
| Change requests | per section 8 | [as signed] | [on acceptance] |

## 12. Confidentiality and data handling

- Telemetry, exports and captures may carry personal data. They are handled by the
  [privacy checklist](privacy-checklist.md): what is collected, where it is kept, how it is
  masked, when it is deleted.
- Access is read-only unless section 4 grants more; credentials stay with the client and in the
  environment of the person using them, never in a repository.
- Working material stays in the engagement's repository; nothing from this engagement goes into
  another client's deliverable.

## 13. Signatures

| Role | Name | Signature | Date |
|---|---|---|---|
| Client sponsor | [name] | | |
| Supplier lead | [name] | | |
