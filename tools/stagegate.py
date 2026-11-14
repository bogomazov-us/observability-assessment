#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Check an engagement state file: may a stage start, and is the file itself sound.

    tools/stagegate.py check engagement-state.yml N          may stage N start?
    tools/stagegate.py lint engagement-state.yml [--since REV]  check the file; with --since,
                                                              also against its version at a git revision

Exit: 0 clean (warnings allowed) or stage may start, 1 rule violations or stage blocked,
2 usage or parse error. Gates: tools/agent/README.md, "Gates"; rule IDs: tools/stagegate.md.
The tool only reads: a person sets a stage to confirmed by editing the file.
"""
import argparse
import datetime
import os
import subprocess
import sys

try:
    import yaml
except ImportError:
    print("stagegate.py: PyYAML is required (pip install pyyaml)", file=sys.stderr)
    sys.exit(2)

STAGES = {
    1: "Inventory",
    2: "Target model",
    3: "Gap",
    4: "Findings",
    5: "Maturity",
    6: "Recommendations",
}
STATUSES = ("not_started", "draft", "handed_over", "returned", "confirmed")
CONFIRMATION = ("confirmed_by", "confirmed_on", "decision_ref")


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


def as_date(v):
    if isinstance(v, datetime.date):
        return v
    if isinstance(v, str):
        try:
            return datetime.date.fromisoformat(v.strip())
        except ValueError:
            return None
    return None


def stages_by_number(doc, rep):
    """Index the stages list by number, reporting malformed and duplicate entries."""
    out = {}
    stages = doc.get("stages") if isinstance(doc, dict) else None
    if not isinstance(stages, list):
        rep.error("stages", "G02", "stages must be a list of the six stages")
        return out
    for i, s in enumerate(stages):
        n = s.get("number") if isinstance(s, dict) else None
        if n not in STAGES:
            rep.error(f"stages[{i}]", "G02", f"number must be 1–6, got {n!r}")
            continue
        if n in out:
            rep.error(f"stage {n}", "G03", "listed twice")
            continue
        out[n] = s
    for n in STAGES:
        if n not in out:
            rep.error(f"stage {n}", "G02", "missing; list every stage, not_started if it has not begun")
    return out


def lint(doc, rep):
    scope = doc.get("scope") if isinstance(doc, dict) else None
    if not isinstance(scope, dict):
        rep.error("scope", "G01", "scope must record the agreement and the access before stage 1")
    stages = stages_by_number(doc, rep)

    for n, s in sorted(stages.items()):
        where = f"stage {n}"
        status = s.get("status")
        if status not in STATUSES:
            rep.error(where, "G04", f"status must be one of {', '.join(STATUSES)}, got {status!r}")
            continue
        if status == "confirmed":
            missing = [k for k in CONFIRMATION if not is_text(s.get(k)) and as_date(s.get(k)) is None]
            if missing:
                rep.error(where, "G05", f"confirmed without {', '.join(missing)}")
            elif as_date(s.get("confirmed_on")) is None:
                rep.error(where, "G05", f"confirmed_on is not a date (YYYY-MM-DD): {s.get('confirmed_on')!r}")
            prev = stages.get(n - 1)
            if n > 1 and prev is not None and prev.get("status") != "confirmed":
                rep.error(where, "G06", f"confirmed while stage {n - 1} is {prev.get('status')}")
            elif n > 1 and prev is not None:
                d, p = as_date(s.get("confirmed_on")), as_date(prev.get("confirmed_on"))
                if d and p and d < p:
                    rep.error(where, "G07", f"confirmed on {d}, before stage {n - 1} ({p})")
        elif any(s.get(k) for k in CONFIRMATION):
            rep.error(where, "G05", f"carries confirmation fields while {status}; a stage is confirmed or it is not")
        if status in ("draft", "handed_over", "returned") and n > 1:
            prev = stages.get(n - 1)
            if prev is not None and prev.get("status") != "confirmed":
                rep.warn(where, "W01", f"{status} while stage {n - 1} is {prev.get('status')}: "
                                      "work started before its gate opened")
        reviews = s.get("reviews", [])
        if not isinstance(reviews, list):
            rep.error(where, "G08", "reviews must be a list")
            continue
        for j, r in enumerate(reviews):
            ok = isinstance(r, dict) and as_date(r.get("date")) and is_text(r.get("by")) and is_text(r.get("file"))
            if not ok:
                rep.error(f"{where} review {j + 1}", "G08", "a review needs date (YYYY-MM-DD), by and file")

    for i, q in enumerate(doc.get("questions") or [] if isinstance(doc, dict) else []):
        where = f"question {q.get('id', i + 1) if isinstance(q, dict) else i + 1}"
        if not isinstance(q, dict) or not is_text(q.get("id")) or not is_text(q.get("question")):
            rep.error(where, "G09", "a question needs id and question")
            continue
        blocks = q.get("blocks", [])
        if not isinstance(blocks, list) or any(b not in STAGES for b in blocks):
            rep.error(where, "G09", f"blocks must list stage numbers 1–6, got {blocks!r}")
        if q.get("answer_ref") is not None and not is_text(q.get("answer_ref")):
            rep.error(where, "G09", "answer_ref is the decision-register id, or absent while open")
        for b in blocks if isinstance(blocks, list) else []:
            if b in stages and stages[b].get("status") == "confirmed" and not is_text(q.get("answer_ref")):
                rep.error(where, "G10", f"still open, but stage {b}, which it blocks, is confirmed")
    return stages


def gate(doc, n, rep):
    """Reasons stage n may not start; empty when it may."""
    stages = lint(doc, rep)
    blocked = []
    if n == 1:
        scope = doc.get("scope") or {}
        if not is_text(scope.get("decision_ref")):
            blocked.append("scope not agreed: scope.decision_ref is empty")
        if as_date(scope.get("access_granted_on")) is None:
            blocked.append("read-only access not recorded: scope.access_granted_on is empty")
    else:
        prev = stages.get(n - 1, {})
        if prev.get("status") != "confirmed":
            blocked.append(f"stage {n - 1} ({STAGES[n - 1]}) is {prev.get('status', 'missing')}, not confirmed")
        elif any(not is_text(prev.get(k)) and as_date(prev.get(k)) is None for k in CONFIRMATION):
            blocked.append(f"stage {n - 1} ({STAGES[n - 1]}) is marked confirmed, but its confirmation "
                           f"lacks one of {', '.join(CONFIRMATION)}")
    for q in doc.get("questions") or []:
        if isinstance(q, dict) and n in (q.get("blocks") or []) and not is_text(q.get("answer_ref")):
            blocked.append(f"question {q.get('id')} is open and blocks stage {n}")
    return blocked


def since(doc, path, rev, rep):
    """Compare with the file at a git revision: reviews only grow, confirmations stay as written."""
    d, name = os.path.split(os.path.abspath(path))
    try:
        old_text = subprocess.run(["git", "-C", d, "show", f"{rev}:./{name}"],
                                  capture_output=True, text=True, check=True).stdout
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f"stagegate.py: cannot read {path} at {rev}: {getattr(e, 'stderr', e)}".strip(), file=sys.stderr)
        sys.exit(2)
    old = stages_by_number(yaml.safe_load(old_text) or {}, Report(f"{path}@{rev}"))
    new = stages_by_number(doc, Report(path))
    for n, o in sorted(old.items()):
        s = new.get(n, {})
        old_r, new_r = o.get("reviews") or [], s.get("reviews") or []
        if new_r[:len(old_r)] != old_r:
            rep.error(f"stage {n}", "G11", f"reviews changed since {rev}: a review is appended, never edited or removed")
        if o.get("status") == "confirmed" and s.get("status") == "confirmed":
            changed = [k for k in CONFIRMATION if o.get(k) != s.get(k)]
            if changed:
                rep.error(f"stage {n}", "G12", f"confirmation rewritten since {rev}: {', '.join(changed)}")


def load(path):
    try:
        with open(path) as f:
            return yaml.safe_load(f) or {}
    except (OSError, yaml.YAMLError) as e:
        print(f"stagegate.py: cannot read {path}: {e}", file=sys.stderr)
        sys.exit(2)


def main():
    ap = argparse.ArgumentParser(description="Check an engagement state file.")
    sub = ap.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("check", help="may stage N start?")
    c.add_argument("state")
    c.add_argument("stage", type=int, choices=sorted(STAGES))
    li = sub.add_parser("lint", help="check the state file")
    li.add_argument("state")
    li.add_argument("--since", metavar="REV", help="also compare with the file at this git revision")
    a = ap.parse_args()

    doc = load(a.state)
    rep = Report(a.state)
    if a.cmd == "check":
        blocked = gate(doc, a.stage, rep)
        for line in rep.errors + rep.warnings:
            print(line, file=sys.stderr)
        if blocked or rep.errors:
            for b in blocked:
                print(f"stage {a.stage} blocked: {b}")
            if rep.errors and not blocked:
                print(f"stage {a.stage} blocked: the state file has errors")
            return 1
        print(f"stage {a.stage} ({STAGES[a.stage]}) may start")
        return 0

    lint(doc, rep)
    if a.since:
        since(doc, a.state, a.since, rep)
    for line in rep.errors + rep.warnings:
        print(line, file=sys.stderr)
    return 1 if rep.errors else 0


if __name__ == "__main__":
    sys.exit(main())
