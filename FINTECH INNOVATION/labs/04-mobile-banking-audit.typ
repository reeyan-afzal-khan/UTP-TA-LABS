#import "/.shared/typst/utp.typ": *
#unit("labs", "04-mobile-banking-audit")

#lab("4")[Mobile banking heuristic audit and funnel analysis] <sec:lab04-mobile>

#callout("labproject", title: [Score two banking apps against the chapter's five principles, then find where users are lost])[#strong[Coverage.] Chapter~#ref(label("ch:mobile-banking"), supplement: none). \
#strong[Goal.] Convert the five usability principles into a repeatable scored instrument, and locate the single step where an onboarding journey loses most of its users.


#include "/FINTECH INNOVATION/labs/visuals/04-flow.typ"
]

#strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file. #code-block("python all_experiments/lab04_mobile_banking_funnel.py", lang: "text")

#strong[Setup and output folder.] #source-code("/FINTECH INNOVATION/all_experiments/lab04_mobile_banking_funnel.py", first: 1, last: 10, lang: "python")

#strong[Generate one ordered cohort.] #source-code("/FINTECH INNOVATION/all_experiments/lab04_mobile_banking_funnel.py", first: 11, last: 25, lang: "python")

#strong[Validate sequence before counting conversion.] 
#include "/FINTECH INNOVATION/labs/visuals/04-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:mobile-banking"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] The sequence validation rejects missing earlier steps before rates are calculated. The first step has no previous denominator, so its step conversion is missing rather than zero. Keep user counts separate from raw event-row counts. 
#include "/FINTECH INNOVATION/labs/visuals/04-worked-case.typ"


#source-code("/FINTECH INNOVATION/all_experiments/lab04_mobile_banking_funnel.py", first: 26, last: 42, lang: "python")

#strong[Inspect a suspected friction point using a denominator.] #source-code("/FINTECH INNOVATION/all_experiments/lab04_mobile_banking_funnel.py", first: 43, last: 48, lang: "python") 
#include "/FINTECH INNOVATION/labs/visuals/04-result.typ"
 #strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only. #source-code("/FINTECH INNOVATION/labs/outputs/lab04.txt", first: 1, last: none, lang: "text") 
#include "/FINTECH INNOVATION/labs/visuals/04-mobile-banking-audit-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Recalculate one stage from the underlying events. Identify the largest absolute drop and propose a measurable change, including the metric and denominator needed to evaluate it.

- The script runs from a fresh process and creates the named CSV or report files.

- Every rate uses a stated population and denominator; every model assumption is identified.

- Synthetic outputs are labelled and are not presented as observations of a real institution.

- Change one input, rerun, and explain the direction of the result.]
