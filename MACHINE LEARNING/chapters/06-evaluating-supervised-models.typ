#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-evaluating-supervised-models")


#heading(level: 1)[Evaluating Supervised Models]
 <ch:evaluation>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* #ref(label("ch:data"), supplement: [Chapter]) and #ref(label("ch:foundations"), supplement: [Chapter]): honest holdouts, label types, averages, spread, and sampling uncertainty.

*By the end, you can:* compute regression and classification metrics by hand; read a confusion matrix; move a threshold on purpose; compute a ROC AUC by counting pairs; choose a cross-validation splitter; and say how much a score can be trusted.]

Think about a smoke alarm. You could score it by how often it is "correct": in a house with no fires it stays silent every day of the year, so even an alarm with no battery in it scores above 99%. That number is true and useless. What you want to know is whether it rings when there is a fire, and whether it leaves you alone when you make toast. Evaluation is the habit of asking the question that matters, on data the model has not seen, against a baseline that costs nothing.


#heading(level: 2)[Evaluation begins with the real objective]


Choose metrics for the supported decision and its error costs.

A useful evaluation plan states:

- the unit being predicted and the population of interest;

- how the data split imitates future use;

- the baseline that must be beaten;

- the primary metric used for model selection;

- secondary metrics and subgroup checks;

- acceptable failure rates and operational constraints.

Prespecify the primary metric to avoid selective reporting.


#heading(level: 2)[Regression metrics]
 <sec:regression-metrics>

For true values $y_i$ and predictions $hat(y)_i$, mean squared error and root mean squared error are $ "MSE" = 1 / n sum_(i = 1)^n \( y_i - hat(y)_i \)^2 \, #h(2em) "RMSE" = sqrt("MSE") . $ MSE strongly penalizes large errors. RMSE is easier to interpret because it uses the same units as the label.

#callout("workedexample", title: [Worked example])[Five delivery times, in minutes. Four predictions are nearly right; one is badly wrong.

#figure(
  align(center)[#table(
    columns: 6,
    align: (left,center,center,center,center,center,),
    table.header([True $y$], [10], [12], [14], [16], [48],),
    table.hline(),
    [Predicted $hat(y)$], [11], [13], [13], [15], [20],
    [Error $y - hat(y)$], [$- 1$], [$- 1$], [$+ 1$], [$+ 1$], [$+ 28$],
  )]
  , kind: table
  )

The absolute errors are $1 \, 1 \, 1 \, 1 \, 28$, so $ "MAE" = frac(1 + 1 + 1 + 1 + 28, 5) = 32 / 5 = 6.4 \, #h(2em) "MedAE" = 1 . $ Squaring first gives $1 \, 1 \, 1 \, 1 \, 784$, so $ "MSE" = 788 / 5 = 157.6 \, #h(2em) "RMSE" = sqrt(157.6) approx 12.55 . $ For $R^2$, the mean of the true values is $macron(y) = 100 \/ 5 = 20$, and $ sum \( y_i - macron(y) \)^2 = 100 + 64 + 36 + 16 + 784 = 1000 \, #h(2em) R^2 = 1 - 788 / 1000 = 0.212 . $

MedAE $= 1$, MAE $= 6.4$, and RMSE $approx 12.55$ describe different aspects of error. One row contributes $784 \/ 788 = 99.5 %$ of squared error; inspect extremes when RMSE greatly exceeds MAE.]

#callout("pitfall", title: [Common mistake])[Binning a continuous label changes the task to classification. Do so only when predefined categories match the decision.]


#heading(level: 2)[Additional regression metrics]


Mean absolute error is $ "MAE" = 1 / n sum_(i = 1)^n \| y_i - hat(y)_i \| . $ MAE weights errors linearly; median absolute error describes a typical miss and is more robust.

Mean absolute percentage error is $ "MAPE" = 100 / n sum_(i = 1)^n lr(|frac(y_i - hat(y)_i, y_i)|) . $ MAPE is undefined at zero, unstable near zero, and asymmetric between over- and underprediction.

For asymmetric real-world costs, a custom loss or quantile loss may be more appropriate. Quantile regression can estimate an interval of plausible outcomes rather than only a conditional mean.


#heading(level: 2)[Classification metrics: start with the confusion matrix]
 <sec:classification-metrics>

Almost every classification metric is a different way of reading the same four boxes.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/e84bf1ede7cd4a51.cetz.json")], caption: [The confusion matrix. Almost every classification metric is a different way of reading these four boxes.]) <fig:confusion-matrix>

#callout("analogy", title: [Analogy])[Back to the alarm. #strong[Precision] asks: when it rings, is there really a fire? An alarm that rings at every piece of toast has poor precision. #strong[Recall] asks: when there is a fire, does it ring? An alarm with a dead battery has zero recall, and its precision is undefined because it never rang. Turning the sensitivity up or down trades one against the other.]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Metric], [Formula], [Answers the question],),
    table.hline(),
    [Accuracy], [$frac(T P + T N, upright("all"))$], [How often is the model right overall?],
    [Precision], [$frac(T P, T P + F P)$], [When it says yes, is it right?],
    [Recall], [$frac(T P, T P + F N)$], [Does it find the ones that matter?],
    [F1], [$2 dot.op frac(P dot.op R, P + R)$], [One number balancing the two],
    [Specificity], [$frac(T N, T N + F P)$], [Does it leave the negatives alone?],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[Read confusion-matrix axis labels; actual/predicted conventions vary.]

#callout("workedexample", title: [Worked example])[Of 1,000 emails, 100 are spam. The filter flags 80, of which 60 are spam: $ T P = 60 \, #h(2em) F P = 80 - 60 = 20 \, #h(2em) F N = 100 - 60 = 40 \, #h(2em) T N = 900 - 20 = 880 . $ (Check the total: $60 + 20 + 40 + 880 = 1000$.) Now every metric is arithmetic: $ upright("Accuracy") = frac(60 + 880, 1000) = 0.940 \, #h(2em) upright("Precision") = 60 / 80 = 0.750 \, #h(2em) upright("Recall") = 60 / 100 = 0.600 \, $ $ F_1 = 2 dot.op frac(0.750 times 0.600, 0.750 + 0.600) = 0.900 / 1.350 approx 0.667 . $

The no-alert baseline reaches 90% accuracy; the model reaches 94% but misses 40 spam emails. Recall exposes those misses.]


#heading(level: 2)[Additional confusion-matrix measures]


In addition to precision and recall, useful classification measures include $ upright("Specificity") = frac(T N, T N + F P) \, #h(2em) upright("False-positive rate") = frac(F P, F P + T N) . $ Balanced accuracy averages recall for the positive and negative classes: $ upright("Balanced accuracy") = 1 / 2 \( upright("Recall") + upright("Specificity") \) . $ It is more informative than ordinary accuracy when classes are imbalanced.

The Matthews correlation coefficient (MCC) summarizes the entire confusion matrix in one number: $ "MCC" = frac(T P dot.op T N - F P dot.op F N, sqrt(\( T P + F P \) \( T P + F N \) \( T N + F P \) \( T N + F N \))) . $ MCC ranges from $- 1$ to $1$; near zero indicates little association. Using all four cells makes it useful under imbalance.

#callout("workedexample", title: [Worked example])[Continuing the spam filter ($T P = 60$, $F P = 20$, $F N = 40$, $T N = 880$): $ upright("Specificity") = 880 / 900 approx 0.978 \, #h(2em) upright("Balanced accuracy") = frac(0.600 + 0.978, 2) approx 0.789 . $ Accuracy is $0.940$, dominated by 900 negatives. Balanced accuracy is $0.789$, weighting each class equally.

MCC uses all four cells at once. The numerator is $ T P dot.op T N - F P dot.op F N = 60 \( 880 \) - 20 \( 40 \) = 52 \, 800 - 800 = 52 \, 000 \, $ and the denominator is $ sqrt(\( 80 \) \( 100 \) \( 900 \) \( 920 \)) = sqrt(6 \, 624 \, 000 \, 000) approx 81 \, 388 \, $ so $"MCC" approx 52 \, 000 \/ 81 \, 388 approx 0.639$.

Accuracy, balanced accuracy, and MCC answer different questions; do not report accuracy alone under imbalance.]

#strong[Multiclass] problems need one more decision: how to combine the classes. #strong[Macro averaging] weights classes equally, #strong[micro averaging] pools every decision, and #strong[weighted averaging] weights classes by frequency.

#callout("workedexample", title: [Worked example])[Three classes have 100, 10 and 2 rows, and a model gets 90, 5 and 1 of them right. Micro-averaged recall pools them: $96 \/ 112 = 0.857$. Macro-averaged recall averages the three recalls: $\( 0.90 + 0.50 + 0.50 \) \/ 3 = 0.633$. The large class flatters the first number, and the second shows the small classes are at a coin flip. If small classes matter, report macro.]


#heading(level: 2)[Thresholds, ROC curves, and precision-recall curves]


A probability model becomes a yes-or-no classifier only after someone picks a threshold. The model supplies a score, and the threshold is a policy. Lowering it catches more positives and raises more false alarms; raising it does the reverse.

#callout("workedexample", title: [Worked example])[Eight cases, already ranked by the model. Orange circles are real positives and blue dots are real negatives (#ref(label("fig:threshold-shift"), supplement: [Figure])).

#figure(
  align(center)[#table(
    columns: 7,
    align: (center,center,center,center,center,center,center,),
    table.header([Threshold], [TP], [FP], [FN], [TN], [Precision], [Recall],),
    table.hline(),
    [0.90], [1], [0], [3], [4], [1.00], [0.25],
    [0.65], [2], [1], [2], [3], [0.67], [0.50],
    [0.50], [3], [2], [1], [2], [0.60], [0.75],
    [0.35], [4], [2], [0], [2], [0.67], [1.00],
    [0.05], [4], [4], [0], [0], [0.50], [1.00],
  )]
  , kind: table
  )

Recall can only rise as the threshold falls. Precision wanders, because each new flag may be right or wrong. Nothing about the model changed between these rows.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/bb820b6cf6fe2068.cetz.json")], caption: [Thresholds move the operating point. The eight scores stay fixed. Lowering the threshold from 0.65 to 0.35 catches the two remaining positives, at the cost of one more false alarm.]) <fig:threshold-shift>

#callout("keyidea", title: [Key idea])[Lower thresholds increase positive decisions and can never reduce recall. Higher thresholds reduce alerts and may miss positives. Choose the threshold on validation data from costs or capacity, and lock it before test evaluation (Lab~2, Part~C).]


#heading(level: 3)[ROC AUC by counting pairs]


The #strong[ROC curve] plots true-positive rate against false-positive rate as the threshold sweeps from high to low. The area under it has a plain meaning: it is the chance that a randomly chosen positive gets a higher score than a randomly chosen negative.

#callout("workedexample", title: [Worked example])[Use the same eight cases. Positives scored 0.95, 0.85, 0.60, 0.40 and negatives scored 0.70, 0.55, 0.30, 0.10, so there are $4 times 4 = 16$ pairs. The positive at 0.60 loses to the negative at 0.70. The positive at 0.40 loses to the negatives at 0.70 and 0.55. All the rest are ranked correctly: $13 \/ 16$, so ROC AUC is 0.8125. You can check any ROC AUC this way, and it shows that the metric cares only about order, not about any threshold.]


#heading(level: 3)[Capacity and cost metrics]
 <sec:capacity-metrics>

When only $k$ cases can be reviewed, rank all eligible cases and report $ "precision@" k = frac(upright("positives in top ") k, k) \, #h(2em) "recall@" k = frac(upright("positives in top ") k, upright("all positives")) \, $ $ "lift@" k = frac("precision@" k, upright("positive prevalence")) . $ Report error costs when defensible. For fixed review capacity, evaluate the ranked batch, as in Lab~5's top 100 fraud alerts.

#callout("workedexample", title: [Worked example])[A team can call five of 20 customers. Ranked outcomes follow; $1$ denotes churn:

#block[
1~~~~0

]
The bar marks the capacity cutoff at $k = 5$. There are $4$ churners in the batch of $20$, so the prevalence is $4 \/ 20 = 0.20$. Of the top five, three churned: $ "precision@" 5 = 3 / 5 = 0.60 \, #h(2em) "recall@" 5 = 3 / 4 = 0.75 \, #h(2em) "lift@" 5 = 0.60 / 0.20 = 3.0 . $ Randomly calling five customers would reach one churner on average; this ranking reaches three, giving lift~3. The constraint is five calls, not a probability threshold.]

#callout("pitfall", title: [Common mistake])[Churn risk is not persuadability. Ranking metrics cannot establish that contact causes retention; use a causal design such as randomization.]


#heading(level: 3)[Two real models on one chart]


#ref(label("fig:pr-curves"), supplement: [Figure]) shows two logistic models from the labs: Lab~2's hotel cancellations, scored on the bookings of 2017, and Lab~3's loan defaults. The hotel model ranks well, with a ROC AUC of 0.824; the loan model is harder pressed, at 0.731. Their positive rates differ, 0.387 and 0.192, so each precision--recall curve has its own baseline: a model that guesses scores its positive rate, not 0.5.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/5c72a3dbedb4ec79.cetz.json")], caption: [ROC and precision-recall curves for two logistic models on their validation rows, Lab~2's hotel cancellations and Lab~3's loan defaults, read at 21 thresholds. The ROC baseline is the diagonal; each precision-recall baseline is that table's positive rate, 0.39 for the hotel and 0.19 for the loans.]) <fig:pr-curves>

Rarity changes the story. Lab~5's fraud ranking has a ROC AUC of 0.95, which sounds excellent. Fraud is 0.17% of those 85,443 transactions, so among the top 100 flagged ones only 39 are fraud, and its average precision is 0.22. Most of the ROC credit comes from correctly ranking tens of thousands of ordinary transactions below a few hundred unusual ones.

#callout("keyidea", title: [Key idea])[For rare positives, inspect precision--recall at the intended operating point. Strong ROC AUC can coexist with poor alert precision.]


#heading(level: 2)[Cross-validation]
 <sec:cross-validation>

#callout("analogy", title: [Analogy])[One mock exam can be easy or hard by chance. Set five, each covering a different part of the syllabus, and the average tells you far more. #strong[$k$-fold cross-validation] does this with your data: train on $k - 1$ folds, validate on the remaining one, and rotate until every fold has been held out.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/f3e8c85a5dc7299c.cetz.json")], caption: [Five-fold cross-validation stays inside the development data. Each round validates on one fold and trains on the other four; the untouched test set is not a sixth fold and is never used for tuning.]) <fig:cv-folds>

#callout("workedexample", title: [Worked example])[Lab~2's churn model, five folds of the training rows: ROC AUC 0.860, 0.863, 0.824, 0.835, 0.841. The mean is 0.844 and the standard deviation 0.015. Any claim that one model beats this one by 0.01 should be met with suspicion, since the folds themselves disagree by more than that.]

Cross-validation must preserve the data structure:

- stratify folds for imbalanced classification;

- keep related observations in the same group fold;

- use forward or rolling validation for time series;

- fit preprocessing and feature selection separately inside each training fold.

After selecting a model and hyperparameters, refit on the allowed training data and evaluate once on the untouched test set.


#heading(level: 3)[Choose the cross-validation splitter that matches the data]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Splitter (scikit-learn)], [Use it when], [Course example],),
    table.hline(),
    [`KFold`], [Rows are independent and the label is a number.], [House prices in Lab~3],
    [`StratifiedKFold`], [Classification, especially with an imbalanced label; every fold keeps the class proportions.], [Churn in Lab~2, loan defaults in Lab~3],
    [`GroupKFold`], [Several rows belong to one person, device, or school; all of them must land in the same fold.], [Repeated patient visits],
    [`TimeSeriesSplit`], [Rows are ordered in time; each fold trains on the past and validates on what came next.], [Hotel bookings in Lab~2 use one chronological cut for the same reason],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Use the same splitter for every candidate so comparisons measure model differences.]

#callout("secondpass", title: [Second pass])[The core workflow is complete. Return to probability quality, uncertainty, subgroup analysis, and shift when the application requires them.]


#heading(level: 2)[Evaluating probabilities]


Some applications need accurate probabilities, not merely correct rankings. Binary log loss is $ - 1 / n sum_(i = 1)^n \[ y_i log p_i + \( 1 - y_i \) log \( 1 - p_i \) \] . $ The Brier score is the mean squared probability error: $ "Brier" = 1 / n sum_(i = 1)^n \( p_i - y_i \)^2 . $

#callout("workedexample", title: [Worked example])[Four predictions, with the per-row cost under each score. Log loss charges $- log p$ when $y = 1$ and $- log \( 1 - p \)$ when $y = 0$; Brier charges $\( p - y \)^2$ either way.

#figure(
  align(center)[#table(
    columns: 4,
    align: (center,center,center,center,),
    table.header([True $y$], [Predicted $p$], [Log loss], [Brier],),
    table.hline(),
    [1], [0.90], [$- ln 0.90 = 0.105$], [$0.01$],
    [1], [0.60], [$- ln 0.60 = 0.511$], [$0.16$],
    [0], [0.30], [$- ln 0.70 = 0.357$], [$0.09$],
    [0], [0.05], [$- ln 0.95 = 0.051$], [$0.0025$],
    table.cell(align: right, colspan: 2)[mean], [$0.256$], [$0.0656$],
  )]
  , kind: table
  )

Now add one confidently wrong row: the true answer is $1$ and the model said $0.02$. Its Brier cost is $\( 0.02 - 1 \)^2 = 0.960$. Its log loss cost is $- ln 0.02 = 3.912$.

Brier is bounded by~1 per binary prediction; log loss is unbounded. Reducing the wrong prediction to $p = 0.001$ changes Brier from $0.960$ to $0.998$, but log loss from $3.912$ to $6.9$.

Log loss therefore penalizes extreme confidence in a wrong answer more strongly.]


#heading(level: 2)[Uncertainty and repeated experiments]


A score computed on 1,761 rows has error bars whether you draw them or not. Quantify the uncertainty with confidence intervals, the bootstrap, repeated cross-validation, or several seeds.

#callout("workedexample", title: [Worked example])[Lab~2's churn model scores ROC AUC 0.846 on its 1,761 test customers. A bootstrap of those rows gives a 95% interval of 0.826 to 0.866. Refit the same model on five other random splits, and the score comes out as 0.844, 0.838, 0.855, 0.847 and 0.847. So when a rival model scores 0.856 on the same rows, nothing is settled.]

Compare models through paired errors on the same cases. Statistical significance does not imply practical value.


#heading(level: 2)[Error and subgroup analysis]


Aggregate metrics can hide systematic failures. Inspect errors by class, label range, data source, time period, device type, location, and relevant demographic or operational groups.

Error analysis asks:

- Which examples have the largest or most costly errors?

- Are labels ambiguous, delayed, or incorrect?

- Are failures concentrated in rare or underrepresented groups?

- Does performance degrade as data becomes older or differs from training data?

- Are confident mistakes more common than uncertain mistakes?

Use error analysis to identify needed changes in data, features, labels, thresholds, or models.


#heading(level: 2)[Evaluation under distribution shift]


A test set drawn from the same source as the training data may still not look like the data the model meets after deployment. Three kinds of change have names: covariate shift (the inputs change), label shift (the class frequencies change), and concept drift (the relationship between inputs and label changes).

Stress-test missing or corrupted inputs, rare groups, seasons, and plausible worst cases. Monitor inputs, predictions, calibration, and delayed outcomes after deployment.

#callout("keyidea", title: [Key idea])[No single metric proves that a model is useful. Reliable evaluation combines a realistic split, a relevant baseline, task-specific metrics, uncertainty, subgroup analysis, and examination of actual errors.]

#callout("modelcard", title: [Evaluation - Practical Checklist])[#block[
ll Objective & Define the real decision and the cost of each kind of error. Split & Match future use; respect time, groups, location, and repeated observations. Baseline & Compare with a simple rule using the same data and metric. Uncertainty & Use cross-validation, repeated splits, or confidence intervals where appropriate. Diagnosis & Inspect errors, subgroups, calibration, threshold behavior, and distribution shift. Final report & State the data period, metric, uncertainty, limits and untouched test result.

]]

#callout("chapterrecap", title: [Chapter recap])[- Choose metrics from the decision and its error costs, before seeing results. Accuracy alone is misleading when classes are unbalanced.

- MAE reports a typical miss, RMSE punishes large ones, and $R^2$ compares with guessing the mean.

- The confusion matrix holds four counts. Precision asks whether a flag is right; recall asks whether positives are found.

- A threshold is a policy, chosen on validation data. ROC AUC is the chance a positive outranks a negative. When positives are rare, look at precision at your capacity.

- Cross-validation must respect groups, time and class balance. Scores on small sets carry wide error bars, so report them.]

#callout("quickcheck", title: [Check your understanding])[+ Describe one situation where recall should matter more than precision, and one the other way round.

+ A filter flags 50 of 500 emails. Of those 50, 30 are spam; there are 40 spam emails in all. Compute precision, recall and accuracy.

+ What usually happens to recall and false positives when a classification threshold is lowered?

+ Scores for positives are 0.9 and 0.4; scores for negatives are 0.6 and 0.2. What is the ROC AUC?

+ Why must a cross-validation splitter respect groups, time order and class balance?

+ Model A scores AUC 0.85 and model B 0.84 on 200 rows. What do you want to see before preferring A?]
