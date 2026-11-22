# Stage 5 — SRE maturity

*Task prompt. Assemble it with `tools/agent/prompt.sh --assessment sre 5`, which appends the
rule files it names, and paste the result as is; replace the bracketed values.*

---

You draft the maturity profile of an SRE assessment from confirmed findings and the confirmed
gap. You draft; a person sets each level and its confidence.

## Rules

The rule files in [`rules/`](../../tools/agent/rules/) apply to this stage:
[boundaries](../../tools/agent/rules/boundaries.md), [evidence](../../tools/agent/rules/evidence.md),
[claims](../../tools/agent/rules/claims.md),
[owner questions](../../tools/agent/rules/owner-questions.md) and the
[progress log](../../tools/agent/rules/progress-log.md), with N = 5. The boundaries below are
this stage's own and add to the common ones.

## Boundaries

- Read-only on every client system. You score from evidence already gathered in stages 1–4; a
  new read query is allowed only to look for the evidence of a level, and is cited like any
  other.
- Every level names its evidence, per [maturity-model.md](../maturity-model.md). Level 1 names
  the search that came back empty. A level nobody looked for is `not_scored`, never 1.
- No overall number: no average, no total, no single score.
- Every level is a proposal until the person sets it.
- N/A needs the client's agreement (`agreed_by`) — propose it, do not set it.

## Inputs

| Input | Where |
|---|---|
| Findings with their verdicts; those still without one, marked | `findings/` |
| Format (focused or full); support mode as the owner stated it: hours, time zone, days, who is responsible | [intake answer or decision register] |
| Gap, confirmed: per service and dimension | `sre/stage-3-gap.md` |
| Targets and agreed thresholds, inventory, baseline | `sre/targets/`, `sre/inventory.md`, `sre/baseline.md` |
| Maturity model and skeleton | `sre/maturity-model.md`, `templates/maturity.yml` |
| Provisional baseline, if written | `sre/maturity.yml` |
| Combined format: the observability profile | `maturity.yml` |

## Method

1. Copy `templates/maturity.yml` with `model: sre` and the ten SRE dimensions, or start from
   the provisional baseline and re-score every level in it; fill the scope: the tier-1
   services and the journeys they serve.
2. **Focused format.** Dimensions 1, 2, 4, 6 and 9 are scored. Every other one is
   `not_scored` with the reason "not in scope (focused format)": not the same as no evidence.
3. For each dimension in scope, read its levels in the model and find the highest level fully
   shown by evidence: a confirmed finding, an `S-`, `T-` or `B-` row, a gap row, an
   export. A level shown for part of the tier-1 services is `partial`, with the
   coverage written out.
4. Above level 2, at least one piece of tool evidence: an export, a query, a trace, code or
   configuration. A slide or an interview alone stops at level 2.
5. Give each score a confidence (high, medium, low) and say why; low confidence above level 2
   is not allowed.
6. A dimension in scope without evidence either way is `not_scored`, with the reason and what
   would score it.
7. Mark the dimensions that block the next step, and what would move the profile fastest, as
   proposals for the person.
8. **Before the verdicts.** A level that rests on a finding still without its verdict is
   *provisional*, and says which finding. When the verdict comes, re-read the level: it may
   change its scope, its confidence or the level itself. Record the change as a dated entry;
   do not overwrite the earlier reading.
9. **Thresholds and support mode.** Read dimensions 5 and 10 against the limits agreed in
   stage 2, and dimension 5 against the support mode the owner agreed: for a service used in
   working hours only, no off-hours on-call is the agreed mode, not a defect. Unanswered:
   "not confirmed by the evidence", never "no on-call".
10. **Recovery in the records.** Dimension 9 above level 2 needs a restore test record with its
    date and measured times: backup history shows backups exist, not that they restore.
11. **Combined format.** Apply the overlap table of
    [sre/maturity-model.md](../maturity-model.md#overlaps-in-the-combined-format):
    - dimension 2: `not_scored` with `refers_to: observability/6`; the notes carry what SRE
      adds: the error-budget policy and the decisions it changed;
    - dimension 3: `not_scored` with `refers_to: observability/7`;
    - dimension 4: scored here; propose `refers_to: sre/4` for observability dimension 8, which
      you do not edit;
    - dimension 6: scored in both, each from its own angle.

    Then run `python3 tools/maturity.py --pair maturity.yml sre/maturity.yml`; fix each P01 or
    P02 line in your file, or hand it to the person.

## Output

The stage report, `sre/stage-5-notes.md`, follows
[`stage-report.md`](../../templates/stage-report.md) and its chain for this stage; the progress
log, the decision register and the target model travel with it as files at a stated commit,
cited, not reprinted.

1. `sre/maturity.yml` with `model: sre`, clean under
   `python3 tools/maturity.py --check sre/maturity.yml`.
2. `sre/stage-5-notes.md`: per dimension, the level, the evidence that shows it, the evidence
   that stops the next level, and the confidence; the dimensions not in scope, apart from
   those not scored; the profile printed by `tools/maturity.py`; in the combined format, the
   `--pair` output.

## Self-check before handing over

- [ ] `python3 tools/maturity.py --check sre/maturity.yml` exits 0; the file says `model: sre`.
- [ ] Every level names its evidence; every level 1 names the empty search.
- [ ] No dimension is scored without having been looked for; those are `not_scored`.
- [ ] Focused format: every dimension outside 1, 2, 4, 6, 9 says "not in scope".
- [ ] No overall number anywhere.
- [ ] Every provisional level names the finding it waits on; every re-read is a dated entry.
- [ ] Dimension 5 is read against the support mode the owner stated, or marked not confirmed.
- [ ] In the combined format, `--pair` exits 0, or each line it prints is handed over.
- [ ] The check at the end of each rule file holds.

## What the person confirms

By the week the [calendar](../README.md#calendar) gives: each level and its confidence, against
the cited evidence; each N/A with the client; which dimensions block the next step; each
provisional level when its findings have their verdicts; in the combined format, both profiles,
clean under `--pair`. Only the confirmed profile goes into stage 6.
