#import "/.shared/typst/utp.typ": *
#unit("labs", "07-regression")

#labsection(7, label: <sec:lab07>)[Build and diagnose a regression model]

#labproject[Regression: predict, benchmark, and diagnose][
  #strong[Coverage.] Chapter~#ref(<ch:regression>). \

  #strong[Goal.] You should be able to construct a leakage-safe train/test workflow, compare a model with a baseline, interpret holdout metrics, inspect residual structure, and evaluate whether a categorical predictor adds useful generalisable information. \

  #strong[Dataset.] `ames_housing_dataset.csv`. \

  #strong[Scenario.] You are building a first house-price prediction model. The goal is not to maximise fit on the available data, but to establish a transparent baseline, estimate performance on unseen records, and identify where the model fails.

  #include "visuals/07-flow.typ"

  #strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block.

  ```terminal
  Rscript all_experiments/lab07_regression.R
  ```

  #strong[Step 1.] Load, validate and prepare the data

  #lstinput("/DATA SCIENCE/all_experiments/lab07_regression.R", first: 1, last: 27, lang: "r")

  #strong[Step 2.] Baseline: the training-set median is a robust constant prediction.

  #include "visuals/07-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:regression>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] The constant baseline learns its value from training data. Use the same target rows for both scores. The later Neighborhood extension explicitly compares on known-category test rows; report that subset rather than comparing mismatched populations.

  #include "visuals/07-worked-case.typ"

  #lstinput("/DATA SCIENCE/all_experiments/lab07_regression.R", first: 28, last: 57, lang: "r")

  #strong[Step 3.] Segment error: does average performance hide poorer prediction for expensive homes?

  #lstinput("/DATA SCIENCE/all_experiments/lab07_regression.R", first: 58, last: 65, lang: "r")

  #strong[Step 4.] Extension: add Neighborhood as a categorical predictor using the same split membership.

  #lstinput("/DATA SCIENCE/all_experiments/lab07_regression.R", first: 66, last: 74, lang: "r")

  #strong[Step 5.] A categorical model cannot predict a level that was never present in training.

  #lstinput("/DATA SCIENCE/all_experiments/lab07_regression.R", first: 75, last: 97, lang: "r")

  #strong[Chapter connection.] Revisit #link(<ch:regression>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/07-regression-chapter.typ"

  #verification[
    #strong[Explain and extend your result.] Inspect one large residual in the original record. Compare expensive-home error with overall error, reporting both sample sizes and the baseline on each segment.

    #strong[Required evidence.] Submit baseline and model metrics, two diagnostic plots, one subgroup error summary, and a short model card stating intended use, strongest observed limitation, and one next improvement to test.

    #strong[Professional standard.] A model is useful only relative to a baseline and an intended decision. Training $R^2$ alone is not evidence of predictive performance.
  ]
]
