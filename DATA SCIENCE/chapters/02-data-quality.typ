#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-data-quality")


#heading(level: 1)[Data Types and Data Quality]
 <ch:quality> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should be able to load a CSV and inspect its rows, columns, and summaries.

*By the end, you can:* classify variable roles; audit missingness, duplicates, validity, and consistency; and document defensible cleaning decisions.]


#heading(level: 2)[Type means more than storage format]
 R reports storage classes such as numeric or character, but analysis also depends on measurement meaning.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Analytical type], [Example], [Appropriate operations],),
    table.hline(),
    [Identifier], [sample ID], [matching, uniqueness checks; not averages],
    [Nominal category], [species, diagnosis], [counts, proportions, group comparisons],
    [Ordinal category], [low / medium / high], [ordered comparisons; spacing is not guaranteed equal],
    [Numeric measurement], [length, radius], [summaries, differences, models],
    [Target / outcome], [malignant or benign], [evaluation against predictions],
  )]
  , kind: table
  )

#callout("pitfall", title: [Analytical pitfall])[A number is not automatically quantitative. Student ID 1042 plus Student ID 1043 does not create a meaningful sum. Analytical meaning determines what operations are valid.]


#heading(level: 2)[Quality is fitness for a specific purpose]
 There is no dataset that is simply "clean" in the abstract. Quality means that the data are sufficiently accurate, complete, consistent, timely, and appropriately sampled for a particular question. A missing measurement may be harmless for one summary and fatal for another model. A duplicated transaction may be legitimate if the unit of analysis is a transaction, but a serious error if the table is supposed to contain one row per customer.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA SCIENCE/figures/diagrams/46e4041f7c9ce993.cetz.json")], caption: [The same table can be adequate for one task and inadequate for another because different questions depend on different fields and assumptions.]) <fig:quality-purpose>


#heading(level: 2)[Four dimensions of a practical data audit]
 #figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA SCIENCE/figures/diagrams/01b8f47935e364b5.cetz.json")], caption: [A quality audit asks whether the data are complete enough, internally valid, consistently represented, and uniquely recorded for the intended analysis.]) <fig:quality-audit>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/quality_missingness_map.svg", width: 90%)], caption: [The deliberately corrupted Iris dataset contains missing and invalid values. A map makes concentration and co-occurrence visible, which a single missing-value count cannot show.]) <fig:quality-map>

Missingness is not just a count. Ask #emph[which variable is missing, for which records, and whether the absence itself could be informative]. A cleaning rule that is harmless for one question can bias another.


#heading(level: 2)[Validity rules come from the domain]
 A positive physical length cannot be negative. A probability must lie between 0 and 1. A date of discharge should not precede admission. These are semantic constraints, not software constraints.

#code-block("invalid <- iris$SepalLengthCm <= 0 |\n           iris$SepalWidthCm <= 0\nsum(invalid, na.rm = TRUE)", lang: "r")


#heading(level: 2)[Missing-data mechanisms change what is defensible]
 The cause of missingness matters. Three common conceptual cases are useful:

- #strong[Missing completely at random (MCAR):] absence is unrelated to measured or unmeasured values. Complete-case analysis may remain unbiased, although less precise.

- #strong[Missing at random (MAR):] absence can be explained by observed variables. Conditional imputation or modelling may be defensible if those predictors are included.

- #strong[Missing not at random (MNAR):] absence depends on the missing value itself or another unobserved factor. Sensitivity analysis and domain knowledge become important because the missingness process cannot be repaired mechanically from observed columns alone.

These labels are assumptions about the data-generating process, not properties that software can determine with certainty from the table.


#heading(level: 2)[Missing data: deletion, imputation, or model explicitly]
 There is no universally correct treatment.

- #strong[Delete] when missingness is small and plausibly unrelated to the outcome, and report how many rows were removed.

- #strong[Impute] when preserving rows is important and a defensible replacement rule exists.

- #strong[Model missingness] or add an indicator when the absence itself may carry information.

Simple median imputation is robust to extreme values but reduces apparent variability. It is suitable as a teaching method, not a reason to ignore why values are missing.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/quality_cleaning_distribution.svg", width: 90%)], caption: [Applying a validity rule can visibly change a distribution. The analyst should compare before and after, count affected rows, and document why the rule is justified.]) <fig:quality-cleaning-change>


#heading(level: 2)[Keys, duplicates, and unit-of-observation errors]
 A duplicate is defined relative to an expected key. Exact duplicated rows are easy to find, but more important problems include duplicated identifiers with conflicting values and repeated observations that are legitimate but accidentally treated as independent entities. Before removing anything, determine the intended key and whether repeated keys are expected.

#code-block("# Are IDs unique when they should be?\nanyDuplicated(iris$Id)\n\n# Which IDs repeat?\niris$Id[duplicated(iris$Id)]", lang: "r")


#heading(level: 2)[Duplicates and inconsistent categories]
 Exact duplicates can inflate counts and train/test performance. Inconsistent labels such as `"Iris-setosa"`, `"iris setosa"`, and `"SETOSA"` represent one concept but appear as three categories until standardised.

#callout("workedexample", title: [Worked example])[A defensible cleaning log records the rule and the evidence: #figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Issue], [Rule], [Evidence retained],),
    table.hline(),
    [Duplicate row], [keep first exact record], [duplicate count before/after],
    [Negative length], [mark impossible value missing], [row identifier and rule],
    [Missing measurement], [median within species], [imputation method and affected count],
    [Label variant], [normalise case/spacing], [original and standard labels],
  )]
  , kind: table
  )]


#heading(level: 2)[Measurement error and label quality]
 Not every bad value is impossible. Measurements can be noisy even when they lie in a plausible range, and labels can be incorrect even when they use a valid category name. This distinction matters because a range check finds impossible values but not subtle measurement error.

For supervised learning, target quality is especially important. If diagnosis labels contain errors, the model is trained to reproduce those errors. Apparent model "mistakes" may sometimes reveal ambiguous or mislabeled examples rather than algorithm failure.


#heading(level: 2)[Leakage: a quality problem for modelling]
 #strong[Data leakage] occurs when information unavailable at prediction time enters model training. Examples include using a final diagnosis to construct an input feature or scaling the entire dataset before the train/test split. Leakage produces optimistic evaluation, even when the code runs correctly.

#callout("keyidea", title: [Key idea])[Cleaning is an analytical decision. A good report states what changed, why it changed, how many records were affected, and what uncertainty the change creates.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA SCIENCE/figures/diagrams/4cc8fded9d138c84.cetz.json")], caption: [A modelling feature is legitimate only if it would be available at the moment a real prediction must be made. Post-outcome information can make validation look excellent while making deployment impossible.]) <fig:leakage-timeline>

#callout("quickcheck", title: [Check your understanding])[+ Why should identifiers usually be excluded from averages and predictive features?

+ What makes a range check different from a missing-value check?

+ Why can median imputation make a distribution look less variable than it really is?

+ Give one example of data leakage.]


#heading(level: 2)[Worked audit: two datasets, two different quality stories]


Quality problems should be described in the language of the data rather than reduced to a single "percent missing" number. The bundled Iris file and Titanic file illustrate two distinct situations.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/quality_iris_audit.svg", width: 90%)], caption: [The Iris file is small enough to inspect manually. It contains a few missing measurements and one inconsistent species label, showing that category consistency and completeness are separate dimensions of quality.]) <fig:quality-iris-audit>

The 153-row Iris file contains three missing `SepalWidthCm` values, two missing `PetalLengthCm` values, and a lower-case/space variant of the setosa label. Converting labels to a canonical form is usually low-risk because the intended semantic equivalence is clear. Imputing a flower measurement is a stronger analytical decision because it invents a value and can change correlations, group means, or downstream classification.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/quality_titanic_missingness.svg", width: 90%)], caption: [About 77% of `Cabin` and 20% of `Age` are missing, whereas most variables are complete. This pattern calls for variable-specific reasoning rather than a blanket "drop missing rows" rule.]) <fig:quality-titanic-missing>

Deleting every row with any missing value would discard most passengers because `Cabin` is frequently absent. A professional audit asks what "missing" means: was a cabin never recorded, not applicable, unreadable in the source, or simply lost during data assembly? The answer determines whether missingness is nuisance, information, or both.

#callout("workedexample", title: [Worked example])[A sensible teaching strategy for `Age` is to preserve the original column and create `Age_imputed`. Group-median imputation by passenger class and sex is transparent and reproducible, but it still shrinks within-group variation. The report should therefore state how many values were imputed and avoid presenting the derived ages as observed facts.]


#heading(level: 2)[Extended audit: structural missingness and duplicate semantics]


The Ames Housing and Red Wine Quality datasets show why a professional data-quality review must go beyond a generic missing-value function. In Ames, some variables are almost entirely missing, but the reason is often structural: a property without a pool has no meaningful pool-quality rating, and a property without an alley cannot have an alley type. Encoding those cases as ordinary numeric or categorical missingness without understanding the data dictionary can erase information.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/quality_ames_missingness.svg", width: 90%)], caption: [The most incomplete fields are largely optional property attributes. A high missing percentage is therefore a prompt to investigate meaning, not an automatic instruction to drop the column.]) <fig:quality-ames-missing>

This distinction is useful in modelling. For a feature such as `Pool QC`, an explicit category such as "No pool" can carry different information from "pool quality was not recorded." The analyst should preserve that distinction whenever the source permits it.

The Red Wine Quality file illustrates a different issue. It contains exact duplicate rows even though no unique wine identifier is supplied.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/quality_wine_duplicates.svg", width: 90%)], caption: [The file has fewer unique rows than supplied rows. That fact alone does not establish an error: two wines can share the same measured chemistry and quality score, or the same record may have been repeated.]) <fig:quality-wine-duplicates>

#callout("keyidea", title: [Key idea])[Never write `distinct()` or `duplicated()` as a cleaning ritual. First state the expected key and the intended unit of observation, then explain why repeated rows are impossible, possible, or informative under that definition.]
