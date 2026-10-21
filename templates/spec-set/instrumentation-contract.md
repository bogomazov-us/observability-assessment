# Skeleton — `instrumentation-contract.md`

What every story must emit, so the model survives the end of the engagement.

---

# Instrumentation contract

## Story template section

Paste into the team's story template:

```
Observability
- Business function(s) touched: <J1.1, …>
- New or changed outcomes / error codes: <code → class>
- Events or attributes added: <name, attributes>
- Release check updated: yes / not needed (why)
```

## Code rules

1. Every response of a critical function carries outcome, error class and error code — also
   when the HTTP status is 200.
2. attempt_id is propagated across retries and services.
3. No personal data or secrets in events, attributes or logs.
4. A new error code is not merged without a class in `error-taxonomy.md`.

## Release check

| Check | How | Pass when |
|---|---|---|
| Controlled scenarios | Harness replays each typed failure as test traffic | each lands in the expected class |
| Detector check | Query each SLI over the harness run | counts match the harness log |
| Notification delivery | Fire a test P1 | delivered, acknowledged, escalated |
| Passive checks | Telemetry health over the last day | no volume floor breached |
