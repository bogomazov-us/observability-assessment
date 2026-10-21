#!/usr/bin/env bash
# Tests for tools/collect: no network. The fake source tree and a stub curl are generated at
# run time, so no foreign file types are committed to the kit.
set -euo pipefail
cd "$(dirname "$0")/../.."
COLLECT=tools/collect
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
FAIL=0
pass() { echo "✓ $*"; }
fail() { echo "✗ $*"; FAIL=1; }
expect() { # $1 description, $2 file, $3 fixed string
  grep -qF -- "$3" "$2" && pass "$1" || fail "$1 (missing: $3)"
}

# 1. code-scan on a fake repository
R="$T/repo"; mkdir -p "$R/web/src" "$R/svc/src/main/java" "$R/web/node_modules/lib"
cat > "$R/web/src/main.js" <<'EOF'
import { datadogRum } from '@datadog/browser-rum';
datadogRum.init({ applicationId: 'app', clientToken: 'token', service: 'shop' });
fetch('/api/orders', { headers: { traceparent: makeTraceparent() } });
EOF
cat > "$R/web/webpack.config.js" <<'EOF'
module.exports = { devtool: 'hidden-source-map' };
EOF
cat > "$R/svc/src/main/java/PaymentController.java" <<'EOF'
import io.opentelemetry.api.trace.Span;
class PaymentController {
  Object pay() { return ResponseEntity.ok(Map.of("status", "DECLINED", "error", "PROVIDER_TIMEOUT")); }
}
EOF
cat > "$R/web/node_modules/lib/index.js" <<'EOF'
datadogRum.init({}); // vendored, must be excluded
EOF
cat > "$R/web/src/bundle.min.js" <<'EOF'
datadogRum.init({})
EOF

"$COLLECT/code-scan.sh" "$R" "$T/scan.md" 2>/dev/null
expect "scan: header says leads, not evidence" "$T/scan.md" "Leads, not evidence"
expect "scan: RUM group counts 2 hits in 1 file" "$T/scan.md" "| RUM / browser SDK | 2 | 1 |"
expect "scan: correlation header found" "$T/scan.md" "web/src/main.js:3"
expect "scan: server-side OTel found" "$T/scan.md" "svc/src/main/java/PaymentController.java:1"
expect "scan: error inside 200 found" "$T/scan.md" "svc/src/main/java/PaymentController.java:3"
expect "scan: source maps found" "$T/scan.md" "web/webpack.config.js:1"
expect "scan: empty group is listed, not dropped" "$T/scan.md" "## Logging libraries and structure (0)"
expect "scan: colons inside a matched line survive" "$T/scan.md" "applicationId: 'app'"
grep -q "node_modules/lib" "$T/scan.md" && fail "scan: node_modules excluded" || pass "scan: node_modules excluded"
grep -q 'bundle.min.js' "$T/scan.md" && fail "scan: minified files excluded" || pass "scan: minified files excluded"
[ -z "$(find "$R" -newer "$T/scan.md" -type f)" ] && pass "scan: repository left untouched" || fail "scan: repository left untouched"

# 2. vendor exporters: syntax, and a clear exit 2 without credentials
for s in dynatrace datadog; do
  bash -n "$COLLECT/$s.sh" && pass "$s: syntax" || fail "$s: syntax"
  set +e
  err="$(env -u DT_ENV_URL -u DT_API_TOKEN -u DD_API_KEY -u DD_APP_KEY "$COLLECT/$s.sh" "$T/out-$s" 2>&1 >/dev/null)"; rc=$?
  set -e
  [ "$rc" -eq 2 ] && [[ "$err" == *"missing environment variables"* ]] \
    && pass "$s: exits 2 and names the missing variables" || fail "$s: exits 2 and names the missing variables (rc=$rc: $err)"
done

# 3. vendor exporters against a stub curl: paging, files, summary, secrets not on the command line
mkdir -p "$T/bin"
cat > "$T/bin/curl" <<'EOF'
#!/usr/bin/env bash
# Stub: record the arguments, answer by URL. Refuse anything that is not a plain GET.
url="${@: -1}"; printf '%s\n' "$*" >> "$STUB_LOG"
for a in "$@"; do case "$a" in -X|--request|-d|--data*|-F|--form) echo "stub: non-GET" >&2; exit 9;; esac; done
case "$url" in
  *fail-me*)                   exit 22 ;;
  *entities*SERVICE*)          echo '{"entities":[{"entityId":"S-1"}],"nextPageKey":"k 2"}' ;;
  *entities*nextPageKey=k%202*) echo '{"entities":[{"entityId":"S-2"}]}' ;;
  *entities*)                  echo '{"entities":[]}' ;;
  *settings/objects*alerting.profile*) echo '{"items":[{"objectId":"a"},{"objectId":"b"}]}' ;;
  *settings/objects*)          echo '{"items":[]}' ;;
  */api/v2/slo*)               echo '{"slo":[{"id":"x"}]}' ;;
  */api/v1/synthetic/monitors) echo '{"monitors":[{"entityId":"m"}]}' ;;
  */api/config/v1/dashboards)  echo '{"dashboards":[{"id":"d1"},{"id":"d2"},{"id":"d3"}]}' ;;
  */api/v1/monitor*)           echo '[{"id":1},{"id":2}]' ;;
  */api/v1/dashboard)          echo '{"dashboards":[{"id":"x"}]}' ;;
  */api/v1/slo*)               echo '{"data":[{"id":"s"}]}' ;;
  */api/v1/synthetics/tests)   echo '{"tests":[]}' ;;
  */api/v2/rum/applications)   echo '{"data":[{"id":"r"}]}' ;;
  */api/v2/services/definitions*) echo '{"data":[{"id":"svc"}]}' ;;
  *) echo "stub: unexpected $url" >&2; exit 7 ;;
esac
EOF
chmod +x "$T/bin/curl"
export STUB_LOG="$T/curl.log"; : > "$STUB_LOG"

PATH="$T/bin:$PATH" DT_ENV_URL="https://dt.example" DT_API_TOKEN="SECRET-DT" \
  "$COLLECT/dynatrace.sh" "$T/dt" 2>/dev/null && pass "dynatrace: runs against the stub" || fail "dynatrace: runs against the stub"
expect "dynatrace: services paged across nextPageKey" "$T/dt/summary.md" "| entities-service | 2 |"
expect "dynatrace: alerting profiles counted" "$T/dt/summary.md" "| alerting-profiles | 2 |"
expect "dynatrace: dashboards counted" "$T/dt/summary.md" "| dashboards | 3 |"
[ -f "$T/dt/entities-service.json" ] && pass "dynatrace: one file per export" || fail "dynatrace: one file per export"

PATH="$T/bin:$PATH" DD_API_KEY="SECRET-API" DD_APP_KEY="SECRET-APP" DD_SITE="dd.example" \
  "$COLLECT/datadog.sh" "$T/dd" 2>/dev/null && pass "datadog: runs against the stub" || fail "datadog: runs against the stub"
expect "datadog: monitors counted" "$T/dd/summary.md" "| monitors | 2 |"
expect "datadog: empty export shows 0" "$T/dd/summary.md" "| synthetics-tests | 0 |"
expect "datadog: service definitions counted" "$T/dd/summary.md" "| service-definitions | 1 |"

grep -q SECRET "$STUB_LOG" && fail "credentials kept off the curl command line" || pass "credentials kept off the curl command line"

# A failing request stops the run instead of reporting an empty estate.
set +e
PATH="$T/bin:$PATH" DT_ENV_URL="https://fail-me.example" DT_API_TOKEN="x" "$COLLECT/dynatrace.sh" "$T/dt-fail" >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && [ ! -f "$T/dt-fail/summary.md" ] && pass "dynatrace: a failed request fails the run" || fail "dynatrace: a failed request fails the run (rc=$rc)"

exit $FAIL
