# Observability Assessment — practice kit

| Author | Version | Licence |
|---|---|---|
| Ivan Bogomazov · [bogomazov.us](https://bogomazov.us) | 0.2.0 | [CC BY 4.0](./LICENSE) |

A reusable kit for running observability / SRE assessments without the original authors in the
room: the method, the templates, the offerings and the people model behind them.

## Why this exists

Most observability assessments end in a list of recommendations nobody can implement, or in a
dashboard that turns red without saying where. This kit is the method we use instead: diagnose
per business function, prove every claim in the tool, and finish with a specification and a
roadmap that a team can build and accept on evidence. It is written so that a new lead can run
an assessment with it, under review once, and then alone.

## What is different about our assessments

1. **Diagnosis per business function, not outcome counting.** We map journey → business function
   → signal → SLI → threshold → owner. A red light must come with an address.
2. **Evidence before opinion.** Every "present" is proven in the tool (export, query, trace), not
   taken from an inventory or a slide. Facts carry a status and a date.
3. **Code and tenant are read, not only interviewed.** Week one reads the code and exports the
   monitoring estate.
4. **The output is implementable.** An assessment ends in a specification and a roadmap with
   demonstrable milestones, not a list of recommendations.
5. **Tooling.** A structured engagement knowledge base with RAG access, and AI agents with
   read-only access to the monitoring tool (e.g. Dynatrace MCP) to speed up inventory and checks.

## Map

| Folder | What | Read when |
|---|---|---|
| [method/getting-started.md](./method/getting-started.md) | First assessment with the kit: what to copy, fill, hold | before day one |
| [example/worked-example.md](./example/worked-example.md) | One fictional engagement, findings to acceptance | before day one |
| [offerings.md](./offerings.md) | The three formats we sell: Assessment, Blueprint, Implementation | scoping a request |
| [method/playbook.md](./method/playbook.md) | Step-by-step method, week by week | running an assessment |
| [method/maturity-model.md](./method/maturity-model.md) | 12 dimensions × 5 levels with definitions | scoring |
| [method/lessons.md](./method/lessons.md) | Anti-patterns and lessons | before the first client meeting |
| [templates/](./templates/) | Intake questionnaire, data request, finding, ADR, report, roadmap, commitment baseline, spec set with nine skeletons | producing artifacts |
| [practice/](./practice/) | How to build an observability practice around the kit | staffing, succession |
| [backlog.md](./backlog.md) | What the kit still lacks | planning kit work |

## Releases

Each tagged release (`vX.Y.Z`) publishes the whole kit as one PDF on the
[releases page](../../releases). Contributions: see [CONTRIBUTING.md](./CONTRIBUTING.md).
