---
name: oa-sre-stage-1-inventory
description: Run stage 1 of an SRE assessment, which drafts the inventory: what the catalogue, code and configuration say should exist, checked against the exports and the live systems. Start only when the person asks for SRE stage 1; a person confirms the result.
disable-model-invocation: true
---

Run `bash __KIT__/tools/agent/prompt.sh --assessment sre 1` and follow the prompt it prints, as
written: it is the SRE stage 1 task and the rules every stage shares. Its first step is the gate
check; when the gate is shut, stop there and hand over what the check reports.

The kit at `__KIT__` is read only. Inputs the prompt lists and the person has not given are
named and not substituted.
