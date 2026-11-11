#import "/.shared/typst/utp.typ": *
#unit("chapters", "11-decision-trees")


#heading(level: 1)[Decision Trees]
 <ch:decision-trees>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* #ref(label("ch:training"), supplement: [Chapter]) plus basic probability from #ref(label("ch:foundations"), supplement: [Chapter]); entropy is helpful but re-explained here.

*By the end, you can:* compute Gini impurity and information gain by hand; choose a split on real counts; read a fitted tree as rules; control depth and pruning; and treat feature importance with care.]

In the game of Twenty Questions you never ask "is it a giraffe?" first. You ask a question that splits the possibilities well, such as "is it alive?", and then ask the next one depending on the answer. A decision tree plays that game with a table. It routes each row through questions such as "age below 30?" until it reaches a #strong[leaf], which holds the prediction. Small trees can be read aloud, and forests and boosting combine many of them into stronger models (#ref(label("ch:ensembles"), supplement: [Chapter])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/2db08ad6e51e40e6.svg")], caption: [A small decision tree. Each internal node asks one question about one feature, and each leaf makes a prediction.]) <fig:tree-example>


#heading(level: 2)[How a tree is grown]
 <sec:decision-tree>

Standard tree learning (the CART algorithm) is #strong[greedy and recursive]:

+ At the current node, consider candidate splits: for a numerical feature, thresholds between sorted values; for categorical features, the rules depend on the implementation; scikit-learn expects them one-hot encoded, which is what Lab~3 does.

+ Score each candidate by how much it #emph[purifies] the data --- how well it separates the classes (or, for regression, how much it shrinks the spread of the label).

+ Apply the best split, sending observations left and right.

+ Repeat on each child until a stopping rule fires; each final node becomes a leaf that predicts its majority class (classification) or mean label (regression).

Greedy means the algorithm never looks ahead or reconsiders: it takes the best immediate split at every step. That keeps training fast and usually works well, though it does not guarantee the globally best tree.


#heading(level: 2)[Measuring impurity]


#callout("analogy", title: [Analogy])[Picture a bag of red and blue marbles. A bag of one color is pure, so you can name the color of the next marble with no doubt. A half-and-half bag is as mixed as it gets. A good question pours one mixed bag into two bags, each purer than the original.]

To pick a split, the algorithm needs a number for "how mixed is this node?" With $p_k$ the fraction of class $k$ in a node, two standard measures are the #strong[Gini impurity] and the #strong[entropy]: $ G = 1 - sum_(k = 1)^K p_k^2 \, #h(2em) H = - sum_(k = 1)^K p_k log_2 p_k . $ Both are zero for a pure node (one class only) and largest for a perfect mixture. Gini reads as "the probability of mislabeling a random point if labels were assigned according to the node's class mix"; entropy reads as "how many yes/no questions of uncertainty remain." A split is chosen to maximize the #strong[information gain]: the parent's impurity minus the size-weighted impurity of the children, $ "Gain" = I \( upright("parent") \) - n_(upright(l e f t)) / n I \( upright("left") \) - n_(upright(r i g h t)) / n I \( upright("right") \) \, $ where $I$ is either measure. Gini and entropy almost always agree on the best split; Gini is slightly cheaper to compute and is the common default.

#callout("workedexample", title: [Worked example])[A node holds 10 loan applications: 6 approved ($+$) and 4 rejected ($-$). Its Gini impurity is $G_(upright("parent")) = 1 - \( 0.6^2 + 0.4^2 \) = 0.48$.

#emph[Candidate split A] produces children $\[ 4 + \, 0 - \]$ and $\[ 2 + \, 4 - \]$: $ G_(upright("left")) = 0 \, #h(2em) G_(upright("right")) = 1 - [(1 / 3)^2 + (2 / 3)^2] = 4 / 9 approx 0.444 \, $ $ "Gain"_A = 0.48 - (4 / 10 times 0 + 6 / 10 times 0.444) = 0.48 - 0.267 = 0.213 . $

#emph[Candidate split B] produces children $\[ 3 + \, 2 - \]$ and $\[ 3 + \, 2 - \]$. Each child has the same $60 \/ 40$ mix as the parent, so each has $G = 0.48$, the weighted impurity is unchanged, and $"Gain"_B = 0$: split B tells us nothing, and split A wins. (Entropy agrees: split A's gain is $0.971 - 0.551 approx 0.42$ bits.)]


#heading(level: 2)[Finding the best split, on real data]


Evaluate every candidate question, and keep the one with the largest weighted drop in impurity. If a threshold separated two classes perfectly, both children would be pure and the gain would equal the parent's impurity.

#callout("workedexample", title: [Worked example])[The 7,043 telecom customers of Labs~1 and~2 include 5,174 who stayed and 1,869 who left, so their Gini is $1 - \( 0.735^2 + 0.265^2 \) = 0.390$. Four candidate first questions:

#figure(
  align(center)[#table(
    columns: 6,
    align: (left,center,center,center,center,center,),
    table.header([Question], [Yes: stayed, left], [Gini], [No: stayed, left], [Gini], [Gain],),
    table.hline(),
    [Month-to-month contract?], [2,220, 1,655], [0.489], [2,954, 214], [0.126], [#strong[0.064]],
    [Tenure at most 12 months?], [1,149, 1,037], [0.499], [4,025, 832], [0.284], [0.039],
    [Fibre internet?], [1,799, 1,297], [0.487], [3,375, 572], [0.248], [0.037],
    [Pays by electronic check?], [1,294, 1,071], [0.496], [3,880, 798], [0.283], [0.036],
  )]
  , kind: table
  )

Check the first row: 3,875 customers on month-to-month contracts and 3,168 on longer ones, so the weighted child impurity is $3875 / 7043 \( 0.489 \) + 3168 / 7043 \( 0.126 \) = 0.326$, and the gain is $0.390 - 0.326 = 0.064$. The contract wins clearly: nearly nine in ten of the customers who left were free to go at a month's notice, so a tree asks it first. Then the same search repeats inside each child. Lab~3 runs this search on personal loans, and the questions it chooses turn out to be the lender's own interest rate and the length of the loan.]

#callout("libnote", title: [Reference note])[Observed-value and midpoint thresholds can partition training rows identically despite different printed values.]


#heading(level: 2)[The geometry: rectangles in feature space]


Because every question compares one feature to one threshold, a tree carves feature space into axis-aligned rectangles, one per leaf, and predicts a constant inside each.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/b59cdd26bd83011a.svg")], caption: [A tree carves feature space into axis-aligned rectangles. The first split is $x_1 < 3$, the second splits only the left side at $x_2 < 2$, and each region predicts a constant.]) <fig:tree-rectangles>

Axis-aligned rules fit naturally; diagonal boundaries require staircases of splits.


#heading(level: 2)[Regression trees]


Regression trees choose splits that reduce within-node variance. Each leaf predicts its training-label mean, producing a piecewise-constant function.

#callout("workedexample", title: [Worked example])[Labels ${ 2 \, 3 \, 10 \, 11 }$ have mean $6.5$ and variance $16.25$. Splitting into ${ 2 \, 3 }$ and ${ 10 \, 11 }$ reduces weighted variance to $0.25$; leaves predict $2.5$ and $10.5$.]

#callout("workedexample", title: [Worked example])[The best single question for the study log is "hours at most 17?". Its leaves predict 60.0 for the eight students below and 40.5 for the two above. Ask this tree about someone who studied 100 hours, and it still says 40.5.]

Leaf means stay within the range of the training labels, so ordinary regression trees do not extrapolate. A forest trained on the prices of past years cannot predict a price above any it has seen, however the market moves.


#heading(level: 2)[Stopping and pruning]


Unrestricted growth can produce pure leaves and memorize observations. Use two complementary controls:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Method], [How it works], [Trade-off],),
    table.hline(),
    [Pre-pruning (early stopping)], [Refuse to grow past limits set in advance: a maximum depth, a minimum number of observations required to split a node or to sit in a leaf, or a minimum impurity decrease.], [Simple and fast; the limits are hyperparameters tuned on validation data.],
    [Post-pruning], [Grow a deliberately large tree first, then cut back branches whose contribution does not justify their complexity. #strong[Cost-complexity pruning] charges a penalty $alpha$ per leaf and keeps the subtree that best trades training fit against size; $alpha$ is chosen by cross-validation.], [Growing and then cutting can rescue good splits that become visible only after a mediocre one, which early stopping would never discover.],
  )]
  , kind: table
  )


#heading(level: 2)[Depth: the dial between too simple and memorized]


Tree depth controls the bias--variance trade-off from #ref(label("sec:bias-variance"), supplement: [Section]). #ref(label("fig:tree-depth"), supplement: [Figure]) measures it on Lab~2's telecom customers; Lab~3 measures the same trade-off on loan defaults.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/432300e1cd3ea283.svg")], caption: [Accuracy of churn trees by depth, on the rows they trained on and on 1,761 validation customers. Training accuracy climbs with every level, while validation accuracy peaks at depth 4 (0.793) and then drifts down to 0.750.]) <fig:tree-depth>

Left to grow without limit, the same tree reaches depth 25 with 1,004 leaves. It scores 0.998 on its training rows and 0.741 on validation: it has started describing individual customers instead of patterns.


#heading(level: 3)[The controls that limit growth]


#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Setting], [What it does],),
    table.hline(),
    [max\_depth], [Hard limit on how many questions can be asked in a row.],
    [min\_samples\_split], [Refuse to split a node holding fewer than this many rows.],
    [min\_samples\_leaf], [Every final leaf must contain at least this many rows.],
    [max\_leaf\_nodes], [Cap the total number of leaves.],
    [ccp\_alpha], [Cost-complexity pruning: grow fully, then prune back.],
    [class\_weight], [Make rare-class rows count for more.],
  )]
  , kind: table
  )


#heading(level: 3)[Cost-complexity pruning, properly]


Grow the tree until every leaf is pure or tiny. Then define, for a penalty $alpha gt.eq 0$, the score $ upright("(training impurity of the subtree)") + alpha times upright("(number of leaves)") . $ Increasing $alpha$ trades fit for fewer leaves along a nested pruning path. Cross-validate `ccp_alpha`; unlike a uniform depth limit, pruning retains detail where useful.


#heading(level: 2)[Strengths, limitations, and practical notes]


- #strong[Interpretability:] the model #emph[is] an explanation; individual predictions can be justified by reading off the path.

- #strong[Preprocessing:] numerical trees need no scaling; categorical and missing-value handling depends on the implementation.

- #strong[Nonlinearity for free:] interactions and thresholds emerge automatically, with no feature engineering.

- #strong[Instability:] small data changes can alter early splits and whole subtrees, motivating the ensembles in #ref(label("ch:ensembles"), supplement: [Chapter]).

- #strong[Feature importance:] use the interpretation and bias cautions in #ref(label("sec:tree-feature-importance"), supplement: [Section]).

#callout("keyidea", title: [Key idea])[Trees learn readable nonlinear rules through impurity reduction. Their instability also makes them useful base learners for ensembles.]

#callout("modelcard", title: [The recipe: Decision tree])[*1. Model* A sequence of yes/no questions, each about one feature, ending in leaves that predict a constant.

*2. Loss* Gini impurity or entropy for classes; squared error for numbers.

*3. Optimizer* Greedy search: at each node, take the best split available now, and never look back.]

#callout("modelcard", title: [Decision Trees - Quick Guide])[#block[
ll Best when & Nonlinear rules, interactions, mixed feature scales, and human-readable if-then paths are useful. Preprocessing & Usually no scaling is needed; categories still need a supported representation; missing-value handling depends on the implementation. Main controls & Maximum depth, minimum samples per split/leaf, maximum leaf nodes, and pruning strength. Strengths & Handles nonlinear relationships and interactions; predictions are easy to trace through a small tree. Watch for & High variance, unstable splits, misleading feature importance, and blocky extrapolation.

]]


#heading(level: 2)[Interpreting a fitted tree]


Inspect paths and leaf counts. Lab~3's loan tree splits first on the interest rate, at 14.0%, then on the rate again and on the term, and its riskiest leaf, a rate above 14.0% on a 60-month loan, holds a 47.5% default rate. The rules are readable, and they show that the tree has largely learned the lender's own pricing back.

#callout("keyidea", title: [Key idea])[The printed paths are the model's actual rules, not a post-hoc approximation. Readability alone does not establish fairness, causality, stability, or safety.]


#heading(level: 2)[Feature importance, and why to distrust it]
 <sec:tree-feature-importance>

#strong[Impurity importance] sums a feature's impurity reductions. Two cautions:

- Many candidate thresholds can inflate importance, favoring continuous features over binary ones.

- Correlated features can substitute for one another, making importance unstable.

#strong[Permutation importance] is the safer alternative: shuffle one feature's values in the validation data and measure how much the score drops. A large drop means this fitted model relied on that column. It is computed on held-out rows, so it also reflects generalization rather than training fit.

#callout("keyidea", title: [Key idea])[Feature importance describes which columns this fitted model used. Apply the general association-versus-causation rule from #ref(label("sec:correlation"), supplement: [Section]); importance is not causal evidence.]

#callout("debugtask", title: [Debugging task])[A depth-20 tree has nearly perfect training accuracy and unstable feature importance across random splits. Diagnose the likely failure mode, then compare depth 2, 5, and 20 using identical validation folds and a sealed test set.]

#callout("decisionmemo", title: [Decision memo])[Choose between a shallow single tree and a random forest for a decision that must be explained to a nontechnical reviewer. Your memo must separate predictive performance from interpretability and state what level of performance loss, if any, you would accept for the simpler model.]

#callout("chapterrecap", title: [Chapter recap])[- A tree asks one question at a time and predicts a constant in each leaf, carving the space into rectangles.

- Each split is chosen greedily, to reduce impurity the most. Gini and entropy almost always agree.

- On the telecom customers the first question is the contract, with a gain of 0.064, ahead of tenure, fibre internet and the payment method.

- Unlimited depth memorizes: training accuracy reached 0.998 with validation at 0.741. Limit growth or prune, and tune on validation.

- Importance scores describe this fitted model. They are unstable under correlation, and they are not causes.]

#callout("quickcheck", title: [Check your understanding])[+ What does a decision-tree split try to improve at each node?

+ A node holds 8 positives and 2 negatives. What is its Gini impurity? A split gives children of $\[ 4 + \, 0 - \]$ and $\[ 4 + \, 2 - \]$; what is the gain?

+ Why can an unconstrained tree achieve excellent training performance yet generalize poorly?

+ Why are ordinary decision trees largely insensitive to monotonic rescaling of a numerical feature?

+ Why can a regression tree not predict a mark above the highest mark it trained on?]
