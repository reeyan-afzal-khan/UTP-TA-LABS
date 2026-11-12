#import "/.shared/typst/utp.typ": *
#unit("labs", "02-measuring-inclusion")

#labsection(2, label: <sec:lab02-inclusion>)[Measuring financial inclusion]

#labproject[Turn an inclusion claim into a number you can defend][
  #strong[Coverage.] Chapter~#ref(<ch:financial-inclusion>). \

  #strong[Goal.] Move from “FinTech improves financial inclusion” --- which is untestable as written --- to a specific, measured, falsifiable statement.

  #include "visuals/02-flow.typ"
]

#strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file.

```terminal
python all_experiments/lab02_measuring_inclusion.py
```

#strong[Setup and output folder.]

#lstinput("/FINTECH INNOVATION/all_experiments/lab02_measuring_inclusion.py", first: 1, last: 10, lang: "python")

#strong[Generate a reproducible respondent fixture.]

#lstinput("/FINTECH INNOVATION/all_experiments/lab02_measuring_inclusion.py", first: 11, last: 32, lang: "python")

#strong[Measure access and subgroup denominators.]

#include "visuals/02-trace.typ"

#lstinput("/FINTECH INNOVATION/all_experiments/lab02_measuring_inclusion.py", first: 33, last: 38, lang: "python")

#strong[Define nested inclusion levels.]

#strong[Use the chapter while coding.] Revisit #link(<ch:financial-inclusion>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Check one respondent through all three boolean expressions. The barrier analysis later changes the denominator to unbanked respondents. Its percentages cannot be compared as though they used the same population as the overall inclusion rates.

#include "visuals/02-worked-case.typ"

#lstinput("/FINTECH INNOVATION/all_experiments/lab02_measuring_inclusion.py", first: 39, last: 47, lang: "python")

#strong[Rank barriers within the appropriate population.]

#lstinput("/FINTECH INNOVATION/all_experiments/lab02_measuring_inclusion.py", first: 48, last: 57, lang: "python")

#include "visuals/02-result.typ"

#strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only.

#lstinput("/FINTECH INNOVATION/labs/outputs/lab02.txt", lang: "terminal")

#include "visuals/02-measuring-inclusion-chapter.typ"

#verification[
  #strong[Explain and extend your result.] Select two groups and report counts beside rates. Recalculate one measure with a different denominator and explain why the interpretation changes.

  - The script runs from a fresh process and creates the named CSV or report files.
  - Every rate uses a stated population and denominator; every model assumption is identified.
  - Synthetic outputs are labelled and are not presented as observations of a real institution.
  - Change one input, rerun, and explain the direction of the result.
]
