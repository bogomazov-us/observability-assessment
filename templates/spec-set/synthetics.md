# Skeleton — `synthetics.md`

What runs continuously, from outside, whether or not customers are active.

---

# Synthetics

| Monitor | Journey / functions | Type | Frequency | Locations | Test user | Pages after | State |
|---|---|---|---|---|---|---|---|
| <sign-in and search> | <J1.1, J1.2> | browser / API | <5 min> | <2 regions> | <dedicated, flagged as test traffic> | <2 consecutive failures> | live / to build |

Test users: <who owns them, how credentials are stored (secret store, never in the script),
how their traffic is excluded from SLIs>.
