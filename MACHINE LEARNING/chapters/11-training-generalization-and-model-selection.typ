#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "11-training-generalization-and-model-selection")

= Training, Generalization, and Model Selection <ch:training>

#chapterguide[#chapref(<ch:supervised>) and #chapref(<ch:evaluation>): supervised objectives, realistic holdouts, and metric choice.][diagnose underfitting and overfitting from training and validation scores; explain bias and variance with numbers; regularize; read a learning curve; tune without fooling yourself; handle imbalance; select features without leakage; and save a model you can reproduce.]

Training lowers the error on the data the model sees. That is easy, and it can be made as low as you like by giving the model enough freedom. The hard part is choosing how much freedom to allow, without being fooled by luck and without looking at the test set. Every decision in this chapter is made before the test set is opened.

#coursechoice[
  This chapter sets workflow rules for tuning, feature selection and imbalance. #chapsref(<ch:regression>, <ch:svm>) explain the model families; revisit these rules when lasso, trees and nearest neighbors make them concrete.
]

== What training is optimizing: empirical risk

Training commonly minimizes average loss plus a charge for complexity:

$ J(bold(theta)) =frac(1, n) sum _(i=1)^n cal(L)(y_i,f_(bold(theta))(bold(x)_i)) + lambda Omega (bold(theta)). $

The first term fits the observed rows, and $Omega$ discourages unnecessary complexity. This objective is only a stand-in for the true goal, low error on future data. It may have one best solution or many local dips, and either way a low training loss guarantees nothing about generalization.

== Underfitting and overfitting

#analogy[
  Three students prepare from past papers. One learns only “answer C when unsure” and does badly on everything. One learns the methods and does well on old and new papers alike. One memorizes every past answer, scores full marks on the past papers, and falls apart on new questions. They have underfitted, fitted well, and overfitted.
]

#describe-nextline(1.15in)[
  / Underfitting: The model is too simple to capture important patterns and performs poorly even on training data.
  / Overfitting: The model learns training-specific noise and performs much worse on unseen data.
  / Good fit: The model captures useful patterns and achieves similar, acceptable performance on training and validation data.
]

Here is the same thing on the study log. Fit polynomials of growing degree to predict the mark from hours. To score each curve on students it has not seen, use #term[leave-one-out] validation: hide one student, fit on the other nine, predict the hidden one, and repeat for all ten.

#utpfig([Three curves through the same ten students. A straight line misses the arch, a quadratic captures it, and a degree-7 polynomial threads between the students it can see. Its weakness appears when a student is hidden: fitted without student J it predicts $-149$ for J, whose mark was 38. MSE is on the rows the curve saw; left-out MSE is on the student it did not see.], label: <fig:three-fits>)[
  #canvas({
    groupplot(group-size: (3, 1), horizontal-sep: 0.75cm, ..logaxis, width: 5.65cm, height: 4.6cm, xmin: 0, xmax: 22, ymin: 25, ymax: 90, xlabel: [hours], xtick: (0, 10, 20),
      nextgroupplot(title: [Degree 1: underfit], ylabel: [mark],
        addplot(..logdots, table: studylog, x: "hours", y: "mark", meta: "name"),
        addplot(draw: orange, line-width: widths.thick, domain: (1, 21), x => -0.5 * x + 61.6),
        {
          node((11, 26), [MSE 125 / left-out 207], font: font("script", fill: navy), anchor: "south")
        },
      ),
      nextgroupplot(title: [Degree 2: good fit], yticklabels: (),
        addplot(..logdots, table: studylog, x: "hours", y: "mark", meta: "name"),
        addplot(draw: green, line-width: widths.thick, domain: (1, 21), samples: 50, x => -0.356 * calc.pow(x, 2) + 7.333 * x + 30.267),
        {
          node((11, 26), [MSE 18 / left-out 43], font: font("script", fill: navy), anchor: "south")
        },
      ),
      nextgroupplot(title: [Degree 7: overfit], yticklabels: (),
        addplot(..logdots, table: studylog, x: "hours", y: "mark", meta: "name"),
        addplot(draw: red, line-width: widths.thick, restrict-y: (20, 95), coords: ((2, 47), (2.5, 44.5), (3, 45.1), (3.5, 47.3), (4, 50.1), (4.5, 52.9), (5, 55.3), (5.5, 57.3), (6, 59), (6.5, 60.4), (7, 61.6), (7.5, 62.9), (8, 64.2), (8.5, 65.7), (9, 67.2), (9.5, 68.9), (10, 70.5), (10.5, 71.8), (11, 72.9), (11.5, 73.4), (12, 73.3), (12.5, 72.4), (13, 70.8), (13.5, 68.4), (14, 65.3), (14.5, 61.7), (15, 57.8), (15.5, 53.9), (16, 50.2), (16.5, 47.2), (17, 45), (17.5, 43.8), (18, 43.5), (18.5, 43.8), (19, 44), (19.5, 42.6), (20, 37.9))),
        {
          node((11, 26), [MSE 3.5 / left-out 3908], font: font("script", fill: navy), anchor: "south")
        },
      ),
    )
  })
]

#utpfig([Training and left-out error on the study log as the polynomial degree grows. The vertical axis is logarithmic. Training error only falls. Left-out error falls, zigzags, then explodes.], label: <fig:capacity-curve>)[
  #canvas({
    axis(..logaxis, width: 11.5632cm, height: 5.4cm, xlabel: [polynomial degree], ylabel: [mean squared error], ymode: "log", xmin: -0.3, xmax: 7.3, ymin: 2, ymax: 6000, xtick: (0, 1, 2, 3, 4, 5, 6, 7), legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.03, 0.97), anchor: "north-west"),
      addplot(draw: blue, mark: "*", mark-size: 1.4944pt, line-width: widths.thick, coords: ((0, 133.69), (1, 125.44), (2, 18.34), (3, 18.31), (4, 6.22), (5, 5.79), (6, 5.31), (7, 3.48)), legend: [rows it saw]),
      addplot(draw: orange, mark: "square*", mark-size: 1.4944pt, line-width: widths.thick, coords: ((0, 165.05), (1, 206.83), (2, 43.48), (3, 108.7), (4, 20.21), (5, 79.44), (6, 903.68), (7, 3907.53)), legend: [student left out]),
    )
  })
]

Real curves are not the smooth U of textbooks. With ten rows the left-out error zigzags, and degrees 2 and 4 both look reasonable. The large shape is what to read: both errors are high at the left, training error keeps falling to the right, and the gap between them eventually dominates.

#intuition[
  For nested model classes with successful optimization, added flexibility cannot worsen the best training fit. So training error can never tell you when to stop. Only validation can, and it does not promise you a smooth curve.
]

#keyidea[
  Overfitting means following sample-specific noise, not merely fitting a curve. The degree-2 curve is curved, and it generalizes.
]

== Model capacity and the bias-variance trade-off <sec:bias-variance>

Capacity is representational flexibility. Too little may cause bias; too much may increase sensitivity to sampling noise.

For squared-error regression, the expected error at a point $bold(x)$ decomposes exactly into three parts. Writing $hat(f)$ for the model trained on a random dataset and $f$ for the true function with noise variance $sigma ^2$,

$ bb(E)[((y-hat(f)(bold(x))))^2] =underbrace(((bb(E)[hat(f)(bold(x))]-f(bold(x))))^2, "bias"^2) +underbrace(op("Var")(hat(f)(bold(x))), "variance") +underbrace(sigma ^2, "irreducible noise"). $

Bias is systematic error; variance is sensitivity to training samples; irreducible noise remains. Regularization trades some bias for lower variance.

#workedexample[
  At a fixed test point, let $f(bold(x))=2$ and $sigma ^2=1$. Compare predictions from three model families, each trained on three random datasets.

  #utptable[
    #fsize("small")[

    #tabularx(
      columns: (auto, auto, auto, auto, auto, auto, auto),
      align: (left, center, center, center, center, center, center),
      styles: (navy-bold,),
      header: (([Model], multicolumn(3, center, style: (weight: "bold", fill: navy))[#strong[#text(fill: navy)[Predictions]]], [$"bias"^2$], [Variance], [Total]), ([], [set 1], [set 2], [set 3], [], [], [($+ thin sigma ^2=1$)])),
      [Rigid], [$2.6$], [$3.0$], [$3.4$], [$1.000$], [$0.107$], [$bold(upright(2.107))$],
      [Balanced], [$1.0$], [$2.0$], [$3.0$], [$0.000$], [$0.667$], [$bold(upright(1.667))$],
      [Wild], [$-1.0$], [$2.0$], [$5.0$], [$0.000$], [$6.000$], [$bold(upright(7.000))$],
    )

    ]
  ]

  The first row averages $3.0$ against truth $2$, giving bias $1$ and squared bias $1$. Its variance is

  $ frac(((2.6-3))^2+((3.0-3))^2+((3.4-3))^2, 3)=frac(0.16+0+0.16, 3) approx 0.107, $

  and the total is $1.000+0.107+1=2.107$.

  The rigid model is biased; the wild model is unbiased but highly variable. Minimize total error, not bias alone.

  Every row includes irreducible noise $sigma ^2=1$, so no model can reduce expected error below~$1$.
]

#analogy[
  Picture darts. #term[Bias] is a tight group landing away from the bullseye, a systematic error. #term[Variance] is a wide scatter around it, a different result on every throw. #term[Irreducible noise] is a board that wobbles, which no player can fix.
]

More data often reduces variance; stronger assumptions may trade bias for lower variance. Choose the capacity with reliable validation performance, not by how impressive the model sounds.

== Regularization

Regularization is a budget. Instead of asking only for the best fit, you ask for the best fit that keeps its parameters modest. Two common penalties are

$ J_(L_1)(bold(theta))=J(bold(theta)) + lambda sum _(j=1)^p| theta _j|, $

$ J_(L_2)(bold(theta))=J(bold(theta)) + lambda sum _(j=1)^p theta _j^2. $

$L_1$ regularization can make some parameters exactly zero. $L_2$ regularization smoothly shrinks large parameters. The strength $lambda$ is normally selected with validation data.

#workedexample[
  For the one-parameter objective $inline(frac(1, 2))( beta -hat(beta)_("OLS"))^2$ with $hat(beta)_("OLS")=4$, ridge adds $lambda beta ^2\/2$ and lasso adds $lambda | beta |$. Their solutions are

  $ hat(beta)_("ridge")=frac(hat(beta)_("OLS"), 1+ lambda), wide hat(beta)_("lasso")=op("sign")(hat(beta)_("OLS"))max(|hat(beta)_("OLS")|- lambda , med 0). $

  #utptable[
    #fsize("small")[

    #tabularx(
      columns: (auto, auto, auto, auto),
      align: (center, center, center, left),
      header: ([$lambda$], [Ridge], [Lasso], [What happened]),
      [$0$], [$4.000$], [$4.000$], [no penalty; both give the OLS answer],
      [$1$], [$2.000$], [$3.000$], [ridge halves it; lasso subtracts a flat $1$],
      [$5$], [$0.667$], [$0.000$], [ridge is small but alive; lasso has deleted the feature],
    )

    ]
  ]

  Here ridge divides by $1+ lambda$, approaching zero without reaching it at finite $lambda$. Lasso subtracts $lambda$ and clips at zero once $lambda >= 4$.
]

#chapref(<ch:regression>) applies this to the wild degree-7 curve above: a small ridge penalty cuts its left-out error from 3,908 to about 101.

=== Other ways to regularize

Regularization is broader than adding a penalty to the objective.

- #term[Early stopping] retains the model from the epoch with the best validation performance.
- #term[Data augmentation] adds meaningful input variation without changing labels.
- #term[Pruning] removes weak branches, features, or parameters.
- #term[Ensembling] averages several models to reduce variance.
- #term[Noise injection] trains the model to remain stable under small perturbations.

Match regularization to the failure mode; it cannot fix leakage or distribution mismatch.

== Learning curves

A #term[learning curve] plots training and validation error against the number of training rows. It answers a practical question: would collecting more data help?

- Poor training and validation performance suggests underfitting or an optimization problem.
- Strong training performance with weak validation performance suggests overfitting.
- Improvement in both curves as more data is added suggests that additional representative data may help.
- Highly unstable curves suggest sensitivity to the split, seed, or a small validation sample.

#utpfig([Real learning curves on Lab~2’s 7,043 telecom customers, five-fold validation. The unrestricted tree has a persistent gap: it memorizes every training row, and more rows narrow the gap only slowly. Logistic regression’s two curves meet near 0.19, so more of the same rows will not help it; it needs better features or a more flexible model.], label: <fig:learning-curves>)[
  #canvas({
    groupplot(group-size: (2, 1), horizontal-sep: 1.3cm, ..logaxis, width: 7.4cm, height: 4.7cm, xlabel: [training rows], xmin: 0, xmax: 5800, ymin: 0, ymax: 0.34, legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.97, 0.6), anchor: "east"),
      nextgroupplot(title: [Unrestricted tree: high variance], ylabel: [error],
        addplot(draw: blue, mark: "*", mark-size: 1.2951pt, line-width: widths.thick, coords: ((50, 0), (200, 0), (500, 0.001), (1000, 0.001), (2000, 0.001), (5634, 0.002)), legend: [training]),
        addplot(draw: orange, mark: "square*", mark-size: 1.2951pt, line-width: widths.thick, coords: ((50, 0.309), (200, 0.289), (500, 0.27), (1000, 0.273), (2000, 0.27), (5634, 0.274)), legend: [validation]),
      ),
      nextgroupplot(title: [Logistic regression: curves meet], ylabel: [error],
        addplot(draw: blue, mark: "*", mark-size: 1.2951pt, line-width: widths.thick, coords: ((50, 0.12), (200, 0.165), (500, 0.187), (1000, 0.181), (2000, 0.188), (5634, 0.194)), legend: [training]),
        addplot(draw: orange, mark: "square*", mark-size: 1.2951pt, line-width: widths.thick, coords: ((50, 0.253), (200, 0.223), (500, 0.215), (1000, 0.203), (2000, 0.2), (5634, 0.195)), legend: [validation]),
      ),
    )
  })
]

#keyidea[
  A persistent gap suggests variance: try more representative data or stronger regularization. Both curves poor suggest limited signal, underfitting, or optimization failure; investigate features and fitting.
]

== Hyperparameter tuning <sec:hyperparameter-tuning>

Hyperparameters include regularization strength, tree depth, number of neighbors, learning rate, and model size. Common search methods are:

#utptable[
  #tabularx(
    columns: (22%, 39%, 1fr),
    styles: (navy-bold,),
    header: ([Method], [Search strategy], [Main consideration]),
    [Grid search], [Evaluates every combination in a fixed Cartesian grid.], [Becomes expensive as the number of dimensions and candidate values grows.],
    [Random search], [Samples combinations from the search space.], [Often explores high-dimensional spaces more efficiently.],
    [Sequential search], [Uses earlier results to choose promising later experiments.], [Concentrates the search on regions that appear useful.],
  )
]

Counting fits keeps a search honest about its cost. Lab~2 tries 5 values of $C$ and 2 class weights over 5 folds, which is $5 times 2 times 5=50$ fits, and then one refit on all training rows. The curve it draws is almost flat: the best and worst settings differ by about 0.007 in ROC AUC, while the folds differ by about 0.031.

Use identical validation across candidates. Repeated tuning can overfit validation, so retain an untouched final test set.

=== Tuning without fooling yourself

#intuition[
  Random search explores more distinct values when few hyperparameters matter. Small grids suit one or two controls; neither fixes invalid validation.
]

#pitfall[
  Trying many settings and reporting the best is a selection. Its score is a little optimistic, for the same reason the tallest of ten people is taller than average. In Lab~2 the winning churn model’s cross-validated ROC AUC is 0.844 and its one test score 0.846. Here the selection effect is smaller than the noise of a 1,761-row test set, so the test score happened to come out a little higher; on another split it could as easily come out lower.
]

=== Nested cross-validation for the selection procedure

Tune inside each outer training split; outer holdouts then evaluate the complete search-plus-model procedure. Lab~2, Part~D instead uses one training-only search and a final test.

== Imbalanced classification: change the policy, not the test set

Imbalance can make majority predictions look accurate while missing every rare case. Consider metrics, thresholds, class weights and training-only resampling, in that order.

#utptable[
  #tabularx(
    columns: (24%, 1fr),
    styles: (navy-bold,),
    header: ([Strategy], [How it helps]),
    [Change the metric first], [For rare-class performance, use recall, precision, balanced accuracy, or average precision rather than accuracy alone (#chapref(<ch:evaluation>)).],
    [Move the threshold], [Choose a lower probability cutoff on validation data to increase recall without retraining.],
    [Class weights], [Tell the model that a mistake on the rare class costs more (`class_weight="balanced"`). Lab~2’s grid search includes this option and selects it.],
    [Resampling], [Drop majority rows (#term[undersampling]) or add minority examples (#term[oversampling]). SMOTE interpolates between nearby minority examples. Resample only within each validation split\'s training portion.],
  )
]

#workedexample[
  Fraud makes up 0.17% of Lab~5’s card transactions. Saying “never fraud” is 99.83% accurate and catches nothing. A logistic regression on 85,443 held-out transactions, 148 of them fraud, under three policies:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    header: ([Policy], [Flagged], [Precision], [Recall], [Accuracy]),
    [Plain model, threshold 0.50], [106], [0.858], [0.615], [0.9992],
    [Plain model, threshold 0.10], [141], [0.752], [0.716], [0.9991],
    [`class_weight="balanced"`, threshold 0.50], [2,051], [0.063], [0.878], [0.9773],
  )

  #raggedright[
  #v(6pt)
  Moving the threshold and reweighting both buy recall with precision. Accuracy falls as the policy improves for its purpose, which is a further reason not to report accuracy here. The right row depends on how many flags your team can review.
  ]]]
]

#coursechoice[
  SMOTE’s geometry is developed in #chapref(<ch:knn-nb>). Its rule applies now: split first and synthesize only within training folds, never from held-out observations.
]

#pitfall[
  Resampling changes training prevalence, not the target evaluation population. Keep validation and test distributions realistic.
]

== Feature selection is part of model development <sec:feature-selection>

#term[Feature selection] keeps a subset of the original columns to cut cost, noise, or complexity. It is not always worth doing: a regularized model with a modest number of features may not need it.

Selection retains original columns; extraction creates new ones, as in PCA (#chapref(<ch:dimred>)).

#utptable[
  #tabularx(
    columns: (19%, 38%, 1fr),
    styles: (navy-bold,),
    header: ([Family], [How it works], [Main trade-off]),
    [Filter methods], [Score features by variance, correlation, tests, or mutual information before model fitting.], [Fast and model-agnostic, but may miss interactions.],
    [Wrapper methods], [Fit a model on different feature subsets, as in recursive feature elimination.], [Model-specific, but computationally expensive.],
    [Embedded methods], [Use selection learned during fitting: zero lasso coefficients or tree-based importances.], [Efficient, but inherits model assumptions and instability.],
  )
]

#secondpass[
  Revisit lasso in #chapref(<ch:regression>), tree importances in #chapsref(<ch:decision-trees>, <ch:ensembles>), and irrelevant dimensions in #chapref(<ch:knn-nb>). The validation rules stay the same.
]

#pitfall[
  Fit supervised selectors inside the validated pipeline, separately in each training fold. #secref(<sec:data-leakage>) showed the price of doing otherwise: selecting columns on all the rows made pure noise score 0.80. The number of retained features is also a hyperparameter.
]

#keyidea[
  Before selecting features, specify the goal: accuracy, collection cost, or interpretability. Validate selection together with the model, without using the test set.
]

#debugtask[
  A researcher selects the top 20 features using all labeled rows, applies SMOTE to the full table, then runs cross-validation and reports the best result. Redesign the experiment so that nothing from the held-out rows can influence selection, resampling, or tuning.
]

== Reproducible training

A reproducible experiment records:

- data and preprocessing versions;
- training, validation, and test identifiers;
- software and hardware environment;
- model specification and configuration;
- hyperparameters, random seeds, and stopping rules;
- training curves, checkpoints, and evaluation outputs.

Report variation across reruns, not one favorable seed. Neither the split seed nor the training seed is innocent: Lab~2’s churn model scored test AUC from 0.838 to 0.855 across five split seeds, and Lab~7’s CNN scores 0.700 in its notebook and 0.686 in the book’s check script, which trains the same network from the same seed in a different order and on a single thread. Parallel hardware may prevent bit-for-bit reproduction.

#keyidea[
  Training fit and generalization are distinct requirements.
]

#modelcard[Training and Tuning - Practical Checklist][
  #tabularx(
    columns: (24%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Objective], [Define the training objective and know which parts are learned from data; optimizer details are second-pass when the estimator exposes them.],
    [Diagnosis], [Compare training and validation curves to identify underfitting or overfitting.],
    [Regularization], [Limit model capacity with penalties, pruning, simpler features, or early stopping.],
    [Tuning], [Search hyperparameters using validation data or nested cross-validation, not the final test set.],
    [Reproducibility], [Record the data version, split logic, preprocessing, model specification, random seeds, software versions, and hardware-relevant settings.],
  )
]

=== A short reproducibility checklist

#utptable[
  #tabularx(
    columns: (5%, 1fr),
    styles: (navy-bold,),
    header: ([✓], [Record this before you call a model finished]),
    [1], [The exact data snapshot, with a date and a row count.],
    [2], [Every random seed used.],
    [3], [Library versions.],
    [4], [The complete preprocessing and modeling procedure, not only the final estimator.],
    [5], [The chosen hyperparameters and the search space they came from.],
    [6], [The metric, the split strategy, and the final test score.],
    [7], [Known limitations: who the model is likely to be wrong about.],
  )
]

#keyidea[
  Record weakly represented populations and known subgroup failures. These limits guide responsible use, not a judgment that the project failed.
]

=== Save the model you would deploy

After locking and testing the procedure, save the whole preprocessing-and-estimator pipeline with a model card for reuse. This is the code Lab~2 runs:

#codefrom("/MACHINE LEARNING/all_experiments/lab02_supervised_workflow/lab02_supervised_workflow_worked.py", "# The fitted pipeline (preparation and model together)", "print(f\"saved: {model_path.name}")

Verify the saved artifact:

- #strong[Save the pipeline.] Include fitted scaling and encoding, not just the estimator.
- #strong[Check that the file reproduces the test predictions.] Load it back and compare with the in-memory model before calling it done. Lab~3 runs this check on its SVM.
- #strong[Include a model card:] features, threshold, test score, and library version. Lab~2 saves and reloads its churn model, and `predict_churn.py` uses it from the terminal.

#tryit[
  Repeat training and validation across prespecified seeds and splits. Report variation, lock the seed policy and model, refit, then test once.
]

#debugtask[
  A hyperparameter search reports its best configuration, then the researcher reruns the search with a narrower grid chosen after inspecting the test score. Explain how the test set entered training decisions and redesign the selection/final-evaluation boundary.
]

#decisionmemo[
  Two models have nearly equal mean validation performance. One has lower fold-to-fold variation, half the inference latency, and simpler monitoring. Decide which to keep and state why a tiny mean-score advantage is not automatically decisive.
]

#tryit[
  Using fixed validation folds, compare training and validation performance across capacities. Tune on development data, lock the procedure, and list the refitting steps before one final test.
]

#chapterrecap[
  - Both errors high means underfitting; a low training error with a much higher validation error means overfitting. Training error can never tell you when to stop.
  - Expected squared error splits into bias$""^2$, variance and noise. Minimize the total.
  - Regularization charges for complexity. Ridge shrinks every coefficient; lasso can delete some.
  - Learning curves show whether more data would help: a gap says perhaps, and two curves that meet say no.
  - Tune on validation folds, keep selection and resampling inside the folds, and open the test set once.
  - Save the whole pipeline with a card, and report variation rather than one lucky seed.
]

#quickcheck[
  + What train-versus-validation pattern suggests underfitting, and what pattern suggests overfitting?
  + From #figref(<fig:capacity-curve>), why would choosing the degree by training error always pick the largest degree available?
  + How can regularization improve validation performance even while making the training fit worse?
  + For $hat(beta)_("OLS")=4$ and $lambda =2$, what do ridge and lasso give, using the formulas in this chapter?
  + A team has 1% positives and reports 99% accuracy. Name two things you would change about the evaluation.
  + Which decisions must be locked before the final test set is evaluated?
]
