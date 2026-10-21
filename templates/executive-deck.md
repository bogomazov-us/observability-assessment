# Executive deck — read-out skeleton

The talk version of the report's executive part (`report.md`, sections 1–5, 9, 10). Most buyers
read slides, not reports; the report stays the record, the deck is what is presented. Build it
in whatever slide tool the client uses; this file fixes the order and the content.

Deliver the format the buyer asked for (lessons, 9): if they asked for a one-page answer, the
deck is slides 1, 2, 5 and 13.

## Rules

- **One claim per slide, and the title states it.** "Checkout is not measured", not
  "Checkout monitoring".
- **Every number traces to a finding** (F-NNN on the slide, small). A number without a finding
  is cut.
- **Maturity is a profile**, never an average or a single score.
- **The appendix is not in the talk.** Inventories, query lists and question logs stay in the
  report.
- **No tool screenshots without a caption** that says what the reader should see in them.
- **The last slide asks for a decision**, with who decides and by when.

## Slides

| # | Title (a claim) | On the slide | Source | Not on the slide |
|---|---|---|---|---|
| 1 | [The answer to the buyer's question, in one sentence] — e.g. "Your checkout is not measured: the dashboard counts confirmation pages" | The buyer's question in their words; the answer; the decision we will ask for | Report §1 | Method, team, agenda |
| 2 | [What it costs today] — e.g. "A slow payment provider is reported to customers as their card being declined" | Two or three consequences for customers or revenue, each with its finding | Report §1, findings | Technical cause in detail |
| 3 | [What we looked at] | Scope (journeys, services, tools), evidence types used, period; what the data cannot tell us | Report §3 | Interview lists, tool inventory |
| 4 | [Where you are] | Maturity profile: one row per dimension, level, coverage, confidence; not-scored dimensions shown as gaps | Report §5, `maturity.yml` | An average, a radar chart without the evidence column |
| 5 | [Finding 1 as a claim] | What we see, why it matters, what follows; the evidence in one line (query, code path, export) | Finding F-NNN | Full query text |
| 6 | [Finding 2 as a claim] | As slide 5 | Finding F-NNN | As slide 5 |
| 7 | [Finding 3 as a claim] | As slide 5 | Finding F-NNN | As slide 5 |
| 8 | [What you already have that we build on] | The client's own investigation or tool and what it gave us | Report §2, playbook principle 6 | Criticism of the client's team |
| 9 | [Target: every failure has an address] | The target model in one picture: journey → function → signal → SLI → threshold → owner, for one tier-1 journey | Report §9, spec set | All journeys at once |
| 10 | [What moves the most, first] | Three or four recommendations ordered by impact over effort, each with its findings and effort size | Report §7 | The full recommendation list |
| 11 | [Roadmap] — e.g. "Five weeks to a checkout that is measured, on four assumptions" | Milestones closed by demonstration, accountable owner per milestone, 30/60/90; the assumptions | Report §10, `roadmap.md` | Gantt detail, task lists |
| 12 | [What it needs from you] | Client obligations and decisions per milestone: owners, people, access | Roadmap, commitment baseline | Our staffing |
| 13 | [Decision requested] | The decision in one sentence; the options if there are several; who decides; by when | Report §1, last page | New information |

Optional, after slide 13 and only on request: the next step as a format (`offerings.md`), with
its scope limits and duration.
