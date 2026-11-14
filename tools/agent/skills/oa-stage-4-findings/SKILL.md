---
name: oa-stage-4-findings
description: Run stage 4 of an observability assessment, which drafts the findings, drafted as assumptions from the confirmed target model and gap. Start only when the person asks for stage 4; a person confirms the result.
disable-model-invocation: true
---

Run `bash __KIT__/tools/agent/prompt.sh 4` and follow the prompt it prints, as written: it is
the stage 4 task and the rules every stage shares. Its first step is the gate check; when the
gate is shut, stop there and hand over what the check reports.

The kit at `__KIT__` is read only. Inputs the prompt lists and the person has not given are
named and not substituted.
