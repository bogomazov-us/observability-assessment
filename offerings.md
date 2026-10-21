# Offerings

Three formats. Each has fixed inputs, outputs and acceptance, so it can be estimated and staffed
without the authors.

| | **Assessment** | **Blueprint** | **Implementation + hypercare** |
|---|---|---|---|
| Question answered | Where are we, what hurts, what to do first? | What exactly do we build, and how do we know it works? | Build it, prove it on stage, run it through go-live |
| Duration | 2–3 weeks (focused) or 6 weeks (full) | 3–4 weeks after an assessment | 6–10 weeks to go-live, then hypercare for a fixed period |
| Inputs from the client | Access to code, monitoring tool (read-only), ticketing; 5–8 stakeholder interviews; incident history. Full format, golden-journey proof: stage access with write rights to the monitoring configuration, one client developer; the client owns the code change | Assessment outputs; product owner for SLOs; tier-1 journeys agreed | Back-end and front-end developers; platform access; hypercare rota |
| Outputs | Current → future → gap → plan; maturity score; top findings with evidence; 30/60/90 plan | Specification set (journeys, signals, error taxonomy, SLOs and alerts, instrumentation contract, synthetics, dashboards, runbooks); roadmap with milestones | Working signals, dashboards, shadow alerts with runbooks, release check; acceptance evidence |
| Done when | Report accepted; decisions on the next step taken | Spec approved for implementation after review rounds | Implementation: acceptance evidence demonstrated, go/no-go taken. Hypercare, closed separately: the paid period ends at its fixed date; BAU readiness is accepted only when the exit criteria are met (actionable share of P1 firings, runbooks exercised, client on-call owns the alerts). If the period ends first, the residual risks are written down and the client decides: extend, or hand over with those risks |
| Scope limits | Stated in every proposal: journeys, services, monitoring tools, environments, review rounds; beyond them is a change request | same | same |
| Roles | Lead + observability engineer (+ architect part-time) | Lead + architect + observability engineer | Observability engineer + architect + lead part-time; client developers |
| Templates | intake-questionnaire, data-request, finding, report | spec-set, roadmap, commitment-baseline | spec-set (living), roadmap cards |

## Full assessment, six weeks

Proven shape (sold as fixed fee):

1. **Align & baseline** — goals, stakeholders, access; maturity baseline.
2. **Observe & trace** — tenant and code inventory; journeys captured and decomposed.
3. **Diagnose** — per-function diagnosis; error taxonomy; gaps with evidence.
4. **Golden journey proof** — one journey instrumented end to end on stage, with the client's
   developer making the code change. Without stage access and a developer it is delivered as a
   design and a checklist, and the proposal says so.
5. **Operationalize** — alert, ownership and runbook model; release check.
6. **Executive roadmap** — roadmap, 30/60/90 plan, decision request.

## Focused assessment, two to three weeks

When the buyer asks for something fast: current → future → gap → plan on the top journeys, RAG
thresholds, severity tiers. Deliver the format the buyer asked for — a comprehensive strategy
where a scrappy MVP was requested is a failure, however good (see lessons).

## Not offered as part of these formats

Auto-remediation, MTTR reduction promises without a baseline, tool migration. These are separate,
priced as support or as their own project.
