# Pilot — the first assessment led by someone else

The kit is meant to let a new lead run an assessment under review once, and then alone. The
pilot tests that claim on a real, bounded engagement and turns every gap it finds into kit
work. Run it once per new lead until a pilot ends without a blocking gap.

## Shape

| | |
|---|---|
| Format | Focused assessment, inside its limits ([offerings.md](../offerings.md)) |
| Lead | The pilot lead: accountable to the client, writes the report |
| Reviewer | The kit's author or a lead who has run one alone; reviews in rounds with [review.md](../templates/review.md), does not take over |
| Engineer | As in the format; may be the reviewer's usual engineer |
| Estimate | From [estimation.md](../method/estimation.md), with the "new lead" contingency |

## Before day one

1. The pilot lead reads, in order: [getting-started.md](../method/getting-started.md), the
   [worked example](../example/worked-example.md), [lessons.md](../method/lessons.md).
2. Agree with the reviewer the review points: findings preview (week 2), draft report, final
   report. Nothing else is reviewed unless the pilot lead asks.
3. Open the two logs below in the engagement repository.

## Help log

Every time the pilot lead asks the reviewer anything, or stops because the kit did not say what
to do, one row. A question answered from the kit without help is not logged.

| # | Date | Step (playbook #) | Question or stop | Answered by | What the kit lacked | Kit action |
|---|---|---|---|---|---|---|
| H1 | YYYY-MM-DD | [5 Score maturity] | [how to score a dimension where only one of three functions has evidence] | reviewer, in chat | [rule existed but no example] | [backlog item / edit to file] |

*What the kit lacked*, one of: missing (the kit is silent), unclear (it says it but it was not
understood), wrong (following it gave a bad result), template (a template did not fit the
situation). *Kit action* is filled by the reviewer within a week.

## Actuals log

Days per role and phase, recorded weekly, next to the estimate. This is what calibrates the
estimation model.

| Phase | Role | Estimated days | Actual days | Why the difference |
|---|---|--:|--:|---|
| [Inventory] | [Obs. engineer] | [3] | [4.5] | [tenant export needed a second access request] |

## Review results

Keep each round record. At the end, count: rounds per deliverable, blocking items per round,
blocking items by checklist section. A section that collects blocking items in every pilot is a
gap in the method, not in the lead.

## Done when

The pilot ends with the client's report accepted, and four answers written down:

1. **Could the pilot lead run the next one alone?** Yes / yes with review of the report only /
   not yet, and why.
2. **Help log:** number of rows by kind; every row has a kit action, done or in the backlog.
3. **Actuals vs estimate** per role; the estimation model updated if a role differs by more
   than 20 %.
4. **Kit release** with the changes the pilot produced, and its version noted in the pilot's
   record.

## What the pilot is not

Not a training course (the pilot lead learns by doing, the reviewer does not lecture), and not
a way to staff an engagement with the reviewer's time: if the reviewer is writing the report,
the pilot has failed and the help log says where.
