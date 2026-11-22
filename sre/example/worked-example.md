# Worked example — Larkfield Grocer, SRE

**Fictional.** Larkfield Grocer is the company of the
[observability worked example](../../example/worked-example.md); its systems, people and
numbers are invented. After the observability read-out, Larkfield added an SRE assessment,
focused format, to the same engagement. The example follows it through every artefact:
request → exports and baseline → catalogue → targets → gaps → findings → profile → roadmap.
Calendar: [SRE calendar](../README.md#calendar). Ids, roles and statuses:
[records.md](../../method/records.md).

| File | Engagement path | Holds |
|---|---|---|
| [exports.sh](exports.sh) | `sre/exports/` | Writes the synthetic incident, deploy and page exports |
| [baseline.md](baseline.md) | `sre/baseline.md` | `B-` rows, as `tools/baseline.py` prints them on those exports |
| [service-catalogue.md](service-catalogue.md) | `sre/service-catalogue.md` | `S-` rows with the agreed tiers |
| [reliability-targets.md](reliability-targets.md) | `sre/targets/reliability-targets.md` | `T-` rows with their decisions |
| [maturity.yml](maturity.yml) | `sre/maturity.yml` | The SRE profile (`model: sre`), checked by `tools/maturity.py` |

## The request

The head of engineering: "In March the orders database failed over by hand and checkout was
down for nearly four hours. Could we restore if we had to? What do we fix first?"

In scope (D-10): the checkout journey and the services it cannot complete without; one
delivery pipeline; production, read-only; one review round. Kick-off 2027-06-07, read-out
2027-06-25.

## One engagement, two types

`init-engagement.sh --assessment sre` added the SRE type to Larkfield's working folder, so the
combined format's rules apply:

- **Shared registers, one sequence each.** The SRE rows continue after the observability ones
  (to D-09, Q-04, R-02, O-11, F-009; REC-01 to REC-04, W-01 to W-12, V-01, V-02; M-1 to M-4).
  The observability rows are not repeated here.
- **Overlaps scored once.** SLOs are scored in observability dimension 6 (level 1), so SRE
  dimension 2 is not scored and refers to it:

  ```
  - number: 2
    status: not_scored
    reason: "SLOs are scored in the observability profile; SRE adds the error-budget policy: none (G-06)"
    refers_to: observability/6
  ```

  The SRE profile adds only the error-budget policy (G-06). Alerts (SRE 3) are out of scope in
  the focused format; incidents are scored here in SRE 4, and the SRE stage 5 notes propose
  `refers_to: sre/4` for observability dimension 8, which they do not edit. Releases are
  scored in both, each from its own angle. The check, clean:
  `tools/maturity.py --pair example/maturity.yml sre/example/maturity.yml`.
- **No referral to the other type.** The observability assessment is already part of the
  engagement.

## Decision register (extract)

| ID | Decision | Decided by | Date | Evidence | Status |
|---|---|---|---|---|---|
| D-10 | SRE scope as above; the observability profile of the read-out stands, no observability milestone demonstrated yet | Sponsor (head of engineering) | 2027-06-07 | Kick-off note | accepted |
| D-11 | SRE stage 1 confirmed | Lead | 2027-06-10 | `sre/inventory.md` at `c71e0a4` | accepted |
| D-12 | Tiers: S-01 to S-05 tier 1; S-06 and S-07 tier 2, on condition that checkout goes on without promotions when `promo-rules` fails (Q-05) | Head of engineering, with the service owners | 2027-06-14 | Targets review; written answer | accepted |
| D-13 | RTO 1 hour and RPO 5 minutes for the orders database and the payments ledger (Q-06) | Platform and payments technical owners | 2027-06-14 | Written answers | accepted |
| D-14 | Tier-1 rollout: canary to 10% with an automatic halt; rollback within 15 minutes (Q-07) | Release technical owner | 2027-06-15 | Written answer | accepted |
| D-15 | SRE stage 2 confirmed | Lead | 2027-06-15 | `sre/target-model.md` at `9d04b1e` | accepted |
| D-16 | SRE stage 3 confirmed | Lead | 2027-06-16 | `sre/stage-3-gap.md` at `e27a6c3` | accepted |
| D-17 | Verdicts: F-010, F-011, F-012 confirmed; F-013 waits for its owner (Q-09) | Platform, release and checkout technical owners | 2027-06-22 | Verdict batch; re-checks E-401 to E-403 | accepted |

Open: Q-08, the error-budget policy (head of e-commerce and head of engineering together);
Q-09, who owns `promo-rules`.

## Facts ledger (extract)

| # | Fact | Status | Source | Date |
|---|---|---|---|---|
| O-12 | "Restores are tested every quarter" | refuted by O-13 | Interview, platform lead | 2027-06-08 |
| O-13 | The last restore on record is of the orders database, 2026-10-14; none of the payments ledger | confirmed | Restore records, E-105 | 2027-06-09 |
| O-14 | The orders database fails over by hand, from a runbook last changed in 2025 | confirmed | Infrastructure as code E-102; runbook history | 2027-06-09 |
| O-15 | `promo-rules` is deployed from the checkout team's pipeline | assumption | Deploy history E-103 | 2027-06-09 |

## Risk register (extract)

| ID | Risk | Source | Owner | Status | Date | Decision |
|---|---|---|---|---|---|---|
| R-03 | A lost tier-1 data store stays down beyond its RTO: no restore tested, failover by hand | Blind spot, SRE stage 1, L-09 | Platform technical owner, *proposed* | open | 2027-06-10 | |
| R-04 | A failure of `promo-rules`, which nobody owns, stops checkout | Blind spot, SRE stage 1, L-14 | Head of engineering, *proposed* | open | 2027-06-10 | |

## Exports and baseline

The client sent three exports from the tracker, the pipeline and the paging tool. The
guardrails track no `.csv` files, so the example keeps them as a generator,
[exports.sh](exports.sh), that writes them where the engagement keeps them. The baseline is
the tool's output on them, unchanged, plus the numbers counted from other exports:
[baseline.md](baseline.md). The ones this example uses:

| ID | Number | Value |
|---|---|---|
| B-15 | Time to recover, severity critical, p90 | 3 h 40 min (the March failover) |
| B-20 | Recurrence share | 46.2% (6 of 13) |
| B-24 | Change failure rate | 14.3% (6 of 42) |
| B-25, B-26 | Failed deployment recovery time, median and p90 | 50 min; 3 h 05 min |
| B-32 | Restore tested | 0% (0 of 2) |
| B-35 | Action-item closure | 36.8% (7 of 19) |

## Catalogue and targets

Seven services, five tier 1 ([service-catalogue.md](service-catalogue.md)): web front end,
`checkout`, `payments` with its ledger, `slots`, the orders database. `promo-rules`
was found in the deploy history, not in the registry: status differs, tier 2 by D-12.

Targets ([reliability-targets.md](reliability-targets.md)): RTO and RPO per tier-1 data store
(T-05 to T-08, D-13) and the rollout policy (T-09, D-14) are confirmed. The SLO is the
observability spec's `SLO-checkout`, cited by T-04 and still proposed. The default rows stay
default: their dimensions are out of scope.

## Gaps (extract of `sre/stage-3-gap.md`)

| ID | Service | Dimension | Target | Current | Evidence | Status |
|---|---|---|---|---|---|---|
| G-01 | S-05 | 9 Backup and disaster recovery | T-05 1 hour, T-06 5 minutes | Backups twice a day and a log archive; last restore 2026-10-14; failover by hand, 3 h 40 min on 2027-03-13 | B-32, B-33, B-15; E-301 | partial |
| G-02 | S-03 | 9 Backup and disaster recovery | T-07 1 hour, T-08 5 minutes | Backups run; no restore on record | B-32, B-34 | absent |
| G-03 | dimension-wide | 6 Change safety | T-09 | One-step rolling deploy, no halt; rollback is a hand redeploy of the previous version | B-24 to B-26; E-108 | absent |
| G-04 | dimension-wide | 4 Incidents and learning | Target model: level 4 | Severity levels, roles and postmortems in place; overdue action items not escalated | B-20, B-35; E-106 | partial |
| G-05 | S-02 | 1 Service catalogue and criticality | D-12: checkout goes on without promotions | No timeout or fallback on the `promo-rules` call found | L-14; E-302 | absent |
| G-06 | dimension-wide | 2 SLOs and error budgets | Error-budget policy (Q-08) | None; SLO definition and measurement: see observability 6 | E-303 | absent |

Absent 4, partial 2, implemented 0: 6 rows.

## Findings

Each finding is a file `findings/F-NNN.md` in [finding.md](../../templates/finding.md)'s
format, in the engagement's one `F-` sequence. Verdicts came from the batch sent at the
findings preview (D-17).

**F-010 · The orders database has no tested way back within its RTO.**

| Status | Date | Source | Evidence level |
|---|---|---|---|
| confirmed | 2027-06-22 | Restore records; incident export; re-check E-401 | tenant |

**Severity:** P1: a tier-1 data store can stay down beyond its RTO with no tested way back. ·
**Model:** sre, dimension 9 · **Decision:** proposed · **Implementation:** partial ·
**Verification:** untested.

**What we see.** Backups run: 180 of 184 in 2027-03-01 → 05-31 (B-33). The last restore on
record is dated 2026-10-14 (O-13, E-105). On 2027-03-13 the primary failed and the failover by
hand took 3 h 40 min (incident 107 in the export; B-15), against an RTO of 1 hour (T-05). The
re-check read the same records (E-401).

**Confidence and limits.** High for the records read. Whether a restore today would meet
T-05 and T-06 is not shown: none was run in the window.

**Why it matters.** A second loss of the primary would again stop checkout for hours, and
orders written since the last good copy could be lost.

**What follows.** A timed restore and a failover drill on stage, run by the client's people;
the failover runbook rewritten. Platform technical owner, M-5. Moves SRE dimension 9 from 2
to 3.

**Closing criterion.** A restore of the orders database on stage, recorded with its date,
within T-05 and T-06.

**Links.** G-01, G-02; R-03.

**F-011 · A failed deploy is rolled back by hand, and one took three hours.** confirmed,
2027-06-22, tenant · P2: a safety mechanism is missing for tier 1 · Model: sre, dimension 6 ·
proposed, absent, untested. *What we see:* 6 of 42 deploys failed (B-24); recovery took a median
50 min, p90 3 h 05 min (B-25, B-26), against 15 minutes in T-09; no canary or halt in the
pipeline configuration (E-108, re-checked E-402). *Limits:* rollback on stage not tried.
*Why it matters:* a bad change reaches every customer at once and stays. *What follows:*
rollback as a tested pipeline step, then the canary (release technical owner, M-6 and M-7).
*Closing criterion:* a rollback on stage within 15 minutes, recorded. *Links:* G-03.

**F-012 · Known causes recur while their action items stay open.** confirmed, 2027-06-22,
tenant · P2: the fix that would stop a known cause is overdue on tier 1 · Model: sre,
dimension 4 · proposed, absent, untested. *What we see:* 6 of 13 incidents with a cause repeat an
earlier one, deploys most often (B-20); 7 of 19 action items closed by their due date (B-35,
E-106, re-checked E-403). *Limits:* whether the open items would have prevented each
recurrence is not shown. *Why it matters:* the same outage comes back. *What follows:*
overdue items escalated, recurrence reviewed monthly (checkout tech lead, M-8); SRE
dimension 4. *Closing criterion:* the first monthly review held with its record. *Links:*
G-04; F-011.

**F-013 · Checkout depends on a service nobody owns.** assumption, 2027-06-17, agent · P2,
*provisional*: a condition for keeping a target (owner, on-call cover) is missing · Model:
sre, dimension 1 · proposed, absent, untested. *What we see:* `checkout` calls `promo-rules`
with no timeout or fallback found (E-302); `promo-rules` has no owner or paging route (B-36);
incident 114 names it as the cause. *Limits:* its owner may exist outside the registry (O-15,
Q-09). *What follows:* V-03 before any card. *Links:* G-05; R-04.

## Profile

As a file: [maturity.yml](maturity.yml), checked by `tools/maturity.py`. Dimensions 3, 5, 7,
8 and 10 are not in scope (focused format).

| Dimension | Level | Coverage | Evidence | Confidence |
|---|---|---|---|---|
| 1 Service catalogue and criticality | 2 (partial 3) | owners and paging routes for 6 of 7 services; tiers first agreed in this assessment | registry export; infrastructure as code | high |
| 2 SLOs and error budgets | not scored | see observability 6; no error-budget policy | — | — |
| 4 Incidents and learning | 3 | severity levels, roles, postmortems with dated action items | incident export; postmortems and tickets | high |
| 6 Change safety | 2 | automated deploy; rollback by hand, no test on record | deploy export; pipeline configuration | high |
| 9 Backup and disaster recovery | 2 | backups monitored; no restore in the window | backup job history; restore records | high |

Block the next step: 6 and 9.

## Roadmap

Shape A of [roadmap.md](../../templates/roadmap.md), continuing the engagement's roadmap after
M-4. Draft; no dates. Sizes: S 1–3, M 4–8, L 9–15 engineer-days, an assumption. Limit for every
milestone: drills and restores are run by the client's people, on stage.

| Milestone | Items, and the `REC-` they deliver | Exit result (checkable) | Effort, engineer-days |
|---|---|---|---|
| M-5 · Recovery proven for tier-1 data stores | W-13, W-14, W-15, W-16 · REC-05 | Restores of the orders database and the payments ledger on stage within T-05 to T-08, and a failover drill, each recorded with its date | 6–10 |
| M-6 · Rollback as a pipeline step | W-17 · none | A rollback on stage within 15 minutes, recorded | 2–4 |
| M-7 · Canary with automatic halt | W-18, W-19 · REC-06 | An injected bad canary halted on stage; configuration read for each tier-1 service | 8–14 |
| M-8 · Learning loop | W-20, W-21 · REC-07 | Overdue items escalated; the first monthly recurrence review recorded | 2–4 |

| Milestone | Accountable | Depends on | Moves on the profile | Architecture delta |
|---|---|---|---|---|
| M-5 | Platform technical owner | none | SRE dimension 9: no restore in the window | Failover runbook; restore age alert |
| M-6 | Release technical owner | none | SRE dimension 6: rollback untested | Rollback step in the pipeline |
| M-7 | Release technical owner | M-6 | SRE dimension 6: no automatic halt | Canary stage and halt rule for tier 1 |
| M-8 | Checkout tech lead | none | SRE dimension 4: overdue items | Escalation rule in the tracker |

V-03 runs beside them: the owner of `promo-rules` found (Q-09) and the checkout call read for a
timeout and fallback. A confirmed F-013 adds a card and a milestone after M-5.

## The read-out

"Your backups run, but nothing shows you could restore the orders database within the hour
you need; the one real failover took nearly four hours (F-010). A bad deploy reaches every
customer and is rolled back by hand (F-011), and known causes come back (F-012). Restores and
a rollback step come first: about 8–14 engineer-days. Decision needed: start M-5 and M-6, and
the error-budget policy (Q-08)."
