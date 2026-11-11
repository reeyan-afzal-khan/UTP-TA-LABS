#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-data-wrangling")


#heading(level: 1)[Data Wrangling and Feature Construction]
 <ch:wrangling> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand observations, variables, data types, and data-quality checks.

*By the end, you can:* select and filter records, sort data, compute grouped summaries, and create features that preserve clear meaning.]


#heading(level: 2)[Wrangling changes representation, not the question]
 Data wrangling prepares the evidence needed for analysis. Common operations are selecting variables, filtering observations, ordering records, grouping categories, aggregating summaries, joining tables, and constructing derived features.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/3541c936f524b7be.svg")], caption: [Each operation should be explainable as a transformation from one table to another.]) <fig:wrangling-pipeline>


#heading(level: 2)[Think in verbs: each step should have one purpose]
 A readable wrangling pipeline is a sequence of simple verbs: #emph[select], #emph[filter], #emph[mutate], #emph[group], #emph[summarise], #emph[join], and #emph[reshape]. Keeping transformations small makes intermediate row counts and assumptions easier to audit.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/6f64ca9463618ca0.svg")], caption: [Each transformation should preserve a clear contract: what one row represents, which variables are retained, and which new values were derived.]) <fig:wrangle-contract>


#heading(level: 2)[Select only what the question needs]
 If the question concerns alcohol, colour intensity, and cultivar, carrying every available variable into every step increases cognitive load and opportunities for mistakes.

#code-block("analysis <- wine[, c(\"cultivar\", \"alcohol\",\n                     \"color_intensity\", \"proline\")]", lang: "r")


#heading(level: 2)[Filter records with explicit conditions]
 Filtering defines the population being analysed. That means every filter should be stated in the report.

#code-block("high_alcohol <- wine[wine$alcohol >= 13.5, ]", lang: "r")

#callout("pitfall", title: [Analytical pitfall])[Filtering after looking at the outcome can quietly turn exploration into cherry-picking. Define inclusion rules from the analytical question or domain constraints, and disclose post-hoc filters.]


#heading(level: 2)[Aggregation changes the unit of observation]
 When rows are grouped and summarised, the output table no longer represents individual observations. One row may now represent a cultivar, region, month, or customer. This is a fundamental change in the analytical unit and should be made explicit.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/wrangling_group_summary.svg", width: 90%)], caption: [The cultivar means differ, while the dashed line shows the overall mean. Error bars are approximate 95% intervals for each group mean and remind us that summaries are estimates.]) <fig:wrangle-group-summary>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/wrangling_transform.svg", width: 90%)], caption: [The log transformation compresses large values more strongly than small values. It can make skewed data easier to visualise or model, but it also changes coefficient interpretation.]) <fig:wrangle-transform>

#callout("keyidea", title: [Key idea])[Always ask whether a grouped result is weighted correctly for the question. Averaging three group means is not generally the same as the overall mean when group sizes differ.]


#heading(level: 2)[Grouped summaries reveal structured differences]
 Overall averages can hide subgroup structure. The `aggregate()` function makes the comparison explicit: #code-block("aggregate(alcohol ~ cultivar, data = wine, FUN = mean)", lang: "r") A group summary should usually include both a center and a measure of spread or sample size.


#heading(level: 2)[Reshaping: wide and long representations]
 The same information can be represented in different table shapes. #strong[Wide] data often place repeated measures in separate columns, while #strong[long] data place the measurement name and value in rows. Long form is often convenient for grouped plotting and repeated-measures analysis; wide form can be convenient for modelling matrices.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/e9a5d6e829adac59.svg")], caption: [Reshaping should change layout, not invent or discard measurements. The key columns must be sufficient to reconstruct the original representation.]) <fig:wide-long>


#heading(level: 2)[Feature engineering should add meaning]
 A #strong[feature] is an input variable used in analysis or modelling. New features can simplify relationships, encode domain knowledge, or make scales easier to compare.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Feature operation], [Example], [Reason],),
    table.hline(),
    [Binning], [alcohol to lower/middle/higher], [communicate broad ranges],
    [Transformation], [$log \( 1 + x \)$], [compress strongly right-skewed values],
    [Ratio], [cost per unit], [represent relative rather than absolute size],
    [Interaction], [age $times$ treatment], [allow one effect to vary with another],
    [Indicator], [missing = yes/no], [preserve missingness as information],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[A good engineered feature has a sentence-level interpretation. If you cannot explain what the feature means without referring to the code that produced it, it is hard to defend analytically.]


#heading(level: 2)[Join cardinality should be known before the join]
 A join combines rows according to key matches. The expected relationship between keys is called #strong[cardinality]. One-to-one joins should preserve row count; one-to-many joins deliberately repeat the "one" side; many-to-many joins can create a Cartesian multiplication and are frequently accidental.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/ce9e533041ef9e20.svg")], caption: [Knowing the expected key relationship lets row-count changes become a diagnostic rather than a surprise.]) <fig:join-cardinality>


#heading(level: 2)[Joining tables introduces a new failure mode]
 When combining tables, the join key should be unique at the expected level. A many-to-many join can multiply rows and corrupt counts.

#callout("workedexample", title: [Worked example])[Before joining customer and transaction tables, verify whether customer ID is unique in the customer table and repeated in the transaction table. That expected one-to-many relationship is part of the data model, not an implementation detail.]

#callout("quickcheck", title: [Check your understanding])[+ Why can an overall mean be misleading when groups differ strongly?

+ What should be stated whenever rows are filtered out?

+ Give one reason to log-transform a feature.

+ What join problem can cause row counts to increase unexpectedly?]


#heading(level: 2)[Worked case: from 17,379 hourly rows to an interpretable demand profile]


The hourly Bike Sharing file demonstrates why wrangling is analytical work rather than clerical preparation. One row represents one observed hour. The goal is not to make the table smaller for its own sake, but to create a representation matched to a question such as "How does the daily demand pattern differ between working and non-working days?"

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/wrangling_bike_hourly_profiles.svg", width: 90%)], caption: [A grouped hourly summary reveals commuting peaks on working days and a broader daytime pattern on non-working days. The transformation changes the grain from individual observed hours to mean demand for each hour--day-type combination.]) <fig:wrangle-bike-hours>

A useful feature engineering detail is that clock hour is cyclical. In ordinary numeric distance, hours 23 and 0 appear 23 units apart even though they are adjacent on the clock. A common encoding maps hour to the unit circle: $ h_sin = sin \( 2 pi h \/ 24 \) \, #h(2em) h_cos = cos \( 2 pi h \/ 24 \) . $ This representation preserves neighbourhood around midnight and gives models two smooth numeric variables instead of an arbitrary linear scale.

#callout("keyidea", title: [Key idea])[Every aggregation changes the unit of analysis. Before and after a `group`/`summarise` operation, state what one row represents. Many subtle data errors are actually grain errors.]
