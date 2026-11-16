#import "/.shared/typst/utp.typ": *
#unit("labs", "06-inference")

#labsection(6, label: <sec:lab06>)[Quantify uncertainty with bootstrap and permutation logic]

#labproject[Sampling and inference: estimate, quantify, challenge][
  #strong[Coverage.] Chapter~#ref(<ch:inference>). \

  #strong[Goal.] You should be able to define an estimand, construct a bootstrap interval, build a permutation reference distribution, report effect size, and separate statistical evidence from study-design limitations. \

  #strong[Dataset.] `student_performance_dataset.csv`. \

  #strong[Scenario.] A school analyst observes a grade difference between students who report intending higher education and those who do not. Your task is to quantify the difference, assess sampling uncertainty, and prevent statistical significance from being mistaken for a causal conclusion.

  #include "visuals/06-flow.typ"

  #strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block.

  ```terminal
  Rscript all_experiments/lab06_inference.R
  ```

  #strong[Step 1.] Load, validate and prepare the data

  #lstinput("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 1, last: 24, lang: "r")

  #strong[Step 2.] Bootstrap confidence interval for the mean difference.

  #include "visuals/06-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:inference>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Trace the source of randomness in each loop. Sampling values within groups estimates uncertainty around the observed contrast; shuffling labels constructs the no-association reference. Neither operation turns these observational groups into a randomised experiment.

  #include "visuals/06-worked-case.typ"

  #lstinput("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 25, last: 35, lang: "r")

  #strong[Step 3.] Permutation test: shuffle group labels under a no-group-association reference model.

  #lstinput("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 36, last: 55, lang: "r")

  #strong[Step 4.] Design audit: plausible confounders available in the same observational dataset.

  #lstinput("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 56, last: 64, lang: "r")

  #strong[Step 5.] Sensitivity check: compare within prior-grade bands (G2 quartiles).

  #lstinput("/DATA SCIENCE/all_experiments/lab06_inference.R", first: 65, last: 75, lang: "r")

  #strong[Chapter connection.] Revisit #link(<ch:inference>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/06-inference-chapter.typ"

  #checklist[
    #strong[Explain and extend your result.] Repeat with a different seed and compare interval endpoints. Then inspect prior-grade bands and explain why an observational association cannot isolate the causal effect of aspiration.

    #strong[Required evidence.] Submit the observed effect, 95% interval, permutation p-value, one bootstrap distribution graphic, and a four-sentence interpretation covering magnitude, uncertainty, null evidence, and design limitation.

    #strong[Professional standard.] Report uncertainty and effect size together. A small p-value without a meaningful effect estimate is not a complete scientific result.
  ]
]
