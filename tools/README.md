# Tools

Small, read-only helpers for the steps of the method that are mechanical. They speed up
collection and checking; they never replace the evidence rule. Python 3.9+ with PyYAML, bash.
The kit is tool-agnostic: it names classes of capability, never a product.

| Tool | Use it | Doc |
|---|---|---|
| `tools/collect/code-scan.sh` | Week one: leads in the client's code (RUM, correlation, agents, errors inside HTTP 200) | [collect.md](collect.md) |
| Estate export by object class | Week one: what to export from whatever monitoring tool the client runs | [collect.md](collect.md) |
| `tools/speclint.py` | Blueprint: check the chain function → signal → SLO → alert → runbook before each review round | [speclint.md](speclint.md) |
| `tools/assessment-pdf.sh` | Each accepted stage: rebuild the assessment report and the evidence bundle from a manifest of stage sources, sections chosen per file; ids in the report must resolve in the bundle | [stage-report.md](../templates/stage-report.md) |
| `tools/report-pdf.sh` | Every stage: build a stage report or its evidence bundle into a PDF with one style (`tools/report.css`) and check that every cited id reaches its text | [stage-report.md](../templates/stage-report.md) |
| `tools/maturity.py` | Assessment: check the maturity scores against the scoring rules and print the profile | [maturity.md](maturity.md) |

Output goes into the engagement repository, sanitized, never into this kit. Tests:
`scripts/test-tools.sh`.
