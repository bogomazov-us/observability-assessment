# Service catalogue

SRE stage 1 copies this to `sre/service-catalogue.md` and fills a row per service in scope;
stage 2 sets the tiers. Ids, statuses and who sets them are in
[records.md](../../method/records.md). The agent's rows enter as found; the lead confirms them
with the stage, and a tier counts only once its owner confirmed it.

| Column | Holds |
|---|---|
| ID | `S-01`, `S-02` …; never renumbered or reused |
| Service | The client's name for it, as deployed; a worker, scheduled task, tunnel or agent in scope is a row too, its kind named |
| Tier | 1, 2 or 3; tier-1 serves a critical journey. *proposed* until its owner confirms, with the `D-` row |
| Owner | The team that runs it and answers its pages; *unknown* is an owner question (`Q-`) |
| Upstream | Services and external dependencies it calls (`S-` ids where catalogued) |
| Downstream | Services that call it (`S-` ids) |
| Deploy target | Where it runs: cluster, account and region, or host group |
| Source | Where the row comes from: registry or CMDB export, infrastructure as code, deploy history, interview (`E-` or `O-` id) |
| Status | confirmed · differs · not found · not verifiable |

| ID | Service | Tier | Owner | Upstream | Downstream | Deploy target | Source | Status |
|---|---|---|---|---|---|---|---|---|
| [S-01] | [service] | [1, proposed] | [team] | [S-02, payment provider] | [S-03] | [cluster, region] | [registry export, E-1NN] | [status] |

**Checks before the stage is handed over**
- Every tier-1 service has an owner and a paging route.
- Each dependency of a tier-1 service is in the catalogue with a tier; a tier-1 service on an
  untiered or lower-tier dependency is a gap, or is accepted in a `D-` row.
- A service seen in deploys or infrastructure but missing from the client's list is a row with
  status differs, not a silent addition.

## In the report

Guidance for the stage notes, not a section of this file. The full table is a record: this file
goes to the evidence bundle as it is (manifest line `evidence sre/service-catalogue.md`), where
the build sets it landscape. The stage notes show it narrow, at most five short columns, so the
report keeps running text:

| ID | Service | Tier | Owner | Status |
|---|---|---|---|---|
| [S-01] | [service] | [1, D-NN] | [team] | [status] |

Dependencies, deploy target and source are read in the bundle.
