#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# The status table in method/records.md lists, for each set a tool enforces, exactly the values
# the tool accepts. Reads the table and the tools' constants (by parsing, not importing).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
python3 - "$here/../.." <<'PY'
import ast, re, sys
root = sys.argv[1]

# set name in the table -> (tool, constant)
ENFORCED = {
    "Stage status": ("stagegate.py", "STATUSES"),
    "Signal state": ("speclint.py", "SIGNAL_STATES"),
    "Spec row status": ("speclint.py", "SPEC_ROW_STATUSES"),
    "Alert state": ("speclint.py", "ALERT_STATES"),
    "Error class": ("speclint.py", "CLASSES"),
    "User impact": ("speclint.py", "USER_IMPACTS"),
    "Severity": ("speclint.py", "SEVERITIES"),
    "Confidence": ("maturity.py", "CONFIDENCE"),
    "Maturity score": ("maturity.py", "STATUSES"),
}

def constants(tool):
    tree = ast.parse(open(f"{root}/tools/{tool}").read())
    out = {}
    for node in tree.body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name):
            try:
                out[node.targets[0].id] = set(ast.literal_eval(node.value))
            except (ValueError, TypeError):
                pass
    return out

text = open(f"{root}/method/records.md").read()
section = text.split("## Status sets", 1)[1].split("\n## ", 1)[0]
rows = {}
for line in section.splitlines():
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) >= 2 and cells[0] not in ("Set", "") and not set(cells[0]) <= set("-"):
        rows[cells[0]] = set(re.findall(r"`([^`]+)`", cells[1]))

fail = 0
for name, (tool, const) in ENFORCED.items():
    tool_values = constants(tool).get(const)
    if tool_values is None:
        print(f"✗ {tool}: no constant {const}"); fail = 1; continue
    if name not in rows:
        print(f"✗ records.md: no row '{name}'"); fail = 1; continue
    if rows[name] != tool_values:
        print(f"✗ {name}: records.md {sorted(rows[name])} != {tool} {const} {sorted(tool_values)}"); fail = 1
    else:
        print(f"✓ {name} = {tool} {const}")
for name, values in rows.items():
    if values and name not in ENFORCED:
        print(f"✗ {name}: values in code but no tool mapped in this test"); fail = 1
sys.exit(fail)
PY
