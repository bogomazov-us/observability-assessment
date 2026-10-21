# Contributing

1. **Generic only.** No client, employer, product or system names; no people; no figures, error
   codes, hostnames or tenants from a real engagement. Write "an e-commerce booking flow", not
   the name of the system.
2. **Text sources only.** Markdown, shell, CSS, workflow YAML. No PDFs, slides, spreadsheets,
   HAR captures or exports — the guardrails reject them.
3. **Run the guardrails before every commit:** `scripts/guardrails.sh`. Keep your own
   denylist in `.guardrails-denylist` (git-ignored, one term per line); the CI uses the
   `GUARDRAIL_DENYLIST` secret. A pull request from a fork gets no secrets, so its CI runs the
   public checks and skips the denylist; the maintainer runs the denylist locally before
   merging, and pushes to `main` and every release require it.
4. **A new file** goes into `scripts/files.sh`, or the guardrails fail.
5. **Release:** raise the version in the README status table, merge to `main`, then tag
   `vX.Y.Z` on `main`. The release workflow re-runs the guardrails, checks the tag against the
   README, builds the PDF, checks the PDF text, and attaches it to the GitHub release.
6. Build locally with `scripts/build.sh --downloads` (needs pandoc and weasyprint). Another edition
   (own title, author, footer, file list, extra chapters) is built from a repository that holds
   this one as a git submodule: `kit/scripts/build.sh --config edition.conf`.
