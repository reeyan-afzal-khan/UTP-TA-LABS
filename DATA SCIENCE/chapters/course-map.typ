#import "/.shared/typst/utp.typ": *


#heading(level: 1, numbering: none)[Course Map]


Data science turns questions and data into evidence that others can inspect, reproduce, and challenge. This course emphasises analytical workflow, with R as a tool. Four stages build on Chapter~#ref(label("ch:toolkit"), supplement: none), which introduces R, RStudio, optional conda management, and the required Git/GitHub SSH workflow; the capstone integrates them. The chapters use varied datasets to build transferable skills rather than familiarity with a single dataset.

#callout("utpfigure", title: [])[#diagram-image("/DATA SCIENCE/figures/diagrams/5a922943c594e544.svg")]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Focus], [Key question],),
    table.hline(),
    [1], [Workflow and data quality], [Is the question answerable, and are the data fit for it?],
    [2], [Wrangling, EDA, and visualization], [What patterns do the data show, and how are they communicated?],
    [3], [Inference, prediction, and validation], [How certain is an estimate, and how well does a model generalise?],
    [4], [Clustering and PCA], [What structure exists when there is no label to predict?],
    [5], [Capstone project], [Can the whole workflow be defended end to end?],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[The workflow and the labs]
 Every lab follows the same workflow, revisited at increasing depth, and works on a different dataset.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/f6716af1401165d9.svg")], caption: [The course revisits the same workflow at increasing depth. Each lab sits immediately after the chapter that supplies its concepts.]) <fig:course-workflow>

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Lab], [Analytical focus], [Dataset(s)], [Key outputs],),
    table.hline(),
    [1], [Workflow and reproducibility], [Bike Sharing (daily)], [Data profile, analytical question, and time-aware summaries],
    [2], [Data quality], [Iris and Titanic], [Missingness audit, category checks, and cleaning decisions],
    [3], [Wrangling and features], [Bike Sharing (hourly)], [Parsed dates, derived features, and temporal summaries],
    [4], [Exploratory analysis], [Medical Costs], [Distributions, outliers, subgroup comparisons, and relationships],
    [5], [Visual communication], [Red Wine Quality], [Purposeful graphics with evidence-based interpretations],
    [6], [Sampling and inference], [Student Performance], [Bootstrap interval, group comparison, effect size, and limitations],
    [7], [Regression], [Ames Housing], [Held-out MAE and RMSE, with residual diagnostics],
    [8], [Classification], [Heart Failure], [Predicted probabilities, confusion matrix, sensitivity, specificity, and precision],
    [9], [Validation and preprocessing], [Credit-card Fraud], [Stratified cross-validation and threshold trade-offs],
    [10], [Unsupervised learning], [Mall Customers and Wine Recognition], [Standardised k-means segments and PCA representation],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Every practical submission should answer four questions: #emph[What was the question? What data were used? What evidence was produced? What are the limitations?]]
