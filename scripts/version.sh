#!/usr/bin/env bash
# Prints the kit version from the README status table (| Author | Version | Licence |).
set -euo pipefail
cd "$(dirname "$0")/.."
awk -F'|' 'NR>4 && $3 ~ /[0-9]+\.[0-9]+\.[0-9]+/ {gsub(/ /,"",$3); print $3; exit}' README.md
