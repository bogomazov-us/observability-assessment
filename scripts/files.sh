# SPDX-License-Identifier: Apache-2.0
# Order of the kit in the PDF. Every Markdown file except CONTRIBUTING.md and CHANGELOG.md must be listed here;
# the guardrails fail on an unlisted file. tools/tests/test_files.sh pins the order rules.
#
# Parts. An entry of the form
#   "PART: Title | One sentence on what the part is for."
# starts a part: scripts/build.sh numbers it (Part I, Part II, ...), sets its title and sentence on a
# page of its own, and files every chapter after it, up to the next part, under it in a two-level
# contents. A list with no PART entry builds flat, one contents level, as before parts existed.
# An edition config that sets its own KIT_FILES adopts parts by putting the same entries in its list;
# its chapters (relative or absolute paths) go between them unchanged.
KIT_FILES=(
  "PART: Getting started | What the kit is, how a first assessment starts, what is offered and how it is estimated."
  README.md
  method/getting-started.md
  offerings.md
  method/estimation.md

  "PART: Method | How an assessment is run, recorded and reported: the rules both assessment types share."
  method/playbook.md
  method/records.md
  method/report.md
  method/lessons.md
  method/agent-harness.md

  "PART: Observability assessment | The observability maturity model, a worked example and the specification set an assessment leaves behind."
  method/maturity-model.md
  example/worked-example.md
  example/agent/progress/stage-3.md
  example/agent/owner-questions.md
  example/agent/stage-3-gap.md
  example/agent/reviews/stage-3-round-1.md
  templates/spec-set/README.md
  templates/spec-set/spec-readme.md
  templates/spec-set/userjourneys.md
  templates/spec-set/signals.md
  templates/spec-set/error-taxonomy.md
  templates/spec-set/slo-alerts.md
  templates/spec-set/instrumentation-contract.md
  templates/spec-set/synthetics.md
  templates/spec-set/dashboards.md
  templates/spec-set/runbooks/function.md
  templates/golden-journey-proof.md

  "PART: SRE assessment | The SRE assessment: its scope and maturity model, a worked example and the templates only it uses."
  sre/README.md
  sre/maturity-model.md
  sre/example/worked-example.md
  sre/example/baseline.md
  sre/example/service-catalogue.md
  sre/example/reliability-targets.md
  sre/example/agent/progress/stage-1.md
  sre/example/agent/owner-questions.md
  sre/example/agent/reviews/stage-1-round-1.md
  sre/templates/service-catalogue.md
  sre/templates/reliability-targets.md
  sre/templates/readiness-review.md
  sre/templates/recovery-proof.md
  sre/templates/data-request.md
  sre/templates/interview-guide.md

  "PART: Agent route | The stage prompts an agent runs, the rules every stage shares, and each stage's reference."
  tools/agent/README.md
  tools/agent/setup.md
  tools/agent/rules/boundaries.md
  tools/agent/rules/evidence.md
  tools/agent/rules/claims.md
  tools/agent/rules/owner-questions.md
  tools/agent/rules/progress-log.md
  tools/agent/stage-1-inventory.md
  tools/agent/stage-2-target-model.md
  tools/agent/reference/stage-2-reference.md
  tools/agent/stage-3-gap.md
  tools/agent/reference/stage-3-reference.md
  tools/agent/stage-4-findings.md
  tools/agent/stage-5-maturity.md
  tools/agent/stage-6-recommendations.md
  sre/agent/stage-1-inventory.md
  sre/agent/reference/stage-1-reference.md
  sre/agent/stage-2-target-model.md
  sre/agent/reference/stage-2-reference.md
  sre/agent/stage-3-gap.md
  sre/agent/reference/stage-3-reference.md
  sre/agent/stage-4-findings.md
  sre/agent/reference/stage-4-reference.md
  sre/agent/stage-5-maturity.md
  sre/agent/reference/stage-5-reference.md
  sre/agent/stage-6-recommendations.md
  sre/agent/reference/stage-6-reference.md
  tools/agent/skills/README.md

  "PART: Tools | The scripts that collect, lint, score, compute and gate, and how to run each."
  tools/README.md
  tools/collect.md
  tools/speclint.md
  tools/maturity.md
  tools/baseline.md
  tools/stagegate.md
  tools/harness-metrics.md
  tools/recordcheck.md

  "PART: Templates | The documents of an engagement both assessment types use, in the order an engagement needs them."
  templates/intake-questionnaire.md
  templates/sow.md
  templates/kickoff-note.md
  templates/interview-guide.md
  templates/data-request.md
  templates/privacy-checklist.md
  templates/ai-ops-boundary.md
  templates/owner-questions.md
  templates/agent-instructions.md
  templates/stage-report.md
  templates/finding.md
  templates/adr.md
  templates/risk-register.md
  templates/review.md
  templates/report.md
  templates/executive-deck.md
  templates/roadmap.md
  templates/commitment-baseline.md
  templates/acceptance.md

  "PART: Practice | How the practice grows past one person, its pilot, and what the kit does next."
  practice/building-the-practice.md
  practice/pilot.md
  backlog.md
)
