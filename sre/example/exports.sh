#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Synthetic exports of the SRE worked example (sre/example/worked-example.md), written into
# DIR/sre/exports/ as the engagement keeps them. The guardrails track no .csv files, so the data
# lives here. Fictional company, no real data.   sre/example/exports.sh DIR
# The baseline (sre/example/baseline.md), from DIR:
#   tools/baseline.py sre/exports/incidents-2027-06-08.csv --map severity=priority \
#     --deploys sre/exports/deploys-2027-06-08.csv --pages sre/exports/pages-2027-06-08.csv
set -euo pipefail
mkdir -p "$1/sre/exports"
cd "$1/sre/exports"
# Incident tracker: six months; severity is the tracker's "priority"; class: outage, or data for
# a data-correctness defect; no titles or people.
cat > incidents-2027-06-08.csv <<'CSV'
id,service,priority,started,detected,recovered,cause,class
101,checkout,critical,2026-12-05T18:10:00Z,2026-12-05T18:14:00Z,2026-12-05T18:55:00Z,deploy,outage
102,slots,major,2026-12-19T09:00:00Z,2026-12-19T09:35:00Z,2026-12-19T11:10:00Z,slot-capacity,outage
103,payments,major,2027-01-09T19:20:00Z,2027-01-09T19:24:00Z,2027-01-09T20:05:00Z,provider-timeout,outage
104,checkout,minor,2027-01-23T11:00:00Z,2027-01-23T11:50:00Z,2027-01-23T13:30:00Z,config,data
105,web,critical,2027-02-06T17:30:00Z,2027-02-06T17:33:00Z,2027-02-06T18:10:00Z,deploy,outage
106,payments,major,2027-02-20T18:00:00Z,2027-02-20T18:40:00Z,2027-02-20T19:30:00Z,provider-timeout,outage
107,orders-db,critical,2027-03-13T02:10:00Z,2027-03-13T02:22:00Z,2027-03-13T05:50:00Z,db-failover,outage
108,checkout,major,2027-03-27T10:00:00Z,2027-03-27T10:06:00Z,2027-03-27T10:50:00Z,deploy,outage
109,slots,minor,2027-04-10T08:00:00Z,2027-04-10T08:30:00Z,2027-04-10T09:40:00Z,cert-expiry,outage
110,checkout,critical,2027-04-24T19:00:00Z,2027-04-24T19:05:00Z,2027-04-24T19:58:00Z,Deploy,outage
111,web,minor,2027-05-08T14:00:00Z,2027-05-08T14:20:00Z,2027-05-08T15:00:00Z,,outage
112,orders-db,major,2027-05-15T03:00:00Z,2027-05-15T03:25:00Z,2027-05-15T04:30:00Z,db-failover,outage
113,payments,minor,2027-05-22T12:00:00Z,,2027-05-22T14:00:00Z,provider-timeout,outage
114,checkout,major,2027-05-29T18:30:00Z,2027-05-29T18:36:00Z,2027-05-29T19:40:00Z,promo-rules,data
CSV
# Delivery pipeline: production deploys of the tier-1 and tier-2 services, three months.
cat > deploys-2027-06-08.csv <<'CSV'
deployed,committed,failed,restored,rework,service
2027-03-01T11:45:00Z,2027-03-01T08:45:00Z,no,,no,web
2027-03-03T15:00:00Z,2027-02-28T17:00:00Z,no,,no,checkout
2027-03-04T14:45:00Z,2027-03-04T09:45:00Z,no,,no,checkout
2027-03-08T14:00:00Z,2027-03-04T14:00:00Z,yes,2027-03-08T14:20:00Z,no,web
2027-03-10T15:00:00Z,2027-03-06T15:00:00Z,no,,yes,promo-rules
2027-03-11T11:00:00Z,2027-03-08T13:00:00Z,no,,no,checkout
2027-03-15T11:00:00Z,2027-03-11T11:00:00Z,no,,no,payments
2027-03-16T16:15:00Z,2027-03-16T11:15:00Z,no,,no,promo-rules
2027-03-17T11:30:00Z,2027-03-17T06:30:00Z,no,,no,promo-rules
2027-03-18T15:00:00Z,2027-03-14T15:00:00Z,yes,2027-03-18T15:35:00Z,no,checkout
2027-03-22T15:45:00Z,2027-03-21T09:45:00Z,no,,no,slots
2027-03-23T14:30:00Z,2027-03-22T12:30:00Z,no,,no,checkout
2027-03-25T11:00:00Z,2027-03-21T11:00:00Z,no,,no,payments
2027-03-29T13:45:00Z,2027-03-28T11:45:00Z,no,,no,promo-rules
2027-03-31T14:15:00Z,2027-03-30T08:15:00Z,no,,no,checkout
2027-04-05T16:00:00Z,2027-04-02T18:00:00Z,yes,2027-04-05T16:50:00Z,no,promo-rules
2027-04-08T13:45:00Z,2027-04-04T13:45:00Z,no,,yes,slots
2027-04-12T10:30:00Z,2027-04-10T08:30:00Z,no,,no,web
2027-04-13T16:30:00Z,2027-04-09T16:30:00Z,no,,no,slots
2027-04-14T14:30:00Z,2027-04-14T11:30:00Z,no,,no,slots
2027-04-15T15:00:00Z,2027-04-13T13:00:00Z,no,,no,web
2027-04-19T13:15:00Z,2027-04-18T17:15:00Z,no,,no,slots
2027-04-20T14:00:00Z,2027-04-20T06:00:00Z,yes,2027-04-20T14:55:00Z,no,slots
2027-04-21T13:15:00Z,2027-04-19T17:15:00Z,no,,yes,promo-rules
2027-04-22T14:30:00Z,2027-04-20T18:30:00Z,no,,no,checkout
2027-04-26T11:15:00Z,2027-04-25T15:15:00Z,no,,no,checkout
2027-04-27T15:15:00Z,2027-04-26T13:15:00Z,no,,no,payments
2027-04-28T14:30:00Z,2027-04-24T14:30:00Z,no,,no,promo-rules
2027-04-29T11:00:00Z,2027-04-27T09:00:00Z,yes,2027-04-29T12:20:00Z,no,promo-rules
2027-05-03T14:45:00Z,2027-05-03T09:45:00Z,no,,no,slots
2027-05-04T10:15:00Z,2027-05-04T05:15:00Z,no,,no,checkout
2027-05-05T10:30:00Z,2027-05-01T10:30:00Z,no,,no,web
2027-05-06T15:15:00Z,2027-05-03T17:15:00Z,no,,no,web
2027-05-11T10:15:00Z,2027-05-07T10:15:00Z,yes,2027-05-11T13:20:00Z,no,slots
2027-05-12T13:30:00Z,2027-05-08T13:30:00Z,no,,yes,payments
2027-05-13T10:45:00Z,2027-05-11T08:45:00Z,no,,no,slots
2027-05-17T10:15:00Z,2027-05-17T05:15:00Z,no,,no,payments
2027-05-18T14:15:00Z,2027-05-15T16:15:00Z,no,,no,web
2027-05-19T15:30:00Z,2027-05-19T07:30:00Z,no,,no,promo-rules
2027-05-25T16:00:00Z,2027-05-24T14:00:00Z,no,,no,promo-rules
2027-05-26T11:30:00Z,2027-05-25T15:30:00Z,no,,no,promo-rules
2027-05-27T15:30:00Z,2027-05-26T19:30:00Z,no,,no,promo-rules
CSV
# Paging tool: one rotation for every service, three months; responders left out.
cat > pages-2027-06-08.csv <<'CSV'
paged,service
2027-03-01T21:12:00Z,checkout
2027-03-03T07:44:00Z,web
2027-03-05T16:49:00Z,web
2027-03-06T00:59:00Z,slots
2027-03-08T16:07:00Z,checkout
2027-03-09T06:36:00Z,payments
2027-03-10T11:45:00Z,web
2027-03-10T20:39:00Z,checkout
2027-03-11T11:55:00Z,payments
2027-03-12T02:44:00Z,slots
2027-03-13T02:12:00Z,checkout
2027-03-13T02:20:00Z,payments
2027-03-13T02:31:00Z,slots
2027-03-13T02:48:00Z,payments
2027-03-13T03:10:00Z,slots
2027-03-13T03:35:00Z,payments
2027-03-13T04:20:00Z,web
2027-03-16T06:42:00Z,payments
2027-03-17T06:58:00Z,checkout
2027-03-18T21:18:00Z,web
2027-03-19T00:03:00Z,web
2027-03-20T22:17:00Z,payments
2027-03-21T21:57:00Z,payments
2027-03-23T04:05:00Z,payments
2027-03-23T13:15:00Z,web
2027-03-24T06:48:00Z,orders-db
2027-03-24T16:19:00Z,web
2027-03-26T21:42:00Z,slots
2027-03-27T02:57:00Z,web
2027-03-28T13:30:00Z,payments
2027-03-28T15:48:00Z,slots
2027-03-29T02:53:00Z,slots
2027-03-30T05:25:00Z,checkout
2027-03-30T05:48:00Z,slots
2027-04-03T15:53:00Z,checkout
2027-04-04T04:59:00Z,slots
2027-04-04T20:52:00Z,orders-db
2027-04-05T16:11:00Z,web
2027-04-06T05:19:00Z,web
2027-04-06T11:57:00Z,checkout
2027-04-07T18:42:00Z,web
2027-04-11T03:30:00Z,slots
2027-04-11T22:10:00Z,orders-db
2027-04-12T04:45:00Z,orders-db
2027-04-13T06:38:00Z,slots
2027-04-16T07:15:00Z,orders-db
2027-04-17T17:06:00Z,checkout
2027-04-19T11:07:00Z,checkout
2027-04-20T18:34:00Z,payments
2027-04-21T04:28:00Z,checkout
2027-04-23T12:04:00Z,checkout
2027-04-23T15:38:00Z,slots
2027-04-24T17:38:00Z,slots
2027-04-24T19:54:00Z,checkout
2027-04-25T17:07:00Z,payments
2027-04-27T05:10:00Z,slots
2027-04-28T17:25:00Z,payments
2027-04-30T06:15:00Z,web
2027-05-01T00:08:00Z,slots
2027-05-05T21:07:00Z,web
2027-05-06T04:06:00Z,payments
2027-05-06T18:59:00Z,orders-db
2027-05-08T23:17:00Z,orders-db
2027-05-09T18:06:00Z,orders-db
2027-05-10T16:28:00Z,web
2027-05-12T01:56:00Z,slots
2027-05-15T01:26:00Z,checkout
2027-05-17T15:26:00Z,slots
2027-05-18T00:57:00Z,checkout
2027-05-20T11:06:00Z,payments
2027-05-21T17:15:00Z,web
2027-05-22T17:28:00Z,checkout
2027-05-24T09:27:00Z,slots
2027-05-24T15:26:00Z,checkout
2027-05-25T18:12:00Z,checkout
2027-05-26T17:19:00Z,slots
2027-05-28T08:51:00Z,checkout
2027-05-28T17:51:00Z,orders-db
2027-05-29T06:54:00Z,payments
2027-05-30T04:40:00Z,checkout
2027-05-31T04:09:00Z,slots
2027-05-31T13:05:00Z,slots
CSV
