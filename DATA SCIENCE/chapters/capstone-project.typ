#import "/.shared/typst/utp.typ": *
#unit("chapters", "capstone-project")


#heading(level: 1)[Capstone: An End-to-End Data-Science Analysis]
 <ch:capstone> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should have completed the ten labs and be able to audit, explore, model, validate, and communicate tabular data.

*By the end, you can:* produce a compact, reproducible analysis in which every technical choice is connected to a question and every conclusion is connected to evidence.]


#heading(level: 2)[The capstone is a workflow, not a bigger coding exercise]
 Choose one bundled dataset or an instructor-approved external dataset. The goal is to demonstrate analytical judgment across the full lifecycle.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA SCIENCE/figures/diagrams/dda0c6473dc2d895.cetz.json")], caption: [A professional analysis keeps a visible line from the original question to the final limitations.]) <fig:capstone-chain>


#heading(level: 2)[Build the report around an evidence chain]
 A capstone becomes easier to follow when every section answers one question. The introduction defines the target population and analytical goal. The data section establishes whether the observations are fit for purpose. EDA develops evidence and candidate explanations. The method section describes how uncertainty or generalisation is quantified. The conclusion states only what the design and validation support.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA SCIENCE/figures/diagrams/a599ee75584c29b8.cetz.json")], caption: [The figure or table in each stage should answer a specific analytical question rather than exist merely to demonstrate a technique.]) <fig:capstone-report-architecture>


#heading(level: 2)[Required components]


+ #strong[Problem framing.] State the analytical question, target population, unit of observation, and why the answer would matter.

+ #strong[Data understanding.] Provide a data dictionary for variables used, source/provenance, shape, missingness, and quality constraints.

+ #strong[Preparation.] Show filters, cleaning rules, transformations, and feature engineering with counts of affected records.

+ #strong[EDA.] Include at least three purposeful visualisations and concise evidence sentences.

+ #strong[Method.] Use an appropriate inferential, supervised, or unsupervised method and justify why it matches the question.

+ #strong[Validation.] Use held-out data, cross-validation, uncertainty intervals, or stability checks appropriate to the method.

+ #strong[Communication.] State the main result, practical meaning, limitations, and a next step without overclaiming causality.


#heading(level: 2)[Minimum visual standard]
 Use at least three analytical figures, not including decorative diagrams. A strong submission normally includes one distribution or group-comparison view, one relationship or multivariate view, and one method-specific diagnostic such as a residual plot, confusion matrix, validation-fold chart, cluster view, or PCA projection.

Every figure should have a title or caption that answers: #emph[what should the reader notice, and why does it matter for the question?] Figures with no analytical interpretation do not strengthen the report.


#heading(level: 2)[Suggested capstone directions]
 #figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Dataset], [Possible question], [Suitable methods],),
    table.hline(),
    [Iris], [Which measurements separate species and how does unsupervised structure compare?], [EDA, PCA, k-means, classification extension],
    [Wine recognition], [Which chemical measurements are most associated with cultivar or alcohol?], [EDA, inference, regression, multiclass extension],
    [Breast cancer diagnostic], [How do selected measurements separate diagnostic labels?], [EDA, logistic classification, cross-validation],
  )]
  , kind: table
  )

#callout("pitfall", title: [Analytical pitfall])[Do not choose a model first and then invent a question that fits it. The capstone is assessed on coherence of the evidence chain, not algorithm complexity.]


#heading(level: 2)[Recommended checks before submission]


+ Restart R and run the analysis script from top to bottom using relative paths.

+ Confirm that raw data files are not modified by the script.

+ Compare row counts before and after every major filter or join.

+ Verify that test or validation data do not influence learned preprocessing.

+ Check that every reported number and figure can be reproduced from code.

+ Read every claim and ask whether it is descriptive, predictive, or causal; revise wording that exceeds the design.

+ State at least two limitations that could materially change the conclusion.


#heading(level: 2)[Submission structure]
 Submit one analysis script, one concise report, and any generated figures or derived data required to reproduce the result. The script should run from a clean session with local relative paths. The report should be readable without executing code.

#callout("keyidea", title: [Key idea])[A strong capstone makes uncertainty and limitations easy to find. Professional data science is credible because it exposes what could be wrong as clearly as what appears to be true.]
