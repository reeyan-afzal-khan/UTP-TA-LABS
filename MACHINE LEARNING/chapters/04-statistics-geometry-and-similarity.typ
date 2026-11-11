#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-statistics-geometry-and-similarity")


#heading(level: 1)[Statistics, Geometry, and Similarity]
 <ch:foundations>
#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* #ref(label("ch:data"), supplement: [Chapter]), #ref(label("ch:learning"), supplement: [Chapter]), and comfort with arithmetic, fractions, powers and basic algebra.

*By the end, you can:* describe a column by its center and spread; read a correlation and know what it hides; reason with base rates; multiply matrices by checking shapes; measure distance and similarity; and say what a gradient is.]

This chapter holds the mathematics the rest of the book leans on, and nothing more. Part~A is about columns: where they sit, how much they spread, and which ones move together. Part~B is about rows: each row of a table is an arrow in space, and most of machine learning is arithmetic on those arrows. Both parts use the tutor's study log from #ref(label("fig:study-log"), supplement: [Figure]) wherever they can.

#callout("secondpass", title: [Second pass])[#strong[Second pass:] standard errors, confidence intervals, bootstrap, distributions, Bayes' algebra, inverses, eigenvectors/SVD, and curvature. These need not delay the first models.]


#heading(level: 2, numbering: none)[Part A: Describe data with statistics and probability]
 
#heading(level: 2)[An average hides almost everything]


Here are the marks of two revision groups. Both average 56.1.

#code-block("steady group: 54 55 56 56 56 57 57 57 56 57\nstudy log:    47 50 59 65 68 77 62 52 43 38", lang: "text")

The first group is uniform and the second is all over the place, yet the average cannot tell them apart. A #strong[distribution] describes which values occur and how often, and two questions come first: where is the center, and how spread out are the values?


#heading(level: 3)[Mean and median]


For values $x_1 \, dots.h \, x_N$, the mean is $ mu = 1 / N sum_(i = 1)^N x_i . $ The symbol $sum$ means summation: add the $N$ values, then divide by $N$. A sample's mean is usually written $macron(x)$ and is calculated the same way. The #strong[median] is the middle value after sorting, or the midpoint of the two middle values, and it is less affected by extreme values.

#callout("workedexample", title: [Worked example])[For $30 \, 32 \, 35 \, 38 \, 500$, the mean is $127$ and median $35$. The median better describes typical income here because the extreme value pulls the mean upward.]


#heading(level: 3)[Variance and standard deviation]


To put a number on spread, take each value's distance from the mean, square it so that nothing cancels, and average the squares. That is the #strong[variance]: $ sigma^2 = 1 / N sum_(i = 1)^N \( x_i - mu \)^2 . $ The result is in squared marks, which nobody can picture, so we take the square root to get back to plain marks. That is the #strong[standard deviation], the typical distance from the mean: $ sigma = sqrt(sigma^2) . $

#callout("workedexample", title: [Worked example])[For $2 \, 4 \, 6$, the mean is $4$. The distances from the mean are $- 2 \, 0 \, 2$. Squaring gives $4 \, 0 \, 4$, so the variance is $8 \/ 3 approx 2.67$ and the standard deviation is about $1.63$.

For the two groups above: the steady group has variance 0.89 and standard deviation 0.94, while the study log has variance 133.69 and standard deviation 11.56. So a typical student in the log sits about 12 marks from the average. Same mean, very different groups.]


#heading(level: 3)[Quantiles and the interquartile range]


A quantile is a cut point in sorted data. The first quartile $Q_1$ has about 25% of values below it, and the third quartile $Q_3$ has about 75% below it. The interquartile range is $ "IQR" = Q_3 - Q_1 . $ It measures the width of the middle half of the data and is resistant to extreme values.

In the study log the sorted marks run 38, 43, 47, 50, 52, 59, 62, 65, 68, 77. The median is 55.5, $Q_1$ is 47.75 and $Q_3$ is 64.25, so the middle half of the group spans 16.5 marks.

#callout("keyidea", title: [Key idea])[Use the mean and standard deviation for roughly symmetric data without severe outliers. Use the median and IQR when the distribution is skewed or contains extreme values.]


#heading(level: 2)[Mean versus median, drawn]


The mean and median agree on symmetric data and disagree sharply on skewed data. That disagreement is itself a useful diagnostic.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/95b1e08bd741e0bc.cetz.json") #diagram-drawing("/MACHINE LEARNING/figures/diagrams/38b96451de4b35cb.cetz.json")], caption: [Mean and median on two distributions of 50 values each. On symmetric data they coincide at 4; on right-skewed data the mean, 2.44, is pulled towards the long tail while the median stays at 2 with the bulk of the values.]) <fig:mean-median>

#callout("keyidea", title: [Key idea])[A mean far above the median suggests right skew. Consider a log transform or robust scaler; extreme errors also affect RMSE more than MAE (#ref(label("ch:evaluation"), supplement: [Chapter])).]


#heading(level: 2)[The normal distribution]


The normal distribution is the familiar bell-shaped curve. It is controlled by a mean $mu$ and standard deviation $sigma$: $ f \( x \) = frac(1, sigma sqrt(2 pi)) exp #h(-1em) [- 1 / 2 (frac(x - mu, sigma))^2] . $

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/04c8182fc6debb50.cetz.json")], caption: [The standard normal distribution. About 68% of values lie within one standard deviation of the mean.]) <fig:normal>

Many measurement errors and averages are approximately normal, but real data should not be assumed normal without inspection.

#callout("intuition", title: [Plain idea])[$mu$ sets the bell's center; $sigma$ sets its width.]


#heading(level: 2)[Population, sample, and sampling bias]


#callout("analogy", title: [Analogy])[A spoonful tells a cook how the whole pot tastes, provided the pot was stirred. Tasting ten spoonfuls from the top of an unstirred pot just repeats the mistake with more confidence. That is the difference between a small sample and a biased one.]

A #strong[sample] is the observed subset of a #strong[population]. Sample statistics estimate population parameters.

For a sample of size $n$, the common sample variance is $ s^2 = frac(1, n - 1) sum_(i = 1)^n \( x_i - macron(x) \)^2 . $ The denominator $n - 1$ corrects the tendency to underestimate population variance when deviations are measured around the sample mean.

#callout("pitfall", title: [Common mistake])[More observations do not correct systematic sampling bias.]


#heading(level: 2)[Standard error and confidence intervals]


Standard deviation describes variation among individual observations. #strong[Standard error] describes uncertainty in an estimate. For a sample mean, $ "SE" \( macron(x) \) = s / sqrt(n) . $ Standard error falls as $1 \/ sqrt(n)$: halving it requires about four times the data.

For independent, identically distributed observations with finite variance, sample means approach normality as sample size grows. Small samples, heavy tails, or dependence can invalidate the approximation. Under suitable conditions: $ macron(x) plus.minus z_(1 - alpha \/ 2) s / sqrt(n) . $

A valid 95% confidence procedure covers the true parameter in about 95% of repeated samples.

#callout("workedexample", title: [Worked example])[Treat the ten marks in the log as a sample. The sample standard deviation (dividing by $n - 1$) is $s = 12.19$, so $ "SE" \( macron(x) \) = 12.19 / sqrt(10) = 3.85 \, #h(2em) 56.1 plus.minus 1.96 times 3.85 #h(0em) upright(" gives ") #h(0em) 48.5 upright(" to ") 63.7 . $ Ten rows is small for this formula, so read the interval as rough. The lesson it carries is sound: with ten students, the average mark is only known to within several marks either way, and model scores on small validation sets are just as shaky. #ref(label("ch:evaluation"), supplement: [Chapter]) applies this to a real model.]


#heading(level: 3)[The bootstrap]


The #strong[bootstrap] estimates sampling variability by repeatedly resampling observations with replacement and recalculating the statistic.

+ Draw $n$ rows with replacement from the $n$ observed rows.

+ Recalculate the statistic, such as a median or a difference in model loss.

+ Repeat many times and use suitable quantiles as an interval.

#callout("workedexample", title: [Worked example])[Five thousand bootstrap resamples of the ten marks give a 95% interval for the median of 46.5 to 65.0. No formula for the standard error of a median was needed, only the ability to resample and recompute.]

Resampling must preserve dependence: use blocks for time series, groups for repeated measurements, and matched observations for paired comparisons.


#heading(level: 2)[Probability basics]


A probability lies between 0 and 1. For events $A$ and $B$:

- $P \( A \)$ is the probability of $A$.

- $P \( A inter B \)$ is the probability that both occur.

- $P \( A union B \)$ is the probability that at least one occurs.

- $P \( A divides B \)$ is the probability of $A$ when $B$ is known.

The multiplication rule is $ P \( A inter B \) = P \( A \) P \( B divides A \) . $ Events are independent when knowing one does not change the probability of the other: $ P \( A inter B \) = P \( A \) P \( B \) . $


#heading(level: 2)[Bayes' theorem]


#callout("analogy", title: [Analogy])[A smoke alarm rings. How worried should you be? That depends on how good the alarm is, and also on how often there really is a fire. Most rings are burnt toast, simply because burnt toast is so much more common than fires. Bayes' theorem is the arithmetic of that reasoning.]

Bayes' theorem reverses a conditional probability: $ P \( A divides B \) = frac(P \( B divides A \) P \( A \), P \( B \)) . $

/ Prior: #block[
$P \( A \)$: belief before seeing new evidence.
]

/ Likelihood: #block[
$P \( B divides A \)$: how likely the evidence is if $A$ is true.
]

/ Posterior: #block[
$P \( A divides B \)$: updated belief after seeing the evidence.
]

#callout("workedexample", title: [Worked example])[A condition affects 1% of people. A test detects 90% of true cases and gives a false positive for 5% of people without the condition. Count people rather than probabilities. In a town of 10,000:

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,center,center,center,),
    table.header([], [Have the condition], [Do not], [Total],),
    table.hline(),
    [Test positive], [90], [495], [585],
    [Test negative], [10], [9,405], [9,415],
    [Total], [100], [9,900], [10,000],
  )]
  , kind: table
  )

Of the 585 people who test positive, 90 have the condition, so the chance is $90 \/ 585 = 0.154$. The formula says the same: $ P \( + \) = 0.90 \( 0.01 \) + 0.05 \( 0.99 \) = 0.0585 \, #h(2em) P \( upright("condition") divides + \) = frac(0.90 \( 0.01 \), 0.0585) approx 0.154 . $ A positive result means about a 15.4% chance of the condition, not 90%, because the condition is rare.]

#callout("keyidea", title: [Key idea])[Always consider the base rate. Strong-looking evidence can still lead to a modest posterior probability when the event is rare.]


#heading(level: 2)[Random variables and common distributions]


A random variable assigns a number to an uncertain outcome. Its expectation is a probability-weighted average. For a discrete random variable, $ bb(E) \[ X \] = sum_x x P \( X = x \) . $

Common distributions include:

/ Bernoulli: #block[
One binary outcome with probability $p$.
]

/ Binomial: #block[
Number of successes in $n$ independent Bernoulli trials.
]

/ Categorical: #block[
One result from several classes.
]

/ Poisson: #block[
Count of events in a fixed interval under simplifying assumptions.
]

/ Uniform: #block[
All values in a range have equal density, or all finite outcomes have equal probability.
]

/ Normal: #block[
Continuous values concentrated symmetrically around a mean.
]

Probability distributions connect directly to loss functions. Gaussian error leads naturally to squared-error regression, while a Bernoulli model leads naturally to binary cross-entropy.


#heading(level: 2)[Covariance and correlation]
 <sec:correlation>

After scaling, every column has the same spread, so spread can no longer tell columns apart. What still differs is how they move together. Rewrite each value as a number of standard deviations from its column's mean. Multiply two columns' values row by row, and average the products. When both columns sit above their means together, or below together, the products come out positive. That average is the #strong[correlation].

Covariance describes whether two variables tend to move together: $ "Cov" \( X \, Y \) = bb(E) \[ \( X - mu_X \) \( Y - mu_Y \) \] . $ Pearson correlation standardizes covariance: $ rho_(X \, Y) = frac("Cov" \( X \, Y \), sigma_X sigma_Y) . $ It lies between $- 1$ and $1$ and measures linear association.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/226b8367254ca56b.cetz.json")], caption: [Three pairs of columns from the study log. Left: hours and sleep are mirror twins, nearly one story told twice. Middle: lectures and mark rise together. Right: hours and mark have a correlation close to zero even though they are strongly related, because a straight line through an arch comes out almost flat.]) <fig:three-correlations>

#callout("keyidea", title: [Key idea])[Correlation near $plus.minus 1$ finds twins: two columns telling one story, so one could nearly be dropped. Correlation near 0 means no #emph[straight-line] connection, and it does not mean no connection. Always plot the pair.]

#callout("pitfall", title: [Common mistake])[Correlation does not establish causation: confounding, reverse direction, or selection may explain it.]

#callout("optionaltopic", title: [Beyond the core])[#strong[Likelihood and maximum likelihood estimation.] Given data $x_1 \, dots.h \, x_n$, the likelihood treats the probability of the observed data as a function of a parameter $theta$: $ L \( theta \) = product_(i = 1)^n p \( x_i divides theta \) . $ Maximum likelihood selects the parameter making the observations most probable. Taking logs converts products into sums: $ hat(theta)_(upright(M L E)) = "argmax"_theta sum_(i = 1)^n log p \( x_i divides theta \) . $ Many familiar machine-learning losses are negative log-likelihoods.]

#callout("optionaltopic", title: [Beyond the core])[#strong[Hypothesis tests.] A p-value is the probability, under the null model, of a result at least as extreme as observed---not the probability the null is true. Report effect size and uncertainty too.]

#callout("optionaltopic", title: [Beyond the core])[#strong[Entropy] measures uncertainty; #strong[cross-entropy] evaluates predicted probabilities; #strong[KL divergence] compares distributions (#ref(label("ch:classification"), supplement: [Chapter]), #ref(label("ch:evaluation"), supplement: [Chapter])).]


#heading(level: 2, numbering: none)[Part B: Rows as arrows]
 
#heading(level: 2)[Scalars, vectors, and matrices]


/ Scalar: #block[
One number, such as temperature $23$.
]

/ Vector: #block[
An ordered list of numbers, such as one house $bold(x) = \[ 120 \, 3 \, 8 \]^(sans(T))$.
]

/ Matrix: #block[
A rectangular table of numbers, such as a dataset with one row per house and one column per feature.
]

For $n$ observations and $p$ features, the design matrix has shape $ X in bb(R)^(n times p) . $ The first number is the number of rows; the second is the number of columns.

#callout("workedexample", title: [Worked example])[The study log is a matrix with 10 rows and 4 columns, $X in bb(R)^(10 times 4)$. Student F is the vector $\[ 12 \, 13 \, 6 \, 77 \]^(sans(T))$. Lab~1's bank-call matrix has 41,176 rows and 19 feature columns.]


#heading(level: 2)[Dot products: a shopping receipt]


#callout("analogy", title: [Analogy])[You buy 2 coffees at 3.50, 3 buns at 1.20 and 1 juice at 2.00. The bill is $2 \( 3.50 \) + 3 \( 1.20 \) + 1 \( 2.00 \) = 12.60$. Multiply matching entries and add them up: that is a dot product of a price list with a basket. A linear model does exactly this, with weights in place of prices and features in place of quantities.]

The dot product of two vectors is $ bold(a)^(sans(T)) bold(b) = sum_(j = 1)^p a_j b_j . $ It has two useful interpretations.

+ It creates a weighted sum. Linear models use $bold(w)^(sans(T)) bold(x) + b$.

+ It measures alignment. A large positive dot product means the vectors point in similar directions; a negative one means they point in opposing directions.

#callout("workedexample", title: [Worked example])[For $bold(w) = \[ 2 \, - 1 \]^(sans(T))$ and $bold(x) = \[ 3 \, 4 \]^(sans(T))$, $ bold(w)^(sans(T)) bold(x) = 2 \( 3 \) + \( - 1 \) \( 4 \) = 2 . $ A linear model with bias $b = 0.5$ would predict $2.5$.]


#heading(level: 2)[Matrix shapes: the rule that governs everything]


For matrix multiplication, inner dimensions must match; outer dimensions determine the result.

#callout("workedexample", title: [Worked example])[A matrix times a vector is one dot product per row. Put the line $upright("mark") = 3 times upright("hours") + 40$ into this form, with a column of ones to carry the 40: $ mat(delim: "[", 1, 2; 1, 4; 1, 6) mat(delim: "[", 40; 3) = mat(delim: "[", 1 \( 40 \) + 2 \( 3 \); 1 \( 40 \) + 4 \( 3 \); 1 \( 40 \) + 6 \( 3 \)) = mat(delim: "[", 46; 52; 58) . $ Shapes: $\( 3 times 2 \)$ times $\( 2 times 1 \)$ gives $\( 3 times 1 \)$. Three students go in, and three predictions come out in one multiplication.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/f49e6c0efb936910.cetz.json")], caption: [Matrix shapes in a product. The inner dimensions must match and the outer dimensions survive into the answer: an $\( n times p \)$ matrix times a $\( p times 1 \)$ vector gives an $\( n times 1 \)$ result.]) <fig:matrix-shapes>


#heading(level: 2)[Vector arithmetic]


Vectors of the same length can be added component by component: $ mat(delim: "[", 1; 2) + mat(delim: "[", 3; 4) = mat(delim: "[", 4; 6) . $ Multiplying by a scalar stretches or reverses a vector: $ 3 mat(delim: "[", 1; 2) = mat(delim: "[", 3; 6) . $


#heading(level: 2)[Norms: measuring vector size]


The $L_1$ norm is the sum of absolute values: $ parallel bold(x) parallel_1 = sum_j \| x_j \| . $ The $L_2$ norm is the ordinary straight-line length: $ parallel bold(x) parallel_2 = sqrt(sum_j x_j^2) . $ These norms appear in distance calculations and regularization.


#heading(level: 2)[Distance and similarity]


#callout("analogy", title: [Analogy])[A crow flies straight, and a taxi follows the grid. Between the same two buildings they travel different distances, and each is right for its purpose. "Close" is a choice you make when you pick a measure.]

A model often needs to decide whether two observations are close or similar.

#block[
lll

Measure & Formula or idea & Useful when \
Euclidean distance & $parallel bold(x) - bold(z) parallel_2$ & ordinary geometric distance; features are scaled Manhattan distance & $parallel bold(x) - bold(z) parallel_1$ & movement along grid-like axes; more robustness to a single large difference Cosine similarity & $frac(bold(x)^(sans(T)) bold(z), parallel bold(x) parallel_2 parallel bold(z) parallel_2)$ & direction matters more than magnitude, such as word-count vectors Jaccard similarity & overlap divided by union & sets or binary presence/absence features Hamming distance & number of unequal positions & binary strings or categorical codes

]

#callout("pitfall", title: [Common mistake])[Distance-based models can be meaningless when features use very different scales. Standardize or otherwise justify the scale before calculating distances.]


#heading(level: 3, numbering: none)[The same two points can look different under different measures]


Euclidean, Manhattan, Jaccard, Minkowski, and cosine measures encode different meanings of "close". Choose one for the representation and task.

#callout("workedexample", title: [Worked example])[For points $P = \( 1 \, 2 \)$ and $Q = \( 4 \, 6 \)$, $ d_2 \( P \, Q \) = sqrt(\( 4 - 1 \)^2 + \( 6 - 2 \)^2) = 5 \, $ while $ d_1 \( P \, Q \) = \| 4 - 1 \| + \| 6 - 2 \| = 7 . $ Euclidean distance measures the straight-line path; Manhattan distance measures the axis-by-axis path.]

The #strong[Minkowski distance] unifies both: $ d_p \( bold(x) \, bold(z) \) = (sum_j \| x_j - z_j \|^p)^(1 \/ p) . $ Minkowski uses Manhattan distance at $p = 1$ and Euclidean distance at $p = 2$. Choose $p$ to match the task.

#callout("workedexample", title: [Worked example])[For sets $A = { 0 \, 1 \, 2 \, 5 \, 6 }$ and $B = { 0 \, 2 \, 3 \, 4 \, 5 \, 7 \, 9 }$, the intersection has three elements and the union has nine. Therefore $ J \( A \, B \) = frac(\| A inter B \|, \| A union B \|) = 3 / 9 = 0.33 . $ Jaccard measures overlap among present items, ignoring shared absences.]

#callout("workedexample", title: [Worked example])[Three documents as word counts over the vocabulary (cat, dog, fish): $a = \( 2 \, 1 \, 0 \)$, $b = \( 4 \, 2 \, 0 \)$ and $c = \( 0 \, 1 \, 3 \)$. Document $b$ is $a$ written out twice as long. Euclidean distance says $a$--$b$ is 2.24 and $a$--$c$ is 3.61, so length still counts. Cosine similarity says $a$--$b$ is 1.00, the same direction, and $a$--$c$ is 0.14, nearly unrelated topics. For documents of different lengths, the angle is usually what you want.]

#callout("keyidea", title: [Key idea])[Choose representation and distance together; a computable distance need not be meaningful.]


#heading(level: 2)[Cosine similarity visually]


Cosine similarity depends on the angle $theta$ between two vectors: $ cos \( theta \) = frac(bold(x)^(sans(T)) bold(z), parallel bold(x) parallel_2 parallel bold(z) parallel_2) . $

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/26d92c0514c13939.cetz.json")], caption: [Cosine similarity depends only on the angle $theta$ between two vectors, not on their lengths.]) <fig:cosine>

A cosine similarity near 1 means similar direction, near 0 means roughly perpendicular, and near $- 1$ means opposite direction.


#heading(level: 2)[Matrices and linear transformations]


A matrix can transform one vector into another: $ bold(y) = A bold(x) . $ Depending on its values, $A$ can rotate, stretch, shrink, reflect, or combine coordinates. A linear regression model applies this same idea to many rows at once: $ hat(bold(y)) = X bold(beta) . $

#callout("intuition", title: [Plain idea])[Matrix multiplication forms weighted combinations; compatible shapes determine which products exist.]


#heading(level: 2)[Transpose, identity, and inverse]


The transpose switches rows and columns. If $A$ is $m times p$, then $A^(sans(T))$ is $p times m$.

The identity matrix $I$ acts like the number 1: $ I bold(x) = bold(x) . $ When an inverse exists, $ A^(- 1) A = I . $ Solve linear systems numerically rather than explicitly computing inverses.


#heading(level: 2)[Gradients: which way changes the loss?]


A model usually has many numbers to adjust at once. Stand at one setting of them and ask of each number in turn: if I nudge only this one, how fast does the loss change? Each answer is a #strong[partial derivative], and the list of answers is the #strong[gradient].

For a function with several parameters, the gradient collects all partial derivatives: $ nabla_(bold(theta)) J = mat(delim: "[", frac(partial J, partial theta_1); dots.v; frac(partial J, partial theta_p)) . $ The gradient points toward the fastest increase in $J$. To reduce a loss, gradient descent moves in the opposite direction: $ bold(theta) arrow.l bold(theta) - alpha nabla_(bold(theta)) J . $

#callout("workedexample", title: [Worked example])[Take guess A from #ref(label("ch:orientation"), supplement: [Chapter]), $upright("mark") = 2 times upright("hours") + 47$, on the first six students. Its errors are $- 4 \, - 5 \, 0 \, 2 \, 1 \, 6$. For mean squared error the two slopes are $ frac(partial J, partial w) = - 2 / n sum_i e_i x_i = - 23.33 \, #h(2em) frac(partial J, partial b) = - 2 / n sum_i e_i = 0 . $ The gradient says: raising $w$ lowers the loss quickly, and $b$ is fine for now. That matches what we know, since the best slope is 3 and this guess is at 2. Gradient descent (#ref(label("sec:gradient-descent"), supplement: [Section])) would step $w$ upward and leave $b$ alone on this step.]

#callout("optionaltopic", title: [Beyond the core])[#strong[Eigenvectors and SVD.] An eigenvector is scaled by a square matrix. SVD factors a matrix into rotations/reflections and scaling. Both reveal directions used in PCA (#ref(label("ch:dimred"), supplement: [Chapter])).]

#callout("optionaltopic", title: [Beyond the core])[#strong[Hessian.] This matrix of second derivatives describes curvature: positive in bowl-like directions, negative in hill-like directions. It supports advanced optimization.]

#callout("keyidea", title: [Key idea])[Vectors represent observations and parameters; matrices represent datasets and transformations; dot products create weighted sums; distances compare observations; and gradients tell optimization which direction to move.]

#callout("chapterrecap", title: [Chapter recap])[- Report a center and a spread. Mean and standard deviation suit symmetric columns; median and IQR suit skewed ones.

- A sample estimates a population. More rows shrink random error as $1 \/ sqrt(n)$, and they do nothing for bias.

- Rare events stay fairly unlikely even after strong evidence. Count people to check the arithmetic.

- Correlation measures straight-line association. It finds twin columns and misses arches, and it never proves cause.

- A row is a vector, a table is a matrix, a linear model is a dot product, and matrix shapes must match on the inside.

- Distance depends on scale and on your choice of measure. The gradient lists one slope per parameter.]

#callout("quickcheck", title: [Check your understanding])[+ When would the median and IQR describe a distribution more faithfully than the mean and standard deviation?

+ The correlation between hours and mark in the study log is $- 0.25$. Does that mean study has little to do with the mark? How would you check?

+ A rare-disease test has 99% sensitivity and a 1% false-positive rate, and 1 person in 1,000 has the disease. Out of 100,000 people, about how many test positive, and what fraction of those have it?

+ If $X$ has shape $n times p$, what shape must a coefficient vector have for $X bold(w)$ to produce one prediction per row?

+ Why can standardizing features change a nearest-neighbor or clustering result even though the observations themselves did not change?

+ What does a gradient of zero tell you about where you are standing on a bowl?]
