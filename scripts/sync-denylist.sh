#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Sync the denylist from its private source to the two places the guardrails read it:
#   the GUARDRAIL_DENYLIST secret of this repository (CI, release) and .guardrails-denylist
#   (local runs, git-ignored).
#   scripts/sync-denylist.sh [path]   path defaults to $GUARDRAIL_DENYLIST_FILE
# The source lives outside this repository: publishing it would publish the names it protects.
# Terms never reach the command line or the output; only counts are printed.
set -euo pipefail
cd "$(dirname "$0")/.."
SRC="${1:-${GUARDRAIL_DENYLIST_FILE:-}}"
[ -n "$SRC" ] || { echo "usage: $0 PATH (or set GUARDRAIL_DENYLIST_FILE)" >&2; exit 2; }
[ -f "$SRC" ] || { echo "not a file: $SRC" >&2; exit 2; }
TERMS="$(sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$SRC" | grep -c . || true)"
[ "$TERMS" -gt 0 ] || { echo "no terms in $SRC — refusing to blank the denylist" >&2; exit 1; }
command -v gh >/dev/null || { echo "gh CLI not found" >&2; exit 2; }

gh secret set GUARDRAIL_DENYLIST < "$SRC"
cp "$SRC" .guardrails-denylist
echo "✓ GUARDRAIL_DENYLIST and .guardrails-denylist set: $TERMS terms"
bash scripts/guardrails.sh | head -1
