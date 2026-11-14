# Kit backlog

| # | Item | Why | Priority |
|---|---|---|---|
| 1 | ~~Neutral worked example~~ — done in 0.2.1: `example/worked-example.md` (fictional) | New leads learn from an example faster than from templates | done |
| 2 | ~~Spec-set file skeletons~~ — done in 0.2.1: `templates/spec-set/` | Today only the README table exists | done |
| 3 | ~~Estimation model per offering~~ — done in 0.3.0: `method/estimation.md` (starting values; calibrate after the pilot) | Sales cannot price without the authors | done |
| 4 | ~~Stack-agnostic collection~~ — code scan by class and estate export by object class; code scan used on a first real codebase and tuned. Open: the estate export on a client's tool | Week-one speed | low |
| 5 | ~~SOW / acceptance template for each offering~~ — done: `templates/sow.md`, `templates/acceptance.md` | Contracting | done |
| 6 | ~~Privacy and PII checklist for telemetry~~ — done: `templates/privacy-checklist.md` | Recurring blocker | done |
| 7 | ~~Boundary checklist for the client's own AI-ops tools~~ — done: `templates/ai-ops-boundary.md` | Avoid competing with what the client built | done |
| 8 | ~~Agentic harness spec~~ — done in 0.3.0: `method/agent-harness.md`; all six stages packaged as prompts since 0.6.1 (`tools/agent/`), with progress logs and a scratch directory. Open: the second engagement. The first ran all six stages with reviews and is measured: findings accepted without change of substance well below 70 % on those with a verdict; person hours not recorded (`method/agent-harness.md`, Status) | Differentiator | medium |
| 9 | ~~Executive deck template for the report~~ — done: `templates/executive-deck.md` | Most buyers read slides | done |
| 10 | ~~Question bank by tool class~~ — done: intake questionnaire section G | Current questions lean on one class of tool | done |
| 11 | ~~Machine-readable spec set and linter~~ — done in 0.3.0: `tools/speclint.py`, `templates/spec-set/observability-spec.yml` | A broken chain is found before a reviewer reads a page | done |
| 12 | ~~Maturity calculator~~ — done in 0.3.0: `tools/maturity.py`, `templates/maturity.yml` | Scoring rules enforced, profile printed, no average | done |
| 13 | ~~Stage reports in two levels~~ — done in 0.7.0: `templates/stage-report.md`, `tools/report-pdf.sh` (one export, id and evidence-catalog checks, wide tables landscape) | Reviewers rebuilt the current state from history and wide tables | done |
| 14 | Stage prompts in two tiers — each stage stays a prompt a person starts; the discipline shared by all stages (progress log, claims within what was checked, citing evidence, owner questions, common boundaries) moves into rule files the stages name instead of copying. Optional thin wrappers let agent tools that load skills start a stage by name | The progress-log section is copied into all six prompts; the claim wording rules are written in stages 1 and 3 and named by none of the others, though they apply at every stage | medium |
| 15 | Stage gate in a file — an engagement state file holds each stage's status (draft, handed over, confirmed), who confirmed it, the date and the decision-register reference; a tool refuses to start stage N unless stage N−1 is confirmed; a review appends a dated block and never changes a status | The gate is text today: a stage started on unconfirmed input is found only when a reviewer reads it | medium |
| 16 | Owner questions as an asynchronous questionnaire — the agent gathers the open questions of a stage with candidate answers marked as candidates; the owner answers in writing; each answer goes into the decision register with its date before any document cites it. Covers the intake and the verdict batch after stage 4 | Answers given in working sessions are hard to find later, and a relayed approval cannot be checked | low |
| 17 | Engagement glossary checked by the linter — names of journeys, functions, signals and SLIs are fixed once, while interviewing, and `tools/speclint.py` reports a name in the spec set that the glossary lacks | A renamed function breaks the chain from journey to owner without any check failing | low |
