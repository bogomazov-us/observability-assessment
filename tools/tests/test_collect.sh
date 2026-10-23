#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Tests for tools/collect: no network. The fake source tree is generated at
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
import rum from 'acme-rum-sdk';
rum.init({ applicationId: 'app', clientToken: 'token', service: 'shop' });
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
rum.init({}); // vendored, must be excluded
EOF
cat > "$R/web/src/bundle.min.js" <<'EOF'
rum.init({})
EOF

mkdir -p "$R/web/tests" "$R/docs"
cat > "$R/web/tests/checkout.test.js" <<'EOF'
test('retries twice', () => { expect(retry(2)).toBe(true); });
EOF
cat > "$R/docs/observability.md" <<'EOF'
Every request carries a traceparent header.
EOF
echo '{"fileNames":["traceparent", "retry"]}' > "$R/web/tsconfig.tsbuildinfo"
{ echo "// traceparent"; head -c 600000 /dev/zero | tr '\0' 'x'; echo; } > "$R/web/src/dump.js"
"$COLLECT/code-scan.sh" "$R" "$T/scan.md" 2>/dev/null
expect "scan: header says leads, not evidence" "$T/scan.md" "Leads, not evidence"
expect "scan: RUM group counts 2 code hits in 1 file" "$T/scan.md" "| RUM / browser SDK | 2 | 0 | 0 | 1 |"
expect "scan: correlation header found" "$T/scan.md" "web/src/main.js:3"
expect "scan: server-side instrumentation found" "$T/scan.md" "svc/src/main/java/PaymentController.java:1"
expect "scan: error inside 200 found" "$T/scan.md" "svc/src/main/java/PaymentController.java:3"
expect "scan: source maps found" "$T/scan.md" "web/webpack.config.js:1"
expect "scan: empty group is listed, not dropped" "$T/scan.md" "## Logging libraries and structure (0)"
expect "scan: colons inside a matched line survive" "$T/scan.md" "applicationId: 'app'"
expect "scan: a test hit is counted under tests" "$T/scan.md" "### Tests"
expect "scan: a docs hit is counted under docs" "$T/scan.md" "docs/observability.md:1"
expect "scan: correlation split code / tests / docs" "$T/scan.md" "| Correlation headers | 1 | 0 | 1 | 2 |"
grep -q "tsbuildinfo" "$T/scan.md" && fail "scan: generated build info excluded" || pass "scan: generated build info excluded"
grep -q "dump.js" "$T/scan.md" && fail "scan: large files skipped" || pass "scan: large files skipped"
expect "scan: skipped large files are counted" "$T/scan.md" "1 file(s) above 512 KB skipped"
grep -q "node_modules/lib" "$T/scan.md" && fail "scan: node_modules excluded" || pass "scan: node_modules excluded"
grep -q 'bundle.min.js' "$T/scan.md" && fail "scan: minified files excluded" || pass "scan: minified files excluded"
[ -z "$(find "$R" -newer "$T/scan.md" -type f)" ] && pass "scan: repository left untouched" || fail "scan: repository left untouched"

# 2. a tool's own signatures, from a file
cat > "$R/web/src/beacon.js" <<'EOF'
acmeBeacon.start({ app: 'shop' });
xagentBootstrap();
EOF
cat > "$T/signatures" <<'EOF'
# the client's tool, named in the engagement repository, never in the kit
RUM / browser SDK|acmeBeacon
Vendor agent|xagentBootstrap
EOF
"$COLLECT/code-scan.sh" --signatures "$T/signatures" "$R" "$T/scan2.md" 2>/dev/null
expect "signatures: a known group is extended" "$T/scan2.md" "| RUM / browser SDK | 3 | 0 | 0 | 2 |"
expect "signatures: a new group is added" "$T/scan2.md" "| Vendor agent | 1 | 0 | 0 | 1 |"
set +e; "$COLLECT/code-scan.sh" --signatures "$T/nope" "$R" >/dev/null 2>&1; rc=$?; set -e
[ "$rc" -eq 2 ] && pass "signatures: a missing file exits 2" || fail "signatures: a missing file exits 2 (rc=$rc)"

exit $FAIL
