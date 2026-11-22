# Interview guide: SRE rows

When the type is SRE, these rows are added to the [core interview guide](../../templates/interview-guide.md);
its format, length and ledger rules apply. Where the intake questionnaire has no section for a
topic, the [SRE maturity dimension](../maturity-model.md) the row scores is named instead. "S"
rows are the [SRE data request](data-request.md)'s.

| Interviewee | Questionnaire sections it covers | Ask | Exports to ask for |
|---|---|---|---|
| On-call engineer | C 17; dimension 5 | Show last month's pages: how many per shift, how many off hours, which woke you for nothing? How is a shift handed over, and who is your backup? What was changed after the last bad week? | Paging export and rotation (S3) |
| Release or platform engineer | D 25; dimension 6 | Walk me through the last deploy of a tier-1 service, from merge to production. Show the last rollback: who decided, how long did it take? Which deploys were unplanned fixes of a production issue? | Deploy history and rollout configuration (S4) |
| Incident or problem manager | C 16, 19; dimension 4 | Open the last major incident: who declared it, which roles were filled, when was it detected and by whom? Show its review and the state of its action items. Which cause has come back? | Incident export (S1); postmortems and action items (S2) |
| Data store owner, per tier-1 store | Dimension 9 | What are the RPO and RTO, and who agreed them? Show the last restore test: what was restored, how long did it take, did it work? What would you do if the region or account were lost? | Backup history and restore records (S6) |
| Capacity owner (platform) | Dimension 8 | Which tier-1 service runs out first at peak, and how would you know? Show the quotas closest to their limit. When was the last load test, and what changed because of it? | Capacity metrics and quotas (S7); load-test reports (S8) |
| Engineering manager or service owner | Dimensions 1, 10 | Who owns each tier-1 service, and where is that written? Which manual task does the team repeat every week, and how much time does it take? How did the last new tier-1 service go live? | Service list with owners; readiness checklist; toil tickets or time tracking |
