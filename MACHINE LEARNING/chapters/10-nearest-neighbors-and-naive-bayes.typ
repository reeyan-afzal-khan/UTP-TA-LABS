#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-nearest-neighbors-and-naive-bayes")


#heading(level: 1)[Nearest Neighbors and Naive Bayes]
 <ch:knn-nb>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Distance measures from #ref(label("ch:foundations"), supplement: [Chapter]), Bayes' theorem from #ref(label("ch:foundations"), supplement: [Chapter]), and model-selection ideas from #ref(label("ch:training"), supplement: [Chapter]).

*By the end, you can:* classify and regress with $k$ nearest neighbors by hand; explain what $k$ and scaling do; compute a naive Bayes prediction from counts; explain smoothing; and say what each method assumes.]

New in town and looking for a good place to eat? You could read a theory of restaurants, or you could ask a few people who live nearby what they like. $k$-nearest neighbors does the second. Naive Bayes is more like a detective weighing clues: each clue shifts the odds a little, and the clues are combined as if they had nothing to do with each other. Both are quick to build, easy to check by hand, and useful baselines.


#heading(level: 2)[$k$-nearest neighbors]
 <sec:knn>

$k$-NN has no training phase worth the name: it simply #emph[stores] the training data. All the work happens at prediction time:

+ compute the distance from the new observation to every stored training observation;

+ keep the $k$ closest ones --- the #strong[neighbors];

+ for classification, predict the majority class among the neighbors; for regression, predict the average of their labels.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/c6dbe79a1caeba5f.svg")], caption: [$k$-nearest neighbors classifies a new point by a vote among the $k$ closest training observations.]) <fig:knn>

#callout("workedexample", title: [Worked example])[Training data: $A = \( 1 \, 1 \)$ and $B = \( 2 \, 1 \)$ labeled Red; $C = \( 4 \, 4 \)$ and $D = \( 5 \, 4 \)$ labeled Blue. Classify the new point $\( 2 \, 2 \)$ with $k = 3$ using Euclidean distance: $ d_A = sqrt(1^2 + 1^2) approx 1.41 \, #h(2em) d_B = sqrt(0^2 + 1^2) = 1.00 \,\
d_C = sqrt(2^2 + 2^2) approx 2.83 \, #h(2em) d_D = sqrt(3^2 + 2^2) approx 3.61 . $ The three nearest are $B$ (Red), $A$ (Red), and $C$ (Blue). The vote is Red 2, Blue 1, so the prediction is Red.]

#callout("workedexample", title: [Worked example])[Neighbors also predict numbers. A student studied 12.5 hours; what mark should the tutor expect? The nearest three in the study log are F (12 hours, mark 77), G (14 hours, 62) and E (10 hours, 68), and their average is 69.0. Unlike a straight line, this rule has no fixed shape, so it follows the arch of #ref(label("fig:three-correlations"), supplement: [Figure]) without being told about it.]


#heading(level: 3)[Choosing $k$]


The single hyperparameter $k$ is a smoothness dial:

- #strong[Small $k$] gives a flexible boundary that follows local patterns but also noise: low bias, high variance.

- #strong[Large $k$] smooths the boundary but can blur distinctions. At $k = n$, classification always predicts the majority class: high bias, low variance.

Validate $k$. Odd $k$ avoids binary majority-vote ties; distance weighting gives nearer neighbors more influence.

Lab~3 shows this on 20,000 personal loans, of which 19% defaulted. Cross-validated ROC AUC is 0.552 at $k = 1$, 0.632 at 5, 0.692 at 25, 0.710 at 101, 0.719 at 801 and 0.717 at 3,201. One borrower's nearest neighbor says almost nothing about them, because credit data is noisy: borrowers who look alike on paper repay or default for reasons no table records. The default rate among hundreds of similar borrowers is informative, so the curve climbs until neighborhoods hold a few hundred runs. Where it peaks depends on the data, which is why $k$ is validated, not assumed.


#heading(level: 3)[What $k$-NN is sensitive to]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Sensitivity], [Why it matters], [Practical response],),
    table.hline(),
    [Feature scale], [Distance inherits the unit problem from #ref(label("sec:scaling"), supplement: [Section]): an unscaled speed column, measured in thousands of rpm, would decide every neighbor on its own.], [Standardize inside the pipeline, as Labs~1 and~3 do.],
    [Irrelevant features], [Every feature affects the distance, so noise features dilute the signal.], [Feature selection helps $k$-NN more than most models.],
    [High dimensions], [With many weak or noisy features, distance contrast can shrink --- the #strong[curse of dimensionality] --- and "nearest" may stop meaning "similar."], [Feature selection or dimensionality reduction (#ref(label("ch:dimred"), supplement: [Chapter])) can help.],
    [Dataset size], [Predicting requires comparing against the whole training set.], [Tree-based indexes (KD-trees, ball trees) and approximate nearest-neighbor methods make this workable at scale.],
  )]
  , kind: table
  )

#callout("workedexample", title: [Worked example])[#strong[Scale.] Lab~3's $k = 801$ model on standardized loans scores a cross-validated ROC AUC of 0.719 and a validation ROC AUC of 0.723. On raw units, where the loan amount (standard deviation \$8,487) dominates every distance and the interest rate (4.3 points) barely counts, those fall to 0.571 and 0.586. The model and the rows are the same; only the ruler changed.

#strong[Dimensions.] Scatter 500 random points in a unit cube and compare one point's farthest neighbor with its nearest. In 2 dimensions the farthest is 35.61 times further away than the nearest. In 10 dimensions the ratio is 4.68, in 100 it is 1.35, and in 1,000 it is 1.11. When everything is about equally far, "nearest" stops meaning much.]

#callout("intuition", title: [Plain idea])[$k$-NN never builds a theory of the data; it just answers every question with "let me check what similar past cases did." That makes it honest and flexible, and completely dependent on the distance measuring a similarity that matters.]


#heading(level: 2)[How $k$ reshapes the boundary]


The boundary changes as $k$ changes.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/f8be9456344b9919.svg")], caption: [How $k$ reshapes the boundary. With $k = 1$ the boundary is jagged and forms an island around an isolated point; with $k = 15$ the surrounding votes smooth it away.]) <fig:knn-k>

#callout("intuition", title: [Plain idea])[At $k = 1$, the boundary forms an island around the isolated orange point. At $k = 15$, surrounding blue votes outweigh it. Smoothing reduces sensitivity to isolated noise.]


#heading(level: 3)[SMOTE: nearest neighbors used to invent minority examples]
 <sec:smote>

#ref(label("ch:training"), supplement: [Chapter]) listed SMOTE as one way to handle a rare class. Its mechanics are pure $k$-NN. Take one minority-class row, find its $k$ nearest #emph[minority] neighbors, pick one at random, and create a new synthetic row somewhere on the straight line between the two. Between $\( 1 \, 2 \)$ and $\( 3 \, 6 \)$, a quarter of the way along, that is $\( 1.5 \, 3 \)$. Repeat until the classes are as balanced as you want.

SMOTE inherits distance-scaling sensitivity. Interpolation can also create invalid categorical or binary values, so use appropriate representations and methods:

- scale the features first, inside the pipeline;

- split first, and synthesize only from the training portion of each fold, never from held-out rows.

#callout("modelcard", title: [The recipe: $k$-nearest neighbors])[*1. Model* The stored training rows, plus a distance and a value of $k$.

*2. Loss* None during fitting. Validation error is used only to choose $k$.

*3. Optimizer* None. All the work happens at prediction time, which is why fitting is instant and predicting is slow.]


#heading(level: 2)[Naive Bayes]
 <sec:naive-bayes>

#callout("analogy", title: [Analogy])[A detective hears several witnesses. Each one shifts the odds a little, and the detective multiplies those shifts together as if the witnesses had never spoken to each other. That assumption is usually false, which is why this method is called naive. It still tends to pick the right suspect, even when it overstates its confidence.]

Naive Bayes turns classification into the question Bayes' theorem was built for: given the observed features, which class is most probable? $ P \( y divides x_1 \, dots.h \, x_p \) #h(0em) prop #h(0em) P \( y \) product_(j = 1)^p P \( x_j divides y \) . $ $P \( y \)$ is the class #strong[prior]; $P \( x_j divides y \)$ is a feature #strong[likelihood]. Multiplying likelihoods assumes conditional independence (#ref(label("ch:foundations"), supplement: [Chapter])). Though often unrealistic, this can still rank classes usefully.

Predict $hat(y) = "argmax"_y P \( y \) product_j P \( x_j divides y \)$. Compute in log space to avoid underflow.

#callout("workedexample", title: [Worked example])[A real calculation on the 7,043 telecom customers of Labs~1 and~2. Will a customer on a month-to-month contract with fibre internet leave? 1,869 customers left and 5,174 stayed. Among the 1,869 who left, 1,655 were on month-to-month contracts and 1,297 had fibre. Among the 5,174 who stayed, 2,220 were month-to-month and 1,799 had fibre. Multiply the prior by each clue: $ upright("left: ") 1869 / 7043 times 1655 / 1869 times 1297 / 1869 = 0.1631 \, #h(2em) upright("stayed: ") 5174 / 7043 times 2220 / 5174 times 1799 / 5174 = 0.1096 . $ Normalizing gives $0.1631 \/ \( 0.1631 + 0.1096 \) = 0.598$. The table can check the answer directly: 1,162 of the 2,128 such customers left, a rate of 0.546. Naive Bayes got the side right and overshot the probability, because the contract and the internet service are not independent clues about leaving: customers who choose one often choose the other, so the model counts the same evidence twice. That pattern is typical: useful rankings, unreliable probabilities.]


#heading(level: 3)[Three standard variants]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Variant], [Feature type], [How it models the features],),
    table.hline(),
    [Gaussian NB], [Continuous features], [Each $P \( x_j divides y \)$ is a normal density with the class-specific mean and variance of feature $j$.],
    [Multinomial NB], [Count data, such as word counts], [$P \( x_j divides y \)$ is the probability of word $j$ in class $y$'s text, and repeated words count repeatedly. It is the workhorse for text classification.],
    [Bernoulli NB], [Binary presence/absence features], [Explicitly models both a word appearing and a word being absent.],
  )]
  , kind: table
  )


#heading(level: 3)[Laplace smoothing]


Suppose "lunch" never appeared in a spam message in training. Its raw probability given spam is then zero, and one zero wipes out the whole product, however spammy the rest of the message is. One unseen word should not have a veto.

Raw counts assign zero probability to unseen class--word pairs, eliminating the whole product. #strong[Laplace (add-one) smoothing] adds one to every count: $ P \( w divides y \) = frac("count" \( w \, y \) + 1, "total words in " y + V) \, $ where $V$ is vocabulary size. Smoothing prevents zero probabilities.

#callout("workedexample", title: [Worked example])[A tiny spam filter with vocabulary ${$money, free, meeting, lunch$}$ ($V = 4$) is trained on 10 words of spam and 10 words of ham, with equal priors $P \( upright("spam") \) = P \( upright("ham") \) = 0.5$:

#figure(
  align(center)[#table(
    columns: 5,
    align: (left,center,center,center,center,),
    table.header([raw counts], [money], [free], [meeting], [lunch],),
    table.hline(),
    [spam (10 words)], [5], [4], [1], [0],
    [ham (10 words)], [1], [1], [5], [3],
  )]
  , kind: table
  )

With smoothing, every likelihood is $\( upright("count") + 1 \) \/ \( 10 + 4 \)$; for example $P \( upright("money") divides upright("spam") \) = 6 \/ 14$ and $P \( upright("money") divides upright("ham") \) = 2 \/ 14$. Classify the message "free money": $ upright("spam score") = 0.5 times 6 / 14 times 5 / 14 = 15 / 196 \, #h(2em) upright("ham score") = 0.5 times 2 / 14 times 2 / 14 = 2 / 196 . $ Normalizing gives spam probability $15 \/ \( 15 + 2 \) approx 0.88$. Without smoothing, any message containing "lunch" would receive zero spam probability.]


#heading(level: 3)[Strengths and limitations]


- Per-feature statistics make training and prediction efficient, especially for sparse text.

- Few estimated interactions make it effective with limited data.

- Correlated evidence can produce overconfident probabilities; validate calibration when risk estimates matter (#ref(label("ch:evaluation"), supplement: [Chapter])).

- Conditional independence prevents explicit modeling of feature interactions.

#callout("keyidea", title: [Key idea])[$k$-NN and naive Bayes make opposite simplifications. $k$-NN keeps the training examples rather than estimating a fixed parametric form, but it still assumes that the chosen distance and local neighborhood are meaningful. Naive Bayes compresses the data into per-class, per-feature summaries and assumes conditional independence. Both are quick to build, valuable as baselines, and clear about what they ignore.]

#callout("modelcard", title: [The recipe: Naive Bayes])[*1. Model* A class prior times one small distribution per feature, assumed independent within each class.

*2. Loss* The negative likelihood of the training data, the same idea as log loss.

*3. Optimizer* Counting. The best prior and per-feature distributions have a closed form, so training is one pass over the data.]

#callout("modelcard", title: [$k$-NN and Naive Bayes - Quick Guide])[#block[
ll l

& $k$-nearest neighbors & Naive Bayes \
Core idea & Predict from nearby training examples & Combine class prior with per-feature evidence Best when & Local similarity is meaningful and data is not too large & Fast probabilistic classification is needed, especially for count or text features Main controls & Number of neighbors, distance, weighting & Distribution variant, smoothing strength Main risks & Scale, irrelevant features, slow prediction, high dimensions & Unrealistic independence assumption, probability calibration

]]

#callout("chapterrecap", title: [Chapter recap])[- $k$-NN stores the rows, then votes or averages among the $k$ closest. Small $k$ follows noise, and large $k$ blurs.

- It depends entirely on the distance: scale the features, and beware of many weak ones.

- Naive Bayes multiplies a prior by per-feature clues, treating them as independent. That is often good enough to rank, and rarely good enough to trust as a probability.

- Smoothing stops one unseen word from zeroing out a class. Work in logs to avoid underflow.]

#callout("quickcheck", title: [Check your understanding])[+ Why is feature scaling usually essential for $k$-NN, and what role does $k$ play in the bias--variance trade-off?

+ Why can $k$-NN become expensive at prediction time even though its training step is simple?

+ Training points are $\( 0 \, 0 \)$ Red, $\( 1 \, 0 \)$ Red, $\( 3 \, 0 \)$ Blue, $\( 4 \, 0 \)$ Blue. With $k = 3$, what is predicted for $\( 1 \, 1 \)$?

+ In the spam example, what would $P \( upright("lunch") divides upright("spam") \)$ be with and without Laplace smoothing?

+ Naive Bayes gave 0.875 where the true rate was 0.965. Which assumption explains the gap?]
