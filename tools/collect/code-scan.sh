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

EXCLUDE_DIRS=(node_modules vendor dist build .git .next out target bin obj coverage __pycache__ .venv venv site-packages .tox .cache)
# Generated and packed files: minified bundles, source maps, lock files, compiler build info, snapshots.
EXCLUDE_FILES=('*.min.js' '*.min.css' '*.map' '*.lock' package-lock.json yarn.lock pnpm-lock.yaml '*.tsbuildinfo' '*.snap')
# Files above this size are data (dumps, backups, fixtures), not code: skipped and counted.
MAX_KB="${SCAN_MAX_KB:-512}"

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
  "Retries and timeouts|retr(y|ies)[A-Za-z_]*[[:space:]]*[:=(]|backoff|resilience4j|Polly|timeout[[:space:]]*[:=]|Timeout[[:space:]]*=|connectTimeout|readTimeout|requestTimeout|circuit.?breaker"
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

HEAD="$(mktemp)"; BODY="$(mktemp)"; LIST="$(mktemp)"; trap 'rm -f "$HEAD" "$BODY" "$LIST"' EXIT
PRUNE=(-name "${EXCLUDE_DIRS[0]}"); for d in "${EXCLUDE_DIRS[@]:1}"; do PRUNE+=(-o -name "$d"); done
NAMES=(); for f in "${EXCLUDE_FILES[@]}"; do NAMES+=(! -name "$f"); done
(cd "$REPO" && find . \( "${PRUNE[@]}" \) -prune -o -type f "${NAMES[@]}" -size -"${MAX_KB}"k -print0) > "$LIST"
SKIPPED="$(cd "$REPO" && find . \( "${PRUNE[@]}" \) -prune -o -type f "${NAMES[@]}" ! -size -"${MAX_KB}"k -print | wc -l | tr -d ' ')"

# Where a hit sits: tests and docs are kept apart from code, so the code leads are read first.
kind_of() { awk -F: '{ p = $1; k = "code"
  if (p ~ /(^|\/)(test|tests|__tests__|spec|specs|e2e|cypress|playwright|fixtures)\// || p ~ /\.(test|spec)\.[A-Za-z]+$/ || p ~ /(^|\/)test_[^\/]*\.py$/) k = "tests"
  else if (p ~ /\.(md|mdx|rst|txt|adoc)$/ || p ~ /(^|\/)docs?\//) k = "docs"
  print k "\t" $0 }'; }

{
  echo "# Code scan — $(basename "$(cd "$REPO" && pwd)")"
  echo
  echo "> **Leads, not evidence — confirm each in the tool (playbook, evidence levels).** A hit"
  echo "> says where to look; a missing hit says where to ask. Neither is a finding on its own."
  echo
  echo "Scanned on $(date +%Y-%m-%d). Excluded: ${EXCLUDE_DIRS[*]}, minified, generated and lock files, source maps;"
  echo "$SKIPPED file(s) above ${MAX_KB} KB skipped as data. Hits in tests and docs are counted apart from code."
  echo
  echo "| Group | Code | Tests | Docs | Files |"
  echo "|---|--:|--:|--:|--:|"
} > "$HEAD"

SUMMARY=""
for g in "${SCAN_GROUPS[@]}"; do
  name="${g%%|*}"; re="${g#*|}"
  hits=""
  [ -s "$LIST" ] && hits="$(cd "$REPO" && xargs -0 grep -HnIE -i -- "$re" < "$LIST" 2>/dev/null | sed 's#^\./##' | cut -c1-240 | kind_of || true)"
  nc=0; nt=0; nd=0; nf=0
  if [ -n "$hits" ]; then
    nc="$(printf '%s\n' "$hits" | grep -c '^code' || true)"
    nt="$(printf '%s\n' "$hits" | grep -c '^tests' || true)"
    nd="$(printf '%s\n' "$hits" | grep -c '^docs' || true)"
    nf="$(printf '%s\n' "$hits" | cut -f2- | cut -d: -f1 | sort -u | wc -l | tr -d ' ')"
  fi
  SUMMARY+="| $name | $nc | $nt | $nd | $nf |"$'\n'
  {
    echo "## $name ($((nc + nt + nd)))"
    echo
    if [ -z "$hits" ]; then
      echo "Nothing found. Ask the owner whether it exists elsewhere (another repository, the platform, the tool's own configuration)."
      echo
    else
      for k in code tests docs; do
        part="$(printf '%s\n' "$hits" | awk -F'\t' -v k="$k" '$1 == k { sub(/^[^\t]*\t/, ""); print }')"
        [ -n "$part" ] || continue
        case "$k" in code) echo "### Code" ;; tests) echo "### Tests" ;; docs) echo "### Docs" ;; esac
        echo
        echo '```'
        printf '%s\n' "$part" | sed -E 's/^([^:]+):([0-9]+):[[:space:]]*/\1:\2  /'
        echo '```'
        echo
      done
    fi
  } >> "$BODY"
done

if [ "$OUT" = /dev/stdout ]; then
  { cat "$HEAD"; printf '%s\n' "$SUMMARY"; cat "$BODY"; }
else
  { cat "$HEAD"; printf '%s\n' "$SUMMARY"; cat "$BODY"; } > "$OUT"
  echo "wrote $OUT" >&2
fi
