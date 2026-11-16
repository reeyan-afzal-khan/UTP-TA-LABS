#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "15-decision-trees")

= Decision Trees <ch:decision-trees>

#chapterguide[#chapref(<ch:training>) plus basic probability from #chapref(<ch:foundations>)\; entropy is helpful but re-explained here.][compute Gini impurity and information gain by hand; choose a split on real counts; read a fitted tree as rules; control depth and pruning; and treat feature importance with care.]

In the game of Twenty Questions you never ask “is it a giraffe?” first. You ask a question that splits the possibilities well, such as “is it alive?”, and then ask the next one depending on the answer. A decision tree plays that game with a table. It routes each row through questions such as “age below 30?” until it reaches a #term[leaf], which holds the prediction. Small trees can be read aloud, and forests and boosting combine many of them into stronger models (#chapref(<ch:ensembles>)).

#utpfig([A small decision tree. Each internal node asks one question about one feature, and each leaf makes a prediction.], label: <fig:tree-example>)[
  #canvas({
    let qnode = (draw: auto, rounded: 1.9925pt, align: center, fill: pale-blue, inner-sep: 3.9851pt)
    let leaf = (draw: auto, align: center, inner-sep: 3.9851pt)
    node((0, 0), [age $<30$?], name: "tree-1", font: font("small"), ..qnode)
    node((rel: (-2.3, -1.35), to: "tree-1"), [income $>= 50$k?], name: "tree-2", font: font("small"), ..qnode)
    connect("tree-1", "tree-2", draw: auto, end: arrow-tip("Stealth", length: 1.8mm, line: 0.4pt))
    node(along("tree-1", "tree-2", t: 50%), [yes], font: font("small"), xshift: -1.9925pt, anchor: "east")
    node((rel: (-1.2, -1.35), to: "tree-2"), [predict: \
  approve], name: "tree-3", font: font("small"), ..leaf)
    connect("tree-2", "tree-3", draw: auto, end: arrow-tip("Stealth", length: 1.8mm, line: 0.4pt))
    node(along("tree-2", "tree-3", t: 50%), [yes], font: font("small"), xshift: -0.9963pt, anchor: "east")
    node((rel: (1.2, -1.35), to: "tree-2"), [predict: \
  review], name: "tree-4", font: font("small"), ..leaf)
    connect("tree-2", "tree-4", draw: auto, end: arrow-tip("Stealth", length: 1.8mm, line: 0.4pt))
    node(along("tree-2", "tree-4", t: 50%), [no], font: font("small"), xshift: 0.9963pt, anchor: "west")
    node((rel: (2.3, -1.35), to: "tree-1"), [predict: \
  approve], name: "tree-5", font: font("small"), ..leaf)
    connect("tree-1", "tree-5", draw: auto, end: arrow-tip("Stealth", length: 1.8mm, line: 0.4pt))
    node(along("tree-1", "tree-5", t: 50%), [no], font: font("small"), xshift: 1.9925pt, anchor: "west")
  })
]

== How a tree is grown <sec:decision-tree>

Standard tree learning (the CART algorithm) is #term[greedy and recursive]:

+ At the current node, consider candidate splits: for a numerical feature, thresholds between sorted values; for categorical features, the rules depend on the implementation; scikit-learn expects them one-hot encoded, which is what Lab~3 does.
+ Score each candidate by how much it #emph[purifies] the data --- how well it separates the classes (or, for regression, how much it shrinks the spread of the label).
+ Apply the best split, sending observations left and right.
+ Repeat on each child until a stopping rule fires; each final node becomes a leaf that predicts its majority class (classification) or mean label (regression).

Greedy means the algorithm never looks ahead or reconsiders: it takes the best immediate split at every step. That keeps training fast and usually works well, though it does not guarantee the globally best tree.

== Measuring impurity

Picture a bag of red and blue marbles. A bag of one color is pure, so you can name the color of the next marble with no doubt. A half-and-half bag is as mixed as it gets. A good question pours one mixed bag into two bags, each purer than the original.

To pick a split, the algorithm needs a number for “how mixed is this node?” With $p_k$ the fraction of class $k$ in a node, two standard measures are the #term[Gini impurity] and the #term[entropy]:

$ G=1- sum _(k=1)^K p_k^2, wide H=- sum _(k=1)^K p_k log_2 p_k. $

Both are zero for a pure node (one class only) and largest for a perfect mixture. Gini reads as “the probability of mislabeling a random point if labels were assigned according to the node’s class mix”; entropy reads as “how many yes/no questions of uncertainty remain.” A split is chosen to maximize the #term[information gain]: the parent’s impurity minus the size-weighted impurity of the children,

$ op("Gain") =I("parent") -frac(n_(upright("left")), n)I("left") -frac(n_(upright("right")), n)I("right"), $

where $I$ is either measure. Gini and entropy almost always agree on the best split; Gini is slightly cheaper to compute and is the common default.

#example[
  A node holds 10 loan applications: 6 approved ($+$) and 4 rejected ($-$). Its Gini impurity is
  $G_("parent")=1-(0.6^2+0.4^2)=0.48$.

  #emph[Candidate split A] produces children $[4+,0-]$ and $[2+,4-]$:

  $ G_("left")=0, wide G_("right")=1-[((inline(frac(1, 3))))^2+((inline(frac(2, 3))))^2]=inline(frac(4, 9)) approx 0.444, $

  $ op("Gain")_A =0.48-(inline(frac(4, 10)) times 0+inline(frac(6, 10)) times 0.444) =0.48-0.267=0.213. $

  #emph[Candidate split B] produces children $[3+,2-]$ and $[3+,2-]$. Each child has the same $60\/40$ mix as the parent, so each has $G=0.48$, the weighted impurity is unchanged, and $op("Gain")_B=0$: split B tells us nothing, and split A wins. (Entropy agrees: split A’s gain is $0.971-0.551 approx 0.42$ bits.)
]

== Finding the best split, on real data

Evaluate every candidate question, and keep the one with the largest weighted drop in impurity. If a threshold separated two classes perfectly, both children would be pure and the gain would equal the parent’s impurity.

#keepspace(216.8pt)

#example[
  The 7,043 telecom customers of Labs~1 and~2 include 5,174 who stayed and 1,869 who left, so their Gini is $1-(0.735^2+0.265^2)=0.390$. Four candidate first questions:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    header: ([Question], [Yes: stayed, left], [Gini], [No: stayed, left], [Gini], [Gain]),
    [Month-to-month contract?], [2,220, 1,655], [0.489], [2,954, 214], [0.126], [#strong[0.064]],
    [Tenure at most 12 months?], [1,149, 1,037], [0.499], [4,025, 832], [0.284], [0.039],
    [Fibre internet?], [1,799, 1,297], [0.487], [3,375, 572], [0.248], [0.037],
    [Pays by electronic check?], [1,294, 1,071], [0.496], [3,880, 798], [0.283], [0.036],
  )

  #raggedright[
  #v(6pt)
  Check the first row: 3,875 customers on month-to-month contracts and 3,168 on longer ones, so the weighted child impurity is $frac(3875, 7043)(0.489)+frac(3168, 7043)(0.126)=0.326$, and the gain is $0.390-0.326=0.064$. The contract wins clearly: nearly nine in ten of the customers who left were free to go at a month’s notice, so a tree asks it first. Then the same search repeats inside each child. Lab~3 runs this search on personal loans, and the questions it chooses turn out to be the lender’s own interest rate and the length of the loan.
  ]]]
]

#note[
  Observed-value and midpoint thresholds can partition training rows identically despite different printed values.
]

== The geometry: rectangles in feature space

Because every question compares one feature to one threshold, a tree carves feature space into axis-aligned rectangles, one per leaf, and predicts a constant inside each.

#utpfig([A tree carves feature space into axis-aligned rectangles. The first split is $x_1<3$, the second splits only the left side at $x_2<2$, and each region predicts a constant.], label: <fig:tree-rectangles>)[
  #canvas(scale: 0.9, {
    rectangle((0, 0), (6, 4), line-width: widths.thick)
    connect((3, 0), (3, 4), line-width: widths.thick)
    connect((0, 2), (3, 2), line-width: widths.thick)
    node((1.5, 1), [$R_1$], font: font("small"))
    node((1.5, 3), [$R_2$], font: font("small"))
    node((4.5, 2), [$R_3$], font: font("small"))
    node((3, 0), [$x_1=3$], font: font("small"), anchor: "north")
    node((0, 2), [$x_2=2$], font: font("small"), anchor: "east")
    node((3, -0.55), [first split: $x_1<3$?#h(1em)second split (left side only): $x_2<2$?], font: font("small"), anchor: "north")
  })
]

Axis-aligned rules fit naturally; diagonal boundaries require staircases of splits.

== Regression trees

Regression trees choose splits that reduce within-node variance. Each leaf predicts its training-label mean, producing a piecewise-constant function.

#example[
  Labels ${ 2,3,10,11 }$ have mean $6.5$ and variance $16.25$. Splitting into ${ 2,3 }$ and ${ 10,11 }$ reduces weighted variance to $0.25$; leaves predict $2.5$ and $10.5$.
]

#example[
  The best single question for the study log is “hours at most 17?”. Its leaves predict 60.0 for the eight students below and 40.5 for the two above. Ask this tree about someone who studied 100 hours, and it still says 40.5.
]

Leaf means stay within the range of the training labels, so ordinary regression trees do not extrapolate. A forest trained on the prices of past years cannot predict a price above any it has seen, however the market moves.

== Stopping and pruning

Unrestricted growth can produce pure leaves and memorize observations. Use two complementary controls:

#utptable[
  #tabularx(
    columns: (22%, 40%, 1fr),
    styles: ((weight: "bold", fill: navy, size: sizes.footnote), (size: sizes.footnote), (size: sizes.footnote)),
    header: ([Method], [How it works], [Trade-off]),
    [Pre-pruning (early stopping)], [Refuse to grow past limits set in advance: a maximum depth, a minimum number of observations required to split a node or to sit in a leaf, or a minimum impurity decrease.], [Simple and fast; the limits are hyperparameters tuned on validation data.],
    [Post-pruning], [Grow a deliberately large tree first, then cut back branches whose contribution does not justify their complexity. #term[Cost-complexity pruning] charges a penalty $alpha$ per leaf and keeps the subtree that best trades training fit against size; $alpha$ is chosen by cross-validation.], [Growing and then cutting can rescue good splits that become visible only after a mediocre one, which early stopping would never discover.],
  )
]

== Depth: the dial between too simple and memorized

Tree depth controls the bias--variance trade-off from #secref(<sec:bias-variance>). #figref(<fig:tree-depth>) measures it on Lab~2’s telecom customers; Lab~3 measures the same trade-off on loan defaults.

#utpfig([Accuracy of churn trees by depth, on the rows they trained on and on 1,761 validation customers. Training accuracy climbs with every level, while validation accuracy peaks at depth 4 (0.793) and then drifts down to 0.750.], label: <fig:tree-depth>)[
  #canvas({
    axis(..logaxis, width: 11.5632cm, height: 5cm, xlabel: [max\_depth], ylabel: [accuracy], xmin: 0.5, xmax: 12.5, ymin: 0.7, ymax: 0.95, xtick: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12), ytick: (0.7, 0.8, 0.9, 1), legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.03, 0.97), anchor: "north-west"),
      addplot(draw: blue, mark: "*", mark-size: 1.2951pt, line-width: widths.thick, coords: ((1, 0.735), (2, 0.764), (3, 0.793), (4, 0.799), (5, 0.804), (6, 0.814), (7, 0.826), (8, 0.841), (9, 0.858), (10, 0.88), (11, 0.9), (12, 0.922)), legend: [training]),
      addplot(draw: orange, mark: "square*", mark-size: 1.2951pt, line-width: widths.thick, coords: ((1, 0.735), (2, 0.757), (3, 0.785), (4, 0.793), (5, 0.792), (6, 0.789), (7, 0.792), (8, 0.784), (9, 0.779), (10, 0.772), (11, 0.751), (12, 0.75)), legend: [validation]),
    )
  })
]

Left to grow without limit, the same tree reaches depth 25 with 1,004 leaves. It scores 0.998 on its training rows and 0.741 on validation: it has started describing individual customers instead of patterns.

=== The controls that limit growth

#utptable[
  #tabularx(
    columns: (25%, 1fr),
    styles: ((weight: "bold", fill: navy, font: "Source Code Pro", size: 0.88em),),
    header: ([Setting], [What it does]),
    [max\_depth], [Hard limit on how many questions can be asked in a row.],
    [min\_samples\_split], [Refuse to split a node holding fewer than this many rows.],
    [min\_samples\_leaf], [Every final leaf must contain at least this many rows.],
    [max\_leaf\_nodes], [Cap the total number of leaves.],
    [ccp\_alpha], [Cost-complexity pruning: grow fully, then prune back.],
    [class\_weight], [Make rare-class rows count for more.],
  )
]

=== Cost-complexity pruning, properly

Grow the tree until every leaf is pure or tiny. Then define, for a penalty $alpha >= 0$, the score

$ "(training impurity of the subtree)"+ alpha times "(number of leaves)". $

Increasing $alpha$ trades fit for fewer leaves along a nested pruning path. Cross-validate `ccp_alpha`; unlike a uniform depth limit, pruning retains detail where useful.

== Strengths, limitations, and practical notes

- #term[Interpretability:] the model #emph[is] an explanation; individual predictions can be justified by reading off the path.
- #term[Preprocessing:] numerical trees need no scaling; categorical and missing-value handling depends on the implementation.
- #term[Nonlinearity for free:] interactions and thresholds emerge automatically, with no feature engineering.
- #term[Instability:] small data changes can alter early splits and whole subtrees, motivating the ensembles in #chapref(<ch:ensembles>).
- #term[Feature importance:] use the interpretation and bias cautions in #secref(<sec:tree-feature-importance>).

#note[
  Trees learn readable nonlinear rules through impurity reduction. Their instability also makes them useful base learners for ensembles.
]

#recipecard([Decision tree], [A sequence of yes/no questions, each about one feature, ending in leaves that predict a constant.], [Gini impurity or entropy for classes; squared error for numbers.], [Greedy search: at each node, take the best split available now, and never look back.])

#checklist(title: [Decision Trees - Quick Guide])[
  #tabularx(
    columns: (24%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Best when], [Nonlinear rules, interactions, mixed feature scales, and human-readable if-then paths are useful.],
    [Preprocessing], [Usually no scaling is needed; categories still need a supported representation; missing-value handling depends on the implementation.],
    [Main controls], [Maximum depth, minimum samples per split/leaf, maximum leaf nodes, and pruning strength.],
    [Strengths], [Handles nonlinear relationships and interactions; predictions are easy to trace through a small tree.],
    [Watch for], [High variance, unstable splits, misleading feature importance, and blocky extrapolation.],
  )
]

== Interpreting a fitted tree

Inspect paths and leaf counts. Lab~3’s loan tree splits first on the interest rate, at 14.0%, then on the rate again and on the term, and its riskiest leaf, a rate above 14.0% on a 60-month loan, holds a 47.5% default rate. The rules are readable, and they show that the tree has largely learned the lender’s own pricing back.

#note[
  The printed paths are the model’s actual rules, not a post-hoc approximation. Readability alone does not establish fairness, causality, stability, or safety.
]

== Feature importance, and why to distrust it <sec:tree-feature-importance>

#term[Impurity importance] sums a feature’s impurity reductions. Two cautions:

- Many candidate thresholds can inflate importance, favoring continuous features over binary ones.
- Correlated features can substitute for one another, making importance unstable.

#term[Permutation importance] is the safer alternative: shuffle one feature’s values in the validation data and measure how much the score drops. A large drop means this fitted model relied on that column. It is computed on held-out rows, so it also reflects generalization rather than training fit.

#note[
  Feature importance describes which columns this fitted model used. Apply the general association-versus-causation rule from #secref(<sec:correlation>)\; importance is not causal evidence.
]

#summary[
  - A tree asks one question at a time and predicts a constant in each leaf, carving the space into rectangles.
  - Each split is chosen greedily, to reduce impurity the most. Gini and entropy almost always agree.
  - On the telecom customers the first question is the contract, with a gain of 0.064, ahead of tenure, fibre internet and the payment method.
  - Unlimited depth memorizes: training accuracy reached 0.998 with validation at 0.741. Limit growth or prune, and tune on validation.
  - Importance scores describe this fitted model. They are unstable under correlation, and they are not causes.
]

#exercises[
  + A depth-20 tree has nearly perfect training accuracy and unstable feature importance across random splits. Diagnose the likely failure mode, then compare depth 2, 5, and 20 using identical validation folds and a sealed test set.

  + Choose between a shallow single tree and a random forest for a decision that must be explained to a nontechnical reviewer. Your memo must separate predictive performance from interpretability and state what level of performance loss, if any, you would accept for the simpler model.
]

#questions[
  + What does a decision-tree split try to improve at each node?
  + A node holds 8 positives and 2 negatives. What is its Gini impurity? A split gives children of $[4+,0-]$ and $[4+,2-]$; what is the gain?
  + Why can an unconstrained tree achieve excellent training performance yet generalize poorly?
  + Why are ordinary decision trees largely insensitive to monotonic rescaling of a numerical feature?
  + Why can a regression tree not predict a mark above the highest mark it trained on?
]
