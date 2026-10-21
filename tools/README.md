# Tools

Small, read-only helpers for the steps of the method that are mechanical. They speed up
collection and checking; they never replace the evidence rule. Python 3.9+ with PyYAML, bash
with curl and jq.

| Tool | Use it | Doc |
|---|---|---|
| `tools/collect/code-scan.sh` | Week one: leads in the client's code (RUM, correlation, agents, errors inside HTTP 200) | [collect.md](collect.md) |
| `tools/collect/dynatrace.sh`, `tools/collect/datadog.sh` | Week one: read-only export of the monitoring estate | [collect.md](collect.md) |
| `tools/speclint.py` | Blueprint: check the chain function → signal → SLO → alert → runbook before each review round | [speclint.md](speclint.md) |
| `tools/maturity.py` | Assessment: check the maturity scores against the scoring rules and print the profile | [maturity.md](maturity.md) |

Output goes into the engagement repository, sanitized, never into this kit. Tests:
`scripts/test-tools.sh`.
