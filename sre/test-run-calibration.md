# SRE test run — calibration record

The first SRE engagement, run with this kit before its release as the test run that the
[estimation section](README.md#estimation) names. Recorded by the agent during the run and
summarised after it; generic words only. It is an input to calibration, not a change to the
starting values: those change as in the estimation model's "Calibrating", by the maintainer.

## The run

- **Format:** focused (dimensions 1, 2, 4, 6, 9), combined with an observability assessment run
  a month earlier with an older kit version; SRE added in sequence.
- **Estate:** a small production estate on one cloud account; five tier-1 services, six
  tier-1 dependencies; one person is technical, product, data and release owner and the only
  operator; support in working hours only; no incident tracker or paging tool (records kept in
  a knowledge base).
- **Access:** a read-only cloud profile, read access to the CI system and the code; no writes.
- **Output:** 31 inventory rows, 12 catalogue rows, 26 baseline rows, 18 target rows, 23 gap
  rows, 12 findings (7 P2, 5 P3, all confirmed), a profile of 4 scored dimensions, 9
  recommendation cards, 13 work items, 1 verification task, 4 milestones (11–37 engineer-days).
- **Owner questions:** 20 in four batches, all answered; verdicts on 13 findings.

## Hours per stage and role

Agent time is the elapsed time in one session, by the progress-log clock. Owner time is the
owner's messages; reading time was not measured. A sample re-check by another path was never
done (see gap 7).

| Stage | Agent | Owner | Owner questions | Records |
|---|---|---|---|---|
| 0 Setup and init | ~0.3 h | one decision on scope, one on folder | 0 | — |
| 1 Inventory and baseline | ~0.3 h (one background fetch of ~400 CI job records, ~2 min) | 2 messages | 4 | 31 L, 12 S, 26 B; 5 exports |
| 2 Target model | ~0.2 h | 3 messages | 11 | 18 T |
| 3 Gap | ~0.25 h | 3 messages | 4 | 23 G; 3 scenarios written, none run |
| 4 Findings | ~0.3 h (most of it reading 25 earlier findings) | 3 messages | verdict batch of 12 | 12 F |
| 5 Maturity | ~0.2 h | 1 message | 1 | profile; 1 pair conflict |
| 6 Recommendations | ~0.2 h | 1 message | decision request | 9 REC, 13 W, 1 V, 4 milestones |
| **Total** | **~1.75 h agent** | **~13 messages; reading not timed** | **20 + 13 verdicts** | |

Per stage the record-keeping after each confirmation (decision row, risk, fact, state file,
checks, merge) took a further 5–10 minutes of agent time, not counted above. Plus about
3 minutes of CI wait per stage.

Calibration reading: for a single-owner estate of this size the agent part fits in one
evening; the bottleneck is the owner's answers, and the kit's estimation model should size the
owner's reading time per batch, not the agent's hours.

## Kit gaps, by priority

### Fix before release

1. **Init assumes the kit's own registers at the repository root.** A client knowledge base
   with its own decision records (ADR files), facts ledger and risk register had to be passed in
   by flags; there is no "decisions live in ADRs" mode, and init would create a kit-format file
   where a path is missing. Init also writes absolute machine-local paths into a tracked file.
2. **A combined run in sequence is not described.** Where the shared id sequences start when
   the first run used an older kit (owner questions per stage, no state file); whether a second
   type opens a new verdict batch or extends the first; who edits the first type's profile when
   the pair check asks to move a dimension to "see other" (the second type's agent may not edit
   it, so the conflict is guaranteed); how a conditional card of the first type is promoted when
   the second type's verdict confirms its finding; and how the second type's roadmap joins a
   roadmap already confirmed. Each was improvised.
3. **Stage 2 sets no target level per dimension, but stage 3 expects one.** Most incident,
   change-safety and backup criteria (severity, reviews, change failure rate, backup monitoring,
   a DR plan) have no target value, so the gap had nothing to measure against until an owner
   question asked for a yardstick. Add a stage-2 row: target level per dimension in scope.
4. **Incidents are one population.** The owner separated service outages from data-correctness
   defects: their detection times differ by orders of magnitude (minutes vs weeks), and mixing
   them makes every time number meaningless. Add a `class` column to the incident export,
   per-class baseline rows, and a model line for detecting data-correctness defects.
5. **The baseline tool takes one window for all inputs** and incidents as a required positional
   argument; sources keep different histories (alarm history 30 days, deploys months), so pages
   had to be run alone with a dummy incidents file. "Pages per shift" assumes round-the-clock
   shifts and is meaningless for a working-hours single operator; there is no "no rotation"
   mode.
6. **"Deploy" is not defined.** Where deploys are an infrastructure pipeline applying on merge,
   the kit needs a rule: which job counts, and that a pipeline failure is not a failure in
   production (change failure rate from pipeline failures is a labelled proxy). Lead time needs
   the first commit of a change, which merge records do not give.
7. **No record of the sample re-check, or of a verdict given without one.** At every stage the
   owner confirmed in one message and no re-check by another path was run; the state file and
   the verdict batch have no field to say so. Add one.
8. **Questions belong in the conversation, not only in the file.** The owner asked three times
   to see the questions on screen. The prompts should say: present each batch inline, every item
   with its claim, its basis and the options, plus a one-line answer template.
9. **The stage-3 prompt numbers evidence `E-3xx`** while the engagement shares one `E-`
   sequence; the prompt contradicts the sequence rule.
10. **No stage closes the report.** The stage prompts never say that, at each accepted stage,
    the summary chapter is rewritten and the stage's lines are added to the assessment
    manifest. In the test run all six stages were confirmed with neither done; the combined
    report existed only as separate stage files until the owner asked where the report was.
    Suggest a closing step in each stage prompt, or a stage-gate rule that refuses stage N+1
    while the manifest lacks stage N.
11. **The report build is observability-only.** The PDF script hard-codes an observability
    title and file prefix and strips only the observability prefix from chapter titles, so an
    SRE or combined report gets the wrong title. Its evidence check accepts only catalog
    headings per `E-` id or table rows with window, result and limits columns: evidence written
    as bold bullets inside finding files counts as a citation, not an entry, and a stage-1
    catalog table holding only commands failed the build. The stage-1 SRE prompt could require
    the catalog columns the build checks.

### Fix soon

12. Templates are observability-shaped where SRE needs its own: the kickoff note (journeys,
    monitoring tools) lacks proposed tiers, incident, paging and backup records; the state file
    comments still speak of a monitoring estate; the generated instructions print observability
    paths for an SRE-only setup.
13. The status sets have no value for "out of scope by format" (inventory, not-measured
    baseline numbers, the stage-4 self-check) or for "absent by design" (no incident tracker,
    no rotation); "not verifiable" was used with a reason.
14. A target agreed on a premise (a store "holds only rebuildable files") has no field for the
    premise; stage 3 found the code contradicting it. Add a premise field to target rows.
15. "Restore tested" does not say the restore must come from the backups the RPO relies on: a
    one-off logical copy made for a migration reads as a restore on record.
16. A rollout-policy target phrased by service kind left a scheduled task in tier 1 uncovered;
    the kind could prompt "which workloads".
17. Stage 4 has no case for a gap measured against no target by the owner's explicit choice;
    and its "separate findings when fixes differ" rule can exceed the ~10-question batch cap.
18. The SRE severity reading has no example for "process absent, recovery met anyway" (one
    operator, every outage inside the RTO); and the model's incident level 2 ("on-call exists")
    has no reading for "support mode agreed on paper, practice not shown".
19. A maturity level resting on a finding of the other type, still without a verdict, has no
    owner for that verdict; the second type's batch could carry the first type's open findings
    it relies on.
20. Milestone ids `M-` collide by prefix with the facts-ledger ids of a host knowledge base;
    reserve a distinct prefix.

### Small

21. The copied owner-questions template keeps kit-relative links that break in the engagement.
22. Undocumented: `--instructions` accepts a subpath.
23. Stage 6 forbids queries, but a verification task may be a read-only check the agent could
    close before hand-over.
24. Stage 6's confirmation batch is a no-op when every finding has a verdict; say "none
    needed" is a valid result.
25. Stage 2, when tiers were decided at scope: the prompt only says "propose a tier"; it should
    say "cite the decision".
26. A withdrawn id before hand-over leaves a hole; the counts must say so (worked, but not
    written down).

### Process lessons for the agent (not kit)

- On a repository with no required checks, `gh pr merge --auto` merges at once, before CI
  ends: wait for the check-run on the head commit, then merge with `--match-head-commit`.
- Writing estimated times into the progress log was caught by its own rule and corrected by an
  appended note.
