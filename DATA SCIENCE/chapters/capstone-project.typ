#import "/.shared/typst/utp.typ": *
#unit("chapters", "capstone-project")

= Capstone: An End-to-End Data-Science Analysis <ch:capstone>

#chapterguide[You should have completed the ten labs and be able to audit, explore, model, validate, and communicate tabular data.][produce a compact, reproducible analysis in which every technical choice is connected to a question and every conclusion is connected to evidence.]

== The capstone is a workflow, not a bigger coding exercise

Choose one bundled dataset or an instructor-approved external dataset. The goal is to demonstrate analytical judgment across the full lifecycle.

#utpfig([A professional analysis keeps a visible line from the original question to the final limitations.], label: <fig:capstone-chain>)[
  #canvas(x: 16.06cm, {
    let stage = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.5978pt, text-width: 0.155 * 16.06, min-height: 1.55, inner-xsep: 1.8mm, inner-ysep: 2mm, align: center, font: font("script", fill: navy))
    let flow = (line-width: 0.797pt, draw: teal, end: arrow-tip("Stealth", length: 2mm, width: 1.5mm, line: 0.797pt))
    node((0, 0), [#strong[Question] \ #v(3.9851pt)
   Define the goal \
  and population], name: "q", ..stage)
    node((0.205, 0), [#strong[Data audit] \ #v(3.9851pt)
   Check quality \
  and provenance], name: "d", ..stage)
    node((0.41, 0), [#strong[EDA] \ #v(3.9851pt)
   Explore patterns \
  and relationships], name: "e", ..stage)
    node((0.615, 0), [#strong[Method] \ #v(3.9851pt)
   Model or infer \
  with justification], name: "m", ..stage)
    node((0.82, 0), [#strong[Validation] \ #v(3.9851pt)
   Assess evidence \
  and state limits], name: "v", ..stage, draw: mix(teal, 80%), fill: pale-teal)
    connect("q.east", "d.west", ..flow)
    connect("d.east", "e.west", ..flow)
    connect("e.east", "m.west", ..flow)
    connect("m.east", "v.west", ..flow)
  })
]

== Build the report around an evidence chain

A capstone becomes easier to follow when every section answers one question. The introduction defines the target population and analytical goal. The data section establishes whether the observations are fit for purpose. EDA develops evidence and candidate explanations. The method section describes how uncertainty or generalisation is quantified. The conclusion states only what the design and validation support.

#utpfig([The figure or table in each stage should answer a specific analytical question rather than exist merely to demonstrate a technique.], label: <fig:capstone-report-architecture>)[
  #canvas({
    let stage = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.5978pt, text-width: 0.68 * 16.06, min-height: 0.9, inner-xsep: 3mm, inner-ysep: 1.5mm, align: center, font: font("script", fill: navy))
    let endpoint = (..stage, draw: mix(teal, 80%), fill: pale-teal)
    let flow = (line-width: 0.797pt, draw: teal, end: arrow-tip("Stealth", length: 1.6mm, width: 1.3mm, line: 0.797pt))
    node((0, 0), [#strong[1\. Question and scope] \ #v(1.9925pt)
   Target population and unit of observation], name: "q", ..endpoint)
    node(below-of("q", 0.24), [#strong[2\. Data audit] \ #v(1.9925pt)
   Data dictionary, quality checks, and exclusions], name: "audit", ..stage)
    node(below-of("audit", 0.24), [#strong[3\. Exploratory analysis] \ #v(1.9925pt)
   3--5 purposeful figures with evidence sentences], name: "eda", ..stage)
    node(below-of("eda", 0.24), [#strong[4\. Method and justification] \ #v(1.9925pt)
   Inference, prediction, or structure discovery], name: "method", ..stage)
    node(below-of("method", 0.24), [#strong[5\. Validation] \ #v(1.9925pt)
   Error analysis and sensitivity checks], name: "val", ..stage)
    node(below-of("val", 0.24), [#strong[6\. Finding and implications] \ #v(1.9925pt)
   Practical meaning, limitations, and next evidence], name: "claim", ..endpoint)
    connect("q.south", "audit.north", ..flow)
    connect("audit.south", "eda.north", ..flow)
    connect("eda.south", "method.north", ..flow)
    connect("method.south", "val.north", ..flow)
    connect("val.south", "claim.north", ..flow)
  })
]

== Required components

#utpsteps[
  + #strong[Problem framing.] State the analytical question, target population, unit of observation, and why the answer would matter.
  + #strong[Data understanding.] Provide a data dictionary for variables used, source/provenance, shape, missingness, and quality constraints.
  + #strong[Preparation.] Show filters, cleaning rules, transformations, and feature engineering with counts of affected records.
  + #strong[EDA.] Include at least three purposeful visualisations and concise evidence sentences.
  + #strong[Method.] Use an appropriate inferential, supervised, or unsupervised method and justify why it matches the question.
  + #strong[Validation.] Use held-out data, cross-validation, uncertainty intervals, or stability checks appropriate to the method.
  + #strong[Communication.] State the main result, practical meaning, limitations, and a next step without overclaiming causality.
]

== Minimum visual standard

Use at least three analytical figures, not including decorative diagrams. A strong submission normally includes one distribution or group-comparison view, one relationship or multivariate view, and one method-specific diagnostic such as a residual plot, confusion matrix, validation-fold chart, cluster view, or PCA projection.

Every figure should have a title or caption that answers: #emph[what should the reader notice, and why does it matter for the question?] Figures with no analytical interpretation do not strengthen the report.

== Suggested capstone directions

#utptable[
  #tabularx(
    columns: (3.2cm, 1fr, 5cm),
    styles: (navy-bold,),
    header: ([Dataset], [Possible question], [Suitable methods]),
    [Iris], [Which measurements separate species and how does unsupervised structure compare?], [EDA, PCA, k-means, classification extension],
    [Wine recognition], [Which chemical measurements are most associated with cultivar or alcohol?], [EDA, inference, regression, multiclass extension],
    [Breast cancer diagnostic], [How do selected measurements separate diagnostic labels?], [EDA, logistic classification, cross-validation],
  )
]

#warning[
  Do not choose a model first and then invent a question that fits it. The capstone is assessed on coherence of the evidence chain, not algorithm complexity.
]

== Recommended checks before submission

#utpsteps[
  + Restart R and run the analysis script from top to bottom using relative paths.
  + Confirm that raw data files are not modified by the script.
  + Compare row counts before and after every major filter or join.
  + Verify that test or validation data do not influence learned preprocessing.
  + Check that every reported number and figure can be reproduced from code.
  + Read every claim and ask whether it is descriptive, predictive, or causal; revise wording that exceeds the design.
  + State at least two limitations that could materially change the conclusion.
]

== Submission structure

Submit one analysis script, one concise report, and any generated figures or derived data required to reproduce the result. The script should run from a clean session with local relative paths. The report should be readable without executing code.

#note[
  A strong capstone makes uncertainty and limitations easy to find. Professional data science is credible because it exposes what could be wrong as clearly as what appears to be true.
]
