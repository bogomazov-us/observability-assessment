# Contributing

1. **Generic only.** No client, employer, product or system names; no people; no figures, error
   codes, hostnames or tenants from a real engagement. Write "an e-commerce booking flow", not
   the name of the system.
2. **Text sources only.** Markdown, shell, CSS, workflow YAML. No PDFs, slides, spreadsheets,
   HAR captures or exports — the guardrails reject them.
3. **Run the guardrails before every commit:** `scripts/guardrails.sh`. Keep your own
   denylist in `.guardrails-denylist` (git-ignored, one term per line); the CI uses the
   `GUARDRAIL_DENYLIST` secret.
4. **A new file** goes into `scripts/files.sh`, or the guardrails fail.
5. **Release:** raise the version in the README status table, merge to `main`, then tag
   `vX.Y.Z` on `main`. The release workflow re-runs the guardrails, checks the tag against the
   README, builds the PDF, checks the PDF text, and attaches it to the GitHub release.
6. Build locally with `scripts/build.sh --downloads` (needs pandoc and weasyprint).
