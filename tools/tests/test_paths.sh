#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests the stage prompts against the path table in tools/agent/README.md, "Artifact paths":
# every path a stage's Output names is in the table as made by that stage; every path its
# Inputs name is made by an earlier stage, by init-engagement.sh (checked on a fresh
# repository) or by the person, and the table lists the stage as a reader. Kit paths
# (tools/, templates/, method/) must exist in the kit.
set -euo pipefail
cd "$(dirname "$0")/../.."
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/eng" "$T/code"; git -C "$T/eng" init -q
tools/agent/init-engagement.sh --repo "$T/eng" --code "$T/code" >/dev/null
for n in 1 2 3 4 5 6; do tools/agent/prompt.sh "$n" "$T/s$n.md"; done

python3 - "$T" <<'PY'
import os, re, sys
T = sys.argv[1]
WORK = os.path.join(T, "eng", "assessment")
fail = 0
def ok(m): print("✓", m)
def ko(m):
    global fail; fail = 1; print("✗", m)

def section(text, name):
    m = re.search(r"^## " + name + r"\n(.*?)(?=^## |^---$|\Z)", text, re.S | re.M)
    return m.group(1) if m else ""

PATH = re.compile(r"^[A-Za-z0-9_.\[\]-]+(/[A-Za-z0-9_.\[\]-]*)*$")
def paths(text):
    text = re.sub(r"\[[^\]]*\]\([^)]*\)", "", text)          # links point at the kit
    out = []
    for c in re.findall(r"`([^`]+)`", text):
        if PATH.match(c) and ("/" in c or re.search(r"\.(md|ya?ml|txt|json)$", c)):
            out.append(c)
    return list(dict.fromkeys(out))

readme = open("tools/agent/README.md").read()
rows = []
for line in section(readme, "Artifact paths").splitlines():
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) != 4 or not cells[0].startswith("`"):
        continue
    made, read = cells[2], cells[3]
    rows.append({
        "paths": re.findall(r"`([^`]+)`", cells[0]),
        "stages": {int(s) for s in re.findall(r"\b([1-6])\b", made)},
        "init": "init" in made, "person": "person" in made,
        "readers": {int(s) for s in re.findall(r"\b([1-6])\b", read)} | ({1, 2, 3, 4, 5, 6} if "every stage" in read else set()),
    })
ok(f"path table has {len(rows)} rows") if rows else ko("no path table in tools/agent/README.md")

def find(p):
    for r in rows:
        for q in r["paths"]:
            if p == q or (q.endswith("/") and p.startswith(q)) or (p.endswith("/") and q.startswith(p)):
                return r
    return None

KIT = ("tools/", "templates/", "method/")
for n in range(1, 7):
    text = open(os.path.join(T, f"s{n}.md")).read()
    for kind in ("Inputs", "Output"):
        for p in paths(section(text, kind)):
            if p.startswith(KIT):
                (ok if os.path.exists(p) else ko)(f"stage {n} {kind.lower()}: kit file {p}")
                continue
            r = find(p)
            if r is None:
                ko(f"stage {n} {kind.lower()}: {p} is not in the path table"); continue
            if kind == "Output":
                (ok if n in r["stages"] else ko)(f"stage {n} output {p} is made by stage {n} in the table")
                continue
            if any(s < n for s in r["stages"]):
                ok(f"stage {n} input {p}: made by an earlier stage")
            elif r["init"]:
                made = any(os.path.exists(os.path.join(WORK, q.rstrip("/"))) for q in r["paths"])
                (ok if made else ko)(f"stage {n} input {p}: made by init-engagement.sh")
            elif r["person"]:
                ok(f"stage {n} input {p}: made by the person")
            else:
                ko(f"stage {n} input {p}: made by no earlier stage, init or the person")
            (ok if n in r["readers"] else ko)(f"stage {n} input {p}: the table lists stage {n} as a reader")

for r in rows:
    if r["init"]:
        for q in r["paths"]:
            d = os.path.dirname(q) if "N" in q else q.rstrip("/")
            (ok if os.path.exists(os.path.join(WORK, d)) else ko)(f"init makes {d}")
sys.exit(fail)
PY
