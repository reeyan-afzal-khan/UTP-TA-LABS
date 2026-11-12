#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-exploratory-analysis")

= Exploratory Data Analysis <ch:eda>

#chapterguide[You should be able to prepare an analysis table and compute grouped summaries.][use distribution, outlier, and relationship summaries to discover structure while separating exploration from confirmation.]

== EDA asks what the data are trying to tell you

#term[Exploratory data analysis (EDA)] is a systematic search for distribution shape, unusual records, group differences, and relationships worth investigating. It is not a licence to report every pattern as a finding.

#utpfig([Move from one variable to pairs and then to conditional or multivariate structure.], label: <fig:eda-lenses>)[
  #canvas(x: 16.06cm, {
    let lens = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.235 * 16.06, min-width: 0.29 * 16.06, min-height: 2.2, inner-xsep: 4mm, inner-ysep: 3mm, align: center, font: font("script", fill: navy))
    let flow = (line-width: 0.8966pt, draw: teal, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8966pt))
    node((0.17, 0), [#text(fill: blue)[#strong[01 DESCRIBE]] \ #v(4.9813pt)
   #fsize("footnote")[#strong[UNIVARIATE]] \ #v(3.9851pt)
   #strong[One variable] \ #v(4.9813pt)
   Shape, centre, and spread], name: "u", ..lens)
    node((0.5, 0), [#text(fill: blue)[#strong[02 RELATE]] \ #v(4.9813pt)
   #fsize("footnote")[#strong[BIVARIATE]] \ #v(3.9851pt)
   #strong[Two variables] \ #v(4.9813pt)
   Differences and relationships], name: "b", ..lens)
    node((0.83, 0), [#text(fill: teal)[#strong[03 CONDITION]] \ #v(4.9813pt)
   #fsize("footnote")[#strong[MULTIVARIATE]] \ #v(3.9851pt)
   #strong[Multiple variables] \ #v(4.9813pt)
   Patterns within groups \
  and joint structure], name: "m", ..lens, draw: mix(teal, 80%), fill: pale-teal)
    connect("u.east", "b.west", ..flow)
    connect("b.east", "m.west", ..flow)
  })
]

== Start with shape before choosing a summary

A mean and standard deviation are informative when the distribution is roughly symmetric and not dominated by extreme values. For skewed or multi-modal distributions, the median, quantiles, and plots often communicate structure more faithfully.

#utpfig([Symmetric, skewed, and bimodal distributions can require different summaries and different follow-up questions. Bimodality often suggests hidden groups or multiple data-generating processes.], label: <fig:eda-shapes>)[
  #image("/DATA SCIENCE/figures/eda_distribution_shapes.pdf", width: 90%)
]

A useful first pass records the minimum, lower quartile, median, upper quartile, maximum, mean, standard deviation, missing count, and sample size. The goal is not to report every number, but to notice when the numbers disagree in ways that suggest skew, extreme values, or subgroup structure.

== Center without spread is incomplete

The mean is sensitive to extreme values; the median is more robust. Standard deviation describes typical distance from the mean; the interquartile range (IQR) describes the middle half of the data.

#utptable[
  #tabularx(
    columns: (4cm, 1fr, 3cm),
    align: (left, left, center),
    styles: (navy-bold,),
    header: ([Statistic], [What it describes], [#shortstack[Robust to \
    extreme values?]]),
    [Mean], [arithmetic center], [no],
    [Median], [middle ordered value], [yes],
    [Standard deviation], [spread around mean], [no],
    [IQR], [spread of middle 50%], [yes],
    [Range], [minimum to maximum], [no],
  )
]

#utpfig([The mean shifts toward an extreme observation because every value contributes its magnitude. The median depends mainly on order and therefore moves much less.], label: <fig:eda-mean-median>)[
  #image("/DATA SCIENCE/figures/eda_mean_median_outlier.pdf", width: 84%)
]

== Quantiles describe relative position

The $p$th quantile is a value below which approximately $p$ proportion of observations fall. Quartiles divide ordered data into four parts; percentiles generalise the same idea. Quantiles are particularly useful for skewed variables because they describe position without assuming symmetry.

== Outliers are observations to investigate

The common 1.5-IQR rule flags values outside

$ [Q_1 - 1.5 thin I Q R, med Q_3 + 1.5 thin I Q R]. $

A flag is not a deletion instruction. An extreme observation may be a data error, a rare but valid case, or the most important record in the dataset.

#pitfall[
  Deleting outliers because they “look wrong” can manufacture a cleaner relationship than the population actually has. Investigate provenance and domain plausibility before removal.
]

== Bivariate EDA depends on variable types

Different pairs of variable types call for different evidence:

- numeric--numeric: scatterplot, correlation, fitted trend, unusual points;
- numeric--categorical: side-by-side distributions, group medians/means and spread;
- categorical--categorical: contingency tables, conditional proportions, mosaic-style comparisons.

The main question is whether the second variable changes the distribution of the first, and whether that change is large enough to matter.

== Relationships need visual and numerical evidence

Correlation summarizes linear association on a scale from -1 to 1. It does not establish causation and can be distorted by nonlinearity, outliers, restricted ranges, or confounding variables.

#utpfig([The matrix summarises pairwise linear association. Strong blocks can reveal redundant features or groups of measurements that move together, but correlation alone does not identify causal relationships.], label: <fig:eda-corr-heatmap>)[
  #image("/DATA SCIENCE/figures/eda_correlation_heatmap.pdf", width: 74%)
]

== Conditional patterns can reverse an overall pattern

A relationship in aggregated data can weaken, disappear, or reverse after conditioning on a third variable. This is one reason to examine important relationships within meaningful subgroups. The phenomenon is often associated with #term[Simpson’s paradox]: aggregation combines group composition with within-group relationships.

When an overall scatterplot or mean difference seems surprising, ask whether a grouping variable, time period, geography, or data-collection mechanism could be mixing distinct populations.

#workedexample[
  If alcohol and colour intensity are correlated in the wine data, plausible explanations include shared chemistry, cultivar differences, or another measured property. A scatterplot coloured or split by cultivar can reveal whether the overall association is partly a group effect.
]

== Exploration versus confirmation

EDA generates hypotheses. Confirmatory analysis evaluates a question that is sufficiently pre-specified to support formal uncertainty statements. Reusing the same dataset to discover and confirm a pattern tends to overstate certainty.

#keyidea[
  Write observations in evidence language: “The median is higher in group A” or “the scatterplot shows a curved relationship.” Avoid causal language unless the study design supports it.
]

== A repeatable EDA checklist

#utpsteps[
  + Verify row count, variable types, missingness, and plausible ranges.
  + Examine each important numeric distribution and categorical frequency table.
  + Compare the target or key outcome across relevant groups.
  + Plot important numeric pairs and inspect correlations cautiously.
  + Investigate unusual records and record any exclusions.
  + Summarise three to five evidence-backed observations and open questions.
]

#quickcheck[
  + When is the median more informative than the mean?
  + Why is an IQR outlier flag not sufficient reason to delete a row?
  + Name two ways a correlation can be misleading.
  + Why should exploratory and confirmatory analysis be distinguished?
]

== Worked EDA: medical insurance charges

The Medical Cost Personal dataset is useful because it contains a strongly right-skewed numeric outcome and a subgroup with a large distributional shift. It illustrates why EDA should combine distribution shape, robust summaries, and conditional comparisons.

#utpfig([The overall distribution is right-skewed. Splitting by smoking status reveals a much larger shift than an overall histogram alone would communicate.], label: <fig:eda-medical-costs>)[
  #image("/DATA SCIENCE/figures/eda_medical_costs.pdf", width: 90%)
]

In the bundled file, mean charges are roughly \$8,434 for non-smokers and \$32,050 for smokers; the corresponding medians are about \$7,345 and \$34,456. The difference between mean and median within each group is itself evidence about shape and tail behaviour. Meanwhile the overall BMI--charges correlation is only about 0.20, which does not imply BMI is unimportant: its association can differ by smoking status and age, and nonlinearities or interactions may matter.

#pitfall[
  A large group difference discovered during EDA should not be promoted directly to a causal story. Smoking status, age, BMI, and other measured or unmeasured factors are not randomly assigned in this observational dataset.
]
