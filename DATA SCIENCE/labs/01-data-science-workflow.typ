#import "/.shared/typst/utp.typ": *
#unit("labs", "01-data-science-workflow")

#lab("1")[Frame a question and build a reproducible data profile] <sec:lab01>

#callout("labproject", title: [Guided workflow: from question to evidence])[#strong[Coverage.] Chapter~#ref(label("ch:workflow"), supplement: none). \
#strong[Goal.] By the end of the lab, you should be able to frame an estimable question, distinguish analytical roles of variables, construct a compact data profile, and document the computational environment that produced the result. \
#strong[Dataset.] `bike_sharing_dataset_day.csv`. \
#strong[Scenario.] A bike-sharing operator wants a concise first assessment of daily demand. Before modelling anything, the analyst must define what one row means, identify the variables that can support the question, and produce an analysis another person can reproduce.


#include "/DATA SCIENCE/labs/visuals/01-flow.typ"


#strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block. #code-block("Rscript all_experiments/lab01_workflow.R", lang: "text")

#strong[Step 1.] Load, validate and prepare the data #source-code("/DATA SCIENCE/all_experiments/lab01_workflow.R", first: 1, last: 16, lang: "r")

#strong[Step 2.] Compact variable profile: storage type, missingness, and number of distinct values. 
#include "/DATA SCIENCE/labs/visuals/01-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:workflow"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Check types before treating a column as numeric or categorical. A centred moving average uses observations on both sides of a date, so it describes past data rather than a forecast available on that date. 
#include "/DATA SCIENCE/labs/visuals/01-worked-case.typ"


#source-code("/DATA SCIENCE/all_experiments/lab01_workflow.R", first: 17, last: 26, lang: "r")

#strong[Step 3.] Question 1 (descriptive): what is the typical level and variability of daily demand? #source-code("/DATA SCIENCE/all_experiments/lab01_workflow.R", first: 27, last: 31, lang: "r")

#strong[Step 4.] Question 2 (comparative): does demand differ between working and non-working days? #source-code("/DATA SCIENCE/all_experiments/lab01_workflow.R", first: 32, last: 40, lang: "r")

#strong[Step 5.] Question 3 (relational): how strongly is normalised temperature associated with demand? #source-code("/DATA SCIENCE/all_experiments/lab01_workflow.R", first: 41, last: 44, lang: "r")

#strong[Step 6.] Time structure: raw daily series plus a centred 30-day moving average. #source-code("/DATA SCIENCE/all_experiments/lab01_workflow.R", first: 45, last: 60, lang: "r") #strong[Chapter connection.] Revisit #link(label("ch:workflow"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA SCIENCE/labs/visuals/01-data-science-workflow-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Choose one descriptive and one association question. State the rows and variables needed, produce the relevant summaries and distinguish the pattern observed from its possible explanation.

#strong[Required evidence.] Submit a one-page analysis note containing: the observational unit; the three questions; a compact data-profile summary; one time-series figure; two numerical findings; and one limitation. Every finding must be written as a complete evidence statement, not as raw console output.

#strong[Decision checkpoint.] End with one recommendation for the #emph[next analysis step]. Examples include modelling seasonality, separating casual from registered users, or investigating weather effects. State what additional evidence would be needed before making an operational decision.]]
