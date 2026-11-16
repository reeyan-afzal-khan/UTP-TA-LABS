#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "24-semi-supervised-and-active-learning")

= Semi-Supervised and Active Learning <ch:semi-supervised>

#chapterguide[Supervised learning, validation, classification probabilities, and similarity measures. Lab~5 follows this chapter and also uses #chapref(<ch:anomaly>).][say when unlabeled data can help; trace self-training and label propagation by hand; explain how pseudo-labels can reinforce mistakes; choose what to label by uncertainty; and judge any such method against a labeled-only baseline on genuine labels.]

Back to the map question: does your log hold the answers? So far the answer was yes or no. Often it is “some of them.” Photos, scans and messages are cheap to collect, and a person’s time to label them is not.

A student has a thick workbook and an answer key for only a few pages. One strategy is to mark the rest yourself, using only the answers you feel very sure about, and study from those too. That is #term[semi-supervised learning], and it works if your confidence is earned. Another strategy is to take the questions you are least sure of to the teacher, who has time for only a few. That is #term[active learning].

== The data setting

Let

$ cal(D)_L= { (bold(x)_i,y_i) } _(i=1)^(n_L) $

be the labeled data and

$ cal(D)_U= { bold(x)_j } _(j=1)^(n_U) $

be the unlabeled data, usually with $n_U gt.double n_L$.

Unlabeled data reveal concentration and similarity, not class meaning.

== When unlabeled data can help

Semi-supervised methods rely on assumptions such as:

- nearby observations are likely to share a label;
- observations in the same dense region are likely to share a label;
- the decision boundary should pass through low-density areas rather than cutting through a cluster.

Nearby observations or shared clusters need not share labels. Unlabeled structure helps only when it relates to the target.

== Self-training and pseudo-labeling

Self-training is the simplest semi-supervised approach.

#utpsteps[
  + Train a supervised model on the labeled data.
  + Predict labels and probabilities for the unlabeled data.
  + Keep only predictions with confidence above a strict threshold.
  + Add those pseudo-labeled examples to the training set, usually with lower weight.
  + Retrain the model and repeat for a limited number of rounds.
]

#example[
  One column, labels for $x=1,2$ (class 0) and $x=8,9$ (class 1), and six unlabeled rows. Adopt a pseudo-label only when the model’s chance is at least 0.8 or at most 0.2.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    align: (center, left, left),
    header: ([Round], [Chance of class 1 for the unlabeled rows], [Adopted]),
    [1], [$x=3$: 0.17, 4: 0.31, 5: 0.50, 6: 0.69, 7: 0.83, 10: 0.98], [3, 7, 10],
    [2], [$x=4$: 0.28, 5: 0.51, 6: 0.73], [none, so stop],
  )

  #raggedright[
  #v(6pt)
  The clear rows join the training set, and the ambiguous rows 4, 5 and 6 stay unlabeled. Tighten the threshold and fewer rows join; loosen it and the model’s mistakes start to count as facts.
  ]]]
]

#warning[
  Pseudo-labeling can reinforce confident mistakes. Limit rounds, check class balance, and validate against human labels.
]

#example[
  Does it help? In Lab~5 a pool holds 8,003 messages to a bank’s support chat in 77 intents, and only 1,000 keep their labels. A plain model on those scores 0.638 on validation; self-training adopts 486 pseudo-labels, 98.8% of them right, and scores 0.632, against 0.882 with every label: no gain, because the model is sure only about messages it already gets right. Lower the confidence threshold to 0.5, and it adopts 3,604 pseudo-labels, only 76.8% of them right, and falls to 0.596: every wrong label is learned as if it were true. Always compute the baseline.
]

== Graph-based label propagation

Connect similar observations with weighted edges, and let labels spread through the graph like news through a group of friends. Each unlabeled node repeatedly takes the average of its neighbors, while labeled nodes stay fixed.

#example[
  A chain of six nodes, with the left end labeled 1 and the right end labeled 0. The unlabeled nodes start at 0.5 and are updated left to right, using the newest values. After one sweep they read $0.75, space 0.5, space 0.5, space 0.25$. After two: $0.75, space 0.625, space 0.375, space 0.25$. They settle at $0.8, space 0.6, space 0.4, space 0.2$, a smooth slope between the two labels, because each value is the mean of its two neighbors.
]

#utpfig([Graph-based label propagation. Similar observations are joined by edges, and the two known labels spread through their own connected groups to the unlabeled points.], label: <fig:label-propagation>)[
  #canvas({
    let node-style = (shape: "circle", draw: muted, min-size: 0.6, inner-sep: 0pt)
    let labA = (..node-style, fill: mix(blue, 35%), draw: blue)
    let labB = (..node-style, fill: mix(orange, 35%), draw: orange)
    let unlab = (..node-style, fill: white)
    let edge = (draw: mix(muted, 60%), line-width: widths.thick)
    node((0, 1.2), [A], name: "a1", ..labA)
    node((1.1, 1.7), [], name: "a2", ..unlab)
    node((1.5, 0.7), [], name: "a3", ..unlab)
    node((2.5, 1.4), [], name: "a4", ..unlab)
    node((5.2, 1.2), [B], name: "b1", ..labB)
    node((4.1, 1.7), [], name: "b2", ..unlab)
    node((3.8, 0.65), [], name: "b3", ..unlab)
    node((5.7, 0.25), [], name: "b4", ..unlab)
    connect("a1", "a2", "a4", "a3", "a1", ..edge)
    connect("a2", "a3", ..edge)
    connect("b1", "b2", "b3", "b1", ..edge)
    connect("b1", "b4", "b3", ..edge)
    connect("a4", "b3", dash: "dashed", draw: mix(muted, 45%))
  })
]

This works well when similarity is meaningful and clusters line up with classes. It can fail when the graph connects unlike observations or when feature scaling is poor.

== Co-training

Co-training fits two views, such as webpage text and links, whose models exchange high-confidence pseudo-labels.

Both views must be informative and offer complementary errors; nearly identical views add little.

== Active learning

Active learning asks which labels would be most informative, within a fixed budget.

Common selection strategies include:

#utptable[
  #tabularx(
    columns: (26%, 1fr),
    styles: (navy-bold,),
    header: ([Selection strategy], [Which examples it chooses]),
    [Uncertainty sampling], [Examples whose predicted probabilities are closest to a tie.],
    [Query by disagreement], [Examples on which several models disagree.],
    [Diversity sampling], [Uncertain examples that also cover different regions of the feature space.],
    [Expected impact], [Examples whose labels are estimated to improve the model most or reduce decision cost.],
  )
]

#example[
  A model gives these unlabeled rows a chance of class 1: $0.97, space 0.52, space 0.10, space 0.61, space 0.48, space 0.88$. With budget for two labels, uncertainty sampling asks about the 0.52 and the 0.48, which are nearest to a coin flip. A label on the 0.97 row would probably just confirm what the model already believes.
]

#utpfig([The active-learning loop. The model selects useful unlabeled cases, a human labels them, and the labeled set grows before the model is trained again.], label: <fig:active-loop>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.35, min-height: 0.82, align: center, font: font("small", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [Train model], name: "train", ..box-style)
    node(right-of("train", 0.55), [Select useful \
  unlabeled cases], name: "select", ..box-style)
    node(right-of("select", 0.55), [Human labels \
  the cases], name: "label", ..box-style)
    node(right-of("label", 0.55), [Add to labeled \
  training set], name: "add", ..box-style)
    connect("train", "select", ..arr)
    connect("select", "label", ..arr)
    connect("label", "add", ..arr)
    connect("add.south", "train.south", bend: 28deg, ..arr, name: "curve-1")
  })
]

#utpfig([Uncertainty sampling, step by step: train on the labels you have, score every unlabeled example, select the most uncertain ones, ask a human to label them, and repeat until the labeling budget runs out.], label: <fig:uncertainty-sampling>)[
  #canvas({
    let st = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 5.25, min-height: 1, inner-xsep: 2.9888pt, align: center, font: font("script", weight: "bold", fill: navy))
    let hum = (draw: orange, fill: pale-orange, rounded: 2mm, min-width: 5.25, min-height: 1, inner-xsep: 2.9888pt, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
    node((0, 0), [1\. Train using the labels you have], name: "train", ..st)
    node(right-of("train", 1.35), [2\. Score every unlabeled example], name: "score", ..st)
    node(below-of("score", 1.05), [3\. Select the most uncertain examples], name: "pick", ..st)
    node(below-of("train", 1.05), [4\. Ask a human to label those examples], name: "ask", ..hum)
    connect("train", "score", ..arr)
    connect("score", "pick", ..arr)
    connect("pick", "ask", ..arr)
    connect("ask", "train", ..arr)
    node(("train", 50%, "pick"), [repeat until the budget runs out], font: font("script", style: "italic", fill: muted), align: center)
  })
]

#utpfig([Lab~5’s support-message simulation: validation accuracy on 2,000 messages against labels bought, from 154 labels (2 per intent), buying 100 per round. The two policies are level for two rounds; from then on uncertainty sampling leads.], label: <fig:active-curve>)[
  #canvas({
    axis(..logaxis, width: 11.5632cm, height: 4.8cm, xlabel: [labels bought], ylabel: [validation accuracy], xmin: 100, xmax: 1100, ymin: 0.28, ymax: 0.75, legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.97, 0.05), anchor: "south-east"),
      addplot(draw: blue, mark: "*", mark-size: 1.3948pt, line-width: widths.thick, coords: ((154, 0.319), (254, 0.36), (354, 0.464), (454, 0.532), (554, 0.594), (654, 0.616), (754, 0.653), (854, 0.674), (954, 0.7), (1054, 0.712)), legend: [uncertainty sampling]),
      addplot(draw: orange, mark: "square*", mark-size: 1.3948pt, line-width: widths.thick, coords: ((154, 0.319), (254, 0.368), (354, 0.438), (454, 0.505), (554, 0.546), (654, 0.579), (754, 0.606), (854, 0.631), (954, 0.648), (1054, 0.679)), legend: [random querying]),
    )
  })
]

On the official test messages the lead holds, 0.725 against 0.682 with 1,054 labels each. Seventy-seven intents with many near neighbors make many hard boundaries, which is when active learning earns its keep. A model that knows too little cannot tell which questions are informative, so start from a sample of every class before letting uncertainty choose.

== A safe practical workflow

#utpsteps[
  + Create fixed, human-labeled validation and test sets before using unlabeled data.
  + Train a supervised baseline using only the labeled training set.
  + Inspect whether similarity or cluster structure appears connected to the label.
  + Add one semi-supervised or active-learning method at a time.
  + Compare against the labeled-only baseline using the same evaluation protocol.
  + Review performance by class and subgroup, not only overall average performance.
  + Keep a record of which labels came from humans and which came from the model.
]

#recipecard([Self-training], [Any supervised model that outputs probabilities.], [That model’s usual loss, computed on real labels and adopted pseudo-labels.], [Fit, adopt the confident predictions, refit, repeat until nothing new is adopted.])

#checklist(title: [Semi-Supervised and Active Learning - Quick Guide])[
  #tabularx(
    columns: (24%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Best when], [Human labels are expensive, unlabeled examples are plentiful, and feature-space structure relates to the label.],
    [Start with], [A supervised baseline and a fixed human-labeled validation/test set.],
    [Main controls], [Confidence threshold, number of pseudo-labeling rounds, graph similarity, labeling budget, query strategy.],
    [Main risks], [Confirmation bias, class imbalance, poor similarity measures, sampling only unusual cases, changing labeling standards.],
  )
]

#note[
  Unlabeled data provides structure, not truth. Human labels remain the source of meaning and the basis of fair evaluation.
]

#summary[
  - Unlabeled rows reveal where data lies, not what it means. They help only if that structure lines up with the label.
  - Self-training adopts confident predictions as labels, and label propagation spreads known labels over a similarity graph. Both can turn mistakes into facts.
  - Active learning spends a labeling budget where the model is least sure.
  - Keep human-labeled validation and test sets, and compare with a labeled-only baseline. In Lab~5 the baseline showed that self-training gained nothing, and that trusting it more made it worse.
]

#questions[
  + Why can pseudo-labeling reinforce mistakes even when the model is highly confident?
  + What does an active-learning query strategy try to spend the labeling budget on?
  + Why must final validation and test labels come from a genuine labeling source rather than from the model itself?
  + Chain nodes hold $1, space ?, space ?, space 0$. At rest, what are the two unknown values?
  + Self-training scored 0.632 and labels-only 0.638 in Lab~5. Which do you ship, and what would you try before giving up on the unlabeled messages?
]
