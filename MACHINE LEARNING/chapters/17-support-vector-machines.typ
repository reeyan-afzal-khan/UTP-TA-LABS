#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "17-support-vector-machines")

= Support Vector Machines and Supervised Synthesis <ch:svm>

#chapterguide[Linear classifiers from #chapref(<ch:classification>), model-capacity ideas from #chapref(<ch:training>), and dot products and norms from #chapref(<ch:foundations>).][find a maximum-margin line on a small example; compute hinge loss; explain what $C$ and $gamma$ do; check the kernel trick with numbers; scale and tune an SVM inside validation; and choose among all the supervised families in this book.]

Two neighborhoods sit on either side of open ground, and the council wants to build a road between them. Many routes would keep every house on the correct side. The sensible one is the route that leaves the widest clearance, because a slightly misplaced new house is then still on the correct side. A #term[support vector machine (SVM)] chooses its boundary by the same reasoning, and only the houses at the edge of the road affect where it runs.

== The widest street

#utpfig([The widest street. A hard-margin SVM places the boundary in the middle of the widest margin between the classes; the circled support vectors on its edges determine it.], label: <fig:svm-margin>)[
  #canvas(scale: 0.85, {
    for p in ((1, 1), (2, 1.2), (1, 2.6), (0.8, 1.8), (2.4, 0.8)) {
      circle-at(p, 2.0324pt, fill: auto, draw: none)
    }
    for p in ((4, 4), (5, 3.5), (3.6, 4.9), (4.6, 4.7), (5.2, 2.9)) {
      circle-at(p, 2.0324pt, line-width: widths.thick, fill: pale-orange)
    }
    circle-at((1.5, 2.5), 2.0324pt, fill: auto, draw: none)
    circle-at((2.5, 3.5), 2.0324pt, line-width: widths.thick, fill: pale-orange)
    circle-at((4, 2), 2.0324pt, line-width: widths.thick, fill: pale-orange)
    circle-at((1.5, 2.5), 4.6576pt)
    circle-at((2.5, 3.5), 4.6576pt)
    circle-at((4, 2), 4.6576pt)
    connect((0, 5), (5, 0), line-width: widths.thick)
    connect((4.6, 0.4), (5.45, -0.35), line-width: widths.thin, draw: muted)
    node(along((4.6, 0.4), (5.45, -0.35), t: 100%), [$bold(w)^(sans(T))bold(x)+b=0$], font: font("small"), xshift: -0.9963pt, anchor: "west")
    connect((0, 4), (4, 0), dash: "dashed")
    connect((0, 6), (6, 0), dash: "dashed")
    connect((3.6, 0.4), (4.6, 1.4), line-width: widths.thick, start: tip("Stealth", length: 2mm, line: widths.thick), end: tip("Stealth", length: 2mm, line: widths.thick))
    node(along((3.6, 0.4), (4.6, 1.4), t: 100%), [margin], font: font("small"), yshift: 0pt, xshift: 0.9963pt, anchor: "south-west")
    node((6, 5.35), [circled points = \
  support vectors], font: font("small"), align: left)
  })
]

#workedexample[
  Six points: $(1,1)$, $(2,1)$, $(1,2)$ are class $-1$, and $(3,3)$, $(4,3)$, $(3,4)$ are class $+1$ (#figref(<fig:svm-toy>)). The SVM’s answer is $bold(w)=(inline(frac(2, 3)),inline(frac(2, 3)))$ and $b=-3$. Check the score $y(bold(w)^(sans(T))bold(x)+b)$ at each point: for $(2,1)$ it is $-1 times (inline(frac(2, 3)) dot.op 3-3)=1$, and for $(1,2)$ and $(3,3)$ it is also exactly 1. These three are the #term[support vectors]. The other three score 1.67, so they sit beyond the curb and do not affect the street at all. Delete them and the answer stays the same.

  The street’s width is $2\/ || bold(w) || _2=2\/(inline(frac(2, 3))sqrt(2))=2.12$.
]

#utpfig([The fitted boundary and its two curbs on six points. The three circled support vectors sit exactly on the curbs. The street is 2.12 wide.], label: <fig:svm-toy>)[
  #canvas({
    axis(..logaxis, width: 7.2cm, height: 6.4cm, axis-equal-image: true, xmin: 0, xmax: 5, ymin: 0, ymax: 5, xlabel: [$x_1$], ylabel: [$x_2$], xtick: (0, 1, 2, 3, 4, 5), ytick: (0, 1, 2, 3, 4, 5),
      addplot(draw: navy, line-width: widths.very-thick, domain: (0, 4.5), x => 4.5 - x),
      addplot(draw: navy, dash: "dashed", domain: (0, 3), x => 3 - x),
      addplot(draw: navy, dash: "dashed", domain: (1, 5), x => 6 - x),
      addplot(only-marks: true, mark: "*", mark-size: 2.1918pt, draw: blue, fill: blue, coords: ((1, 1), (2, 1), (1, 2))),
      addplot(only-marks: true, mark: "square*", mark-size: 2.1918pt, draw: orange, fill: orange, coords: ((3, 3), (4, 3), (3, 4))),
      addplot(only-marks: true, mark: "o", mark-size: 4.1843pt, draw: red, line-width: widths.thick, coords: ((2, 1), (1, 2), (3, 3))),
      {
        node((0.15, 0.35), [class $-1$], font: font("script", fill: navy), anchor: "west")
        node((4.9, 4.6), [class $+1$], font: font("script", fill: navy), anchor: "east")
      },
    )
  })
]

== The hard-margin objective

For $y_i in { -1,+1 }$, require correctly signed linear scores of magnitude at least one:

$ min_(bold(w),b) space frac(1, 2) || bold(w) || _2^2 quad "subject to" quad y_i(bold(w)^(sans(T))bold(x)_i+b) >= 1 . $

The constraint requires the correct sign and score magnitude at least~1. The margin width is $2\/ || bold(w) || _2$, so minimizing the norm maximizes that width.

== The soft margin: allowing exceptions

Real classes overlap, so the SVM used in practice permits violations and charges for them:

$ min_(bold(w),b) space frac(1, 2) || bold(w) || _2^2 +C sum _(i=1)^n max(0, thin 1-y_i(bold(w)^(sans(T))bold(x)_i+b)). $

#term[Hinge loss] is zero beyond the margin and linear within it or on the wrong side. $C$ balances margin width against violations:

#workedexample[
  The hinge loss is $max(0, thin 1-m)$, where $m=y(bold(w)^(sans(T))bold(x)+b)$ measures how far a point is on the right side, in margin units.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    align: (left, center, center),
    header: ([Where the point is], [$m$], [Hinge loss]),
    [Well beyond the curb], [2.0], [0.0],
    [Exactly on the curb], [1.0], [0.0],
    [Inside the street, right side], [0.4], [0.6],
    [On the wrong side], [$-0.5$], [1.5],
  )

  #raggedright[
  #v(6pt)
  Points beyond the curb cost nothing and so have no effect on the fit. Log loss, by contrast, keeps rewarding more confidence forever.
  ]]]
]

- #term[Large $C$]: violations cost more; weaker regularization can overfit.
- #term[Small $C$]: more violations are tolerated; regularization is stronger.

Both SVMs and regularized logistic regression combine loss with an $L_2$ penalty. Hinge loss becomes zero beyond the margin; cross-entropy continues rewarding confidence.

== Curved boundaries: mapping up

Some datasets cannot be separated by any straight line --- but they can be after the features are transformed.

#workedexample[
  Let $x in { -2,2 }$ be class A and $x in { -1,0,1 }$ class B. No single threshold separates them. Map to $phi.alt (x)=(x,x^2)$:

  #utptable[
    #tabularx(
      columns: (auto, auto, auto, auto, auto, auto),
      align: (left, center, center, center, center, center),
      header: ([$x$], [$-2$], [$-1$], [$0$], [$1$], [$2$]),
      [$x^2$], [$4$], [$1$], [$0$], [$1$], [$4$],
      [class], [A], [B], [B], [B], [A],
    )
  ]

  Class A has height 4 and class B at most 1. The line $x^2=2.5$ separates them, corresponding to two thresholds $|x|=sqrt(2.5)$ in the original space.
]

#analogy[
  Marbles of two colors lie on a table, with one color in a ring around the other. No straight stick can separate them. Give the table a sharp tap from below so the central marbles fly up, and a flat sheet of card can slide between the two groups. A new feature gives you the extra height.
]

== The kernel trick

Rich feature maps can be expensive or infinite-dimensional. The SVM’s equations happen to use the mapped rows only through dot products, and a #term[kernel function] computes those dot products directly:

$ k(bold(x),bold(x)')= phi.alt (bold(x))^(sans(T)) phi.alt (bold(x)'), $

so the mapped features never need to be constructed at all. That shortcut is the #term[kernel trick].

#workedexample[
  Let $phi.alt (bold(v))=(v_1^2, space sqrt(2) thin v_1 v_2, space v_2^2)$, and take $bold(x)=(1,2)$ and $bold(z)=(3,1)$. The long way: $phi.alt (bold(x))=(1, space 2.83, space 4)$ and $phi.alt (bold(z))=(9, space 4.24, space 1)$, whose dot product is $9+12+4=25$. The short way: $(bold(x)^(sans(T))bold(z))^2=(3+2)^2=25$. Same answer, with no need to visit the larger space.
]

Standard choices:

#utptable[
  #tabularx(
    columns: (auto, auto, auto),
    header: ([Kernel], [Formula], [Boundary it produces]),
    [Linear], [$bold(x)^(sans(T))bold(x)'$], [Straight; fast on huge, sparse data],
    [Polynomial], [$(( gamma thin bold(x)^(sans(T))bold(x)'+r))^d$], [Curved, degree-$d$ interactions],
    [RBF (Gaussian)], [$exp(- gamma || bold(x)-bold(x)' || _2^2)$], [Smooth, local, very flexible],
  )
]

The #term[RBF kernel] measures similarity that decays with distance. Small $gamma$ gives broad influence and smooth boundaries; large $gamma$ gives local, flexible boundaries. Tune $C$ and $gamma$ together on logarithmic grids.

#workedexample[
  RBF similarity $exp(- gamma d^2)$ between two points at distance $d$:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto),
    align: (center, center, center, center),
    header: ([$gamma$], [$d=0.5$], [$d=1$], [$d=2$]),
    [0.1], [0.975], [0.905], [0.670],
    [1], [0.779], [0.368], [0.018],
    [10], [0.082], [0.000], [0.000],
  )

  #raggedright[
  #v(6pt)
  At $gamma =10$ a training point has almost no influence even one unit away, so the boundary can wrap individual points.
  ]]]
]

#intuition[
  RBF support vectors act as landmarks with distance-decaying influence. The kernel evaluates their similarity without explicitly constructing the feature map.
]

=== Linear versus RBF boundaries, drawn

A feature map can make a nonlinear separation linear in the transformed space.

#utpfig([Linear versus RBF boundaries. One straight line cannot put a central region in its own class; an RBF kernel draws a smooth curved boundary that isolates it.], label: <fig:svm-kernels>)[
  #canvas({
    draw.scope({
      rectangle((0, 0), (4.7, 3.8), draw: mix(muted, 70%), fill: white)
      node((2.35, 4.2), [Linear kernel], font: font("small", weight: "bold", fill: navy))
      for p in ((2, 1.7), (2.4, 1.9), (2.1, 2.3), (2.7, 2.2), (2.55, 1.55)) {
        circle-at(p, 2.5903pt, fill: blue, draw: none)
      }
      for p in ((0.65, 0.65), (1, 3.05), (3.75, 0.7), (4, 3), (0.55, 2), (4.15, 1.85)) {
        circle-at(p, 2.8892pt, line-width: widths.very-thick, draw: orange)
      }
      connect((0.35, 2.9), (4.35, 0.85), line-width: widths.very-thick, draw: navy)
      node((2.35, -0.48), [one straight line cannot \
  put the center in its own class], font: font("script"), align: center, text: red)
    })
    draw.scope({
      draw.translate((6, 0))
      rectangle((0, 0), (4.7, 3.8), draw: mix(muted, 70%), fill: white)
      node((2.35, 4.2), [RBF kernel], font: font("small", weight: "bold", fill: navy))
      for p in ((2, 1.7), (2.4, 1.9), (2.1, 2.3), (2.7, 2.2), (2.55, 1.55)) {
        circle-at(p, 2.5903pt, fill: blue, draw: none)
      }
      for p in ((0.65, 0.65), (1, 3.05), (3.75, 0.7), (4, 3), (0.55, 2), (4.15, 1.85)) {
        circle-at(p, 2.8892pt, line-width: widths.very-thick, draw: orange)
      }
      circle-at((2.35, 1.95), (1.15, 0.92), line-width: widths.very-thick, draw: teal)
      node((2.35, -0.48), [a smooth curved boundary \
  can isolate the local region], font: font("script"), align: center, text: green)
    })
    node((4.9, 4.18), [$bullet$ class A], font: font("script", fill: blue))
    node((6.65, 4.18), [$compose$ class B], font: font("script", fill: orange))
  })
]

#keyidea[
  A kernel changes the representation during fitting; it does not bend an already-trained line afterward.
]

#keepspace(243.9pt)

== What $C$ and $gamma$ actually do <sec:svm-controls>

#utpfig([What $C$ does. A small $C$ keeps a wide street and tolerates a stray point; a large $C$ narrows the street and bends to capture it, at the risk of overfitting.], label: <fig:svm-c>)[
  #canvas(scale: 0.82, {
    draw.scope({
      rectangle((0, 0), (3.5, 2.8), draw: muted, fill: white)
      connect((0.3, 0.2), (3.2, 2.6), line-width: widths.very-thick, draw: navy)
      connect((0.05, 0.75), (2.7, 2.95), dash: "dashed", draw: navy)
      connect((0.75, -0.15), (3.5, 2.15), dash: "dashed", draw: navy)
      connect((0.05, 0.75), (2.7, 2.95), (3.5, 2.15), (0.75, -0.15), (0.05, 0.75), fill: mix(blue, 12%), draw: none)
      connect((0.3, 0.2), (3.2, 2.6), line-width: widths.very-thick, draw: navy)
      for p in ((0.5, 1.9), (1, 2.4), (0.35, 1.35), (1.5, 2.65)) {
        circle-at(p, 1.7973pt, fill: blue, draw: none)
      }
      for p in ((2.4, 0.5), (2.9, 1), (3.2, 0.4), (1.9, 0.25)) {
        circle-at(p, 1.7973pt, fill: orange, draw: none)
      }
      circle-at((1.65, 1.6), 1.7973pt, fill: orange, draw: none)
      node((1.75, 3.15), [small $C$: wide street], font: font("small", weight: "bold", fill: navy))
      node((1.75, -0.55), [tolerates the stray point \
  simpler, may underfit], font: font("script"), align: center, text: muted)
    })
    draw.scope({
      draw.translate((4.6, 0))
      rectangle((0, 0), (3.5, 2.8), draw: muted, fill: white)
      connect((0.35, 0.95), (2.15, 2.9), (2.6, 2.5), (0.8, 0.55), (0.35, 0.95), fill: mix(red, 10%), draw: none)
      connect((0.2, 0.5), (1.2, 1.3), (1.45, 1.85), (2, 2.2), (2.6, 2.8), line-width: widths.very-thick, rounded: 1.9925pt, draw: red)
      for p in ((0.5, 1.9), (1, 2.4), (0.35, 1.35), (1.5, 2.65)) {
        circle-at(p, 1.7973pt, fill: blue, draw: none)
      }
      for p in ((2.4, 0.5), (2.9, 1), (3.2, 0.4), (1.9, 0.25)) {
        circle-at(p, 1.7973pt, fill: orange, draw: none)
      }
      circle-at((1.65, 1.6), 1.7973pt, fill: orange, draw: none)
      circle-at((1.4, 1.45), 0.32, line-width: widths.very-thick, draw: red)
      node((1.75, 3.15), [large $C$: narrow street], font: font("small", weight: "bold", fill: navy))
      node((1.75, -0.55), [bends to capture it \
  complex, may overfit], font: font("script"), align: center, text: muted)
    })
  })
]

#utptable[
  #tabularx(
    columns: (10%, 27%, 1fr),
    styles: (navy-bold,),
    header: ([Dial], [Plain meaning], [Turn it up when]),
    [$C$], [How badly you want to avoid mistakes on the training data], [The model underfits; the boundary is too simple],
    [$gamma$], [How far a single training point’s influence reaches], [The boundary needs to be more local and wiggly],
  )
]

#analogy[
  $C$ is a strictness setting for a teacher marking homework. A low $C$ teacher accepts that a few students will get things wrong and teaches a general rule. A high $C$ teacher insists that every single student’s answer be accommodated, and ends up teaching a rule so contorted that nobody can apply it to a new question.

  $gamma$ is the radius of each training point’s voice. Low $gamma$ means every point is heard across the whole room, producing a smooth global boundary. High $gamma$ means each point is only heard by its immediate neighbors, producing islands around individual examples.
]

#workedexample[
  Lab~3’s grid search on 15,000 personal loans, RBF kernel with balanced class weights, three-fold cross-validated ROC AUC on the training rows (`scale` means $gamma =1\/p$ on standardized data, here about 0.077 for thirteen columns):

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto),
    align: (center, center, center, center),
    header: ([$C$], [$gamma =0.01$], [$gamma =$ scale], [$gamma =0.1$]),
    [0.1], [#strong[0.718]], [0.714], [0.713],
    [1], [0.715], [0.707], [0.702],
    [10], [0.714], [0.665], [0.647],
  )

  #raggedright[
  #v(6pt)
  Every cell lies between 0.647 and 0.718. The worst corner pairs the narrowest kernel with the largest $C$: each loan only speaks for its own neighborhood, and the boundary bends to fit every one. The winner, $C=0.1$ with $gamma =0.01$, is the smoothest setting in the grid, and it still keeps 11,478 of its 15,000 training loans as support vectors, 2,205 of them defaults: on noisy data most loans sit near the boundary. The best linear kernel scores 0.713 on 20,000 fresh test loans, against 0.716 for the RBF kernel, so here the curvature does almost no work.
  ]]]
]

== Multiclass SVMs and support vector regression

Multiclass reductions include #term[one-vs-rest] ($K$ classifiers) and #term[one-vs-one] (one per class pair, combined by voting).

#term[Support vector regression (SVR)] recycles the margin idea for numeric labels: build a tube of half-width $epsilon$ around the prediction and charge nothing for points inside it, using the $epsilon$-insensitive loss $max(0, thin |y-f(bold(x))|- epsilon )$. Only points on or outside the tube become support vectors.

== Practical notes

- #term[Scale the features.] Apply the distance-geometry rule from #secref(<sec:scaling>).
- #term[Tune $C$ (and $gamma$)] by cross-validation over logarithmic grids such as $10^(-2), dots.h ,10^3$.
- #term[Scale limits:] kernel SVMs suit small-to-medium datasets; linear SVMs suit high-dimensional text. Large datasets may favor linear models or ensembles.
- #term[Probabilities are not native.] SVMs output scores and margins; if calibrated probabilities are needed, apply and validate a calibration step (#chapref(<ch:evaluation>)).

#recipecard([Support vector machine], [A separating line or plane, $bold(w)^(sans(T)) phi.alt (bold(x))+b$, possibly in a kernel’s richer space.], [Hinge loss plus a penalty that keeps the street wide; $C$ sets the balance.], [A convex quadratic program. Its one best answer depends only on the support vectors.])

== Choosing a supervised model <sec:supervised-model-choice>

#utptable[
  #tabularx(
    columns: (19%, 36%, 36%),
    valign: (top, top, top),
    header: ([Model], [Useful strengths], [Important limitations]),
    [Linear regression], [Interpretable, fast, the standard first baseline], [Linear relationships only; sensitive to outliers],
    [Ridge / lasso], [Controls overfitting; lasso selects features], [Still linear; needs feature scaling],
    [Logistic regression], [Strong probability baseline, convex training, interpretable odds], [Linear boundary; calibration still needs checking],
    [LDA / QDA], [Fast, stable on small data], [Gaussian class assumptions],
    [$k$-NN], [No training, flexible boundaries], [Slow at prediction; scale- and dimension-sensitive],
    [Naive Bayes], [Very fast, strong text baseline], [Independence and calibration caveats (#secref(<sec:naive-bayes>))],
    [Decision tree], [Readable rules, no scaling, mixed data], [Unstable; overfits without pruning],
    [Random forest], [Robust, accurate, minimal tuning], [Larger, slower, less transparent],
    [Gradient boosting], [Often a very strong tabular benchmark], [Needs careful tuning and early stopping],
    [SVM], [Margins and kernels; strong in high dimensions], [Scaling required; slow on very large data],
  )
]

Start with regularized linear models, and add complexity only for validated gains. In Lab~3 a tuned RBF SVM reaches a test ROC AUC of 0.716 on fresh loans, where $k$-NN scored 0.723, naive Bayes 0.716 and plain logistic regression 0.731 on validation. A linear SVM reaches 0.713. Here the extra complexity is not earned: the SVM is slower, its saved file holds 11,478 support vectors, and it ranks loans no better than a straight line. On data with a curved boundary the RBF kernel can win clearly; on noisy data like this, the simpler model is the one to keep.

#modelcard[Support Vector Machines - Quick Guide][
  #tabularx(
    columns: (24%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Best when], [The dataset is small to medium sized, features are informative, and a strong margin-based boundary is useful.],
    [Preprocessing], [Standardize numerical features; encode categories; remove clearly irrelevant features when justified by the validated workflow in #secref(<sec:feature-selection>).],
    [Main controls], [$C$ for margin violations; kernel choice; $gamma$ for RBF-kernel reach; $epsilon$ for SVR.],
    [Watch for], [Slow training on very large datasets, sensitive scale, difficult probability interpretation, and expensive kernel tuning.],
  )
]

#chapterrecap[
  - An SVM chooses the widest street between the classes. Only the support vectors, the points on or inside its curbs, affect it.
  - Soft margins charge hinge loss for violations, and $C$ sets how expensive those are.
  - Mapping to richer features can make curved boundaries straight, and a kernel computes the needed dot products without visiting that space.
  - $gamma$ sets how far one point’s influence reaches. Tune $C$ and $gamma$ together, with scaling inside the folds.
  - Across the supervised families, start simple and keep complexity only when validation pays for it.
]

#quickcheck[
  + What is the geometric meaning of a larger separating margin in an SVM?
  + In the six-point example, what happens to the fitted line if you delete the point $(4,3)$? Why?
  + A point has $y(bold(w)^(sans(T))bold(x)+b)=0.7$. What is its hinge loss, and where is it?
  + How do $C$ and, for an RBF kernel, $gamma$ change the flexibility of the fitted decision boundary?
  + Why should scaling and SVM tuning both happen inside the validation procedure?
]
