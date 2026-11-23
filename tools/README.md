# Tools

Small, read-only helpers for the steps of the method that are mechanical. They speed up
collection and checking; they never replace the evidence rule. Python 3.9+ with PyYAML, bash.
The kit is tool-agnostic: it names classes of capability, never a product.

| Tool | Use it | Doc |
|---|---|---|
| `tools/collect/code-scan.sh` | Week one: leads in the client's code (RUM, correlation, agents, errors inside HTTP 200) | [collect.md](collect.md) |
| Estate export by object class | Week one: what to export from whatever monitoring tool the client runs | [collect.md](collect.md) |
| `tools/speclint.py` | Blueprint: check the chain function → signal → SLO → alert → runbook before each review round | [speclint.md](speclint.md) |
| `tools/assessment-pdf.sh` | Each accepted stage: rebuild the assessment report and the evidence bundle from a manifest of stage sources, sections chosen per file; ids in the report must resolve in the bundle | [report.md](../method/report.md) |
| `tools/report-pdf.sh` | Every stage: build a stage report or its evidence bundle into a PDF with one style (`tools/report.css`) and check that every cited id reaches its text | [stage-report.md](../templates/stage-report.md) |
| `tools/agent/init-engagement.sh` | Once per engagement: set up the engagement repository for the agent stages (instructions for the agent with the paths filled in, state file, facts ledger, decision register; skills optional) | [agent/setup.md](agent/setup.md) |
| `tools/agent/prompt.sh` | Each agent stage: assemble the stage's task prompt with the rule files it names | [agent/README.md](agent/README.md) |
| `tools/agent/skills/install.sh` | Optional, per engagement: install the stage and rule skills, pointed at this kit checkout | [agent/skills/README.md](agent/skills/README.md) |
| `tools/stagegate.py` | Each agent stage: may it start (the stage before confirmed, its blocking questions answered); is the state file sound and unrewritten | [stagegate.md](stagegate.md) |
| `tools/maturity.py` | Assessment: check the maturity scores against the scoring rules and print the profile | [maturity.md](maturity.md) |
| `tools/baseline.py` | SRE assessment, week one: baseline numbers (incidents, DORA keys, pages) from CSV exports, each with its method and window | [baseline.md](baseline.md) |

Output goes into the engagement repository, sanitized, never into this kit. Tests:
`scripts/test-tools.sh`.
