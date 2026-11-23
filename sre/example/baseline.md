# Baseline — Larkfield Grocer, SRE

**Fictional.** `sre/baseline.md` of the [SRE worked example](worked-example.md), as SRE stage 1
handed it over. The three tables below are what [`tools/baseline.py`](../../tools/baseline.md)
prints on the synthetic exports, with the `B-` ids added in the first column. To reproduce
them, write the exports with [`exports.sh`](exports.sh) into a folder and run, from it:

```
exports.sh DIR && cd DIR
tools/baseline.py sre/exports/incidents-2027-06-08.csv --map severity=priority \
  --deploys sre/exports/deploys-2027-06-08.csv --pages sre/exports/pages-2027-06-08.csv
```

The tracker calls severity "priority" (`--map`) and marks each incident's class: `outage`, or
`data` for a data-correctness defect. Windows come from the data, as the exports
were requested: incidents for six months, deploys and pages for three. Clock: UTC, the
client's.

## Incidents

Source: `sre/exports/incidents-2027-06-08.csv`.

| ID | Number | Value | n | Method | Window |
|---|---|---|---|---|---|
| B-01 | Incidents, severity critical | 4 | 14 | count of rows with this severity | 2026-12-05 to 2027-05-29 (from data) |
| B-02 | Incidents, severity major | 6 | 14 | count of rows with this severity | 2026-12-05 to 2027-05-29 (from data) |
| B-03 | Incidents, severity minor | 4 | 14 | count of rows with this severity | 2026-12-05 to 2027-05-29 (from data) |
| B-37 | Incidents, class data | 2 | 14 | count of rows with this class | 2026-12-05 to 2027-05-29 (from data) |
| B-38 | Incidents, class outage | 12 | 14 | count of rows with this class | 2026-12-05 to 2027-05-29 (from data) |
| B-04 | Time to detect, median | 12 min | 13 of 14 | nearest-rank median of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-05 | Time to detect, p90 | 40 min | 13 of 14 | nearest-rank p90 of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-06 | Time to detect, severity critical, median | 4 min | 4 of 4 | nearest-rank median of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-07 | Time to detect, severity critical, p90 | 12 min | 4 of 4 | nearest-rank p90 of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-08 | Time to detect, severity major, median | 6 min | 6 of 6 | nearest-rank median of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-09 | Time to detect, severity major, p90 | 40 min | 6 of 6 | nearest-rank p90 of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-10 | Time to detect, severity minor, median | 30 min | 3 of 4 | nearest-rank median of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-11 | Time to detect, severity minor, p90 | 50 min | 3 of 4 | nearest-rank p90 of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-39 | Time to detect, class data, median | 6 min | 2 of 2 | nearest-rank median of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-40 | Time to detect, class data, p90 | 50 min | 2 of 2 | nearest-rank p90 of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-41 | Time to detect, class outage, median | 12 min | 11 of 12 | nearest-rank median of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-42 | Time to detect, class outage, p90 | 35 min | 11 of 12 | nearest-rank p90 of detected − started | 2026-12-05 to 2027-05-29 (from data) |
| B-12 | Time to recover, median | 70 min | 14 of 14 | nearest-rank median of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-13 | Time to recover, p90 | 2 h 30 min | 14 of 14 | nearest-rank p90 of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-14 | Time to recover, severity critical, median | 45 min | 4 of 4 | nearest-rank median of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-15 | Time to recover, severity critical, p90 | 3 h 40 min | 4 of 4 | nearest-rank p90 of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-16 | Time to recover, severity major, median | 70 min | 6 of 6 | nearest-rank median of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-17 | Time to recover, severity major, p90 | 2 h 10 min | 6 of 6 | nearest-rank p90 of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-18 | Time to recover, severity minor, median | 100 min | 4 of 4 | nearest-rank median of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-19 | Time to recover, severity minor, p90 | 2 h 30 min | 4 of 4 | nearest-rank p90 of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-43 | Time to recover, class data, median | 70 min | 2 of 2 | nearest-rank median of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-44 | Time to recover, class data, p90 | 2 h 30 min | 2 of 2 | nearest-rank p90 of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-45 | Time to recover, class outage, median | 60 min | 12 of 12 | nearest-rank median of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-46 | Time to recover, class outage, p90 | 2 h 10 min | 12 of 12 | nearest-rank p90 of recovered − started | 2026-12-05 to 2027-05-29 (from data) |
| B-20 | Recurrence share | 46.2% (6 of 13) | 13 of 14 | incidents whose cause matches an earlier incident's, of incidents with a cause | 2026-12-05 to 2027-05-29 (from data) |

## Deploys (DORA)

Source: `sre/exports/deploys-2027-06-08.csv`. Deployment rework rate is recorded when the export flags it; it does not gate a level.

| ID | Number | Value | n | Method | Window |
|---|---|---|---|---|---|
| B-21 | Deployment frequency | 3.3 per week | 42 | deploys ÷ 88 days in the window × 7 | 2027-03-01 to 2027-05-27 (from data) |
| B-22 | Change lead time, median | 44 h 00 min | 42 of 42 | nearest-rank median of deployed − committed | 2027-03-01 to 2027-05-27 (from data) |
| B-23 | Change lead time, p90 | 4 d 0 h | 42 of 42 | nearest-rank p90 of deployed − committed | 2027-03-01 to 2027-05-27 (from data) |
| B-24 | Change failure rate | 14.3% (6 of 42) | 42 | deploys flagged failed ÷ deploys | 2027-03-01 to 2027-05-27 (from data) |
| B-25 | Failed deployment recovery time, median | 50 min | 6 of 6 | nearest-rank median of restored − deployed, failed deploys | 2027-03-01 to 2027-05-27 (from data) |
| B-26 | Failed deployment recovery time, p90 | 3 h 05 min | 6 of 6 | nearest-rank p90 of restored − deployed, failed deploys | 2027-03-01 to 2027-05-27 (from data) |
| B-27 | Deployment rework rate | 9.5% (4 of 42) | 42 | deploys flagged rework (unplanned, to fix a production issue) ÷ deploys | 2027-03-01 to 2027-05-27 (from data) |

## Pages

Source: `sre/exports/pages-2027-06-08.csv`. Clock: UTC. Shifts: 12 h from 08:00, every shift counted. Office hours: 09:00–18:00 Monday to Friday; public holidays are not known to the tool.

| ID | Number | Value | n | Method | Window |
|---|---|---|---|---|---|
| B-28 | Pages per shift, mean | 0.45 | 82 | pages ÷ 183 shifts overlapping the window | 2027-03-01 to 2027-05-31 (from data) |
| B-29 | Pages per shift, max | 7 | 82 | most pages in one shift | 2027-03-01 to 2027-05-31 (from data) |
| B-30 | Shifts over 2 pages | 0.5% (1 of 183) | 183 | shifts with more than 2 pages ÷ shifts | 2027-03-01 to 2027-05-31 (from data) |
| B-31 | Off-hours share | 74.4% (61 of 82) | 82 | pages outside office hours ÷ pages | 2027-03-01 to 2027-05-31 (from data) |

## Counted from other exports

Numbers the tool does not compute, counted by the method of the
[stage 1 reference](../agent/reference/stage-1-reference.md#6-baseline). Tier-1 is the
proposed tier at stage 1.

| ID | Number | Value | n | Method | Window | Source |
|---|---|---|---|---|---|---|
| B-32 | Restore tested | 0% (0 of 2) | 2 | tier-1 data stores with a restore record in the window ÷ tier-1 data stores | 2026-12-05 to 2027-05-31 | Restore records, E-105: the last restore of the orders database is dated 2026-10-14; none of the payments ledger |
| B-33 | Backup success, orders database | 97.8% (180 of 184) | 184 | successful backup runs ÷ scheduled runs | 2027-03-01 to 2027-05-31 | Backup job history, E-104 |
| B-34 | Backup success, payments ledger | 100.0% (184 of 184) | 184 | successful backup runs ÷ scheduled runs | 2027-03-01 to 2027-05-31 | Backup job history, E-104 |
| B-35 | Action-item closure | 36.8% (7 of 19) | 19 | postmortem action items closed by their due date ÷ items due in the window | 2026-12-05 to 2027-05-31 | Action-item tickets, E-106 |
| B-36 | Owner coverage | 85.7% (6 of 7) | 7 | services in scope with an owner and a paging route ÷ services in scope | at 2027-06-09 | Service registry and paging routes, E-101, E-107 |
