# Changelog

What changed in each release, for someone who used the previous one. The release notes on
GitHub are taken from the section of the tagged version.

## Unreleased

- `scripts/sync-denylist.sh`: the denylist lives in a private file outside the repository; the
  script puts it into the CI secret and the local git-ignored copy, and refuses an empty list.
- **From the review of the first real stage 1:**
  - Stage 1 packaged as a prompt (`tools/agent/stage-1-inventory.md`): one status per object
    (confirmed, differs, not found, not verifiable) whose counts sum to the rows; claims stay
    within what was checked (window and place; evaluation is not detection; absence is not a
    defect; an OK by the missing-data setting says so; totals are not attributions; a difference
    is not a cause); confirmed blind spots go to the risk register at once.
  - Harness measurement: first engagements are pilot measurements; agent time is not compared
    with the estimate's person-days; a re-run sample is "n of n selected checks reproduced",
    not an accuracy estimate.
  - Spec: each function names its `requirement` (SL017, warning) and keeps its `current` state
    with inventory evidence apart from the target; SLOs and alerts carry `status` proposed or
    confirmed, and paging needs both confirmed (SL018). The linter says a clean run is
    structural only. Stage 2 prompt and review checklists follow.
- **From the first run of stages 1 and 2:** inventory rows carry stable ids (`L-01`) that later
  stages cite instead of line numbers; an agent never decides a question addressed to the owner
  and reads only the paths its prompt lists; stage 2 starts by reconciling the sources of
  requirements with the owner; assessment work runs on its own branch from the first stage;
  person hours are recorded per stage, and a change of granularity is counted apart from
  errors. Spec linter: unknown keys are reported (SL019), an engagement's own field is
  prefixed `x_`.

## 0.5.0 — 2026-10-21

- Each release also carries the PDF under a fixed name, so
  `releases/latest/download/observability-assessment-kit.pdf` always serves the newest one.
- Release notes come from this file.
- **Staffing: the lead is full time; the engineer and the architect join by scope.** The
  capacity check adds roles in order (lead alone → with an engineer → with an architect) only
  when the days do not fit; offerings and getting started say the same.
- **Statement of work and acceptance record** (`templates/sow.md`, `templates/acceptance.md`):
  one SOW skeleton for the four formats — scope in units, client obligations, change control by
  the increments table, staffing — and a per-deliverable acceptance record with evidence, known
  limitations, go / no-go and hypercare BAU readiness.
- **Privacy checklist** (`templates/privacy-checklist.md`): personal data in telemetry — what to
  ask and check in week one, rules for the instrumentation contract, HAR sanitisation, the
  team's own data, red flags; scores maturity dimension 11.
- **AI-ops boundary checklist** (`templates/ai-ops-boundary.md`): what the client's anomaly
  detection and assisted investigation already decide, where the assessment builds on it, one
  condition pages once; scores dimension 12.
- **Agent stages packaged** (`tools/agent/`): task prompts for harness stages 2, 4 and 6, each
  with boundaries, inputs, an output contract, a self-check and what the person confirms.
  Tool- and model-agnostic.
- **Executive deck skeleton** (`templates/executive-deck.md`): thirteen slides for the read-out,
  each title a claim, maturity as a profile, the decision request last.
- **Intake by tool class:** section G of the intake questionnaire (questions 32–54) for APM
  suites, metrics-and-logs stacks, OpenTelemetry pipelines, cloud provider monitoring and
  estates with several tools.
- **Code scan, after its first use on a real codebase:** hits counted apart in code, tests and
  docs; generated files and files above 512 KB skipped (a scan that took minutes on data
  directories now takes seconds); the retry class matches calls and settings, not the word in
  labels and prose (about 60 % fewer leads, none lost that mattered).

## 0.4.0 — 2026-10-21

- **Tool-agnostic collection.** The kit names classes of capability and of configuration
  object, never a product. The code scan's built-in patterns are vendor-neutral; a tool's own
  signatures come from a file in the engagement repository (`--signatures`). The vendor
  exporters of 0.3.0 are replaced by an estate export by object class that works for any
  monitoring tool (`tools/collect.md`).
- **Maturity: level 1 needs evidence too** — the export or query that came back empty. A level
  nobody looked for is *not scored*. The maturity calculator enforces it (M07).
- **Alert ownership is decided with the client**, by maturity and organisation (service team,
  platform SRE or operations centre); until then the alert stays in shadow. The worked example
  leaves it open.
- **Lead at most half time** in every format. The capacity check now shows the lead over the
  calendar in the full assessment; how that is covered is open.

## 0.3.0 — 2026-10-21

- **Estimation model** (`method/estimation.md`): person-days by role and phase per format,
  increments per journey, service, tool and review round, a capacity check, contingency for our
  own risks. Starting values, to be calibrated after the pilot.
- **Review rounds and checklists** (`templates/review.md`): a round record with verdicts and a
  checklist per deliverable.
- **Pilot protocol** (`practice/pilot.md`): the first assessment led by someone new, with a help
  log, an actuals log and four exit answers.
- **Tools:** spec linter (`tools/speclint.py`, with `observability-spec.yml`), maturity
  calculator (`tools/maturity.py`, with `templates/maturity.yml`), a week-one code scan and two
  vendor exporters (replaced in 0.4.0).
- **Agent harness** (`method/agent-harness.md`): agents draft, people confirm; inputs → model →
  gap → recommendations, the release check, and when the harness may be relied on.
- Worked example: the C1 event the attempt model needs (four events in M2). Error taxonomy:
  class `none` for a condition that looked like an error but the operation took effect.
- Python allowed in the kit; tool tests run in CI and on release.

## 0.2.2 — 2026-10-21

- Offerings: starting scope limits per format; 4 weeks of hypercare, closed at 80 % actionable
  P1 firings; 5 client developer days for the golden-journey proof.
- Worked example: an unclassified code gives an unclassified attempt — bad, but kept apart from
  ambiguous; reconciliation reads the slot hold too and releases orphan holds.
- SLO skeleton: a caller defect pages when it blocks customers at P1 scale; routing by impact,
  not by class.
- Build: other editions can hold the kit as a submodule and build with `--config`.

## 0.2.1 — 2026-10-21

0.2.0 was reviewed as two different local builds and never released; 0.2.1 carries it.

- **Getting started**, a **fictional worked example** from request to acceptance, and
  **skeletons for the nine spec-set documents**. The engagement knowledge base is optional.
  "Scrappy" assessment renamed *focused*.
- Error taxonomy: *ambiguous* means the business outcome is unknown and needs reconciliation;
  an overloaded code is a gap, classified by context.
- SLO rules: valid and good decided per SLI; one bad predicate per SLI.
- Maturity model: capability, not technology; the score is the highest fully evidenced level;
  partial, not scored, N/A and confidence defined; no overall average; dimension 12 optional.
- Offerings: the golden-journey proof needs stage access and a client developer; the end of
  paid hypercare is not BAU acceptance.
- CI: pull requests from forks run the public checks; the PDF is checked on every build.

## 0.1.0 — 2026-10-21

First public release: method, maturity model, lessons, templates and the practice guide; PDF
build, guardrails and release pipeline.
