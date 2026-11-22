#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# The status table in method/records.md lists, for each set a tool enforces, exactly the values
# the tool accepts. Reads the table and the tools' constants (by parsing, not importing).
# Also: maturity.py's SRE_DIMENSIONS and OVERLAPS match the tables of sre/maturity-model.md
# (until that page exists, tools/tests/fixtures/maturity/sre-model.md, the PRD and brief tables).
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

def constants(tool, raw=False):
    tree = ast.parse(open(f"{root}/tools/{tool}").read())
    out = {}
    for node in tree.body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name):
            try:
                v = ast.literal_eval(node.value)
                out[node.targets[0].id] = v if raw else set(v)
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

# SRE model: dimension table ("| # | Dimension |") and overlap table ("| Topic | Observability | SRE | Combined |")
import os
page = f"{root}/sre/maturity-model.md"
if not os.path.exists(page):
    page = f"{root}/tools/tests/fixtures/maturity/sre-model.md"
tables, cur = [], None
for line in open(page).read().splitlines():
    if line.startswith("|"):
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if cur is None:
            cur = {"head": cells, "rows": []}; tables.append(cur)
        elif not set("".join(cells)) <= set("-: "):
            cur["rows"].append(cells)
    else:
        cur = None

def where_scored(text):
    t = text.lower()
    if "both scored" in t:
        return "both"
    m = re.search(r"scored in (observability|sre)", t) or re.search(r"refers to (observability|sre)", t)
    return m.group(1) if m else None

def first_int(text):
    m = re.match(r"\s*(\d+)", text)
    return int(m.group(1)) if m else None

rel = os.path.relpath(page, root)
c = constants("maturity.py", raw=True)
dims = {int(r[0]): r[1] for t in tables if t["head"][:2] == ["#", "Dimension"] for r in t["rows"] if r[0].isdigit()}
over = tuple((r[0], first_int(r[1]), first_int(r[2]), where_scored(r[3]))
             for t in tables if t["head"][:4] == ["Topic", "Observability", "SRE", "Combined"] for r in t["rows"])
for name, doc_value, const in (("SRE dimensions", dims, "SRE_DIMENSIONS"), ("Overlap table", over, "OVERLAPS")):
    if not doc_value:
        print(f"✗ {rel}: no {name} table"); fail = 1
    elif doc_value != c.get(const):
        print(f"✗ {name}: {rel} {doc_value} != maturity.py {const} {c.get(const)}"); fail = 1
    else:
        print(f"✓ {name} = maturity.py {const} ({rel})")
sys.exit(fail)
PY
