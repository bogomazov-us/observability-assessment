# Rule: claims stay within what was checked

*Applies to every stage. An agent writes fast and generalises easily; a reviewer reads the
generalisation as a finding. Before handing over, tick each item against every claim.*

1. A claim says what was looked at, and no more.
2. A claim names the window and the place of its check; for a point-in-time read (a
   configuration, an alarm's current state) the window is the time of the check.
   Bad: "traces are not delivered". Good: "0 traces in the trace store in the checked 24 h".
3. Evaluation is not detection: a rule that evaluates without error and is inactive shows only
   that the expression runs, and whether it fires on a failure needs a scenario test.
4. Absence of data is not a defect by itself (an error series that does not exist may mean no
   such error happened), so say what would tell the two apart.
   Bad: "no alert exists". Good: "no alert shown in the folder read".
5. A state says how it was reached.
   Bad: "OK". Good: "no data, OK by the missing-data setting".
6. A cost or volume read at account or service level is labelled so, and its attribution to the
   scope is a separate step, stated as done or not done.
7. A difference is not a cause: a cause is "not established" until shown, and a shown cause is
   bounded to the window read.
   Good: "counter above the expected number of scheduled runs; cause not established".
8. A metric, label or alert defined in code is "defined in code", and live only when the series
   or rule was seen in the estate.
9. A document's statement is quoted with the document's date and never carried into the current
   state without live evidence, since documents mix past and present.
10. A claim about a mechanism covers each way it runs (full, partial or filtered runs, stop on
    the first error, continue on error, dry run, offline, killed): list the modes from the
    options and the error branches, say per mode what is written, and name each mode not read.
    Bad: "each run writes a record", with only the full run read.
11. A measurement names the tool and the settings that change its number, such as sampling, a
    default depth or a window.
12. An explanation beyond what was measured is a hypothesis until something shows it.
    Bad: "only a restart would help", stated as found.
13. When no layer's counters show an event, say that, without placing the source in a layer
    that was not read or excluding a layer whose counters could miss it.
14. A missing header or field alone does not establish where a response came from; that takes
    the full request record, correlated in each layer.
15. A proposed or decided remedy is stated with the case it does not cover and the test that
    would show it, not as closing the gap.
16. A health signal vouches for its own stream only: a heartbeat shows that its stream arrives,
    and each other input is checked on its own.
17. Not built is not impossible: "cannot be computed" only when the inputs do not exist.
    Bad: "cannot be computed". Good: "continuous computation is not implemented; computed once
    by hand".
18. A passing check covers only the paths it exercised, so a green pipeline or test suite says
    which.
19. What a pipeline runs is read from its steps, not from a job name.
