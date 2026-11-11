#import "/.shared/typst/utp.typ": *
#unit("labs", "04-exploratory-analysis")

#lab("4")[Explore distributions, subgroups, and relationships] <sec:lab04>

#callout("labproject", title: [Exploratory analysis: develop a defensible EDA narrative])[#strong[Coverage.] Chapter~#ref(label("ch:eda"), supplement: none). \
#strong[Goal.] You should be able to combine robust summaries and graphics, investigate subgroup structure, detect when aggregate relationships are misleading, and translate exploration into testable modelling questions. \
#strong[Dataset.] `medical_cost_personal_dataset.csv`. \
#strong[Scenario.] An insurer wants to understand the structure of medical charges before any predictive model is considered. Your task is to discover patterns, identify plausible interactions, and separate observations that are unusual from observations that are invalid.


#include "/DATA SCIENCE/labs/visuals/04-flow.typ"


#strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block. #code-block("Rscript all_experiments/lab04_eda.R", lang: "text")

#strong[Step 1.] Load, validate and prepare the data #source-code("/DATA SCIENCE/all_experiments/lab04_eda.R", first: 1, last: 8, lang: "r")

#strong[Step 2.] 1. Target shape and robust summaries. 
#include "/DATA SCIENCE/labs/visuals/04-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:eda"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] The threshold is a descriptive rule, not proof of bad data. Compare the smoker and non-smoker summaries and inspect the original rows before proposing any exclusion. Report how many observations the flag captures. 
#include "/DATA SCIENCE/labs/visuals/04-worked-case.typ"


#source-code("/DATA SCIENCE/all_experiments/lab04_eda.R", first: 9, last: 19, lang: "r")

#strong[Step 3.] Inspect flagged rows rather than deleting them. #source-code("/DATA SCIENCE/all_experiments/lab04_eda.R", first: 20, last: 26, lang: "r")

#strong[Step 4.] 2. Subgroup comparison. #source-code("/DATA SCIENCE/all_experiments/lab04_eda.R", first: 27, last: 33, lang: "r")

#strong[Step 5.] 3. Region is inspected without over-interpreting small differences. #source-code("/DATA SCIENCE/all_experiments/lab04_eda.R", first: 34, last: 41, lang: "r")

#strong[Step 6.] 4. Overall versus conditional relationship. #source-code("/DATA SCIENCE/all_experiments/lab04_eda.R", first: 42, last: 60, lang: "r")

#strong[Step 7.] Extension: age bands within smoking groups. #source-code("/DATA SCIENCE/all_experiments/lab04_eda.R", first: 61, last: 65, lang: "r") #strong[Chapter connection.] Revisit #link(label("ch:eda"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA SCIENCE/labs/visuals/04-exploratory-analysis-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Inspect one unusually high charge against similar-age records in the same smoking group. Explain what is unusual and what missing information prevents a causal explanation.

#strong[Required evidence.] Submit an EDA brief containing three graphics and no more than six evidence statements. Each statement must include the comparison or relationship, its direction/magnitude, and an appropriate limitation.

#strong[Professional standard.] Exploration is used to generate and refine hypotheses. Do not present a pattern discovered in the same data as if it were independently confirmed evidence.]]
