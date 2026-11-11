#import "/.shared/typst/utp.typ": *
#unit("chapters", "13-support-vector-machines")


#heading(level: 1)[Support Vector Machines and Supervised Synthesis]
 <ch:svm>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Linear classifiers from #ref(label("ch:classification"), supplement: [Chapter]), model-capacity ideas from #ref(label("ch:training"), supplement: [Chapter]), and dot products and norms from #ref(label("ch:foundations"), supplement: [Chapter]).

*By the end, you can:* find a maximum-margin line on a small example; compute hinge loss; explain what $C$ and $gamma$ do; check the kernel trick with numbers; scale and tune an SVM inside validation; and choose among all the supervised families in this book.]

Two neighborhoods sit on either side of open ground, and the council wants to build a road between them. Many routes would keep every house on the correct side. The sensible one is the route that leaves the widest clearance, because a slightly misplaced new house is then still on the correct side. A #strong[support vector machine (SVM)] chooses its boundary by the same reasoning, and only the houses at the edge of the road affect where it runs.


#heading(level: 2)[The widest street]


#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/b8152e4a2a784f31.cetz.json")], caption: [The widest street. A hard-margin SVM places the boundary in the middle of the widest margin between the classes; the circled support vectors on its edges determine it.]) <fig:svm-margin>

#callout("workedexample", title: [Worked example])[Six points: $\( 1 \, 1 \)$, $\( 2 \, 1 \)$, $\( 1 \, 2 \)$ are class $- 1$, and $\( 3 \, 3 \)$, $\( 4 \, 3 \)$, $\( 3 \, 4 \)$ are class $+ 1$ (#ref(label("fig:svm-toy"), supplement: [Figure])). The SVM's answer is $bold(w) = \( 2 / 3 \, 2 / 3 \)$ and $b = - 3$. Check the score $y \( bold(w)^(sans(T)) bold(x) + b \)$ at each point: for $\( 2 \, 1 \)$ it is $- 1 times \( 2 / 3 dot.op 3 - 3 \) = 1$, and for $\( 1 \, 2 \)$ and $\( 3 \, 3 \)$ it is also exactly 1. These three are the #strong[support vectors]. The other three score 1.67, so they sit beyond the curb and do not affect the street at all. Delete them and the answer stays the same.

The street's width is $2 \/ parallel bold(w) parallel_2 = 2 \/ \( 2 / 3 sqrt(2) \) = 2.12$.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/d0192f268768345c.cetz.json")], caption: [The fitted boundary and its two curbs on six points. The three circled support vectors sit exactly on the curbs. The street is 2.12 wide.]) <fig:svm-toy>


#heading(level: 2)[The hard-margin objective]


For $y_i in { - 1 \, + 1 }$, require correctly signed linear scores of magnitude at least one: $ min_(bold(w) \, b) med 1 / 2 parallel bold(w) parallel_2^2 quad upright("subject to") quad y_i \( bold(w)^(sans(T)) bold(x)_i + b \) gt.eq 1 . $ The constraint requires the correct sign and score magnitude at least~1. The margin width is $2 \/ parallel bold(w) parallel_2$, so minimizing the norm maximizes that width.


#heading(level: 2)[The soft margin: allowing exceptions]


Real classes overlap, so the SVM used in practice permits violations and charges for them: $ min_(bold(w) \, b) med 1 / 2 parallel bold(w) parallel_2^2 + C sum_(i = 1)^n max #h(-1em) (0 \, thin 1 - y_i \( bold(w)^(sans(T)) bold(x)_i + b \)) . $ #strong[Hinge loss] is zero beyond the margin and linear within it or on the wrong side. $C$ balances margin width against violations:

#callout("workedexample", title: [Worked example])[The hinge loss is $max \( 0 \, thin 1 - m \)$, where $m = y \( bold(w)^(sans(T)) bold(x) + b \)$ measures how far a point is on the right side, in margin units.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,center,),
    table.header([Where the point is], [$m$], [Hinge loss],),
    table.hline(),
    [Well beyond the curb], [2.0], [0.0],
    [Exactly on the curb], [1.0], [0.0],
    [Inside the street, right side], [0.4], [0.6],
    [On the wrong side], [$- 0.5$], [1.5],
  )]
  , kind: table
  )

Points beyond the curb cost nothing and so have no effect on the fit. Log loss, by contrast, keeps rewarding more confidence forever.]

- #strong[Large $C$]: violations cost more; weaker regularization can overfit.

- #strong[Small $C$]: more violations are tolerated; regularization is stronger.

Both SVMs and regularized logistic regression combine loss with an $L_2$ penalty. Hinge loss becomes zero beyond the margin; cross-entropy continues rewarding confidence.


#heading(level: 2)[Curved boundaries: mapping up]


Some datasets cannot be separated by any straight line --- but they can be after the features are transformed.

#callout("workedexample", title: [Worked example])[Let $x in { - 2 \, 2 }$ be class A and $x in { - 1 \, 0 \, 1 }$ class B. No single threshold separates them. Map to $phi.alt \( x \) = \( x \, x^2 \)$: #figure(
  align(center)[#table(
    columns: 6,
    align: (left,center,center,center,center,center,),
    table.header([$x$], [$- 2$], [$- 1$], [$0$], [$1$], [$2$],),
    table.hline(),
    [$x^2$], [$4$], [$1$], [$0$], [$1$], [$4$],
    [class], [A], [B], [B], [B], [A],
  )]
  , kind: table
  ) Class A has height 4 and class B at most 1. The line $x^2 = 2.5$ separates them, corresponding to two thresholds $\| x \| = sqrt(2.5)$ in the original space.]

#callout("analogy", title: [Analogy])[Marbles of two colors lie on a table, with one color in a ring around the other. No straight stick can separate them. Give the table a sharp tap from below so the central marbles fly up, and a flat sheet of card can slide between the two groups. A new feature gives you the extra height.]


#heading(level: 2)[The kernel trick]


Rich feature maps can be expensive or infinite-dimensional. The SVM's equations happen to use the mapped rows only through dot products, and a #strong[kernel function] computes those dot products directly: $ k \( bold(x) \, bold(x)' \) = phi.alt \( bold(x) \)^(sans(T)) phi.alt \( bold(x)' \) \, $ so the mapped features never need to be constructed at all. That shortcut is the #strong[kernel trick].

#callout("workedexample", title: [Worked example])[Let $phi.alt \( bold(v) \) = \( v_1^2 \, med sqrt(2) thin v_1 v_2 \, med v_2^2 \)$, and take $bold(x) = \( 1 \, 2 \)$ and $bold(z) = \( 3 \, 1 \)$. The long way: $phi.alt \( bold(x) \) = \( 1 \, med 2.83 \, med 4 \)$ and $phi.alt \( bold(z) \) = \( 9 \, med 4.24 \, med 1 \)$, whose dot product is $9 + 12 + 4 = 25$. The short way: $\( bold(x)^(sans(T)) bold(z) \)^2 = \( 3 + 2 \)^2 = 25$. Same answer, with no need to visit the larger space.]

Standard choices:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Kernel], [Formula], [Boundary it produces],),
    table.hline(),
    [Linear], [$bold(x)^(sans(T)) bold(x)'$], [Straight; fast on huge, sparse data],
    [Polynomial], [$\( gamma thin bold(x)^(sans(T)) bold(x)' + r \)^d$], [Curved, degree-$d$ interactions],
    [RBF (Gaussian)], [$exp #h(-1em) (- gamma parallel bold(x) - bold(x)' parallel_2^2)$], [Smooth, local, very flexible],
  )]
  , kind: table
  )

The #strong[RBF kernel] measures similarity that decays with distance. Small $gamma$ gives broad influence and smooth boundaries; large $gamma$ gives local, flexible boundaries. Tune $C$ and $gamma$ together on logarithmic grids.

#callout("workedexample", title: [Worked example])[RBF similarity $exp \( - gamma d^2 \)$ between two points at distance $d$:

#figure(
  align(center)[#table(
    columns: 4,
    align: (center,center,center,center,),
    table.header([$gamma$], [$d = 0.5$], [$d = 1$], [$d = 2$],),
    table.hline(),
    [0.1], [0.975], [0.905], [0.670],
    [1], [0.779], [0.368], [0.018],
    [10], [0.082], [0.000], [0.000],
  )]
  , kind: table
  )

At $gamma = 10$ a training point has almost no influence even one unit away, so the boundary can wrap individual points.]

#callout("intuition", title: [Plain idea])[RBF support vectors act as landmarks with distance-decaying influence. The kernel evaluates their similarity without explicitly constructing the feature map.]


#heading(level: 3)[Linear versus RBF boundaries, drawn]


A feature map can make a nonlinear separation linear in the transformed space.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/2d2953c035b492e0.cetz.json")], caption: [Linear versus RBF boundaries. One straight line cannot put a central region in its own class; an RBF kernel draws a smooth curved boundary that isolates it.]) <fig:svm-kernels>

#callout("keyidea", title: [Key idea])[A kernel changes the representation during fitting; it does not bend an already-trained line afterward.]


#heading(level: 2)[What $C$ and $gamma$ actually do]
 <sec:svm-controls>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/57141d719038066b.cetz.json")], caption: [What $C$ does. A small $C$ keeps a wide street and tolerates a stray point; a large $C$ narrows the street and bends to capture it, at the risk of overfitting.]) <fig:svm-c>

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Dial], [Plain meaning], [Turn it up when],),
    table.hline(),
    [$C$], [How badly you want to avoid mistakes on the training data], [The model underfits; the boundary is too simple],
    [$gamma$], [How far a single training point's influence reaches], [The boundary needs to be more local and wiggly],
  )]
  , kind: table
  )

#callout("analogy", title: [Analogy])[$C$ is a strictness setting for a teacher marking homework. A low $C$ teacher accepts that a few students will get things wrong and teaches a general rule. A high $C$ teacher insists that every single student's answer be accommodated, and ends up teaching a rule so contorted that nobody can apply it to a new question.

$gamma$ is the radius of each training point's voice. Low $gamma$ means every point is heard across the whole room, producing a smooth global boundary. High $gamma$ means each point is only heard by its immediate neighbors, producing islands around individual examples.]

#callout("workedexample", title: [Worked example])[Lab~3's grid search on 15,000 personal loans, RBF kernel with balanced class weights, three-fold cross-validated ROC AUC on the training rows (`scale` means $gamma = 1 \/ p$ on standardized data, here about 0.077 for thirteen columns):

#figure(
  align(center)[#table(
    columns: 4,
    align: (center,center,center,center,),
    table.header([$C$], [$gamma = 0.01$], [$gamma =$ scale], [$gamma = 0.1$],),
    table.hline(),
    [0.1], [#strong[0.718]], [0.714], [0.713],
    [1], [0.715], [0.707], [0.702],
    [10], [0.714], [0.665], [0.647],
  )]
  , kind: table
  )

Every cell lies between 0.647 and 0.718. The worst corner pairs the narrowest kernel with the largest $C$: each loan only speaks for its own neighborhood, and the boundary bends to fit every one. The winner, $C = 0.1$ with $gamma = 0.01$, is the smoothest setting in the grid, and it still keeps 11,478 of its 15,000 training loans as support vectors, 2,205 of them defaults: on noisy data most loans sit near the boundary. The best linear kernel scores 0.713 on 20,000 fresh test loans, against 0.716 for the RBF kernel, so here the curvature does almost no work.]


#heading(level: 2)[Multiclass SVMs and support vector regression]


Multiclass reductions include #strong[one-vs-rest] ($K$ classifiers) and #strong[one-vs-one] (one per class pair, combined by voting).

#strong[Support vector regression (SVR)] recycles the margin idea for numeric labels: build a tube of half-width $epsilon$ around the prediction and charge nothing for points inside it, using the $epsilon$-insensitive loss $max \( 0 \, thin \| y - f \( bold(x) \) \| - epsilon \)$. Only points on or outside the tube become support vectors.


#heading(level: 2)[Practical notes]


- #strong[Scale the features.] Apply the distance-geometry rule from #ref(label("sec:scaling"), supplement: [Section]).

- #strong[Tune $C$ (and $gamma$)] by cross-validation over logarithmic grids such as $10^(- 2) \, dots.h \, 10^3$.

- #strong[Scale limits:] kernel SVMs suit small-to-medium datasets; linear SVMs suit high-dimensional text. Large datasets may favor linear models or ensembles.

- #strong[Probabilities are not native.] SVMs output scores and margins; if calibrated probabilities are needed, apply and validate a calibration step (#ref(label("ch:evaluation"), supplement: [Chapter])).

#callout("modelcard", title: [The recipe: Support vector machine])[*1. Model* A separating line or plane, $bold(w)^(sans(T)) phi.alt \( bold(x) \) + b$, possibly in a kernel's richer space.

*2. Loss* Hinge loss plus a penalty that keeps the street wide; $C$ sets the balance.

*3. Optimizer* A convex quadratic program. Its one best answer depends only on the support vectors.]


#heading(level: 2)[Choosing a supervised model]
 <sec:supervised-model-choice>

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Model], [Useful strengths], [Important limitations],),
    table.hline(),
    [Linear regression], [Interpretable, fast, the standard first baseline], [Linear relationships only; sensitive to outliers],
    [Ridge / lasso], [Controls overfitting; lasso selects features], [Still linear; needs feature scaling],
    [Logistic regression], [Strong probability baseline, convex training, interpretable odds], [Linear boundary; calibration still needs checking],
    [LDA / QDA], [Fast, stable on small data], [Gaussian class assumptions],
    [$k$-NN], [No training, flexible boundaries], [Slow at prediction; scale- and dimension-sensitive],
    [Naive Bayes], [Very fast, strong text baseline], [Independence and calibration caveats (#ref(label("sec:naive-bayes"), supplement: [Section]))],
    [Decision tree], [Readable rules, no scaling, mixed data], [Unstable; overfits without pruning],
    [Random forest], [Robust, accurate, minimal tuning], [Larger, slower, less transparent],
    [Gradient boosting], [Often a very strong tabular benchmark], [Needs careful tuning and early stopping],
    [SVM], [Margins and kernels; strong in high dimensions], [Scaling required; slow on very large data],
  )]
  , kind: table
  )

Start with regularized linear models, and add complexity only for validated gains. In Lab~3 a tuned RBF SVM reaches a test ROC AUC of 0.716 on fresh loans, where $k$-NN scored 0.723, naive Bayes 0.716 and plain logistic regression 0.731 on validation. A linear SVM reaches 0.713. Here the extra complexity is not earned: the SVM is slower, its saved file holds 11,478 support vectors, and it ranks loans no better than a straight line. On data with a curved boundary the RBF kernel can win clearly; on noisy data like this, the simpler model is the one to keep.

#callout("modelcard", title: [Support Vector Machines - Quick Guide])[#block[
ll Best when & The dataset is small to medium sized, features are informative, and a strong margin-based boundary is useful. Preprocessing & Standardize numerical features; encode categories; remove clearly irrelevant features when justified by the validated workflow in #ref(label("sec:feature-selection"), supplement: [Section]). Main controls & $C$ for margin violations; kernel choice; $gamma$ for RBF-kernel reach; $epsilon$ for SVR. Watch for & Slow training on very large datasets, sensitive scale, difficult probability interpretation, and expensive kernel tuning.

]]

#callout("chapterrecap", title: [Chapter recap])[- An SVM chooses the widest street between the classes. Only the support vectors, the points on or inside its curbs, affect it.

- Soft margins charge hinge loss for violations, and $C$ sets how expensive those are.

- Mapping to richer features can make curved boundaries straight, and a kernel computes the needed dot products without visiting that space.

- $gamma$ sets how far one point's influence reaches. Tune $C$ and $gamma$ together, with scaling inside the folds.

- Across the supervised families, start simple and keep complexity only when validation pays for it.]

#callout("quickcheck", title: [Check your understanding])[+ What is the geometric meaning of a larger separating margin in an SVM?

+ In the six-point example, what happens to the fitted line if you delete the point $\( 4 \, 3 \)$? Why?

+ A point has $y \( bold(w)^(sans(T)) bold(x) + b \) = 0.7$. What is its hinge loss, and where is it?

+ How do $C$ and, for an RBF kernel, $gamma$ change the flexibility of the fitted decision boundary?

+ Why should scaling and SVM tuning both happen inside the validation procedure?]
