#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Pinned tool versions for CI (Ubuntu 24.04). Downloads are checked against a SHA-256 before use:
# gitleaks' from its published checksums file, pandoc's (none published) from the release asset
# when the version was pinned. A new version needs a new hash.
set -euo pipefail
PANDOC=3.5
PANDOC_SHA256=4f41d817d262ef3d17953a3e6e0fefddb971aa4f2f121544a9a86db449d945e1
GITLEAKS=8.21.2
GITLEAKS_SHA256=5bc41815076e6ed6ef8fbecc9d9b75bcae31f39029ceb55da08086315316e3ba
WEASYPRINT=63.1
RUFF=0.16.2

sudo apt-get update -qq
sudo apt-get install -y -qq libpango-1.0-0 libpangoft2-1.0-0 poppler-utils fonts-ibm-plex python3-yaml jq shellcheck >/dev/null

curl -fsSL -o /tmp/pandoc.deb "https://github.com/jgm/pandoc/releases/download/${PANDOC}/pandoc-${PANDOC}-1-amd64.deb"
echo "${PANDOC_SHA256}  /tmp/pandoc.deb" | sha256sum -c --quiet -
sudo dpkg -i /tmp/pandoc.deb >/dev/null

pipx install "weasyprint==${WEASYPRINT}" >/dev/null
pipx install "ruff==${RUFF}" >/dev/null

curl -fsSL -o /tmp/gitleaks.tar.gz "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS}/gitleaks_${GITLEAKS}_linux_x64.tar.gz"
echo "${GITLEAKS_SHA256}  /tmp/gitleaks.tar.gz" | sha256sum -c --quiet -
sudo tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin gitleaks

pandoc --version | head -1; weasyprint --version; gitleaks version; shellcheck --version | sed -n 2p; ruff --version
