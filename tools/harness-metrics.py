#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Compute the harness measures of one engagement from the records it already keeps.

    tools/harness-metrics.py ENGAGEMENT-STATE.yml [--findings DIR] [--json]

Reads, and never writes:
  - the engagement state file (engagement-state.yml, or sre/engagement-state.yml): review
    blocks with review_hours, confirmations with rework_hours;
  - the review files the review blocks name: the "Finding outcomes" table (stage 4), the
    "Re-checks" table (any stage) and the optional "Second reading" table (stage 4);
  - findings/F-NNN.md: the verdict, from the Status cell of the finding's first table;
  - progress/stage-N.md beside the state file: the agent's first and last times.

Exit: 0 measured (some values may be "not measured"), 1 the records break a rule (H01–H07;
the measures are still printed), 2 usage or parse error. Rules and definitions:
tools/harness-metrics.md; the measures: method/agent-harness.md, "Measuring the harness".
"""
import argparse
import datetime
import json
import math
import os
import re
import subprocess
import sys

try:
    import yaml
except ImportError:
    print("harness-metrics.py: PyYAML is required (pip install pyyaml)", file=sys.stderr)
    sys.exit(2)

STAGES = {1: "Inventory", 2: "Target model", 3: "Gap", 4: "Findings", 5: "Maturity", 6: "Recommendations"}
LABELS = ("unchanged", "bounded", "new_input", "corrected", "severity_changed", "split_merge")
STRICT_OUT = {"bounded", "new_input", "corrected", "severity_changed"}  # any of them: not unchanged
LENIENT_OUT = {"corrected", "severity_changed"}
VERDICTS = ("confirmed", "disputed", "refuted", "inconclusive", "resolved")
PENDING = "assumption"
RECHECK = {"reproduced": True, "not reproduced": False}
FLAGS = ("pass", "needs_revision", "needs_human_review")  # second reading (tools/agent/review-findings.md)
REVIEWER = ("open", "acted", "agreed_no_change", "disagreed")
FID = re.compile(r"^F-\d{2,4}$")
EID = re.compile(r"^E-\d{2,4}$")


class Report:
    def __init__(self):
        self.errors = []

    def error(self, where, rule, msg):
        self.errors.append(f"{where}: {rule} {msg}")


def is_hours(v):
    return isinstance(v, (int, float)) and not isinstance(v, bool) and math.isfinite(v) and v >= 0


def cells(line):
    """The cells of a Markdown table row, stripped; None for a line that is not a row."""
    s = line.strip()
    if not (s.startswith("|") and s.endswith("|")):
        return None
    return [c.strip().strip("`").strip() for c in s[1:-1].split("|")]


def tables(path):
    """Yield (header cells, [(line number, row cells)]) for each table in a Markdown file."""
    with open(path, encoding="utf-8") as f:
        lines = f.read().splitlines()
    i, fence = 0, False
    while i < len(lines):
        if lines[i].lstrip().startswith("```"):
            fence = not fence
        head = None if fence else cells(lines[i])
        sep = cells(lines[i + 1]) if head and i + 1 < len(lines) else None
        if head and sep and all(re.fullmatch(r":?-{3,}:?", c) for c in sep):
            rows, j = [], i + 2
            while j < len(lines) and cells(lines[j]) is not None:
                rows.append((j + 1, cells(lines[j])))
                j += 1
            yield [h.lower() for h in head], rows
            i = j
            continue
        i += 1


def column(head, *names):
    for k, h in enumerate(head):
        if any(h.startswith(n) for n in names):
            return k
    return None


def read_outcomes(path, rep, found):
    """Outcome labels per finding from the review file's "Finding outcomes" table."""
    for head, rows in tables(path):
        f, o = column(head, "finding"), column(head, "outcome")
        if f is None or o is None:
            continue
        for ln, row in rows:
            where = f"{path}:{ln}"
            fid = row[f] if f < len(row) else ""
            if not FID.match(fid):
                rep.error(where, "H01", f"an outcome row names one finding id (F-NNN), got {fid!r}")
                continue
            labels = [x.strip() for x in (row[o] if o < len(row) else "").split(",") if x.strip()]
            unknown = [x for x in labels if x not in LABELS]
            if not labels or unknown:
                rep.error(where, "H02", f"{fid}: outcome must be one or more of {', '.join(LABELS)}; got "
                                        f"{', '.join(unknown) or 'nothing'}")
                continue
            if "unchanged" in labels and len(set(labels)) > 1:
                rep.error(where, "H03", f"{fid}: unchanged cannot stand with {', '.join(x for x in labels if x != 'unchanged')}")
                continue
            found.setdefault(fid, set()).update(labels)


def read_rechecks(path, rep, out):
    """Selected re-checks from the review file's "Re-checks" table: (E-id, reproduced?)."""
    for head, rows in tables(path):
        e, r = column(head, "evidence", "check"), column(head, "result")
        if e is None or r is None or column(head, "finding") is not None:
            continue
        for ln, row in rows:
            eid, res = (row[e] if e < len(row) else ""), (row[r] if r < len(row) else "").lower()
            if not EID.match(eid) or res not in RECHECK:
                rep.error(f"{path}:{ln}", "H04", f"a re-check row is an E- id and reproduced or not reproduced; got {eid!r}, {res!r}")
                continue
            out.append((eid, RECHECK[res]))


def read_second_reading(path, rep, out):
    """Rows of the optional second reading: (finding, flag, reviewer's disposition)."""
    for head, rows in tables(path):
        f, fl, rv = column(head, "finding"), column(head, "flag"), column(head, "reviewer")
        if None in (f, fl, rv):
            continue
        for ln, row in rows:
            get = lambda k: row[k].lower() if k < len(row) else ""
            if not FID.match(row[f] if f < len(row) else "") or get(fl) not in FLAGS or get(rv) not in REVIEWER:
                rep.error(f"{path}:{ln}", "H07", f"a second-reading row is a finding id, a flag ({', '.join(FLAGS)}) "
                                                f"and the reviewer's disposition ({', '.join(REVIEWER)})")
                continue
            out.append((row[f], get(fl), get(rv)))


def read_verdict(path):
    """The Status cell of the finding's status table (the first table with a Status column),
    lower case; None if there is none."""
    for head, rows in tables(path):
        s = column(head, "status")
        if s is not None and rows:
            return rows[0][1][s].split("(")[0].strip().lower() if s < len(rows[0][1]) else None
    return None


def read_model(path):
    with open(path, encoding="utf-8") as f:
        m = re.search(r"\*\*Model:\*\*\s*([a-z]+)", f.read(), re.I)
    return m.group(1).lower() if m else None


def agent_span(path):
    """Minutes from the first to the last clock time in a progress log; None if unreadable."""
    if not os.path.isfile(path):
        return None
    day, stamps = None, []
    with open(path, encoding="utf-8") as f:
        for line in f:
            m = re.match(r"^(\d{4}-\d{2}-\d{2})\s*$", line)
            if m:
                day = datetime.date.fromisoformat(m.group(1))
                continue
            m = re.match(r"^(\d{2}):(\d{2})\s", line)
            if m:
                d = day or datetime.date(2000, 1, 1)
                stamps.append(datetime.datetime(d.year, d.month, d.day, int(m.group(1)), int(m.group(2))))
    if len(stamps) < 2:
        return None
    return int((stamps[-1] - stamps[0]).total_seconds() // 60)


def revision(paths):
    """The git commit the inputs were read at, and whether any input differs from it."""
    d = os.path.dirname(os.path.abspath(paths[0]))
    try:
        head = subprocess.run(["git", "-C", d, "rev-parse", "--short", "HEAD"], capture_output=True, text=True)
        if head.returncode != 0:
            return "not under git"
        dirty = subprocess.run(["git", "-C", d, "status", "--porcelain", "--", *[os.path.abspath(p) for p in paths]],
                               capture_output=True, text=True).stdout.strip()
    except FileNotFoundError:
        return "not under git"
    return head.stdout.strip() + (" with uncommitted changes" if dirty else "")


def locate(base, rel):
    """A path a record names: beside the state file, or one folder up (sre/ inside a report)."""
    for root in (base, os.path.dirname(base)):
        p = os.path.join(root, rel)
        if os.path.exists(p):
            return p
    return None


def measure(state_path, findings_dir=None):
    rep = Report()
    try:
        with open(state_path, encoding="utf-8") as f:
            doc = yaml.safe_load(f) or {}
    except (OSError, yaml.YAMLError) as e:
        print(f"harness-metrics.py: cannot read {state_path}: {e}", file=sys.stderr)
        sys.exit(2)
    base = os.path.dirname(os.path.abspath(state_path))
    kind = doc.get("assessment", "observability")
    inputs = [state_path]
    outcomes, stages, second = {}, [], []

    for s in sorted((x for x in doc.get("stages") or [] if isinstance(x, dict) and x.get("number") in STAGES),
                    key=lambda x: x["number"]):
        n = s["number"]
        reviews = [r for r in s.get("reviews") or [] if isinstance(r, dict)]
        hours = [r.get("review_hours") for r in reviews if "review_hours" in r]
        bad = [h for h in hours if not is_hours(h)]
        if bad:
            rep.error(f"{state_path}: stage {n}", "H05", f"review_hours must be hours, 0 or more; got {bad[0]!r}")
        rework = s.get("rework_hours")
        if "rework_hours" in s and not is_hours(rework):
            rep.error(f"{state_path}: stage {n}", "H05", f"rework_hours must be hours, 0 or more; got {rework!r}")
            rework = None
        rechecks = []
        for r in reviews:
            p = locate(base, str(r.get("file", "")))
            if p is None:
                rep.error(f"{state_path}: stage {n}", "H06", f"review file not found: {r.get('file')!r}")
                continue
            inputs.append(p)
            read_rechecks(p, rep, rechecks)
            if n == 4:
                read_outcomes(p, rep, outcomes)
                read_second_reading(p, rep, second)
        good = [h for h in hours if is_hours(h)]
        log = os.path.join(base, "progress", f"stage-{n}.md")
        if os.path.isfile(log):
            inputs.append(log)
        stages.append({
            "stage": n,
            "name": STAGES[n],
            "status": s.get("status"),
            "reviews": len(reviews),
            "reviews_measured": len(good),
            "review_hours": sum(good) if reviews and len(good) == len(reviews) else None,
            "review_hours_partial": sum(good) if good and len(good) < len(reviews) else None,
            "rework_hours": rework if s.get("status") == "confirmed" and "rework_hours" in s else None,
            "agent_minutes": agent_span(log),
            "rechecks_selected": len(rechecks),
            "rechecks_reproduced": sum(1 for _, ok in rechecks if ok),
        })

    # Findings: the verdict is the finding's own Status; the outcome is the reviewer's record.
    if findings_dir is None:
        findings_dir = locate(base, "findings")
    findings = {}
    if findings_dir and os.path.isdir(findings_dir):
        for name in sorted(os.listdir(findings_dir)):
            m = re.match(r"^(F-\d{2,4})\b.*\.md$", name)
            if not m:
                continue
            p = os.path.join(findings_dir, name)
            model = read_model(p)
            if model is not None and model != kind:
                continue
            findings[m.group(1)] = read_verdict(p)
            inputs.append(p)
    for fid in sorted(outcomes):
        if fid not in findings:
            rep.error(f"stage 4 outcomes", "H01", f"{fid} has an outcome but no {kind} finding file")

    verdicted = [f for f, v in findings.items() if v in VERDICTS]
    classified = [f for f in verdicted if f in outcomes]
    strict = [f for f in classified if not outcomes[f] & STRICT_OUT]
    lenient = [f for f in classified if not outcomes[f] & LENIENT_OUT]
    result = {
        "assessment": kind,
        "inputs_at": revision(inputs),
        "stages": stages,
        "findings": {
            "total": len(findings),
            "with_verdict": len(verdicted),
            "pending": sum(1 for v in findings.values() if v == PENDING),
            "other_status": sorted(f for f, v in findings.items() if v not in VERDICTS and v != PENDING),
            "verdict_without_outcome": sorted(set(verdicted) - set(classified)),
            "classified": len(classified),
            # The shares are over every finding with a verdict. A finding without an outcome counts
            # in the denominator and never as unchanged: the share is then a lower bound, the
            # upper bound counts the missing ones as unchanged, and no quality decision is read.
            "denominator": len(verdicted),
            "outcomes_complete": len(classified) == len(verdicted),
            "strict_unchanged": len(strict),
            "lenient_unchanged": len(lenient),
            "split_merge": sum(1 for f in classified if "split_merge" in outcomes[f]),
            "severity_changed": sum(1 for f in classified if "severity_changed" in outcomes[f]),
            "new_input": sum(1 for f in classified if "new_input" in outcomes[f]),
        },
        "second_reading": {
            "rows": len(second),
            "flags": sum(1 for _, fl, _ in second if fl != "pass"),
            "acted": sum(1 for _, fl, rv in second if fl != "pass" and rv == "acted"),
            "agreed_no_change": sum(1 for _, fl, rv in second if fl != "pass" and rv == "agreed_no_change"),
            "disagreed": sum(1 for _, fl, rv in second if fl != "pass" and rv == "disagreed"),
            "open": sum(1 for _, fl, rv in second if fl != "pass" and rv == "open"),
        },
    }
    return result, rep


def hours(v):
    return "not measured" if v is None else f"{v:g} h"


def rate(k, n, missing=0):
    if n == 0:
        return "no findings with a verdict"
    s = f"{k}/{n} ({100 * k / n:.1f}%)"
    if missing:
        s = f"at least {s}, at most {k + missing}/{n} ({100 * (k + missing) / n:.1f}%): outcomes missing"
    return s


def text(r):
    f = r["findings"]
    out = [f"Harness measures — {r['assessment']} assessment; inputs at {r['inputs_at']}", ""]
    out.append("Stage                Status       Review (person)      Rework (person)  Agent span    Re-checks")
    for s in r["stages"]:
        rv = hours(s["review_hours"]) if s["reviews"] else "no review"
        if s["review_hours_partial"] is not None:
            rv = f"{s['review_hours_partial']:g} h, {s['reviews_measured']} of {s['reviews']} reviews"
        ag = "not measured" if s["agent_minutes"] is None else f"{s['agent_minutes'] // 60}h{s['agent_minutes'] % 60:02d}"
        rc = (f"{s['rechecks_reproduced']} of {s['rechecks_selected']} selected reproduced"
              if s["rechecks_selected"] else "none recorded")
        rw = hours(s["rework_hours"]) if s["status"] == "confirmed" else "-"
        out.append(f"{s['stage']} {s['name']:<18} {str(s['status']):<12} {rv:<20} {rw:<16} {ag:<13} {rc}")
    n, miss = f["denominator"], len(f["verdict_without_outcome"])
    out += ["", "Stage 4 findings (count only findings with a verdict):",
            f"  strict unchanged:  {rate(f['strict_unchanged'], n, miss)}",
            f"  lenient unchanged: {rate(f['lenient_unchanged'], n, miss)}",
            f"  with a verdict {f['with_verdict']}, of them without an outcome {len(f['verdict_without_outcome'])}"
            + (f" ({', '.join(f['verdict_without_outcome'])})" if f["verdict_without_outcome"] else ""),
            f"  pending (assumption) {f['pending']}, not in the rates",
            f"  split or merged {f['split_merge']} (granularity, not a defect); severity changed {f['severity_changed']}; "
            f"changed on new input from the owner {f['new_input']}"]
    if f["other_status"]:
        out.append(f"  status not read as a verdict: {', '.join(f['other_status'])}")
    if miss:
        out.append(f"  INCOMPLETE: {miss} finding(s) with a verdict have no outcome row; record them before "
                   "any decision on quality is read from these shares")
    s2 = r["second_reading"]
    if s2["rows"]:
        out += ["", f"Second reading (optional, recommendations only): {s2['flags']} flags; the reviewer acted on "
                    f"{s2['acted']}, agreed without a change on {s2['agreed_no_change']}, disagreed with "
                    f"{s2['disagreed']}, left open {s2['open']}. Not a precision: a flag can be right and need no "
                    "change. Its cost is in the review hours above."]
    out += ["", "Re-checks are a selected sample: they say those claims held, not how accurate the whole output is."]
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser(description="Compute the harness measures of one engagement.")
    ap.add_argument("state", help="engagement-state.yml or sre/engagement-state.yml")
    ap.add_argument("--findings", metavar="DIR", help="findings folder (default: findings/ beside the state file, or one up)")
    ap.add_argument("--json", action="store_true", help="print JSON instead of text")
    a = ap.parse_args()
    if a.findings and not os.path.isdir(a.findings):
        print(f"harness-metrics.py: --findings {a.findings}: not a folder", file=sys.stderr)
        return 2
    r, rep = measure(a.state, a.findings)
    print(json.dumps(r, indent=2, sort_keys=True) if a.json else text(r))
    for e in rep.errors:
        print(e, file=sys.stderr)
    return 1 if rep.errors else 0


if __name__ == "__main__":
    sys.exit(main())
