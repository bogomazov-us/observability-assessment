---
name: oa-sre-stage-3-gap
description: Run stage 3 of an SRE assessment, which drafts the gap: per tier-1 service and dimension, what the confirmed target asks, what is in place today, and the evidence for it. Start only when the person asks for SRE stage 3; a person confirms the result.
disable-model-invocation: true
---

Run `bash __KIT__/tools/agent/prompt.sh --assessment sre 3` and follow the prompt it prints, as
written: it is the SRE stage 3 task and the rules every stage shares. Its first step is the gate
check; when the gate is shut, stop there and hand over what the check reports.

The kit at `__KIT__` is read only. Inputs the prompt lists and the person has not given are
named and not substituted.
