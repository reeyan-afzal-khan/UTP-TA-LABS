#import "/.shared/typst/utp.typ": *

#chapter-star[Course Map]

Data science turns questions and data into evidence that others can inspect, reproduce, and challenge. This course emphasises analytical workflow, with R as a tool. Four stages build on Chapter~@ch:toolkit, which introduces R, RStudio, optional conda management, and the required Git/GitHub SSH workflow; the capstone integrates them. The chapters use varied datasets to build transferable skills rather than familiarity with a single dataset.

#utpfigure[
  #canvas({
    node((0, 0), [#coursemapcard([STAGE 01], [Foundations], [Questions, data quality, and reproducibility])], name: "a", ..card)
    node(right-of("a", 0.66), [#coursemapcard([STAGE 02], [Working with data], [Wrangling, EDA, and visualization])], name: "b", ..card)
    node(right-of("b", 0.66), [#coursemapcard([STAGE 03], [Prediction], [Inference, regression, and classification])], name: "c", ..card)
    node(below-of("c", 0.58), [#coursemapcard([STAGE 04], [Structure], [Clustering and PCA])], name: "d", ..card)
    node(left-of("d", 0.66), [#coursemapcard([STAGE 05], [Capstone], [An end-to-end analysis])], name: "e", ..finalcard)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
    connect("d", "e", ..arr)
  })
]

#utptable[
  #tabularx(
    columns: (8%, 31%, 1fr),
    align: (center, left, left),
    styles: (navy-bold,),
    header: ([Stage], [Focus], [Key question]),
    [1], [Workflow and data quality], [Is the question answerable, and are the data fit for it?],
    [2], [Wrangling, EDA, and visualization], [What patterns do the data show, and how are they communicated?],
    [3], [Inference, prediction, and validation], [How certain is an estimate, and how well does a model generalise?],
    [4], [Clustering and PCA], [What structure exists when there is no label to predict?],
    [5], [Capstone project], [Can the whole workflow be defended end to end?],
  )
]

#heading(depth: 2, numbering: none)[The workflow and the labs]

Every lab follows the same workflow, revisited at increasing depth, and works on a different dataset.

#utpfig([The course revisits the same workflow at increasing depth. Each lab sits immediately after the chapter that supplies its concepts.], label: <fig:course-workflow>)[
  #canvas(x: 16.06cm, {
    let stage = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.6974pt, text-width: 0.155 * 16.06, min-height: 1.65, inner-xsep: 1.8mm, inner-ysep: 2mm, align: center, font: font("script", fill: navy))
    let arr = (line-width: 0.797pt, draw: teal, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.797pt))
    let feedback = (..arr, draw: muted, rounded: 2mm)
    node((0, 0), [#strong[1\. Frame] \ #v(3.9851pt)
   Define the question \
  and scope], name: "q", ..stage)
    node((0.205, 0), [#strong[2\. Prepare] \ #v(3.9851pt)
   Audit quality \
  and organise data], name: "a", ..stage)
    node((0.41, 0), [#strong[3\. Explore] \ #v(3.9851pt)
   Visualise patterns \
  and relationships], name: "e", ..stage)
    node((0.615, 0), [#strong[4\. Model] \ #v(3.9851pt)
   Fit models and \
  assess uncertainty], name: "m", ..stage)
    node((0.82, 0), [#strong[5\. Validate] \ #v(3.9851pt)
   Check results \
  and communicate], name: "v", ..stage, draw: mix(teal, 80%), fill: pale-teal)
    connect("q.east", "a.west", ..arr)
    connect("a.east", "e.west", ..arr)
    connect("e.east", "m.west", ..arr)
    connect("m.east", "v.west", ..arr)
    connect("v.south", (0.82, -1.3), (0, -1.3), "q.south", ..feedback)
    node(along((0.82, -1.3), (0, -1.3), t: 50%), [New evidence refines the question], yshift: -2.9888pt, inner-sep: 0.9963pt, font: font("script", fill: muted), anchor: "north")
  })
]

#utptable[
  #tabularx(
    columns: (4.5%, 23%, 23.5%, 1fr),
    align: (center, left, left, left),
    styles: (navy-bold,),
    header: ([Lab], [Analytical focus], [Dataset(s)], [Key outputs]),
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
  )
]

#keyidea[
  Every practical submission should answer four questions: #emph[What was the question? What data were used? What evidence was produced? What are the limitations?]
]
