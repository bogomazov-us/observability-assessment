#!/usr/bin/env python3
"""Lint an observability-spec.yml: the checkable core of a Blueprint specification set.

The nine Markdown documents of the spec set stay the human documents; this file holds the
chain journey -> function -> signal -> SLO -> alert -> owner -> runbook in a form a machine can
check. Rules and the kit rule each one enforces: tools/speclint.md.

Exit: 0 clean (warnings allowed unless --strict), 1 findings, 2 usage or parse error.
"""
import argparse
import os
import re
import sys

try:
    import yaml
except ImportError:  # pragma: no cover
    sys.stderr.write("speclint: PyYAML is required (pip install pyyaml)\n")
    sys.exit(2)



class _Loader(yaml.SafeLoader):
    """Safe loader that keeps every repeated mapping key it meets.

    PyYAML keeps the last value of a repeated key and drops the others without a word, so a
    second `good:` hides the first and a second `id:` renames a row. The linter reports them.
    """

    def __init__(self, stream):
        super().__init__(stream)
        self.repeated = []

    def construct_mapping(self, node, deep=False):
        seen = set()
        for key_node, _ in node.value:
            key = self.construct_object(key_node, deep=deep)
            try:
                if key in seen:
                    self.repeated.append((key_node.start_mark.line + 1, key))
                seen.add(key)
            except TypeError:  # unhashable key: construct_mapping reports it
                pass
        return super().construct_mapping(node, deep=deep)


def load(fh):
    """The document and its repeated keys as (line, key)."""
    loader = _Loader(fh)
    try:
        return loader.get_single_data(), loader.repeated
    finally:
        loader.dispose()


CLASSES = {"expected", "failure", "caller_defect", "ambiguous", "unknown", "none"}
USER_IMPACTS = {"blocked", "degraded", "unaffected", "unknown"}
SIGNAL_STATES = {"live", "to_build"}
ALERT_STATES = {"shadow", "paging"}
SEVERITIES = {"P1", "P2", "P3"}
REFUSAL_TREATMENTS = {"excluded", "good"}
DECISION_STATUSES = {"proposed", "confirmed"}
SLO_FIELDS = ("subject", "good", "valid", "bad", "target", "window", "owner")
P1_FIELDS = ("owner", "runbook", "delivery_test", "min_volume", "grouping")
POOLED = {"all", "pooled", "none", "global", "service", "total"}
PLACEHOLDER = re.compile(r"^\[[^\]]*\]$")
# Known keys per section; anything else is a typo or an engagement's own field (prefix x_).
COMMON = {"note", "source"}
KNOWN = {
    "(root)": {"spec", "journeys", "taxonomy", "signals", "attempts", "slos", "alerts"},
    "spec": {"name", "version"},
    "journeys": {"id", "name", "success", "functions", "requirement"},
    "functions": {"id", "name", "route", "success", "requirement", "current", "severity",
                  "service", "status"},
    "taxonomy": {"function", "code", "context", "http", "class", "customer_sees", "user_impact", "confirmed_by",
                 "reconciliation", "status"},
    "signals": {"function", "name", "emitted_by", "attributes", "state", "evidence",
                "status"},
    "attempts": {"id", "name", "journey", "functions", "outcomes", "decided_by", "rules",
                 "unclassified", "ambiguous_after", "reconciliation", "status"},
    "slos": {"id", "subject", "good", "valid", "bad", "bad_reason", "expected_refusals",
             "traffic", "target", "window", "owner", "status"},
    "alerts": {"id", "slo", "severity", "condition", "for", "min_volume", "grouping", "notifies",
               "runbook", "delivery_test", "state", "owner", "status"},
}


class Linter:
    def __init__(self, path, check_files):
        self.path = path
        self.check_files = check_files
        self.findings = []  # (severity, where, rule, message)

    def add(self, sev, where, rule, msg):
        self.findings.append((sev, where, rule, msg))

    def err(self, where, rule, msg):
        self.add("error", where, rule, msg)

    def warn(self, where, rule, msg):
        self.add("warning", where, rule, msg)

    # -- helpers -----------------------------------------------------------------------------

    def items(self, doc, key):
        """A top-level list section; anything else is a structure error."""
        val = doc.get(key)
        if val is None:
            return []
        if not isinstance(val, list):
            self.err(key, "SL000", "must be a list")
            return []
        out = []
        for i, it in enumerate(val):
            if not isinstance(it, dict):
                self.err("%s[%d]" % (key, i), "SL000", "must be a mapping")
                continue
            out.append(("%s[%d]" % (key, i), it))
        return out

    @staticmethod
    def blank(v):
        return v is None or (isinstance(v, str) and not v.strip()) or v == [] or v == {}

    def placeholders(self, node, where):
        if isinstance(node, dict):
            for k, v in node.items():
                self.placeholders(v, "%s.%s" % (where, k) if where else str(k))
        elif isinstance(node, list):
            for i, v in enumerate(node):
                self.placeholders(v, "%s[%d]" % (where, i))
        elif isinstance(node, str) and PLACEHOLDER.match(node.strip()):
            self.warn(where, "SL016", "placeholder left: %s" % node.strip())

    # -- the rules ---------------------------------------------------------------------------

    def run(self, doc):
        if not isinstance(doc, dict):
            self.err("(root)", "SL000", "the spec must be a mapping with journeys, taxonomy, "
                     "signals, slos, alerts")
            return
        self.placeholders(doc, "")
        self.keys(doc)

        # Functions (inside journeys) and attempts: the ids everything else refers to.
        functions = {}
        seen_ids = {}
        journeys = set()
        for jw, j in self.items(doc, "journeys"):
            if self.blank(j.get("id")):
                self.err(jw + ".id", "SL000", "journey without an id")
            else:
                self.unique(seen_ids, j["id"], jw)
                journeys.add(j["id"])
            fl = j.get("functions") or []
            if not isinstance(fl, list):
                self.err(jw + ".functions", "SL000", "must be a list")
                continue
            for i, f in enumerate(fl):
                fw = "%s.functions[%d]" % (jw, i)
                if not isinstance(f, dict) or self.blank(f.get("id")):
                    self.err(fw, "SL000", "function without an id")
                    continue
                self.unique(seen_ids, f["id"], fw)
                functions[f["id"]] = fw
                if self.blank(f.get("requirement")):
                    self.warn(fw + ".requirement", "SL017", "function %r without the source of "
                              "its requirement (journey model, capture, kick-off note)" % f["id"])

        attempts = {}
        for aw, a in self.items(doc, "attempts"):
            if self.blank(a.get("id")):
                self.err(aw + ".id", "SL000", "attempt without an id")
                continue
            self.unique(seen_ids, a["id"], aw)
            attempts[a["id"]] = a
            if not self.blank(a.get("journey")) and a["journey"] not in journeys:
                self.err(aw + ".journey", "SL013", "unknown journey %r" % a["journey"])
            for k, fid in enumerate(a.get("functions") or []):
                if fid not in functions:
                    self.err("%s.functions[%d]" % (aw, k), "SL013", "unknown function %r" % fid)
            outcomes = a.get("outcomes") or []
            if "ambiguous" in outcomes and self.blank(a.get("reconciliation")):
                self.err(aw, "SL005", "the attempt can end ambiguous but has no reconciliation")

        subjects = set(functions) | set(attempts)

        # Signals.
        signals_by_subject = {}
        for sw, s in self.items(doc, "signals"):
            subj = s.get("function")
            if self.blank(subj) or subj not in subjects:
                self.err(sw + ".function", "SL013", "unknown function or attempt %r" % subj)
            else:
                signals_by_subject.setdefault(subj, []).append(s)
            state = s.get("state")
            if state not in SIGNAL_STATES:
                self.err(sw + ".state", "SL015", "state must be one of %s, not %r"
                         % ("/".join(sorted(SIGNAL_STATES)), state))
            elif state == "live" and self.blank(s.get("evidence")):
                self.err(sw, "SL002", "signal %r is live without evidence (browser, agent or "
                         "tenant)" % s.get("name"))

        for fid, fw in functions.items():
            if fid not in signals_by_subject:
                self.err(fw, "SL001", "function %r has no signal" % fid)

        # Error taxonomy.
        reconciled = set()
        for a in attempts.values():
            if not self.blank(a.get("reconciliation")):
                reconciled.update(a.get("functions") or [])
        classified = {}
        for tw, t in self.items(doc, "taxonomy"):
            fid = t.get("function")
            if fid not in functions:
                self.err(tw + ".function", "SL013", "unknown function %r" % fid)
            cls = t.get("class")
            if cls not in CLASSES:
                self.err(tw + ".class", "SL003", "class must be one of %s, not %r"
                         % ("/".join(sorted(CLASSES)), cls))
            impact = t.get("user_impact")
            if impact is not None and impact not in USER_IMPACTS:
                self.err(tw + ".user_impact", "SL015", "user_impact must be one of %s, not %r"
                         % ("/".join(sorted(USER_IMPACTS)), impact))
            key = (fid, str(t.get("code", "")).strip(), str(t.get("context", "")).strip())
            if self.blank(t.get("code")):
                self.err(tw + ".code", "SL003", "row without a code or condition")
            elif key in classified:
                self.err(tw, "SL004", "%r in context %r is already classified at %s"
                         % (key[1], key[2] or "any", classified[key]))
            else:
                classified[key] = tw
            if cls == "ambiguous" and fid not in reconciled and self.blank(t.get("reconciliation")):
                self.err(tw, "SL005", "ambiguous outcome without a reconciliation path (an "
                         "attempt model with reconciliation, or the runbook section)")

        # SLOs.
        slos = {}
        for ow, o in self.items(doc, "slos"):
            if self.blank(o.get("id")):
                self.err(ow + ".id", "SL006", "SLO without an id")
            else:
                self.unique(seen_ids, o["id"], ow)
                slos[o["id"]] = o
            for k in SLO_FIELDS:
                if self.blank(o.get(k)):
                    self.err("%s.%s" % (ow, k), "SL006", "SLO without %s" % k)
            subj = o.get("subject")
            if not self.blank(subj) and subj not in subjects:
                self.err(ow + ".subject", "SL013", "unknown function or attempt %r" % subj)
            self.status(ow, o)
            tgt = o.get("target")
            if isinstance(tgt, (int, float)) and not 0 < tgt < 100:
                self.err(ow + ".target", "SL006", "target %r is not a percentage below 100" % tgt)
            er = o.get("expected_refusals")
            if not isinstance(er, dict) or er.get("treatment") not in REFUSAL_TREATMENTS:
                self.err(ow + ".expected_refusals", "SL007", "say whether expected refusals are "
                         "excluded or counted as good (treatment: excluded / good)")
            elif self.blank(er.get("reason")):
                self.err(ow + ".expected_refusals.reason", "SL007", "treatment of expected "
                         "refusals without a reason")
            bad = o.get("bad") or []
            if isinstance(bad, str):
                bad = [b.strip() for b in re.split(r"[+,]", bad)]
            if bad and not ("ambiguous" in bad and ({"unknown", "unclassified"} & set(bad))) \
                    and self.blank(o.get("bad_reason")):
                self.warn(ow + ".bad", "SL008", "bad predicate leaves out ambiguous or "
                          "unknown/unclassified; they stay bad until reconciled or classified "
                          "(or give bad_reason)")

        # Alerts.
        for lw, l in self.items(doc, "alerts"):
            if not self.blank(l.get("id")):
                self.unique(seen_ids, l["id"], lw)
            sev = l.get("severity")
            if sev not in SEVERITIES:
                self.err(lw + ".severity", "SL015", "severity must be one of %s, not %r"
                         % ("/".join(sorted(SEVERITIES)), sev))
            state = l.get("state")
            if state not in ALERT_STATES:
                self.err(lw + ".state", "SL015", "state must be one of %s, not %r"
                         % ("/".join(sorted(ALERT_STATES)), state))
            sid = l.get("slo")
            slo = slos.get(sid)
            if slo is None:
                self.err(lw + ".slo", "SL013", "unknown SLO %r" % sid)
            if sev == "P1":
                for k in P1_FIELDS:
                    if self.blank(l.get(k)):
                        self.err("%s.%s" % (lw, k), "SL009", "P1 alert without %s" % k)
            grp = str(l.get("grouping") or "").strip().lower()
            if grp and (grp in POOLED or "host" in grp or grp.startswith("pooled")):
                self.err(lw + ".grouping", "SL010", "grouped by %r: alert per function, never "
                         "on a pooled rate or a host" % l.get("grouping"))
            if state == "paging" and slo is not None:
                gaps = self.gaps(slo.get("subject"), signals_by_subject, attempts)
                if gaps:
                    self.err(lw, "SL011", "paging on signals that are not live: %s"
                             % ", ".join(gaps))
            self.status(lw, l)
            if state == "paging":
                unconfirmed = [w for w, x in ((lw, l), (sid, slo)) if x is not None
                               and x.get("status") != "confirmed"]
                if unconfirmed:
                    self.err(lw, "SL018", "paging on a proposed decision: %s must have status "
                             "confirmed (owner, target and threshold agreed with the client)"
                             % " and ".join(str(u) for u in unconfirmed))
            rb = l.get("runbook")
            if self.check_files and isinstance(rb, str) and rb.strip() \
                    and not PLACEHOLDER.match(rb.strip()):
                full = os.path.join(os.path.dirname(os.path.abspath(self.path)), rb)
                if not os.path.exists(full):
                    self.err(lw + ".runbook", "SL012", "runbook %s does not exist" % rb)

    def keys(self, doc):
        """Unknown keys: a misspelt field would otherwise pass silently."""
        def check(where, item, section):
            if not isinstance(item, dict):
                return
            for k in item:
                if k not in KNOWN[section] and k not in COMMON and not str(k).startswith("x_"):
                    self.warn("%s.%s" % (where, k) if where else k, "SL019", "unknown key %r "
                              "(a typo, or an engagement's own field: prefix it x_)" % k)
        check("", doc, "(root)")
        check("spec", doc.get("spec"), "spec")
        for section in ("journeys", "taxonomy", "signals", "attempts", "slos", "alerts"):
            for i, item in enumerate(doc.get(section) or []):
                check("%s[%d]" % (section, i), item, section)
                if section == "journeys" and isinstance(item, dict):
                    for k, f in enumerate(item.get("functions") or []):
                        check("journeys[%d].functions[%d]" % (i, k), f, "functions")

    def status(self, where, item):
        """SLOs and alerts carry status proposed (the default) or confirmed."""
        st = item.get("status", "proposed")
        if st not in DECISION_STATUSES:
            self.err(where + ".status", "SL015", "status must be one of %s, not %r"
                     % ("/".join(sorted(DECISION_STATUSES)), st))

    def unique(self, seen, ident, where):
        if ident in seen:
            self.err(where, "SL014", "id %r already used at %s" % (ident, seen[ident]))
        else:
            seen[ident] = where

    @staticmethod
    def gaps(subject, signals_by_subject, attempts):
        """Signals an SLO rests on that are not live: no threshold on a gap."""
        subjects = [subject]
        if subject in attempts:
            subjects += list(attempts[subject].get("functions") or [])
        out = []
        for s in subjects:
            sigs = signals_by_subject.get(s, [])
            if not sigs:
                out.append("%s (no signal)" % s)
            out += ["%s (%s)" % (g.get("name"), g.get("state")) for g in sigs
                    if g.get("state") != "live"]
        return out


def main():
    ap = argparse.ArgumentParser(description="Lint an observability-spec.yml (kit: tools/speclint.md).")
    ap.add_argument("spec", help="path to observability-spec.yml")
    ap.add_argument("--strict", action="store_true", help="warnings fail too")
    ap.add_argument("--check-files", action="store_true",
                    help="check that runbook paths exist, relative to the spec file")
    args = ap.parse_args()

    try:
        with open(args.spec, encoding="utf-8") as fh:
            doc, repeated = load(fh)
    except OSError as e:
        sys.stderr.write("speclint: %s\n" % e)
        return 2
    except yaml.YAMLError as e:
        sys.stderr.write("speclint: %s: not valid YAML: %s\n" % (args.spec, e))
        return 2

    lint = Linter(args.spec, args.check_files)
    for line, key in repeated:
        lint.err("line %d" % line, "SL020", "key %r repeated in one mapping; only the last "
                 "value would be read" % key)
    lint.run(doc)
    for sev, where, rule, msg in lint.findings:
        print("%s: %s: %s %s: %s" % (args.spec, where or "(root)", rule, sev, msg))
    errors = sum(1 for f in lint.findings if f[0] == "error")
    warnings = len(lint.findings) - errors
    sys.stderr.write("speclint: %d error(s), %d warning(s); a clean run means the spec is "
                     "structurally complete, not that it is right\n" % (errors, warnings))
    if errors or (args.strict and warnings):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
