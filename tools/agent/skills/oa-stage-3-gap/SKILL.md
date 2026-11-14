---
name: oa-stage-3-gap
description: Run stage 3 of an observability assessment, which drafts the gap: which signals of the confirmed target model are live, which SLIs can be computed today, which alerts can detect what they are meant to. Start only when the person asks for stage 3; a person confirms the result.
disable-model-invocation: true
---

Run `bash __KIT__/tools/agent/prompt.sh 3` and follow the prompt it prints, as written: it is
the stage 3 task and the rules every stage shares. Its first step is the gate check; when the
gate is shut, stop there and hand over what the check reports.

The kit at `__KIT__` is read only. Inputs the prompt lists and the person has not given are
named and not substituted.
