# Commitment baseline

Write before implementation starts; agree with the account lead first, then the client. Every
line is demonstrable; what is not here is a change of scope.

| # | Deliverable | Measure (demonstrated at go-live) |
|---|---|---|
| 1 | Catalog of owner/customer journeys, signed off | N tier-1 journeys, each with SLIs and acceptance criteria |
| 2 | Real-user monitoring on the front end; error adapter; source maps | RUM live on all environments |
| 3 | Named business events on every critical step | ~N events visible in the tool, mapped to analytics events |
| 4 | End-to-end trace front end → services → downstream call | ≥95% of API calls linked to a browser action |
| 5 | Continuous synthetic monitoring | N monitors 24/7, two locations |
| 6 | Journey dashboard with baselines and control limits | ~N metrics with control limits |
| 7 | Alerts in shadow, each with an owner and a playbook | N critical alerts; paging after tuning on live traffic |
| 8 | Release check | 100% of releases checked for their signals; observability section in every story |

**Targets after go-live (next quarter):** ≥80% of alerts actionable; a broken critical step
detected within N minutes.

**Not promised:** live paging at go-live; a percentage MTTR reduction without a baseline;
automatic remediation.
