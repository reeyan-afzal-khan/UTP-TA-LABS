#import "/.shared/typst/utp.typ": *
#unit("chapters", "16-dimensionality-reduction-and-representation")


#heading(level: 1)[Dimensionality Reduction and Representation]
 <ch:dimred>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* #ref(label("ch:unsupervised"), supplement: [Chapter]), correlation and dot products from #ref(label("ch:foundations"), supplement: [Chapter]), and scaling from #ref(label("ch:data"), supplement: [Chapter]). Eigenvectors and eigenvalues are introduced here from scratch.

*By the end, you can:* explain PCA as choosing the best shadow; score a direction by hand; compute shares of variance; read a component's weights; choose how many components to keep from evidence; and read t-SNE and UMAP maps with care.]

The tutor wants all four columns of the study log on one chart. A chart has two axes, and the table has four columns, so that chart cannot be drawn. But you have known the way out since you were a child.


#heading(level: 2)[The idea: find the best shadow]


#callout("analogy", title: [Analogy])[Hold a toy horse up to a lamp, and its shadow on the wall flattens three dimensions into two. Turn the horse side-on and the shadow keeps the head, legs and tail, spread out and recognizable. Turn it head-on and the shadow is a narrow blob. Same object, same lamp; the angle is everything. A #strong[projection] is that flattening, and #strong[principal component analysis (PCA)] finds the angle whose shadow keeps the most.]

What does "keeps the most" mean as a number? In the good shadow, parts of the horse land far apart. In the bad one, everything lands on top of everything else. So we score a shadow by how spread out it is, and we already have a number for spread: the variance. PCA turns "keep as much information as possible" into "keep as much variance as possible."

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/2e54975edc0427a8.cetz.json")], caption: [Principal component analysis finds better axes. The first component points along the direction of most variance; the second is perpendicular to it.]) <fig:pca-axes>


#heading(level: 2)[One shadow by hand]


Start with two columns: hours studied and hours slept. Their correlation is $- 0.96$, so they are nearly one story told twice. Scale each column to mean 0 and standard deviation 1 first, because we are about to add hours of study to hours of sleep, and each column should get an equal voice. Student J, for example, becomes $\( 1.57 \, thin - 1.85 \)$: well above average on study, well below on sleep.

Now pick a direction, written as weights whose squares add to 1, so that one step along it has length 1. The direction $\( 0.71 \, - 0.71 \)$ means "study up, sleep down." A student's shadow on that line is a dot product: J's is $0.71 times 1.57 + \( - 0.71 \) times \( - 1.85 \) approx 2.4$, far along the line.

#callout("workedexample", title: [Worked example])[Take the shadow of all ten students on two perpendicular directions, and compute the variance of each set of shadows.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,center,),
    table.header([Direction], [Meaning], [Spread of the shadows],),
    table.hline(),
    [$\( 0.71 \, - 0.71 \)$], [study up, sleep down], [1.965],
    [$\( 0.71 \, med 0.71 \)$], [study and sleep up together], [0.035],
  )]
  , kind: table
  )

The two scaled columns hold 2 units of spread in total, and one direction holds 1.965 of them, or 98%. The students barely differ at all along the other. Nothing would be lost by replacing these two columns with one new column, "cramming versus resting."]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/52cf340606a9e796.cetz.json")], caption: [Hours and sleep, both scaled. Along the "study up, sleep down" direction the students spread out, keeping 1.965 of the 2 units of spread. Along the perpendicular direction they crowd together, keeping 0.035.]) <fig:shadow>


#heading(level: 2)[All four columns at once]


PCA runs the same scoring over every possible direction, using one piece of mathematics. Doing the correlation for every pair of columns fills a table; on scaled data it is also the covariance table.

#figure(
  align(center)[#table(
    columns: 5,
    align: (left,center,center,center,center,),
    table.header([], [hours], [lectures], [sleep], [mark],),
    table.hline(),
    [hours], [1.00], [$- 0.15$], [$- 0.96$], [$- 0.25$],
    [lectures], [$- 0.15$], [1.00], [0.35], [0.86],
    [sleep], [$- 0.96$], [0.35], [1.00], [0.46],
    [mark], [$- 0.25$], [0.86], [0.46], [1.00],
  )]
  , kind: table
  )

The #strong[eigendecomposition] takes that table and returns every direction ranked by spread. Its two words name things we already have: an #strong[eigenvector] is one direction, written as its weights, and its #strong[eigenvalue] is that direction's spread. In formula form, $S bold(v) = lambda bold(v)$: multiplying the table by the direction only stretches it. NumPy calls the routine `eigh`.

#source-code("/MACHINE LEARNING/all_experiments/book_checks/demo_study_log.py", first: 108, last: 114, lang: "python")

#callout("workedexample", title: [Worked example])[The four directions have spreads 2.532, 1.330, 0.130 and 0.008, out of 4 units in total. Their shares are 63.3%, 33.2%, 3.3% and 0.2%. So the first two together keep 96.5%, and the other two can go.

#figure(
  align(center)[#table(
    columns: 6,
    align: (left,center,center,center,center,left,),
    table.header([Direction], [hours], [lectures], [sleep], [mark], [What it reads as],),
    table.hline(),
    [PC1], [$- 0.48$], [0.46], [0.56], [0.50], [attending and rested, not cramming],
    [PC2], [0.56], [0.55], [$- 0.40$], [0.47], [how much work went in],
  )]
  , kind: table
  )

A big weight means the column matters, and the signs show which columns move together. The names are ours, read from the weights. The sign of a whole direction is arbitrary, so software may flip it.]

Multiplying the scaled table by those two directions gives every student two new coordinates, and the whole group finally fits on one chart (#ref(label("fig:pc-map"), supplement: [Figure])). Far right are D, E and F, who attended, slept and did well. Far left are I and J, the crammers. At the bottom are A and B, who did little work, and at the top are F and G, who did a lot. The three groups $K$-means found from only hours and mark in #ref(label("ch:clustering"), supplement: [Chapter]) land in three separate regions, and this time the map also used lectures and sleep. That is the check we promised: the crammers really are the students who skipped lectures and barely slept.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/cdf0629e1c619939.cetz.json")], caption: [Each student on the first two principal components, keeping 96.5% of the spread of all four columns. Markers show the groups $K$-means found from hours and mark alone.]) <fig:pc-map>

#callout("modelcard", title: [The recipe: PCA])[*1. Model* A set of directions to flatten the data onto.

*2. Loss* The spread lost by flattening: here 3.5% with two directions.

*3. Optimizer* An exact matrix routine, the eigendecomposition or the SVD, which finds every direction at once.]


#heading(level: 2)[PCA step by step]


+ #strong[Center] the data by subtracting each feature's training mean. Decide separately whether to standardize: do so when equal standardized variation should carry equal weight, but retain original units when their variance is scientifically meaningful.

+ Compute the sample covariance matrix $ S = frac(1, n - 1) X^(sans(T)) X $ for the centered matrix $X$.

+ Find its eigenvectors and eigenvalues: for centered data matrix $X$, $ S bold(v) = lambda thin bold(v) . $ Each eigenvector $bold(v)$ is a component direction; its eigenvalue $lambda$ measures the variance captured along it.

+ #strong[Sort] components by eigenvalue and keep the top $k$.

+ #strong[Project]: the new features (#strong[scores]) are the dot products of each observation with the kept components.

The proportion of variance explained by component $j$ is $ frac(lambda_j, sum_k lambda_k) \, $ explaining the variance along each axis, not its predictive value (#ref(label("sec:pca-limitations"), supplement: [Section])). Components are orthogonal and fitted scores uncorrelated. SVD of centered data computes the same directions.

#callout("workedexample", title: [Worked example])[Take five centered points that lie exactly on a line: $\( - 2 \, - 2 \)$, $\( - 1 \, - 1 \)$, $\( 0 \, 0 \)$, $\( 1 \, 1 \)$, $\( 2 \, 2 \)$. Each feature has variance $10 \/ 4 = 2.5$ and their covariance is also $2.5$, so the covariance matrix is $mat(delim: "[", 2.5, 2.5; 2.5, 2.5)$ with $lambda_1 = 5$, $lambda_2 = 0$, and $bold(v)_1 = \( 1 \, 1 \) \/ sqrt(2)$. Scores $\( - 2.83 \, - 1.41 \, 0 \, 1.41 \, 2.83 \)$ retain 100% of variance in one dimension. Dropping nonzero components instead loses variance.]


#heading(level: 2)[Explained variance: the compression budget]


Lab~4 applies this to $32 times 32$ colour photos of wood defects, 3,072 pixel values per image. The first component alone keeps 39.1%, and the first ten keep 83.9%. Keeping 90%, 95% and 99% of the variance needs 21, 51 and 253 components. The first components describe mostly the light and colour of the wood: on Lab~4's test boards, logistic regression scores 0.638 on all 3,072 pixel values and 0.633 on 253 components.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/b76f2a08da7fd0be.cetz.json")], caption: [Real numbers from Lab~4's 12,567 development images. Left: the share of variance per component for the first ten. Right: the cumulative share, on a logarithmic axis, which bends early.]) <fig:cumulative-variance>

Choose the count by a variance target, a bend in the curve, or downstream validation on training folds. Discarded eigenvalues add up to the variance you lost: here 1.0% for 253 components.

#callout("workedexample", title: [Worked example])[How few can you keep? On Lab~4's validation boards, logistic regression scores 0.420 on 2 components, 0.538 on 10, 0.591 on 50, 0.608 on 248 and 0.618 on all 3,072. Two components make a fine picture and a poor classifier; 248 come within a point of the raw pixels with a twelfth of the inputs.]


#heading(level: 3)[What PCA cannot promise]
 <sec:pca-limitations>

- It is #strong[linear]: a spiral or a curved sheet of data has structure PCA cannot straighten out.

- It is #strong[scale-sensitive]: changing units changes the covariance matrix. Standardize when that influence is arbitrary, not as an automatic rule.

- #strong[Variance is not predictive importance]: low-variance directions may carry label signal. LDA instead seeks class separation (#ref(label("ch:classification"), supplement: [Chapter])).

- #strong[Interpretation]: inspect component weights; each component blends original features.

#callout("workedexample", title: [Worked example])[#strong[Scale.] Run PCA on the raw study log, without scaling. The first direction then takes 80.2% of the variance with a weight of 0.96 on the mark. It has found "the column with the largest numbers", since marks vary far more than hours of sleep. On scaled columns the first direction keeps 63.3% and uses all four columns about equally. Neither is wrong; they answer different questions, so choose on purpose.]

#callout("pitfall", title: [Common mistake])[Projecting a four-feature clustering into two PCA dimensions only visualizes its existing assignments. Clustering the two PCA columns instead is a different model with reduced information.]


#heading(level: 2)[t-SNE and UMAP: maps for the eye]
 <sec:tsne-umap>

For two-dimensional neighborhood maps rather than global variance preservation, consider t-SNE or UMAP.

#strong[t-SNE] converts distances into neighbor probabilities and arranges points in 2-D so that neighborhoods are preserved: points close in the original space stay close on the map. Its main hyperparameter, #strong[perplexity], roughly sets the neighborhood size being honored (typical values 5--50).

#strong[UMAP] pursues the same goal with different mathematics; it is much faster, tends to preserve somewhat more of the global arrangement, and --- unlike classic t-SNE --- can place #emph[new] points onto an existing map.

Both need cautious reading:

- cluster sizes, empty gaps, and distances between separated groups can be artifacts; even apparent neighborhoods should be checked against original-space distances;

- check whether the interpretation survives changes in seeds and hyperparameters;

- for ordinary preprocessing PCA is the simpler default, because it can project new rows.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([], [PCA], [t-SNE / UMAP],),
    table.hline(),
    [Preserves], [global variance, linear structure], [local neighborhoods],
    [Handles new points], [yes (a projection)], [UMAP yes; t-SNE awkwardly],
    [Best use], [preprocessing, compression, denoising], [exploratory visualization],
  )]
  , kind: table
  )

PCA, t-SNE, and UMAP #strong[extract] new features; #strong[selection] retains original columns (#ref(label("sec:feature-selection"), supplement: [Section])).

#callout("keyidea", title: [Key idea])[PCA quantifies lost variance; nonlinear maps emphasize neighborhoods and need cautious interpretation. A visualization is evidence to investigate, not a substitute for the original data.]

#callout("modelcard", title: [Dimensionality Reduction - Quick Guide])[#block[
ll PCA is best for & Compressing correlated numerical features, denoising, visualization, and faster downstream modeling. Preprocessing & Center features; standardize when unit scales are arbitrary and equal standardized influence is intended. Main control & Number of components, by explained variance and validation. Visualization tools & t-SNE and UMAP make useful two-dimensional maps of neighborhoods. Watch for & Loss of interpretability, information loss, leakage from fitting on all data, and over-interpreting visual clusters.

]]

#callout("chapterrecap", title: [Chapter recap])[- PCA is a shadow: it flattens rows onto the directions that keep the most spread.

- A direction is a list of weights, a shadow is a dot product, and the eigendecomposition of the correlation table ranks every direction at once.

- On the study log, two directions keep 96.5% of four columns: four columns were really two stories.

- Choose the component count from a variance target and a downstream test: 90% of the variance is not 90% of the usefulness.

- PCA is linear and sensitive to scale, and variance is not the same as usefulness for a label. t-SNE and UMAP make maps for looking at, not measuring on.]

#callout("quickcheck", title: [Check your understanding])[+ What does PCA optimize when it chooses its first principal component?

+ Two scaled columns have a correlation of 0.80. What spread does the direction $\( 0.71 \, 0.71 \)$ keep, and what share of the total?

+ PCA's first direction has weights near $0.25$ on four columns of very different meaning. What does that suggest?

+ Why can standardization change which PCA directions appear most important?

+ Accuracy falls from 0.841 with 82 components to 0.506 with 2, yet the 2-D plot looks clean. Conclusion?

+ Why should distances and apparent cluster sizes in a t-SNE or UMAP plot not be interpreted as exact properties of the original high-dimensional data?]
