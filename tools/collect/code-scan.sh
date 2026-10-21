#!/usr/bin/env bash
# Week-one code scan: grep a client code repository for observability leads.
#   tools/collect/code-scan.sh [--signatures FILE] REPO_DIR [OUT.md]
# Writes a Markdown report (stdout when OUT.md is omitted). Every hit is a lead, not
# evidence: confirm it in the tool before it becomes a finding (playbook, evidence levels).
# Read-only: the scan never writes inside REPO_DIR.
set -euo pipefail

usage() { echo "usage: $0 [--signatures FILE] REPO_DIR [OUT.md]" >&2; exit 2; }
SIGNATURES=""
if [ "${1:-}" = "--signatures" ]; then
  [ $# -ge 2 ] && [ -f "$2" ] || { echo "signatures file not found: ${2:-}" >&2; exit 2; }
  SIGNATURES="$2"; shift 2
fi
[ $# -ge 1 ] && [ $# -le 2 ] || usage
REPO="$1"
[ -d "$REPO" ] || { echo "not a directory: $REPO" >&2; exit 2; }
OUT="${2:-/dev/stdout}"

EXCLUDE_DIRS=(node_modules vendor dist build .git .next out target bin obj coverage __pycache__ .venv venv)
GREP_OPTS=(-rnIE --exclude='*.min.js' --exclude='*.min.css' --exclude='*.map' --exclude='*.lock'
  --exclude='package-lock.json' --exclude='yarn.lock' --exclude='pnpm-lock.yaml')
for d in "${EXCLUDE_DIRS[@]}"; do GREP_OPTS+=(--exclude-dir="$d"); done

# Group name | extended regex, matched case-insensitively. The groups are classes, and the
# built-in patterns are vendor-neutral: open standards (W3C trace context, OpenTelemetry) and
# generic terms. A specific tool's signatures come from a file passed with --signatures, one
# "Group name|regex" per line; a known group name extends that group, a new one adds a group.
SCAN_GROUPS=(
  "RUM / browser SDK|(^|[^a-z])rum([^a-z]|$)|real.?user|browser.?(agent|sdk|monitoring)|WebTracerProvider|sdk-trace-web|sendBeacon"
  "Correlation headers|traceparent|tracestate|x-request-id|x-correlation-id|x-b3-traceid|\bb3\b"
  "Server-side agents and instrumentation|-javaagent|opentelemetry|otel[_.-]|OTEL_|apm.?agent|(^|[^a-z])apm([^a-z]|$)|auto.?instrument|TracerProvider|tracer\.(init|start)"
  "Source maps|devtool[[:space:]]*:|hidden-source-map|productionSourceMap|sourcemap[[:space:]]*[:=]|sourceMap[[:space:]]*[:=]|productionBrowserSourceMaps|upload.*source.?map|source.?map.*upload"
  "Errors inside HTTP 200|status\(200\).*(error|fail)|(error|fail).*status\(200\)|HttpStatus\.OK.*(error|fail)|ResponseEntity\.ok\(.*(error|fail)|\"status\"[[:space:]]*:[[:space:]]*\"(DECLINED|FAILED|ERROR|REJECTED)\"|status[[:space:]]*[:=][[:space:]]*[\"'](DECLINED|FAILED|ERROR|REJECTED)[\"']|\"errors\"[[:space:]]*:|errors[[:space:]]*:[[:space:]]*\[|GraphQLError|graphql.*errors"
  "Logging libraries and structure|winston|pino|bunyan|log4j|logback|slf4j|LogstashEncoder|serilog|NLog|structlog|python-json-logger|logging\.getLogger|zap\.New|zerolog|logrus|slog\.|JsonLayout|json_logging|MDC\.put"
  "Retries and timeouts|retry|retries|backoff|resilience4j|Polly|timeout[[:space:]]*[:=]|Timeout[[:space:]]*=|connectTimeout|readTimeout|requestTimeout|circuit.?breaker"
)

if [ -n "$SIGNATURES" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ''|'#'*) continue ;; esac
    gname="${line%%|*}"; gre="${line#*|}"
    [ "$gname" != "$line" ] && [ -n "$gre" ] || { echo "bad signature line (want Group|regex): $line" >&2; exit 2; }
    found=0
    for i in "${!SCAN_GROUPS[@]}"; do
      [ "${SCAN_GROUPS[$i]%%|*}" = "$gname" ] && { SCAN_GROUPS[$i]="${SCAN_GROUPS[$i]}|$gre"; found=1; }
    done
    [ $found -eq 1 ] || SCAN_GROUPS+=("$gname|$gre")
  done < "$SIGNATURES"
fi

HEAD="$(mktemp)"; BODY="$(mktemp)"; trap 'rm -f "$HEAD" "$BODY"' EXIT
{
  echo "# Code scan — $(basename "$(cd "$REPO" && pwd)")"
  echo
  echo "> **Leads, not evidence — confirm each in the tool (playbook, evidence levels).** A hit"
  echo "> says where to look; a missing hit says where to ask. Neither is a finding on its own."
  echo
  echo "Scanned on $(date +%Y-%m-%d). Excluded: ${EXCLUDE_DIRS[*]}, minified files, lock files, source maps."
  echo
  echo "| Group | Hits | Files |"
  echo "|---|--:|--:|"
} > "$HEAD"

SUMMARY=""
for g in "${SCAN_GROUPS[@]}"; do
  name="${g%%|*}"; re="${g#*|}"
  hits="$(cd "$REPO" && grep "${GREP_OPTS[@]}" -i -- "$re" . 2>/dev/null | sed 's#^\./##' | cut -c1-240 || true)"
  if [ -n "$hits" ]; then
    n="$(printf '%s\n' "$hits" | wc -l | tr -d ' ')"
    nf="$(printf '%s\n' "$hits" | cut -d: -f1 | sort -u | wc -l | tr -d ' ')"
  else n=0; nf=0; fi
  SUMMARY+="| $name | $n | $nf |"$'\n'
  {
    echo "## $name ($n)"
    echo
    if [ "$n" -eq 0 ]; then
      echo "Nothing found. Ask the owner whether it exists elsewhere (another repository, the platform, the tool's own configuration)."
    else
      echo '```'
      printf '%s\n' "$hits" | sed -E 's/^([^:]+):([0-9]+):[[:space:]]*/\1:\2  /'
      echo '```'
    fi
    echo
  } >> "$BODY"
done

if [ "$OUT" = /dev/stdout ]; then
  { cat "$HEAD"; printf '%s\n' "$SUMMARY"; cat "$BODY"; }
else
  { cat "$HEAD"; printf '%s\n' "$SUMMARY"; cat "$BODY"; } > "$OUT"
  echo "wrote $OUT" >&2
fi
