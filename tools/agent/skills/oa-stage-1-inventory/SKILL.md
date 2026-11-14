---
name: oa-stage-1-inventory
description: Run stage 1 of an observability assessment, which drafts the inventory: what code and configuration say is collected, alerted on and routed, checked against the live estate. Start only when the person asks for stage 1; a person confirms the result.
disable-model-invocation: true
---

Run `bash __KIT__/tools/agent/prompt.sh 1` and follow the prompt it prints, as written: it is
the stage 1 task and the rules every stage shares. Its first step is the gate check; when the
gate is shut, stop there and hand over what the check reports.

The kit at `__KIT__` is read only. Inputs the prompt lists and the person has not given are
named and not substituted.
