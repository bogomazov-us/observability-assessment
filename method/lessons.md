# Lessons and anti-patterns

Each lesson cost us time once on a real engagement.

| # | Lesson | What goes wrong otherwise |
|---|---|---|
| 1 | Counting outcomes is not diagnosis | Dashboards show "booking down" with no address; teams argue about where |
| 2 | Never alert on a pooled rate or a host | One noisy endpoint hides a dead one; host alerts page nobody useful |
| 3 | HTTP 200 can carry an error; half of refusals are the product working | Error rate looks perfect while bookings fail; or alerts fire on wrong passwords |
| 4 | No playbook, no alert; every alert has an owner and a sample rule | Alert fatigue; the rare high-stakes event (unknown booking result) is lost — that one gets no minimum sample |
| 5 | Rates move with the denominator; tools disagree for a reason | Two tools "disagree" because one counts sessions, the other failures; sampling and retention limit what an SLI can use |
| 6 | Check the metric an alert is built on | Critical alerts built on a deprecated, ~3× noisy metric were disabled and nobody noticed the gap |
| 7 | "Present" requires evidence | Inventories are wrong; similar-looking data came from an old front end; a board goes green on a blind spot |
| 8 | Build on the client's own investigation | The assessment is seen as a repeat of a tiger team or an internal tool |
| 9 | Deliver the format the buyer asked for | A comprehensive strategy where a scrappy MVP was requested → an unhappy executive |
| 10 | Treat leaked or informal material as intelligence, not proof | Conclusions rest on a document nobody will stand behind |
| 11 | Sanitize HAR captures before committing | A raw HAR contains session tokens and personal data; steps in `templates/privacy-checklist.md` |
| 12 | Ask for exports, not opinions | Interviews give confident, wrong answers ("we have tracing") |
| 13 | Ask how "non-actionable" is measured | Clients state alert-noise targets they do not measure |
| 14 | Monitoring config ships with the component | Monitoring drifts from topology after blue/green or DR changes |
| 15 | Observability shows up as a cross-cutting finding in other assessments | Performance or resilience work stalls on missing baselines; sell observability as the enabler |
| 16 | Monitoring sections in migration questionnaires are too thin | Three questions about monitoring cannot size the work; use the intake questionnaire |
| 17 | Separate technical readiness from switching users on and from live paging | A single go-live date hides three decisions and three owners |
| 18 | Approve a spec for implementation, then accept on evidence | Endless document rounds; or sign-off on text that was never run |
