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
printf '# Stage 1\n\nG-01 rests on E-001 and E-002.\n\n## Appendix A\n\n### E-001 — a check\n\n- Checked at: 10:00\n- Result: ok\n\n### E-001 — again\n\n- Data window: 7 d\n- Result: ok\n- Limits: none\n' > "$tmp/cat.md"
out="$("$tool" --project Demo --stage 1 --version abc1234 --out "$tmp/c.pdf" "$tmp/cat.md" 2>&1)" && { echo "✗ a broken catalog: expected a failure"; exit 1; }
grep -q "defined more than once: E-001" <<<"$out" || { echo "✗ repeated evidence id not reported"; exit 1; }
grep -q "without a catalog entry: E-002" <<<"$out" || { echo "✗ unresolved evidence id not reported"; exit 1; }
grep -q "E-001 (no limits)" <<<"$out" || { echo "✗ missing evidence field not reported"; exit 1; }
echo "✓ evidence catalog: repeated, unresolved and incomplete entries fail"
printf '# Stage 4\n\nF-001 rests on E-001 and E-002.\n\n## Evidence catalog\n\n| E-id | Check | Window | Result | Limits |\n|---|---|---|---|---|\n| E-001 | a | 7 d | ok | none |\n| E-002 | b | 7 d | ok |  |\n' > "$tmp/tab.md"
out="$("$tool" --project Demo --stage 4 --version abc1234 --out "$tmp/t.pdf" "$tmp/tab.md" 2>&1)" && { echo "✗ a table catalog with an empty limit: expected a failure"; exit 1; }
grep -q "E-002 (no limits)" <<<"$out" || { echo "✗ table catalog field not checked"; exit 1; }
grep -q "without a catalog entry" <<<"$out" && { echo "✗ table catalog ids not resolved"; exit 1; }
echo "✓ evidence catalog as a table: ids resolve, empty fields fail"
