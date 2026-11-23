# Changelog

What changed in each release, for someone who used the previous one. The release notes on
GitHub are taken from the section of the tagged version.

## Unreleased

## 0.15.2 — 2026-11-23

Readable chapters after the SRE releases, setup fixes, and the client's time in the estimate.

- **Chapters split for reading**:
  - `method/report.md`, new: the report from stage to acceptance (one report per assessment,
    the manifest, closing, acceptance, hand-over), moved from `templates/stage-report.md`,
    which now holds only the stage-chapter template;
  - `tools/agent/setup.md`, new: setting up the engagement repository and the artifact paths,
    moved from `tools/agent/README.md`, which keeps running a stage;
  - each long chapter opens with "What is here" and "Read it when";
  - `sre/README.md`: a table for a lead who knows the observability assessment, what differs in SRE.
- **Setup** (`init-engagement.sh`): a register named by flag and missing makes init exit 1 after
  writing the rest; with the kit in the home folder and the repository outside it, init warns
  that the relative paths name the home folder.
- **SRE estimation**: the client's time (the owner about 1 hour per question batch, 6–8 hours
  focused, 10–12 full) and a 2-working-day answer turnaround, also a client obligation in
  `templates/sow.md`. The team's days stay starting values.
- **SRE mapping** to DORA and Well-Architected, rows 2, 4 and 10 re-checked with best-practice
  ids.
- `scripts/test-tools.sh` prints every failed check of a failing test.

## 0.15.1 — 2026-11-23

Lessons from closing the first SRE engagement: how a report is closed and accepted, owner
questions asked from the registers, and gaps in the SRE pack. Both assessment types.

- **Closing the report** (`templates/stage-report.md`, "Closing the report"): a closing check
  of every decision the report calls open against the decision register and facts ledger; answers
  read against earlier decisions; the hand-over; acceptance as a `D-` row with the summary's
  status; the final PDFs rebuilt from the merged commit. Both stage 6 prompts point to it.
- **Summary** (`templates/report.md`): states the current position, while stage chapters stay
  history with a dated "Later" note; decisions cited with their record ("ADR-007 item 3", never a
  bare "item 3"); a new section 9, Hand-over: open decisions, decided work not yet scheduled with
  its owner, what only the client can do.
- **Owner questions** (`tools/agent/rules/owner-questions.md`, `templates/owner-questions.md`):
  asked from the registers, not the report; each option names one card or record; an answer is
  checked against earlier decisions before it is recorded; every batch is shown in the
  conversation with an answer template, now for observability too. The rule files were
  tightened to pay for it: every prompt stays under 2,500 words, and the observability prompts
  change only in these rule lines and two trims in stage 2.
- **SRE pack**:
  - stage 2: a change-safety target lists every tier-1 workload kind it covers;
  - stage 4: a gap with no target by the owner's choice; splitting a verdict batch over ten;
    severity examples for "process absent, recovery met anyway" and "on-call agreed on paper";
    in the combined format the batch carries the other type's open findings it relies on;
  - the model: a criterion met only on paper reads partial;
  - the catalogue and targets templates give a narrow report table, the full one in the
    evidence bundle;
  - `templates/recovery-proof.md`: a hand-over for a test the client's people run.
- **Records** (`method/records.md`): a kit id is cited with its file where a host's ledgers use
  the same prefix ("roadmap M-3").
- **Report build**: the manifest format is documented as a contract (`tools/assessment-pdf.sh`,
  `tools/agent/README.md`, "The manifest"); an unmatched selector is reported; the evidence
  bundle takes wide record tables without the warning; `tools/report-pdf.sh` no longer fails on
  sources that cite no id.

## 0.15.0 — 2026-11-23

Adds the **SRE assessment** as a second assessment type on the same core. Observability stays
the root type and is unchanged: its six assembled prompts are byte-identical apart from two
rule lines, and an engagement set up without `--assessment` gets exactly the 0.14 layout.

- **SRE type** (`sre/`):
  - `sre/README.md`: the focused, full and combined formats, scope limits, the calendar,
    starting values for estimation (an SRE engineer column), the combined format with overlaps
    scored once, the report, setup and prompts, and how SRE is added to an observability
    assessment already under way ("In sequence");
  - `sre/maturity-model.md`: 10 dimensions with level criteria, mapped to DORA's four keys and
    the reliability pillar of the Well-Architected Framework, and the overlap table with the
    observability model;
  - six agent stages in `sre/agent/`, each with a reference file and a skill
    (`oa-sre-stage-N-*`);
  - templates: service catalogue (`S-`), reliability targets (`T-`, with a target level per
    dimension and a premise column), readiness review, recovery proof, and SRE rows for the
    data request and interview guide;
  - a synthetic worked example with CSV exports, checked in CI.
- **Setup by type**:
  - `init-engagement.sh --assessment observability|sre`, repeatable; SRE files go to
    `<work>/sre/`, owner questions and findings stay shared;
  - registers named by `--facts`, `--decisions` (a file or a folder of ADRs) or `--risks` are
    the host's and are never created or written;
  - paths written into the engagement are relative to the repository;
  - `install.sh --rules` installs only the rule skills.
- **Tools**:
  - `prompt.sh --assessment sre N`;
  - `tools/baseline.py`: baseline numbers (`B-`) from CSV exports of deploys, incidents and
    pages, a window per input, an optional incident `class`, and `--no-rotation`;
  - `maturity.py`: a model per type (`model: sre`) and `--pair` for the combined format;
  - `stagegate.py`: the assessment type (G13) and the recorded sample re-check (G14);
  - `assessment-pdf.sh`: title and file prefix follow the types in the manifest.
- **Core**: one row or link per document for the second type (offerings, estimation, getting
  started, report, finding, SOW, executive deck, records); the consistency check covers `sre/`
  and checks that the shared method sentences match in both types' stage prompts.
- Calibrated on a test run on a real engagement before release; only generic lessons
  entered the kit.
- CI writes the word delta of each pull request to the job summary.

## 0.14.0 — 2026-11-21

Closes the gaps found in the 0.13.2 retrospective: the method says each thing once, the agent
route has a path for every file, and the stage prompts are shorter.

- **Engagement calendar** (`method/getting-started.md`, "3. Calendar"): weeks 1–6 of the
  full assessment with phases, playbook steps, agent stages, meetings and client deliveries,
  and a three-week focused variant. Other documents link it instead of restating weeks.
- **Roles, records and ids defined once** (`method/records.md`):
  - who sets which status;
  - the decision register and when a decision also gets an ADR (new `templates/adr.md`);
  - one registry of id prefixes (`D-` now means only the decision register);
  - every status set.
- **One report model** (`templates/stage-report.md`): a summary chapter (`summary.md`, from
  `templates/report.md`) rewritten at each accepted stage, plus a chapter per accepted stage,
  assembled by `tools/assessment-pdf.sh`. The executive deck names the chapters it is built
  from.
- **Consistency check** (`scripts/consistency.py`, run by the guardrails):
  - week numbers outside the calendar;
  - id prefixes missing from the registry;
  - incomplete status lists;
  - stage gate phrases that differ between the README and the prompts.
  Exceptions go in `scripts/consistency-allow.yml`.
- **Agent route**:
  - one table of artifact paths, with who makes and who reads each file (`tools/agent/README.md`), checked by a test;
  - stage 1 keeps raw exports in `exports/` and the code scan in `scan.md`;
  - a risk register (`templates/risk-register.md`, `R-`; `init-engagement.sh --risks`);
  - findings that people write before stage 4 are an input to it, and stage 4 reconciles rather than redrafts;
  - getting started §6 gives the first-confirmation lint as numbered steps.
- **Intake**:
  - `templates/kickoff-note.md` and `templates/interview-guide.md`;
  - new data request rows (HAR captures, billing, golden journey access, monitoring access per object class), each with "Needed by (week)".
- **Phases of the full assessment**:
  - golden journey proof has a template (`templates/golden-journey-proof.md`) and a week;
  - Operationalize is an optional priced phase (estimation, offerings, SOW);
  - "30/60/90" is gone from the report, SOW and deck;
  - client review rounds and stage reviews are told apart.
- **Worked example in the current method**:
  - records with ids;
  - an agent thread for stage 3 in `example/agent/`;
  - a maturity profile in `example/maturity.yml`, checked in CI (`tools/tests/test_example.sh`).
- **Shorter stage prompts**:
  - stages 2 and 3 keep their steps in the prompt and move rules and tables to `tools/agent/reference/`;
  - claims are one numbered checklist;
  - every assembled prompt is at most 2,500 words (tested);
  - `scripts/word-delta.sh` reports the word delta against a base.

## 0.13.2 — 2026-11-14

- **A "live" signal is confirmed through another path** than the agent's query: lesson 21 in
  `method/lessons.md`; what the person confirms in stages 1 and 3; the harness table in
  `method/agent-harness.md`. Re-running the agent's query shows it repeats, not that the
  signal is live.

## 0.13.1 — 2026-11-14

- `tools/agent/init-engagement.sh --force` no longer replaces `engagement-state.yml`: it holds
  the stage confirmations, and `--force` is for refreshing the instructions and skills after a
  kit upgrade.

## 0.13.0 — 2026-11-14

- **Engagement setup in one command** (`tools/agent/init-engagement.sh`): writes the agent's
  standing instructions (`AGENTS.md` or the file your agent tool reads, from the new
  `templates/agent-instructions.md`) with the paths filled in, the stage-gate state file, the
  owner-questions file, the progress folder, a facts ledger and a decision register, and
  optionally installs the skills.
- **Getting started with the agent stages** (`method/getting-started.md`, section 6): the
  whole route with an agent, from setup to the last confirmed stage, and what the person does
  at each step.
- `tools/agent/skills/install.sh` no longer reports "kept 0" when it kept nothing.

## 0.12.0 — 2026-11-14

- **Stage and rule skills** (`tools/agent/skills/`, optional): a skill per stage that only the
  person starts, and a skill per shared rule that the agent reaches for unasked. Each points
  at the stage prompt or rule file and copies nothing; `install.sh SKILLS_DIR` installs them
  into an engagement with this kit checkout's path.
- **Owner questions as a written batch** (`templates/owner-questions.md`): one decision per
  question in plain words, what it blocks, candidates marked with what each rests on, the
  answer recorded in the decision register before use; with a verdict batch for the findings
  after stage 4. The shared owner-questions rule hands questions over in this format.
- **Engagement glossary in the spec** (`glossary` in `observability-spec.yml`): the names of
  journeys, functions and attempts, fixed in stage 2 and used after it. `tools/speclint.py`
  reports an item without an entry (SL021), a renamed item (SL022), a term defined twice
  (SL023) and an entry naming an unknown id (SL013). The worked example has its glossary.
  An existing spec without a glossary now gets one SL021 warning, which fails `--strict`.
- **The build fails on a missing chapter.** `scripts/build.sh` stops and names every file
  listed in the build (or in an edition's config) that does not exist. Before, it printed a
  warning and produced a PDF without the chapter.

## 0.11.0 — 2026-11-14

- **Rules every agent stage shares, in one place** (`tools/agent/rules/`): common boundaries,
  citing evidence, claims within what was checked, owner questions, the progress log. The six
  stage prompts name them instead of copying them; stages 2, 4, 5 and 6 now carry the claim
  wording rules and the rule on secrets, which only stages 1 and 3 had. `tools/agent/prompt.sh N`
  assembles a stage with its rules into one prompt to paste.
- **Stage gate in a file** (`templates/engagement-state.yml`, `tools/stagegate.py`): each
  stage's status, who confirmed it, when, and the decision-register reference; the owner
  questions that block a stage. `check N` says whether stage N may start; `lint` checks the
  file, and with `--since REV` that no review was edited and no confirmation rewritten. Every
  stage runs the check first and stops on a shut gate (`rules/boundaries.md`); the agent never
  sets a stage confirmed.

## 0.10.0 — 2026-10-23

- **Two licences.** Text stays under CC BY 4.0; the code in `tools/` and `scripts/` (`.py`, `.sh`,
  `.pl`, `.css` and the test fixtures) is under Apache 2.0 (`LICENSE-CODE`), which carries the
  patent grant code users expect. Each code file has an SPDX line; the PDF footer names both.
  Releases up to 0.9.0 stay available under CC BY 4.0.

## 0.9.0 — 2026-10-23

- **Roadmap from the stage-6 plan** (`templates/roadmap.md`, shape A), from the first
  engagement's roadmap: milestones grouped along the per-alert paging gates; every work item in
  exactly one milestone, checked by a script; dependencies only backwards; an exit result that
  is a recorded test or a configuration read; a recommendation delivered only when its work
  items' exits are recorded; no dates until the executor is known, effort as engineer-day ranges
  from a stated size mapping; per milestone what it moves on the profile and what it changes in
  the architecture. The launch-to-BAU milestones stay as shape B. The stage-6 prompt and the
  playbook point to it.
- **Two lessons told as cases** (`method/lessons.md`): read the bill before sizing telemetry
  work, with no formula, because reading and attributing it depends on the platform; and a living
  book behind the client's sign-in as the working view beside the report of record.
- **First pilot measurement of the harness** (`method/agent-harness.md`): count acceptance on
  findings with a verdict, strict and lenient; record person hours while each stage runs, because
  rebuilt from message timestamps they are only a wide range.

## 0.8.1 — 2026-10-22

- **Report PDF:** a two-column table with an empty header — a list of labels and values such as
  "Checked", "Main limits", "Next step" — keeps its label column whole; a long value had squeezed
  the labels until they broke letter by letter.
- A table row in a stage report is kept on one page, so a row's id no longer stands alone at the
  foot of a page with its text on the next.

## 0.8.0 — 2026-10-22

- **One report for the whole assessment**, from the first engagement, where the client was
  handed a dozen PDFs (stage reports, notes, question lists, batches, re-checks, plan, drafts):
  the client now reads two documents — the assessment report, which grows by a chapter per
  accepted stage and opens with the current state, and the evidence bundle with every record and
  catalog. Sources stay per stage; `tools/assessment-pdf.sh` builds both from a manifest that picks
  each file's sections, and fails when an id the report cites is not in the bundle. Working files
  stay in the repository as history (`templates/stage-report.md`).
- `tools/report-pdf.sh`: `--part` sets the footer's middle field; with `--external` the cited
  evidence ids are checked even when the sources hold no catalog of their own.
- **Five verdicts for a finding**, from the first engagement's stages 4–6 and their reviews:
  confirmed, disputed (with the reason), refuted, inconclusive, resolved. Did not reproduce is
  not refuted; a claim is bounded to its window and scope before its verdict; a decision record
  is not technical evidence; confirmed does not mean fixed. Verdicts are the owner's; re-checks
  are read-only evidence with their own ids (`finding.md`, stage-4 prompt, review checklist).
- **Paging is admitted per alert**, not by a maturity level: a gate of alert quality, response,
  outside-in and a tested independent delivery path; one responsible person is not a rota; a
  recorded test is not a passed gate; where failure and delivery tests run; synthetic identities,
  blocked checks and missing data per input (`spec-set/slo-alerts.md`, stage-3 prompt).
- **Support mode** asked at intake: hours of use and who is responsible in them. Working-hours
  support without off-hours on-call is an agreed mode, not a defect; dimension 8 is read against
  it; a silent answer is "not confirmed by the evidence".
- **Stage 5:** levels may be provisional before the verdicts and are re-read by a dated entry;
  wording within the evidence; dimension 12 in sequence, inputs first (`maturity-model.md`).
- **Stage 6:** three kinds of record — `REC-` on confirmed findings only, `V-` verification
  tasks, `W-` work towards an accepted decision; a confirmation batch before the first `REC-`;
  no dependency cycles; done when is a reproducible test, not a production event; sizes are
  not durations.
- **Harness:** a reviewer's recommendation stays one until the owner approves; owner decisions
  are recorded by the session the owner spoke to; progress-log times read from the clock;
  parallel agents commit only their own files.

## 0.7.3 — 2026-10-22

- **Report PDF:** a short code token such as a commit hash stays on one line (a change-history cell
  broke `8a71785` character by character); table headers break only between words, so a narrow
  `Confidence` column keeps its header whole; `--stage "Stage 5"` no longer prints "stage Stage 5"
  in the title and footer.

## 0.7.2 — 2026-10-22

- **Ids stay whole in the PDF:** a narrow table column broke `F-06` at its hyphen, so the text
  no longer held the id; the HTML post-processing (`tools/wide-tables.pl`) keeps every stable id
  on one line. Long paths and code in cells now wrap anywhere, so a wide catalog table no longer
  runs off the page and cuts its right-hand columns; a report row may break across pages.
- The evidence-catalog check accepts a catalog kept as a table (first cell the id; window,
  result and limits columns filled), as stage 4's is, so later stages can cite it with
  `--external`.

## 0.7.1 — 2026-10-22

- **The kit's own PDF follows its layout rules**, from the review of 0.7.0: a chapter with a
  table wider than six columns is set landscape as a whole (`tools/wide-tables.pl` marks such
  tables in stage reports too); chapters no longer force a page break, so no page is left with
  a line or two; orphans and widows held.
- **Stages 5 and 6 in the stage-report template:** their chains and required fields (the
  profile without an overall number, the empty search behind a level 1; every confirmed finding
  answered or left out with a reason, every decision with its decider).
- **A severity scale** in `finding.md`: P1, P2, P3 by what happens when the defect meets a
  failure, not by whether it was seen in production; apart from confidence, implementation
  priority and the paging severity of an alert; provisional where cause or impact is not
  established; linked findings assessed together. From the first engagement, where the review
  moved five severities.
- `tools/report-pdf.sh` checks the evidence catalog: every cited `E-` id resolves (here or in an
  `--external` report), no entry id repeats, each entry states its window, result and limits.
- A short filled example next to the report skeleton; the kit's PDF opens with what is new in
  the version; the backlog is in step with the text.

## 0.7.0 — 2026-10-22

- **Stage reports in two levels, from the review of the first engagement's stages 1–3** (content
  rated ahead of form): a common skeleton, `templates/stage-report.md` — the result first, scope
  and method, main results by stable id, records (observed, expected, difference, consequence,
  evidence, confidence, limits, next action, done when), decisions and open questions, an
  evidence catalog of `E-` ids, the changes of the version. History, the decision register, the
  full spec and the progress log travel with the report as files at a commit, not reprinted.
- Decision, implementation and verification are separate statuses everywhere; a finding also
  carries severity with its reason, confidence and limits, and a closing criterion
  (`templates/finding.md`).
- One export for every stage report: `tools/report-pdf.sh` with `tools/report.css` (A4
  portrait, 10.5 pt text, 9 pt tables, contents and bookmarks, repeated table headers, footer
  with project, stage, version and page). It fails when an id cited in the sources is not in
  the PDF's text or a font is not embedded. Tested in CI.
- Stage prompts 1–4 ask for this form: one page of result first; commands in the evidence
  catalog, not in the tables; the stage-2 notes written around the resulting contract with
  superseded decisions marked; at stage 3, what a signal count counts, separate fields for
  absent, differs, not verified and observed failure, and separate candidates for different
  fixes.
- `tools/report-pdf.sh` also fails on HTML in the Markdown and names tables wider than five
  columns; the review template gains a checklist for the report's form and the finding's new
  fields, and the signal states read as speclint accepts them.

## 0.6.2 — 2026-10-21

- **From the first stage 3 and its review:** speclint accepts the four signal states the stage-3
  prompt names — `live`, `differs`, `to_build`, `not_verifiable` — and SL002 asks for evidence
  on every state but `to_build`; the first run had to store "differs" as `to_build`.
- New claim rules, from the review of the first gap: absence in every layer read is not a
  location, and a missing header alone does not establish a source; a remedy is stated with
  the case it leaves and the test that shows it; a health signal vouches for its own stream
  only; "not implemented" is not "cannot be computed".
- Stage 3: a window read for an event starts before it, with margin — the first run's windows
  began one minute after the origin errors they were looking for; a layer the agent cannot
  read is `not_verifiable` with an owner question, and a read the owner then allows in the
  system's own console is a dated addition by the person, recorded as status, path template,
  host class and time only.
- How an agent gets single-sign-on credentials its SDK cannot refresh is settled before the
  run (in-process from the CLI, never printed or written).
- **From closing the first stage 2:** a decision that changed a definition is followed into
  every source that stated it, and a source outside the agent's write paths is listed as a
  follow-up for the person; a later decision that changes the basis of an earlier one (a
  window, a unit, a cadence) sends the derived values back to `proposed` with a question.
- Every stage prompt names one scratch directory for temporary files; a temporary file
  elsewhere is a write outside the boundary, logged, and the person checks for stray files
  before confirming. The first run wrote lint output outside its paths twice.

## 0.6.1 — 2026-10-21

- **Stage 3 packaged as a prompt** (`tools/agent/stage-3-gap.md`): signal states with evidence
  from the estate, SLIs computable today as readings, alerts and their inputs, the detection
  matrix for each P1 (proven, scenario written, residual risk), paging readiness shown or not
  shown, telemetry health, questions carried from stage 2, blind spots. Read-only: no fault is
  injected and no test traffic sent to production by the assessment. 0.6.0 named the matrix
  and the gate but had no prompt that asked for them.
- **Stage 5 packaged as a prompt** (`tools/agent/stage-5-maturity.md`): the highest level fully
  shown per dimension, its evidence and confidence, `not_scored` where nobody looked, no overall
  number, clean under `tools/maturity.py`. All six stages now have a prompt, in order.

## 0.6.0 — 2026-10-21

- `scripts/sync-denylist.sh`: the denylist lives in a private file outside the repository; the
  script puts it into the CI secret and the local git-ignored copy, and refuses an empty list.
- **From the review of the first real stage 1:**
  - Stage 1 packaged as a prompt (`tools/agent/stage-1-inventory.md`): one status per object
    (confirmed, differs, not found, not verifiable) whose counts sum to the rows; claims stay
    within what was checked (window and place; evaluation is not detection; absence is not a
    defect; an OK by the missing-data setting says so; totals are not attributions; a difference
    is not a cause); confirmed blind spots go to the risk register at once.
  - Harness measurement: first engagements are pilot measurements; agent time is not compared
    with the estimate's person-days; a re-run sample is "n of n selected checks reproduced",
    not an accuracy estimate.
  - Spec: each function names its `requirement` (SL017, warning) and keeps its `current` state
    with inventory evidence apart from the target; SLOs and alerts carry `status` proposed or
    confirmed, and paging needs both confirmed (SL018). The linter says a clean run is
    structural only. Stage 2 prompt and review checklists follow.
- **From the first run of stages 1 and 2:** inventory rows carry stable ids (`L-01`) that later
  stages cite instead of line numbers; an agent never decides a question addressed to the owner
  and reads only the paths its prompt lists; stage 2 starts by reconciling the sources of
  requirements with the owner; assessment work runs on its own branch from the first stage;
  person hours are recorded per stage, and a change of granularity is counted apart from
  errors. Spec linter: unknown keys are reported (SL019), an engagement's own field is
  prefixed `x_`.
- **From the review of the consolidated journey model:** stage 2 makes success checkable
  (states, empty case, time bound, or an open question for the owner); reconciles ambiguous
  outcomes per operation type with acceptance scenarios, a schedule alone is not a path; maps
  business, monitoring and synthetic layers by exact ids in both directions instead of merging
  them; drafts a legacy → current table for names. Claims: defined in code is not emitted; a
  document's statement carries its date. Review checklist and spec skeleton follow.
- An owner's answer given in a working session is recorded in the client's decision register
  before a document cites it; alert and check lists separate live, historical and planned.
- **From the review of the first stage 2 and of the changes it led to:**
  - Proof that an operation took effect links the change to that operation (its key or its
    own stamp); a state any other writer could have produced leaves it undetermined.
    Composite operations are settled per mutation and get their own acceptance scenario.
  - Count SLIs separate no traffic from telemetry unknown; with no valid window an SLO reads
    "no estimate". A value an agent fills in where a decision left it open is marked as its
    reading; a decision does not stand in for evidence.
  - Claims: a mechanism is described per way it runs; a measurement names its method; a
    passing check shows only what it ran.
  - The review bundle is generated from the committed versions it cites, with their commits
    and the confirmed baseline. Agent permissions enforce network calls as well as paths.
  - Spec linter: a key repeated in one mapping is an error (SL020); YAML would keep the last
    value without a word.
- **From an SRE review of the first run:**
  - Stage 2 adds four steps: each taxonomy row gets a `user_impact` (blocked, degraded,
    unaffected, unknown; checked by SL015); each SLO states its error budget in the SLI's own
    units, with burn-rate alerts in shadow and a budget policy left to the owner; a table of
    how the telemetry itself fails and what that reads as today; the volume per evaluation
    window, with insufficient windows marked.
  - The SLO and alerts skeleton gains the volume and budget columns, burn-rate alerts,
    telemetry health, a paging readiness gate (owner, rota, acknowledgement, escalation,
    runbook, delivery test, fallback — shown, not stated) and a budget policy table.
  - The gap stage records how each P1 alert's detection is shown: proven, scenario written, or
    residual risk with an owner; faults are reproduced on a stage or during implementation,
    never injected in production by the assessment.
  - Acceptance tells spec validated from runtime validated.
- Spec linter: an SLO's subject may be a journey, for one SLO over a journey's functions;
  paging on it needs every function's signals live (SL011).
- **Progress logs:** each agent stage keeps `progress/stage-N.md` in the engagement repository —
  the plan with its step count, each step started and done, each commit with its hash, each
  stop with the reason. The person reads it while the agent runs; the first and last times are
  the agent's elapsed time for the pilot measurement.

## 0.5.0 — 2026-10-21

- Each release also carries the PDF under a fixed name, so
  `releases/latest/download/observability-assessment-kit.pdf` always serves the newest one.
- Release notes come from this file.
- **Staffing: the lead is full time; the engineer and the architect join by scope.** The
  capacity check adds roles in order (lead alone → with an engineer → with an architect) only
  when the days do not fit; offerings and getting started say the same.
- **Statement of work and acceptance record** (`templates/sow.md`, `templates/acceptance.md`):
  one SOW skeleton for the four formats — scope in units, client obligations, change control by
  the increments table, staffing — and a per-deliverable acceptance record with evidence, known
  limitations, go / no-go and hypercare BAU readiness.
- **Privacy checklist** (`templates/privacy-checklist.md`): personal data in telemetry — what to
  ask and check in week one, rules for the instrumentation contract, HAR sanitisation, the
  team's own data, red flags; scores maturity dimension 11.
- **AI-ops boundary checklist** (`templates/ai-ops-boundary.md`): what the client's anomaly
  detection and assisted investigation already decide, where the assessment builds on it, one
  condition pages once; scores dimension 12.
- **Agent stages packaged** (`tools/agent/`): task prompts for harness stages 2, 4 and 6, each
  with boundaries, inputs, an output contract, a self-check and what the person confirms.
  Tool- and model-agnostic.
- **Executive deck skeleton** (`templates/executive-deck.md`): thirteen slides for the read-out,
  each title a claim, maturity as a profile, the decision request last.
- **Intake by tool class:** section G of the intake questionnaire (questions 32–54) for APM
  suites, metrics-and-logs stacks, OpenTelemetry pipelines, cloud provider monitoring and
  estates with several tools.
- **Code scan, after its first use on a real codebase:** hits counted apart in code, tests and
  docs; generated files and files above 512 KB skipped (a scan that took minutes on data
  directories now takes seconds); the retry class matches calls and settings, not the word in
  labels and prose (about 60 % fewer leads, none lost that mattered).

## 0.4.0 — 2026-10-21

- **Tool-agnostic collection.** The kit names classes of capability and of configuration
  object, never a product. The code scan's built-in patterns are vendor-neutral; a tool's own
  signatures come from a file in the engagement repository (`--signatures`). The vendor
  exporters of 0.3.0 are replaced by an estate export by object class that works for any
  monitoring tool (`tools/collect.md`).
- **Maturity: level 1 needs evidence too** — the export or query that came back empty. A level
  nobody looked for is *not scored*. The maturity calculator enforces it (M07).
- **Alert ownership is decided with the client**, by maturity and organisation (service team,
  platform SRE or operations centre); until then the alert stays in shadow. The worked example
  leaves it open.
- **Lead at most half time** in every format. The capacity check now shows the lead over the
  calendar in the full assessment; how that is covered is open.

## 0.3.0 — 2026-10-21

- **Estimation model** (`method/estimation.md`): person-days by role and phase per format,
  increments per journey, service, tool and review round, a capacity check, contingency for our
  own risks. Starting values, to be calibrated after the pilot.
- **Review rounds and checklists** (`templates/review.md`): a round record with verdicts and a
  checklist per deliverable.
- **Pilot protocol** (`practice/pilot.md`): the first assessment led by someone new, with a help
  log, an actuals log and four exit answers.
- **Tools:** spec linter (`tools/speclint.py`, with `observability-spec.yml`), maturity
  calculator (`tools/maturity.py`, with `templates/maturity.yml`), a week-one code scan and two
  vendor exporters (replaced in 0.4.0).
- **Agent harness** (`method/agent-harness.md`): agents draft, people confirm; inputs → model →
  gap → recommendations, the release check, and when the harness may be relied on.
- Worked example: the C1 event the attempt model needs (four events in M2). Error taxonomy:
  class `none` for a condition that looked like an error but the operation took effect.
- Python allowed in the kit; tool tests run in CI and on release.

## 0.2.2 — 2026-10-21

- Offerings: starting scope limits per format; 4 weeks of hypercare, closed at 80 % actionable
  P1 firings; 5 client developer days for the golden-journey proof.
- Worked example: an unclassified code gives an unclassified attempt — bad, but kept apart from
  ambiguous; reconciliation reads the slot hold too and releases orphan holds.
- SLO skeleton: a caller defect pages when it blocks customers at P1 scale; routing by impact,
  not by class.
- Build: other editions can hold the kit as a submodule and build with `--config`.

## 0.2.1 — 2026-10-21

0.2.0 was reviewed as two different local builds and never released; 0.2.1 carries it.

- **Getting started**, a **fictional worked example** from request to acceptance, and
  **skeletons for the nine spec-set documents**. The engagement knowledge base is optional.
  "Scrappy" assessment renamed *focused*.
- Error taxonomy: *ambiguous* means the business outcome is unknown and needs reconciliation;
  an overloaded code is a gap, classified by context.
- SLO rules: valid and good decided per SLI; one bad predicate per SLI.
- Maturity model: capability, not technology; the score is the highest fully evidenced level;
  partial, not scored, N/A and confidence defined; no overall average; dimension 12 optional.
- Offerings: the golden-journey proof needs stage access and a client developer; the end of
  paid hypercare is not BAU acceptance.
- CI: pull requests from forks run the public checks; the PDF is checked on every build.

## 0.1.0 — 2026-10-21

First public release: method, maturity model, lessons, templates and the practice guide; PDF
build, guardrails and release pipeline.
