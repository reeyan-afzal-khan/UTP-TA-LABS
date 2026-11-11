#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-unsupervised-learning")


#heading(level: 1)[Unsupervised Learning: Clustering and PCA]
 <ch:unsupervised> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand feature scaling, validation, and supervised targets.

*By the end, you can:* distinguish supervised from unsupervised learning; run k-means clustering; interpret cluster limitations; and use PCA to represent correlated numeric features in fewer dimensions.]


#heading(level: 2)[Unsupervised learning has no target label during fitting]
 Supervised learning asks how features predict a known outcome. Unsupervised learning searches for structure in the feature space itself. Common tasks include clustering, dimensionality reduction, anomaly detection, and representation learning.


#heading(level: 2)[K-means searches for compact groups]
 K-means chooses $k$ cluster centres and assigns each observation to the nearest centre, repeating assignment and centre updates to reduce within-cluster squared distance.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/9a0ddcec2a2873c6.svg")], caption: [K-means alternates between assigning observations and recomputing centres until assignments stabilise or improvement becomes negligible.]) <fig:kmeans-loop>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/unsupervised_kmeans_clusters.svg", width: 90%)], caption: [The algorithm partitions observations according to distance from learned centres. The labels "cluster 1" etc. are arbitrary; only the geometry matters during fitting.]) <fig:unsup-kmeans-example>


#heading(level: 2)[Distance defines what "similar" means]
 K-means uses squared Euclidean distance, so its notion of similarity is geometric and roughly spherical around cluster centres. If meaningful groups differ by density, curved shape, categorical structure, or another distance notion, k-means may be a poor representation even when it returns a numerically stable solution.

Standardisation is therefore not a routine cosmetic step: it changes the geometry on which clusters are defined.


#heading(level: 2)[Scale before distance-based clustering]
 If one feature ranges from 0 to 1000 and another from 0 to 1, Euclidean distance is dominated by the larger scale. Standardisation makes distances reflect standard-deviation units rather than raw measurement magnitude.

#callout("pitfall", title: [Analytical pitfall])[Clusters are not automatically "real" categories. K-means will return $k$ clusters even when the data have no natural grouping. Interpret clusters using stability, separation, domain meaning, and external information when available.]


#heading(level: 2)[Initialisation and stability matter]
 K-means can converge to different local solutions from different starting centres. Using multiple random initialisations and comparing the best within-cluster objective reduces this instability. More importantly, analysts should check whether broad cluster assignments persist across seeds or modest perturbations of the data.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/unsupervised_elbow.svg", width: 90%)], caption: [Within-cluster sum of squares must decrease as more clusters are added. The useful question is whether there is a practically meaningful bend before improvements become small.]) <fig:unsup-elbow>


#heading(level: 2)[Choosing $k$ is a modelling decision]
 Use several forms of evidence: within-cluster sum of squares, silhouette-style separation, stability across random starts or resamples, and domain usefulness. No elbow plot can replace interpretation.


#heading(level: 2)[PCA is a rotation of the numeric feature space]
 After centering the features---and often scaling them when units differ---PCA finds a first direction with maximum variance. The second direction is constrained to be perpendicular to the first and captures the greatest remaining variance, and so on. Because the directions are linear combinations of the original features, PCA is most useful when correlation creates redundancy.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/unsupervised_pca_scores.svg", width: 90%)], caption: [The first two components retain most of the variance and reveal strong separation for setosa plus overlap between the other species. Species labels are shown only for interpretation.]) <fig:unsup-pca-scores>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/unsupervised_explained_variance.svg", width: 90%)], caption: [The bars show variance captured by each component, while the cumulative line shows how quickly information is retained as more components are kept.]) <fig:unsup-pca-variance>


#heading(level: 2)[Principal component analysis compresses correlated features]
 #strong[PCA] creates orthogonal linear combinations of the original numeric variables. The first component captures the greatest possible variance; later components capture remaining orthogonal variance.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([PCA object], [Meaning], [Use],),
    table.hline(),
    [Scores], [coordinates of observations on components], [plotting or modelling],
    [Loadings], [contribution of original features to components], [interpretation],
    [Explained variance], [fraction of variability per component], [decide dimensionality],
  )]
  , kind: table
  )


#heading(level: 2)[Loadings connect components back to original variables]
 A principal-component score is difficult to interpret until the corresponding #strong[loadings] are inspected. Large absolute loadings indicate variables that contribute strongly to that direction; signs indicate which variables move together or oppose one another along the component.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/unsupervised_pca_loadings.svg", width: 90%)], caption: [Arrows show how the four standardised Iris measurements contribute to the first two principal components. Variables pointing in similar directions are positively related in this reduced space.]) <fig:unsup-pca-loadings>

#callout("pitfall", title: [Analytical pitfall])[PCA maximises variance, not predictive usefulness or interpretability. A low-variance direction can still be important for a specific target, and a high-variance component can reflect nuisance variation. Dimensionality reduction must be evaluated against the downstream purpose.]


#heading(level: 2)[Labels can be used after clustering for interpretation]
 In the Iris lab, species labels are excluded from k-means fitting. After the clusters are created, comparing cluster assignment with species can help interpret discovered structure. This is evaluation after fitting, not supervision during fitting.

#callout("keyidea", title: [Key idea])[Unsupervised methods discover mathematical structure. Human judgment is still required to decide whether that structure is stable, meaningful, actionable, or merely an artefact of scaling and algorithm choices.]

#callout("quickcheck", title: [Check your understanding])[+ What information is missing in unsupervised learning compared with supervised learning?

+ Why should numeric features often be standardised before k-means?

+ Why does requesting three clusters not prove that three natural groups exist?

+ What is the difference between PCA scores and loadings?]


#heading(level: 2)[Beyond Iris: customer segmentation and chemical profiles]


Different unsupervised methods answer different structural questions. Mall Customers asks whether observations form useful geometric segments; Wine Recognition asks whether many correlated chemical measurements can be represented in fewer dimensions.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/unsupervised_mall_clusters.svg", width: 90%)], caption: [K-means partitions customers in income--spending space around learned centres. The five colours are algorithmic clusters, not pre-existing customer categories.]) <fig:unsup-mall>

The Mall Customers file has only 200 rows, but it is pedagogically useful because cluster meaning can be inspected in original units. Adding age changes the geometry even when the displayed plot uses only income and spending score; this reminds students that a two-dimensional visualisation can omit variables used by the algorithm.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/unsupervised_wine_pca.svg", width: 90%)], caption: [The cultivar labels are shown only after PCA has been fitted. Separation in score space helps interpret whether the unsupervised representation captures known chemical structure.]) <fig:unsup-wine>

PCA is particularly appropriate here because the numeric variables are measured on different scales and many describe related chemical properties. Standardisation prevents variables with large raw units, such as proline or magnesium, from dominating simply because of their measurement scale.
