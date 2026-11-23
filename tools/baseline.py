#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Compute the SRE baseline numbers from CSV exports and print them in Markdown.

    tools/baseline.py [incidents.csv] [--deploys deploys.csv] [--pages pages.csv]
                      [--map field=column ...] [--from DATE] [--to DATE] [--tz ZONE]
                      [--incidents-from/--incidents-to/--deploys-from/--deploys-to/
                       --pages-from/--pages-to DATE] [--assume-tz ZONE]
                      [--shift-hours N] [--shift-start HH:MM] [--no-rotation]
                      [--page-limit N] [--office-hours HH:MM-HH:MM]

Each number carries its method and window; a missing column prints
"not measured: <column> missing". Exit: 0 printed, 2 usage, unreadable file or bad time.
Columns, methods and output: tools/baseline.md. Stdlib only.
"""
import argparse
import csv
import math
import re
import sys
from datetime import datetime, timedelta, timezone

try:
    from zoneinfo import ZoneInfo
except ImportError:  # pragma: no cover
    ZoneInfo = None

# field -> default column name, per file
FIELDS = {
    "incidents": ("severity", "started", "detected", "recovered", "cause", "class"),
    "deploys": ("deployed", "committed", "failed", "restored", "rework"),
    "pages": ("paged",),
}
TRUE = {"1", "true", "yes", "y", "x", "failed", "fail"}


class DataError(Exception):
    pass


def zone(text):
    """A time zone: UTC, Z, an offset +HH:MM, or an IANA name."""
    if text in ("UTC", "Z"):
        return timezone.utc
    m = re.fullmatch(r"([+-])(\d\d):(\d\d)", text)
    if m:
        d = timedelta(hours=int(m[2]), minutes=int(m[3]))
        return timezone(-d if m[1] == "-" else d)
    if ZoneInfo is not None:
        try:
            return ZoneInfo(text)
        except Exception:
            pass
    raise argparse.ArgumentTypeError(f"unknown time zone: {text}")


class Table:
    """One CSV export: rows as dicts keyed by field, the columns found, a row count."""

    def __init__(self, kind, path, mapping, assume_tz):
        self.kind, self.path, self.assume_tz = kind, path, assume_tz
        self.col = {f: mapping.get(f, f) for f in FIELDS[kind]}
        self.empty = False
        try:
            with open(path, newline="", encoding="utf-8-sig") as fh:
                reader = csv.DictReader(fh)
                header = [h.strip() for h in (reader.fieldnames or [])]
                reader.fieldnames = header
                self.rows = [(i, r) for i, r in enumerate(reader, start=2)]
        except OSError as e:
            raise DataError(f"{path}: cannot read: {e.strerror}")
        self.empty = not header
        self.have = {f for f, c in self.col.items() if c in header}

    def missing(self, *fields):
        """The first missing column among fields, as the not-measured text, or None."""
        if self.empty:
            return "not measured: file empty"
        for f in fields:
            if f not in self.have:
                return f"not measured: {self.col[f]} missing"
        if not self.rows:
            return "not measured: no rows"
        return None

    def cell(self, row, field):
        return (row[1].get(self.col[field]) or "").strip() if field in self.have else ""

    def time(self, row, field):
        text = self.cell(row, field)
        if not text:
            return None
        iso = text[:-1] + "+00:00" if text.endswith(("Z", "z")) else text
        try:
            t = datetime.fromisoformat(iso)
        except ValueError:
            raise DataError(f"{self.path}:{row[0]}: {self.col[field]}: not an ISO 8601 time: {text}")
        if t.tzinfo is None:
            if self.assume_tz is None:
                raise DataError(f"{self.path}:{row[0]}: {self.col[field]}: time has no offset: {text}"
                                " (add one, or pass --assume-tz)")
            t = t.replace(tzinfo=self.assume_tz)
        return t.astimezone(timezone.utc)

    def flag(self, row, field):
        return self.cell(row, field).lower() in TRUE


def nearest_rank(values, p):
    """Nearest-rank percentile: the value at rank ceil(p/100 * n) of the sorted values."""
    v = sorted(values)
    return v[max(1, math.ceil(p / 100 * len(v))) - 1]


def duration(td):
    m = round(td.total_seconds() / 60)
    if m < 120:
        return f"{m} min"
    if m < 48 * 60:
        return f"{m // 60} h {m % 60:02d} min"
    return f"{m // 1440} d {(m % 1440) // 60} h"


def pct(a, b):
    return f"{100 * a / b:.1f}% ({a} of {b})"


class Out:
    def __init__(self):
        self.lines = []

    def section(self, title, note):
        self.lines += ["", f"## {title}", "", note, "",
                       "| Number | Value | n | Method | Window |", "|---|---|---|---|---|"]

    def row(self, name, value, n, method, window):
        self.lines.append(f"| {name} | {value} | {n} | {method} | {window} |")

    def gap(self, name, reason, method):
        self.row(name, reason, "—", method, "—")


def windowed(table, field, args):
    """Rows whose main time is in the input's window; the window text."""
    start, end, flags = args.window[table.kind]
    kept = []
    for r in table.rows:
        t = table.time(r, field)
        if t is None:
            raise DataError(f"{table.path}:{r[0]}: {table.col[field]}: empty")
        if (start is None or t >= start) and (end is None or t < end):
            kept.append((r, t))
    if start is not None and end is not None:
        lo, hi, src = start, end, flags
    elif kept:
        ts = [t for _, t in kept]
        lo = start or min(ts)
        hi = end or max(ts)
        src = "from data" if start is None and end is None else f"{flags} and data"
    else:
        return kept, None, None, "no rows in the window"
    text = f"{lo.astimezone(args.tz):%Y-%m-%d} to {(hi - timedelta(microseconds=1) if end else hi).astimezone(args.tz):%Y-%m-%d} ({src})"
    return kept, lo, hi, text


def spread(out, name, pairs, total, what, window):
    """Median and p90 of durations; n states how many rows had both times."""
    if not pairs:
        out.gap(f"{name}, median", f"not measured: no row with {what}", "nearest-rank median")
        return
    n = f"{len(pairs)} of {total}"
    out.row(f"{name}, median", duration(nearest_rank(pairs, 50)), n, f"nearest-rank median of {what}", window)
    out.row(f"{name}, p90", duration(nearest_rank(pairs, 90)), n, f"nearest-rank p90 of {what}", window)


def durations(table, kept, a, b, *, only=None):
    res = []
    for r, _ in kept:
        if only is not None and not only(r):
            continue
        ta, tb = table.time(r, a), table.time(r, b)
        if ta is None or tb is None:
            continue
        if tb < ta:
            raise DataError(f"{table.path}:{r[0]}: {table.col[b]} is before {table.col[a]}")
        res.append(tb - ta)
    return res


def natural(s):
    return [int(p) if p.isdigit() else p.lower() for p in re.split(r"(\d+)", s)]


def incidents(out, t, args):
    out.section("Incidents", f"Source: `{t.path}`.")
    gone = t.missing("started")
    if gone:
        for name in ("Incidents per severity", "Time to detect", "Time to recover", "Recurrence share"):
            out.gap(name, gone, "—")
        return
    kept, lo, hi, window = windowed(t, "started", args)
    total = len(kept)
    if not kept:
        out.gap("Incidents per severity", "not measured: no rows in the window", "—")
        return
    gone = t.missing("severity")
    if gone:
        out.gap("Incidents per severity", gone, "count of rows per severity")
    else:
        sev = {}
        for r, _ in kept:
            sev.setdefault(t.cell(r, "severity") or "(blank)", []).append(r)
        for s in sorted(sev, key=natural):
            out.row(f"Incidents, severity {s}", len(sev[s]), total, "count of rows with this severity", window)
    groups = [("all", lambda r: True)]
    by = [f for f in ("severity", "class") if not t.missing(f)]
    if "class" in by:  # e.g. outage and data defect: their times differ by orders of magnitude
        for c in sorted({t.cell(r, "class") or "(blank)" for r, _ in kept}, key=natural):
            out.row(f"Incidents, class {c}", sum((t.cell(r, "class") or "(blank)") == c for r, _ in kept),
                    total, "count of rows with this class", window)
    for f in by:
        groups += [(f"{f} {v}", (lambda f, v: lambda r: (t.cell(r, f) or "(blank)") == v)(f, v))
                   for v in sorted({t.cell(r, f) or "(blank)" for r, _ in kept}, key=natural)]
    for name, field, what in (("Time to detect", "detected", "detected − started"),
                              ("Time to recover", "recovered", "recovered − started")):
        miss = t.missing(field)
        if miss:
            out.gap(name, miss, f"nearest-rank median and p90 of {what}")
            continue
        for g, keep in groups:
            sub = [x for x in kept if keep(x[0])]
            label = name if g == "all" else f"{name}, {g}"
            spread(out, label, durations(t, sub, "started", field), len(sub), what, window)
    miss = t.missing("cause")
    if miss:
        out.gap("Recurrence share", miss, "incidents repeating an earlier cause")
    else:
        seen, repeats, with_cause = set(), 0, 0
        for r, _ in sorted(kept, key=lambda x: x[1]):
            c = t.cell(r, "cause").lower()
            if not c:
                continue
            with_cause += 1
            repeats += c in seen
            seen.add(c)
        if with_cause:
            out.row("Recurrence share", pct(repeats, with_cause), f"{with_cause} of {total}",
                    "incidents whose cause matches an earlier incident's, of incidents with a cause", window)
        else:
            out.gap("Recurrence share", "not measured: no row with a cause", "—")


def deploys(out, t, args):
    out.section("Deploys (DORA)", f"Source: `{t.path}`. Deployment rework rate is recorded when the "
                "export flags it; it does not gate a level.")
    gone = t.missing("deployed")
    if gone:
        for name in ("Deployment frequency", "Change lead time", "Change failure rate",
                     "Failed deployment recovery time", "Deployment rework rate"):
            out.gap(name, gone, "—")
        return
    kept, lo, hi, window = windowed(t, "deployed", args)
    n = len(kept)
    if not kept:
        out.gap("Deployment frequency", "not measured: no rows in the window", "—")
        return
    days = (hi.astimezone(args.tz).date() - lo.astimezone(args.tz).date()).days + (0 if args.window["deploys"][1] else 1)
    out.row("Deployment frequency", f"{7 * n / days:.1f} per week", n,
            f"deploys ÷ {days} days in the window × 7", window)
    miss = t.missing("committed")
    if miss:
        out.gap("Change lead time", miss, "nearest-rank median and p90 of deployed − committed")
    else:
        spread(out, "Change lead time", durations(t, kept, "committed", "deployed"), n,
               "deployed − committed", window)
    miss = t.missing("failed")
    failed = None
    if miss:
        out.gap("Change failure rate", miss, "failed deploys ÷ deploys")
    else:
        failed = [x for x in kept if t.flag(x[0], "failed")]
        out.row("Change failure rate", pct(len(failed), n), n, "deploys flagged failed ÷ deploys", window)
    miss = t.missing("failed", "restored")
    if miss:
        out.gap("Failed deployment recovery time", miss, "nearest-rank median and p90 of restored − deployed")
    else:
        spread(out, "Failed deployment recovery time", durations(t, failed, "deployed", "restored"),
               len(failed), "restored − deployed, failed deploys", window)
    miss = t.missing("rework")
    if miss:
        out.gap("Deployment rework rate", miss, "rework deploys ÷ deploys")
    else:
        rw = sum(t.flag(r, "rework") for r, _ in kept)
        out.row("Deployment rework rate", pct(rw, n), n,
                "deploys flagged rework (unplanned, to fix a production issue) ÷ deploys", window)


def pages(out, t, args):
    o_from, o_to = args.office_hours
    unit = "working day" if args.no_rotation else "shift"
    shifts = ("No rotation (--no-rotation): pages per working day, Monday to Friday" if args.no_rotation
              else f"Shifts: {args.shift_hours} h from {args.shift_start}, every shift counted")
    out.section("Pages", f"Source: `{t.path}`. Clock: {args.tz_name}. {shifts}. Office hours: {o_from}–{o_to} "
                "Monday to Friday; public holidays are not known to the tool.")
    gone = t.missing("paged")
    if gone:
        out.gap(f"Pages per {unit}", gone, "—")
        out.gap("Off-hours share", gone, "—")
        return
    kept, lo, hi, window = windowed(t, "paged", args)
    if not kept:
        out.gap(f"Pages per {unit}", "not measured: no rows in the window", "—")
        return
    if args.no_rotation:
        return working_days(out, kept, lo, hi, window, args)
    hh, mm = map(int, args.shift_start.split(":"))
    step = timedelta(hours=args.shift_hours)
    anchor = lo.astimezone(args.tz).replace(hour=hh, minute=mm, second=0, microsecond=0)
    while anchor > lo:
        anchor -= step
    end = hi if args.window["pages"][1] else hi + timedelta(microseconds=1)
    shifts = max(1, math.ceil((end - anchor) / step))
    per = [0] * shifts
    off = 0
    for _, ts in kept:
        per[min(shifts - 1, int((ts - anchor) / step))] += 1
        local = ts.astimezone(args.tz)
        hm = f"{local:%H:%M}"
        off += local.weekday() >= 5 or not (o_from <= hm < o_to)
    n = len(kept)
    out.row("Pages per shift, mean", f"{n / shifts:.2f}", n, f"pages ÷ {shifts} shifts overlapping the window", window)
    out.row("Pages per shift, max", max(per), n, "most pages in one shift", window)
    over = sum(c > args.page_limit for c in per)
    out.row(f"Shifts over {args.page_limit} pages", pct(over, shifts), shifts,
            f"shifts with more than {args.page_limit} pages ÷ shifts", window)
    out.row("Off-hours share", pct(off, n), n, "pages outside office hours ÷ pages", window)


def off_hours(ts, args):
    local = ts.astimezone(args.tz)
    o_from, o_to = args.office_hours
    return local.weekday() >= 5 or not (o_from <= f"{local:%H:%M}" < o_to)


def working_days(out, kept, lo, hi, window, args):
    """Pages per working day: one operator in working hours, no rotation of shifts."""
    first = lo.astimezone(args.tz).date()
    last = (hi - timedelta(microseconds=1) if args.window["pages"][1] else hi).astimezone(args.tz).date()
    days = [first + timedelta(d) for d in range((last - first).days + 1)]
    per = {d: 0 for d in days if d.weekday() < 5}
    for _, ts in kept:
        d = ts.astimezone(args.tz).date()
        if d in per:
            per[d] += 1
    n, wd = len(kept), max(1, len(per))
    on = sum(per.values())
    out.row("Pages per working day, mean", f"{on / wd:.2f}", n,
            f"pages on working days ÷ {len(per)} working days in the window", window)
    out.row("Pages per working day, max", max(per.values(), default=0), n, "most pages on one working day", window)
    over = sum(c > args.page_limit for c in per.values())
    out.row(f"Working days over {args.page_limit} pages", pct(over, wd), len(per),
            f"working days with more than {args.page_limit} pages ÷ working days", window)
    out.row("Off-hours share", pct(sum(off_hours(ts, args) for _, ts in kept), n), n,
            "pages outside office hours ÷ pages", window)


def main(argv=None):
    ap = argparse.ArgumentParser(description="SRE baseline numbers from CSV exports (tools/baseline.md).")
    ap.add_argument("incidents", nargs="?", help="optional: without it the incident numbers are not measured")
    ap.add_argument("--deploys")
    ap.add_argument("--pages")
    ap.add_argument("--map", action="append", default=[], metavar="FIELD=COLUMN")
    ap.add_argument("--from", dest="start", metavar="YYYY-MM-DD")
    ap.add_argument("--to", dest="end", metavar="YYYY-MM-DD", help="inclusive")
    ap.add_argument("--tz", default="UTC", help="clock for dates, shifts and office hours")
    ap.add_argument("--assume-tz", help="zone for times without an offset (default: reject them)")
    ap.add_argument("--shift-hours", type=int, default=12)
    ap.add_argument("--shift-start", default="08:00")
    ap.add_argument("--no-rotation", action="store_true",
                    help="one operator in working hours: pages per working day instead of per shift")
    for kind in FIELDS:
        ap.add_argument(f"--{kind}-from", metavar="YYYY-MM-DD", help=f"window for {kind} only; overrides --from")
        ap.add_argument(f"--{kind}-to", metavar="YYYY-MM-DD", help=f"window for {kind} only; overrides --to")
    ap.add_argument("--page-limit", type=int, default=2)
    ap.add_argument("--office-hours", default="09:00-18:00")
    args = ap.parse_args(argv)
    try:
        args.tz_name, args.tz = args.tz, zone(args.tz)
        args.assume_tz = zone(args.assume_tz) if args.assume_tz else None
    except argparse.ArgumentTypeError as e:
        ap.error(str(e))
    hm = r"([01]\d|2[0-3]):[0-5]\d"
    if not re.fullmatch(hm, args.shift_start) or args.shift_hours < 1:
        ap.error("--shift-start is HH:MM and --shift-hours at least 1")
    m = re.fullmatch(f"({hm})-({hm})", args.office_hours)
    if not m:
        ap.error("--office-hours is HH:MM-HH:MM")
    args.office_hours = (m[1], m[3])
    def day(v, end):
        d = datetime.strptime(v, "%Y-%m-%d").replace(tzinfo=args.tz)
        return (d + timedelta(days=1) if end else d).astimezone(timezone.utc)
    args.window = {}
    try:
        for kind in FIELDS:  # an input's own window, else --from/--to
            own = getattr(args, f"{kind}_from"), getattr(args, f"{kind}_to")
            v = [o or g for o, g in zip(own, (args.start, args.end))]
            flags = f"--{kind}-from/--{kind}-to" if any(own) else "--from/--to"
            args.window[kind] = (v[0] and day(v[0], False), v[1] and day(v[1], True), flags)
    except ValueError:
        ap.error("--from, --to and the per-input windows are YYYY-MM-DD")
    mapping = {}
    known = {f for fs in FIELDS.values() for f in fs}
    for m in args.map:
        f, sep, c = m.partition("=")
        if not sep or f not in known or not c:
            ap.error(f"--map {m}: expected FIELD=COLUMN, FIELD one of {', '.join(sorted(known))}")
        mapping[f] = c
    out = Out()
    out.lines.append("# Baseline")
    try:
        for kind, path, fn, title in (("incidents", args.incidents, incidents, "Incidents"),
                                      ("deploys", args.deploys, deploys, "Deploys (DORA)"),
                                      ("pages", args.pages, pages, "Pages")):
            if path:
                fn(out, Table(kind, path, mapping, args.assume_tz), args)
            else:
                what = "incidents export" if kind == "incidents" else f"--{kind} export"
                out.lines += ["", f"## {title}", "", f"not measured: no {what}"]
    except DataError as e:
        print(f"baseline.py: {e}", file=sys.stderr)
        return 2
    print("\n".join(out.lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
