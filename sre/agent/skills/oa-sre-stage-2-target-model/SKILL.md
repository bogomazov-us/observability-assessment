---
name: oa-sre-stage-2-target-model
description: Run stage 2 of an SRE assessment, which drafts the target model: the tier of each service in scope and the reliability targets per tier, or per service where one differs. Start only when the person asks for SRE stage 2; a person confirms the result.
disable-model-invocation: true
---

Run `bash __KIT__/tools/agent/prompt.sh --assessment sre 2` and follow the prompt it prints, as
written: it is the SRE stage 2 task and the rules every stage shares. Its first step is the gate
check; when the gate is shut, stop there and hand over what the check reports.

The kit at `__KIT__` is read only. Inputs the prompt lists and the person has not given are
named and not substituted.
