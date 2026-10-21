# Privacy checklist — personal data in telemetry

Personal data leaks into telemetry by default: URLs, headers, error payloads, log bodies, session
replay. This checklist is used twice: in week one, to find what already flows; in the Blueprint,
to write the rules the instrumentation contract enforces. It is not legal advice: what the law
requires is decided by the client's applicable data-protection law and its DPO; the checklist
finds the facts they need.

## Week one — ask

- [ ] Who is the client's DPO or privacy owner, and who signs off on telemetry changes?
- [ ] Which data classes does the client treat as personal or sensitive (identifiers, contact
      data, payment data, health, location, free text)?
- [ ] Where may telemetry be stored and processed (region, residency), and for how long?
- [ ] Is there a record of what the monitoring tools collect? When was it last reviewed?
- [ ] How are deletion and access requests handled for data held in monitoring tools?
- [ ] Who has access to the monitoring tools, and is access reviewed?

## Week one — check in the estate export

Against the object classes of [tools/collect.md](../tools/collect.md):

| Class | Check | Evidence |
|---|---|---|
| Telemetry pipelines | Masking, drop and scrub rules exist; they run before storage, not at query time | rule export |
| Telemetry pipelines | Retention per data type (traces, logs, RUM sessions, replays) matches what the client stated | retention settings |
| Real-user monitoring | Input capture, session replay and their masking defaults; user identification settings | RUM settings |
| Real-user monitoring | Full URLs with query strings recorded; IP addresses stored or truncated | sample of stored actions |
| Monitored entities | Request attributes or captured headers that may carry identifiers or tokens | capture configuration |
| Alert rules, dashboards | Queries or titles that embed customer data | export |
| Integrations | Data sent on to ticketing or chat (alert payloads with customer data) | notification templates |

Sample stored data, not only settings: one query over a day of logs and spans for e-mail
patterns, card-like numbers, tokens and national-ID-like strings. Record the query and the count,
never the matches.

## Blueprint — rules for the instrumentation contract

| Rule | What it means |
|---|---|
| Never emitted | Credentials, tokens, session cookies, full card numbers, security answers, free-text fields, request and response bodies of personal-data endpoints |
| Mask at source | The service removes or masks before emitting; the pipeline mask is a second line, not the only one |
| Pseudonymous IDs | attempt_id, operation_id and user references are opaque; no e-mail or account number as an ID |
| URLs | Path parameters templated (`/orders/[id]`); query strings dropped or allow-listed |
| Headers | Allow-list of captured headers; `Authorization`, `Cookie` and custom auth headers never captured |
| Session replay | Off, or on with all inputs and text masked by default; unmasking is a reviewed exception |
| Error payloads | Error class, code and reason only; no echo of the request or of customer data |
| Log bodies | Structured fields from an allow-list; no full objects dumped |
| Retention | Per data type, written in `signals.md`; replays and raw logs shortest |
| Access | Role-based; access to raw sessions and logs is limited and reviewed |
| Residency | Storage and processing region as the client requires |
| Deletion | How a deletion request reaches telemetry stores, or why it does not need to |
| Test traffic | Synthetic users and test data only; never copies of production customers |

Each rule gets a release check where it can be checked mechanically (a sample query for patterns
on every release; an allow-list diff).

## The engagement team's own data

- [ ] Exports and captures live in the engagement repository or a store the client approved;
      never in this kit, never on a personal device without encryption.
- [ ] Raw exports stay out of version control when the engagement's rules say so; only sanitized
      extracts are committed.
- [ ] Queries are recorded, results with personal data are not.
- [ ] Everything is deleted or returned at the end of the engagement, as the contract states.

## Sanitising a HAR capture (lesson 11)

1. Capture with a test user, never a real customer.
2. Remove cookies, `Authorization` and any custom auth headers from every request and response.
3. Remove request and response bodies of authentication and personal-data endpoints; keep status,
   timing and the fields the journey decomposition needs.
4. Replace query-string values and path identifiers with placeholders.
5. Search the result for the test user's e-mail, name and tokens; zero hits before committing.
6. Keep the raw capture outside version control and delete it once sanitized.

## Red flags

| Seen | Why it matters |
|---|---|
| Session replay on with unmasked inputs | Typed data, including passwords or card data, is recorded |
| Full URLs with e-mail or tokens in query strings | Identifiers and credentials sit in every trace and log |
| Request bodies captured on all endpoints | Personal data stored in bulk, often outside the stated retention |
| Masking only at query time | Data is stored unmasked; anyone with raw access sees it |
| No one can say what the tools collect | Nobody can answer an access or deletion request |
| Alert payloads with customer data sent to chat | Personal data copied into tools outside the agreed scope |

## Findings and maturity

Write each confirmed issue as a finding (`templates/finding.md`) with the query or setting as
evidence. They score maturity dimension 11 (data governance and cost): personal data unknown is
level 1; documented and scrubbed is level 3; managed per signal is level 4. A red flag on a
tier-1 journey goes into the report's executive part.
