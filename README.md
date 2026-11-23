# Observability Assessment Kit

| Author | Version | Licence |
|---|---|---|
| Ivan Bogomazov · [bogomazov.us](https://bogomazov.us) | 0.15.5 | [CC BY 4.0](./LICENSE) · code [Apache 2.0](./LICENSE-CODE) |

An open kit for finding out what your monitoring and your reliability practice actually do, and
what to fix first. Two assessment types, observability and SRE, on one method:

- **Observability assessment.** Does each business function (sign-in, search, checkout) tell you
  when it fails for a customer, and who is told? 12 dimensions.
- **SRE assessment.** Do your services stay reliable, and how do they recover when they do not?
  SLOs and error budgets, incidents, on-call, change safety, resilience, capacity, backup and
  recovery. 10 dimensions.

Each runs in 2 to 3 weeks (focused) or 6 weeks (full), alone or combined. AI agents can do the
reading on read-only access; a person confirms every stage.

**[Download the kit as one PDF](https://github.com/bogomazov-us/observability-assessment/releases/latest/download/observability-assessment-kit.pdf)**
· [what changed](./CHANGELOG.md)

## Who it is for

| You are | Start with | You get |
|---|---|---|
| An engineering leader who wants to know where the next outage hides | [Worked example](./example/worked-example.md), then [offerings](./offerings.md) | What an assessment finds, what it costs your people, what you hold at the end |
| A lead or consultant who runs assessments | [Getting started](./method/getting-started.md), then the [playbook](./method/playbook.md) | The method week by week, templates from intake to acceptance, review checklists |
| An SRE or platform team checking itself | [SRE assessment](./sre/README.md) and its [maturity model](./sre/maturity-model.md) | A profile per dimension with the evidence each level needs |
| Someone running it with an AI agent | [Agent setup](./tools/agent/setup.md) | Prompts for six stages, gates that stop the next stage until a person confirms |

## What a finding looks like

From the kit's fictional example, an online grocer:

> **Payment timeouts are reported to the customer and to monitoring as card declines.**
> When the payment provider is slow, checkout retries twice and then returns "declined". In the
> week read, 4 % of declines were really timeouts, 9 % on the Monday. Customers are told their
> card was declined while money may be held, and the dashboard stays green.
> *Evidence:* the code path and a span query, re-run a week later. *Next:* ask the provider for
> the status after a timeout and alert on failed and unknown attempts. *Owner:* checkout tech lead.

Every finding has a source, a date, a severity, an owner and a test that closes it.

## What is different

1. **Diagnosis per business function, not outcome counting.** Journey, function, signal, SLI,
   threshold, owner. A red light comes with an address.
2. **Evidence before opinion.** Every "present" is proven in the tool (an export, a query, a
   trace), not taken from a slide. Facts carry a status and a date.
3. **Code and tooling are read, not only interviewed.** Week one reads the code, the delivery
   pipeline and the monitoring estate.
4. **The output can be built.** A profile, not one score; a roadmap with milestones, effort and
   acceptance evidence; a hand-over of what is still open.
5. **Agents draft, people confirm.** AI agents on read-only access do the inventory and the
   checks; each claim cites its source, and a gate refuses the next stage until a person signs.

## Three ways to use it

1. **Read it.** [The PDF](https://github.com/bogomazov-us/observability-assessment/releases/latest/download/observability-assessment-kit.pdf)
   holds the whole kit in eight parts, with both worked examples.
2. **Run an assessment yourself.** Copy the templates, follow [getting started](./method/getting-started.md),
   check your records with the [tools](./tools/).
3. **Run it with an agent.** Set up an engagement repository with [the agent route](./tools/agent/setup.md)
   and run the six stages, inventory to recommendations.

To have it run for you: [bogomazov.us/observability](https://bogomazov.us/observability).

## Map

The PDF follows the same parts.

| Part | Start here | What is in it |
|---|---|---|
| Getting started | [getting-started.md](./method/getting-started.md) | The first assessment: what to copy, fill and hold; [offerings](./offerings.md) and [estimation](./method/estimation.md) |
| Method | [playbook.md](./method/playbook.md) | The steps with their weeks; [records](./method/records.md), [report](./method/report.md), [lessons](./method/lessons.md), [agents and people](./method/agent-harness.md) |
| Observability assessment | [maturity-model.md](./method/maturity-model.md) | 12 dimensions × 5 levels; the [worked example](./example/worked-example.md); the [specification set](./templates/spec-set/README.md) an assessment leaves behind |
| SRE assessment | [sre/README.md](./sre/README.md) | Formats, calendar, estimation; the [10-dimension model](./sre/maturity-model.md); its worked example and templates |
| Agent route | [tools/agent/](./tools/agent/) | The stage prompts, the rules every stage shares, [setup and paths](./tools/agent/setup.md) |
| Tools | [tools/](./tools/) | Code scan and estate export, spec linter, maturity calculator, baseline numbers, the stage gate, report PDF |
| Templates | [templates/](./templates/) | Intake questionnaire to acceptance record: data request, interview guide, finding, report, roadmap, statement of work, review checklists |
| Practice | [practice/](./practice/) | Building a practice around the kit, the pilot for a new lead; [backlog](./backlog.md) |

## Releases

Each tagged release (`vX.Y.Z`) publishes the whole kit as one PDF on the
[releases page](../../releases); the newest is always at
[releases/latest/download/observability-assessment-kit.pdf](https://github.com/bogomazov-us/observability-assessment/releases/latest/download/observability-assessment-kit.pdf).
What changed in each release: [CHANGELOG.md](./CHANGELOG.md). Contributions: see
[CONTRIBUTING.md](./CONTRIBUTING.md).

## Licence

Two licences, by kind of file:

- **Text**: every Markdown file, the templates (including their YAML) and the worked examples:
  [CC BY 4.0](./LICENSE).
- **Code**: the `.py`, `.sh`, `.pl` and `.css` files and the test fixtures under `tools/` and
  `scripts/`: [Apache 2.0](./LICENSE-CODE). Each code file carries an
  `SPDX-License-Identifier: Apache-2.0` line.

Releases up to 0.9.0 were published under CC BY 4.0 alone and stay available under it.

## Author

Ivan Bogomazov runs observability and SRE assessments: [bogomazov.us](https://bogomazov.us)
· [LinkedIn](https://www.linkedin.com/in/ivan-bogomazov/).
