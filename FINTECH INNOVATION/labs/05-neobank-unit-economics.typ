#import "/.shared/typst/utp.typ": *
#unit("labs", "05-neobank-unit-economics")

#lab("5")[Neobank unit economics] <sec:lab05-unit-economics>

#callout("labproject", title: [Find out whether a digital-only bank makes money per customer])[#strong[Coverage.] Chapter~#ref(label("ch:digital-banks"), supplement: none). \
#strong[Goal.] Build the model that answers the chapter's third strategic priority --- expand #emph[profitably] --- and find the assumption the whole business rests on.


#include "/FINTECH INNOVATION/labs/visuals/05-flow.typ"
]

#strong[Complete worked example.] This runnable fixture uses synthetic inputs. First reproduce it, then adapt the data or ratings with documented evidence. All code below belongs to one file. #code-block("python all_experiments/lab05_neobank_unit_economics.py", lang: "text")

#strong[Setup and output folder.] #source-code("/FINTECH INNOVATION/all_experiments/lab05_neobank_unit_economics.py", first: 1, last: 10, lang: "python")

#strong[Define and validate unit economics.] #source-code("/FINTECH INNOVATION/all_experiments/lab05_neobank_unit_economics.py", first: 11, last: 24, lang: "python")

#strong[Project the customer stock and cumulative cash.] 
#include "/FINTECH INNOVATION/labs/visuals/05-trace.typ"
 #strong[Use the chapter while coding.] Revisit #link(label("ch:digital-banks"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] In project, churn applies to existing customers before new customers are added. New customers earn a full month of contribution under this teaching convention. cash += accumulates margin minus acquisition spending, so the returned cash is a balance rather than monthly profit. Compare the first two rows of fast.csv with this trace before interpreting the 60-month chart. Values are synthetic and omit fixed costs and financing. 
#include "/FINTECH INNOVATION/labs/visuals/05-worked-case.typ"


#source-code("/FINTECH INNOVATION/all_experiments/lab05_neobank_unit_economics.py", first: 25, last: 46, lang: "python")

#strong[Change one assumption at a time.] #source-code("/FINTECH INNOVATION/all_experiments/lab05_neobank_unit_economics.py", first: 47, last: 51, lang: "python") 
#include "/FINTECH INNOVATION/labs/visuals/05-result.typ"
 #strong[Check the run.] The following output was captured from the supplied script; it describes the synthetic fixture only. #source-code("/FINTECH INNOVATION/labs/outputs/lab05.txt", first: 1, last: none, lang: "text") 
#include "/FINTECH INNOVATION/labs/visuals/05-neobank-unit-economics-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Change churn while holding other assumptions fixed. Compare LTV/CAC and the lowest monthly cash balance; explain why they answer different business questions.

- The script runs from a fresh process and creates the named CSV or report files.

- Every rate uses a stated population and denominator; every model assumption is identified.

- Synthetic outputs are labelled and are not presented as observations of a real institution.

- Change one input, rerun, and explain the direction of the result.]
