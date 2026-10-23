#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Last guardrail: the denylist and the sensitive patterns, checked on the text of the built PDF.
# Catches anything that entered through the build itself (metadata, templates).
set -uo pipefail
PDF="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/patterns.sh"
TEXT="$(pdftotext "$PDF" - 2>/dev/null)
$(pdfinfo "$PDF" 2>/dev/null)"
FAIL=0
DENY="${GUARDRAIL_DENYLIST:-}"
[ -z "$DENY" ] && [ -f "$ROOT/.guardrails-denylist" ] && DENY="$(cat "$ROOT/.guardrails-denylist")"
if [ -z "$DENY" ]; then
  if [ "${GUARDRAIL_REQUIRE_DENYLIST:-}" = 1 ]; then echo "✗ denylist missing"; FAIL=1; else echo "! denylist not available — PDF denylist check skipped"; fi
fi
while IFS= read -r term; do
  term="${term%%#*}"; term="$(echo "$term" | sed 's/[[:space:]]*$//')"
  [ -z "$term" ] && continue
  echo "$TEXT" | grep -q -i -w -F -- "$term" && { echo "✗ denylisted term in the PDF (term not printed)"; FAIL=1; }
done <<< "$DENY"
for p in "${SENSITIVE_PATTERNS[@]}"; do
  echo "$TEXT" | grep -E -- "$p" | grep -q -v -E "$SENSITIVE_ALLOW" && { echo "✗ sensitive pattern in the PDF (match not printed)"; FAIL=1; }
done
[ $FAIL -eq 0 ] && echo "✓ PDF clean"
exit $FAIL
