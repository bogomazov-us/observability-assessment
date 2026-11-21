# Risk register

Risks to the client's service that someone must own: a confirmed blind spot (stage 1 or 3), a
residual risk of the detection matrix (stage 3), or a risk a finding names. The agent hands
them over as proposed rows; a person enters them once confirmed, with a proposed owner, without
waiting for the findings. A finding written later links the risk. `tools/agent/init-engagement.sh`
creates this file when absent and never replaces it.

| Column | Holds |
|---|---|
| ID | `R-01`, `R-02` …; never renumbered or reused |
| Risk | What can go wrong, and for whom, in one sentence |
| Source | Blind spot, residual risk or finding; the stage; the row it rests on (`L-07`, `G-03`, `F-012`) |
| Owner | The client's person who owns it; *proposed* until they accept |
| Status | open, accepted, mitigated, closed, or superseded by `R-NN` (the row stays) |
| Date | When the row was entered or its status last changed |
| Decision | The decision-register id that accepted, mitigated or closed it; empty while open |

| ID | Risk | Source | Owner | Status | Date | Decision |
|---|---|---|---|---|---|---|
