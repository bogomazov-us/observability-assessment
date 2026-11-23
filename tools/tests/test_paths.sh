#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests the stage prompts against the path table in tools/agent/setup.md, "Artifact paths":
# every path a stage's Output names is in the table as made by that stage; every path its
# Inputs name is made by an earlier stage, by init-engagement.sh (checked on a fresh
# repository) or by the person, and the table lists the stage as a reader; init makes every
# folder the table names. Kit paths (tools/, templates/, method/, sre/ kit folders) must exist.
# The SRE rows (paths under sre/) get the same checks, applied as their parts land, so the table
# can lead the kit: the SRE stage files present are checked, a placeholder names no paths; the
# init checks run once init-engagement.sh takes --assessment. Until then the SRE rows are
# checked for shape: the required paths, a maker and a reader in each, shared rows marked.
# An SRE prompt names its own paths with sre/; a path without it is an observability file, read
# only when the table lists the SRE stage as a reader ("SRE N") or the row is shared by every
# type. Paths in an SRE prompt's Inputs and Output tables are in backticks.
set -euo pipefail
cd "$(dirname "$0")/../.."
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/eng" "$T/sre" "$T/code"; git -C "$T/eng" init -q; git -C "$T/sre" init -q
tools/agent/init-engagement.sh --repo "$T/eng" --code "$T/code" >/dev/null
for n in 1 2 3 4 5 6; do tools/agent/prompt.sh "$n" "$T/s$n.md"; done
SRE_INIT=0
if grep -q -- '--assessment' tools/agent/init-engagement.sh; then
  tools/agent/init-engagement.sh --repo "$T/sre" --code "$T/code" --assessment sre >/dev/null; SRE_INIT=1
fi
for f in sre/agent/stage-[1-6]-*.md; do
  [ -e "$f" ] || continue; n="${f#sre/agent/stage-}"; n="${n%%-*}"
  tools/agent/prompt.sh --assessment sre "$n" "$T/sre-s$n.md"
done

python3 - "$T" "$SRE_INIT" <<'PY'
import os, re, sys
T, SRE_INIT = sys.argv[1], sys.argv[2] == "1"
WORK = os.path.join(T, "eng", "assessment")
SRE_WORK = os.path.join(T, "sre", "assessment")
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

KIT = ("tools/", "templates/", "method/", "sre/agent/", "sre/templates/", "sre/example/", "sre/README.md", "sre/maturity-model.md")
readme = open("tools/agent/setup.md").read()
rows = []
for line in section(readme, "Artifact paths").splitlines():
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) != 3 or not cells[0].startswith("`"):
        continue
    made, read = cells[1], cells[2]
    m = re.search(r"SRE ([1-6](?:, [1-6])*)", read)
    sre_readers = {int(s) for s in re.findall(r"[1-6]", m.group(1))} if m else set()
    read = read.replace(m.group(0), "") if m else read
    ps = [p for p in paths(cells[0]) if not p.startswith(KIT)]
    rows.append({
        "paths": ps, "sre": all(p.startswith("sre/") for p in ps), "cells": cells,
        "stages": {int(s) for s in re.findall(r"\b([1-6])\b", made)},
        "init": "init" in made, "person": "person" in made, "sre_readers": sre_readers,
        "shared": "every type" in cells[0],
        "readers": {int(s) for s in re.findall(r"\b([1-6])\b", read)} | ({1, 2, 3, 4, 5, 6} if "every stage" in read else set()),
    })
ok(f"path table has {len(rows)} rows") if rows else ko("no path table in tools/agent/setup.md")
obs = [r for r in rows if not r["sre"]]
sre = [r for r in rows if r["sre"]]

def find(p, table):
    for r in table:
        for q in r["paths"]:
            if p == q or (q.endswith("/") and p.startswith(q)) or (p.endswith("/") and q.startswith(p)):
                return r
    return None

# The SRE rows: the paths of the engagement layout, each with a maker and a reader; the
# paths every type shares are marked so in the first table.
for q in ("sre/engagement-state.yml", "sre/progress/", "sre/exports/", "sre/targets/",
          "sre/inventory.md", "sre/service-catalogue.md", "sre/maturity.yml"):
    (ok if find(q, sre) else ko)(f"SRE row for {q}")
for r in sre:
    shaped = (r["stages"] or r["init"] or r["person"] or "stage N" in r["cells"][1]) and r["cells"][2]
    (ok if shaped else ko)(f"SRE row {r['paths'][0]} names its maker and readers")
for q in ("owner-questions.md", "findings/F-NNN.md", "summary.md", "manifest.txt"):
    r = find(q, obs)
    (ok if r and "every type" in r["cells"][0] else ko)(f"{q} is marked as shared by every type")

def resolve(p, sre_prompt):
    if sre_prompt:
        return find(p, sre if p.startswith("sre/") else obs), SRE_WORK
    return find(p, obs), WORK

def plain(text):
    # a path written without backticks in a table row of Inputs or Output
    text = re.sub(r"\[[^\]]*\]\([^)]*\)", "", re.sub(r"`[^`]*`", "", text))
    rows = [l for l in text.splitlines() if l.startswith("|")]
    return re.findall(r"(?<![\w/.-])(?:[\w.-]+/)+[\w.-]*|[\w-]+\.(?:md|ya?ml)\b", "\n".join(rows))

prompts = [(n, f"s{n}.md", False) for n in range(1, 7)]
prompts += [(n, f"sre-s{n}.md", True) for n in range(1, 7) if os.path.exists(os.path.join(T, f"sre-s{n}.md"))]
for n, fname, is_sre in prompts:
    text = open(os.path.join(T, fname)).read()
    label = f"SRE stage {n}" if is_sre else f"stage {n}"
    for kind in ("Inputs", "Output"):
        if is_sre:
            loose = plain(section(text, kind))
            (ko if loose else ok)(f"{label} {kind.lower()}: paths in backticks" + (f" (not: {', '.join(loose)})" if loose else ""))
        for p in paths(section(text, kind)):
            if p.startswith(KIT):
                (ok if os.path.exists(p) else ko)(f"{label} {kind.lower()}: kit file {p}")
                continue
            r, work = resolve(p, is_sre)
            if r is None:
                ko(f"{label} {kind.lower()}: {p} is not in the path table"); continue
            if is_sre and not p.startswith("sre/") and not r["shared"]:
                if kind == "Output":
                    ko(f"{label} output {p}: an SRE stage writes no observability file")
                else:
                    (ok if n in r["sre_readers"] else ko)(f"{label} input {p}: the table lists SRE {n} as a reader of the observability file")
                continue
            if kind == "Output":
                (ok if n in r["stages"] else ko)(f"{label} output {p} is made by stage {n} in the table")
                continue
            if any(s < n for s in r["stages"]):
                ok(f"{label} input {p}: made by an earlier stage")
            elif r["init"] and is_sre and not SRE_INIT:
                print(f"- {label} input {p}: made by init, not checked until init takes --assessment")
            elif r["init"]:
                made = any(os.path.exists(os.path.join(work, q.rstrip("/"))) for q in r["paths"])
                (ok if made else ko)(f"{label} input {p}: made by init-engagement.sh")
            elif r["person"]:
                ok(f"{label} input {p}: made by the person")
            else:
                ko(f"{label} input {p}: made by no earlier stage, init or the person")
            (ok if n in r["readers"] else ko)(f"{label} input {p}: the table lists stage {n} as a reader")

shared = [r for r in obs if "every type" in r["cells"][0]]
checks = [(obs, WORK, "")] + ([(sre + shared, SRE_WORK, "SRE: ")] if SRE_INIT else [])
if not SRE_INIT:
    print("- SRE rows: init checks skipped until init-engagement.sh takes --assessment")
for table, work, tag in checks:
    folders = set()
    for r in table:
        for q in r["paths"]:
            if r["init"]:
                (ok if os.path.exists(os.path.join(work, q)) else ko)(f"{tag}init makes {q}")
            if "/" in q:
                folders.add(q if q.endswith("/") else os.path.dirname(q) + "/")
    for d in sorted(folders):
        (ok if os.path.isdir(os.path.join(work, d)) else ko)(f"{tag}init makes the folder {d}")
sys.exit(fail)
PY
