#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "14-nearest-neighbors-and-naive-bayes")

= Nearest Neighbors and Naive Bayes <ch:knn-nb>

#chapterguide[Distance measures from #chapref(<ch:foundations>), Bayes’ theorem from #chapref(<ch:foundations>), and model-selection ideas from #chapref(<ch:training>).][classify and regress with $k$ nearest neighbors by hand; explain what $k$ and scaling do; compute a naive Bayes prediction from counts; explain smoothing; and say what each method assumes.]

New in town and looking for a good place to eat? You could read a theory of restaurants, or you could ask a few people who live nearby what they like. $k$-nearest neighbors does the second. Naive Bayes is more like a detective weighing clues: each clue shifts the odds a little, and the clues are combined as if they had nothing to do with each other. Both are quick to build, easy to check by hand, and useful baselines.

== $k$-nearest neighbors <sec:knn>

$k$-NN has no training phase worth the name: it simply #emph[stores] the training data. All the work happens at prediction time:

+ compute the distance from the new observation to every stored training observation;
+ keep the $k$ closest ones --- the #term[neighbors];
+ for classification, predict the majority class among the neighbors; for regression, predict the average of their labels.

#utpfig([$k$-nearest neighbors classifies a new point by a vote among the $k$ closest training observations.], label: <fig:knn>)[
  #canvas(scale: 1.05, {
    for p in ((1, 1), (1.5, 2), (2, 1.2), (0.8, 2.2)) {
      circle-at(p, 2.406pt, fill: auto, draw: none)
    }
    for p in ((3.5, 3), (4, 2.5), (3, 3.6), (4.3, 3.4)) {
      circle-at(p, 2.406pt, line-width: widths.thick, fill: pale-orange)
    }
    node((2.6, 2.4), [], name: "q", font: font("small"), shape: "star", star-points: 5, star-point-ratio: 2.4, fill: black, inner-sep: 1.594pt)
    circle-at((2.6, 2.4), 1.32, dash: "dashed")
    node((2.6, 2.3), [new point], font: font("small"), yshift: -1.9925pt, anchor: "north")
    node((0.55, 3.5), [$bullet$ = class A], font: font("small"), align: left)
    node((4.6, 1.5), [$compose$ = class B], font: font("small"), align: left)
    node((2.6, 0.3), [$k=3$ neighborhood: two of the three \
  nearest points are class B $arrow.r$ predict B], font: font("small"), align: center)
  })
]

#workedexample[
  Training data: $A=(1,1)$ and $B=(2,1)$ labeled Red; $C=(4,4)$ and $D=(5,4)$ labeled Blue. Classify the new point $(2,2)$ with $k=3$ using Euclidean distance:

  $ d_A=sqrt(1^2+1^2) approx 1.41, wide d_B=sqrt(0^2+1^2)=1.00, \
   d_C=sqrt(2^2+2^2) approx 2.83, wide d_D=sqrt(3^2+2^2) approx 3.61. $

  The three nearest are $B$ (Red), $A$ (Red), and $C$ (Blue). The vote is Red 2, Blue 1, so the prediction is Red.
]

#workedexample[
  Neighbors also predict numbers. A student studied 12.5 hours; what mark should the tutor expect? The nearest three in the study log are F (12 hours, mark 77), G (14 hours, 62) and E (10 hours, 68), and their average is 69.0. Unlike a straight line, this rule has no fixed shape, so it follows the arch of #figref(<fig:three-correlations>) without being told about it.
]

=== Choosing $k$

The single hyperparameter $k$ is a smoothness dial:

- #term[Small $k$] gives a flexible boundary that follows local patterns but also noise: low bias, high variance.
- #term[Large $k$] smooths the boundary but can blur distinctions. At $k=n$, classification always predicts the majority class: high bias, low variance.

Validate $k$. Odd $k$ avoids binary majority-vote ties; distance weighting gives nearer neighbors more influence.

Lab~3 shows this on 20,000 personal loans, of which 19% defaulted. Cross-validated ROC AUC is 0.552 at $k=1$, 0.632 at 5, 0.692 at 25, 0.710 at 101, 0.719 at 801 and 0.717 at 3,201. One borrower’s nearest neighbor says almost nothing about them, because credit data is noisy: borrowers who look alike on paper repay or default for reasons no table records. The default rate among hundreds of similar borrowers is informative, so the curve climbs until neighborhoods hold a few hundred runs. Where it peaks depends on the data, which is why $k$ is validated, not assumed.

=== What $k$-NN is sensitive to

#utptable[
  #tabularx(
    columns: (20%, 42%, 1fr),
    styles: (navy-bold,),
    header: ([Sensitivity], [Why it matters], [Practical response]),
    [Feature scale], [Distance inherits the unit problem from #secref(<sec:scaling>): an unscaled speed column, measured in thousands of rpm, would decide every neighbor on its own.], [Standardize inside the pipeline, as Labs~1 and~3 do.],
    [Irrelevant features], [Every feature affects the distance, so noise features dilute the signal.], [Feature selection helps $k$-NN more than most models.],
    [High dimensions], [With many weak or noisy features, distance contrast can shrink --- the #term[curse of dimensionality] --- and “nearest” may stop meaning “similar.”], [Feature selection or dimensionality reduction (#chapref(<ch:dimred>)) can help.],
    [Dataset size], [Predicting requires comparing against the whole training set.], [Tree-based indexes (KD-trees, ball trees) and approximate nearest-neighbor methods make this workable at scale.],
  )
]

#workedexample[
  #strong[Scale.] Lab~3’s $k=801$ model on standardized loans scores a cross-validated ROC AUC of 0.719 and a validation ROC AUC of 0.723. On raw units, where the loan amount (standard deviation \$8,487) dominates every distance and the interest rate (4.3 points) barely counts, those fall to 0.571 and 0.586. The model and the rows are the same; only the ruler changed.

  #strong[Dimensions.] Scatter 500 random points in a unit cube and compare one point’s farthest neighbor with its nearest. In 2 dimensions the farthest is 35.61 times further away than the nearest. In 10 dimensions the ratio is 4.68, in 100 it is 1.35, and in 1,000 it is 1.11. When everything is about equally far, “nearest” stops meaning much.
]

#intuition[
  $k$-NN never builds a theory of the data; it just answers every question with “let me check what similar past cases did.” That makes it honest and flexible, and completely dependent on the distance measuring a similarity that matters.
]

== How $k$ reshapes the boundary

The boundary changes as $k$ changes.

#utpfig([How $k$ reshapes the boundary. With $k=1$ the boundary is jagged and forms an island around an isolated point; with $k=15$ the surrounding votes smooth it away.], label: <fig:knn-k>)[
  #canvas(scale: 0.88, {
    draw.scope({
      rectangle((0, 0), (3.4, 2.7), draw: muted, fill: white)
      connect((0, 1.15), (0.5, 1.4), (0.75, 0.95), (1.2, 1.5), (1.45, 1), (1.9, 1.6), (2.15, 1.05), (2.6, 1.65), (2.9, 1.1), (3.4, 1.5), line-width: widths.very-thick, rounded: 0.9963pt, draw: red)
      for p in ((0.4, 1.9), (0.9, 2.2), (1.5, 2), (2.2, 2.3), (2.8, 1.95), (1.9, 2.45)) {
        circle-at(p, 1.8411pt, fill: blue, draw: none)
      }
      for p in ((0.5, 0.5), (1.1, 0.4), (1.7, 0.6), (2.4, 0.35), (2.9, 0.6), (1.4, 0.15)) {
        circle-at(p, 1.8411pt, fill: orange, draw: none)
      }
      circle-at((1.15, 1.62), 1.8411pt, fill: orange, draw: none)
      node((1.7, 3.05), [$k=1$], font: font("small", weight: "bold", fill: navy))
      node((1.7, -0.38), [jagged, chases every point], font: font("script"), text: muted)
    })
    draw.scope({
      draw.translate((4.4, 0))
      rectangle((0, 0), (3.4, 2.7), draw: muted, fill: white)
      curve((0, 1.2), (3.4, 1.4), (1.2, 1.45), (2.2, 1.15), line-width: widths.very-thick, draw: green)
      for p in ((0.4, 1.9), (0.9, 2.2), (1.5, 2), (2.2, 2.3), (2.8, 1.95), (1.9, 2.45)) {
        circle-at(p, 1.8411pt, fill: blue, draw: none)
      }
      for p in ((0.5, 0.5), (1.1, 0.4), (1.7, 0.6), (2.4, 0.35), (2.9, 0.6), (1.4, 0.15)) {
        circle-at(p, 1.8411pt, fill: orange, draw: none)
      }
      circle-at((1.15, 1.62), 1.8411pt, fill: orange, draw: none)
      node((1.7, 3.05), [$k=15$], font: font("small", weight: "bold", fill: navy))
      node((1.7, -0.38), [smooth, ignores the odd point], font: font("script"), text: muted)
    })
  })
]

#intuition[
  At $k=1$, the boundary forms an island around the isolated orange point. At $k=15$, surrounding blue votes outweigh it. Smoothing reduces sensitivity to isolated noise.
]

=== SMOTE: nearest neighbors used to invent minority examples <sec:smote>

#chapref(<ch:training>) listed SMOTE as one way to handle a rare class. Its mechanics are pure $k$-NN. Take one minority-class row, find its $k$ nearest #emph[minority] neighbors, pick one at random, and create a new synthetic row somewhere on the straight line between the two. Between $(1,2)$ and $(3,6)$, a quarter of the way along, that is $(1.5,3)$. Repeat until the classes are as balanced as you want.

SMOTE inherits distance-scaling sensitivity. Interpolation can also create invalid categorical or binary values, so use appropriate representations and methods:

- scale the features first, inside the pipeline;
- split first, and synthesize only from the training portion of each fold, never from held-out rows.

#recipecard([$k$-nearest neighbors], [The stored training rows, plus a distance and a value of $k$.], [None during fitting. Validation error is used only to choose $k$.], [None. All the work happens at prediction time, which is why fitting is instant and predicting is slow.])

== Naive Bayes <sec:naive-bayes>

#analogy[
  A detective hears several witnesses. Each one shifts the odds a little, and the detective multiplies those shifts together as if the witnesses had never spoken to each other. That assumption is usually false, which is why this method is called naive. It still tends to pick the right suspect, even when it overstates its confidence.
]

Naive Bayes turns classification into the question Bayes’ theorem was built for: given the observed features, which class is most probable?

$ P(y mid x_1, dots.h ,x_p) med prop med P(y) product _(j=1)^p P(x_j mid y). $

$P(y)$ is the class #term[prior]; $P(x_j mid y)$ is a feature #term[likelihood]. Multiplying likelihoods assumes conditional independence (#chapref(<ch:foundations>)). Though often unrealistic, this can still rank classes usefully.

Predict $hat(y)=op("arg max", limits: #true)_y P(y) product _j P(x_j mid y)$. Compute in log space to avoid underflow.

#workedexample[
  A real calculation on the 7,043 telecom customers of Labs~1 and~2. Will a customer on a month-to-month contract with fibre internet leave? 1,869 customers left and 5,174 stayed. Among the 1,869 who left, 1,655 were on month-to-month contracts and 1,297 had fibre. Among the 5,174 who stayed, 2,220 were month-to-month and 1,799 had fibre. Multiply the prior by each clue:

  $ "left: " frac(1869, 7043) times frac(1655, 1869) times frac(1297, 1869)=0.1631, wide "stayed: " frac(5174, 7043) times frac(2220, 5174) times frac(1799, 5174)=0.1096. $

  Normalizing gives $0.1631\/(0.1631+0.1096)=0.598$. The table can check the answer directly: 1,162 of the 2,128 such customers left, a rate of 0.546. Naive Bayes got the side right and overshot the probability, because the contract and the internet service are not independent clues about leaving: customers who choose one often choose the other, so the model counts the same evidence twice. That pattern is typical: useful rankings, unreliable probabilities.
]

=== Three standard variants

#utptable[
  #tabularx(
    columns: (20%, 25%, 1fr),
    styles: (navy-bold,),
    header: ([Variant], [Feature type], [How it models the features]),
    [Gaussian NB], [Continuous features], [Each $P(x_j mid y)$ is a normal density with the class-specific mean and variance of feature $j$.],
    [Multinomial NB], [Count data, such as word counts], [$P(x_j mid y)$ is the probability of word $j$ in class $y$’s text, and repeated words count repeatedly. It is the workhorse for text classification.],
    [Bernoulli NB], [Binary presence/absence features], [Explicitly models both a word appearing and a word being absent.],
  )
]

=== Laplace smoothing

Suppose “lunch” never appeared in a spam message in training. Its raw probability given spam is then zero, and one zero wipes out the whole product, however spammy the rest of the message is. One unseen word should not have a veto.

Raw counts assign zero probability to unseen class--word pairs, eliminating the whole product. #term[Laplace (add-one) smoothing] adds one to every count:

$ P(w mid y) =frac(op("count")(w,y)+1, op("total words in")y+V), $

where $V$ is vocabulary size. Smoothing prevents zero probabilities.

#workedexample[
  A tiny spam filter with vocabulary ${$money, free, meeting, lunch$}$ ($V=4$) is trained on 10 words of spam and 10 words of ham, with equal priors $P("spam")=P("ham")=0.5$:

  #utptable[
    #tabularx(
      columns: (auto, auto, auto, auto, auto),
      align: (left, center, center, center, center),
      header: ([raw counts], [money], [free], [meeting], [lunch]),
      [spam (10 words)], [5], [4], [1], [0],
      [ham (10 words)], [1], [1], [5], [3],
    )
  ]

  With smoothing, every likelihood is $("count"+1)\/(10+4)$; for example $P("money" mid "spam")=6\/14$ and $P("money" mid "ham")=2\/14$. Classify the message “free money”:

  $ "spam score"=0.5 times inline(frac(6, 14)) times inline(frac(5, 14)) =inline(frac(15, 196)), wide "ham score"=0.5 times inline(frac(2, 14)) times inline(frac(2, 14)) =inline(frac(2, 196)). $

  Normalizing gives spam probability $15\/(15+2) approx 0.88$. Without smoothing, any message containing “lunch” would receive zero spam probability.
]

=== Strengths and limitations

- Per-feature statistics make training and prediction efficient, especially for sparse text.
- Few estimated interactions make it effective with limited data.
- Correlated evidence can produce overconfident probabilities; validate calibration when risk estimates matter (#chapref(<ch:evaluation>)).
- Conditional independence prevents explicit modeling of feature interactions.

#keyidea[
  $k$-NN and naive Bayes make opposite simplifications. $k$-NN keeps the training examples rather than estimating a fixed parametric form, but it still assumes that the chosen distance and local neighborhood are meaningful. Naive Bayes compresses the data into per-class, per-feature summaries and assumes conditional independence. Both are quick to build, valuable as baselines, and clear about what they ignore.
]

#recipecard([Naive Bayes], [A class prior times one small distribution per feature, assumed independent within each class.], [The negative likelihood of the training data, the same idea as log loss.], [Counting. The best prior and per-feature distributions have a closed form, so training is one pass over the data.])

#modelcard[$k$-NN and Naive Bayes - Quick Guide][
  #tabularx(
    columns: (22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([], [$k$-nearest neighbors], [Naive Bayes]),
    [Core idea], [Predict from nearby training examples], [Combine class prior with per-feature evidence],
    [Best when], [Local similarity is meaningful and data is not too large], [Fast probabilistic classification is needed, especially for count or text features],
    [Main controls], [Number of neighbors, distance, weighting], [Distribution variant, smoothing strength],
    [Main risks], [Scale, irrelevant features, slow prediction, high dimensions], [Unrealistic independence assumption, probability calibration],
  )
]

#chapterrecap[
  - $k$-NN stores the rows, then votes or averages among the $k$ closest. Small $k$ follows noise, and large $k$ blurs.
  - It depends entirely on the distance: scale the features, and beware of many weak ones.
  - Naive Bayes multiplies a prior by per-feature clues, treating them as independent. That is often good enough to rank, and rarely good enough to trust as a probability.
  - Smoothing stops one unseen word from zeroing out a class. Work in logs to avoid underflow.
]

#quickcheck[
  + Why is feature scaling usually essential for $k$-NN, and what role does $k$ play in the bias--variance trade-off?
  + Why can $k$-NN become expensive at prediction time even though its training step is simple?
  + Training points are $(0,0)$ Red, $(1,0)$ Red, $(3,0)$ Blue, $(4,0)$ Blue. With $k=3$, what is predicted for $(1,1)$?
  + In the spam example, what would $P("lunch" mid "spam")$ be with and without Laplace smoothing?
  + Naive Bayes gave 0.875 where the true rate was 0.965. Which assumption explains the gap?
]
