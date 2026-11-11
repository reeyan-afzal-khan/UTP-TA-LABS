#import "/.shared/typst/utp.typ": *
#unit("labs", "02-data-quality")

#lab("2")[Audit missingness, categories, and validity] <sec:lab02>

#callout("labproject", title: [Data-quality audit: define rules before cleaning])[#strong[Coverage.] Chapter~#ref(label("ch:quality"), supplement: none). \
#strong[Goal.] You should be able to distinguish missingness, invalid values, inconsistent categories, duplicate records, and structural absence; then choose a defensible treatment based on variable meaning and analytical purpose. \
#strong[Datasets.] `iris_dataset.csv` and `titanic_dataset.csv`; Ames Housing and Red Wine Quality are used as extensions. \
#strong[Scenario.] You have received data from multiple sources and must decide whether it is fit for analysis. The objective is not to make the data "look clean", but to identify defects, document rules, and preserve an auditable record of every transformation.


#include "/DATA SCIENCE/labs/visuals/02-flow.typ"


#strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block. #code-block("Rscript all_experiments/lab02_data_quality.R", lang: "text")

#strong[Step 1.] Load, validate and prepare the data #source-code("/DATA SCIENCE/all_experiments/lab02_data_quality.R", first: 1, last: 26, lang: "r")

#strong[Step 2.] Standardise category labels without modifying the raw field. 
#include "/DATA SCIENCE/labs/visuals/02-trace.typ"
 #source-code("/DATA SCIENCE/all_experiments/lab02_data_quality.R", first: 27, last: 48, lang: "r")

#strong[Step 3.] Demonstrate a documented derived field rather than overwriting Age.

#strong[Use the chapter while coding.] Revisit #link(label("ch:quality"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Read the assignment and the condition around it before interpreting the count. This is a documented cleaning demonstration. If using imputation in a prediction workflow, learn its replacement value from training rows only. 
#include "/DATA SCIENCE/labs/visuals/02-worked-case.typ"


#source-code("/DATA SCIENCE/all_experiments/lab02_data_quality.R", first: 49, last: 68, lang: "r")

#strong[Step 4.] Extension A - Ames Housing: inspect high-missingness fields before assigning meaning. #source-code("/DATA SCIENCE/all_experiments/lab02_data_quality.R", first: 69, last: 78, lang: "r")

#strong[Step 5.] Extension B - Red Wine Quality: identical feature rows are not automatically bad records. #source-code("/DATA SCIENCE/all_experiments/lab02_data_quality.R", first: 79, last: 85, lang: "r") #strong[Chapter connection.] Revisit #link(label("ch:quality"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA SCIENCE/labs/visuals/02-data-quality-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Audit one cleaning decision with before/after values and a reason. Compare the relevant distribution before and after treatment, including the count of observations.

#strong[Required evidence.] Submit a data-quality log with each issue written as #emph[rule $arrow.r$ evidence $arrow.r$ action $arrow.r$ consequence]. Include at least one issue you deliberately leave unchanged because the evidence is insufficient to justify a transformation.

#strong[Professional standard.] A cleaning step is acceptable only when another analyst can determine what changed, why it changed, and whether the original value is still recoverable.]]
