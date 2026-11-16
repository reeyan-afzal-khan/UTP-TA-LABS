#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-data-quality")

= Data Types and Data Quality <ch:quality>

#chapterguide[You should be able to load a CSV and inspect its rows, columns, and summaries.][classify variable roles; audit missingness, duplicates, validity, and consistency; and document defensible cleaning decisions.]

== Type means more than storage format

R reports storage classes such as numeric or character, but analysis also depends on measurement meaning.

#utptable[
  #tabularx(
    columns: (2.7cm, 4.1cm, 1fr),
    styles: (navy-bold,),
    header: ([Analytical type], [Example], [Appropriate operations]),
    [Identifier], [sample ID], [matching, uniqueness checks; not averages],
    [Nominal category], [species, diagnosis], [counts, proportions, group comparisons],
    [Ordinal category], [low / medium / high], [ordered comparisons; spacing is not guaranteed equal],
    [Numeric measurement], [length, radius], [summaries, differences, models],
    [Target / outcome], [malignant or benign], [evaluation against predictions],
  )
]

#warning[
  A number is not automatically quantitative. Student ID 1042 plus Student ID 1043 does not create a meaningful sum. Analytical meaning determines what operations are valid.
]

== Quality is fitness for a specific purpose

There is no dataset that is simply “clean” in the abstract. Quality means that the data are sufficiently accurate, complete, consistent, timely, and appropriately sampled for a particular question. A missing measurement may be harmless for one summary and fatal for another model. A duplicated transaction may be legitimate if the unit of analysis is a transaction, but a serious error if the table is supposed to contain one row per customer.

#utpfig([The same table can be adequate for one task and inadequate for another because different questions depend on different fields and assumptions.], label: <fig:quality-purpose>)[
  #canvas(x: 16.06cm, {
    let sourcecard = (draw: mix(blue, 75%), fill: pale-blue, rounded: 1.8mm, line-width: 0.7472pt, text-width: 0.15 * 16.06, min-width: 0.19 * 16.06, min-height: 1.15, inner-xsep: 3mm, inner-ysep: 2.5mm, align: center, font: font("script", fill: navy))
    let taskcard = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.21 * 16.06, min-width: 0.255 * 16.06, min-height: 1.05, inner-xsep: 3.5mm, inner-ysep: 2mm, align: left, font: font("script", fill: navy))
    let qualityflow = (line-width: 0.8468pt, draw: teal, end: arrow-tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8468pt))
    node((0.12, 0), [#text(fill: blue)[#strong[SHARED INPUT]] \ #v(2.9888pt)
   The same dataset], name: "data", ..sourcecard)
    node((0.43, 0.8), [#text(fill: blue)[#strong[QUESTION A]] \ #v(2.9888pt)
   Requires a complete target.], name: "q1", ..taskcard)
    node((0.43, -0.8), [#text(fill: blue)[#strong[QUESTION B]] \ #v(2.9888pt)
   Requires reliable dates.], name: "q2", ..taskcard)
    node((0.78, 0.8), [#text(fill: teal)[#strong[QUALITY CHECK]] \ #v(2.9888pt)
   Is the target complete and reliable?], name: "a1", ..taskcard, draw: mix(teal, 80%), fill: pale-teal)
    node((0.78, -0.8), [#text(fill: teal)[#strong[QUALITY CHECK]] \ #v(2.9888pt)
   Are the dates complete and valid?], name: "a2", ..taskcard, draw: mix(teal, 80%), fill: pale-teal)
    coordinate("split", (0.275, 0))
    connect("data.east", "split", draw: teal, line-width: 0.8468pt)
    connect("split", "|-", "q1.west", ..qualityflow)
    connect("split", "|-", "q2.west", ..qualityflow)
    connect("q1.east", "a1.west", ..qualityflow)
    connect("q2.east", "a2.west", ..qualityflow)
    circle-at("split", 1.2951pt, fill: teal, draw: none)
  })
]

== Four dimensions of a practical data audit

#utpfig([A quality audit asks whether the data are complete enough, internally valid, consistently represented, and uniquely recorded for the intended analysis.], label: <fig:quality-audit>)[
  #canvas(x: 16.06cm, {
    let auditroot = (draw: mix(teal, 80%), fill: pale-teal, rounded: 5mm, line-width: 0.7472pt, text-width: 0.17 * 16.06, min-height: 0.9, inner-xsep: 3mm, inner-ysep: 2mm, align: center, font: font("script", fill: navy))
    let auditcard = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.235 * 16.06, min-width: 0.29 * 16.06, min-height: 1.15, inner-xsep: 4mm, inner-ysep: 2.5mm, align: left, font: font("footnote", fill: navy))
    let auditflow = (line-width: 0.797pt, draw: teal, end: arrow-tip("Stealth", length: 2mm, width: 1.5mm, line: 0.797pt))
    node((0.5, 0), [#strong[QUALITY AUDIT] \ #v(2.9888pt)
   #text(fill: muted)[fit for purpose]], name: "audit", ..auditroot)
    node((0.2, 1), [#text(fill: blue)[#strong[01 COMPLETENESS]] \ #v(3.9851pt)
   Missing values], name: "c", ..auditcard)
    node((0.8, 1), [#text(fill: blue)[#strong[02 VALIDITY]] \ #v(3.9851pt)
   Plausible ranges], name: "v", ..auditcard)
    node((0.2, -1), [#text(fill: blue)[#strong[03 CONSISTENCY]] \ #v(3.9851pt)
   Labels and units], name: "s", ..auditcard)
    node((0.8, -1), [#text(fill: blue)[#strong[04 UNIQUENESS]] \ #v(3.9851pt)
   Duplicate records], name: "u", ..auditcard)
    connect("audit.west", "c.east", out-angle: 160deg, in-angle: 0deg, ..auditflow, name: "curve-1")
    connect("audit.east", "v.west", out-angle: 20deg, in-angle: 180deg, ..auditflow, name: "curve-2")
    connect("audit.west", "s.east", out-angle: 200deg, in-angle: 0deg, ..auditflow, name: "curve-3")
    connect("audit.east", "u.west", out-angle: -20deg, in-angle: 180deg, ..auditflow, name: "curve-4")
  })
]

#utpfig([The deliberately corrupted Iris dataset contains missing and invalid values. A map makes concentration and co-occurrence visible, which a single missing-value count cannot show.], label: <fig:quality-map>)[
  #image("/DATA SCIENCE/figures/quality_missingness_map.pdf", width: 93%)
]

Missingness is not just a count. Ask #emph[which variable is missing, for which records, and whether the absence itself could be informative]. A cleaning rule that is harmless for one question can bias another.

== Validity rules come from the domain

A positive physical length cannot be negative. A probability must lie between 0 and 1. A date of discharge should not precede admission. These are semantic constraints, not software constraints.

```r
invalid <- iris$SepalLengthCm <= 0 |
           iris$SepalWidthCm <= 0
sum(invalid, na.rm = TRUE)
```

== Missing-data mechanisms change what is defensible

The cause of missingness matters. Three common conceptual cases are useful:

- #strong[Missing completely at random (MCAR):] absence is unrelated to measured or unmeasured values. Complete-case analysis may remain unbiased, although less precise.
- #strong[Missing at random (MAR):] absence can be explained by observed variables. Conditional imputation or modelling may be defensible if those predictors are included.
- #strong[Missing not at random (MNAR):] absence depends on the missing value itself or another unobserved factor. Sensitivity analysis and domain knowledge become important because the missingness process cannot be repaired mechanically from observed columns alone.

These labels are assumptions about the data-generating process, not properties that software can determine with certainty from the table.

== Missing data: deletion, imputation, or model explicitly

There is no universally correct treatment.

- #strong[Delete] when missingness is small and plausibly unrelated to the outcome, and report how many rows were removed.
- #strong[Impute] when preserving rows is important and a defensible replacement rule exists.
- #strong[Model missingness] or add an indicator when the absence itself may carry information.

Simple median imputation is robust to extreme values but reduces apparent variability. It is suitable as a teaching method, not a reason to ignore why values are missing.

#utpfig([Applying a validity rule can visibly change a distribution. The analyst should compare before and after, count affected rows, and document why the rule is justified.], label: <fig:quality-cleaning-change>)[
  #image("/DATA SCIENCE/figures/quality_cleaning_distribution.pdf", width: 82%)
]

== Keys, duplicates, and unit-of-observation errors

A duplicate is defined relative to an expected key. Exact duplicated rows are easy to find, but more important problems include duplicated identifiers with conflicting values and repeated observations that are legitimate but accidentally treated as independent entities. Before removing anything, determine the intended key and whether repeated keys are expected.

```r
# Are IDs unique when they should be?
anyDuplicated(iris$Id)

# Which IDs repeat?
iris$Id[duplicated(iris$Id)]
```

== Duplicates and inconsistent categories

Exact duplicates can inflate counts and train/test performance. Inconsistent labels such as `"Iris-setosa"`, `"iris setosa"`, and `"SETOSA"` represent one concept but appear as three categories until standardised.

#example[
  A defensible cleaning log records the rule and the evidence:

  #utptable[
    #tabularx(
      columns: (3.2cm, 4.5cm, 1fr),
      styles: (navy-bold,),
      header: ([Issue], [Rule], [Evidence retained]),
      [Duplicate row], [keep first exact record], [duplicate count before/after],
      [Negative length], [mark impossible value missing], [row identifier and rule],
      [Missing measurement], [median within species], [imputation method and affected count],
      [Label variant], [normalise case/spacing], [original and standard labels],
    )
  ]
]

== Measurement error and label quality

Not every bad value is impossible. Measurements can be noisy even when they lie in a plausible range, and labels can be incorrect even when they use a valid category name. This distinction matters because a range check finds impossible values but not subtle measurement error.

For supervised learning, target quality is especially important. If diagnosis labels contain errors, the model is trained to reproduce those errors. Apparent model “mistakes” may sometimes reveal ambiguous or mislabeled examples rather than algorithm failure.

== Leakage: a quality problem for modelling

#term[Data leakage] occurs when information unavailable at prediction time enters model training. Examples include using a final diagnosis to construct an input feature or scaling the entire dataset before the train/test split. Leakage produces optimistic evaluation, even when the code runs correctly.

#note[
  Cleaning is an analytical decision. A good report states what changed, why it changed, how many records were affected, and what uncertainty the change creates.
]

#utpfig([A modelling feature is legitimate only if it would be available at the moment a real prediction must be made. Post-outcome information can make validation look excellent while making deployment impossible.], label: <fig:leakage-timeline>)[
  #canvas({
    connect((-5, 0), (5, 0), line-width: widths.thick, draw: muted, end: arrow-tip("Stealth", length: 2.5mm, line: widths.thick))
    node((-4.1, 0.6), [information available], ..tagb)
    node((0, 0.65), [prediction time], ..tagb)
    node((4, 0.6), [outcome known], ..tagb)
    connect((0, -0.28), (0, 0.28), line-width: widths.thick, draw: teal)
    node((-2.8, -1), [valid features \
  measurements before decision], ..fcbox, text-width: 3)
    node((2.8, -1), [leaky features \
  treatment or information created after outcome], ..cellbad, min-width: 4, min-height: 1.15, align: center)
  })
]

#questions[
  + Why should identifiers usually be excluded from averages and predictive features?
  + What makes a range check different from a missing-value check?
  + Why can median imputation make a distribution look less variable than it really is?
  + Give one example of data leakage.
]

== Worked audit: two datasets, two different quality stories

Quality problems should be described in the language of the data rather than reduced to a single “percent missing” number. The bundled Iris file and Titanic file illustrate two distinct situations.

#utpfig([The Iris file is small enough to inspect manually. It contains a few missing measurements and one inconsistent species label, showing that category consistency and completeness are separate dimensions of quality.], label: <fig:quality-iris-audit>)[
  #image("/DATA SCIENCE/figures/quality_iris_audit.pdf", width: 88%)
]

The 153-row Iris file contains three missing `SepalWidthCm` values, two missing `PetalLengthCm` values, and a lower-case/space variant of the setosa label. Converting labels to a canonical form is usually low-risk because the intended semantic equivalence is clear. Imputing a flower measurement is a stronger analytical decision because it invents a value and can change correlations, group means, or downstream classification.

#utpfig([About 77% of `Cabin` and 20% of `Age` are missing, whereas most variables are complete. This pattern calls for variable-specific reasoning rather than a blanket “drop missing rows” rule.], label: <fig:quality-titanic-missing>)[
  #image("/DATA SCIENCE/figures/quality_titanic_missingness.pdf", width: 82%)
]

Deleting every row with any missing value would discard most passengers because `Cabin` is frequently absent. A professional audit asks what “missing” means: was a cabin never recorded, not applicable, unreadable in the source, or simply lost during data assembly? The answer determines whether missingness is nuisance, information, or both.

#example[
  A sensible teaching strategy for `Age` is to preserve the original column and create `Age_imputed`. Group-median imputation by passenger class and sex is transparent and reproducible, but it still shrinks within-group variation. The report should therefore state how many values were imputed and avoid presenting the derived ages as observed facts.
]

== Extended audit: structural missingness and duplicate semantics

The Ames Housing and Red Wine Quality datasets show why a professional data-quality review must go beyond a generic missing-value function. In Ames, some variables are almost entirely missing, but the reason is often structural: a property without a pool has no meaningful pool-quality rating, and a property without an alley cannot have an alley type. Encoding those cases as ordinary numeric or categorical missingness without understanding the data dictionary can erase information.

#utpfig([The most incomplete fields are largely optional property attributes. A high missing percentage is therefore a prompt to investigate meaning, not an automatic instruction to drop the column.], label: <fig:quality-ames-missing>)[
  #image("/DATA SCIENCE/figures/quality_ames_missingness.pdf", width: 86%)
]

This distinction is useful in modelling. For a feature such as `Pool QC`, an explicit category such as “No pool” can carry different information from “pool quality was not recorded.” The analyst should preserve that distinction whenever the source permits it.

The Red Wine Quality file illustrates a different issue. It contains exact duplicate rows even though no unique wine identifier is supplied.

#utpfig([The file has fewer unique rows than supplied rows. That fact alone does not establish an error: two wines can share the same measured chemistry and quality score, or the same record may have been repeated.], label: <fig:quality-wine-duplicates>)[
  #image("/DATA SCIENCE/figures/quality_wine_duplicates.pdf", width: 72%)
]

#note[
  Never write `distinct()` or `duplicated()` as a cleaning ritual. First state the expected key and the intended unit of observation, then explain why repeated rows are impossible, possible, or informative under that definition.
]
