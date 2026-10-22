#!/usr/bin/env bash
# Tests for tools/report-pdf.sh: a clean source builds and passes; an id that does not reach the
# PDF text fails the build.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../report-pdf.sh"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
printf '# Stage 3 — gap\n\n## 1. Result\n\nG-01 rests on E-001 and L-07.\n\n| ID | Object | Result | Evidence |\n|---|---|---|---|\n| G-01 | `signal.name` | differs | E-001 |\n' > "$tmp/ok.md"
"$tool" --project Demo --stage 3 --version abc1234 --out "$tmp/ok.pdf" "$tmp/ok.md" >/dev/null \
  || { echo "✗ clean source: expected exit 0"; exit 1; }
echo "✓ clean source"
cp "$tmp/ok.md" "$tmp/hidden.md"; printf '\n<!-- E-099 -->\n' >> "$tmp/hidden.md"
if "$tool" --project Demo --stage 3 --version abc1234 --out "$tmp/h.pdf" "$tmp/hidden.md" >/dev/null; then
  echo "✗ an id missing from the PDF text: expected a failure"; exit 1; fi
echo "✓ an id missing from the PDF text fails"
cp "$tmp/ok.md" "$tmp/html.md"; printf '\n<div class="pb"></div>\n' >> "$tmp/html.md"
if "$tool" --project Demo --stage 3 --version abc1234 --out "$tmp/x.pdf" "$tmp/html.md" >/dev/null; then
  echo "✗ HTML in the Markdown: expected a failure"; exit 1; fi
echo "✓ HTML in the Markdown fails"
