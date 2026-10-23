#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Pinned tool versions for CI (Ubuntu 24.04).
set -euo pipefail
PANDOC=3.5
GITLEAKS=8.21.2
WEASYPRINT=63.1

sudo apt-get update -qq
sudo apt-get install -y -qq libpango-1.0-0 libpangoft2-1.0-0 poppler-utils fonts-ibm-plex python3-yaml jq >/dev/null

curl -fsSL -o /tmp/pandoc.deb "https://github.com/jgm/pandoc/releases/download/${PANDOC}/pandoc-${PANDOC}-1-amd64.deb"
sudo dpkg -i /tmp/pandoc.deb >/dev/null

pipx install "weasyprint==${WEASYPRINT}" >/dev/null

curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS}/gitleaks_${GITLEAKS}_linux_x64.tar.gz" \
  | sudo tar -xz -C /usr/local/bin gitleaks

pandoc --version | head -1; weasyprint --version; gitleaks version
