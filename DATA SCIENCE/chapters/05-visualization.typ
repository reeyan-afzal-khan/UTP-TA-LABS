#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-visualization")


#heading(level: 1)[Data Visualization and Communication]
 <ch:visualization> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand distributions, grouped comparisons, outliers, and relationships.

*By the end, you can:* choose charts by analytical purpose; map variables to visual encodings; and write interpretations that do not overclaim.]


#heading(level: 2)[Choose the chart from the question]
 A chart is an argument made with visual encodings. The plot type should match the task rather than personal preference.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Analytical task], [Useful chart], [Read from the chart],),
    table.hline(),
    [Distribution], [histogram / density / box plot], [shape, center, spread, unusual values],
    [Compare categories], [bar chart / box plot], [differences in counts or distributions],
    [Numeric relationship], [scatterplot], [form, direction, strength, clusters, outliers],
    [Change over ordered time], [line chart], [direction, rate, turning points],
    [Part-to-whole], [stacked bar (sparingly)], [composition, preferably with common baselines],
  )]
  , kind: table
  )


#heading(level: 2)[Position is usually the strongest encoding]
 Humans compare positions along a common axis more accurately than angles, areas, or 3D volumes. That is why a bar chart is often easier to read than a pie chart and why decorative 3D effects are rarely useful.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA SCIENCE/figures/diagrams/1da056e97304bc68.cetz.json")], caption: [Prefer encodings that support precise comparison when the analytical goal depends on small differences.]) <fig:encoding-hierarchy>


#heading(level: 2)[Every visual encoding consumes attention]
 A chart encodes variables using position, length, colour, shape, size, angle, and sometimes texture. More encodings are not automatically better. Use the strongest channels for the variables most central to the question, and reserve colour or shape for secondary grouping only when it clarifies interpretation.

Direct labels, meaningful axis titles, and a descriptive caption often improve comprehension more than additional decoration. A chart should be understandable without requiring the reader to reverse-engineer arbitrary abbreviations.


#heading(level: 2)[Histograms answer distribution questions]
 Histogram appearance depends on bin boundaries. Too few bins hide structure; too many amplify noise. Use the chart to understand shape, then check conclusions across reasonable bin choices.

#code-block("hist(wine$alcohol,\n     breaks = 12,\n     xlab = \"Alcohol\",\n     main = \"Distribution of alcohol measurements\")", lang: "r")

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/viz_histogram_bins.svg", width: 90%)], caption: [All three panels contain the same alcohol measurements. Few bins hide local structure; many bins can make random sample noise look important.]) <fig:viz-bin-choice>


#heading(level: 2)[Density, box, and violin-style views answer different questions]
 A histogram or density estimate emphasises shape. A box plot emphasises median, quartiles, and outlier flags. A violin plot combines a density-like shape with a group comparison, but can suggest more precision than the sample supports when groups are small. Choose the representation that exposes the property the reader needs to compare.


#heading(level: 2)[Box plots compare distributions compactly]
 A box plot shows the median, quartiles, and potential outliers. It is effective for comparing several groups, but it hides detailed shape and sample-size differences unless additional context is provided.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/viz_boxplot_species.svg", width: 90%)], caption: [The same measurement can have overlapping but distinct group distributions. Box plots make medians and spread easy to compare, while the chapter's scatterplot will show within-group relationships.]) <fig:viz-boxplot>


#heading(level: 2)[Scatterplots are the default for two numeric variables]
 A scatterplot can reveal linear or curved relationships, changing variance, distinct clusters, and influential points that one correlation coefficient cannot show.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/viz_iris_scatter.svg", width: 90%)], caption: [Petal length and width have a strong overall relationship, but colour reveals three species-level groups and different local ranges.]) <fig:viz-iris-scatter>


#heading(level: 2)[Uncertainty should be visible when the claim is uncertain]
 If a figure shows an estimated mean, fitted line, or model prediction, include an interval, error bar, distribution of resampled estimates, or another appropriate uncertainty display when possible. Showing only the point estimate can make an uncertain result appear exact.


#heading(level: 2)[Design for comparison]
 Good chart design places the values that need comparison on a common scale and close enough to compare. Small multiples are effective when several groups or time periods share the same axes. Sorting categories by a meaningful quantity can also reduce the mental work needed to find patterns.

#callout("pitfall", title: [Analytical pitfall])[Axis limits can exaggerate or conceal differences. Truncating a bar chart away from zero changes the perceived ratio of bar lengths; clipping a scatterplot can hide records that contradict the intended story. State and justify unusual scales.]


#heading(level: 2)[A chart needs an evidence sentence]
 Every figure should support a short interpretation that names the variables, describes the visible pattern, and separates observation from explanation.

#callout("workedexample", title: [Worked example])[Weak: "The graph shows a relationship."

Better: "Petal length and petal width increase together, and the observations form visible species-level clusters. The plot establishes association and separation, not a biological causal mechanism."]

#callout("keyidea", title: [Key idea])[Good visualisation reduces the distance between data and judgment. Remove decoration that does not encode information; keep labels, units, and context that make the evidence interpretable.]


#heading(level: 2)[A visualisation review checklist]
 Before publishing a chart, ask: Is the analytical question visible? Are units and population clear? Does the geometry match the variable type? Are scales honest and comparable? Is colour necessary and distinguishable? Are missing values or excluded groups acknowledged? Does the caption state the evidence rather than merely repeat the title? Could a reader misinterpret association as causation?

#callout("quickcheck", title: [Check your understanding])[+ Why is position on a common axis easier to compare than area?

+ What can a scatterplot reveal that correlation alone cannot?

+ Why should histogram conclusions be checked across reasonable bin widths?

+ What makes an interpretation sentence stronger than a chart title alone?]


#heading(level: 2)[Worked visual design: red-wine quality]


The Red Wine Quality dataset contains 1,599 wines and an ordered quality score from 3 to 8. The outcome is numeric in storage but conceptually discrete and ordinal. That distinction affects chart design.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/viz_wine_quality_alcohol.svg", width: 90%)], caption: [Boxplots preserve the discreteness of the quality score while showing a systematic shift in the alcohol distribution. The figure supports comparison without pretending that every one-unit quality change is exactly equivalent.]) <fig:viz-redwine-alcohol>

The correlation between alcohol and quality is about 0.48, but the boxplots communicate more: the quality groups overlap substantially and sample sizes are very unequal. Scores 5 and 6 dominate the dataset, whereas extreme scores are rare. A regression line alone would hide both facts.

#callout("keyidea", title: [Key idea])[The best chart is not the chart with the most aesthetics. It is the chart whose visual encoding makes the comparison required by the question easy and honest.]


#heading(level: 2)[A second visual-design case: when two discrete dimensions interact]


The Bike Sharing hourly table contains two discrete coordinates that are easy to lose in a sequence of separate bar charts: hour of day and weekday. A heatmap uses position in two dimensions and colour for mean demand, allowing the reader to scan for recurring temporal structure.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/viz_bike_heatmap.svg", width: 90%)], caption: [The heatmap makes morning/evening weekday peaks and broader weekend daytime use visible in one compact display. A one-dimensional average by hour would blur some of this structure.]) <fig:viz-bike-heatmap>

This example also illustrates a design principle: aggregation should match the visual question. Each cell is a mean across many observed hours. The chart is therefore suitable for a recurring pattern, but not for showing day-to-day volatility, weather shocks, or uncertainty around each cell. A professional report should not ask one graphic to answer all of those questions simultaneously.
