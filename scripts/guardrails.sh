#!/usr/bin/env bash
# Guardrails: run before every commit, in CI on every push, and before every release.
#   scripts/guardrails.sh             all checks
#   scripts/guardrails.sh --tag vX.Y.Z  also check the tag matches the README version
#
# Denylist: words that must never appear (former clients, employers, people, systems).
# It is NOT stored in this repository — that would publish the very names it protects.
# Source, in order: $GUARDRAIL_DENYLIST (one term per line; CI secret), else .guardrails-denylist
# (local, git-ignored). CI fails if neither is present.
set -uo pipefail
cd "$(dirname "$0")/.."
source scripts/files.sh

FAIL=0
fail() { echo "✗ $*"; FAIL=1; }
ok()   { echo "✓ $*"; }

TRACKED=()
while IFS= read -r f; do TRACKED+=("$f"); done < <(git ls-files --cached --others --exclude-standard)
TEXT=()
for f in "${TRACKED[@]}"; do [ -f "$f" ] && [ "$f" != LICENSE ] && TEXT+=("$f"); done

# 1. Denylist
DENY="${GUARDRAIL_DENYLIST:-}"
[ -z "$DENY" ] && [ -f .guardrails-denylist ] && DENY="$(cat .guardrails-denylist)"
if [ -z "$DENY" ]; then
  if [ -n "${CI:-}" ]; then fail "denylist missing: set the GUARDRAIL_DENYLIST secret"; else echo "! denylist missing locally (.guardrails-denylist) — check skipped"; fi
else
  hits=0
  while IFS= read -r term; do
    term="${term%%#*}"; term="$(echo "$term" | sed 's/[[:space:]]*$//')"
    [ -z "$term" ] && continue
    if grep -n -i -w -F -- "$term" "${TEXT[@]}" >/dev/null 2>&1; then
      # print file:line only, never the term itself: CI logs are public
      grep -n -i -w -F -- "$term" "${TEXT[@]}" | cut -d: -f1,2 | sed 's/^/  denylisted term at /'
      hits=1
    fi
  done <<< "$DENY"
  [ $hits -eq 0 ] && ok "no denylisted terms" || fail "denylisted terms found"
fi

# 2. Secrets and personal data patterns
PATTERNS=(
  'AKIA[0-9A-Z]{16}'                          # AWS access key id
  'dt0[a-z][0-9]{2}\.[A-Z0-9]{24}'             # Dynatrace token
  'gh[pousr]_[A-Za-z0-9]{30,}'                 # GitHub token
  'xox[baprs]-[A-Za-z0-9-]{10,}'               # Slack token
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'            # IPv4
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}' # e-mail
  '\b[a-z0-9-]+\.(internal|corp|local|lan)\b'  # internal hostnames
  '\.live\.dynatrace\.com|\.apps\.dynatrace\.com' # tenant URLs
)
phits=0
for p in "${PATTERNS[@]}"; do
  out="$(grep -n -E -- "$p" "${TEXT[@]}" 2>/dev/null | grep -v -E '@bogomazov\.us|scripts/guardrails\.sh')"
  if [ -n "$out" ]; then echo "$out" | cut -d: -f1,2 | sed 's/^/  sensitive pattern at /'; phits=1; fi
done
[ $phits -eq 0 ] && ok "no secrets, e-mails, IPs or internal hosts" || fail "sensitive patterns found"

if command -v gitleaks >/dev/null; then
  gitleaks git --no-banner --redact --log-level error . && ok "gitleaks: clean" || fail "gitleaks found secrets"
else
  [ -n "${CI:-}" ] && fail "gitleaks not installed" || echo "! gitleaks not installed locally — skipped"
fi

# 3. Only expected file types (no client documents, captures or binaries)
bad=0
for f in "${TRACKED[@]}"; do
  case "$f" in
    *.md|*.sh|*.css|*.yml|LICENSE|.gitignore) ;;
    *) echo "  unexpected file: $f"; bad=1 ;;
  esac
done
[ $bad -eq 0 ] && ok "only text sources tracked" || fail "unexpected files (binaries, captures, client documents?)"

# 4. Every Markdown file is in the build, every build file exists
miss=0
for f in "${TRACKED[@]}"; do
  [[ "$f" == *.md && "$f" != CONTRIBUTING.md ]] || continue
  printf '%s\n' "${KIT_FILES[@]}" | grep -qx -- "$f" || { echo "  not in scripts/files.sh: $f"; miss=1; }
done
for f in "${KIT_FILES[@]}"; do [ -f "$f" ] || { echo "  listed but missing: $f"; miss=1; }; done
[ $miss -eq 0 ] && ok "build list matches files" || fail "build list out of sync"

# 5. Relative links resolve
broken=0
for f in "${TRACKED[@]}"; do
  [[ "$f" == *.md ]] || continue
  dir="$(dirname "$f")"
  while IFS= read -r link; do
    target="${link%%#*}"
    [ -z "$target" ] && continue
    case "$target" in http*|mailto:*|../../releases) continue ;; esac
    [ -e "$dir/$target" ] || { echo "  broken link in $f: $link"; broken=1; }
  done < <(grep -oE '\]\([^)]+\)' "$f" | sed -E 's/^\]\((.*)\)$/\1/')
done
[ $broken -eq 0 ] && ok "relative links resolve" || fail "broken links"

# 6. Version and tag
VERSION="$(scripts/version.sh)"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && ok "README version $VERSION" || fail "README version not semver"
if [ "${1:-}" = "--tag" ]; then
  [ "${2:-}" = "v$VERSION" ] && ok "tag ${2} matches README" || fail "tag ${2:-<none>} does not match README version v$VERSION"
fi

exit $FAIL
