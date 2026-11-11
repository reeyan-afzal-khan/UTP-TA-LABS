#import "/.shared/typst/utp.typ": *
#unit("chapters", "15-clustering")


#heading(level: 1)[Clustering]
 <ch:clustering>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* #ref(label("ch:unsupervised"), supplement: [Chapter]), feature scaling, vectors, distances, and the Gaussian distribution from #ref(label("ch:foundations"), supplement: [Chapter]).

*By the end, you can:* trace $K$-means by hand; explain why starting points matter; choose $K$ with evidence; compute a silhouette; compare centroid, hierarchical, density and soft clustering; and treat a clustering as a hypothesis.]

Sort the ten students of the study log into groups of similar students. Nobody has told us what the groups are. Each method in this chapter defines a group differently: $K$-means uses compact groups around a center, hierarchical methods build nested families, DBSCAN follows density, and mixture models give each row partial membership. We start with the first one and follow it by hand.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Assignment style], [Meaning], [Examples],),
    table.hline(),
    [Hard clustering], [Every row receives one cluster label. The memberships are mutually exclusive in the final partition.], [$K$-means, $K$-medoids, DBSCAN, agglomerative clustering],
    [Soft clustering], [Every row can have partial membership in several groups, usually summarized by a vector of membership degrees or component responsibilities.], [Fuzzy $C$-means, Gaussian mixture models],
  )]
  , kind: table
  )

Hard and soft are about the #emph[form of the assignment], not about whether an algorithm is better. If customers can genuinely sit between segments, a membership vector may preserve useful ambiguity that a single label throws away.


#heading(level: 2)[$K$-means: landmarks]
 <sec:kmeans>

Put each student on a chart, with hours across the bottom and mark up the side, so that each student is a dot. To say that two students are similar, we need to measure how far apart their dots are. Suppose each group has a #strong[landmark], one point marking its center. Textbooks call it the #strong[centroid].

Two facts make this easy, and they point in opposite directions. If someone handed us the landmarks, the groups would be easy: each student joins the nearest one. If someone handed us the groups, the landmarks would be easy: each one is just the average of its members. Each needs the other, and we have neither.

#callout("analogy", title: [Analogy])[The way out is a guess that is almost certainly wrong, made on purpose. Drop the landmarks anywhere, say on $K$ randomly chosen students. Everyone joins their nearest landmark. Those groups are probably bad, but they are groups, so each landmark can move to the center of the people who joined it. Now some students are nearer a different landmark, so they switch. Keep taking turns until nobody switches.]

That loop is #strong[Lloyd's algorithm], and it is the whole of $K$-means. "Nearest" needs a measure, and Pythagoras supplies one: the squared distance from student A at $\( 2 \, 47 \)$ to a landmark at $\( 8 \, 65 \)$ is $6^2 + 18^2 = 360$. Skipping the square root does not change which landmark is nearest.

#source-code("/MACHINE LEARNING/all_experiments/book_checks/demo_study_log.py", first: 84, last: 96, lang: "python")

#callout("workedexample", title: [Worked example])[Three groups, starting from students D, F and J, so the landmarks start at $\( 8 \, 65 \)$, $\( 12 \, 77 \)$ and $\( 20 \, 38 \)$.

#figure(
  align(center)[#table(
    columns: 2,
    align: (center,left,),
    table.header([Round], [Assign: who joins each landmark],),
    table.hline(),
    [1], [A B C D E G ~$\|$ ~F ~$\|$ ~H I J],
    [2], [A B C D G ~$\|$ ~E F ~$\|$ ~H I J],
    [3], [A B C G ~$\|$ ~D E F ~$\|$ ~H I J],
    [4], [A B C ~$\|$ ~D E F G ~$\|$ ~H I J],
    [5], [the same as round 4, so stop],
  )]
  , kind: table
  )

Check round 1 for student A: the squared distances to the three landmarks are 360, 1,000 and 405, so A joins the first. Then the move step: the first group's average is $\( 2 + 4 + 6 + 8 + 10 + 14 \) \/ 6 = 7.33$ hours and $\( 47 + 50 + 59 + 65 + 68 + 62 \) \/ 6 = 58.5$ marks. The landmark moves there, and that is why E switches in round 2.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/d37b81b0fe450699.cetz.json")], caption: [Four rounds of $K$-means on hours and mark. Crosses mark the landmarks in use at each round's assignment; students take the marker of their group. One student changes group per round, until nothing changes.]) <fig:kmeans-rounds>

Here are the three groups, with their final landmarks. The names are ours: the method only sorted dots.

#figure(
  align(center)[#table(
    columns: 5,
    align: (left,left,left,left,left,),
    table.header([Students], [Mean hours], [Mean mark], [Subtotal], [Our name for them],),
    table.hline(),
    [A, B, C], [4.0], [52.0], [86.00], [Light studiers: few hours, moderate marks],
    [D, E, F, G], [11.0], [68.0], [146.00], [Steady: solid hours, the best marks],
    [H, I, J], [18.0], [44.33], [108.67], [Crammers: the most hours, the lowest marks],
  )]
  , kind: table
  )

The method found that very long hours go with low marks. It did not say why. That the crammers skipped lectures and barely slept is our reading of columns $K$-means never saw, and #ref(label("ch:dimred"), supplement: [Chapter]) checks it against all four columns.


#heading(level: 3)[The score it minimizes]


Draw a line from every student to their own landmark. A good grouping has short lines. Squaring and adding them gives one number, the #strong[inertia] or within-cluster sum of squares: $ "argmin"_(S_1 \, dots.h \, S_K) sum_(j = 1)^K sum_(bold(x)_i in S_j) parallel bold(x)_i - bold(mu)_j parallel_2^2 . $ For the light studiers it is $\( 4 + 25 \) + \( 0 + 4 \) + \( 4 + 49 \) = 86$. The three subtotals add to 340.67, the score of this grouping. Neither step can make the score worse: reassigning a point to a nearer landmark lowers it, and moving a landmark to the mean of its members lowers it. So the loop must stop.

#callout("modelcard", title: [The recipe: $K$-means])[*1. Model* $K$ landmarks, each a point in feature space.

*2. Loss* Total squared distance from each row to its own landmark.

*3. Optimizer* A greedy loop: assign, move, repeat until nothing changes.]


#heading(level: 3)[$K$-means as a four-frame loop]


Initialize centers, assign points, update centers, and repeat.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/b8128467b90b0ecc.cetz.json")], caption: [$K$-means as a loop: initialize the centers, assign each point to its nearest center, move each center to the mean of its points, and repeat until nothing changes.]) <fig:kmeans-loop>

#callout("workedexample", title: [Worked example])[Cluster the one-dimensional points ${ 1 \, 2 \, 3 \, 10 \, 11 \, 12 }$ with $K = 2$, starting from centers $c_1 = 1$ and $c_2 = 12$. #emph[Assign:] points $1 \, 2 \, 3$ are nearer $c_1$; points $10 \, 11 \, 12$ are nearer $c_2$. #emph[Update:] $c_1 = \( 1 + 2 + 3 \) \/ 3 = 2$ and $c_2 = \( 10 + 11 + 12 \) \/ 3 = 11$. #emph[Assign again:] nothing moves, so the algorithm stops. The objective is $\( 1 + 0 + 1 \) + \( 1 + 0 + 1 \) = 4$, and the two obvious groups have been found in one round.]

$K$-means implicitly assumes clusters are compact, roughly spherical, and similar in size; it struggles with elongated or irregular shapes, very different cluster sizes, and outliers (a single far-away point drags its center toward it).


#heading(level: 2)[Initialization and stability]


The loop never looks ahead and never tries a different start, so it is greedy, and the final groups can depend on where it began.

#callout("workedexample", title: [Worked example])[The study log has 120 possible starting trios. Trying them all, 25 reach the best score, 340.67. The others stop at eleven worse answers, up to 778.50, where the start from D, G and J gets stuck.

Real data can go either way. Lab~4's 5,878 customers with $K = 4$ and one random start, seeds 0 to 7, all end with inertia between 4,963.7 and 4,964.0: four well-separated groups leave little room for a bad start. Lab~4's 9,357 wood-defect images, reduced to 50 components, with $K = 7$ and one start each, end between 248,598 and 251,895, and only three of the eight land within a few units of the best.]

So use a smart start and many restarts. scikit-learn's `k-means++` spreads the starting landmarks apart, and `n_init` runs several starts and keeps the best; Lab~4 uses 10 or 20. Mini-batches trade some fit quality for speed. Compare restarts and resamples, and treat very different solutions at the same $K$ as ambiguity worth reporting.

#callout("keyidea", title: [Key idea])[Check multiple initializations and resamples before interpreting clusters.]


#heading(level: 2)[Choosing $K$: the elbow and the silhouette]


Why three groups and not two or seven? More groups always lower the score, until every row has its own landmark and the score is zero. So the score alone will never say stop. Look at how much each extra group helps.

#callout("workedexample", title: [Worked example])[Best total for each $K$ on the study log, trying every start:

#figure(
  align(center)[#table(
    columns: 7,
    align: (left,center,center,center,center,center,center,),
    table.header([$K$], [1], [2], [3], [4], [5], [6],),
    table.hline(),
    [Total], [1666.90], [636.80], [340.67], [195.17], [101.00], [57.67],
    [Saved by this group], [], [1030.1], [296.1], [145.5], [94.2], [43.3],
  )]
  , kind: table
  )

The savings shrink quickly, and by $K = 4$ an extra group saves less than half of what the third did. Picking $K$ at that bend is the #strong[elbow method]. There is no strict rule, only a bend and a choice, and three matches a story the tutor can use.]

The #strong[silhouette] scores each row on how much closer it is to its own group than to the next nearest one: $ s \( i \) = frac(b \( i \) - a \( i \), max { a \( i \) \, b \( i \) }) \, $ where $a \( i \)$ is the mean distance to its own group and $b \( i \)$ is the smallest mean distance to another group. Near 1 means well placed, near 0 means on a border, and negative means probably in the wrong group.

#callout("workedexample", title: [Worked example])[For ${ 1 \, 2 \, 3 }$ and ${ 10 \, 11 \, 12 }$, take the point 3. Its mean distance to its own group is $a = \( 2 + 1 \) \/ 2 = 1.5$, and to the other group it is $b = \( 7 + 8 + 9 \) \/ 3 = 8$. So $s = \( 8 - 1.5 \) \/ 8 = 0.8125$. The mean over all six points is 0.850, which says these groups are very clear.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/47260f50b2663381.cetz.json")], caption: [Choosing $K$ for Lab~4's 5,878 customers. Inertia always falls as $K$ grows, so look for the bend, here gentle and around 4. The silhouette peaks at $K = 2$ with 0.439, and among richer splits $K = 4$ (0.365) beats its neighbors.]) <fig:elbow-silhouette>

#callout("intuition", title: [Plain idea])[Inertia decreases as $K$ increases, reaching zero with one cluster per point, so look for diminishing gains rather than its minimum. Silhouette favors compact, separated groups. Neither alone establishes that a grouping is useful: in Lab~4 they narrow the choice to two or four, and what the segments are for picks four.]


#heading(level: 3)[$K$-medoids]


$K$-medoids is a robust alternative to $K$-means: each cluster is represented by an actual observation (its #strong[medoid]) rather than a mean, and any distance function may be used. Medoids resist outliers (a far point cannot drag a medoid the way it drags a mean) and make sense for data where averaging is meaningless --- at a higher computational price.


#heading(level: 2)[Gaussian mixture models]


$K$-means forces every row into one group. A student on the border between two groups would rather say "a bit of both". A #strong[Gaussian mixture model (GMM)] is a probabilistic relative of $K$-means that allows this. It assumes the rows were generated from $K$ bell-shaped components with mixing weights $pi_k$:

$ p \( bold(x) \) = sum_(k = 1)^K pi_k thin cal(N) \( bold(x) divides bold(mu)_k \, Sigma_k \) \, #h(2em) sum_(k = 1)^K pi_k = 1 . $ Instead of hard assignments, each observation receives a #strong[responsibility]: the posterior probability that component $k$ generated it, $ gamma_(i k) = frac(pi_k thin cal(N) \( bold(x)_i divides bold(mu)_k \, Sigma_k \), sum_(j = 1)^K pi_j thin cal(N) \( bold(x)_i divides bold(mu)_j \, Sigma_j \)) . $

#callout("workedexample", title: [Worked example])[Two equally weighted components, $cal(N) \( 0 \, 1 \)$ and $cal(N) \( 4 \, 1 \)$. A point at 1.5 is much more likely under the first: its responsibility for that component is 0.881. At 2.0, exactly halfway, it is 0.500. At 3.0 it is 0.018. Membership slides smoothly from one component to the other, which a hard assignment cannot express.]

#strong[Expectation-maximization (EM)] alternates responsibility estimation (E-step) with weighted updates of $pi_k$, $bold(mu)_k$, and $Sigma_k$ (M-step), improving data log-likelihood until convergence.

#callout("intuition", title: [Plain idea])[EM alternates estimating memberships and component shapes. $K$-means follows a similar cycle with hard assignments.]

GMMs provide soft memberships, elliptical components, and density-based anomaly scores (#ref(label("ch:anomaly"), supplement: [Chapter])). Responsibilities are probabilities under the mixture assumptions, not proof of real-world group membership.


#heading(level: 2)[Fuzzy $C$-means: soft distance-based clustering]


#strong[Fuzzy $C$-means] (FCM) keeps the centroid idea of $K$-means but replaces a one-hot assignment with membership degrees $u_(i k) in \[ 0 \, 1 \]$ that sum to 1 across clusters for each observation. A common objective is $ sum_i sum_(k = 1)^K u_(i k)^m thin parallel bold(x)_i - bold(c)_k parallel_2^2 \, $ where $m > 1$ is the #strong[fuzziness parameter]. Larger $m$ produces softer memberships; $m = 2$ is a common teaching default.

The algorithm alternates between two updates:

+ recompute each centroid as a membership-weighted mean;

+ recompute each observation's memberships from its relative distances to all centroids.

The iterations stop when memberships or centers change by less than a chosen tolerance.

#callout("intuition", title: [Plain idea])[$K$-means asks, "Which center is closest?" FCM asks, "How strongly does each center describe this point?" A boundary case might be 0.52 in cluster A and 0.45 in cluster B instead of being forced to pretend it is unambiguously A.]

#callout("workedexample", title: [Worked example])[With $m = 2$, memberships come from inverse squared distances. A point at distance 1 from center A and 3 from center B has membership $\( 1 \/ 1 \) \/ \( 1 \/ 1 + 1 \/ 9 \) = 0.90$ in A and 0.10 in B.]

#callout("pitfall", title: [Common mistake])[FCM memberships are distance-based degrees controlled by scale, cluster count, and fuzziness. Unlike GMM responsibilities, they do not imply a generative probability model.]


#heading(level: 2)[Hierarchical clustering]
 <sec:hierarchical-clustering>

#strong[Agglomerative clustering] starts with one cluster per observation and repeatedly merges the closest pair. A #strong[dendrogram] records the hierarchy.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Direction], [Start], [Repeated operation],),
    table.hline(),
    [Agglomerative (bottom-up)], [One cluster per observation], [Merge the closest clusters until one hierarchy remains],
    [Divisive (top-down)], [One cluster containing all observations], [Split a current cluster into smaller groups until a stopping rule is reached],
  )]
  , kind: table
  )

Divisive clustering instead recursively splits clusters, sometimes starting from dissimilar seed observations.

#callout("workedexample", title: [Worked example])[For ${ 1 \, 2 \, 4 \, 8 }$, single linkage merges 1 and 2 at distance 1, adds 4 at distance 2, then adds 8 at distance 4:]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/877d5fe357236473.cetz.json")], caption: [The single-linkage dendrogram for ${ 1 \, 2 \, 4 \, 8 }$. Cutting it at a chosen merge distance gives the clusters; the cut shown gives two.]) <fig:dendrogram>

Cut the dendrogram at a chosen height to obtain clusters. The #strong[linkage] rule defines distance between clusters:

- #strong[single linkage] uses the closest pair of observations --- follows chains, finds elongated clusters, sensitive to noise bridges;

- #strong[complete linkage] uses the farthest pair --- compact, similar-diameter clusters;

- #strong[average linkage] uses the average pairwise distance --- a middle ground;

- #strong[Ward linkage] merges whichever pair least increases within-cluster variance --- behaves most like $K$-means and is a common default.

Pairwise distances can be costly for large datasets; standard hierarchical clustering has no built-in new-point assignment.


#heading(level: 2)[DBSCAN: clustering by density]
 <sec:dbscan>

#callout("analogy", title: [Analogy])[Look down at a crowd from a balcony. Groups are wherever people stand close together, and you did not need to decide how many groups to expect in advance. Someone at the edge of a group is still with it. Someone standing alone across the square belongs to nobody. DBSCAN follows the same reasoning.]

DBSCAN defines clusters as regions where points are packed densely, using two hyperparameters: a neighborhood radius $epsilon$ and a minimum count #strong[minPts]. Every point gets one of three roles:

/ Core point: #block[
Has at least minPts points within distance $epsilon$ --- it sits in a dense region.
]

/ Border point: #block[
Is within $epsilon$ of a core point but is not dense enough itself --- the edge of a cluster.
]

/ Noise point: #block[
Neither --- it belongs to no cluster at all.
]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/c02e901276ccb989.cetz.json")], caption: [DBSCAN's three roles. A core point has at least minPts neighbors within $epsilon$; a border point is sparse itself but near a core point; a noise point is neither.]) <fig:dbscan-roles>

#callout("workedexample", title: [Worked example])[Eight points with $epsilon = 1.5$ and minPts $= 4$, counting the point itself:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,left,),
    table.header([Point], [Within 1.5], [Role],),
    table.hline(),
    [$\( 0 \, 0 \)$, $\( 0 \, 1 \)$, $\( 2 \, 1 \)$], [4], [core],
    [$\( 1 \, 0 \)$, $\( 1 \, 1 \)$], [5], [core],
    [$\( 3 \, 2 \)$], [2], [border: sparse itself, but within reach of $\( 2 \, 1 \)$],
    [$\( 1 \, 3.2 \)$], [1], [noise],
    [$\( 6 \, 6 \)$], [1], [noise],
  )]
  , kind: table
  )]

Connected core points form clusters, border points attach, and noise remains unassigned. Density needs no assumption about shape: on two interlocking crescents of 300 points, $K$-means agrees with the true shapes at an adjusted Rand index of only 0.24, while DBSCAN reaches 1.00. It struggles when clusters have very different densities, and in high dimensions. A sorted neighbor-distance plot helps to choose $epsilon$. In Lab~4, $epsilon = 0.75$ finds one cluster with 14 noise points, and $epsilon = 0.5$ finds five clusters with 66 noise points, about one customer in three.


#heading(level: 2)[Which clustering method?]


#figure(
  align(center)[#table(
    columns: 5,
    align: (left,left,left,left,left,),
    table.header([Method], [Needs $K$?], [Cluster shapes], [Outliers], [Notable trait],),
    table.hline(),
    [$K$-means], [yes], [compact, spherical], [distort means], [fast, scalable, simple],
    [GMM], [yes], [elliptical], [distort fits], [soft memberships, density],
    [Hierarchical], [no (cut later)], [depends on linkage], [can distort merges], [full dendrogram of groupings],
    [DBSCAN], [no], [arbitrary], [labeled as noise], [density-based, finds outliers],
  )]
  , kind: table
  )

$K$-means and GMM also assign new observations naturally (nearest center; highest responsibility); hierarchical clustering and DBSCAN have no built-in rule for unseen points, so a small classifier trained on the cluster labels often fills that gap in practice.


#heading(level: 2)[Evaluating a clustering]


When reference labels happen to exist (for validation only), agreement measures such as the #strong[adjusted Rand index] compare the discovered clusters with the labeled groups while correcting for chance.

#callout("keyidea", title: [Key idea])[Treat clusters as hypotheses. Support interpretation with scores, stability, and domain evidence.]

#callout("modelcard", title: [Clustering - Quick Guide])[#block[
ll l

Method & Good for & Main caution \
$K$-means & Compact, roughly spherical clusters; large numeric datasets & Requires $K$, scaling, and sensitivity to initialization/outliers Gaussian mixture & Overlapping elliptical clusters and soft membership & Distribution assumptions and local optima Hierarchical & Dendrograms and nested group structure & Distance/linkage choices and cost on large data DBSCAN & Irregular shapes and explicit noise points & Density parameters and varying-density clusters

]]

#callout("chapterrecap", title: [Chapter recap])[- $K$-means alternates assign and move, and minimizes total squared distance to the landmarks. The groups and their names are two different things: the method finds the first, and you supply the second.

- It is greedy, so starts matter. On the study log, 95 of 120 starts ended in a worse answer. Use restarts.

- Choose $K$ from the bend, the silhouette, stability and usefulness together.

- Hierarchical clustering gives a tree of groupings, DBSCAN follows density and flags noise, and mixtures and fuzzy $C$-means allow partial membership.

- A clustering is a hypothesis. Support it with evidence before acting on it.]

#callout("quickcheck", title: [Check your understanding])[+ What kind of cluster geometry does $K$-means favor, and why can scaling change the resulting partition?

+ $K$-means never saw a label, yet it separated the crammers. How?

+ Starting landmarks are at 2 and 9, and the points are 1, 3, 8, 10. What are the groups, the new landmarks, and the score after one full round?

+ Why can inertia never tell you when to stop adding clusters?

+ What does DBSCAN do with observations that do not belong to a sufficiently dense region?

+ The name "crammers" is in the table above. Where did it come from?]
