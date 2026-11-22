# Interview guide

For the interviews in the [calendar](../method/getting-started.md#3-calendar)'s weeks. The intake questionnaire is
sent before; an interview does not re-ask it. It checks the written answers against the
interviewee's own screen and asks for what a form cannot: a walk-through, the last real case,
the export behind a number. 45–60 minutes; ask to share the screen. SRE type: add the rows of
[sre/templates/interview-guide.md](../sre/templates/interview-guide.md).

| Interviewee | Questionnaire sections it covers | Ask | Exports to ask for |
|---|---|---|---|
| Monitoring tool owner | B, G; C 13–14 | Walk me through the last alert that paged, from the rule to the person, in the tool. Which part of the estate do you not trust, and why? What changed in the last three months: agents, rules, licence? | Estate by object class (`tools/collect.md`); consumption report |
| Platform | B 10–11, E, G (pipeline, cloud) | Show how telemetry leaves a host or a cluster and what is dropped on the way. Open the bill: which lines are monitoring, and which grew last quarter? | Pipeline and collector configuration; retention settings; billing export (data request row 12) |
| On-call (SRE / NOC) | C | Take the last three pages: was each one actionable, and what did you open first? Which alert do you ignore? When did a customer tell you before an alert did? | Ticket history; rota and escalation; incident timelines |
| Product | A, F | Describe one customer's attempt at each journey in your own words. Show a failed attempt and a refused one: how would a dashboard tell them apart? Which number do you look at first on a Monday? | Business dashboards and KPIs; journey model; contract SLAs |
| Developer, per tier-1 service | D | Show in the code where a business refusal is returned. Follow one request id from the browser to the downstream call in the logs. What happens on a downstream timeout? How do you know a release broke something? | Error code list; API contracts; a log line with the correlation id; repository access |

## How answers enter the ledger

- Every answer is a facts-ledger row with status *assumption*, source "interview, [role],
  [date]". It becomes *confirmed* only when an export, the code (file:line) or a check in the
  tool shows it, and *refuted* when the evidence shows otherwise.
- An export promised in the interview becomes a data request row with a provider and a week.
- A question nobody in the room could answer goes to `owner-questions.md`, with an owner.
- Who rules on what is in the [roles table](../method/records.md#roles); an interviewee's view is not a verdict.
