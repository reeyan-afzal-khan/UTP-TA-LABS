#import "/.shared/typst/utp.typ": *
#unit("chapters", "18-semi-supervised-and-active-learning")


#heading(level: 1)[Semi-Supervised and Active Learning]
 <ch:semi-supervised>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Supervised learning, validation, classification probabilities, and similarity measures. Lab~5 follows this chapter and also uses #ref(label("ch:anomaly"), supplement: [Chapter]).

*By the end, you can:* say when unlabeled data can help; trace self-training and label propagation by hand; explain how pseudo-labels can reinforce mistakes; choose what to label by uncertainty; and judge any such method against a labeled-only baseline on genuine labels.]

Back to the map question: does your log hold the answers? So far the answer was yes or no. Often it is "some of them." Photos, scans and messages are cheap to collect, and a person's time to label them is not.

#callout("analogy", title: [Analogy])[A student has a thick workbook and an answer key for only a few pages. One strategy is to mark the rest yourself, using only the answers you feel very sure about, and study from those too. That is #strong[semi-supervised learning], and it works if your confidence is earned. Another strategy is to take the questions you are least sure of to the teacher, who has time for only a few. That is #strong[active learning].]


#heading(level: 2)[The data setting]


Let $ cal(D)_L = { \( bold(x)_i \, y_i \) }_(i = 1)^(n_L) $ be the labeled data and $ cal(D)_U = { bold(x)_j }_(j = 1)^(n_U) $ be the unlabeled data, usually with $n_U gt.double n_L$.

Unlabeled data reveal concentration and similarity, not class meaning.


#heading(level: 2)[When unlabeled data can help]


Semi-supervised methods rely on assumptions such as:

- nearby observations are likely to share a label;

- observations in the same dense region are likely to share a label;

- the decision boundary should pass through low-density areas rather than cutting through a cluster.

Nearby observations or shared clusters need not share labels. Unlabeled structure helps only when it relates to the target.


#heading(level: 2)[Self-training and pseudo-labeling]


Self-training is the simplest semi-supervised approach.

+ Train a supervised model on the labeled data.

+ Predict labels and probabilities for the unlabeled data.

+ Keep only predictions with confidence above a strict threshold.

+ Add those pseudo-labeled examples to the training set, usually with lower weight.

+ Retrain the model and repeat for a limited number of rounds.

#callout("workedexample", title: [Worked example])[One column, labels for $x = 1 \, 2$ (class 0) and $x = 8 \, 9$ (class 1), and six unlabeled rows. Adopt a pseudo-label only when the model's chance is at least 0.8 or at most 0.2.

#figure(
  align(center)[#table(
    columns: 3,
    align: (center,left,left,),
    table.header([Round], [Chance of class 1 for the unlabeled rows], [Adopted],),
    table.hline(),
    [1], [$x = 3$: 0.17,~4: 0.31,~5: 0.50,~6: 0.69,~7: 0.83,~10: 0.98], [3, 7, 10],
    [2], [$x = 4$: 0.28,~5: 0.51,~6: 0.73], [none, so stop],
  )]
  , kind: table
  )

The clear rows join the training set, and the ambiguous rows 4, 5 and 6 stay unlabeled. Tighten the threshold and fewer rows join; loosen it and the model's mistakes start to count as facts.]

#callout("pitfall", title: [Common mistake])[Pseudo-labeling can reinforce confident mistakes. Limit rounds, check class balance, and validate against human labels.]

#callout("workedexample", title: [Worked example])[Does it help? In Lab~5 a pool holds 8,003 messages to a bank's support chat in 77 intents, and only 1,000 keep their labels. A plain model on those scores 0.638 on validation; self-training adopts 486 pseudo-labels, 98.8% of them right, and scores 0.632, against 0.882 with every label: no gain, because the model is sure only about messages it already gets right. Lower the confidence threshold to 0.5, and it adopts 3,604 pseudo-labels, only 76.8% of them right, and falls to 0.596: every wrong label is learned as if it were true. Always compute the baseline.]


#heading(level: 2)[Graph-based label propagation]


Connect similar observations with weighted edges, and let labels spread through the graph like news through a group of friends. Each unlabeled node repeatedly takes the average of its neighbors, while labeled nodes stay fixed.

#callout("workedexample", title: [Worked example])[A chain of six nodes, with the left end labeled 1 and the right end labeled 0. The unlabeled nodes start at 0.5 and are updated left to right, using the newest values. After one sweep they read $0.75 \, med 0.5 \, med 0.5 \, med 0.25$. After two: $0.75 \, med 0.625 \, med 0.375 \, med 0.25$. They settle at $0.8 \, med 0.6 \, med 0.4 \, med 0.2$, a smooth slope between the two labels, because each value is the mean of its two neighbors.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/68365b5505d3b5b0.svg")], caption: [Graph-based label propagation. Similar observations are joined by edges, and the two known labels spread through their own connected groups to the unlabeled points.]) <fig:label-propagation>

This works well when similarity is meaningful and clusters line up with classes. It can fail when the graph connects unlike observations or when feature scaling is poor.


#heading(level: 2)[Co-training]


Co-training fits two views, such as webpage text and links, whose models exchange high-confidence pseudo-labels.

Both views must be informative and offer complementary errors; nearly identical views add little.


#heading(level: 2)[Active learning]


Active learning asks which labels would be most informative, within a fixed budget.

Common selection strategies include:

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Selection strategy], [Which examples it chooses],),
    table.hline(),
    [Uncertainty sampling], [Examples whose predicted probabilities are closest to a tie.],
    [Query by disagreement], [Examples on which several models disagree.],
    [Diversity sampling], [Uncertain examples that also cover different regions of the feature space.],
    [Expected impact], [Examples whose labels are estimated to improve the model most or reduce decision cost.],
  )]
  , kind: table
  )

#callout("workedexample", title: [Worked example])[A model gives these unlabeled rows a chance of class 1: $0.97 \, med 0.52 \, med 0.10 \, med 0.61 \, med 0.48 \, med 0.88$. With budget for two labels, uncertainty sampling asks about the 0.52 and the 0.48, which are nearest to a coin flip. A label on the 0.97 row would probably just confirm what the model already believes.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/1831a5400a7d6a4d.svg")], caption: [The active-learning loop. The model selects useful unlabeled cases, a human labels them, and the labeled set grows before the model is trained again.]) <fig:active-loop>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/c93c7b31f5b1a654.svg")], caption: [Uncertainty sampling, step by step: train on the labels you have, score every unlabeled example, select the most uncertain ones, ask a human to label them, and repeat until the labeling budget runs out.]) <fig:uncertainty-sampling>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/8bd5e52d8c8348c0.svg")], caption: [Lab~5's support-message simulation: validation accuracy on 2,000 messages against labels bought, from 154 labels (2 per intent), buying 100 per round. The two policies are level for two rounds; from then on uncertainty sampling leads.]) <fig:active-curve>

On the official test messages the lead holds, 0.725 against 0.682 with 1,054 labels each. Seventy-seven intents with many near neighbors make many hard boundaries, which is when active learning earns its keep. A model that knows too little cannot tell which questions are informative, so start from a sample of every class before letting uncertainty choose.


#heading(level: 2)[A safe practical workflow]


+ Create fixed, human-labeled validation and test sets before using unlabeled data.

+ Train a supervised baseline using only the labeled training set.

+ Inspect whether similarity or cluster structure appears connected to the label.

+ Add one semi-supervised or active-learning method at a time.

+ Compare against the labeled-only baseline using the same evaluation protocol.

+ Review performance by class and subgroup, not only overall average performance.

+ Keep a record of which labels came from humans and which came from the model.

#callout("modelcard", title: [The recipe: Self-training])[*1. Model* Any supervised model that outputs probabilities.

*2. Loss* That model's usual loss, computed on real labels and adopted pseudo-labels.

*3. Optimizer* Fit, adopt the confident predictions, refit, repeat until nothing new is adopted.]

#callout("modelcard", title: [Semi-Supervised and Active Learning - Quick Guide])[#block[
ll Best when & Human labels are expensive, unlabeled examples are plentiful, and feature-space structure relates to the label. Start with & A supervised baseline and a fixed human-labeled validation/test set. Main controls & Confidence threshold, number of pseudo-labeling rounds, graph similarity, labeling budget, query strategy. Main risks & Confirmation bias, class imbalance, poor similarity measures, sampling only unusual cases, changing labeling standards.

]]

#callout("keyidea", title: [Key idea])[Unlabeled data provides structure, not truth. Human labels remain the source of meaning and the basis of fair evaluation.]

#callout("chapterrecap", title: [Chapter recap])[- Unlabeled rows reveal where data lies, not what it means. They help only if that structure lines up with the label.

- Self-training adopts confident predictions as labels, and label propagation spreads known labels over a similarity graph. Both can turn mistakes into facts.

- Active learning spends a labeling budget where the model is least sure.

- Keep human-labeled validation and test sets, and compare with a labeled-only baseline. In Lab~5 the baseline showed that self-training gained nothing, and that trusting it more made it worse.]

#callout("quickcheck", title: [Check your understanding])[+ Why can pseudo-labeling reinforce mistakes even when the model is highly confident?

+ What does an active-learning query strategy try to spend the labeling budget on?

+ Why must final validation and test labels come from a genuine labeling source rather than from the model itself?

+ Chain nodes hold $1 \, med ? \, med ? \, med 0$. At rest, what are the two unknown values?

+ Self-training scored 0.632 and labels-only 0.638 in Lab~5. Which do you ship, and what would you try before giving up on the unlabeled messages?]
