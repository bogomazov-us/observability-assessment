# Baseline calculator

`tools/baseline.py` reads CSV exports of incidents, deploys and pages and prints the SRE baseline
numbers in Markdown, each with its method, window and row count. A number the data cannot
support prints `not measured: <reason>`, never a guess. The tool gives no ids: the lead or agent
adds the `B-` ids in `sre/baseline.md` ([records.md](../method/records.md)).

```
tools/baseline.py incidents.csv [--deploys deploys.csv] [--pages pages.csv]
tools/baseline.py incidents.csv --map severity=Priority --map started=Opened
tools/baseline.py incidents.csv --pages pages.csv --tz Europe/Berlin --from 2026-01-01 --to 2026-06-30
tools/baseline.py --deploys deploys.csv --pages pages.csv --pages-from 2026-06-01 --no-rotation
```

Every input is optional, incidents included.

Exit 0: printed. Exit 2: usage, an unreadable file, a time that is not ISO 8601 or has no
offset, or an end time before its start (one line naming the file and row). Python 3.9+,
standard library only.

## Columns

The header row names the columns; other columns are ignored. A column with another name is
mapped with `--map field=column` (repeatable).

| File | Field | Content | Numbers that need it |
|---|---|---|---|
| incidents | `started` | Impact start | all incident numbers; the window |
| incidents | `severity` | Severity as the tracker names it | incidents per severity; the per-severity times |
| incidents | `detected` | First alert or report | time to detect |
| incidents | `recovered` | Service restored (mitigated, not closed) | time to recover |
| incidents | `cause` | Cause label | recurrence share |
| incidents | `class` | Optional: the kind of incident, such as `outage` or `data` (a data-correctness defect) | per-class counts and times |
| deploys | `deployed` | Deploy to production | all deploy numbers; the window |
| deploys | `committed` | Commit time of the change | change lead time |
| deploys | `failed` | Flag: the deploy failed in production | change failure rate; recovery time |
| deploys | `restored` | Service restored after a failed deploy | failed deployment recovery time |
| deploys | `rework` | Flag: unplanned deploy to fix a production issue | deployment rework rate |
| pages | `paged` | Page time | pages per shift; off-hours share |

Flags are true for `1`, `true`, `yes`, `y`, `x`, `fail` or `failed` (any case); anything else,
blank included, is false. A blank time leaves that row out of that number only; `n` shows
"used of rows".

## Time

- Times are ISO 8601 with an offset or `Z`, e.g. `2026-03-01T01:00:00+02:00`. Times without
  an offset are rejected, unless `--assume-tz ZONE` names the zone they were exported in.
- `--tz ZONE` (default `UTC`; an offset `+01:00` or an IANA name) is the clock for dates, the
  window, shifts and office hours. An IANA name follows daylight saving time.
- The window is `--from`/`--to` (dates on that clock, both inclusive) when given; rows outside
  it are left out. Otherwise it runs from the first to the last row's main time (`started`,
  `deployed`, `paged`) and says "from data". Use 6–12 months for incidents.
- Sources keep different histories (alarm history may hold 30 days, deploys months):
  `--incidents-from`/`--incidents-to`, `--deploys-from`/`--deploys-to` and
  `--pages-from`/`--pages-to` set one input's window and override `--from`/`--to` for it; the
  Window column names the flags used.

## Methods

| Number | Method |
|---|---|
| Incidents per severity | Count of rows per severity value |
| Incidents per class | Count of rows per class value, when the `class` column is present |
| Time to detect; to recover | `detected − started`; `recovered − started`. Median and p90, overall, per severity and per class. Classes whose times differ by orders of magnitude (minutes for outages, weeks for data defects) are read per class, not overall |
| Recurrence share | Incidents whose cause (case ignored) matches an earlier incident's, of incidents with a cause |
| Deployment frequency | Deploys ÷ days in the window × 7, per week |
| Change lead time | `deployed − committed`, median and p90 |
| Change failure rate | Deploys flagged failed ÷ deploys |
| Failed deployment recovery time | `restored − deployed` over failed deploys, median and p90 |
| Deployment rework rate | Deploys flagged rework ÷ deploys. DORA's fifth metric: recorded when the export flags it; it does not gate a level ([sre/maturity-model.md](../sre/maturity-model.md)) |
| Pages per shift | Pages ÷ shifts overlapping the window (mean), the most in one shift, and the share of shifts over `--page-limit` (default 2). Shifts: `--shift-hours` (default 12) from `--shift-start` (default 08:00), every shift counted |
| Pages per working day | With `--no-rotation` (one operator in working hours, no shifts), instead of pages per shift: pages on Monday to Friday ÷ those days in the window (mean), the most on one day, and the share of days over `--page-limit`. The section says "No rotation" |
| Off-hours share | Pages outside `--office-hours` (default 09:00-18:00) Monday to Friday ÷ pages. Public holidays are not known to the tool |

Median and p90 are nearest-rank: sort the n values and take the one at rank ⌈p/100 × n⌉ (no
interpolation; for an even n the median is the lower middle value).

## Output

From the synthetic test fixtures (`tools/tests/fixtures/baseline/fixtures.sh`):

| Number | Value | n | Method | Window |
|---|---|---|---|---|
| Time to detect, median | 25 min | 10 of 11 | nearest-rank median of detected − started | 2026-01-05 to 2026-06-30 (from data) |
| Change failure rate | 25.0% (2 of 8) | 8 | deploys flagged failed ÷ deploys | 2026-06-01 to 2026-06-14 (from data) |
| Change lead time | not measured: committed missing | — | nearest-rank median and p90 of deployed − committed | — |

One section each for incidents, deploys (DORA) and pages; a file not given prints
`not measured: no --deploys export`. An empty file prints `not measured: file empty`; a header
with no rows, `not measured: no rows`.

Tests: `tools/tests/test_baseline.sh` (synthetic fixtures: normal data, empty files, missing
columns, mapping, time zones, classes, per-input windows, no rotation).
