#import "/.shared/typst/utp.typ": *
#unit("chapters", "14-how-unsupervised-learning-works")


#heading(level: 1)[How Unsupervised Learning Works]
 <ch:unsupervised>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* The shared foundations in Stages 1--2 and the supervised workflow in Stage 3A for comparison.

*By the end, you can:* say what an unsupervised method optimizes when no answers exist; match a question to a family of methods; gather internal, external and practical evidence for a result; and justify your scaling before you interpret anything.]

Tip a box of old holiday photos onto the table and start sorting them into piles. Nobody told you which piles to make. You might sort by place, by year, or by who is in them, and each sorting would be sensible. Nobody can mark it right or wrong either. You can only ask whether a sorting is tidy, stable, and useful for what you wanted.

Back to the map in #ref(label("fig:ml-map"), supplement: [Figure]). Ask of the study log, "what kinds of student are in this group?", and you will find that no column holds the answer. That is the other half of machine learning: given features $X$ without labels, find groups, representations, or unusual cases.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/81b3170ae20f0ba7.svg")], caption: [Supervised learning uses features $X$ and labels $y$ to predict $y$; unsupervised learning has only $X$ and looks for structure in it.]) <fig:sup-vs-unsup>


#heading(level: 2)[The unsupervised-learning map]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Question], [First framing], [Main output],),
    table.hline(),
    [Do observations form groups?], [Clustering], [Cluster assignments, centers, hierarchy, or soft memberships],
    [Can the data be represented with fewer dimensions?], [Dimensionality reduction / representation], [Components or lower-dimensional coordinates],
    [Which observations are unusual?], [Anomaly / novelty detection], [Anomaly score or ranked suspicious cases],
    [Where is the data concentrated?], [Density estimation], [Estimated probability density or mixture components],
    [Which items occur together?], [Association / pattern mining #emph[(beyond core)]], [Frequent itemsets and rules],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Evaluation follows the objective: variance for PCA, separation for clustering, reviewed-alert precision for anomalies.]


#heading(level: 2)[What does fitting mean without labels?]


An unsupervised method still follows the recipe. It has a model, it has a loss, and it has an optimizer. The loss simply does not compare predictions with a supplied label.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Method family], [What fitting tries to do], [What is learned],),
    table.hline(),
    [$K$-means], [Reduce squared distance from points to assigned centers], [Cluster centers and assignments],
    [PCA], [Preserve as much variance as possible in a lower-dimensional linear representation], [Principal directions and projected coordinates],
    [Density / mixture models], [Assign high likelihood to the observed feature distribution under a chosen family], [Distribution parameters and soft memberships],
    [Isolation / local methods], [Make unusual observations easy to isolate or locally sparse], [Anomaly scores / rankings],
    [Association mining #emph[(beyond core)]], [Find item combinations that occur often enough to be interesting], [Frequent itemsets and conditional rules],
  )]
  , kind: table
  )


#heading(level: 2)[How do we evaluate when there is no answer key?]


There is no universal "unsupervised accuracy." Use evidence that matches the task, and more than one kind of it.


#heading(level: 3)[Internal evidence]
 Assess compactness, separation, reconstruction, retained variance, and stability under resampling or perturbation.


#heading(level: 3)[External evidence]
 Compare with independent reference labels when available, using measures such as adjusted Rand index. Disagreement may reflect a different valid structure.


#heading(level: 3)[Practical or downstream evidence]
 Test usefulness: interpretable clusters, retained downstream signal, or anomalies that merit review.

#callout("workedexample", title: [Worked example])[Lab~4 groups 5,878 customers of an online shop, built from two years of invoices, with $K$-means and brings all three kinds of evidence. Internal: the silhouette peaks at 0.439 for two groups, and among richer splits four groups (0.365) beat three and five. Stability: every one of eight single random starts reaches the same four groups. Practical: the four groups can be named (lost one-time buyers, lapsing regulars, recent occasional buyers, and best customers, who bring in 72.1% of revenue), and a marketing team could act on those names. DBSCAN adds a fourth kind of evidence, the customers it refuses to place: 91 wholesale buyers who carry 30.8% of revenue. No single score settles it, and the conclusion is stated as "four segments, with the wholesale accounts handled separately".]

#callout("pitfall", title: [Common mistake])[Do not invent labels after fitting and treat them as ground truth. Known classes and visual groupings need not match the structure the method preserves.]


#heading(level: 2)[The unsupervised workflow]


#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/3d175b8c6ceb3302.svg")], caption: [The unsupervised workflow, from defining the structure sought to using it on new or downstream data. Checking stability and meaning is the step a label would otherwise have done.]) <fig:unsup-workflow>

Describing a fixed dataset need not require a split. Claims about new data or downstream prediction do: fit on training rows and evaluate held-out cases, as in Labs~4--5.


#heading(level: 2)[Scaling and representation matter even more here]


In supervised learning, a poor representation shows up as a poor validation score. Here nothing protests. Scaling, weighting, encoding and distance simply define what the method can see.

#callout("workedexample", title: [Worked example])[Take the same 5,878 customers and the same $K$-means with four groups. On logged and standardized columns, and on standardized columns without the logs, the two groupings agree with an adjusted Rand index of only 0.172 (1 is identical, and 0 is chance). Now drop the scaling too. Spend in pounds has a standard deviation of 14,440.9, against 209.4 days of recency and 13.0 orders, and the grouping becomes identical to clustering on spend alone, with an index of 1.000: recency and orders no longer count at all. Each result looks like a tidy clustering, and nothing warns you which one you got.]

#callout("keyidea", title: [Key idea])[There is no label to reveal a poor representation, so justify the scaling and distance choices before interpreting the result.]

#callout("chapterrecap", title: [Chapter recap])[- Unsupervised learning has no answer column, but it still has a model, a loss and an optimizer.

- The question picks the family: groups, fewer columns, unusual cases, density, or co-occurrence.

- No universal accuracy exists. Combine internal evidence, external evidence where it exists, and practical usefulness.

- Nothing protests when the representation is wrong, so justify scaling before interpreting. Changing one column's units changed the mall clustering completely.]

#callout("quickcheck", title: [Check your understanding])[+ Why is there no universal unsupervised-learning accuracy score?

+ Give one internal, one external, and one downstream form of evidence that could support an unsupervised result.

+ When does an unsupervised project need a held-out split even though no label is used during fitting?

+ A clustering looks tidy. Then income is re-expressed in cents and the clusters change completely. What does that tell you, and what should you do?]
