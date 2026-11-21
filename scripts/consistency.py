#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Consistency check: stops the contradictions the kit removed from coming back.

  scripts/consistency.py [--root DIR] [--allow FILE]

Pattern-based, not a Markdown parser. Four checks:
  weeks   a week number ("week 2", "weeks 1-2") outside the calendar section of
          method/getting-started.md; the playbook's Week column equals the calendar's
  prefix  an id prefix (D-, REC-, ...) not in the registry table of method/records.md
  status  an inline status list (a · b · c, a / b / c, a | b) that names a status set of
          method/records.md but differs from its values
  gate    a checked phrase of a stage gate in tools/agent/README.md missing from the README
          row or from the stage prompt section it restates
Exceptions go in the allow-list (default scripts/consistency-allow.yml), one per line:
  - "check | file | text on the offending line | reason"
An entry that matches nothing fails, so the list cannot go stale.
"""
import argparse
import os
import re
import sys

# Files and folders checked, relative to the root. Extend here (e.g. "example").
SCOPE = ["README.md", "offerings.md", "backlog.md", "method", "templates", "tools", "practice", "example"]
EXCLUDE = ["tools/tests"]
EXTENSIONS = (".md", ".yml")

CALENDAR_FILE = "method/getting-started.md"
CALENDAR_HEADING = "## 3. Calendar"
PLAYBOOK_FILE = "method/playbook.md"
RECORDS_FILE = "method/records.md"
AGENT_README = "tools/agent/README.md"

# (stage row in the README gate table, phrase, prompt file, section of the prompt)
GATE_PHRASES = [
    (4, "a sample of", "tools/agent/stage-3-gap.md", "What the person confirms"),
    (4, '"live"', "tools/agent/stage-3-gap.md", "What the person confirms"),
    (4, 'each "proven"', "tools/agent/stage-3-gap.md", "What the person confirms"),
    (4, "another path than the agent's query", "tools/agent/stage-3-gap.md", "What the person confirms"),
    (5, "verdict recorded or sent in the", "tools/agent/stage-4-findings.md", "What the person confirms"),
    (5, "a finding still waiting stays *assumption*", "tools/agent/stage-4-findings.md", "What the person confirms"),
    (5, "provisional", "tools/agent/stage-4-findings.md", "What the person confirms"),
    (6, "confirmation batch", "tools/agent/stage-6-recommendations.md", "Method"),
]

WEEK = re.compile(r"\b[Ww]eeks? \d+")
PREFIX = re.compile(r"\b(?!YYYY-)([A-Z][A-Z0-9]{0,4})-(?=\d|NN|MM|x|\.\.|\[|`)")
ITEM = r"`?\w[\w-]*(?: \w[\w-]*){0,5}`?(?: \([^()]*\))?"
LISTS = [re.compile(rf"{ITEM}(?:{re.escape(sep)}{ITEM})+") for sep in (" · ", " / ", " | ")]
SEP = re.compile(r" · | / | \| ")


def norm(s):
    return " ".join(s.split())


def read(root, rel):
    with open(os.path.join(root, rel), encoding="utf-8") as fh:
        return fh.read()


def files(root):
    out = []
    for entry in SCOPE:
        path = os.path.join(root, entry)
        if os.path.isfile(path):
            out.append(entry)
        for d, subdirs, names in os.walk(path):
            rel_d = os.path.relpath(d, root)
            if any(rel_d == e or rel_d.startswith(e + "/") for e in EXCLUDE):
                subdirs[:] = []
                continue
            out += [os.path.join(rel_d, n) for n in sorted(names) if n.endswith(EXTENSIONS)]
    return sorted(set(out))


def section(text, heading):
    """Lines of the section that starts at `heading`, as (line number, line)."""
    lines, out, inside = text.splitlines(), [], False
    level = heading.split(" ", 1)[0]
    for i, line in enumerate(lines, 1):
        if line.strip() == heading:
            inside = True
        elif inside and line.startswith(level + " "):
            break
        if inside:
            out.append((i, line))
    return out


def cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


# ---- registry and status sets from records.md


def registry(root):
    text = read(root, RECORDS_FILE)
    prefixes = set()
    for _, line in section(text, "## Id prefixes"):
        if line.startswith("|"):
            prefixes |= set(re.findall(r"`([A-Z]+-)`", cells(line)[0]))
    sets = {}
    for _, line in section(text, "## Status sets"):
        c = cells(line)
        if not line.startswith("|") or len(c) < 2 or c[0] in ("Set", "") or set(c[0]) <= set("-"):
            continue
        for n, seg in enumerate(c[1].split(";")):
            seg = re.sub(r"^\s*[\w ]+:\s*", "", seg)          # "item: ...", "round: ..."
            seg = re.sub(r"^\s*for [\w-]+ ", "", seg)          # "for implementation go · ..."
            values = [re.sub(r"\(.*?\)", "", v).replace("`", "").replace("_", " ").strip().lower()
                      for v in seg.split(" · ")]
            values = [v for v in values if v]
            if len(values) >= 2:
                sets[c[0] + (f" ({n + 1})" if n else "")] = values
    return prefixes, sets


# ---- checks: each yields (check, file, line number, line text, message)


def check_weeks(root, paths):
    cal = {i for i, _ in section(read(root, CALENDAR_FILE), CALENDAR_HEADING)}
    for p in paths:
        for i, line in enumerate(read(root, p).splitlines(), 1):
            if p == CALENDAR_FILE and i in cal:
                continue
            for m in WEEK.finditer(line):
                yield ("weeks", p, i, line, f"week number outside the calendar: '{m.group(0)}'")
    # the playbook's Week column copies the calendar's playbook steps exactly
    weeks_of = {}
    for i, line in section(read(root, CALENDAR_FILE), CALENDAR_HEADING):
        c = cells(line)
        if line.startswith("|") and c[0].isdigit() and len(c) > 2:
            if len(c) < 6:          # the focused table has fewer columns; full format only
                break
            for step in re.findall(r"(?:^|,\s*)(\d+)\b", c[2]):
                weeks_of.setdefault(int(step), set()).add(int(c[0]))
    if not os.path.exists(os.path.join(root, PLAYBOOK_FILE)):
        return
    for i, line in enumerate(read(root, PLAYBOOK_FILE).splitlines(), 1):
        c = cells(line)
        if line.startswith("|") and len(c) > 2 and c[0].isdigit():
            nums = [int(x) for x in re.findall(r"\d+", c[1])]
            if re.search(r"\d\s*[–-]\s*\d", c[1]):
                nums = list(range(nums[0], nums[-1] + 1))
            want = weeks_of.get(int(c[0]), set())
            if set(nums) != want:
                yield ("weeks", PLAYBOOK_FILE, i, line,
                       f"step {c[0]}: Week {sorted(nums)} differs from the calendar's {sorted(want)}")


def check_prefixes(root, paths, prefixes):
    for p in paths:
        if p == RECORDS_FILE:
            continue
        for i, line in enumerate(read(root, p).splitlines(), 1):
            for m in PREFIX.finditer(line):
                if m.group(1) + "-" not in prefixes:
                    yield ("prefix", p, i, line, f"id prefix '{m.group(1)}-' not in the registry ({RECORDS_FILE})")


def chunks(text):
    """Table cells one by one; other lines joined into paragraphs. Yields (line number, text)."""
    para, start, fence = [], 0, False
    for i, line in enumerate(text.splitlines() + [""], 1):
        s = line.strip()
        if s.startswith("```"):
            fence = not fence
        if fence or s.startswith("```") or not s or s.startswith("#") or s.startswith("|"):
            if para:
                yield start, " ".join(para)
                para = []
            if s.startswith("|") and not fence:
                for c in cells(s):
                    yield i, c
            continue
        if not para:
            start = i
        para.append(s)


def mapped(item, values):
    item = re.sub(r"\(.*?\)", "", item).replace("`", "").replace("_", " ").strip().lower()
    hits = [v for v in values if item == v or item.startswith(v + " ") or item.endswith(" " + v)]
    return max(hits, key=len) if hits else None


def check_status(root, paths, sets):
    for p in paths:
        if p == RECORDS_FILE:
            continue
        for i, text in chunks(read(root, p)):
            for rx in LISTS:
                for m in rx.finditer(text):
                    items = SEP.split(m.group(0))
                    best, ok = None, False
                    for name, values in sets.items():
                        got = [mapped(it, values) for it in items]
                        hit = {g for g in got if g}
                        if len(hit) < 2 or (len(items) == 2 and len(values) > 2):
                            continue  # a pair names two values; it enumerates only a two-value set
                        if None not in got and len(hit) == len(got) and hit == set(values):
                            ok = True
                            break
                        if best is None or len(hit) > best[1]:
                            best = (name, len(hit), values)
                    if best and not ok:
                        yield ("status", p, i, m.group(0),
                               f"'{m.group(0)}' differs from the status set '{best[0]}': {' · '.join(best[2])}")


def check_gates(root):
    readme = read(root, AGENT_README).splitlines()
    rows = {}
    for i, line in enumerate(readme, 1):
        c = cells(line)
        if line.startswith("|") and re.match(r"^\d \w", c[0]):
            rows[int(c[0][0])] = (i, line, norm(c[-1]))
    for stage, phrase, prompt, heading in GATE_PHRASES:
        if stage not in rows:
            yield ("gate", AGENT_README, 0, "", f"no gate row for stage {stage}")
            continue
        i, line, gate = rows[stage]
        if phrase.lower() not in gate.lower():
            yield ("gate", AGENT_README, i, line, f"stage {stage} gate lacks the checked phrase: {phrase}")
        sec = section(read(root, prompt), "## " + heading)
        if not sec:
            yield ("gate", prompt, 0, "", f"no section '{heading}'")
        elif phrase.lower() not in norm(" ".join(l for _, l in sec)).lower():
            yield ("gate", prompt, sec[0][0], "", f"'{heading}' lacks the phrase the stage {stage} gate states: {phrase}")


def load_allow(path):
    allow = []
    if not os.path.exists(path):
        return allow
    with open(path, encoding="utf-8") as fh:
        for n, line in enumerate(fh, 1):
            m = re.match(r'^\s*-\s*"(.*)"\s*$', line)
            if not m:
                continue
            parts = [x.strip() for x in m.group(1).split(" | ")]
            if len(parts) != 4 or not all(parts):
                sys.exit(f"{path}:{n}: expected \"check | file | text | reason\"")
            allow.append([n] + parts + [0])
    return allow


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    ap.add_argument("--allow", help="allow-list (default: ROOT/scripts/consistency-allow.yml)")
    a = ap.parse_args()
    root = os.path.abspath(a.root)
    allow_path = a.allow or os.path.join(root, "scripts", "consistency-allow.yml")
    allow = load_allow(allow_path)
    paths = files(root)
    prefixes, sets = registry(root)

    found = list(check_weeks(root, paths)) + list(check_prefixes(root, paths, prefixes)) \
        + list(check_status(root, paths, sets)) + list(check_gates(root))
    fail = 0
    for check, path, line_no, text, msg in found:
        hit = next((e for e in allow if e[1] == check and e[2] == path and e[3] in text), None)
        if hit:
            hit[5] += 1
            continue
        print(f"  {check}: {path}:{line_no}: {msg}")
        fail = 1
    for n, check, path, text, reason, used in allow:
        if not used:
            print(f"  allow-list entry matches nothing: {os.path.basename(allow_path)}:{n}: {check} | {path} | {text}")
            fail = 1
    return fail


if __name__ == "__main__":
    sys.exit(main())
