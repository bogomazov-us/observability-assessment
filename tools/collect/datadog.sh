#!/usr/bin/env bash
# Week-one inventory export from Datadog. Read-only: GET only.
#   DD_API_KEY=[key] DD_APP_KEY=[key] [DD_SITE=datadoghq.eu] tools/collect/datadog.sh OUT_DIR
# DD_SITE defaults to datadoghq.com. Use an application key scoped to read only:
# monitors_read, dashboards_read, slos_read, synthetics_read, rum_apps_read, apm_service_catalog_read.
# Writes one .json per export and summary.md into OUT_DIR. OUT_DIR belongs to the engagement
# repository, never to this kit; sanitize before committing.
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true # bash < 4.4: explicit returns below

[ $# -eq 1 ] || { echo "usage: DD_API_KEY=... DD_APP_KEY=... [DD_SITE=...] $0 OUT_DIR" >&2; exit 2; }
missing=()
[ -n "${DD_API_KEY:-}" ] || missing+=(DD_API_KEY)
[ -n "${DD_APP_KEY:-}" ] || missing+=(DD_APP_KEY)
[ ${#missing[@]} -eq 0 ] || { echo "missing environment variables: ${missing[*]} (see tools/collect.md)" >&2; exit 2; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 2; }

OUT="$1"; mkdir -p "$OUT"
BASE="https://api.${DD_SITE:-datadoghq.com}"
# Keys go to curl through a private header file, never through the command line.
HDR="$(mktemp)"; chmod 600 "$HDR"; trap 'rm -f "$HDR"' EXIT
printf 'DD-API-KEY: %s\nDD-APPLICATION-KEY: %s\nAccept: application/json\n' "$DD_API_KEY" "$DD_APP_KEY" > "$HDR"

get() { curl -fsS --retry 2 -H @"$HDR" "$1"; }

save() { # $1 name, $2 JSON array
  jq '.' <<<"$2" > "$OUT/$1.json"
  echo "$1|$(jq 'length' <<<"$2")"
}

# Page until a page comes back shorter than the page size.
# $1 path (with ? already present), $2 jq path of items, $3 page-size param, $4 page-number param, $5 size, $6 first page
paged() {
  local path="$1" items="$2" sp="$3" np="$4" size="$5" n="$6" page got all="[]"
  while :; do
    page="$(get "$BASE$path&$sp=$size&$np=$n")" || return 1
    got="$(jq -c "$items // []" <<<"$page")"
    all="$(jq -c --argjson a "$all" --argjson b "$got" -n '$a + $b')"
    [ "$(jq 'length' <<<"$got")" -lt "$size" ] && break
    n=$((n + 1))
  done
  printf '%s' "$all"
}

# SLOs page with limit/offset.
slos() {
  local off=0 size=1000 page got all="[]"
  while :; do
    page="$(get "$BASE/api/v1/slo?limit=$size&offset=$off")" || return 1
    got="$(jq -c '.data // []' <<<"$page")"
    all="$(jq -c --argjson a "$all" --argjson b "$got" -n '$a + $b')"
    [ "$(jq 'length' <<<"$got")" -lt "$size" ] && break
    off=$((off + size))
  done
  printf '%s' "$all"
}

ROWS=()
# A failed request stops the run: a missing scope must not look like an empty estate.
add() { local r; r="$("$@")" || exit 1; ROWS+=("$r"); }
# Each fetch is assigned on its own line, so a failed request stops the run under set -e.
v="$(paged '/api/v1/monitor?with_downtimes=false' '.' page_size page 1000 0)"; add save monitors "$v"
v="$(get "$BASE/api/v1/dashboard")"; v="$(jq -c '.dashboards // []' <<<"$v")"; add save dashboards "$v"
v="$(slos)"; add save slos "$v"
v="$(get "$BASE/api/v1/synthetics/tests")"; v="$(jq -c '.tests // []' <<<"$v")"; add save synthetics-tests "$v"
v="$(get "$BASE/api/v2/rum/applications")"; v="$(jq -c '.data // []' <<<"$v")"; add save rum-applications "$v"
v="$(paged '/api/v2/services/definitions?schema_version=v2.2' '.data' 'page%5Bsize%5D' 'page%5Bnumber%5D' 100 0)"; add save service-definitions "$v"

{
  echo "# Datadog inventory export"
  echo
  echo "Exported on $(date +%Y-%m-%d). Counts are what the API returned to these keys; a scope the"
  echo "application key lacks shows as a failed run, not as zero."
  echo
  echo "| Export | Items | File |"
  echo "|---|--:|---|"
  for r in "${ROWS[@]}"; do echo "| ${r%%|*} | ${r#*|} | \`${r%%|*}.json\` |"; done
  echo
  echo "Next: reconcile the exports with each other and with the intake answers (playbook, step 4)."
} > "$OUT/summary.md"
echo "wrote $OUT/summary.md" >&2
