#import "/.shared/typst/utp.typ": *
#unit("labs", "06-inference")

#lab("6")[Quantify uncertainty with bootstrap and permutation logic] <sec:lab06>

#callout("labproject", title: [Sampling and inference: estimate, quantify, challenge])[#strong[Coverage.] Chapter~#ref(label("ch:inference"), supplement: none). \
#strong[Goal.] You should be able to define an estimand, construct a bootstrap interval, build a permutation reference distribution, report effect size, and separate statistical evidence from study-design limitations. \
#strong[Dataset.] `student_performance_dataset.csv`. \
#strong[Scenario.] A school analyst observes a grade difference between students who report intending higher education and those who do not. Your task is to quantify the difference, assess sampling uncertainty, and prevent statistical significance from being mistaken for a causal conclusion.


#include "/DATA SCIENCE/labs/visuals/06-flow.typ"


#strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block. #code-block("Rscript all_experiments/lab06_inference.R", lang: "text")

#strong[Step 1.] Load, validate and prepare the data #source-code("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 1, last: 24, lang: "r")

#strong[Step 2.] Bootstrap confidence interval for the mean difference. 
#include "/DATA SCIENCE/labs/visuals/06-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:inference"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Trace the source of randomness in each loop. Sampling values within groups estimates uncertainty around the observed contrast; shuffling labels constructs the no-association reference. Neither operation turns these observational groups into a randomised experiment. 
#include "/DATA SCIENCE/labs/visuals/06-worked-case.typ"


#source-code("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 25, last: 35, lang: "r")

#strong[Step 3.] Permutation test: shuffle group labels under a no-group-association reference model. #source-code("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 36, last: 55, lang: "r")

#strong[Step 4.] Design audit: plausible confounders available in the same observational dataset. #source-code("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 56, last: 64, lang: "r")

#strong[Step 5.] Sensitivity check: compare within prior-grade bands (G2 quartiles). #source-code("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 65, last: 75, lang: "r") #strong[Chapter connection.] Revisit #link(label("ch:inference"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA SCIENCE/labs/visuals/06-inference-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Repeat with a different seed and compare interval endpoints. Then inspect prior-grade bands and explain why an observational association cannot isolate the causal effect of aspiration.

#strong[Required evidence.] Submit the observed effect, 95% interval, permutation p-value, one bootstrap distribution graphic, and a four-sentence interpretation covering magnitude, uncertainty, null evidence, and design limitation.

#strong[Professional standard.] Report uncertainty and effect size together. A small p-value without a meaningful effect estimate is not a complete scientific result.]]
