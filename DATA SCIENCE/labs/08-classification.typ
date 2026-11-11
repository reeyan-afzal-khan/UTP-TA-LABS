#import "/.shared/typst/utp.typ": *
#unit("labs", "08-classification")

#lab("8")[Evaluate probabilistic classification] <sec:lab08>

#callout("labproject", title: [Classification: preserve probabilities and make error trade-offs explicit])[#strong[Coverage.] Chapter~#ref(label("ch:classification"), supplement: none). \
#strong[Goal.] You should be able to create a stratified split, fit logistic regression, evaluate confusion-matrix metrics, compare thresholds, and distinguish binary from multiclass evaluation. \
#strong[Datasets.] `heart_failure_dataset.csv`; Breast Cancer and Optical Digits are used as extensions. \
#strong[Scenario.] You are evaluating a binary risk classifier. The purpose is to understand probabilistic output, threshold-dependent decisions, and asymmetric errors---not to treat a statistical exercise as a clinical diagnostic system.


#include "/DATA SCIENCE/labs/visuals/08-flow.typ"


#strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block. #code-block("Rscript all_experiments/lab08_classification.R", lang: "text")

#strong[Step 1.] Load, validate and prepare the data #source-code("/DATA SCIENCE/all_experiments/lab08_classification.R", first: 1, last: 11, lang: "r")

#strong[Step 2.] Stratified train/test split preserves class prevalence. 
#include "/DATA SCIENCE/labs/visuals/08-trace.typ"
 #source-code("/DATA SCIENCE/all_experiments/lab08_classification.R", first: 12, last: 43, lang: "r")

#strong[Use the chapter while coding.] Revisit #link(label("ch:classification"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] The fitted probabilities do not change when the threshold changes. Read the matrix labels: cm uses predicted labels as rows and observed labels as columns. Identify one row that changes classification between .30 and .70. 
#include "/DATA SCIENCE/labs/visuals/08-worked-case.typ"


#source-code("/DATA SCIENCE/all_experiments/lab08_classification.R", first: 44, last: 52, lang: "r")

#strong[Step 3.] Reference confusion matrix at 0.50. #source-code("/DATA SCIENCE/all_experiments/lab08_classification.R", first: 53, last: 59, lang: "r")

#strong[Step 4.] Probabilities preserve more information than hard decisions. #source-code("/DATA SCIENCE/all_experiments/lab08_classification.R", first: 60, last: 67, lang: "r")

#strong[Step 5.] Extension A - Breast Cancer: second binary feature geometry. #source-code("/DATA SCIENCE/all_experiments/lab08_classification.R", first: 68, last: 79, lang: "r")

#strong[Step 6.] Extension B - Optical Digits: high-dimensional multiclass example. #source-code("/DATA SCIENCE/all_experiments/lab08_classification.R", first: 80, last: 94, lang: "r") #strong[Chapter connection.] Revisit #link(label("ch:classification"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA SCIENCE/labs/visuals/08-classification-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Compute two confusion matrices and identify the records that change decision. Explain the false-positive/false-negative trade-off in the task's context.

#strong[Required evidence.] Submit one holdout confusion matrix, a threshold comparison, one probability-distribution view, and a short decision note explaining which error would be more costly in a stated hypothetical use case.]]
