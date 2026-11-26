[What changes, and why, in a sentence or two.]

- [ ] Generic only: no client, employer, product or system names, no figures from a real engagement
- [ ] `scripts/guardrails.sh` and `scripts/test-tools.sh` pass locally
- [ ] A new Markdown file is listed in `scripts/files.sh` (Markdown under `.github/` is skipped by the build-list check and does not need to be added)
- [ ] The change has a line under `## Unreleased` in `CHANGELOG.md` (not for typo fixes)
- [ ] A deliberate prompt change: goldens refreshed with `UPDATE_GOLDEN=1 tools/tests/test_prompt.sh`, and the reason is above
