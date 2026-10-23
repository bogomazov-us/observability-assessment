#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Check a maturity scoring file against the kit's scoring rules and print the profile.

    tools/maturity.py maturity.yml              check, then print the profile (Markdown)
    tools/maturity.py --check maturity.yml      check only

Exit: 0 clean (warnings allowed), 1 rule violations, 2 usage or parse error.
Rules: method/maturity-model.md, "Scoring rules"; rule IDs: tools/maturity.md.
"""
import argparse
import sys

try:
    import yaml
except ImportError:
    print("maturity.py: PyYAML is required (pip install pyyaml)", file=sys.stderr)
    sys.exit(2)

DIMENSIONS = {
    1: "Business-function model",
    2: "Telemetry coverage",
    3: "Error semantics",
    4: "Correlation",
    5: "Business outcome data",
    6: "SLOs",
    7: "Alert quality",
    8: "Incident response",
    9: "Outside-in checks",
    10: "Release observability",
    11: "Data governance and cost",
    12: "Operational analytics",
}
STATUSES = ("scored", "partial", "not_scored", "na")
EVIDENCE_TYPES = ("export", "query", "trace", "code", "config", "interview", "document")
TOOL_EVIDENCE = ("export", "query", "trace", "code", "config")
CONFIDENCE = ("high", "medium", "low")


class Report:
    def __init__(self, path):
        self.path = path
        self.errors = []
        self.warnings = []

    def error(self, where, rule, msg):
        self.errors.append(f"{self.path}: {where}: {rule} {msg}")

    def warn(self, where, rule, msg):
        self.warnings.append(f"{self.path}: {where}: {rule} {msg}")


def is_text(v):
    return isinstance(v, str) and v.strip() != ""


def check(doc, rep):
    scope = doc.get("scope") if isinstance(doc, dict) else None
    if not isinstance(scope, dict) or not scope.get("journeys") or not scope.get("services"):
        rep.error("scope", "M01", "scope must list journeys and services before any score")

    dims = doc.get("dimensions") if isinstance(doc, dict) else None
    if not isinstance(dims, list) or not dims:
        rep.error("dimensions", "M02", "no dimensions listed")
        return []

    seen = set()
    valid = []
    for i, d in enumerate(dims):
        if not isinstance(d, dict):
            rep.error(f"dimensions[{i}]", "M02", "entry is not a mapping")
            continue
        n = d.get("number")
        where = f"dimension {n}"
        if n not in DIMENSIONS:
            rep.error(where, "M02", "number must be 1-12")
            continue
        if "name" in d and d["name"] != DIMENSIONS[n]:
            rep.error(where, "M02", f"name must be '{DIMENSIONS[n]}'")
        if n in seen:
            rep.error(where, "M03", "dimension listed twice")
            continue
        seen.add(n)

        status = d.get("status")
        if status not in STATUSES:
            rep.error(where, "M04", f"status must be one of {', '.join(STATUSES)}")
            continue

        if status in ("not_scored", "na"):
            if not is_text(d.get("reason")):
                rep.error(where, "M11", f"{status} needs a reason")
            if d.get("level") is not None:
                rep.error(where, "M11", f"{status} carries no level (not scored is not level 1)")
            if status == "na" and n != 12 and not is_text(d.get("agreed_by")):
                rep.warn(where, "W01", "N/A outside dimension 12: record who on the client side agreed (agreed_by)")
            valid.append(d)
            continue

        level = d.get("level")
        if not isinstance(level, int) or isinstance(level, bool) or not 1 <= level <= 5:
            rep.error(where, "M05", "level must be an integer 1-5")
            continue
        if status == "partial":
            pl = d.get("partial_level")
            if not is_text(d.get("coverage")):
                rep.error(where, "M06", "partial needs the coverage written out (e.g. 'level 3 on 2 of 5 functions')")
            if not isinstance(pl, int) or isinstance(pl, bool) or pl <= level or pl > 5:
                rep.error(where, "M06", "partial needs partial_level above level: the level held on some functions")

        ev = d.get("evidence") or []
        if not isinstance(ev, list):
            rep.error(where, "M13", "evidence must be a list")
            ev = []
        types = []
        for j, e in enumerate(ev):
            if not isinstance(e, dict) or e.get("type") not in EVIDENCE_TYPES or not is_text(e.get("ref")):
                rep.error(where, "M13", f"evidence[{j}] needs type ({'/'.join(EVIDENCE_TYPES)}) and ref")
                continue
            types.append(e["type"])
        if not ev:
            rep.error(where, "M07", "every score names its evidence; level 1 names the search that came back empty")
        if level > 2 and not any(t in TOOL_EVIDENCE for t in types):
            rep.error(where, "M08", "above level 2 needs tool evidence (export, query, trace, code, config); interviews and documents cap at 2")

        conf = d.get("confidence")
        if conf not in CONFIDENCE:
            rep.error(where, "M10", "confidence must be high, medium or low")
        elif conf == "low" and level > 2:
            rep.error(where, "M09", "low confidence caps the score at 2")
        valid.append(d)

    for k in ("average", "overall", "score"):
        if isinstance(doc, dict) and k in doc:
            rep.error(k, "M12", "no overall number: show the profile (agreed weights go in the report, not here)")
    return valid


def level_cell(d):
    if d["status"] == "not_scored":
        return "not scored"
    if d["status"] == "partial":
        return f"{d['level']} (partial {d['partial_level']})"
    return str(d["level"])


def cell(v):
    return str(v).replace("|", "\\|").replace("\n", " ") if v else "—"


def render(doc, dims):
    out = []
    scope = doc["scope"]
    out.append(f"**Scope:** {', '.join(map(str, scope['journeys']))} · services: {', '.join(map(str, scope['services']))}")
    out.append("")
    out.append("| Dimension | Level | Coverage | Evidence | Confidence |")
    out.append("|---|---|---|---|---|")
    shown = sorted((d for d in dims if d["status"] != "na"), key=lambda d: d["number"])
    for d in shown:
        n = d["number"]
        if d["status"] == "not_scored":
            out.append(f"| {n} {DIMENSIONS[n]} | not scored | {cell(d.get('reason'))} | — | — |")
            continue
        ev = "; ".join(e["ref"] for e in d.get("evidence") or [])
        out.append(f"| {n} {DIMENSIONS[n]} | {level_cell(d)} | {cell(d.get('coverage'))} | {cell(ev)} | {d['confidence']} |")

    na = [d for d in dims if d["status"] == "na"]
    if na:
        out.append("")
        out.append("**Left out as N/A:** " + "; ".join(
            f"{d['number']} {DIMENSIONS[d['number']]} — {d['reason']}" for d in sorted(na, key=lambda d: d["number"])))

    counts = {}
    for d in shown:
        if d["status"] in ("scored", "partial"):
            counts[d["level"]] = counts.get(d["level"], 0) + 1
    parts = []
    for lvl in sorted(counts):
        c = counts[lvl]
        parts.append(f"{c} {'dimension' if c == 1 else 'dimensions'} at {lvl}" if not parts else f"{c} at {lvl}")
    ns = sum(1 for d in shown if d["status"] == "not_scored")
    if ns:
        parts.append(f"{ns} not scored")
    out.append("")
    out.append("**Distribution:** " + (", ".join(parts) if parts else "nothing scored"))

    blocks = [d for d in shown if d.get("blocks_next_step")]
    out.append("")
    if blocks:
        out.append("**Block the next step:** " + "; ".join(f"{d['number']} {DIMENSIONS[d['number']]}" for d in blocks))
    else:
        out.append("**Block the next step:** none marked (set `blocks_next_step: true` on up to three dimensions)")

    moves = doc.get("moves_fastest")
    if moves:
        out.append("")
        out.append("**What moves the score fastest**")
        out.append("")
        for m in moves:
            out.append(f"- {m}")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser(description="Check a maturity scoring file and print the profile.")
    ap.add_argument("file", help="scoring file, e.g. maturity.yml")
    ap.add_argument("--check", action="store_true", help="validate only, print no profile")
    ap.add_argument("--format", choices=("md",), default="md", help="output format (Markdown)")
    a = ap.parse_args()

    try:
        with open(a.file, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
    except (OSError, yaml.YAMLError) as e:
        print(f"{a.file}: cannot read: {e}", file=sys.stderr)
        return 2
    if not isinstance(doc, dict):
        print(f"{a.file}: not a mapping", file=sys.stderr)
        return 2

    rep = Report(a.file)
    dims = check(doc, rep)
    for w in rep.warnings:
        print(w, file=sys.stderr)
    if rep.errors:
        for e in rep.errors:
            print(e, file=sys.stderr)
        return 1
    if not a.check:
        print(render(doc, dims))
    return 0


if __name__ == "__main__":
    sys.exit(main())
