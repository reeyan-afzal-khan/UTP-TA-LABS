#import "/.shared/typst/utp.typ": *
#unit("labs", "10-unsupervised-learning")

#labsection(10, label: <sec:lab10>)[Discover structure with clustering and PCA]

#labproject[Unsupervised learning: discover structure without inventing meaning][
  #strong[Coverage.] Chapter~#ref(<ch:unsupervised>). \

  #strong[Goal.] You should be able to standardise features for distance-based methods, assess cluster stability and choice of $k$, profile clusters in original units, fit PCA without label leakage, and interpret explained variance and loadings. \

  #strong[Datasets.] `mall_customers_dataset.csv` and `wine_recognition_dataset.csv`. \

  #strong[Scenario.] You have two unsupervised tasks: identify potentially useful customer groupings and compress correlated chemical measurements. In both cases, the algorithm returns mathematical structure; interpretation must be earned through diagnostics and domain context.

  #include "visuals/10-flow.typ"

  #strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block.

  ```terminal
  Rscript all_experiments/lab10_unsupervised.R
  ```

  #strong[Step 1.] Load, validate and prepare the data

  #lstinput("/DATA SCIENCE/all_experiments/lab10_unsupervised.R", first: 1, last: 6, lang: "r")

  #strong[Step 2.] Part A: k-means customer segmentation

  #include "visuals/10-trace.typ"

  #lstinput("/DATA SCIENCE/all_experiments/lab10_unsupervised.R", first: 7, last: 12, lang: "r")

  #strong[Step 3.] Compare candidate k values using total within-cluster sum of squares.

  #lstinput("/DATA SCIENCE/all_experiments/lab10_unsupervised.R", first: 13, last: 27, lang: "r")

  #strong[Step 4.] Use k=5 as a teaching solution; students should justify or challenge this choice.

  #lstinput("/DATA SCIENCE/all_experiments/lab10_unsupervised.R", first: 28, last: 41, lang: "r")

  #strong[Step 5.] Stability check across random seeds using label-invariant co-clustering agreement.

  #lstinput("/DATA SCIENCE/all_experiments/lab10_unsupervised.R", first: 42, last: 65, lang: "r")

  #strong[Step 6.] Part B: PCA on chemical measurements; labels are withheld during fitting

  #strong[Use the chapter while coding.] Revisit #link(<ch:unsupervised>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Read variance\_table before interpreting the score plot. Squaring pca\$sdev gives component variances, normalising gives explained, and cumsum gives cumulative. The first index where cumulative reaches .80 is 5 for the supplied file. Thus the two-dimensional plot hides about 44.59% of the standardised variance. Component signs may reverse between implementations without changing these proportions.

  #include "visuals/10-worked-case.typ"

  #lstinput("/DATA SCIENCE/all_experiments/lab10_unsupervised.R", first: 66, last: 97, lang: "r")

  #strong[Step 7.] Labels are introduced only after PCA for post-hoc interpretation.

  #lstinput("/DATA SCIENCE/all_experiments/lab10_unsupervised.R", first: 98, last: 105, lang: "r")

  #strong[Chapter connection.] Revisit #link(<ch:unsupervised>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/10-unsupervised-learning-chapter.typ"

  #verification[
    #strong[Explain and extend your result.] Describe one cluster’s size and feature profile. Compare a two-component projection with the full scaled representation and identify distinctions the plot can hide.

    #strong[Required evidence.] Submit one cluster-selection diagnostic, one cluster profile, one PCA explained-variance summary, and one score plot. For each task, write a two-sentence interpretation that separates the algorithmic result from the substantive meaning you are assigning to it.

    #strong[Professional standard.] Do not name clusters as customer “types” unless the labels are supported by stable feature profiles and a real decision context. Do not describe a principal component as a latent concept unless its loading pattern and domain meaning justify that interpretation.
  ]
]
