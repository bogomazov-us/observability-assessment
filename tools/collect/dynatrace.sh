#!/usr/bin/env bash
# Week-one inventory export from Dynatrace (Environment API v2, config API v1). Read-only: GET only.
#   DT_ENV_URL=https://[environment] DT_API_TOKEN=[token] tools/collect/dynatrace.sh OUT_DIR
# DT_ENV_URL is the environment base URL, without a trailing slash. The token needs read scopes
# only: entities.read, settings.read, slo.read, ReadSyntheticData, ReadConfig.
# Writes one .json per export and summary.md into OUT_DIR. OUT_DIR belongs to the engagement
# repository, never to this kit; sanitize before committing.
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true # bash < 4.4: explicit returns below

[ $# -eq 1 ] || { echo "usage: DT_ENV_URL=... DT_API_TOKEN=... $0 OUT_DIR" >&2; exit 2; }
missing=()
[ -n "${DT_ENV_URL:-}" ] || missing+=(DT_ENV_URL)
[ -n "${DT_API_TOKEN:-}" ] || missing+=(DT_API_TOKEN)
[ ${#missing[@]} -eq 0 ] || { echo "missing environment variables: ${missing[*]} (see tools/collect.md)" >&2; exit 2; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 2; }

OUT="$1"; mkdir -p "$OUT"
BASE="${DT_ENV_URL%/}"
# The token goes to curl through a private header file, never through the command line.
HDR="$(mktemp)"; chmod 600 "$HDR"; trap 'rm -f "$HDR"' EXIT
printf 'Authorization: Api-Token %s\nAccept: application/json\n' "$DT_API_TOKEN" > "$HDR"

get() { curl -fsS --retry 2 -H @"$HDR" "$1"; }

# Paged v2 export: $1 name, $2 path with query, $3 jq path of the item array.
# Dynatrace pages with nextPageKey; a follow-up request carries nextPageKey alone.
paged() {
  local name="$1" path="$2" items="$3" url page key all="[]"
  url="$BASE$path"
  while :; do
    page="$(get "$url")" || return 1
    all="$(jq -c --argjson acc "$all" "\$acc + ($items // [])" <<<"$page")"
    key="$(jq -r '.nextPageKey // empty' <<<"$page")"
    [ -n "$key" ] || break
    url="$BASE${path%%\?*}?nextPageKey=$(jq -rn --arg k "$key" '$k|@uri')"
  done
  jq '.' <<<"$all" > "$OUT/$name.json"
  echo "$name|$(jq 'length' <<<"$all")"
}

single() { # $1 name, $2 path, $3 jq path of the item array
  local page; page="$(get "$BASE$2")" || return 1
  jq "$3 // []" <<<"$page" > "$OUT/$1.json"
  echo "$1|$(jq 'length' "$OUT/$1.json")"
}

ROWS=()
# A failed request stops the run: a missing scope must not look like an empty estate.
add() { local r; r="$("$@")" || exit 1; ROWS+=("$r"); }
for t in APPLICATION MOBILE_APPLICATION SERVICE HOST PROCESS_GROUP HTTP_CHECK SYNTHETIC_TEST; do
  sel="$(jq -rn --arg s "type(\"$t\")" '$s|@uri')"
  add paged "entities-$(tr 'A-Z_' 'a-z-' <<<"$t")" "/api/v2/entities?entitySelector=$sel&pageSize=500&from=now-72h&fields=%2Btags,%2BmanagementZones" '.entities'
done
add paged alerting-profiles "/api/v2/settings/objects?schemaIds=builtin%3Aalerting.profile&pageSize=500&fields=objectId,scope,value" '.items'
add paged metric-events "/api/v2/settings/objects?schemaIds=builtin%3Aanomaly-detection.metric-events&pageSize=500&fields=objectId,scope,value" '.items'
add paged problem-notifications "/api/v2/settings/objects?schemaIds=builtin%3Aproblem.notifications&pageSize=500&fields=objectId,scope,value" '.items'
add paged slos "/api/v2/slo?pageSize=500&evaluate=false" '.slo'
add single synthetic-monitors "/api/v1/synthetic/monitors" '.monitors'
add single dashboards "/api/config/v1/dashboards" '.dashboards'

{
  echo "# Dynatrace inventory export"
  echo
  echo "Exported on $(date +%Y-%m-%d). Entities seen in the last 72 hours. Counts are what the API"
  echo "returned to this token; a scope the token lacks shows as a failed run, not as zero."
  echo
  echo "| Export | Items | File |"
  echo "|---|--:|---|"
  for r in "${ROWS[@]}"; do echo "| ${r%%|*} | ${r#*|} | \`${r%%|*}.json\` |"; done
  echo
  echo "Next: reconcile the exports with each other and with the intake answers (playbook, step 4)."
} > "$OUT/summary.md"
echo "wrote $OUT/summary.md" >&2
