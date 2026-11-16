#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-data-science-workflow")

= The Data-Science Workflow <ch:workflow>

#chapterguide[No prior data-science experience is required. Basic familiarity with files and folders is helpful.][distinguish data science from programming; frame answerable questions; inspect a dataset; and structure a reproducible R analysis.]

== Data science starts with a decision or question

A useful analysis begins before code. A data scientist translates a broad concern into a question that can be answered with observable variables.

#utptable[
  #tabularx(
    columns: (15%, 47%, 1fr),
    styles: (navy-bold,),
    header: ([Question type], [Example], [Typical evidence]),
    [Descriptive], [What does the dataset contain?], [counts, distributions, summaries],
    [Comparative], [How do groups differ?], [group summaries, intervals, tests],
    [Relational], [Which variables move together?], [scatterplots, correlation, regression],
    [Predictive], [Can we estimate an unknown outcome?], [holdout predictions and error metrics],
    [Structural], [Are there natural groups or lower-dimensional patterns?], [clusters, principal components],
  )
]

#warning[
  A dataset does not automatically define the question. Starting with “What can I do with these columns?” often creates technically correct but irrelevant analysis. State the question first, then identify the evidence needed to answer it.
]

== From a broad topic to an estimable quantity

Broad topics become data-science problems only after the analyst specifies #emph[who or what is being studied], #emph[what is measured], and #emph[what quantity should be learned]. This quantity is sometimes called an #term[estimand]: the numerical or structural target that connects the question to evidence.

For example, “Are flowers different?” is too vague. “How much does mean petal length differ among the three species represented in this dataset?” identifies the unit of observation, the grouping variable, the outcome, and the comparison. A predictive version would be different again: “How accurately can species be predicted for unseen flowers using the four measurements?”

#utpfig([A strong analysis makes every transition explicit. If a link is vague, later modelling sophistication cannot repair the ambiguity.], label: <fig:question-evidence-ladder>)[
  #canvas({
    let laddercard = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.6974pt, text-width: 0.78 * 16.06, min-height: 1.1, inner-xsep: 9mm, inner-ysep: 2.5mm, align: left, font: font("footnote", fill: navy))
    let badge = (shape: "circle", fill: blue, draw: white, line-width: 0.6974pt, min-size: 0.65, inner-sep: 0pt, font: font("script", weight: "bold", fill: white))
    let flow = (line-width: 0.797pt, draw: teal, end: arrow-tip("Stealth", length: 2mm, width: 1.5mm, line: 0.797pt))
    node((0, 0), [#strong[Context and purpose] \ #v(1.9925pt)
   Identify the decision, scientific concern, or operational need.], name: "context", ..laddercard)
    node(below-of("context", 0.28), [#strong[Answerable question] \ #v(1.9925pt)
   State exactly what should be learned, compared, predicted, or discovered.], name: "question", ..laddercard)
    node(below-of("question", 0.28), [#strong[Unit and population] \ #v(1.9925pt)
   Define what one row represents and where the conclusion should apply.], name: "unit", ..laddercard)
    node(below-of("unit", 0.28), [#strong[Variables and estimand] \ #v(1.9925pt)
   Select the measurements and target quantity that answer the question.], name: "vars", ..laddercard)
    node(below-of("vars", 0.28), [#strong[Method and validation] \ #v(1.9925pt)
   Choose an analysis and specify how uncertainty or error will be checked.], name: "method", ..laddercard)
    node(below-of("method", 0.28), [#strong[Evidence-supported claim] \ #v(1.9925pt)
   Report only what the design supports, with uncertainty and limitations.], name: "claim", ..laddercard, draw: mix(teal, 80%), fill: pale-teal)
    for (target, labelnum) in (("context", 1), ("question", 2), ("unit", 3), ("vars", 4), ("method", 5), ("claim", 6)) {
      node((rel: (0.45, 0), to: target + ".west"), [#labelnum], ..badge)
    }
    connect("context.south", "question.north", ..flow)
    connect("question.south", "unit.north", ..flow)
    connect("unit.south", "vars.north", ..flow)
    connect("vars.south", "method.north", ..flow)
    connect("method.south", "claim.north", ..flow)
  })
]

#note[
  The unit of observation is one of the most important pieces of metadata in a dataset. If a row represents a patient visit rather than a patient, then row counts, train/test splitting, and uncertainty calculations may need to account for repeated observations from the same person.
]

== A practical analytical cycle

#utpfig([A good workflow is iterative rather than a straight line. Quality problems found during exploration can send the analyst back to preparation or even to the original question.], label: <fig:analytical-cycle>)[
  #canvas(x: 16.06cm, {
    let stagecard = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.19 * 16.06, min-height: 1.25, inner-xsep: 4mm, inner-ysep: 2.5mm, align: left, font: font("script", fill: navy))
    let hub = (draw: mix(muted, 65%), fill: pale-gray, rounded: 5mm, line-width: 0.6974pt, text-width: 0.13 * 16.06, min-height: 0.85, inner-xsep: 3mm, inner-ysep: 2mm, align: center, font: font("script", fill: navy))
    let mainflow = (line-width: 0.8966pt, draw: teal, end: arrow-tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8966pt))
    node((0.5, 1.85), [#text(fill: blue)[#strong[01]]#h(1em)#strong[Frame the question] \ #v(3.9851pt)
   Purpose, scope, and intended claim], name: "q", ..stagecard)
    node((0.79, 0.95), [#text(fill: blue)[#strong[02]]#h(1em)#strong[Inspect the data] \ #v(3.9851pt)
   Source, unit, coverage, and constraints], name: "d", ..stagecard)
    node((0.79, -0.95), [#text(fill: mix(orange, 85%, other: black))[#strong[03]]#h(1em)#strong[Prepare and audit] \ #v(3.9851pt)
   Quality checks and feature creation], name: "p", ..stagecard, draw: mix(orange, 80%), fill: pale-orange)
    node((0.5, -1.85), [#text(fill: blue)[#strong[04]]#h(1em)#strong[Explore patterns] \ #v(3.9851pt)
   Relationships, distributions, and anomalies], name: "e", ..stagecard)
    node((0.21, -0.95), [#text(fill: blue)[#strong[05]]#h(1em)#strong[Model and quantify] \ #v(3.9851pt)
   Effects, predictions, and uncertainty], name: "m", ..stagecard)
    node((0.21, 0.95), [#text(fill: teal)[#strong[06]]#h(1em)#strong[Validate and report] \ #v(3.9851pt)
   Errors, limitations, and evidence], name: "c", ..stagecard, draw: mix(teal, 80%), fill: pale-teal)
    node((0.5, 0), [#strong[Iterate] \ #v(2.9888pt)
  #text(fill: muted)[as evidence changes]], ..hub)
    connect("q.east", "d.north-west", out-angle: 0deg, in-angle: 120deg, ..mainflow, name: "curve-1")
    connect("d.south", "p.north", ..mainflow)
    connect("p.south-west", "e.east", out-angle: 240deg, in-angle: 0deg, ..mainflow, name: "curve-2")
    connect("e.west", "m.south-east", out-angle: 180deg, in-angle: 300deg, ..mainflow, name: "curve-3")
    connect("m.north", "c.south", ..mainflow)
    connect("c.north-east", "q.west", out-angle: 60deg, in-angle: 180deg, ..mainflow, name: "curve-4")
  })
]

== The same dataset can support several kinds of analysis

The question determines the role of each column. In the Iris data, `Species` is a grouping variable in a descriptive comparison, but becomes the target in a classification task. The four measurements can be outcomes in one analysis and predictive features in another.

#utpfig([Roles such as feature, target, identifier, and grouping variable are analytical roles, not permanent properties of a column.], label: <fig:variable-roles>)[
  #canvas(x: 16.06cm, {
    let sourcecard = (draw: mix(blue, 75%), fill: pale-blue, rounded: 1.8mm, line-width: 0.7472pt, text-width: 0.46 * 16.06, min-height: 1.2, inner-xsep: 4mm, inner-ysep: 2.5mm, align: center, font: font("footnote", fill: navy))
    let rolecard = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.235 * 16.06, min-height: 2.05, inner-xsep: 3.5mm, inner-ysep: 3mm, align: left, font: font("script", fill: navy))
    let roleflow = (line-width: 0.8468pt, draw: teal, end: arrow-tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8468pt))
    node((0.5, 2.35), [#text(fill: blue)[#strong[SHARED INPUT]] \ #v(2.9888pt)
   #strong[The same Iris dataset] \ #v(2.9888pt)
   Four measurements and a species label], name: "data", ..sourcecard)
    node((0.17, -0.25), [#text(fill: blue)[#strong[DESCRIBE]] \ #v(4.9813pt)
   #strong[Question:] How do species differ? \ #v(3.9851pt)
   #strong[Group:] species \ #v(1.9925pt)
   #strong[Outcome:] petal length], name: "desc", ..rolecard)
    node((0.5, -0.25), [#text(fill: teal)[#strong[PREDICT]] \ #v(4.9813pt)
   #strong[Question:] Which species is this? \ #v(3.9851pt)
   #strong[Target:] species \ #v(1.9925pt)
   #strong[Features:] four measurements], name: "pred", ..rolecard, draw: mix(teal, 80%), fill: pale-teal)
    node((0.83, -0.25), [#text(fill: mix(orange, 85%, other: black))[#strong[DISCOVER STRUCTURE]] \ #v(4.9813pt)
   #strong[Question:] What patterns emerge without labels? \ #v(3.9851pt)
   #strong[Geometry:] measurements \ #v(1.9925pt)
   #strong[Label:] species withheld], name: "struct", ..rolecard, draw: mix(orange, 80%), fill: pale-orange)
    connect("data.south-west", "desc.north", out-angle: 235deg, in-angle: 90deg, ..roleflow, name: "curve-1")
    connect("data.south", "pred.north", ..roleflow)
    connect("data.south-east", "struct.north", out-angle: 305deg, in-angle: 90deg, ..roleflow, name: "curve-2")
  })
]

== Rows, columns, and analytical roles

A rectangular dataset usually stores one #term[observation] per row and one #term[variable] per column. Variables can play different analytical roles: identifiers locate records; features describe them; a target is the outcome to predict; metadata records context such as time or source.

The bundled Iris dataset contains 153 rows, four numeric measurements, one species label, and an identifier. Its small quality issues are useful later because even familiar teaching datasets should be audited rather than assumed perfect. The first inspection should answer shape, names, types, missingness, and basic range questions before any model is fitted.

```r
iris <- read.csv("all_datasets/iris_dataset.csv")
dim(iris)
names(iris)
str(iris)
summary(iris)
```

== Three layers of reproducibility

Reproducibility is easier to reason about when separated into three layers. #strong[Computational reproducibility] asks whether the code reruns. #strong[Analytical reproducibility] asks whether another analyst can understand and repeat the decisions: filters, transformations, metrics, and model settings. #strong[Scientific reproducibility] asks whether a result persists with new data or a new sample from the intended population.

A script that runs but silently drops rows is computationally reproducible yet analytically weak. A well-documented analysis that cannot generalise beyond one convenience sample may be reproducible but still limited scientifically.

#utpfig([A professional workflow records enough information to reproduce both the computation and the reasoning, while recognising that new data provide the strongest test of generalisation.], label: <fig:repro-layers>)[
  #canvas(x: 16.06cm, {
    let layercard = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.235 * 16.06, min-width: 0.285 * 16.06, min-height: 1.85, inner-xsep: 3.5mm, inner-ysep: 3mm, align: left, font: font("footnote", fill: navy))
    let layerflow = (line-width: 0.8966pt, draw: teal, end: arrow-tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8966pt))
    node((0.17, 0), [#text(fill: blue)[#strong[01 COMPUTATIONAL]] \ #v(4.9813pt)
   #strong[Does the code rerun?] \ #v(3.9851pt)
   Same files + software $arrow.r$ same output], name: "comp", ..layercard)
    node((0.5, 0), [#text(fill: teal)[#strong[02 ANALYTICAL]] \ #v(4.9813pt)
   #strong[Can choices be repeated?] \ #v(3.9851pt)
   Same rules + assumptions $arrow.r$ same reasoning], name: "anal", ..layercard, draw: mix(teal, 80%), fill: pale-teal)
    node((0.83, 0), [#text(fill: mix(orange, 85%, other: black))[#strong[03 SCIENTIFIC]] \ #v(4.9813pt)
   #strong[Does it generalise?] \ #v(3.9851pt)
   New data $arrow.r$ similar result?], name: "sci", ..layercard, draw: mix(orange, 80%), fill: pale-orange)
    connect("comp.east", "anal.west", ..layerflow)
    connect("anal.east", "sci.west", ..layerflow)
  })
]

== R essentials used throughout the course

The course assumes only a small R core: assignment with `<-`, functions such as `mean()`, indexing with brackets, data frames, and saved scripts. The important habit is not memorising syntax but reading code as a sequence of data transformations.

#example[
  The question “Which Iris species has the largest average petal length?” maps directly to grouped evidence:

  ```r
  mean_petal <- aggregate(PetalLengthCm ~ Species,
                          data = iris,
                          FUN = mean)
  mean_petal[order(mean_petal$PetalLengthCm,
                   decreasing = TRUE), ]
  ```

  The result is useful because every line supports the stated question.
]

== A minimum analysis record

For every substantial analysis, record the dataset version, unit of observation, question, inclusion rules, transformations, random seed when randomness is used, model or test settings, evaluation procedure, and the final evidence statement. These details form an #term[analysis trail]: a compact explanation of how raw evidence became a conclusion.

A useful habit is to end every script with three comments:

```r
# RESULT: what did the analysis show?
# LIMITATION: what could make this conclusion fail?
# NEXT STEP: what evidence would most reduce uncertainty?
```

These comments force the analyst to move from “the code ran” to “the evidence means something.

#questions[
  + Why is a predictive question different from a descriptive question?
  + What five checks should happen immediately after loading a new table?
  + Why should derived files not overwrite raw data?
  + What makes an analysis reproducible beyond simply saving the final chart?
]

== Worked case: bike demand as a question-to-evidence problem

The bundled daily Bike Sharing data contain 731 days. A broad topic such as “bike usage” becomes useful only after the analyst specifies the quantity of interest. Three different questions lead to three different evidential objects:

#utptable[
  #tabularx(
    columns: (35%, 28%, 1fr),
    styles: (navy-bold,),
    header: ([Question], [Estimand / target], [Evidence]),
    [How variable is daily demand?], [distribution of `cnt`], [median, IQR, histogram/time plot],
    [Does demand differ on working days?], [difference in group means/medians], [grouped summaries with uncertainty],
    [Can weather help predict demand?], [out-of-sample predictive error], [train/test or cross-validated regression],
  )
]

#utpfig([A time plot immediately shows that observations are ordered and that demand changes across seasons and years. Randomly summarising rows without recognising time can hide structure that matters for both inference and validation.], label: <fig:workflow-bike>)[
  #image("/DATA SCIENCE/figures/workflow_bike_daily_pattern.pdf", width: 88%)
]

In this file, mean demand is about 4,504 rentals per day and normalized temperature has a correlation of about 0.63 with total demand. Neither number is a complete answer. Temperature changes with season, demand changes over calendar time, and working-day status changes the mix of casual and registered users. The workflow therefore moves from a first summary to progressively more careful questions rather than treating the first coefficient as the conclusion.

#note[
  The first professional judgment is often not which model to fit, but which comparisons are legitimate given the unit of observation, time ordering, sampling process, and intended claim.
]
