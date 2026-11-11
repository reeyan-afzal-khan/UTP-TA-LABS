#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-data-science-workflow")


#heading(level: 1)[The Data-Science Workflow]
 <ch:workflow> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* No prior data-science experience is required. Basic familiarity with files and folders is helpful.

*By the end, you can:* distinguish data science from programming; frame answerable questions; inspect a dataset; and structure a reproducible R analysis.]


#heading(level: 2)[Data science starts with a decision or question]
 A useful analysis begins before code. A data scientist translates a broad concern into a question that can be answered with observable variables.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Question type], [Example], [Typical evidence],),
    table.hline(),
    [Descriptive], [What does the dataset contain?], [counts, distributions, summaries],
    [Comparative], [How do groups differ?], [group summaries, intervals, tests],
    [Relational], [Which variables move together?], [scatterplots, correlation, regression],
    [Predictive], [Can we estimate an unknown outcome?], [holdout predictions and error metrics],
    [Structural], [Are there natural groups or lower-dimensional patterns?], [clusters, principal components],
  )]
  , kind: table
  )

#callout("pitfall", title: [Analytical pitfall])[A dataset does not automatically define the question. Starting with "What can I do with these columns?" often creates technically correct but irrelevant analysis. State the question first, then identify the evidence needed to answer it.]


#heading(level: 2)[From a broad topic to an estimable quantity]
 Broad topics become data-science problems only after the analyst specifies #emph[who or what is being studied], #emph[what is measured], and #emph[what quantity should be learned]. This quantity is sometimes called an #strong[estimand]: the numerical or structural target that connects the question to evidence.

For example, "Are flowers different?" is too vague. "How much does mean petal length differ among the three species represented in this dataset?" identifies the unit of observation, the grouping variable, the outcome, and the comparison. A predictive version would be different again: "How accurately can species be predicted for unseen flowers using the four measurements?"

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/7417abf3541b5549.svg")], caption: [A strong analysis makes every transition explicit. If a link is vague, later modelling sophistication cannot repair the ambiguity.]) <fig:question-evidence-ladder>

#callout("keyidea", title: [Key idea])[The unit of observation is one of the most important pieces of metadata in a dataset. If a row represents a patient visit rather than a patient, then row counts, train/test splitting, and uncertainty calculations may need to account for repeated observations from the same person.]


#heading(level: 2)[A practical analytical cycle]
 #figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/7d880ee2718f99e7.svg")], caption: [A good workflow is iterative rather than a straight line. Quality problems found during exploration can send the analyst back to preparation or even to the original question.]) <fig:analytical-cycle>


#heading(level: 2)[The same dataset can support several kinds of analysis]
 The question determines the role of each column. In the Iris data, `Species` is a grouping variable in a descriptive comparison, but becomes the target in a classification task. The four measurements can be outcomes in one analysis and predictive features in another.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/a91435f0337e95f0.svg")], caption: [Roles such as feature, target, identifier, and grouping variable are analytical roles, not permanent properties of a column.]) <fig:variable-roles>


#heading(level: 2)[Rows, columns, and analytical roles]
 A rectangular dataset usually stores one #strong[observation] per row and one #strong[variable] per column. Variables can play different analytical roles: identifiers locate records; features describe them; a target is the outcome to predict; metadata records context such as time or source.

The bundled Iris dataset contains 153 rows, four numeric measurements, one species label, and an identifier. Its small quality issues are useful later because even familiar teaching datasets should be audited rather than assumed perfect. The first inspection should answer shape, names, types, missingness, and basic range questions before any model is fitted.

#code-block("iris <- read.csv(\"all_datasets/iris_dataset.csv\")\ndim(iris)\nnames(iris)\nstr(iris)\nsummary(iris)", lang: "r")


#heading(level: 2)[Three layers of reproducibility]
 Reproducibility is easier to reason about when separated into three layers. #strong[Computational reproducibility] asks whether the code reruns. #strong[Analytical reproducibility] asks whether another analyst can understand and repeat the decisions: filters, transformations, metrics, and model settings. #strong[Scientific reproducibility] asks whether a result persists with new data or a new sample from the intended population.

A script that runs but silently drops rows is computationally reproducible yet analytically weak. A well-documented analysis that cannot generalise beyond one convenience sample may be reproducible but still limited scientifically.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/52a7a0e507f66b5f.svg")], caption: [A professional workflow records enough information to reproduce both the computation and the reasoning, while recognising that new data provide the strongest test of generalisation.]) <fig:repro-layers>


#heading(level: 2)[R essentials used throughout the course]
 The course assumes only a small R core: assignment with `<-`, functions such as `mean()`, indexing with brackets, data frames, and saved scripts. The important habit is not memorising syntax but reading code as a sequence of data transformations.

#callout("workedexample", title: [Worked example])[The question "Which Iris species has the largest average petal length?" maps directly to grouped evidence: #code-block("mean_petal <- aggregate(PetalLengthCm ~ Species,\n                        data = iris,\n                        FUN = mean)\nmean_petal[order(mean_petal$PetalLengthCm,\n                 decreasing = TRUE), ]", lang: "r") The result is useful because every line supports the stated question.]


#heading(level: 2)[A minimum analysis record]
 For every substantial analysis, record the dataset version, unit of observation, question, inclusion rules, transformations, random seed when randomness is used, model or test settings, evaluation procedure, and the final evidence statement. These details form an #strong[analysis trail]: a compact explanation of how raw evidence became a conclusion.

A useful habit is to end every script with three comments: #code-block("# RESULT: what did the analysis show?\n# LIMITATION: what could make this conclusion fail?\n# NEXT STEP: what evidence would most reduce uncertainty?", lang: "r") These comments force the analyst to move from "the code ran" to “the evidence means something.

#callout("quickcheck", title: [Check your understanding])[+ Why is a predictive question different from a descriptive question?

+ What five checks should happen immediately after loading a new table?

+ Why should derived files not overwrite raw data?

+ What makes an analysis reproducible beyond simply saving the final chart?]


#heading(level: 2)[Worked case: bike demand as a question-to-evidence problem]


The bundled daily Bike Sharing data contain 731 days. A broad topic such as "bike usage" becomes useful only after the analyst specifies the quantity of interest. Three different questions lead to three different evidential objects:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Question], [Estimand / target], [Evidence],),
    table.hline(),
    [How variable is daily demand?], [distribution of `cnt`], [median, IQR, histogram/time plot],
    [Does demand differ on working days?], [difference in group means/medians], [grouped summaries with uncertainty],
    [Can weather help predict demand?], [out-of-sample predictive error], [train/test or cross-validated regression],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/workflow_bike_daily_pattern.svg", width: 90%)], caption: [A time plot immediately shows that observations are ordered and that demand changes across seasons and years. Randomly summarising rows without recognising time can hide structure that matters for both inference and validation.]) <fig:workflow-bike>

In this file, mean demand is about 4,504 rentals per day and normalized temperature has a correlation of about 0.63 with total demand. Neither number is a complete answer. Temperature changes with season, demand changes over calendar time, and working-day status changes the mix of casual and registered users. The workflow therefore moves from a first summary to progressively more careful questions rather than treating the first coefficient as the conclusion.

#callout("keyidea", title: [Key idea])[The first professional judgment is often not which model to fit, but which comparisons are legitimate given the unit of observation, time ordering, sampling process, and intended claim.]
