#import "/.shared/typst/utp.typ": *
#unit("chapters", "12-ensemble-methods")


#heading(level: 1)[Ensemble Methods]
 <ch:ensembles>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Decision trees from #ref(label("ch:decision-trees"), supplement: [Chapter]) and the bias--variance ideas from #ref(label("ch:training"), supplement: [Chapter]).

*By the end, you can:* explain why averaging helps and when it stops helping; bootstrap and compute an out-of-bag fraction; run one round of AdaBoost and several rounds of gradient boosting by hand; choose between forests and boosting; and validate whether the added complexity pays.]

Ask one person to guess how many sweets are in a jar, and they may be far off. Average the guesses of a whole room, and the answer is often uncannily close, because the high guesses and the low guesses cancel. An #strong[ensemble] applies this to models: combine many whose errors differ, and the mistakes partly cancel. Random forests and boosted trees are among the strongest tools for tabular data, and they rest on two different ways of getting that difference.


#heading(level: 2)[Why averaging helps]


#callout("workedexample", title: [Worked example])[A simulated jar holds 200 sweets, and each guesser's error has a standard deviation of 40. Over 10,000 simulated rooms, one guesser misses by 31.6 sweets on average, while a crowd of 25 misses by 6.4. The standard deviation of the crowd's average is 8.0, which is $40 \/ sqrt(25)$.

Now let someone announce a wrong number first, so that the whole room is swayed in the same direction. The guesses are as noisy as before, but they now share part of their error. The swayed crowd's standard deviation is 30.3, hardly better than one person. A crowd helps only if its members make different mistakes.]

For $B$ models with error variance $sigma^2$, independent errors give average variance $sigma^2 \/ B$. With average pairwise correlation $rho$, it is approximately $ rho thin sigma^2 + frac(\( 1 - rho \), B) thin sigma^2 . $ Adding models shrinks the second term, not the correlation floor. At $rho = 0$ and $B = 25$ the average has 0.04 of one model's variance. At $rho = 0.5$ it has 0.52, and adding models up to $B = 1000$ only reaches 0.50. So the art of ensembles is making members that disagree. #strong[Bagging] gets diversity from independent fits on perturbed data, and #strong[boosting] from sequential corrections.


#heading(level: 2)[Bagging: bootstrap aggregating]


Bagging fits learners to #strong[bootstrap samples]: $n$ draws with replacement from the $n$ rows. Each sample repeats some rows and leaves others out. A given row is missed by one draw with probability $1 - 1 \/ n$, and by all $n$ draws with probability $\( 1 - 1 \/ n \)^n approx e^(- 1)$. So each tree misses about 36.8% of the rows; in a simulation on 1,000 rows the fraction is 0.368. Deep trees are common base learners, and predictions are combined by voting or averaging.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/09b750dfac801a98.cetz.json")], caption: [Bagging. Each tree is fitted to its own bootstrap sample of the training data, and their predictions are combined by voting or averaging.]) <fig:bagging>

Each row can be predicted by the trees that never saw it; the resulting #strong[out-of-bag (OOB)] score is a free validation estimate. Use it as a validation signal for choosing settings, not as a replacement for the final test.


#heading(level: 2)[Random forests]
 <sec:random-forest>

If one feature is very strong, every bagged tree asks about it first, and the trees end up alike, with a high $rho$. A #strong[random forest] therefore lets each split consider only a random subset of features, which forces the trees to differ. $sqrt(p)$ features is a common starting point for classification; validate the fraction for regression and other settings.

#callout("workedexample", title: [Worked example])[On Lab~2's 7,043 telecom customers, under the same five folds, one unrestricted tree averages 0.731 accuracy. A forest of 300 such trees averages 0.793. The fold spreads are 0.010 and 0.009, so the gain is about six standard deviations: the averaging has removed most of what the single tree memorized. It cost you the readable rules of a single tree, and some prediction time.]

Practical profile:

- #strong[Key hyperparameters:] the number of trees $B$ (more trees make the average steadier until the gain flattens out), the number of features tried per split, and tree depth or minimum leaf size.

- #strong[Little tuning required:] sensible defaults perform well, which makes random forests the standard "strong model with ten minutes of effort" on tabular data.

- #strong[Extras:] OOB error estimates and feature-importance rankings come nearly free; apply the importance caveat from #ref(label("sec:tree-feature-importance"), supplement: [Section]).

- #strong[Costs:] the model is large, slower to predict than a single tree, and no longer readable as rules.


#heading(level: 3)[Extra Trees: randomize the split thresholds too]
 <sec:extra-trees>

#strong[Extremely Randomized Trees] (Extra Trees) go one step further than a forest: at each split they draw the candidate thresholds at random instead of searching for the best one, and by default they use the whole training set rather than a bootstrap sample. The extra randomness lowers variance and training time at the cost of a little bias.

Compare Extra Trees with Random Forest under the same folds and metric. Neither is universally better; the useful lesson is that both trade individual-tree strength for diversity across the ensemble.

#callout("modelcard", title: [The recipe: Random forest])[*1. Model* Many deep trees, each on its own bootstrap sample and with random feature subsets at each split.

*2. Loss* Each tree reduces Gini or squared error; the ensemble just averages.

*3. Optimizer* Greedy tree growth, repeated independently. Trees can be fitted in parallel.]


#heading(level: 2)[Boosting: learning from mistakes]


#callout("analogy", title: [Analogy])[Think of a relay of tutors. The first teaches the whole class and notes which questions students still get wrong. The second concentrates on exactly those. The third concentrates on what is left. No single tutor is impressive, but the class improves at every handover. Boosting adds #strong[weak learners], often shallow trees, in sequence, each one correcting the current ensemble.]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([], [Bagging / random forest], [Boosting],),
    table.hline(),
    [Training], [Parallel, independent], [Sequential, each model depends on the last],
    [Base models], [Fully grown, low-bias, high-variance trees], [Shallow, high-bias, low-variance trees],
    [Main effect], [Reduces variance], [Reduces bias (and variance via shrinkage)],
    [Overfitting risk], [Low; robust to noise], [Real; needs a learning rate and early stopping],
    [Tuning effort], [Small], [Moderate to large],
  )]
  , kind: table
  )


#heading(level: 3)[AdaBoost: reweight the hard cases]
 <sec:adaboost>

AdaBoost repeatedly increases the weights of misclassified observations:

+ Start with equal weights $w_i = 1 \/ n$.

+ Fit a weak learner $h_m$ to the weighted data and compute its weighted error rate $epsilon_m$.

+ Give the learner a say proportional to its quality: $ alpha_m = 1 / 2 ln frac(1 - epsilon_m, epsilon_m) . $

+ Multiply misclassified weights by $e^(alpha_m)$ and correct weights by $e^(- alpha_m)$, then renormalize.

+ After $M$ rounds, predict with the weighted vote $"sign" #h(-1em) (sum_m alpha_m h_m \( bold(x) \))$.

#callout("workedexample", title: [Worked example])[Five rows with equal weights of 0.2. A weak rule gets four right and misclassifies row 5, so its weighted error is $epsilon = 0.20$ and its say is $alpha = 1 / 2 ln \( 0.8 \/ 0.2 \) = 0.693$. Multiply the four correct weights by $e^(- 0.693) = 0.5$, giving 0.1 each, and the wrong one by $e^0.693 = 2$, giving 0.4. They now sum to 0.8, so renormalize: the four correct rows get 0.125 each, and row 5 gets 0.5. Row 5 alone now counts as much as all the others together, so the next learner has to get it right.]

At $epsilon_m = 0.3$, $alpha_m approx 0.42$, which multiplies misclassified weights by about $1.5$. A chance learner with $epsilon_m = 0.5$ gets no vote. Repeated emphasis on mislabeled cases makes AdaBoost sensitive to label noise.


#heading(level: 3)[Gradient boosting: fit the residuals]
 <sec:gradient-boosting>

Gradient boosting fits $h_m$ to the negative loss gradient at current predictions. For squared loss this is the residual $y_i - F_(m - 1) \( bold(x)_i \)$. Update by $ F_m \( bold(x) \) = F_(m - 1) \( bold(x) \) + nu thin h_m \( bold(x) \) \, #h(2em) 0 < nu lt.eq 1 . $ The learning rate $nu$ scales each correction. Tune it jointly with tree count, using validation or early stopping.

#callout("workedexample", title: [Worked example])[For $y = \( 3 \, 5 \, 8 \, 10 \)$, start at the mean, $F_0 = 6.5$, so the residuals are $\( - 3.5 \, - 1.5 \, 1.5 \, 3.5 \)$. A one-split stump on those residuals groups the first two rows and the last two, predicting $- 2.5$ and $+ 2.5$. With $nu = 0.5$ only half of that is admitted, and the process repeats on what remains:

#figure(
  align(center)[#table(
    columns: 6,
    align: (center,center,center,center,center,center,),
    table.header([Round], table.cell(align: center, colspan: 4)[#strong[Predictions for $y = 3 \, 5 \, 8 \, 10$]], [MSE],),
    table.hline(),
    [0], [6.500], [6.500], [6.500], [6.500], [7.250],
    [1], [5.250], [5.250], [7.750], [7.750], [2.562],
    [2], [4.125], [5.625], [8.125], [8.125], [1.297],
    [3], [3.812], [5.312], [7.812], [9.062], [0.418],
    [4], [3.531], [5.031], [8.094], [9.344], [0.181],
    [5], [3.422], [4.922], [7.984], [9.672], [0.073],
    [6], [3.211], [4.992], [8.055], [9.742], [0.029],
  )]
  , kind: table
  )

Each tree is weak on its own. Together, six of them have nearly memorized four rows, which is exactly why boosting needs early stopping on real data.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/1344e5714bba39c7.cetz.json")], caption: [Gradient boosting on the worked example. Round 0 predicts the mean; one stump with learning rate $nu = 0.5$ shrinks every residual towards zero.]) <fig:boosting-residuals>

#callout("intuition", title: [Plain idea])[Gradient boosting fits corrections; AdaBoost reweights mistakes. Both train sequentially.]

#callout("modelcard", title: [The recipe: Gradient boosting])[*1. Model* A sum of many shallow trees, each scaled by a learning rate.

*2. Loss* Any differentiable loss, such as squared error or log loss.

*3. Optimizer* Gradient descent in function space: each new tree fits the negative gradient of the loss at the current predictions.]


#heading(level: 3)[Modern gradient-boosting libraries]


Three refinements of gradient boosting dominate practical work; all keep the algorithm above and add engineering and regularization:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Library], [Distinctive approach], [Practical strength],),
    table.hline(),
    [XGBoost], [Adds explicit regularization of tree size and leaf values to the objective and uses second-derivative information for better splits.], [Popularized the modern toolkit, including early stopping and column subsampling.],
    [LightGBM], [Grows trees leaf-wise instead of level-wise and buckets feature values into histograms.], [Extremely fast on large datasets.],
    [CatBoost], [Handles categorical features natively with label statistics computed in a careful order to avoid leakage.], [Notably strong when the data contains many categorical columns.],
  )]
  , kind: table
  )

The hyperparameters that matter most, in rough order: number of trees (via early stopping), learning rate, tree depth or leaf count, and the row/column subsampling fractions.


#heading(level: 2)[Bagging and boosting, side by side]
 <sec:bagging-vs-boosting>

Bagging fits independently and can run in parallel; boosting fits sequential corrections.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/4371b6c3c6a2a22e.cetz.json")], caption: [Bagging fits trees in parallel on independent samples and reduces variance; boosting fits them in sequence, each correcting the remaining errors, and reduces bias.]) <fig:bagging-boosting>

#callout("keyidea", title: [Key idea])[Bagging often uses deep trees; boosting often uses shallow trees. Validate depth, leaf size, learning rate, and rounds together.]


#heading(level: 2)[Voting and stacking]


#strong[Voting] combines models by majority labels or averaged probabilities. #strong[Stacking] trains a #strong[meta-model] on base predictions to learn their combination.

Train the meta-model on #strong[out-of-fold] base predictions, not predictions fitted to those same rows. Otherwise it learns from overfitted outputs. Linear or logistic meta-models are common.


#heading(level: 2)[Practical ensemble workflow]


- Want a strong tabular model with minimal fuss? #strong[Random forest].

- Chasing the best accuracy and willing to tune? #strong[Gradient boosting] with early stopping.

- Noisy labels? Prefer forests over AdaBoost-style boosting, or lower the boosting learning rate and depth.

- Stack diverse models only when out-of-fold validation justifies the added maintenance.

#callout("workedexample", title: [Worked example])[Lab~3 compares both families under one protocol. On used-car prices (log price, three folds), boosting has a log-RMSE of 0.1941 and the forest 0.2083, and boosting wins on every fold, by ten times more than the folds differ from each other. On Lab~3's loans the order flips: the forest ranks defaults a little better, with ROC AUC 0.733 against 0.728 and average precision 0.393 against 0.389, a gap no larger than the noise between runs. No family wins everywhere, and sometimes not even on every metric.]

#callout("keyidea", title: [Key idea])[Bagging averages varied trees; boosting adds dependent corrections. Judge their gains against latency, interpretability, and maintenance costs.]

#callout("modelcard", title: [Tree Ensembles - Quick Guide])[#block[
ll l

& Random forest & Gradient boosting \
Core idea & Average many varied trees & Add shallow trees sequentially to repair errors Usually strong for & Reliable general-purpose tabular prediction & High predictive accuracy on structured/tabular data Main controls & Number of trees, sampled features, depth, leaf size & Number of trees, learning rate, depth, subsampling Main risks & Large models, less transparent than one tree & Overfitting through too many rounds, sensitive tuning, slower training

]]


#heading(level: 3)[Controls worth tuning]


Random forests are usually forgiving: start with enough trees for stable averages, then control individual-tree complexity with depth, leaf size, and the number of features considered at each split. Gradient boosting is more sensitive because learning rate and number of rounds trade off directly. The table below is a practical starting range, not a universal recipe.

#callout("pitfall", title: [Common mistake])[Early-stopping validation must preserve time or group structure. Supply an appropriately separated validation set or tune rounds with structure-preserving folds.]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Setting], [Try], [Effect],),
    table.hline(),
    [learning\_rate], [0.01--0.1], [Smaller learns more carefully; needs more trees.],
    [n\_estimators], [300--2000], [With early stopping, set it generously.],
    [max\_depth], [3--8], [Deeper catches interactions but overfits sooner.],
    [subsample], [0.6--1.0], [Row sampling; adds randomness, fights overfitting.],
    [colsample\_bytree], [0.6--1.0], [Column sampling; same idea, per feature.],
    [reg\_lambda], [0--10], [Extra penalty on leaf values.],
  )]
  , kind: table
  )


#heading(level: 3)[When combining model families helps]


#callout("intuition", title: [Plain idea])[Stacking can adapt model weights to different cases, but the extra layer needs sufficient data and out-of-fold training.]

#callout("pitfall", title: [Common mistake])[Combine individually useful, non-redundant models, such as a linear model and a forest. Keep the ensemble only if validation gains justify its complexity.]


#heading(level: 2)[Inspecting ensemble predictions]
 <sec:ensemble-interpretability>

Use permutation importance (#ref(label("sec:tree-feature-importance"), supplement: [Section])), partial dependence, or SHAP to describe model behavior, not causal effects.

Correlated features can mask permutation importance. Partial dependence averages predictions as one feature varies, potentially creating implausible combinations.


#heading(level: 3)[Optional: SHAP for local explanations]


#strong[SHAP] (SHapley Additive exPlanations) decomposes a prediction relative to a reference output: $ hat(y)_i = bb(E) \[ hat(y) \] + sum_(j = 1)^p phi.alt_(i j) . $ $phi.alt_(i j)$ attributes row $i$'s departure from the reference output. Correlated features can redistribute attribution; check stability.

Apply the association-versus-causation distinction from #ref(label("sec:correlation"), supplement: [Section]): an explanation can reveal what the model used without proving what would happen under an intervention.


#heading(level: 2)[Ensemble comparison at a glance]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Method], [What changes from one tree], [Main reason to try it],),
    table.hline(),
    [Bagging], [Bootstrap many trees and average/vote], [Reduce variance and make a high-variance learner more stable],
    [Random Forest], [Bagging plus random feature subsets at splits], [Make the trees less correlated, so averaging helps more],
    [AdaBoost], [Train weak learners sequentially with emphasis on previous errors], [Reduce bias by focusing later learners on difficult cases],
    [Soft voting], [Average probabilities from different model families], [Combine complementary decision rules rather than many copies of one rule],
  )]
  , kind: table
  )

#callout("tryit", title: [Try it yourself])[Compare a single tree, a random forest, and a gradient-boosting model with the same cross-validation splits. Record mean validation score, descriptive fold spread, fit time, and prediction time. Decide whether any gain justifies the added cost, then evaluate the locked choice on the test set once.]

#callout("chapterrecap", title: [Chapter recap])[- Averaging cancels errors only if members disagree. Correlation sets a floor that more models cannot get below.

- Bagging fits trees independently on bootstrap samples, each of which misses about 36.8% of the rows, giving a free out-of-bag estimate. Forests add random feature subsets to force more disagreement.

- Boosting adds shallow trees in sequence. AdaBoost reweights hard rows; gradient boosting fits residuals with a learning rate.

- Forests are forgiving; boosting is often stronger and needs tuning and early stopping. Neither wins everywhere, as Lab~3's car prices and loans show.

- Keep the ensemble only if a validated gain justifies its cost.]

#callout("quickcheck", title: [Check your understanding])[+ How does bagging reduce variance, and how does boosting differ in the way later learners are constructed?

+ With $rho = 0.25$ and $B = 100$, what fraction of one model's variance does the average keep?

+ Why does a random forest consider only a subset of features at many splits?

+ A weak learner has weighted error 0.1. What is its say $alpha$, and by what factor do misclassified weights grow before renormalizing?

+ In gradient boosting with $nu = 0.5$, a row has prediction 7 and label 10, and the next tree predicts its residual exactly. What is the new prediction?

+ Why must predictions used to train a stacking meta-model be out-of-fold rather than fitted predictions from the same rows?]
