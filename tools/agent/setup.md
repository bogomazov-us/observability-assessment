# Setup and paths

**What is here:** setting up the engagement repository for the agent stages, and the table of
the paths every stage reads and writes. **Read it when:** an engagement starts, or a stage
cannot find an input. Running a stage: [README.md](README.md).

## Setting up the engagement repository

Once per engagement, before stage 1:

```
tools/agent/init-engagement.sh --repo ENGAGEMENT_REPO --code CODE_CHECKOUT [--code ...] \
    [--skills SKILLS_DIR] [--instructions PATH] [--assessment observability|sre ...] \
    [--facts PATH] [--decisions PATH] [--risks PATH] [--work PATH] [--scratch DIR]
```

It commits nothing. It writes the agent's standing instructions, from
[`templates/agent-instructions.md`](../../templates/agent-instructions.md) with the paths
filled in, to `AGENTS.md` (or `--instructions PATH`, the file your agent tool reads, a subpath such as
`.claude/CLAUDE.md` included), every path relative to the repository; the
client and the monitoring tool are left for the person. It makes what the path table marks
*init*, its folders, and the scratch directory `.scratch/`, added to `.gitignore`.
`--assessment sre` (repeatable; the default is observability) adds `sre/` in the working folder:
its own state file, `progress/`, `exports/` and `targets/`. Owner questions and findings stay
shared; with SRE alone, the observability state file and folders are not made. The
instructions file then lists each type's folder, state file and prompt command. A host
knowledge base keeps its own registers: a register named by `--facts`, `--decisions` (a file,
or a folder of ADRs) or `--risks` is never created or written to; a missing one is reported and
init exits 1 once the rest is written. Paths are written relative to the repository; keep the
repository beside the kit, since with the kit in the home folder and the repository outside it
the path names the home folder (init warns).

With `--skills SKILLS_DIR` it also installs the [stage and rule skills](skills/README.md) of
each type.
A re-run keeps what exists; `--force` replaces the instructions and the skills (after a kit
upgrade), never a state file, a register, the questions or a progress log. The agent's read-only
boundary is set in the agent tool's own permissions as well: the instructions file alone does
not enforce it. Tests: `tools/tests/test_init_engagement.sh`.

## Artifact paths

Stages read and write at these paths, relative to the working folder (`assessment/`, or
`--work`); `tools/`, `templates/` and `method/` are in the kit. The facts ledger and the
decision and risk registers are at the repository root (`facts.md`, `decisions.md`,
`risks.md`, created only when absent), or where `--facts`, `--decisions`, `--risks` point;
the instructions file names them. Rows marked *every type* are shared by the assessment types
of an engagement; "SRE N" reads the observability file in the combined format; the SRE type's
own paths are in the second table.

| Path | Made by | Read by |
|---|---|---|
| `engagement-state.yml` | init | every stage, `tools/stagegate.py` |
| `owner-questions.md` (every type) | init; every stage adds | the person |
| `progress/stage-N.md` | stage N | the person |
| `kickoff-note.md` (every type; scope, journeys, buyer's question) | the person, from `templates/kickoff-note.md` | 1, 2, 6 |
| `captures/` (sanitized journey captures) | the person | 2 |
| `scan.md` (code scan) | 1 | 2, 4 |
| `exports/` (a file per object class and date) | 1 | 2, 4 |
| `inventory.md` | 1 | 2, 3, 5, report |
| `spec/observability-spec.yml` | 2; 3 sets the signal states | 3, 4, 5; SRE 2 |
| `stage-2-notes.md` | 2 | 3, report |
| `stage-3-gap.md` | 3 | 4, 5, report |
| `findings/F-NNN.md` (every type, one `F-` sequence) | the person, as findings appear; 4 | 4, 5, 6 |
| `stage-4-notes.md` | 4 | report |
| `maturity.yml` | the person (provisional baseline); 5 | 5, 6, report; SRE 5, 6 |
| `stage-5-notes.md` | 5 | 6, report |
| `recommendations.md` | 6 | report; SRE 6 |
| `summary.md` (from `templates/report.md`; section 9, the hand-over, at acceptance), `manifest.txt` (every type) | the person, at each accepted stage | `tools/assessment-pdf.sh` |

The SRE type (`--assessment sre`) works in `sre/` under the working folder; stage numbers here
are the SRE stages.

| Path | Made by | Read by |
|---|---|---|
| `sre/engagement-state.yml` | init | every stage, `tools/stagegate.py` |
| `sre/progress/stage-N.md` | stage N | the person |
| `sre/exports/` (a file per object class and date) | 1 | 2, 3, 4, `tools/baseline.py` |
| `sre/inventory.md` | 1 | 2, 3, 4, 5, report |
| `sre/service-catalogue.md` (`S-` rows) | 1; 2 sets the tiers | 2, 3, 4, 6, report (bundle) |
| `sre/baseline.md` (`B-` rows, from `tools/baseline.py`) | 1 | 3, 4, 5, 6, report |
| `sre/target-model.md` | 2 | 3, report |
| `sre/targets/reliability-targets.md` (`T-` rows) | 2 | 3, 4, 5, 6, report (bundle) |
| `sre/stage-3-gap.md` | 3 | 4, 5, report |
| `sre/stage-4-notes.md` | 4 | report |
| `sre/maturity.yml` (`model: sre`) | the person (provisional baseline); 5 | 5, 6, report |
| `sre/stage-5-notes.md` | 5 | 6, report |
| `sre/recommendations.md` | 6 | report |
| `summary.md`, `manifest.txt` (every type; in the working folder itself) | the person, at each accepted stage | `tools/assessment-pdf.sh` |

The spec is drafted here; the person takes the confirmed spec set to the client's
`docs/observability/`.
`tools/tests/test_paths.sh` checks the prompts against this table. The format of
`manifest.txt`: [the manifest](../../method/report.md#the-manifest).
Engagement paths in the instructions file and the installed skills are relative to the main
checkout's root, also when the agent works in a worktree.
