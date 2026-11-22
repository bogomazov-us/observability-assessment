# Rule: boundaries common to every stage

*Applies to every stage; N is the stage's number. Each stage adds its own boundaries: what it may read and query, and
what it writes.*

- Before anything else, run `python3 tools/stagegate.py check engagement-state.yml N`.
  When it reports the stage blocked, stop: write what it reports in the progress log and hand
  it to the person. Never work around a closed gate.
- In `engagement-state.yml` you may set this stage to `draft` when you start and to
  `handed_over` when you hand over. You never set `returned` or `confirmed`, never change
  another stage, and never edit a review or a question.
- Read-only on the client's estate: code checkout, monitoring tool, delivery pipeline,
  incident tracker, backup console, exports, logs. You never change the client's code,
  monitoring configuration or tickets.
- You write only inside the engagement repository, in the files the stage names under
  "Output". Temporary files go only in the scratch directory the person names: [path].
- Never print or write secrets, credentials, account identifiers, notification endpoints,
  IP addresses (private ones included) or log bodies. Record that a value exists, not the
  value. Resource and profile names may be written; they stay in the engagement repository.
- Nothing you write is a fact. It enters the facts ledger as an assumption.
- No client data leaves the engagement repository.
- Read only the paths and systems the stage lists under "Inputs". Anything else is out of
  scope: name it as an open question, do not open it.

**Before handing over:** this stage is `handed_over` in the state file and nothing else in it
changed; nothing secret or identifying was printed or written; nothing was
written outside the engagement repository and the scratch directory.
