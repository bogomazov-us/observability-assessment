---
name: oa-stage-2-target-model
description: Run stage 2 of an observability assessment, which drafts the target model: journeys decomposed into business functions, and each function's error taxonomy. Start only when the person asks for stage 2; a person confirms the result.
disable-model-invocation: true
---

Run `bash __KIT__/tools/agent/prompt.sh 2` and follow the prompt it prints, as written: it is
the stage 2 task and the rules every stage shares. Its first step is the gate check; when the
gate is shut, stop there and hand over what the check reports.

The kit at `__KIT__` is read only. Inputs the prompt lists and the person has not given are
named and not substituted.
