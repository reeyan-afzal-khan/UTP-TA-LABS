#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "05-statistics-geometry-and-similarity")

= Statistics, Geometry, and Similarity <ch:foundations>

#chapterguide[#chapref(<ch:data>), #chapref(<ch:learning>), and comfort with arithmetic, fractions, powers and basic algebra.][describe a column by its center and spread; read a correlation and know what it hides; reason with base rates; multiply matrices by checking shapes; measure distance and similarity; and say what a gradient is.]

This chapter holds the mathematics the rest of the book leans on, and nothing more. Part~A is about columns: where they sit, how much they spread, and which ones move together. Part~B is about rows: each row of a table is an arrow in space, and most of machine learning is arithmetic on those arrows. Both parts use the tutor’s study log from #figref(<fig:study-log>) wherever they can.

#secondpass[
  #strong[Second pass:] standard errors, confidence intervals, bootstrap, distributions, Bayes’ algebra, inverses, eigenvectors/SVD, and curvature. These need not delay the first models.
]

#heading(depth: 2, numbering: none)[Part A: Describe data with statistics and probability]

== An average hides almost everything

Here are the marks of two revision groups. Both average 56.1.

```terminal
steady group: 54 55 56 56 56 57 57 57 56 57
study log:    47 50 59 65 68 77 62 52 43 38
```

The first group is uniform and the second is all over the place, yet the average cannot tell them apart. A #term[distribution] describes which values occur and how often, and two questions come first: where is the center, and how spread out are the values?

=== Mean and median

For values $x_1, dots.h ,x_N$, the mean is

$ mu =frac(1, N) sum _(i=1)^N x_i. $

The symbol $sum$ means summation: add the $N$ values, then divide by $N$. A sample’s mean is usually written $macron(x)$ and is calculated the same way. The #term[median] is the middle value after sorting, or the midpoint of the two middle values, and it is less affected by extreme values.

#workedexample[
  For $30,32,35,38,500$, the mean is $127$ and median $35$. The median better describes typical income here because the extreme value pulls the mean upward.
]

=== Variance and standard deviation

To put a number on spread, take each value’s distance from the mean, square it so that nothing cancels, and average the squares. That is the #term[variance]:

$ sigma ^2=frac(1, N) sum _(i=1)^N(x_i- mu )^2. $

The result is in squared marks, which nobody can picture, so we take the square root to get back to plain marks. That is the #term[standard deviation], the typical distance from the mean:

$ sigma =sqrt(sigma ^2). $

#workedexample[
  For $2,4,6$, the mean is $4$. The distances from the mean are $-2,0,2$. Squaring gives $4,0,4$, so the variance is $8\/3 approx 2.67$ and the standard deviation is about $1.63$.

  For the two groups above: the steady group has variance 0.89 and standard deviation 0.94, while the study log has variance 133.69 and standard deviation 11.56. So a typical student in the log sits about 12 marks from the average. Same mean, very different groups.
]

=== Quantiles and the interquartile range

A quantile is a cut point in sorted data. The first quartile $Q_1$ has about 25% of values below it, and the third quartile $Q_3$ has about 75% below it. The interquartile range is

$ op("IQR")=Q_3-Q_1. $

It measures the width of the middle half of the data and is resistant to extreme values.

In the study log the sorted marks run 38, 43, 47, 50, 52, 59, 62, 65, 68, 77. The median is 55.5, $Q_1$ is 47.75 and $Q_3$ is 64.25, so the middle half of the group spans 16.5 marks.

#keyidea[
  Use the mean and standard deviation for roughly symmetric data without severe outliers. Use the median and IQR when the distribution is skewed or contains extreme values.
]

== Mean versus median, drawn

The mean and median agree on symmetric data and disagree sharply on skewed data. That disagreement is itself a useful diagnostic.

#utpfig([Mean and median on two distributions of 50 values each. On symmetric data they coincide at 4; on right-skewed data the mean, 2.44, is pulled towards the long tail while the median stays at 2 with the bulk of the values.], label: <fig:mean-median>)[
  #box(baseline: 100%, canvas({
    axis(width: 7.3876cm, height: 4.2cm, axis-lines: "left", title-style: font("small", weight: "bold", fill: navy), title: [Symmetric: they agree], xlabel: [Value], ylabel: [How many], label-style: font("script", fill: muted), tick-label-style: font("script", fill: muted), ybar: auto, bar-width: 6.9738pt, ymin: 0, ymax: 20, xmin: 0, xmax: 9,
      addplot(fill: pale-blue, draw: blue, coords: ((1, 2), (2, 6), (3, 12), (4, 17), (5, 12), (6, 6), (7, 2))),
      {
        connect((4, 0), (4, 19), line-width: widths.very-thick, dash: "dashed", draw: red)
        node((6.5, 17), [mean = median], font: font("script", fill: red))
      },
    )
  }))
  #h(1fr)#box(baseline: 100%, canvas({
    axis(width: 7.3876cm, height: 4.2cm, axis-lines: "left", title-style: font("small", weight: "bold", fill: navy), title: [Skewed: they split apart], xlabel: [Value], ylabel: [How many], label-style: font("script", fill: muted), tick-label-style: font("script", fill: muted), ybar: auto, bar-width: 6.9738pt, ymin: 0, ymax: 20, xmin: 0, xmax: 9,
      addplot(fill: pale-orange, draw: orange, coords: ((1, 18), (2, 13), (3, 8), (4, 5), (5, 3), (6, 2), (7, 1))),
      {
        connect((2, 0), (2, 19), line-width: widths.very-thick, dash: "dashed", draw: teal)
        connect((2.44, 0), (2.44, 19), line-width: widths.very-thick, dash: "dashed", draw: red)
        node((3, 17), [median 2], font: font("script", fill: teal), anchor: "west")
        node((3, 13.5), [mean 2.44 (pulled right)], font: font("script", fill: red), anchor: "west")
      },
    )
  }))
]

#keyidea[
  A mean far above the median suggests right skew. Consider a log transform or robust scaler; extreme errors also affect RMSE more than MAE (#chapref(<ch:evaluation>)).
]

== The normal distribution

The normal distribution is the familiar bell-shaped curve. It is controlled by a mean $mu$ and standard deviation $sigma$:

$ f(x)=frac(1, sigma sqrt(2 pi)) exp[-frac(1, 2)(frac(x- mu, sigma))^2]. $

#utpfig([The standard normal distribution. About 68% of values lie within one standard deviation of the mean.], label: <fig:normal>)[
  #canvas({
    axis(width: 13.1692cm, height: 5.3cm, axis-lines: "left", xlabel: [value], ylabel: [density], ytick: (), xtick: (-2, -1, 0, 1, 2), xticklabels: ([$mu -2 sigma$], [$mu - sigma$], [$mu$], [$mu + sigma$], [$mu +2 sigma$]), domain: (-3.2, 3.2), samples: 140, ymin: 0, ymax: 0.45, clip: false,
      addplot(line-width: widths.very-thick, draw: blue, x => calc.exp(-calc.pow(x, 2) / 2) / calc.sqrt(2 * calc.pi)),
      {
        connect((0, 0), (0, 0.399), dash: "dashed", draw: muted)
        connect((-1, 0.24), (1, 0.24), line-width: widths.thick, draw: teal, start: tip("Stealth", line: widths.thick), end: tip("Stealth", line: widths.thick))
        node(along((-1, 0.24), (1, 0.24), t: 50%), [about 68%], font: font("small"), anchor: "south")
      },
    )
  })
]

Many measurement errors and averages are approximately normal, but real data should not be assumed normal without inspection.

#intuition[
  $mu$ sets the bell’s center; $sigma$ sets its width.
]

== Population, sample, and sampling bias

#analogy[
  A spoonful tells a cook how the whole pot tastes, provided the pot was stirred. Tasting ten spoonfuls from the top of an unstirred pot just repeats the mistake with more confidence. That is the difference between a small sample and a biased one.
]

A #term[sample] is the observed subset of a #term[population]. Sample statistics estimate population parameters.

For a sample of size $n$, the common sample variance is

$ s^2=frac(1, n-1) sum _(i=1)^n(x_i-macron(x))^2. $

The denominator $n-1$ corrects the tendency to underestimate population variance when deviations are measured around the sample mean.

#pitfall[
  More observations do not correct systematic sampling bias.
]

== Standard error and confidence intervals

Standard deviation describes variation among individual observations. #term[Standard error] describes uncertainty in an estimate. For a sample mean,

$ op("SE")(macron(x))=frac(s, sqrt(n)). $

Standard error falls as $1\/sqrt(n)$: halving it requires about four times the data.

For independent, identically distributed observations with finite variance, sample means approach normality as sample size grows. Small samples, heavy tails, or dependence can invalidate the approximation. Under suitable conditions:

$ macron(x) plus.minus z_(1- alpha \/2)frac(s, sqrt(n)). $

A valid 95% confidence procedure covers the true parameter in about 95% of repeated samples.

#workedexample[
  Treat the ten marks in the log as a sample. The sample standard deviation (dividing by $n-1$) is $s=12.19$, so

  $ op("SE")(macron(x))=frac(12.19, sqrt(10))=3.85, wide 56.1 plus.minus 1.96 times 3.85 med " gives " med 48.5 " to "63.7. $

  Ten rows is small for this formula, so read the interval as rough. The lesson it carries is sound: with ten students, the average mark is only known to within several marks either way, and model scores on small validation sets are just as shaky. #chapref(<ch:evaluation>) applies this to a real model.
]

=== The bootstrap

The #term[bootstrap] estimates sampling variability by repeatedly resampling observations with replacement and recalculating the statistic.

#utpsteps[
  + Draw $n$ rows with replacement from the $n$ observed rows.
  + Recalculate the statistic, such as a median or a difference in model loss.
  + Repeat many times and use suitable quantiles as an interval.
]

#workedexample[
  Five thousand bootstrap resamples of the ten marks give a 95% interval for the median of 46.5 to 65.0. No formula for the standard error of a median was needed, only the ability to resample and recompute.
]

Resampling must preserve dependence: use blocks for time series, groups for repeated measurements, and matched observations for paired comparisons.

== Probability basics

A probability lies between 0 and 1. For events $A$ and $B$:

- $P(A)$ is the probability of $A$.
- $P(A inter B)$ is the probability that both occur.
- $P(A union B)$ is the probability that at least one occurs.
- $P(A mid B)$ is the probability of $A$ when $B$ is known.

The multiplication rule is

$ P(A inter B)=P(A)P(B mid A). $

Events are independent when knowing one does not change the probability of the other:

$ P(A inter B)=P(A)P(B). $

== Bayes’ theorem

#analogy[
  A smoke alarm rings. How worried should you be? That depends on how good the alarm is, and also on how often there really is a fire. Most rings are burnt toast, simply because burnt toast is so much more common than fires. Bayes’ theorem is the arithmetic of that reasoning.
]

Bayes’ theorem reverses a conditional probability:

$ P(A mid B)=frac(P(B mid A)P(A), P(B)). $

#describe-nextline(1.15in)[
  / Prior: $P(A)$: belief before seeing new evidence.
  / Likelihood: $P(B mid A)$: how likely the evidence is if $A$ is true.
  / Posterior: $P(A mid B)$: updated belief after seeing the evidence.
]

#keepspace(243.9pt)

#workedexample[
  A condition affects 1% of people. A test detects 90% of true cases and gives a false positive for 5% of people without the condition. Count people rather than probabilities. In a town of 10,000:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto),
    align: (left, center, center, center),
    header: ([], [Have the condition], [Do not], [Total]),
    [Test positive], [90], [495], [585],
    [Test negative], [10], [9,405], [9,415],
    [Total], [100], [9,900], [10,000],
  )

  #raggedright[
  #v(6pt)
  Of the 585 people who test positive, 90 have the condition, so the chance is $90\/585=0.154$. The formula says the same:

  $ P(+)=0.90(0.01)+0.05(0.99)=0.0585, wide P("condition" mid +)=frac(0.90(0.01), 0.0585) approx 0.154. $

  A positive result means about a 15.4% chance of the condition, not 90%, because the condition is rare.
  ]]]
]

#keyidea[
  Always consider the base rate. Strong-looking evidence can still lead to a modest posterior probability when the event is rare.
]

== Random variables and common distributions

A random variable assigns a number to an uncertain outcome. Its expectation is a probability-weighted average. For a discrete random variable,

$ bb(E)[X]= sum _x x P(X=x). $

Common distributions include:

#describe-nextline(1.25in)[
  / Bernoulli: One binary outcome with probability $p$.
  / Binomial: Number of successes in $n$ independent Bernoulli trials.
  / Categorical: One result from several classes.
  / Poisson: Count of events in a fixed interval under simplifying assumptions.
  / Uniform: All values in a range have equal density, or all finite outcomes have equal probability.
  / Normal: Continuous values concentrated symmetrically around a mean.
]

Probability distributions connect directly to loss functions. Gaussian error leads naturally to squared-error regression, while a Bernoulli model leads naturally to binary cross-entropy.

== Covariance and correlation <sec:correlation>

After scaling, every column has the same spread, so spread can no longer tell columns apart. What still differs is how they move together. Rewrite each value as a number of standard deviations from its column’s mean. Multiply two columns’ values row by row, and average the products. When both columns sit above their means together, or below together, the products come out positive. That average is the #term[correlation].

Covariance describes whether two variables tend to move together:

$ op("Cov")(X,Y)=bb(E)[(X- mu _X)(Y- mu _Y)]. $

Pearson correlation standardizes covariance:

$ rho _(X,Y)=frac(op("Cov")(X,Y), sigma _X sigma _Y). $

It lies between $-1$ and $1$ and measures linear association.

#utpfig([Three pairs of columns from the study log. Left: hours and sleep are mirror twins, nearly one story told twice. Middle: lectures and mark rise together. Right: hours and mark have a correlation close to zero even though they are strongly related, because a straight line through an arch comes out almost flat.], label: <fig:three-correlations>)[
  #canvas({
    groupplot(group-size: (3, 1), horizontal-sep: 1cm, ..logaxis, width: 5.4cm, height: 4.2cm,
      nextgroupplot(title: [$r=-0.96$], xlabel: [hours studied], ylabel: [hours slept], xmin: 0, xmax: 22, ymin: 0, ymax: 10,
        addplot(..logdots, table: studylog, x: "hours", y: "sleep", meta: "name"),
      ),
      nextgroupplot(title: [$r=0.86$], xlabel: [lectures attended], ylabel: [mark], xmin: 1, xmax: 15, ymin: 30, ymax: 85,
        addplot(..logdots, table: studylog, x: "lectures", y: "mark", meta: "name"),
      ),
      nextgroupplot(title: [$r=-0.25$], xlabel: [hours studied], ylabel: [mark], xmin: 0, xmax: 22, ymin: 30, ymax: 85,
        addplot(..logdots, table: studylog, x: "hours", y: "mark", meta: "name"),
        addplot(draw: orange, line-width: widths.thick, domain: (1, 21), x => -0.5 * x + 61.6),
      ),
    )
  })
]

#keyidea[
  Correlation near $plus.minus 1$ finds twins: two columns telling one story, so one could nearly be dropped. Correlation near 0 means no #emph[straight-line] connection, and it does not mean no connection. Always plot the pair.
]

#pitfall[
  Correlation does not establish causation: confounding, reverse direction, or selection may explain it.
]

#optionaltopic[
  #strong[Likelihood and maximum likelihood estimation.] Given data $x_1, dots.h ,x_n$, the likelihood treats the probability of the observed data as a function of a parameter $theta$:

  $ L( theta )= product _(i=1)^n p(x_i mid theta ). $

  Maximum likelihood selects the parameter making the observations most probable. Taking logs converts products into sums:

  $ hat(theta)_(upright("MLE"))=op("arg max", limits: #true)_theta sum _(i=1)^n log p(x_i mid theta ). $

  Many familiar machine-learning losses are negative log-likelihoods.
]

#optionaltopic[
  #strong[Hypothesis tests.] A p-value is the probability, under the null model, of a result at least as extreme as observed---not the probability the null is true. Report effect size and uncertainty too.
]

#optionaltopic[
  #strong[Entropy] measures uncertainty; #strong[cross-entropy] evaluates predicted probabilities; #strong[KL divergence] compares distributions (#chapref(<ch:classification>), #chapref(<ch:evaluation>)).
]

#keepspace(162.6pt)

#heading(depth: 2, numbering: none)[Part B: Rows as arrows]

== Scalars, vectors, and matrices

#describe-nextline(1.1in)[
  / Scalar: One number, such as temperature $23$.
  / Vector: An ordered list of numbers, such as one house $bold(x)=[120,3,8]^(sans(T))$.
  / Matrix: A rectangular table of numbers, such as a dataset with one row per house and one column per feature.
]

For $n$ observations and $p$ features, the design matrix has shape

$ X in RR^(n times p). $

The first number is the number of rows; the second is the number of columns.

#workedexample[
  The study log is a matrix with 10 rows and 4 columns, $X in RR^(10 times 4)$. Student F is the vector $[12,13,6,77]^(sans(T))$. Lab~1’s bank-call matrix has 41,176 rows and 19 feature columns.
]

== Dot products: a shopping receipt

#analogy[
  You buy 2 coffees at 3.50, 3 buns at 1.20 and 1 juice at 2.00. The bill is $2(3.50)+3(1.20)+1(2.00)=12.60$. Multiply matching entries and add them up: that is a dot product of a price list with a basket. A linear model does exactly this, with weights in place of prices and features in place of quantities.
]

The dot product of two vectors is

$ bold(a)^(sans(T))bold(b)= sum _(j=1)^p a_j b_j. $

It has two useful interpretations.

+ It creates a weighted sum. Linear models use $bold(w)^(sans(T))bold(x)+b$.
+ It measures alignment. A large positive dot product means the vectors point in similar directions; a negative one means they point in opposing directions.

#workedexample[
  For $bold(w)=[2,-1]^(sans(T))$ and $bold(x)=[3,4]^(sans(T))$,

  $ bold(w)^(sans(T))bold(x)=2(3)+(-1)(4)=2. $

  A linear model with bias $b=0.5$ would predict $2.5$.
]

== Matrix shapes: the rule that governs everything

For matrix multiplication, inner dimensions must match; outer dimensions determine the result.

#workedexample[
  A matrix times a vector is one dot product per row. Put the line $"mark"=3 times "hours"+40$ into this form, with a column of ones to carry the 40:

  $ mat(delim: "[", 1, 2; 1, 4; 1, 6) mat(delim: "[", 40; 3) = mat(delim: "[", 1(40)+2(3); 1(40)+4(3); 1(40)+6(3)) = mat(delim: "[", 46; 52; 58). $

  Shapes: $(3 times 2)$ times $(2 times 1)$ gives $(3 times 1)$. Three students go in, and three predictions come out in one multiplication.
]

#utpfig([Matrix shapes in a product. The inner dimensions must match and the outer dimensions survive into the answer: an $(n times p)$ matrix times a $(p times 1)$ vector gives an $(n times 1)$ result.], label: <fig:matrix-shapes>)[
  #canvas({
    rectangle((0, 0), (2.2, 1.9), rounded: 1mm, fill: pale-blue, draw: none)
    node((1.1, 0.95), [$X$], font: font("normal", weight: "bold", fill: navy))
    node((1.1, -0.35), [$(n times p)$], font: font("script", fill: muted))
    node((2.75, 0.95), [$times$], font: font("Large", fill: ink))
    rectangle((3.3, 0.35), (4.3, 1.55), rounded: 1mm, fill: pale-teal, draw: none)
    node((3.8, 0.95), [$bold(w)$], font: font("normal", weight: "bold", fill: navy))
    node((3.8, -0.35), [$(p times 1)$], font: font("script", fill: muted))
    node((4.85, 0.95), [$=$], font: font("Large", fill: ink))
    rectangle((5.4, 0), (6.1, 1.9), rounded: 1mm, fill: pale-orange, draw: none)
    node((5.75, 0.95), [$hat(bold(y))$], font: font("normal", weight: "bold", fill: navy))
    node((5.75, -0.35), [$(n times 1)$], font: font("script", fill: muted))
    connect((1.75, -0.75), (3.35, -0.75), line-width: widths.thick, draw: red, start: tip("Stealth", length: 2mm, line: widths.thick), end: tip("Stealth", length: 2mm, line: widths.thick))
    node((2.55, -1.05), [these must match], font: font("script", fill: red))
    connect((0.4, 2.25), (0.4, 2), line-width: widths.thick, draw: green, start: tip("Stealth", length: 2mm, line: widths.thick))
    connect((0.4, 2.25), (5.6, 2.25), line-width: widths.thick, draw: green, end: tip("Stealth", length: 2mm, line: widths.thick))
    connect((5.6, 2.25), (5.6, 2), line-width: widths.thick, draw: green, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((3, 2.5), [these survive into the answer], font: font("script", fill: green))
  })
]

== Vector arithmetic

Vectors of the same length can be added component by component:

$ mat(delim: "[", 1; 2)+ mat(delim: "[", 3; 4)= mat(delim: "[", 4; 6). $

Multiplying by a scalar stretches or reverses a vector:

$ 3 mat(delim: "[", 1; 2)= mat(delim: "[", 3; 6). $

== Norms: measuring vector size

The $L_1$ norm is the sum of absolute values:

$ || bold(x) || _1= sum _j|x_j|. $

The $L_2$ norm is the ordinary straight-line length:

$ || bold(x) || _2=sqrt(sum _j x_j^2). $

These norms appear in distance calculations and regularization.

== Distance and similarity

#analogy[
  A crow flies straight, and a taxi follows the grid. Between the same two buildings they travel different distances, and each is right for its purpose. “Close” is a choice you make when you pick a measure.
]

A model often needs to decide whether two observations are close or similar.

#utptable[
  #tabularx(
    columns: (20%, 28%, 1fr),
    styles: (navy-bold,),
    header: ([Measure], [Formula or idea], [Useful when]),
    [Euclidean distance], [$|| bold(x)-bold(z) || _2$], [ordinary geometric distance; features are scaled],
    [Manhattan distance], [$|| bold(x)-bold(z) || _1$], [movement along grid-like axes; more robustness to a single large difference],
    [Cosine similarity], [$frac(bold(x)^(sans(T))bold(z), || bold(x) || _2 || bold(z) || _2)$], [direction matters more than magnitude, such as word-count vectors],
    [Jaccard similarity], [overlap divided by union], [sets or binary presence/absence features],
    [Hamming distance], [number of unequal positions], [binary strings or categorical codes],
  )
]

#pitfall[
  Distance-based models can be meaningless when features use very different scales. Standardize or otherwise justify the scale before calculating distances.
]

#heading(depth: 3, numbering: none)[The same two points can look different under different measures]

Euclidean, Manhattan, Jaccard, Minkowski, and cosine measures encode different meanings of “close”. Choose one for the representation and task.

#workedexample[
  For points $P=(1,2)$ and $Q=(4,6)$,

  $ d_2(P,Q)=sqrt((4-1)^2+(6-2)^2)=5, $

  while

  $ d_1(P,Q)=|4-1|+|6-2|=7. $

  Euclidean distance measures the straight-line path; Manhattan distance measures the axis-by-axis path.
]

The #term[Minkowski distance] unifies both:

$ d_p(bold(x),bold(z))= ( sum _j |x_j-z_j|^p)^(1\/p). $

Minkowski uses Manhattan distance at $p=1$ and Euclidean distance at $p=2$. Choose $p$ to match the task.

#workedexample[
  For sets $A= { 0,1,2,5,6 }$ and $B= { 0,2,3,4,5,7,9 }$, the intersection has three elements and the union has nine. Therefore

  $ J(A,B)=frac(|A inter B|, |A union B|)=frac(3, 9)=0.33. $

  Jaccard measures overlap among present items, ignoring shared absences.
]

#workedexample[
  Three documents as word counts over the vocabulary (cat, dog, fish): $a=(2,1,0)$, $b=(4,2,0)$ and $c=(0,1,3)$. Document $b$ is $a$ written out twice as long. Euclidean distance says $a$--$b$ is 2.24 and $a$--$c$ is 3.61, so length still counts. Cosine similarity says $a$--$b$ is 1.00, the same direction, and $a$--$c$ is 0.14, nearly unrelated topics. For documents of different lengths, the angle is usually what you want.
]

#keyidea[
  Choose representation and distance together; a computable distance need not be meaningful.
]

== Cosine similarity visually

Cosine similarity depends on the angle $theta$ between two vectors:

$ cos( theta )=frac(bold(x)^(sans(T))bold(z), || bold(x) || _2 || bold(z) || _2). $

#utpfig([Cosine similarity depends only on the angle $theta$ between two vectors, not on their lengths.], label: <fig:cosine>)[
  #canvas(scale: 1.05, {
    connect((0, 0), (4, 1.2), line-width: widths.thick, draw: blue, end: tip("Stealth", length: 2.5mm, line: widths.thick))
    node(along((0, 0), (4, 1.2), t: 100%), [$bold(x)$], anchor: "west")
    connect((0, 0), (3, 2.7), line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.5mm, line: widths.thick))
    node(along((0, 0), (3, 2.7), t: 100%), [$bold(z)$], anchor: "south")
    arc-at((1.1, 0.33), 16.7, 42, 1.15, line-width: widths.thick, draw: orange)
    node((1.45, 0.82), [$theta$], text: orange)
    connect((-0.3, 0), (4.5, 0), draw: muted, end: tip("to", line: 0.4pt))
    connect((0, -0.3), (0, 3.2), draw: muted, end: tip("to", line: 0.4pt))
  })
]

A cosine similarity near 1 means similar direction, near 0 means roughly perpendicular, and near $-1$ means opposite direction.

== Matrices and linear transformations

A matrix can transform one vector into another:

$ bold(y)=A bold(x). $

Depending on its values, $A$ can rotate, stretch, shrink, reflect, or combine coordinates. A linear regression model applies this same idea to many rows at once:

$ hat(bold(y))=X bold(beta). $

#intuition[
  Matrix multiplication forms weighted combinations; compatible shapes determine which products exist.
]

== Transpose, identity, and inverse

The transpose switches rows and columns. If $A$ is $m times p$, then $A^(sans(T))$ is $p times m$.

The identity matrix $I$ acts like the number 1:

$ I bold(x)=bold(x). $

When an inverse exists,

$ A^(-1)A=I. $

Solve linear systems numerically rather than explicitly computing inverses.

== Gradients: which way changes the loss?

A model usually has many numbers to adjust at once. Stand at one setting of them and ask of each number in turn: if I nudge only this one, how fast does the loss change? Each answer is a #term[partial derivative], and the list of answers is the #term[gradient].

For a function with several parameters, the gradient collects all partial derivatives:

$ nabla _(bold(theta))J= mat(delim: "[", frac(partial J, partial theta _1); dots.v; frac(partial J, partial theta _p)). $

The gradient points toward the fastest increase in $J$. To reduce a loss, gradient descent moves in the opposite direction:

$ bold(theta) arrow.l bold(theta)- alpha nabla _(bold(theta))J. $

#workedexample[
  Take guess A from #chapref(<ch:orientation>), $"mark"=2 times "hours"+47$, on the first six students. Its errors are $-4,-5,0,2,1,6$. For mean squared error the two slopes are

  $ frac(partial J, partial w)=-frac(2, n) sum _i e_i x_i=-23.33, wide frac(partial J, partial b)=-frac(2, n) sum _i e_i=0. $

  The gradient says: raising $w$ lowers the loss quickly, and $b$ is fine for now. That matches what we know, since the best slope is 3 and this guess is at 2. Gradient descent (#secref(<sec:gradient-descent>)) would step $w$ upward and leave $b$ alone on this step.
]

#optionaltopic[
  #strong[Eigenvectors and SVD.] An eigenvector is scaled by a square matrix. SVD factors a matrix into rotations/reflections and scaling. Both reveal directions used in PCA (#chapref(<ch:dimred>)).
]

#optionaltopic[
  #strong[Hessian.] This matrix of second derivatives describes curvature: positive in bowl-like directions, negative in hill-like directions. It supports advanced optimization.
]

#keyidea[
  Vectors represent observations and parameters; matrices represent datasets and transformations; dot products create weighted sums; distances compare observations; and gradients tell optimization which direction to move.
]

#chapterrecap[
  - Report a center and a spread. Mean and standard deviation suit symmetric columns; median and IQR suit skewed ones.
  - A sample estimates a population. More rows shrink random error as $1\/sqrt(n)$, and they do nothing for bias.
  - Rare events stay fairly unlikely even after strong evidence. Count people to check the arithmetic.
  - Correlation measures straight-line association. It finds twin columns and misses arches, and it never proves cause.
  - A row is a vector, a table is a matrix, a linear model is a dot product, and matrix shapes must match on the inside.
  - Distance depends on scale and on your choice of measure. The gradient lists one slope per parameter.
]

#quickcheck[
  + When would the median and IQR describe a distribution more faithfully than the mean and standard deviation?
  + The correlation between hours and mark in the study log is $-0.25$. Does that mean study has little to do with the mark? How would you check?
  + A rare-disease test has 99% sensitivity and a 1% false-positive rate, and 1 person in 1,000 has the disease. Out of 100,000 people, about how many test positive, and what fraction of those have it?
  + If $X$ has shape $n times p$, what shape must a coefficient vector have for $X bold(w)$ to produce one prediction per row?
  + Why can standardizing features change a nearest-neighbor or clustering result even though the observations themselves did not change?
  + What does a gradient of zero tell you about where you are standing on a bowl?
]
