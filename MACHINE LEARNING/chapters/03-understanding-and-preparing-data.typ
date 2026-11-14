#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#unit("chapters", "03-understanding-and-preparing-data")

= Understanding and Preparing Data <ch:data>

#chapterguide[#chapsref(<ch:toolkit>, <ch:orientation>): the workflow, and the difference between features and a target.][assess a table before modeling, log every cleaning rule, choose a split that imitates the future, spot leakage, handle missing values and categories, scale numbers on purpose, and keep all of it inside a pipeline.]

A good cook reads the recipe, checks the fridge and washes the vegetables before lighting the stove. Nobody praises that part, and it decides how dinner turns out. Data work is the same: most projects that fail do so before any model is fitted, because the table meant something other than the team assumed, or because the model was quietly shown the answers.

This chapter asks three questions in order. #emph[What does the data mean? What is wrong with it? What is the model allowed to learn from it?]

== Start with a data quality assessment

Before any model, answer five questions about the table itself. None of them needs code, and each one has sunk real projects.

#utpsteps[
  + #term[What does one row represent?] A person, transaction, image, day, machine, or something else?
  + #term[What does each column mean?] Record its type, unit, valid range, and source.
  + #term[When is prediction made?] Features must exist then. In Lab~1 a call’s duration is known only once the call has ended, and a hotel booking’s reservation status only after the guest has cancelled or left.
  + #term[Which rows are related?] Repeated measurements from one person or device must usually stay in the same split.
  + #term[Who or what is missing?] The dataset may not represent the full population where the model will be used.
]

== A safe order of operations

Some preparation is a fixed rule: a date format, a unit conversion, a typo in a label. It would be done the same way whatever the data said, so it can happen before the split. Other preparation learns something from the data: a median to fill gaps, a mean to scale by. Those steps look at numbers, and they may look only at training rows.

#utpfig([A safe order of operations: define what the data mean, apply fixed rules, split honestly, and only then learn any preparation from the training rows.], label: <fig:safe-order>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.75, min-height: 1.05, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [1\. Define meaning \
  rows, keys, units, timing], name: "meaning", ..box-style)
    node(right-of("meaning", 0.45), [2\. Apply fixed rules \
  parse, standardize, validate], name: "rules", ..box-style)
    node(right-of("rules", 0.45), [3\. Split honestly \
  groups, time, population], name: "split", ..box-style)
    node(right-of("split", 0.45), [4\. Learn preparation \
  from training data only], name: "learn", ..box-style)
    connect("meaning", "rules", ..arr)
    connect("rules", "split", ..arr)
    connect("split", "learn", ..arr)
  })
]

#utptable[
  #tabularx(
    columns: (18%, 35%, 1fr),
    styles: (navy-bold,),
    header: ([Stage], [Examples], [Why it belongs there]),
    [Before the split], [Validate columns, keys, and values; parse dates; standardize units and whitespace.], [These are fixed rules. They do not use the label or any statistic estimated from the data.],
    [After the split], [Learn imputation, scaling, category mappings, outlier thresholds, feature selection, and resampling rules.], [Fit data-dependent choices on training rows only.],
    [After modeling], [Evaluate test performance once, document limits, and monitor data quality and drift.], [Keep the test set for final evaluation, not design decisions.],
  )
]

#keyidea[
  Fixed rules, such as unit conversions, may precede splitting. Estimate medians, scales, category mappings, and cutoffs from training rows only.
]

== Feature and label types

The type of a column decides how a model can use it. A number can go in almost as it is. A word has to be turned into numbers first, and the way you do that can invent an order that was never there.

#utptable[
  #tabularx(
    columns: (20%, 27%, 1fr),
    styles: (navy-bold,),
    header: ([Type], [Example], [Typical treatment]),
    [Numerical], [age, temperature, income], [keep numeric; scale or transform when needed],
    [Nominal category], [country, product type], [one-hot encode or use a model that handles categories],
    [Ordinal category], [low, medium, high], [encode in the true order, but do not assume equal gaps without reason],
    [Date or time], [purchase date, hour], [extract useful parts such as elapsed time, weekday, or season],
    [Text], [review, message], [convert to numerical counts or other classical text features],
  )
]

Labels usually fall into two basic groups:

- A #term[continuous number] suggests regression, such as price or temperature.
- A #term[category] suggests classification, such as fraud/not fraud or animal species.

== Clean structural problems before modeling <sec:cleaning>

Make stored values match their documented meaning using reproducible code, so that anyone can rerun the cleaning and see what it changed. Here is a small messy extract of a student table. It has one duplicated student, an age of $-1$, study hours written as the word `five`, stray spaces, a programme spelled two ways, and one suspicious 30 hours.

#codefrom("/MACHINE LEARNING/all_experiments/book_checks/demo_foundations.py", "def clean_messy_table():", "return table, log")

Running it prints the cleaned table and, more importantly, the log:

```terminal
 student_id  age  hours programme  mark  hours_suspicious
        101 19.0    6.0        CS    58             False
        102 20.0    8.0        CS    64             False
        103  NaN   30.0        IT    71              True
        104 22.0    4.0        IT    49             False
        105  NaN    NaN        CS    66             False
{'rows in': 6, 'duplicate rows dropped': 1, 'hours that would not parse': 1,
 'impossible ages set to missing': 1, 'unusual hours flagged': 1, 'rows out': 5}
```

Notice what the code did not do. It never used the mark to decide anything, and it did not delete the student who claimed 30 hours. That value is unusual, not impossible, so it gets a flag and stays.

=== Confirm row identity and handle duplicates

#utptable[
  #tabularx(
    columns: (20%, 35%, 1fr),
    styles: ((weight: "bold", fill: navy, size: sizes.footnote), (size: sizes.footnote), (size: sizes.footnote)),
    header: ([Pattern], [What it may mean], [Safe response]),
    [Exact repeated row], [Duplicate import or distinct events lacking identifiers], [Remove only if repetition is meaningless; log the count.],
    [Repeated key], [Key conflict, multiple versions, or valid one-to-many data], [Investigate: keep the latest, aggregate, repair the key, or redefine rows.],
    [Same person, different visits], [Valid repeated measurements], [Keep rows; group splits by person to prevent overlap.],
    [Near duplicate], [Spelling, rounding, or record-linkage differences], [Define matching rules and review uncertain matches.],
  )
]

=== Repair types, labels, dates, and units

#utpsteps[
  + #term[Preserve the raw value.] Keep the source file unchanged and create a cleaned copy or scripted transformation.
  + #term[Parse explicitly.] Convert numbers and dates with known rules, and count values that fail to parse.
  + #term[Normalize representation.] Trim accidental whitespace, standardize case where case has no meaning, and map documented synonyms to one label.
  + #term[Normalize units.] Convert to one stated unit using a known conversion; never mix unit conversion with statistical scaling.
  + #term[Validate the result.] Check allowed categories, ranges, key uniqueness, and date order with assertions.
]

=== Distinguish impossible values from unusual values

An age of $-1$ breaks a rule of the world, so it is an #term[impossible value]. A very large purchase may be perfectly real, so it is only a #term[rare value]. They call for different responses.

#utptable[
  #tabularx(
    columns: (15%, 1fr),
    styles: (navy-bold,),
    header: ([Action], [When to use it]),
    [Correct], [Only when an authoritative source or deterministic rule reveals the true value.],
    [Set missing], [When the stored value is known to be invalid but the true value is unknown. Impute later inside the training pipeline if appropriate.],
    [Drop], [When the row cannot answer the project question and a documented inclusion rule justifies removal. Report the count and check whether exclusions are concentrated in a group.],
    [Flag], [When a suspicious value may still be real. A binary quality flag lets the model or analyst retain that information.],
    [Keep], [When a value is valid, even if it is inconvenient. Rare cases may be exactly where a useful model is most needed.],
  )
]

#pitfall[
  Do not remove difficult cases merely to improve scores; they may occur after deployment.
]

=== Keep a cleaning log

Log each rule’s reason, columns, affected row count and action: correction, missingness, exclusion or flagging. Retain identifiers for tracing changes, not as model features.

== Training, validation, and test sets <sec:data-splits>

#analogy[
  Think of how a student prepares for a final. Worked past papers are for learning. A mock exam tells you which study method works best, and you may sit it more than once, which is why it slowly stops being a fair test. The final is sat once, and its score is the one that counts. Those are the training, validation and test sets.
]

#utpfig([The three splits and their jobs: the training set learns parameters, the validation set chooses settings, and the test set gives the final check.], label: <fig:three-splits>)[
  #canvas(x: 1.4936cm, {
    rectangle((0, 0), (6.5, 0.85), fill: mix(blue, 28%), draw: blue)
    rectangle((6.5, 0), (8.3, 0.85), fill: mix(teal, 22%), draw: teal)
    rectangle((8.3, 0), (10, 0.85), fill: mix(orange, 22%), draw: orange)
    node((3.25, 0.425), [Training \
  learn parameters], font: font("small"), align: center)
    node((7.4, 0.425), [Validation \
  choose settings], align: center, font: font("footnote"))
    node((9.15, 0.425), [Test \
  final check], align: center, font: font("footnote"))
  })
]

#describe-nextline(1.15in)[
  / Training set: Used to fit model parameters and data-dependent preprocessing steps.
  / Validation set: Used to compare models, thresholds, and hyperparameters.
  / Test set: Used only for the final estimate after all choices are complete.
]

Training often uses 60--80% of rows. Choose proportions for dataset size while preserving separate validation and test roles.

#pitfall[
  If you look at the test score and then change anything, the test set has become a second validation set, and its score is no longer a fair estimate. Decide what the test set is for, seal it, and open it once.
]

== Choose a split that imitates the future

A random split is honest only when future rows are independent of past rows and drawn the same way. Ask how the model will really be used, and make the split imitate that.

#describe-nextline(1.35in)[
  / Stratified split: Keeps class proportions similar across subsets.
  / Group split: Keeps all rows from one person, device, school, or customer in one subset.
  / Time split: Trains on the past and evaluates on later periods.
  / Spatial split: Separates locations when nearby observations are strongly related.
]

#workedexample[
  #strong[Patients.] With five visits per patient, a random row split lets the model meet the same patient in training and in validation. It may then recognize patients rather than learn medicine. Group by patient when the model is meant for new patients.

  #strong[Hotel bookings.] Lab~2’s cancellation forest scores ROC AUC 0.841 when it trains on arrivals up to the end of 2016 and predicts 2017, which is how a hotel would really use it. Shuffle the bookings first, and the same model on the same data scores 0.911. It looks better only because it was allowed to train on bookings from the very weeks it predicts: 9,366 of the 29,848 shuffled validation bookings have an exact twin among the training rows.
]

#pitfall[
  An unrealistic split gives an unrealistic performance estimate, and nothing downstream can repair that.
]

== Data leakage <sec:data-leakage>

#analogy[
  A class scores 95% on an exam. It later turns out that the paper circulated the night before. The score was real, but it measured the wrong thing, and it predicts nothing about next year. #term[Data leakage] is the same accident: information the model would not have at prediction time, or information from the held-out rows, finds its way into the features, the preprocessing, the choice of model, or the split.
]

Examples include:

- predicting hospital readmission using a field recorded after discharge;
- calculating the mean for standardization using the entire dataset;
- selecting features using test-set performance;
- placing near-duplicate rows in both training and test data;
- using future values to predict an earlier point in time;
- including an identifier or proxy that effectively reveals the label, such as a claim-resolution code when predicting whether a claim will be approved.

The safe rule is simple: fit every data-dependent choice on training data only, then apply the learned transformation unchanged to validation and test data.

The diagram contrasts fitting the preprocessing before and after the split. Only the training rows should decide what a fitted transformation does.

#utpfig([Leakage through preprocessing. Fitting the preparation on all the data lets the test rows influence the scaler; splitting first and fitting on the training rows only keeps the test honest.], label: <fig:prep-leakage>)[
  #canvas({
    let ok = (draw: green, fill: pale-teal, rounded: 1.5mm, min-width: 2.85, min-height: 0.78, inner-xsep: 2.9888pt, align: center, font: font("script", weight: "bold", fill: navy))
    let bad = (draw: red, fill: pale-red, rounded: 1.5mm, min-width: 2.85, min-height: 0.78, inner-xsep: 2.9888pt, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 1.9mm, line: widths.thick))
    let barr = (line-width: widths.thick, draw: red, end: tip("Stealth", length: 1.9mm, line: widths.thick))
    let tag = (font: font("script", weight: "bold"), align: left)
    node((0, 0), [WRONG], name: "t1", ..tag, text: red)
    node(right-of("t1", 0.35), [Load all data], name: "w1", ..bad)
    node(right-of("w1", 0.5), [Fit prep on all data], name: "w2", ..bad)
    node(right-of("w2", 0.5), [Split], name: "w3", ..bad)
    node(right-of("w3", 0.5), [Train, test, celebrate], name: "w4", ..bad)
    connect("w1", "w2", ..barr)
    connect("w2", "w3", ..barr)
    connect("w3", "w4", ..barr)
    node(below-of("w2", 0.12), [test rows influenced the scaler], font: font("script", style: "italic", fill: red))
    node(below-of("t1", 1.35), [RIGHT], name: "t2", ..tag, text: green)
    node(right-of("t2", 0.35), [Load all data], name: "r1", ..ok)
    node(right-of("r1", 0.5), [Split first], name: "r2", ..ok)
    node(right-of("r2", 0.5), [Fit prep on training only], name: "r3", ..ok)
    node(right-of("r3", 0.5), [Transform test, then evaluate], name: "r4", ..ok)
    connect("r1", "r2", ..arr)
    connect("r2", "r3", ..arr)
    connect("r3", "r4", ..arr)
  })
]

#workedexample[
  How much can leakage inflate a score? Build a table with no signal in it at all: 100 rows, 1,000 columns of random noise, and labels from coin flips. Honest accuracy has to be near 0.5. The listing below picks the 20 columns that look most related to the labels, then cross-validates. It runs the same experiment twice, and only the place where the columns are picked differs.

  #codefrom("/MACHINE LEARNING/all_experiments/book_checks/demo_foundations.py", "# Leakage on pure noise:", "X, y, cv=folds).mean()")

  Picking on all the rows reports 0.80. Picking inside each fold reports 0.52. With a thousand noise columns, some match the coin flips by luck, and the first version tested the model on the very rows that made those columns look good. Nothing in that first run looks broken, which is what makes leakage dangerous.

  Lab~1 shows the other common kind, a column from the future. Deciding before a sales call whether the customer will sign up scores a ROC AUC of 0.80. Adding the call’s duration lifts it to 0.94, a triumph that could never be delivered, because nobody knows how long a call will last before making it.
]

== Missing values: meaning and strategy

A blank cell is a fact about how the data was collected. It may mean the value was never measured, does not apply, cost too much to collect, or is related to the outcome itself.

#utpsteps[
  + Measure how much is missing in each feature and group.
  + Investigate why it is missing and whether the pattern carries information.
  + Choose a treatment and fit it on training rows only (#secref(<sec:data-leakage>)).
  + Add a missing-value indicator when the fact that a value is missing may matter.
  + Check whether the treatment changes important distributions.
]

#workedexample[
  Training ages are 19, 20, 22, 21, 58, 23 and two blanks. The mean is 27.2, a value no student near the center has, because one mature student pulls it up. The median is 21.5, so a median fill stays with the bulk of the group. The test rows are then filled with that same 21.5, even if their own median differs. If blanks turn out to be informative, add a yes/no column saying the age was missing.
]

Use numerical medians, a separate missing category, or model-based imputation when justified.

#term[MCAR]: missing independently of values. #term[MAR]: missingness explained by observed values. #term[MNAR]: missingness depends on unobserved values. The table alone cannot identify the mechanism; investigate causes and compare treatments.

== Encoding categorical features

Most algorithms need numerical inputs, and the encoding must preserve what the category means. Suppose the programme column holds CS, IT and EE. Coding them 1, 2, 3 tells a linear model that EE is three times CS and that IT sits halfway between the other two. Nothing in the world says that. #term[One-hot encoding] gives each category its own yes/no column instead, so CS becomes $(1,0,0)$, IT becomes $(0,1,0)$ and EE becomes $(0,0,1)$.

#utptable[
  #tabularx(
    columns: (35%, 1fr),
    styles: (navy-bold,),
    header: ([Encoding method], [How it works]),
    [One-hot encoding], [Creates one binary column per category. It is a safe default for nominal features with a manageable number of values.],
    [Ordinal encoding], [Uses ordered numbers only when the categories truly have an order.],
    [Frequency encoding], [Replaces a category with how often it appears in training data.],
    [Label-informed mean encoding], [Uses label statistics; apply the leakage rule from #secref(<sec:data-leakage>).],
  )
]

Define how the pipeline handles unseen categories, because a new programme will eventually appear after deployment. All the labs use `OneHotEncoder(handle_unknown="ignore")`, which gives an unseen category all zeros instead of crashing.

== Scaling and transforming numerical features <sec:scaling>

#analogy[
  Ask whether two customers are similar, and measure one column in years and another in dollars. A gap of ten years is 10 and a gap of 500 dollars is 500, so the second gap wins before any judgment has happened. Scaling hands every column the same ruler.
]

Distances, margins, penalties and gradient steps all let large numerical units dominate smaller ones. The change can alter the answer, not just the arithmetic.

#workedexample[
  Three customers, written as (age, income): $A=(30, med 50","000)$, $B=(40, med 90","000)$ and $C=(60, med 52","000)$. Who is nearest to $A$?

  $ d(A,B)=sqrt(10^2+40","000^2)=40","000.00, wide d(A,C)=sqrt(30^2+2","000^2)=2","000.22. $

  In raw units $C$ wins, and age barely counts. Now divide each column by its standard deviation, 20 years and 100,000 dollars:

  $ d(A,B)=sqrt(0.50^2+0.40^2)=0.64, wide d(A,C)=sqrt(1.50^2+0.02^2)=1.50. $

  Now $B$ is nearest. The customers did not change; the measuring stick did. #figref(<fig:scaling-geometry>) draws the $A$--$B$ gap.
]

The three course scalers answer three different questions:

#utptable[
  #tabularx(
    columns: (20%, 29%, 1fr),
    styles: (navy-bold,),
    header: ([Method], [Transformation], [Best first use]),
    [Standard scaling], [$z=(x- mu )\/ sigma$], [General default for SVM, $k$-NN, clustering, and regularized linear models when mean and standard deviation are meaningful.],
    [Min--max scaling], [$x'=(x-x_(min))\/(x_(max)-x_(min))$], [Put a feature into $[0,1]$ when a bounded range is convenient and extreme values are not dominating the observed range.],
    [Robust scaling], [$x'=(x-op("median")(x))\/op("IQR")(x)$], [Data with strong outliers, because the median and interquartile range are less affected by extreme observations.],
  )
]

Fit every scaler on training rows only (#secref(<sec:data-leakage>)).

#workedexample[
  Take the skewed column $[2400, space 36, space 23075, space 70, space 1, space 905]$.

  #strong[Min--max] maps 1 to 0 and 23,075 to 1, which leaves everything else crushed near zero: 905 becomes 0.039 and 2,400 becomes 0.104.

  #strong[Robust scaling] uses the median, 487.5, and the IQR, 1,981.75. Now 2,400 becomes 0.97 and 905 becomes 0.21, so the ordinary values stay spread out, while the extreme one lands at 11.40 and can be seen for what it is.
]

Not every model cares. Trees compare one column to a threshold, so stretching a column changes nothing about the order of its values.

#utptable[
  #tabularx(
    columns: (27%, 20%, 1fr),
    styles: (navy-bold,),
    header: ([Model family], [Scale-sensitive?], [Why]),
    [$k$-NN, $K$-means, DBSCAN], [Usually yes], [Their neighborhoods or clusters are defined by distance.],
    [SVM / SVR], [Usually yes], [Margin and kernel distances depend directly on feature magnitude.],
    [Ridge, lasso, elastic net, logistic regression], [Usually yes], [The penalty compares coefficient sizes across features; unequal units distort that comparison.],
    [Decision trees and tree ensembles], [Usually no], [Splits depend on ordering and thresholds, which monotonic rescaling preserves.],
    [Naive Bayes], [Depends on variant], [Gaussian naive Bayes does not need it; other variants expect counts or binary inputs, so match the preprocessing to the variant.],
  )
]

A $log(1+x)$ or power transform changes the shape of a distribution, while scaling mainly changes units and location. Hotel lead times show why that can matter: across Lab~1’s 119,390 bookings the median lead time is 69 days, the mean 104 and the largest 737, a skew of 1.35. After $log(1+x)$ the skew is $-0.87$: the long right tail is gone, but the transform pulls so hard that the shape now leans the other way. A transform is a choice to check on a histogram, not a cure. Lab~1 keeps both the raw lead time and its log, `log_lead_time`, and lets the model use either.

=== Scaling changes the geometry, drawn

#utpfig([Scaling changes the geometry. Before scaling, raw Euclidean distance is almost entirely the income column; after standardization both features contribute on comparable measuring sticks.], label: <fig:scaling-geometry>)[
  #canvas({
    draw.scope({
      rectangle((0, 0), (6.25, 3.45), rounded: 1mm, fill: mix(pale-red, 30%), draw: none)
      rectangle((0, 0), (6.25, 3.45), rounded: 1mm, draw: mix(red, 45%))
      node((3.125, 3.05), [Before scaling], font: font("small", weight: "bold", fill: navy))
      node((0.35, 2.3), [age gap], font: font("script"), anchor: "west", text: muted)
      connect((2.05, 2.3), (2.85, 2.3), line-width: 4.9813pt, draw: blue)
      node((3.07, 2.3), [$10$ years], font: font("script"), anchor: "west", text: blue)
      node((0.35, 1.48), [income gap], font: font("script"), anchor: "west", text: muted)
      connect((2.05, 1.48), (5.5, 1.48), line-width: 4.9813pt, draw: orange)
      node((5.75, 1.8), [$40","000$ dollars], font: font("script"), anchor: "east", text: orange)
      node((3.125, 0.55), [Raw Euclidean distance is almost entirely the income column.], font: font("script"), align: center, text-width: 5.35, text: red)
    })
    draw.scope({
      draw.translate((6.75, 0))
      rectangle((0, 0), (6.25, 3.45), rounded: 1mm, fill: mix(pale-teal, 45%), draw: none)
      rectangle((0, 0), (6.25, 3.45), rounded: 1mm, draw: mix(teal, 55%))
      node((3.125, 3.05), [After standardization], font: font("small", weight: "bold", fill: navy))
      node((0.35, 2.3), [age gap], font: font("script"), anchor: "west", text: muted)
      connect((2.05, 2.3), (4.5, 2.3), line-width: 4.9813pt, draw: blue)
      node((4.72, 2.3), [$0.50$ SD], font: font("script"), anchor: "west", text: blue)
      node((0.35, 1.48), [income gap], font: font("script"), anchor: "west", text: muted)
      connect((2.05, 1.48), (4.01, 1.48), line-width: 4.9813pt, draw: teal)
      node((4.23, 1.48), [$0.40$ SD], font: font("script"), anchor: "west", text: teal)
      node((3.125, 0.55), [Both features now contribute on comparable measuring sticks.], font: font("script"), align: center, text-width: 5.35, text: green)
    })
    node((6.5, -0.48), [Same observations; different geometry. Scaling changes distance, not the ordering within a feature.], align: center, text-width: 12.5, font: font("script", weight: "bold", fill: navy))
  })
]

#keyidea[
  Changing units can change neighbors, margins, and clusters without changing observations or labels.
]

== Outliers, imbalance, and rare cases

Outliers may be valid rare events or evidence of mixed populations. Investigate before deleting them; learn percentile or IQR cutoffs from training rows only.

Record class counts and retain rare cases. Stratify when random splitting is appropriate.

#keyidea[
  Choose evaluation metrics before an imbalance intervention (#chapref(<ch:evaluation>)). #chapref(<ch:training>) covers weights, thresholds, and resampling, including SMOTE; #chapref(<ch:knn-nb>) explains its neighbor geometry.
]

== Feature engineering

#term[Feature engineering] creates useful inputs from raw data, and it is often the cheapest improvement available. In Lab~1 the same logistic regression on the same split moves from a validation ROC AUC of 0.846 to 0.855 when it is handed the total nights, the number of guests, whether children come along, the log of the lead time, and whether the customer has cancelled before. No new model was needed, and five-fold cross-validation confirms the gain: 0.858 against 0.848.

Every engineered column has to pass the test this chapter has been building. It may use only information that exists at the moment of prediction, and whatever it learns from the data it learns from training rows. #chapref(<ch:feature-engineering>) is devoted to the craft itself: reshaping numbers, encoding dates and large categories, transforming the target, and deciding which features earn their place.

== Use a preprocessing pipeline <sec:preprocessing-pipeline>

A #term[pipeline] joins the preparation steps and the model into one object. When it is fitted, every step learns from the training rows alone. When it predicts, every step reapplies what it learned. It cannot accidentally peek at held-out rows, and it can be saved and reused as one file. Keep feature selection and resampling within training folds too (#chapref(<ch:training>)). All of Labs~1--3 use this one helper, which fills gaps, scales the numbers and one-hot encodes the categories:

#codefrom("/MACHINE LEARNING/all_experiments/lab01_features/lab01_features_worked.py", "def make_preprocess(", "return ColumnTransformer(")

#utpfig([A preprocessing pipeline. Fixed schema and quality rules come before the honest split; every data-dependent step after it is fitted on the training rows only and then reused unchanged.], label: <fig:prep-pipeline>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-height: 0.76, inner-xsep: 4.9813pt, align: center, font: font("script", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [Raw data], name: "raw", ..box-style, min-width: 1.8)
    node(right-of("raw", 0.35), [Fixed schema and quality rules], name: "check", ..box-style, min-width: 3.5)
    node(right-of("check", 0.35), [Honest split], name: "split", ..box-style, min-width: 2.1)
    node(right-of("split", 0.35), [Train-fitted preprocessing], name: "prep", ..box-style, min-width: 3.4)
    node(right-of("prep", 0.35), [Fit model], name: "model", ..box-style, min-width: 1.8)
    connect("raw", "check", ..arr)
    connect("check", "split", ..arr)
    connect("split", "prep", ..arr)
    connect("prep", "model", ..arr)
  })
]

Document the data source, collection period, row definition, feature units, label timing, inclusion rules, split logic, random seed, known bias and privacy limits.

#keyidea[
  Validate the whole pipeline, refitting it inside each cross-validation training fold (#chapref(<ch:evaluation>)).
]

#debugtask[
  A teammate computes median values, standardization statistics, and a label-informed mean encoding on the complete labeled table, then creates the train--test split. Identify every quantity that carried information from the future holdout backward. Rewrite the order of operations in six lines of pseudocode.
]

#chapterrecap[
  - Before modeling, know what one row is, what each column means, when each value becomes available, which rows are related, and who is missing.
  - Fixed rules may run before the split, and they get logged. Anything learned from data is fitted on training rows only.
  - Training is for learning, validation for choosing, and the test set for one final check. The split must imitate how the model will be used, which is why time series split by date.
  - Leakage inflates scores silently. Selecting columns on all the rows made pure noise look 80% accurate.
  - Scale for distance-based and penalized models, one-hot encode categories without an order, and put every step in a pipeline.
]

#quickcheck[
  + Why must train/test splitting happen before any preprocessing step that learns from the data?
  + What is the difference between an identifier, a feature, and a label?
  + Why do you need to know the moment of prediction before you can say whether a feature is leakage?
  + Lab~2’s hotel forest scores ROC AUC 0.841 on a date-order split and 0.911 on a shuffled split. Which number should you report, and why?
  + A column is coded 1 for red, 2 for green, 3 for blue and fed to a linear model. What false assumption has been added?
  + In the three-customer example, which step changed the nearest neighbor of $A$, and did it change any customer?
]
