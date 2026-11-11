#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-exploratory-analysis")


#heading(level: 1)[Exploratory Data Analysis]
 <ch:eda> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should be able to prepare an analysis table and compute grouped summaries.

*By the end, you can:* use distribution, outlier, and relationship summaries to discover structure while separating exploration from confirmation.]


#heading(level: 2)[EDA asks what the data are trying to tell you]
 #strong[Exploratory data analysis (EDA)] is a systematic search for distribution shape, unusual records, group differences, and relationships worth investigating. It is not a licence to report every pattern as a finding.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/bb54160ff1338926.svg")], caption: [Move from one variable to pairs and then to conditional or multivariate structure.]) <fig:eda-lenses>


#heading(level: 2)[Start with shape before choosing a summary]
 A mean and standard deviation are informative when the distribution is roughly symmetric and not dominated by extreme values. For skewed or multi-modal distributions, the median, quantiles, and plots often communicate structure more faithfully.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/eda_distribution_shapes.svg", width: 90%)], caption: [Symmetric, skewed, and bimodal distributions can require different summaries and different follow-up questions. Bimodality often suggests hidden groups or multiple data-generating processes.]) <fig:eda-shapes>

A useful first pass records the minimum, lower quartile, median, upper quartile, maximum, mean, standard deviation, missing count, and sample size. The goal is not to report every number, but to notice when the numbers disagree in ways that suggest skew, extreme values, or subgroup structure.


#heading(level: 2)[Center without spread is incomplete]
 The mean is sensitive to extreme values; the median is more robust. Standard deviation describes typical distance from the mean; the interquartile range (IQR) describes the middle half of the data.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    [Statistic], [What it describes], [],
    [extreme values?], [], [],
    [Mean], [arithmetic center], [no],
    [Median], [middle ordered value], [yes],
    [Standard deviation], [spread around mean], [no],
    [IQR], [spread of middle 50%], [yes],
    [Range], [minimum to maximum], [no],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/eda_mean_median_outlier.svg", width: 90%)], caption: [The mean shifts toward an extreme observation because every value contributes its magnitude. The median depends mainly on order and therefore moves much less.]) <fig:eda-mean-median>


#heading(level: 2)[Quantiles describe relative position]
 The $p$th quantile is a value below which approximately $p$ proportion of observations fall. Quartiles divide ordered data into four parts; percentiles generalise the same idea. Quantiles are particularly useful for skewed variables because they describe position without assuming symmetry.


#heading(level: 2)[Outliers are observations to investigate]
 The common 1.5-IQR rule flags values outside $ \[ Q_1 - 1.5 thin I Q R \, #h(0em) Q_3 + 1.5 thin I Q R \] . $ A flag is not a deletion instruction. An extreme observation may be a data error, a rare but valid case, or the most important record in the dataset.

#callout("pitfall", title: [Analytical pitfall])[Deleting outliers because they "look wrong" can manufacture a cleaner relationship than the population actually has. Investigate provenance and domain plausibility before removal.]


#heading(level: 2)[Bivariate EDA depends on variable types]
 Different pairs of variable types call for different evidence:

- numeric--numeric: scatterplot, correlation, fitted trend, unusual points;

- numeric--categorical: side-by-side distributions, group medians/means and spread;

- categorical--categorical: contingency tables, conditional proportions, mosaic-style comparisons.

The main question is whether the second variable changes the distribution of the first, and whether that change is large enough to matter.


#heading(level: 2)[Relationships need visual and numerical evidence]
 Correlation summarizes linear association on a scale from -1 to 1. It does not establish causation and can be distorted by nonlinearity, outliers, restricted ranges, or confounding variables.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/eda_correlation_heatmap.svg", width: 90%)], caption: [The matrix summarises pairwise linear association. Strong blocks can reveal redundant features or groups of measurements that move together, but correlation alone does not identify causal relationships.]) <fig:eda-corr-heatmap>


#heading(level: 2)[Conditional patterns can reverse an overall pattern]
 A relationship in aggregated data can weaken, disappear, or reverse after conditioning on a third variable. This is one reason to examine important relationships within meaningful subgroups. The phenomenon is often associated with #strong[Simpson's paradox]: aggregation combines group composition with within-group relationships.

When an overall scatterplot or mean difference seems surprising, ask whether a grouping variable, time period, geography, or data-collection mechanism could be mixing distinct populations.

#callout("workedexample", title: [Worked example])[If alcohol and colour intensity are correlated in the wine data, plausible explanations include shared chemistry, cultivar differences, or another measured property. A scatterplot coloured or split by cultivar can reveal whether the overall association is partly a group effect.]


#heading(level: 2)[Exploration versus confirmation]
 EDA generates hypotheses. Confirmatory analysis evaluates a question that is sufficiently pre-specified to support formal uncertainty statements. Reusing the same dataset to discover and confirm a pattern tends to overstate certainty.

#callout("keyidea", title: [Key idea])[Write observations in evidence language: "The median is higher in group A" or "the scatterplot shows a curved relationship." Avoid causal language unless the study design supports it.]


#heading(level: 2)[A repeatable EDA checklist]


+ Verify row count, variable types, missingness, and plausible ranges.

+ Examine each important numeric distribution and categorical frequency table.

+ Compare the target or key outcome across relevant groups.

+ Plot important numeric pairs and inspect correlations cautiously.

+ Investigate unusual records and record any exclusions.

+ Summarise three to five evidence-backed observations and open questions.

#callout("quickcheck", title: [Check your understanding])[+ When is the median more informative than the mean?

+ Why is an IQR outlier flag not sufficient reason to delete a row?

+ Name two ways a correlation can be misleading.

+ Why should exploratory and confirmatory analysis be distinguished?]


#heading(level: 2)[Worked EDA: medical insurance charges]


The Medical Cost Personal dataset is useful because it contains a strongly right-skewed numeric outcome and a subgroup with a large distributional shift. It illustrates why EDA should combine distribution shape, robust summaries, and conditional comparisons.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/eda_medical_costs.svg", width: 90%)], caption: [The overall distribution is right-skewed. Splitting by smoking status reveals a much larger shift than an overall histogram alone would communicate.]) <fig:eda-medical-costs>

In the bundled file, mean charges are roughly \$8,434 for non-smokers and \$32,050 for smokers; the corresponding medians are about \$7,345 and \$34,456. The difference between mean and median within each group is itself evidence about shape and tail behaviour. Meanwhile the overall BMI--charges correlation is only about 0.20, which does not imply BMI is unimportant: its association can differ by smoking status and age, and nonlinearities or interactions may matter.

#callout("pitfall", title: [Analytical pitfall])[A large group difference discovered during EDA should not be promoted directly to a causal story. Smoking status, age, BMI, and other measured or unmeasured factors are not randomly assigned in this observational dataset.]
