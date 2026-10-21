#!/usr/bin/env bash
# Last guardrail: the denylist and the sensitive patterns, checked on the text of the built PDF.
# Catches anything that entered through the build itself (metadata, templates).
set -uo pipefail
PDF="$1"
TEXT="$(pdftotext "$PDF" - 2>/dev/null)$(pdfinfo "$PDF" 2>/dev/null)"
FAIL=0
DENY="${GUARDRAIL_DENYLIST:-}"
[ -z "$DENY" ] && [ -f "$(dirname "$0")/../.guardrails-denylist" ] && DENY="$(cat "$(dirname "$0")/../.guardrails-denylist")"
while IFS= read -r term; do
  term="${term%%#*}"; term="$(echo "$term" | sed 's/[[:space:]]*$//')"
  [ -z "$term" ] && continue
  echo "$TEXT" | grep -q -i -w -F -- "$term" && { echo "✗ denylisted term in the PDF (term not printed)"; FAIL=1; }
done <<< "$DENY"
echo "$TEXT" | grep -q -E 'AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{30,}|dt0[a-z][0-9]{2}\.' && { echo "✗ token pattern in the PDF"; FAIL=1; }
[ $FAIL -eq 0 ] && echo "✓ PDF clean"
exit $FAIL
