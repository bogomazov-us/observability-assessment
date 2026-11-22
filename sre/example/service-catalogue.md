# Service catalogue — Larkfield Grocer

**Fictional.** `sre/service-catalogue.md` of the [SRE worked example](worked-example.md), in
the [template](../templates/service-catalogue.md)'s format, after stage 2: the tiers are the
owners' (D-12). Stage 1 drafted the rows; the evidence ids are its catalog in `sre/inventory.md`.

| ID | Service | Tier | Owner | Upstream | Downstream | Deploy target | Source | Status |
|---|---|---|---|---|---|---|---|---|
| S-01 | web front end | 1, D-12 | Web team | S-02, S-04 | customers | production cluster, primary region | registry export E-101; deploy history E-103 | confirmed |
| S-02 | `checkout` | 1, D-12 | Checkout team | S-03, S-04, S-05, S-06 | S-01 | production cluster, primary region | registry export E-101; infrastructure as code E-102 | confirmed |
| S-03 | `payments`, with the payments ledger | 1, D-12 | Payments team | payment provider; its ledger database | S-02 | production cluster, primary region; ledger in the managed database service | registry export E-101; infrastructure as code E-102 | confirmed |
| S-04 | `slots` | 1, D-12 | Delivery team | S-05 | S-01, S-02 | production cluster, primary region | registry export E-101 | confirmed |
| S-05 | orders database | 1, D-12 | Platform team | — | S-02, S-04 | managed database service, primary region, one replica in a second zone | infrastructure as code E-102; backup history E-104 | confirmed |
| S-06 | `promo-rules` | 2, D-12 | *unknown* (Q-09) | — | S-02 | production cluster, primary region | deploy history E-103; not in the registry | differs |
| S-07 | `search` | 2, D-12 | Catalogue team | — | S-01 | production cluster, primary region | registry export E-101 | confirmed |

**Checks before the stage is handed over**
- Every tier-1 service has an owner and a paging route: yes for S-01 to S-05 (E-107).
- Each dependency of a tier-1 service has a tier: `checkout` calls `promo-rules`, a tier-2
  service with no owner. D-12 accepts tier 2 on the condition that checkout goes on without
  promotions when `promo-rules` fails; that fallback is not shown yet (F-013).
- `promo-rules` is in the deploy history but not in the client's registry: status differs.
