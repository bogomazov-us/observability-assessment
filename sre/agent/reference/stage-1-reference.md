# Stage 1 reference — SRE inventory

*Reference for [stage 1](../stage-1-inventory.md). `prompt.sh --assessment sre 1` does not
append it; the prompt names it at the Method and the Output, and the agent reads a step's section here before
doing the step. A rule here binds as if it were in the prompt.*

## Method

### 1. Object classes

Whatever the tools, the same classes of object are inventoried. "Should exist" is read from the
first source available, in the order given; "Export shows" is what the client's systems hold.
"Request" is the row of the [SRE data request](../../templates/data-request.md); "Dimension"
is the [SRE maturity model](../../maturity-model.md)'s.

| Object class | Should exist, from | Export shows | Request | Dimension | Reconcile with |
|---|---|---|---|---|---|
| Services | Service registry or catalogue export; infrastructure as code; deploy targets in the pipeline | Workloads running in the estate, with deploy target and last deploy | S5 | 1 | Deploys; infrastructure as code; the kick-off scope |
| Dependencies | Architecture documents; configuration (endpoints, connection settings); infrastructure as code | Calls or connections seen live where a read-only view exists (service map, network or mesh configuration) | S5 | 1, 7 | Services; tiers |
| Deploys | Pipeline definition per service; rollout configuration (strategy, automatic halt, rollback) | Deploy history: service, time, result, rollback, unplanned fix | S4 | 6 | Services; incidents linked to a change |
| Incidents | Severity levels and roles in the incident process; the postmortem rule above a severity | Incident export, with each incident's class (outage or data correctness); postmortems; action items with owner role, due date and state | S1, S2 | 4 | Pages; deploys; services |
| Pages and rotations | Rotation and escalation per service, from the paging tool's configuration | Rotations with their members (opaque ids); paging export | S3 | 5 | Services; alerts |
| Alerts (light) | Alert rules in code or infrastructure as code for tier-1 candidates | Alert rules with route, owner and runbook link | — | 3 | Pages and rotations. Depth is the observability assessment's |
| Backups and restores | Backup policy per data store in infrastructure as code (schedule, retention, copy location) | Backup job history with results; restore test records with date, store, duration, result | S6 | 9 | Services' data stores |
| Capacity and quotas | Autoscaling configuration and limits in infrastructure as code; quotas | Utilisation, scaling events, quota usage; load-test reports; peak events | S7, S8 | 8 | Services; incidents with a capacity cause |
| Infrastructure as code | Repositories and modules for the services in scope | Live resources against the code: present in both, live only (drift or manual), code only | S5 | 1, 7 | Services; backups; capacity |

Check the exports received against the data request first. A class with no export and no
read-only access is one line, status *not verifiable*, with the data request row it waits on;
it is never an empty class. An export without its query or call, time and count is a lead,
not evidence. A restore or failover with no record is recorded as untested; it is never tried.

**What a deploy is.** A deploy is a run of the job that changes production for a service: the
deploy job, or, where infrastructure is applied on merge, the apply job of the production
pipeline. Build, test and plan jobs are not deploys; name the job counted in the `L-` row. A
failed pipeline run is not a failure in production: a change failure rate counted from
pipeline failures is a proxy and its `B-` row says so. Lead time needs the first commit of each
change; merge records alone do not give it, so without it lead time is *not measured*.

**Incidents per class.** Service outages and data-correctness defects are timed apart: their
detection times differ by orders of magnitude. Every incident row carries its class; an
incident export without one is classed with the owner, as a question.

### 4. Reconciliation

Each line is checked for every service in scope; a hit is a row in the reconciliation, citing
the `L-` rows that show it. Those in **bold** are confirmed blind spots once the rows behind
them are confirmed or not found in the checked window.

| Check | Rows it reads |
|---|---|
| **A tier-1 candidate with no owner** | Services, pages and rotations |
| **A service whose pages route to no rotation, or to a rotation with no members** | Pages and rotations, alerts |
| **A tier-1 data store with no restore on record** | Backups and restores |
| **A backup job failing, or not run in its schedule, with no alert on it** | Backups and restores, alerts |
| **A quota or autoscaling maximum near its limit with nothing watching it** | Capacity and quotas, alerts |
| A service deployed but in no catalogue, or catalogued and never deployed | Services, deploys |
| A live resource no code describes, or code with no live resource | Infrastructure as code |
| A deploy with no pipeline, or a pipeline with no rollback path | Deploys |
| An incident whose service is not in the catalogue | Incidents, services |
| A tier-1 candidate on a dependency outside the catalogue | Dependencies, services |
| Postmortem action items past their due date and still open | Incidents |

"Near its limit" uses the threshold the client's configuration states; without one, the
usage is stated and the check is an owner question.

### 5. Service catalogue

One `S-` row per service found, from [the template](../../templates/service-catalogue.md), with
the status of its `L-` row. A service found in deploys or infrastructure but missing from the
client's list is a row with status *differs*. Tiers are *proposed*, from the critical journeys
agreed at kick-off; the owners decide them in stage 2. An owner not found is *unknown* and an
owner question.

### 6. Baseline

Run [`tools/baseline.py`](../../../tools/baseline.md) on the sanitized incident, deploy and page
exports in `sre/exports/`, stating the column mapping (`--map`), the window and the time zone.
Copy its table into `sre/baseline.md` and add the `B-` ids. Incident numbers are given per
class (the tool run once per class, unless it splits them); never one number over both. A number it prints as *not measured*
keeps its reason; it is never estimated, and stage 3 reads it as a gap. An export not received
gives *not measured: no export*, with the data request row.

Numbers the tool does not compute are counted from the exports, each as a `B-` row with this
method, its window and its source; any other method is named in the row. Tier-1 means the
proposed tier until stage 2 confirms it.

| Number | Method |
|---|---|
| Restore tested | Tier-1 data stores with a restore record in the window, from the backups the RPO relies on (a one-off copy is not one) ÷ tier-1 data stores |
| Backup success | Successful backup runs ÷ scheduled runs, per data store, in the window |
| Action-item closure | Postmortem action items closed by their due date ÷ items due in the window |
| Owner coverage | Services in scope with an owner and a paging route ÷ services in scope |
| Quota headroom | Highest usage in the window ÷ limit, per quota of a tier-1 service |

## Output

`sre/inventory.md`, after its one page of result:

1. The live verification table: class, object, status, evidence by `E-` id (the commands and
   their output go to the evidence catalog).
   A catalog entry is a heading `### E-NNN — name` with `Checked at:` or `Data window:`,
   `Result:` and `Limits:` lines, or a table row with the `E-` id first under Window (or
   Checked at), Result and Limits columns, all filled; the report build checks it.
2. The data request items received and missing.
3. The sources read, with their revision.
4. The status summary with its sum.
5. The reconciliation (step 4).
6. What could not be inventoried, with the reason.

Owner questions are presented inline in the conversation as well as in the file: per item its
claim, its basis and the options, then a one-line answer template (`Q-07: B; Q-08: 4 hours`).
Withdrawn ids are stated in the counts, with the reason.

## Combined format

When the engagement also runs observability:
- Alert and routing objects already in the observability inventory are cited by its row id
  ("observability L-07"), not collected again; this stage adds only the route to a rotation.
- Each type keeps its own `L-` sequence and its own exports folder.
- Owner questions and confirmed blind spots go to the shared files, in their one sequence.
