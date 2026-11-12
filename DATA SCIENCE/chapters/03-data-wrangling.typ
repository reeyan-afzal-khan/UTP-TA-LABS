#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-data-wrangling")

= Data Wrangling and Feature Construction <ch:wrangling>

#chapterguide[You should understand observations, variables, data types, and data-quality checks.][select and filter records, sort data, compute grouped summaries, and create features that preserve clear meaning.]

== Wrangling changes representation, not the question

Data wrangling prepares the evidence needed for analysis. Common operations are selecting variables, filtering observations, ordering records, grouping categories, aggregating summaries, joining tables, and constructing derived features.

#utpfig([Each operation should be explainable as a transformation from one table to another.], label: <fig:wrangling-pipeline>)[
  #canvas(x: 16.06cm, {
    let stage = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.14 * 16.06, min-width: 0.18 * 16.06, min-height: 1.7, inner-xsep: 2.5mm, inner-ysep: 2.5mm, align: center, font: font("script", fill: navy))
    let endpoint = (..stage, draw: mix(teal, 80%), fill: pale-teal)
    let flow = (line-width: 0.8966pt, draw: teal, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8966pt))
    node((0.1, 0), [#text(fill: teal)[#strong[01 INPUT]] \ #v(4.9813pt)
   #strong[Raw table] \ #v(2.9888pt)
   Original records \
  and variables], name: "raw", ..endpoint)
    node((0.3, 0), [#text(fill: blue)[#strong[02 SCOPE]] \ #v(4.9813pt)
   #strong[Select and filter] \ #v(2.9888pt)
   Relevant rows \
  and columns], name: "sel", ..stage)
    node((0.5, 0), [#text(fill: blue)[#strong[03 DERIVE]] \ #v(4.9813pt)
   #strong[Create features] \ #v(2.9888pt)
   Interpretable \
  derived variables], name: "feat", ..stage)
    node((0.7, 0), [#text(fill: blue)[#strong[04 SUMMARISE]] \ #v(4.9813pt)
   #strong[Aggregate] \ #v(2.9888pt)
   Summaries at \
  the required grain], name: "grp", ..stage)
    node((0.9, 0), [#text(fill: teal)[#strong[05 OUTPUT]] \ #v(4.9813pt)
   #strong[Analysis table] \ #v(2.9888pt)
   Evidence for \
  the question], name: "ana", ..endpoint)
    connect("raw.east", "sel.west", ..flow)
    connect("sel.east", "feat.west", ..flow)
    connect("feat.east", "grp.west", ..flow)
    connect("grp.east", "ana.west", ..flow)
  })
]

== Think in verbs: each step should have one purpose

A readable wrangling pipeline is a sequence of simple verbs: #emph[select], #emph[filter], #emph[mutate], #emph[group], #emph[summarise], #emph[join], and #emph[reshape]. Keeping transformations small makes intermediate row counts and assumptions easier to audit.

#utpfig([Each transformation should preserve a clear contract: what one row represents, which variables are retained, and which new values were derived.], label: <fig:wrangle-contract>)[
  #canvas({
    let stage = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.7 * 16.06, min-width: 0.76 * 16.06, min-height: 0.84, inner-xsep: 5mm, inner-ysep: 1.3mm, align: left, font: font("script", fill: navy))
    let endpoint = (..stage, draw: mix(teal, 80%), fill: pale-teal)
    let flow = (line-width: 0.8966pt, draw: teal, end: tip("Stealth", length: 1.8mm, width: 1.4mm, line: 0.8966pt))
    let stagejoin = (line-width: 0.7472pt, draw: teal)
    node((0, 0), [#text(fill: teal)[#strong[01 INPUT CONTRACT]] \ #v(2.9888pt)
   One row = one wine sample; 15 variables], name: "a", ..endpoint)
    node(below-of("a", 0.14), [#text(fill: blue)[#strong[02 SELECT]] \ #v(2.9888pt)
   Keep cultivar, alcohol, colour intensity, and proline], name: "b", ..stage)
    node(below-of("b", 0.14), [#text(fill: blue)[#strong[03 FILTER]] \ #v(2.9888pt)
   Retain records meeting a stated inclusion rule], name: "c", ..stage)
    node(below-of("c", 0.14), [#text(fill: blue)[#strong[04 CREATE FEATURES]] \ #v(2.9888pt)
   Add interpretable derived columns], name: "d", ..stage)
    node(below-of("d", 0.14), [#text(fill: teal)[#strong[05 OUTPUT CONTRACT]] \ #v(2.9888pt)
   One row still = one wine sample; analysis-ready variables], name: "e", ..endpoint)
    coordinate("r1", (rel: (-0.7, 0), to: "a.west"))
    coordinate("r2", (rel: (-0.7, 0), to: "b.west"))
    coordinate("r3", (rel: (-0.7, 0), to: "c.west"))
    coordinate("r4", (rel: (-0.7, 0), to: "d.west"))
    coordinate("r5", (rel: (-0.7, 0), to: "e.west"))
    connect((rel: (0, 0.3), to: "r1"), (rel: (0, -0.3), to: "r5"), ..flow)
    for (rail, card) in (("r1", "a"), ("r2", "b"), ("r3", "c"), ("r4", "d"), ("r5", "e")) {
      connect(rail, card + ".west", ..stagejoin)
      circle-at(rail, 1.1457pt, fill: teal, draw: none)
    }
  })
]

== Select only what the question needs

If the question concerns alcohol, colour intensity, and cultivar, carrying every available variable into every step increases cognitive load and opportunities for mistakes.

```r
analysis <- wine[, c("cultivar", "alcohol",
                     "color_intensity", "proline")]
```

== Filter records with explicit conditions

Filtering defines the population being analysed. That means every filter should be stated in the report.

```r
high_alcohol <- wine[wine$alcohol >= 13.5, ]
```

#pitfall[
  Filtering after looking at the outcome can quietly turn exploration into cherry-picking. Define inclusion rules from the analytical question or domain constraints, and disclose post-hoc filters.
]

== Aggregation changes the unit of observation

When rows are grouped and summarised, the output table no longer represents individual observations. One row may now represent a cultivar, region, month, or customer. This is a fundamental change in the analytical unit and should be made explicit.

#utpfig([The cultivar means differ, while the dashed line shows the overall mean. Error bars are approximate 95% intervals for each group mean and remind us that summaries are estimates.], label: <fig:wrangle-group-summary>)[
  #image("/DATA SCIENCE/figures/wrangling_group_summary.pdf", width: 80%)
]

#utpfig([The log transformation compresses large values more strongly than small values. It can make skewed data easier to visualise or model, but it also changes coefficient interpretation.], label: <fig:wrangle-transform>)[
  #image("/DATA SCIENCE/figures/wrangling_transform.pdf", width: 82%)
]

#keyidea[
  Always ask whether a grouped result is weighted correctly for the question. Averaging three group means is not generally the same as the overall mean when group sizes differ.
]

== Grouped summaries reveal structured differences

Overall averages can hide subgroup structure. The `aggregate()` function makes the comparison explicit:

```r
aggregate(alcohol ~ cultivar, data = wine, FUN = mean)
```

A group summary should usually include both a center and a measure of spread or sample size.

== Reshaping: wide and long representations

The same information can be represented in different table shapes. #term[Wide] data often place repeated measures in separate columns, while #term[long] data place the measurement name and value in rows. Long form is often convenient for grouped plotting and repeated-measures analysis; wide form can be convenient for modelling matrices.

#utpfig([Reshaping should change layout, not invent or discard measurements. The key columns must be sufficient to reconstruct the original representation.], label: <fig:wide-long>)[
  #canvas(x: 16.06cm, {
    let tablecard = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.36 * 16.06, min-width: 0.42 * 16.06, min-height: 4.05, inner-sep: 3mm, align: center, font: font("script", fill: navy))
    let reshapebadge = (draw: mix(teal, 80%), fill: pale-teal, rounded: 4mm, line-width: 0.7472pt, text-width: 0.075 * 16.06, min-height: 0.78, inner-xsep: 2mm, inner-ysep: 1.5mm, align: center, font: font("script", weight: "bold", fill: teal))
    let reshape = (line-width: 0.8468pt, draw: teal, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8468pt))
    node((0.22, 0), [#box(width: 100%, height: 3.35cm)[
    #align(center)[#text(fill: blue)[#strong[01 WIDE FORMAT]] \ #v(2.9888pt)

    #strong[One row per ID] \ #v(0.9963pt)

    Repeated measures occupy columns

    #v(3.9851pt)

    #fsize-at(7.3724pt, 8.7671pt)[

    #tabularx(
      columns: (auto, auto, auto),
      align: (center, right, right),
      rules: ("bottom",),
      rule-color: mix(blue, 45%),
      header-fill: mix(blue, 85%),
      header: ([#text(fill: white)[#strong[ID]]], [#text(fill: white)[#strong[Morning]]], [#text(fill: white)[#strong[Evening]]]),
      table.cell(fill: white)[01], table.cell(fill: white)[21.4], table.cell(fill: white)[26.1],
      table.cell(fill: mix(blue, 5%))[02], table.cell(fill: mix(blue, 5%))[20.9], table.cell(fill: mix(blue, 5%))[25.6],
    )

    ]]
  ]], name: "wide", ..tablecard)
    node((0.78, 0), [#box(width: 100%, height: 3.35cm)[
    #align(center)[#text(fill: teal)[#strong[02 LONG FORMAT]] \ #v(2.9888pt)

    #strong[One row per ID and time] \ #v(0.9963pt)

    Repeated measures occupy rows

    #v(3.9851pt)

    #fsize-at(7.3724pt, 8.7671pt)[

    #tabularx(
      columns: (auto, auto, auto),
      align: (center, left, right),
      rules: ("bottom",),
      rule-color: mix(teal, 45%),
      header-fill: mix(teal, 85%),
      header: ([#text(fill: white)[#strong[ID]]], [#text(fill: white)[#strong[Time]]], [#text(fill: white)[#strong[Value]]]),
      table.cell(fill: white)[01], table.cell(fill: white)[morning], table.cell(fill: white)[21.4],
      table.cell(fill: mix(teal, 5%))[01], table.cell(fill: mix(teal, 5%))[evening], table.cell(fill: mix(teal, 5%))[26.1],
      table.cell(fill: white)[02], table.cell(fill: white)[morning], table.cell(fill: white)[20.9],
      table.cell(fill: mix(teal, 5%))[02], table.cell(fill: mix(teal, 5%))[evening], table.cell(fill: mix(teal, 5%))[25.6],
    )

    ]]
  ]], name: "long", ..tablecard, draw: mix(teal, 80%), fill: pale-teal)
    node((0.5, 0), [RESHAPE], name: "change", ..reshapebadge)
    connect("wide.east", "change.west", ..reshape)
    connect("change.east", "long.west", ..reshape)
    node((0.5, -2.3), [same measurements • different layout], font: font("script", fill: muted), align: center)
  })
]

== Feature engineering should add meaning

A #term[feature] is an input variable used in analysis or modelling. New features can simplify relationships, encode domain knowledge, or make scales easier to compare.

#utptable[
  #tabularx(
    columns: (3.1cm, 4.4cm, 1fr),
    styles: (navy-bold,),
    header: ([Feature operation], [Example], [Reason]),
    [Binning], [alcohol to lower/middle/higher], [communicate broad ranges],
    [Transformation], [$log(1+x)$], [compress strongly right-skewed values],
    [Ratio], [cost per unit], [represent relative rather than absolute size],
    [Interaction], [age $times$ treatment], [allow one effect to vary with another],
    [Indicator], [missing = yes/no], [preserve missingness as information],
  )
]

#keyidea[
  A good engineered feature has a sentence-level interpretation. If you cannot explain what the feature means without referring to the code that produced it, it is hard to defend analytically.
]

== Join cardinality should be known before the join

A join combines rows according to key matches. The expected relationship between keys is called #term[cardinality]. One-to-one joins should preserve row count; one-to-many joins deliberately repeat the “one” side; many-to-many joins can create a Cartesian multiplication and are frequently accidental.

#utpfig([Knowing the expected key relationship lets row-count changes become a diagnostic rather than a surprise.], label: <fig:join-cardinality>)[
  #canvas(x: 16.06cm, {
    let relationship = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.235 * 16.06, min-width: 0.29 * 16.06, min-height: 2.7, inner-xsep: 4mm, inner-ysep: 3mm, align: center, font: font("script", fill: navy))
    node((0.17, 0), [#text(fill: blue)[#strong[01 ONE-TO-ONE]] \ #v(4.9813pt)
   #fsize-at(12.9514pt, 14.944pt)[#strong[1 : 1]] \ #v(5.9776pt)
   One profile per ID \
  One outcome per ID \ #v(5.9776pt)
   #text(fill: muted)[#strong[ROW COUNT]] \ #v(-0.9963pt)
   Usually preserved], name: "oneone", ..relationship)
    node((0.5, 0), [#text(fill: teal)[#strong[02 ONE-TO-MANY]] \ #v(4.9813pt)
   #fsize-at(12.9514pt, 14.944pt)[#strong[1 : many]] \ #v(5.9776pt)
   One customer \
  Many transactions \ #v(5.9776pt)
   #text(fill: muted)[#strong[ROW COUNT]] \ #v(-0.9963pt)
   Expected expansion], name: "onemany", ..relationship, draw: mix(teal, 80%), fill: pale-teal)
    node((0.83, 0), [#text(fill: mix(red, 85%, other: black))[#strong[03 MANY-TO-MANY]] \ #v(4.9813pt)
   #fsize-at(12.9514pt, 14.944pt)[#strong[many : many]] \ #v(5.9776pt)
   Repeated keys \
  on both sides \ #v(5.9776pt)
   #text(fill: mix(red, 85%, other: black))[#strong[ROW COUNT]] \ #v(-0.9963pt)
   Can multiply unexpectedly], name: "manymany", ..relationship, draw: mix(red, 80%), fill: pale-red)
  })
]

== Joining tables introduces a new failure mode

When combining tables, the join key should be unique at the expected level. A many-to-many join can multiply rows and corrupt counts.

#workedexample[
  Before joining customer and transaction tables, verify whether customer ID is unique in the customer table and repeated in the transaction table. That expected one-to-many relationship is part of the data model, not an implementation detail.
]

#quickcheck[
  + Why can an overall mean be misleading when groups differ strongly?
  + What should be stated whenever rows are filtered out?
  + Give one reason to log-transform a feature.
  + What join problem can cause row counts to increase unexpectedly?
]

== Worked case: from 17,379 hourly rows to an interpretable demand profile

The hourly Bike Sharing file demonstrates why wrangling is analytical work rather than clerical preparation. One row represents one observed hour. The goal is not to make the table smaller for its own sake, but to create a representation matched to a question such as “How does the daily demand pattern differ between working and non-working days?”

#utpfig([A grouped hourly summary reveals commuting peaks on working days and a broader daytime pattern on non-working days. The transformation changes the grain from individual observed hours to mean demand for each hour--day-type combination.], label: <fig:wrangle-bike-hours>)[
  #image("/DATA SCIENCE/figures/wrangling_bike_hourly_profiles.pdf", width: 86%)
]

A useful feature engineering detail is that clock hour is cyclical. In ordinary numeric distance, hours 23 and 0 appear 23 units apart even though they are adjacent on the clock. A common encoding maps hour to the unit circle:

$ h_(sin)=sin(2 pi h\/24), wide h_(cos)=cos(2 pi h\/24). $

This representation preserves neighbourhood around midnight and gives models two smooth numeric variables instead of an arbitrary linear scale.

#keyidea[
  Every aggregation changes the unit of analysis. Before and after a `group`/`summarise` operation, state what one row represents. Many subtle data errors are actually grain errors.
]
