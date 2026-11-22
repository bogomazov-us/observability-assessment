---
name: oa-sre-stage-5-maturity
description: Run stage 5 of an SRE assessment, which drafts the maturity profile, a level per dimension with its evidence, from confirmed findings and the confirmed gap. Start only when the person asks for SRE stage 5; a person confirms the result.
disable-model-invocation: true
---

Run `bash __KIT__/tools/agent/prompt.sh --assessment sre 5` and follow the prompt it prints, as
written: it is the SRE stage 5 task and the rules every stage shares. Its first step is the gate
check; when the gate is shut, stop there and hand over what the check reports.

The kit at `__KIT__` is read only. Inputs the prompt lists and the person has not given are
named and not substituted.
