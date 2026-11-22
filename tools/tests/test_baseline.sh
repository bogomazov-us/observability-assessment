#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/baseline.py on synthetic fixtures: medians and p90, DORA keys, pages,
# empty files, missing columns, column mapping and time zones.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../baseline.py"
fx="$(mktemp -d)"; trap 'rm -rf "${fx:?}"' EXIT
bash "$here/fixtures/baseline/fixtures.sh" "$fx"
fail=0

# has NAME OUTPUT LINE...: each LINE is a fixed string that must appear in OUTPUT
has() {
  local name="$1" out="$2"; shift 2
  for l in "$@"; do grep -qF -- "$l" <<<"$out" || { echo "✗ $name: missing: $l"; fail=1; return; }; done
  echo "✓ $name"
}
# exits NAME CODE PATTERN ARGS...: exit code and a stderr pattern
exits() {
  local name="$1" want="$2" pat="$3"; shift 3
  set +e; err="$("$tool" "$@" 2>&1 >/dev/null)"; code=$?; set -e
  if [ $code -eq "$want" ] && grep -q -- "$pat" <<<"$err"; then echo "✓ $name"
  else echo "✗ $name: exit $code, output: $err"; fail=1; fi
}

out="$("$tool" "$fx/incidents.csv" --deploys "$fx/deploys.csv" --pages "$fx/pages.csv")"
has "incidents per severity" "$out" \
  '| Incidents, severity SEV1 | 3 | 11 | count of rows with this severity | 2026-01-05 to 2026-06-30 (from data) |' \
  '| Incidents, severity SEV3 | 4 | 11 |'
has "time to detect and recover: nearest rank, rows without a time left out" "$out" \
  '| Time to detect, median | 25 min | 10 of 11 | nearest-rank median of detected − started |' \
  '| Time to detect, p90 | 45 min | 10 of 11 |' \
  '| Time to detect, severity SEV2, p90 | 35 min | 4 of 4 |' \
  '| Time to recover, median | 2 h 30 min | 10 of 11 |' \
  '| Time to recover, severity SEV3, p90 | 5 h 00 min | 3 of 4 |'
has "recurrence share (cause case-insensitive)" "$out" '| Recurrence share | 30.0% (3 of 10) | 10 of 11 |'
has "DORA keys and rework rate" "$out" \
  '| Deployment frequency | 4.0 per week | 8 | deploys ÷ 14 days in the window × 7 | 2026-06-01 to 2026-06-14 (from data) |' \
  '| Change lead time, median | 4 h 00 min | 8 of 8 |' \
  '| Change lead time, p90 | 8 h 00 min | 8 of 8 |' \
  '| Change failure rate | 25.0% (2 of 8) | 8 |' \
  '| Failed deployment recovery time, median | 30 min | 2 of 2 |' \
  '| Failed deployment recovery time, p90 | 90 min | 2 of 2 |' \
  '| Deployment rework rate | 12.5% (1 of 8) | 8 |'
has "pages in UTC" "$out" \
  '| Pages per shift, mean | 3.00 | 6 | pages ÷ 2 shifts overlapping the window |' \
  '| Pages per shift, max | 4 | 6 |' \
  '| Off-hours share | 50.0% (3 of 6) | 6 |'

# Time zones: offsets in the data are honoured (fixture rows 2-5 mix them); the clock moves pages.
out="$("$tool" "$fx/header-only.csv" --pages "$fx/pages.csv" --tz +01:00)"
has "pages on a +01:00 clock" "$out" '| Off-hours share | 66.7% (4 of 6) |' '| Pages per shift, mean | 2.00 | 6 | pages ÷ 3 shifts'
out="$("$tool" "$fx/header-only.csv" --pages "$fx/pages.csv" --tz Europe/Berlin --from 2026-06-01 --to 2026-06-02)"
has "pages on a named zone with --from/--to" "$out" \
  '| Off-hours share | 50.0% (3 of 6) | 6 | pages outside office hours ÷ pages | 2026-06-01 to 2026-06-02 (--from/--to) |' \
  'pages ÷ 5 shifts overlapping the window'
exits "time without an offset is rejected" 2 'incidents-naive.csv:2: started: time has no offset' "$fx/incidents-naive.csv"
out="$("$tool" "$fx/incidents-naive.csv" --assume-tz +02:00)"
has "--assume-tz reads times without an offset" "$out" '| Time to detect, median | 5 min | 1 of 1 |'

# Missing columns: "not measured", never a guess.
out="$("$tool" "$fx/incidents-mapped.csv" --map severity=Priority --map started=Opened --map recovered=Resolved \
  --deploys "$fx/deploys-minimal.csv")"
has "column mapping" "$out" '| Incidents, severity P1 | 1 | 2 |' '| Time to recover, median | 30 min | 2 of 2 |'
has "missing columns" "$out" \
  '| Time to detect | not measured: detected missing |' \
  '| Recurrence share | not measured: cause missing |' \
  '| Change lead time | not measured: committed missing |' \
  '| Change failure rate | not measured: failed missing |' \
  '| Deployment rework rate | not measured: rework missing |' \
  'not measured: no --pages export'
out="$("$tool" "$fx/incidents-mapped.csv")"
has "unmapped columns are missing" "$out" '| Incidents per severity | not measured: started missing |'

# Empty files.
out="$("$tool" "$fx/empty.csv" --deploys "$fx/empty.csv" --pages "$fx/header-only.csv")"
has "empty and header-only files" "$out" \
  '| Time to detect | not measured: file empty |' \
  '| Deployment frequency | not measured: file empty |' \
  '| Pages per shift | not measured: paged missing |'
out="$("$tool" "$fx/header-only.csv")"
has "header only" "$out" '| Incidents per severity | not measured: no rows |'
out="$("$tool" "$fx/incidents.csv" --from 2027-01-01)"
has "no rows in the window" "$out" 'not measured: no rows in the window'

exits "recovery before start exits 2" 2 'detected is before started' "$fx/incidents-bad-order.csv"
exits "unknown --map field exits 2" 2 'expected FIELD=COLUMN' "$fx/incidents.csv" --map foo=bar
exits "unreadable file exits 2" 2 'cannot read' "$fx/does-not-exist.csv"

exit $fail
