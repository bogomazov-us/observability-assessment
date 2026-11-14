# Rule: claims stay within what was checked

*Applies to every stage. An agent writes fast and generalises easily; a reviewer reads the
generalisation as a finding.*

Each claim says what was looked at, and no more:

- **Name the window and the place.** For a point-in-time read (a configuration, an alarm's
  current state) the time of the check is the window. "0 traces in the trace store in the checked 24 h", not
  "traces are not delivered": another backend, or another window, was not checked.
- **Evaluation is not detection.** A rule that evaluates without error and is inactive shows
  that the expression runs. Whether it fires on a failure needs a scenario test.
- **Absence of data is not a defect by itself.** An error series that does not exist may mean
  no such error happened. Say what would tell the two apart.
- **Say how a state was reached.** An alarm that is OK because missing data is treated as not
  breaching is "no data, OK by the missing-data setting", not "OK".
- **Totals are not attributions.** A cost or volume read at account or service level is
  labelled so; attribution to the scope is a separate step, done or not done.
- **A difference is not a cause.** "Counter above the expected number of scheduled runs; cause
  not established" until the cause is shown.
- **Defined is not emitted.** A metric, label or alert defined in code is "defined in code";
  it is live only when the series or rule was seen in the estate.
- **A document's statement has a date.** Client documents mix past and present. Quote a
  statement with the document's date, and never carry it into the current state without
  live evidence.
- **A mechanism runs in more than one way.** "Each run writes a record" holds only after every
  way it runs was read: full, partial or filtered runs, stop on the first error, continue on
  error, dry run, offline, killed. List the modes from the options and the error branches,
  and say per mode what is written; when a mode was not read, say so.
- **A measurement names its method.** Say which tool and settings produced a number when they
  change it — sampling, a default depth, a window. An explanation that goes beyond what was
  measured ("only a restart would help") is a hypothesis until something shows it.
- **Absence everywhere is not a location.** When no layer's counters show an event, say that;
  it does not place the source in the layer that was not read, and it does not exclude a layer
  whose counters could miss it. A missing header or field alone does not establish where a
  response came from: that takes the full request record, correlated in each layer.
- **A remedy narrows; say what it leaves.** A proposed or decided fix is described with the
  case it does not cover and the test that would show it, not as closing the gap.
- **A health signal vouches for its own stream.** A heartbeat shows that its stream arrives,
  not that any other input exists; each input is checked on its own.
- **Not built is not impossible.** "Continuous computation is not implemented" when a value
  was computed once by hand; "cannot be computed" only when the inputs do not exist.
- **A passing check shows what it ran.** A green pipeline or test suite covers the paths it
  exercised; say which. What a pipeline runs is read from its steps, not from a job name.


**Before handing over:** no claim says more than its check: evaluation, absence, missing-data
states, totals, causes, modes of a mechanism, measurement methods and passing checks are worded
as above.
