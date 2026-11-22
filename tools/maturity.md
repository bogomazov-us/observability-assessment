# Maturity profile check

`tools/maturity.py` reads a scoring file (skeleton: `templates/maturity.yml`), checks it against
the scoring rules in [maturity-model.md](../method/maturity-model.md), and prints the profile
for the report. It never computes an average.

```
tools/maturity.py maturity.yml            # check, then print the profile (Markdown)
tools/maturity.py --check maturity.yml    # check only
tools/maturity.py --pair obs.yml sre.yml  # combined format: check both files and their overlaps
```

Exit 0: clean (warnings may be printed). Exit 1: rule violations, one line each as
`file: dimension N: RULE message`. Exit 2: the file cannot be read or is not YAML. Needs
Python 3.9+ and PyYAML.

## Models

`model:` names the dimension table: `observability` (the default, when absent; dimensions 1–12,
12 optional) or `sre` (dimensions 1–10 of `sre/maturity-model.md`; none
optional, so every N/A records `agreed_by`).

In the combined format a dimension may carry `refers_to: <other model>/<n>`, e.g.
`refers_to: observability/7`: the topic is scored there. `--pair` applies the overlap table of
`sre/maturity-model.md` (the tool's `OVERLAPS`; `tools/tests/test_records.sh` checks they match).
It prints no profile.

## Rules

| ID | Check | Scoring rule |
|---|---|---|
| M01 | Scope lists journeys and services | 1 Scope first |
| M02 | Dimension number is in the model (1–12, SRE 1–10); a name, if given, matches it | dimensions table |
| M03 | No dimension listed twice | 7 the profile |
| M04 | Status is scored, partial, not_scored or na | 2, 4, 5 |
| M05 | A scored level is an integer 1–5 | 2 |
| M06 | Partial has the coverage written out and a partial level above the scored one | 2 partial |
| M07 | Every score names its evidence; level 1 names the search that came back empty | 3 evidence per score; 4 |
| M08 | Above level 2 at least one piece of tool evidence: export, query, trace, code, config | 3 |
| M09 | Low confidence with a level above 2 | 6 confidence |
| M10 | Confidence is high, medium or low | 6 |
| M11 | Not scored and N/A carry a reason and no level | 4, 5 |
| M12 | No overall number (`average`, `overall`, `score`) in the file | 7 no overall average |
| M13 | Each evidence item has a known type and a reference | 3 |
| M14 | `model` is observability or sre | dimensions table |
| M15 | `refers_to` is `<other model>/<n>` with a dimension of that model | combined format |
| P01 | `--pair`: an overlap topic is scored in both files (except releases, scored in both) | combined format |
| P02 | `--pair`: `refers_to` points at a dimension not scored in the other file | combined format |
| W01 | Warning: N/A without `agreed_by` outside an optional dimension (observability 12) | 5 the client agrees |

## Output

From the worked example's profile (`example/maturity.yml`):

| Dimension | Level | Coverage | Evidence | Confidence |
|---|---|---|---|---|
| 1 Business-function model | 2 | journeys listed, no functions | product wiki; interviews | medium |
| 2 Telemetry coverage | not scored | extract only | — | — |
| 3 Error semantics | 2 (partial 3) | classified on C1 only | `slots` and `payments` error handlers | high |
| 5 Business outcome data | 2 | outcomes reconstructable from the orders database by hand | ad-hoc query | high |
| 6 SLOs | 1 | none | SLO list, empty; no SLO in contracts or wiki | high |
| 7 Alert quality | 2 | per-service 5xx alerts, no owners | alert export | high |

(Rows for the other not-scored dimensions omitted here.) Below the table:

- **Left out as N/A:** 12 Operational analytics — client does not intend to use it this year
- **Distribution:** 1 dimension at 1, 4 at 2, 6 not scored
- **Block the next step:** the dimensions marked `blocks_next_step`, or "none marked" — the
  tool does not choose them
- **What moves the score fastest:** the `moves_fastest` list, if given

Tests: `tools/tests/test_maturity.sh` (the worked example passes; one fixture per rule fails; SRE and pair fixtures).
