#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "16-ensemble-methods")

= Ensemble Methods <ch:ensembles>

#chapterguide[Decision trees from #chapref(<ch:decision-trees>) and the bias--variance ideas from #chapref(<ch:training>).][explain why averaging helps and when it stops helping; bootstrap and compute an out-of-bag fraction; run one round of AdaBoost and several rounds of gradient boosting by hand; choose between forests and boosting; and validate whether the added complexity pays.]

Ask one person to guess how many sweets are in a jar, and they may be far off. Average the guesses of a whole room, and the answer is often uncannily close, because the high guesses and the low guesses cancel. An #term[ensemble] applies this to models: combine many whose errors differ, and the mistakes partly cancel. Random forests and boosted trees are among the strongest tools for tabular data, and they rest on two different ways of getting that difference.

== Why averaging helps

#workedexample[
  A simulated jar holds 200 sweets, and each guesser’s error has a standard deviation of 40. Over 10,000 simulated rooms, one guesser misses by 31.6 sweets on average, while a crowd of 25 misses by 6.4. The standard deviation of the crowd’s average is 8.0, which is $40\/sqrt(25)$.

  Now let someone announce a wrong number first, so that the whole room is swayed in the same direction. The guesses are as noisy as before, but they now share part of their error. The swayed crowd’s standard deviation is 30.3, hardly better than one person. A crowd helps only if its members make different mistakes.
]

For $B$ models with error variance $sigma ^2$, independent errors give average variance $sigma ^2\/B$. With average pairwise correlation $rho$, it is approximately

$ rho thin sigma ^2+frac((1- rho ), B) thin sigma ^2 . $

Adding models shrinks the second term, not the correlation floor. At $rho =0$ and $B=25$ the average has 0.04 of one model’s variance. At $rho =0.5$ it has 0.52, and adding models up to $B=1000$ only reaches 0.50. So the art of ensembles is making members that disagree. #term[Bagging] gets diversity from independent fits on perturbed data, and #term[boosting] from sequential corrections.

== Bagging: bootstrap aggregating

Bagging fits learners to #term[bootstrap samples]: $n$ draws with replacement from the $n$ rows. Each sample repeats some rows and leaves others out. A given row is missed by one draw with probability $1-1\/n$, and by all $n$ draws with probability $(1-1\/n)^n approx e^(-1)$. So each tree misses about 36.8% of the rows; in a simulation on 1,000 rows the fraction is 0.368. Deep trees are common base learners, and predictions are combined by voting or averaging.

#utpfig([Bagging. Each tree is fitted to its own bootstrap sample of the training data, and their predictions are combined by voting or averaging.], label: <fig:bagging>)[
  #canvas({
    let box-style = (draw: auto, rounded: 1.9925pt, align: center, min-height: 0.8461, min-width: 2.4614, inner-sep: 2.9888pt, fill: pale-blue)
    let arr = (line-width: widths.thick, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [training data \
  ($n$ observations)], name: "data", font: font("small"), ..box-style)
    node(right-of("data", 1.05), [bootstrap \
  sample 1], name: "s1", font: font("small"), ..box-style, yshift: 1.35cm)
    node(right-of("data", 1.05), [bootstrap \
  sample 2], name: "s2", font: font("small"), ..box-style)
    node(right-of("data", 1.05), [bootstrap \
  sample $B$], name: "s3", font: font("small"), ..box-style, yshift: -1.35cm)
    node(right-of("s1", 1.05), [tree 1], name: "t1", font: font("small"), ..box-style)
    node(right-of("s2", 1.05), [tree 2], name: "t2", font: font("small"), ..box-style)
    node(right-of("s3", 1.05), [tree $B$], name: "t3", font: font("small"), ..box-style)
    node(right-of("t2", 1.05), [vote / \
  average], name: "agg", font: font("small"), ..box-style)
    connect("data", "s1", ..arr)
    connect("data", "s2", ..arr)
    connect("data", "s3", ..arr)
    connect("s1", "t1", ..arr)
    connect("s2", "t2", ..arr)
    connect("s3", "t3", ..arr)
    connect("t1", "agg", ..arr)
    connect("t2", "agg", ..arr)
    connect("t3", "agg", ..arr)
    node(("s2", 50%, "s3"), [$dots.v$], font: font("small"))
    node(("t2", 50%, "t3"), [$dots.v$], font: font("small"))
  })
]

Each row can be predicted by the trees that never saw it; the resulting #term[out-of-bag (OOB)] score is a free validation estimate. Use it as a validation signal for choosing settings, not as a replacement for the final test.

== Random forests <sec:random-forest>

If one feature is very strong, every bagged tree asks about it first, and the trees end up alike, with a high $rho$. A #term[random forest] therefore lets each split consider only a random subset of features, which forces the trees to differ. $sqrt(p)$ features is a common starting point for classification; validate the fraction for regression and other settings.

#workedexample[
  On Lab~2’s 7,043 telecom customers, under the same five folds, one unrestricted tree averages 0.731 accuracy. A forest of 300 such trees averages 0.793. The fold spreads are 0.010 and 0.009, so the gain is about six standard deviations: the averaging has removed most of what the single tree memorized. It cost you the readable rules of a single tree, and some prediction time.
]

Practical profile:

- #term[Key hyperparameters:] the number of trees $B$ (more trees make the average steadier until the gain flattens out), the number of features tried per split, and tree depth or minimum leaf size.
- #term[Little tuning required:] sensible defaults perform well, which makes random forests the standard “strong model with ten minutes of effort” on tabular data.
- #term[Extras:] OOB error estimates and feature-importance rankings come nearly free; apply the importance caveat from #secref(<sec:tree-feature-importance>).
- #term[Costs:] the model is large, slower to predict than a single tree, and no longer readable as rules.

=== Extra Trees: randomize the split thresholds too <sec:extra-trees>

#term[Extremely Randomized Trees] (Extra Trees) go one step further than a forest: at each split they draw the candidate thresholds at random instead of searching for the best one, and by default they use the whole training set rather than a bootstrap sample. The extra randomness lowers variance and training time at the cost of a little bias.

Compare Extra Trees with Random Forest under the same folds and metric. Neither is universally better; the useful lesson is that both trade individual-tree strength for diversity across the ensemble.

#recipecard([Random forest], [Many deep trees, each on its own bootstrap sample and with random feature subsets at each split.], [Each tree reduces Gini or squared error; the ensemble just averages.], [Greedy tree growth, repeated independently. Trees can be fitted in parallel.])

== Boosting: learning from mistakes

#analogy[
  Think of a relay of tutors. The first teaches the whole class and notes which questions students still get wrong. The second concentrates on exactly those. The third concentrates on what is left. No single tutor is impressive, but the class improves at every handover. Boosting adds #term[weak learners], often shallow trees, in sequence, each one correcting the current ensemble.
]

#utptable[
  #tabularx(
    columns: (26%, 31%, 31%),
    valign: (top, top, top),
    header: ([], [Bagging / random forest], [Boosting]),
    [Training], [Parallel, independent], [Sequential, each model depends on the last],
    [Base models], [Fully grown, low-bias, high-variance trees], [Shallow, high-bias, low-variance trees],
    [Main effect], [Reduces variance], [Reduces bias (and variance via shrinkage)],
    [Overfitting risk], [Low; robust to noise], [Real; needs a learning rate and early stopping],
    [Tuning effort], [Small], [Moderate to large],
  )
]

=== AdaBoost: reweight the hard cases <sec:adaboost>

AdaBoost repeatedly increases the weights of misclassified observations:

+ Start with equal weights $w_i=1\/n$.
+ Fit a weak learner $h_m$ to the weighted data and compute its weighted error rate $epsilon _m$.
+ Give the learner a say proportional to its quality:

  $ alpha _m=inline(frac(1, 2))ln frac(1- epsilon _m, epsilon _m). $
+ Multiply misclassified weights by $e^(alpha _m)$ and correct weights by $e^(- alpha _m)$, then renormalize.
+ After $M$ rounds, predict with the weighted vote $op("sign")( sum _m alpha _m h_m(bold(x)))$.

#workedexample[
  Five rows with equal weights of 0.2. A weak rule gets four right and misclassifies row 5, so its weighted error is $epsilon =0.20$ and its say is $alpha =inline(frac(1, 2))ln(0.8\/0.2)=0.693$. Multiply the four correct weights by $e^(-0.693)=0.5$, giving 0.1 each, and the wrong one by $e^0.693=2$, giving 0.4. They now sum to 0.8, so renormalize: the four correct rows get 0.125 each, and row 5 gets 0.5. Row 5 alone now counts as much as all the others together, so the next learner has to get it right.
]

At $epsilon _m=0.3$, $alpha _m approx 0.42$, which multiplies misclassified weights by about $1.5$. A chance learner with $epsilon _m=0.5$ gets no vote. Repeated emphasis on mislabeled cases makes AdaBoost sensitive to label noise.

=== Gradient boosting: fit the residuals <sec:gradient-boosting>

Gradient boosting fits $h_m$ to the negative loss gradient at current predictions. For squared loss this is the residual $y_i-F_(m-1)(bold(x)_i)$. Update by

$ F_m(bold(x)) =F_(m-1)(bold(x))+ nu thin h_m(bold(x)), wide 0< nu <= 1. $

The learning rate $nu$ scales each correction. Tune it jointly with tree count, using validation or early stopping.

#workedexample[
  For $y=(3,5,8,10)$, start at the mean, $F_0=6.5$, so the residuals are $(-3.5,-1.5,1.5,3.5)$. A one-split stump on those residuals groups the first two rows and the last two, predicting $-2.5$ and $+2.5$. With $nu =0.5$ only half of that is admitted, and the process repeats on what remains:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (center, center, center, center, center, center),
    header: ([Round], multicolumn(4, center, style: (weight: "bold", fill: navy))[#strong[#text(fill: navy)[Predictions for $y=3,5,8,10$]]], [MSE]),
    [0], [6.500], [6.500], [6.500], [6.500], [7.250],
    [1], [5.250], [5.250], [7.750], [7.750], [2.562],
    [2], [4.125], [5.625], [8.125], [8.125], [1.297],
    [3], [3.812], [5.312], [7.812], [9.062], [0.418],
    [4], [3.531], [5.031], [8.094], [9.344], [0.181],
    [5], [3.422], [4.922], [7.984], [9.672], [0.073],
    [6], [3.211], [4.992], [8.055], [9.742], [0.029],
  )

  #raggedright[
  #v(6pt)
  Each tree is weak on its own. Together, six of them have nearly memorized four rows, which is exactly why boosting needs early stopping on real data.
  ]]]
]

#utpfig([Gradient boosting on the worked example. Round 0 predicts the mean; one stump with learning rate $nu =0.5$ shrinks every residual towards zero.], label: <fig:boosting-residuals>)[
  #canvas({
    let ax = (draw: mix(muted, 55%), line-width: widths.semithick)
    let obs = (shape: "circle", fill: navy, inner-sep: 1.4944pt)
    let fit-style = (draw: blue, line-width: 1.0959pt)
    let resid = (draw: red, line-width: widths.semithick, end: tip("Stealth", length: 1.7mm, line: widths.semithick))
    let rl = (font: font("tiny", fill: red),)
    let hd = (font: font("small", weight: "bold", fill: navy),)
    let yl = (font: font("tiny", fill: muted), anchor: "east")
    node((1.9, 4.35), [Round 0: predict the mean], font: font("small"), ..hd)
    connect((0.3, 0), (0.3, 3.95), ..ax)
    connect((0.3, 0), (3.55, 0), ..ax)
    for (vv, cy) in ((3, 0.42), (5, 1.26), (8, 2.52), (10, 3.36)) {
      node((0.22, cy), [#vv], font: font("small"), ..yl)
    }
    connect((0.45, 1.89), (3.35, 1.89), ..fit-style)
    node((3.4, 1.89), [$F_0=6.5$], font: font("tiny", fill: blue), anchor: "west")
    connect((0.7, 1.89), (0.7, 0.5), ..resid)
    connect((1.5, 1.89), (1.5, 1.34), ..resid)
    connect((2.3, 1.89), (2.3, 2.44), ..resid)
    connect((3.1, 1.89), (3.1, 3.28), ..resid)
    node((0.78, 0.86), [$-3.5$], font: font("small"), ..rl, anchor: "west")
    node((1.58, 1.62), [$-1.5$], font: font("small"), ..rl, anchor: "west")
    node((2.38, 2.16), [$+1.5$], font: font("small"), ..rl, anchor: "west")
    node((3.18, 2.62), [$+3.5$], font: font("small"), ..rl, anchor: "west")
    for (cx, cy) in ((0.7, 0.42), (1.5, 1.26), (2.3, 2.52), (3.1, 3.36)) {
      node((cx, cy), [], font: font("small"), ..obs)
    }
    draw.scope({
      draw.translate((7, 0))
      node((1.9, 4.35), [After round 1, with $nu =0.5$], font: font("small"), ..hd)
      connect((0.3, 0), (0.3, 3.95), ..ax)
      connect((0.3, 0), (3.55, 0), ..ax)
      for (vv, cy) in ((3, 0.42), (5, 1.26), (8, 2.52), (10, 3.36)) {
        node((0.22, cy), [#vv], font: font("small"), ..yl)
      }
      connect((0.45, 1.365), (1.9, 1.365), ..fit-style)
      connect((1.9, 2.415), (3.35, 2.415), ..fit-style)
      connect((1.9, 1.365), (1.9, 2.415), ..fit-style, dash: "dashed")
      node((3.4, 2.415), [$F_1$], font: font("tiny", fill: blue), anchor: "west")
      connect((0.7, 1.365), (0.7, 0.5), ..resid)
      connect((1.5, 1.365), (1.5, 1.34), ..resid)
      connect((2.3, 2.415), (2.3, 2.44), ..resid)
      connect((3.1, 2.415), (3.1, 3.28), ..resid)
      node((0.78, 0.66), [$-2.25$], font: font("small"), ..rl, anchor: "west")
      node((1.5, 1.16), [$-0.25$], font: font("small"), ..rl, anchor: "north")
      node((2.38, 2.05), [$+0.25$], font: font("small"), ..rl, anchor: "west")
      node((3.18, 2.85), [$+2.25$], font: font("small"), ..rl, anchor: "west")
      for (cx, cy) in ((0.7, 0.42), (1.5, 1.26), (2.3, 2.52), (3.1, 3.36)) {
        node((cx, cy), [], font: font("small"), ..obs)
      }
    })
    node((5.4, -0.85), [The stump is never fitted to the labels --- it is fitted to the red arrows. One split separates the first two observations from the last two and predicts their residual means, $-2.5$ and $+2.5$; the learning rate admits only half of that, so every residual shrinks but none is erased. A hundred such corrections trace the data closely.], font: font("script", fill: ink), align: center, text-width: 12.5)
  })
]

#intuition[
  Gradient boosting fits corrections; AdaBoost reweights mistakes. Both train sequentially.
]

#recipecard([Gradient boosting], [A sum of many shallow trees, each scaled by a learning rate.], [Any differentiable loss, such as squared error or log loss.], [Gradient descent in function space: each new tree fits the negative gradient of the loss at the current predictions.])

=== Modern gradient-boosting libraries

Three refinements of gradient boosting dominate practical work; all keep the algorithm above and add engineering and regularization:

#utptable[
  #tabularx(
    columns: (18%, 46%, 1fr),
    styles: (navy-bold,),
    header: ([Library], [Distinctive approach], [Practical strength]),
    [XGBoost], [Adds explicit regularization of tree size and leaf values to the objective and uses second-derivative information for better splits.], [Popularized the modern toolkit, including early stopping and column subsampling.],
    [LightGBM], [Grows trees leaf-wise instead of level-wise and buckets feature values into histograms.], [Extremely fast on large datasets.],
    [CatBoost], [Handles categorical features natively with label statistics computed in a careful order to avoid leakage.], [Notably strong when the data contains many categorical columns.],
  )
]

The hyperparameters that matter most, in rough order: number of trees (via early stopping), learning rate, tree depth or leaf count, and the row/column subsampling fractions.

== Bagging and boosting, side by side <sec:bagging-vs-boosting>

Bagging fits independently and can run in parallel; boosting fits sequential corrections.

#utpfig([Bagging fits trees in parallel on independent samples and reduces variance; boosting fits them in sequence, each correcting the remaining errors, and reduces bias.], label: <fig:bagging-boosting>)[
  #canvas({
    let t = (draw: blue, fill: pale-blue, rounded: 1.2mm, min-width: 1.45, min-height: 0.55, align: center, font: font("script", weight: "bold", fill: navy))
    let tb = (draw: orange, fill: pale-orange, rounded: 1.2mm, min-width: 1.45, min-height: 0.55, align: center, font: font("script", weight: "bold", fill: navy))
    let d = (draw: muted, fill: pale-gray, rounded: 1.2mm, min-width: 1.1, min-height: 0.5, align: center, font: font("tiny", fill: navy))
    let agg = (draw: green, fill: pale-teal, rounded: 1.5mm, min-width: 1.5, min-height: 1.9, align: center, font: font("script", weight: "bold", fill: navy))
    let result = (draw: green, fill: pale-teal, rounded: 1.2mm, min-width: 1.15, min-height: 0.55, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    let arro = (line-width: widths.thick, draw: orange, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    node((0, 2.55), [Bagging: parallel and independent], name: "hb", font: font("small", weight: "bold", fill: navy))
    node((-1.3, 1.85), [sample 1], name: "d1", ..d)
    node((-1.3, 1.15), [sample 2], name: "d2", ..d)
    node((-1.3, 0.45), [sample 3], name: "d3", ..d)
    node((0.55, 1.85), [tree 1], name: "t1", ..t)
    node((0.55, 1.15), [tree 2], name: "t2", ..t)
    node((0.55, 0.45), [tree 3], name: "t3", ..t)
    node((2.5, 1.15), [average \
  or vote], name: "av", ..agg)
    connect("d1", "t1", ..arr)
    connect("d2", "t2", ..arr)
    connect("d3", "t3", ..arr)
    connect("t1", "av", ..arr)
    connect("t2", "av", ..arr)
    connect("t3", "av", ..arr)
    node((0.6, -0.2), [reduces variance], font: font("script", style: "italic", fill: muted))
    node((8.85, 2.55), [Boosting: sequential and corrective], name: "hs", font: font("small", weight: "bold", fill: navy))
    node((5.75, 1.45), [tree 1], name: "b1", ..tb)
    node((8.05, 1.45), [tree 2], name: "b2", ..tb)
    node((10.35, 1.45), [tree 3], name: "b3", ..tb)
    node((12.15, 1.45), [weighted \
  sum], name: "sum", ..result)
    connect("b1.east", "b2.west", ..arro)
    connect("b2.east", "b3.west", ..arro)
    connect("b3.east", "sum.west", ..arro)
    node((6.9, 0.88), [fit remaining \
  errors], font: font("tiny", fill: red), align: center)
    node((9.2, 0.88), [fit remaining \
  errors], font: font("tiny", fill: red), align: center)
    node((8.85, -0.2), [reduces bias], font: font("script", style: "italic", fill: muted))
  })
]

#keyidea[
  Bagging often uses deep trees; boosting often uses shallow trees. Validate depth, leaf size, learning rate, and rounds together.
]

== Voting and stacking

#term[Voting] combines models by majority labels or averaged probabilities. #term[Stacking] trains a #term[meta-model] on base predictions to learn their combination.

Train the meta-model on #term[out-of-fold] base predictions, not predictions fitted to those same rows. Otherwise it learns from overfitted outputs. Linear or logistic meta-models are common.

== Practical ensemble workflow

- Want a strong tabular model with minimal fuss? #term[Random forest].
- Chasing the best accuracy and willing to tune? #term[Gradient boosting] with early stopping.
- Noisy labels? Prefer forests over AdaBoost-style boosting, or lower the boosting learning rate and depth.
- Stack diverse models only when out-of-fold validation justifies the added maintenance.

#workedexample[
  Lab~3 compares both families under one protocol. On used-car prices (log price, three folds), boosting has a log-RMSE of 0.1941 and the forest 0.2083, and boosting wins on every fold, by ten times more than the folds differ from each other. On Lab~3’s loans the order flips: the forest ranks defaults a little better, with ROC AUC 0.733 against 0.728 and average precision 0.393 against 0.389, a gap no larger than the noise between runs. No family wins everywhere, and sometimes not even on every metric.
]

#keyidea[
  Bagging averages varied trees; boosting adds dependent corrections. Judge their gains against latency, interpretability, and maintenance costs.
]

#modelcard[Tree Ensembles - Quick Guide][
  #tabularx(
    columns: (22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([], [Random forest], [Gradient boosting]),
    [Core idea], [Average many varied trees], [Add shallow trees sequentially to repair errors],
    [Usually strong for], [Reliable general-purpose tabular prediction], [High predictive accuracy on structured/tabular data],
    [Main controls], [Number of trees, sampled features, depth, leaf size], [Number of trees, learning rate, depth, subsampling],
    [Main risks], [Large models, less transparent than one tree], [Overfitting through too many rounds, sensitive tuning, slower training],
  )
]

=== Controls worth tuning

Random forests are usually forgiving: start with enough trees for stable averages, then control individual-tree complexity with depth, leaf size, and the number of features considered at each split. Gradient boosting is more sensitive because learning rate and number of rounds trade off directly. The table below is a practical starting range, not a universal recipe.

#pitfall[
  Early-stopping validation must preserve time or group structure. Supply an appropriately separated validation set or tune rounds with structure-preserving folds.
]

#utptable[
  #tabularx(
    columns: (21%, 16%, 1fr),
    styles: ((weight: "bold", fill: navy, font: "Source Code Pro", size: 0.88em),),
    header: ([Setting], [Try], [Effect]),
    [learning\_rate], [0.01--0.1], [Smaller learns more carefully; needs more trees.],
    [n\_estimators], [300--2000], [With early stopping, set it generously.],
    [max\_depth], [3--8], [Deeper catches interactions but overfits sooner.],
    [subsample], [0.6--1.0], [Row sampling; adds randomness, fights overfitting.],
    [colsample\_bytree], [0.6--1.0], [Column sampling; same idea, per feature.],
    [reg\_lambda], [0--10], [Extra penalty on leaf values.],
  )
]

=== When combining model families helps

#intuition[
  Stacking can adapt model weights to different cases, but the extra layer needs sufficient data and out-of-fold training.
]

#pitfall[
  Combine individually useful, non-redundant models, such as a linear model and a forest. Keep the ensemble only if validation gains justify its complexity.
]

== Inspecting ensemble predictions <sec:ensemble-interpretability>

Use permutation importance (#secref(<sec:tree-feature-importance>)), partial dependence, or SHAP to describe model behavior, not causal effects.

Correlated features can mask permutation importance. Partial dependence averages predictions as one feature varies, potentially creating implausible combinations.

=== Optional: SHAP for local explanations

#term[SHAP] (SHapley Additive exPlanations) decomposes a prediction relative to a reference output:

$ hat(y)_i = bb(E)[hat(y)] + sum _(j=1)^p phi.alt _(i j). $

$phi.alt _(i j)$ attributes row $i$’s departure from the reference output. Correlated features can redistribute attribution; check stability.

Apply the association-versus-causation distinction from #secref(<sec:correlation>): an explanation can reveal what the model used without proving what would happen under an intervention.

#keepspace(189.7pt)

== Ensemble comparison at a glance

#utptable[
  #tabularx(
    columns: (22%, 25%, 1fr),
    styles: (navy-bold,),
    header: ([Method], [What changes from one tree], [Main reason to try it]),
    [Bagging], [Bootstrap many trees and average/vote], [Reduce variance and make a high-variance learner more stable],
    [Random Forest], [Bagging plus random feature subsets at splits], [Make the trees less correlated, so averaging helps more],
    [AdaBoost], [Train weak learners sequentially with emphasis on previous errors], [Reduce bias by focusing later learners on difficult cases],
    [Soft voting], [Average probabilities from different model families], [Combine complementary decision rules rather than many copies of one rule],
  )
]

#tryit[
  Compare a single tree, a random forest and gradient boosting on the same cross-validation splits: mean score, fold spread, fit time and prediction time. Does any gain justify its cost? Then test the locked choice once.
]

#chapterrecap[
  - Averaging cancels errors only if members disagree. Correlation sets a floor that more models cannot get below.
  - Bagging fits trees on bootstrap samples; each misses about 36.8% of the rows, which gives a free out-of-bag estimate. Forests add random feature subsets for more disagreement.
  - Boosting adds shallow trees in sequence. AdaBoost reweights hard rows; gradient boosting fits residuals with a learning rate.
  - Forests are forgiving; boosting is often stronger and needs tuning and early stopping. Neither wins everywhere, as Lab~3’s car prices and loans show.
  - Keep the ensemble only if a validated gain justifies its cost.
]

#quickcheck[
  + How does bagging reduce variance, and how does boosting build its later learners differently?
  + With $rho =0.25$ and $B=100$, what fraction of one model’s variance does the average keep?
  + Why does a random forest consider only a subset of features at many splits?
  + A weak learner has weighted error 0.1. What is its say $alpha$, and by what factor do misclassified weights grow before renormalizing?
  + In gradient boosting with $nu =0.5$, a row has prediction 7 and label 10, and the next tree predicts its residual exactly. What is the new prediction?
  + Why must predictions used to train a stacking meta-model be out-of-fold rather than fitted predictions from the same rows?
]
