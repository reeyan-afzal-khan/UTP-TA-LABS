#import "/.shared/typst/utp.typ": *
#unit("labs", "09-validation-preprocessing")

#labsection(9, label: <sec:lab09>)[Validate an imbalanced classifier without leakage]

#labproject[Validation and preprocessing: evaluate the process, not one lucky split][
  #strong[Coverage.] Chapter~#ref(<ch:validation>). \

  #strong[Goal.] You should be able to construct stratified folds, prevent preprocessing leakage, compare thresholds across folds, quantify metric variability, and distinguish discrimination from calibration. \

  #strong[Datasets.] `credit_card_fraud_dataset.csv`; Heart Failure is used for a calibration extension. \

  #strong[Scenario.] Fraud is rare, so a superficially high accuracy can be operationally useless. You must evaluate a complete modelling process with stratified cross-validation, fold-local preprocessing, and threshold-sensitive metrics.

  #include "visuals/09-flow.typ"

  #strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block.

  ```terminal
  Rscript all_experiments/lab09_validation.R
  ```

  #strong[Step 1.] Load, validate and prepare the data

  #lstinput("/DATA SCIENCE/all_experiments/lab09_validation.R", first: 1, last: 11, lang: "r")

  #strong[Step 2.] Create stratified fold labels.

  #include "visuals/09-trace.typ"

  #lstinput("/DATA SCIENCE/all_experiments/lab09_validation.R", first: 12, last: 43, lang: "r")

  #strong[Use the chapter while coding.] Revisit #link(<ch:validation>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Inspect the scaling assignments inside the loop, not just the final scores. The cost\_5\_to\_1 summary uses an explicitly assumed cost ratio. Compare both mean and variability before selecting a decision rule.

  #include "visuals/09-worked-case.typ"

  #lstinput("/DATA SCIENCE/all_experiments/lab09_validation.R", first: 44, last: 75, lang: "r")

  #lstinput("/DATA SCIENCE/all_experiments/lab09_validation.R", first: 76, last: 81, lang: "r")

  #strong[Step 3.] Illustrative operational choice: missing a fraud costs 5 times a false alarm.

  #lstinput("/DATA SCIENCE/all_experiments/lab09_validation.R", first: 82, last: 88, lang: "r")

  #strong[Step 4.] Calibration extension with Heart Failure probabilities on a fresh holdout split.

  #lstinput("/DATA SCIENCE/all_experiments/lab09_validation.R", first: 89, last: 113, lang: "r")

  #strong[Chapter connection.] Revisit #link(<ch:validation>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/09-validation-preprocessing-chapter.typ"

  #verification[
    #strong[Explain and extend your result.] Compare two thresholds at the stated cost ratio, then repeat with a second ratio. Explain whether the best decision threshold changes even when predicted probabilities stay fixed.

    #strong[Required evidence.] Submit the majority-class baseline, five-fold metric summary, one variability result, and a threshold recommendation tied to an explicit error-cost assumption. Include one sentence identifying where leakage would occur if global scaling were applied before cross-validation.

    #strong[Professional standard.] Validation must reproduce the full future prediction process. Any transformation learned from all records before validation contaminates the estimate of generalisation performance.
  ]
]
