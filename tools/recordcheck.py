#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Check the records of an engagement: evidence catalogs, and findings against the records they cite.

    tools/recordcheck.py catalog FILE.md... [--external FILE.md]...
        the evidence catalog in FILE.md: E- ids cited resolve, ids are unique, entries carry
        their window, result and limits (the check tools/report-pdf.sh runs on its sources)
    tools/recordcheck.py findings F-NNN.md... [--catalog FILE]... [--gaps FILE]...
                                 [--findings DIR] [--owner-questions FILE] [--decisions FILE]
        each finding in the format of templates/finding.md, and the F-, G-, E- and D- ids it
        cites against the records given

Exit: 0 clean (notes allowed), 1 rule violations, 2 usage or a file that cannot be read.
Violations go to standard error as `file:line: RULE message`; notes ("not verifiable") to
standard output. A clean check says the records hang together; it never says a claim is true.
Rules: tools/recordcheck.md.
"""
import argparse
import os
import re
import sys

ID = r"\d{2,4}"
VERDICTS = ("confirmed", "disputed", "refuted", "inconclusive", "resolved")
STATUSES = ("assumption",) + VERDICTS


def read(path):
    try:
        with open(path, encoding="utf-8") as f:
            return f.read().splitlines()
    except (OSError, UnicodeDecodeError) as e:
        print(f"recordcheck.py: cannot read {path}: {e}", file=sys.stderr)
        sys.exit(2)


def cells(line):
    s = line.strip()
    if not (s.startswith("|") and s.endswith("|")):
        return None
    return [c.strip() for c in s[1:-1].split("|")]


def is_sep(c):
    return c is not None and all(re.fullmatch(r":?-{3,}:?", x.strip()) for x in c)


def tables(lines):
    """Yield (header cells lower case, [(line number, cells)]) for each table outside code fences."""
    i, fence = 0, False
    while i < len(lines):
        if lines[i].lstrip().startswith("```"):
            fence = not fence
            i += 1
            continue
        head = None if fence else cells(lines[i])
        if head and i + 1 < len(lines) and is_sep(cells(lines[i + 1])):
            rows, j = [], i + 2
            while j < len(lines) and cells(lines[j]) is not None:
                rows.append((j + 1, cells(lines[j])))
                j += 1
            yield [h.lower() for h in head], rows
            i = j
            continue
        i += 1


def defined(prefix, paths):
    """Where each id of a prefix is defined: a heading "## X-NN …" or a table row whose first cell is it.
    Returns {id: [(path, line)]}."""
    head = re.compile(rf"^#{{2,4}} ({prefix}-{ID})\b")
    row = re.compile(rf"^\|\s*({prefix}-{ID})\s*\|")
    out = {}
    for p in paths:
        for n, line in enumerate(read(p), 1):
            m = head.match(line) or row.match(line)
            if m:
                out.setdefault(m.group(1), []).append((p, n))
    return out


def cited(prefix, lines):
    """Ids of a prefix cited anywhere in the lines, with the first line each appears on."""
    out = {}
    for n, line in enumerate(lines, 1):
        for m in re.finditer(rf"\b{prefix}-{ID}\b", line):
            out.setdefault(m.group(0), n)
    return out


# --- evidence catalog: one implementation for report-pdf.sh and the finding check -----------

def catalog_fields(paths):
    """Catalog entries missing a field: [(path, line, id, [missing])]. Heading entries carry "Checked at" or
    "window", "Result" and "Limits" in their body; table rows fill the Window (or Checked at),
    Result and Limits columns."""
    bad = []
    for p in paths:
        lines = read(p)
        cur, at, body = None, 0, []

        def close():
            if cur:
                b = "\n".join(body)
                miss = [n for n, rx in (("window", r"checked at|window"), ("result", r"\bresult\b"),
                                         ("limits", r"\blimits?\b")) if not re.search(rx, b, re.I)]
                if miss:
                    bad.append((p, at, cur, miss))

        for ln, line in enumerate(lines, 1):
            m = re.match(rf"^#{{2,4}} (E-{ID})\b", line)
            if m:
                close()
                cur, at, body = m.group(1), ln, []
                continue
            if re.match(r"^#{1,4} ", line):
                close()
                cur, body = None, []
                continue
            if cur:
                body.append(line)
        close()
        for head, rows in tables(lines):
            w = next((k for k, h in enumerate(head) if re.search(r"window|checked", h)), None)
            r = next((k for k, h in enumerate(head) if h.startswith("result")), None)
            lim = next((k for k, h in enumerate(head) if re.match(r"limits?", h)), None)
            for ln, c in rows:
                if not c or not re.fullmatch(rf"E-{ID}", c[0]):
                    continue
                miss = [n for n, k in (("window", w), ("result", r), ("limits", lim))
                        if k is None or k >= len(c) or not c[k].strip()]
                if miss:
                    bad.append((p, ln, c[0], miss))
    return bad


def check_catalog(files, external):
    """The catalog check, with the messages report-pdf.sh has always printed. Returns failed?"""
    cat = defined("E", files)
    if not cat and not external:
        return False
    fail = False
    dup = sorted(i for i, where in cat.items() if len(where) > 1)
    if dup:
        print(f"✗ evidence ids defined more than once: {' '.join(dup)}")
        fail = True
    known = set(cat) | set(defined("E", external))
    unres = sorted({i for p in files for i in cited("E", read(p))} - known)
    if unres:
        print(f"✗ evidence ids cited without a catalog entry: {' '.join(unres)[:300]}")
        fail = True
    bad = catalog_fields(files)
    if bad:
        print("✗ evidence entries missing a field:")
        for _, _, i, miss in bad[:10]:
            print(f"{i} (no {', '.join(miss)})")
        fail = True
    if unres or bad:
        print('  An entry is a heading "### E-NNN — name" with "Checked at:" or "Data window:", "Result:" and '
              '"Limits:" lines, or a table row whose first cell is the E- id under columns Window (or Checked at), '
              'Result and Limits, each filled.')
    return fail


# --- findings ---------------------------------------------------------------------------------

class Report:
    def __init__(self):
        self.errors, self.notes = [], []

    def error(self, path, line, rule, msg):
        self.errors.append(f"{path}:{line}: {rule} {msg}")

    def note(self, msg):
        if msg not in self.notes:
            self.notes.append(msg)


def section(lines, label):
    """(line number, text) of a bold-labelled paragraph "**Label.** …" up to the next blank line."""
    for n, line in enumerate(lines, 1):
        if line.startswith(f"**{label}"):
            text = [line[len(label) + 4:] if line.startswith(f"**{label}.**") else line.split("**", 2)[-1]]
            for nxt in lines[n:]:
                if not nxt.strip() or nxt.startswith("**"):
                    break
                text.append(nxt)
            return n, " ".join(text).strip()
    return None, None


def verdict_batch(path):
    """Rows of the verdict batch: {F-id: [(line, verdict, [D-ids])]}; one row may name several findings."""
    out = {}
    for head, rows in tables(read(path)):
        f = next((k for k, h in enumerate(head) if h.startswith("finding")), None)
        v = next((k for k, h in enumerate(head) if h.startswith("verdict")), None)
        d = next((k for k, h in enumerate(head) if h.startswith("decision")), None)
        if None in (f, v, d):
            continue
        for n, c in rows:
            if max(f, v, d) >= len(c):
                continue
            verdict = c[v].strip().lower()
            ds = re.findall(rf"\bD-{ID}\b", c[d])
            for fid in re.findall(rf"\bF-{ID}\b", c[f]):
                out.setdefault(fid, []).append((n, verdict, ds))
    return out


def check_finding(path, rep, ctx):
    lines = read(path)
    name = os.path.basename(path)
    m = re.match(rf"^(F-{ID})\.md$", name)
    title = next(((n, l) for n, l in enumerate(lines, 1) if l.startswith("# ")), (1, ""))
    tid = re.match(rf"^# (F-{ID})\b", title[1])
    if not m or not tid or tid.group(1) != m.group(1):
        rep.error(path, title[0], "RC01", f"a finding is findings/F-NNN.md with the same id in its title; "
                                          f"got {name} and {title[1][:40]!r}")
        return
    fid = m.group(1)

    status = None
    for head, rows in tables(lines):
        s = next((k for k, h in enumerate(head) if h.startswith("status")), None)
        dt = next((k for k, h in enumerate(head) if h.startswith("date")), None)
        if s is not None and rows:
            n, c = rows[0]
            status = c[s].strip().lower() if s < len(c) else ""
            if status not in STATUSES:
                rep.error(path, n, "RC02", f"status must be one of {', '.join(STATUSES)}; got {status!r}")
                status = None
            if dt is None or dt >= len(c) or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", c[dt].strip()):
                rep.error(path, n, "RC02", "the status table needs a date, YYYY-MM-DD")
        break
    else:
        rep.error(path, 1, "RC02", "no status table (Status | Date | Source | Evidence level)")

    sev = next(((n, l) for n, l in enumerate(lines, 1) if l.startswith("**Severity:**")), None)
    if sev is None:
        rep.error(path, 1, "RC03", "no **Severity:** line")
    else:
        rest = sev[1][len("**Severity:**"):].split(" · **")[0]
        mm = re.match(r"\s*(P[123])\b(.*)$", rest)
        if not mm:
            rep.error(path, sev[0], "RC03", "severity must be P1, P2 or P3")
        elif not re.search(r"[A-Za-z]{2,}", mm.group(2)):
            rep.error(path, sev[0], "RC03", f"{mm.group(1)} without its reason: say why, on the same line")

    n, seen = section(lines, "What we see")
    if n is None:
        rep.error(path, 1, "RC04", "no **What we see.** paragraph")
    elif not re.search(rf"\bE-{ID}\b", seen):
        rep.error(path, n, "RC04", "*What we see* cites no evidence id (E-NNN)")
    n, lim = section(lines, "Confidence and limits")
    if n is None or len(re.sub(r"[^A-Za-z]", "", lim or "")) < 10:
        rep.error(path, n or 1, "RC04", "*Confidence and limits* missing or empty: say what the evidence does not establish")

    # references to other records
    refs = {"E": ("catalog", "--catalog", ctx["E"]), "G": ("gap records", "--gaps", ctx["G"]),
            "F": ("findings", "--findings", ctx["F"]), "D": ("decision register", "--decisions", ctx["D"])}
    for prefix, (what, opt, known) in refs.items():
        ids = {i: ln for i, ln in cited(prefix, lines).items() if not (prefix == "F" and i == fid)}
        if not ids:
            continue
        if known is None:
            rep.note(f"{prefix}- references not verifiable: no {what} given ({opt})")
            continue
        for i, ln in sorted(ids.items()):
            if i not in known:
                rep.error(path, ln, "RC05", f"{i} cited, but not in the {what}")

    if status == "confirmed" or (ctx["batch"] is not None and fid in ctx["batch"]):
        if ctx["batch"] is None:
            if status == "confirmed":
                rep.note("confirmed findings: the decision behind the verdict is not verifiable: "
                         "no verdict batch given (--owner-questions)")
            return
        rows = ctx["batch"].get(fid, [])
        if status == "confirmed" and not any(v == "confirmed" and ds for _, v, ds in rows):
            rep.error(path, 1, "RC07", f"confirmed, but the verdict batch has no row confirming {fid} with a D- id")
        for ln, v, ds in rows:
            if status and v in VERDICTS and v != status:
                rep.error(path, 1, "RC08", f"status {status}, but the verdict batch says {v} "
                                           f"({ctx['batch_path']}:{ln})")
            if ctx["D"] is not None:
                for d in ds:
                    if d not in ctx["D"]:
                        rep.error(ctx["batch_path"], ln, "RC05", f"{d} (verdict of {fid}) not in the decision register")


def check_findings(a):
    rep = Report()
    files = a.files
    ctx = {"E": None, "G": None, "F": None, "D": None, "batch": None, "batch_path": a.owner_questions}
    if a.catalog:
        ctx["E"] = set(defined("E", a.catalog))
        for p, ln, i, miss in catalog_fields(a.catalog):
            rep.error(p, ln, "RC06", f"evidence entry {i} lacks {', '.join(miss)}")
    if a.gaps:
        ctx["G"] = set(defined("G", a.gaps))
    if a.decisions:
        ctx["D"] = set(defined("D", [a.decisions]))
    fdir = a.findings or (os.path.dirname(files[0]) if files else None)
    if fdir and os.path.isdir(fdir):
        ctx["F"] = {m.group(1) for x in os.listdir(fdir) for m in [re.match(rf"^(F-{ID})\.md$", x)] if m}
    if a.owner_questions:
        ctx["batch"] = verdict_batch(a.owner_questions)
    # one id, one definition
    for prefix, paths in (("E", a.catalog or []), ("G", a.gaps or []), ("D", [a.decisions] if a.decisions else [])):
        for i, where in sorted(defined(prefix, paths).items()):
            if len(where) > 1:
                p, n = where[1]
                rep.error(p, n, "RC09", f"{i} defined more than once (first at {where[0][0]}:{where[0][1]})")
    for f in files:
        check_finding(f, rep, ctx)
    for n in rep.notes:
        print(f"note: {n}")
    for e in rep.errors:
        print(e, file=sys.stderr)
    if not rep.errors:
        print(f"✓ {len(files)} finding(s): form and references checked. This does not confirm any claim.")
    return 1 if rep.errors else 0


def main():
    ap = argparse.ArgumentParser(description="Check evidence catalogs and findings.")
    sub = ap.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("catalog", help="the evidence catalog in Markdown sources")
    c.add_argument("files", nargs="+")
    c.add_argument("--external", action="append", default=[], metavar="FILE",
                   help="a catalog kept apart: its entries resolve citations, it is not itself checked")
    f = sub.add_parser("findings", help="findings and the records they cite")
    f.add_argument("files", nargs="+", metavar="F-NNN.md")
    f.add_argument("--catalog", action="append", metavar="FILE", help="evidence catalog(s): E- entries")
    f.add_argument("--gaps", action="append", metavar="FILE", help="gap records: G- entries (the stage 3 report)")
    f.add_argument("--findings", metavar="DIR", help="all findings, for F- references (default: the folder of the first file)")
    f.add_argument("--owner-questions", metavar="FILE", help="the verdict batch: Finding, Verdict and Decision columns")
    f.add_argument("--decisions", metavar="FILE", help="the decision register: D- entries")
    a = ap.parse_args()
    if a.cmd == "catalog":
        return 1 if check_catalog(a.files, a.external) else 0
    return check_findings(a)


if __name__ == "__main__":
    sys.exit(main())
