#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-understanding-and-preparing-data")


#heading(level: 1)[Understanding and Preparing Data]
 <ch:data>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Chapters #ref(label("ch:toolkit"), supplement: none)--#ref(label("ch:orientation"), supplement: none): the workflow, and the difference between features and a target.

*By the end, you can:* assess a table before modeling, log every cleaning rule, choose a split that imitates the future, spot leakage, handle missing values and categories, scale numbers on purpose, engineer features, and keep all of it inside a pipeline.]

A good cook reads the recipe, checks the fridge and washes the vegetables before lighting the stove. Nobody praises that part, and it decides how dinner turns out. Data work is the same: most projects that fail do so before any model is fitted, because the table meant something other than the team assumed, or because the model was quietly shown the answers.

This chapter asks three questions in order. #emph[What does the data mean? What is wrong with it? What is the model allowed to learn from it?]


#heading(level: 2)[Start with a data quality assessment]


Before any model, answer five questions about the table itself. None of them needs code, and each one has sunk real projects.

+ #strong[What does one row represent?] A person, transaction, image, day, machine, or something else?

+ #strong[What does each column mean?] Record its type, unit, valid range, and source.

+ #strong[When is prediction made?] Features must exist then. In Lab~1 a call's duration is known only once the call has ended, and a hotel booking's reservation status only after the guest has cancelled or left.

+ #strong[Which rows are related?] Repeated measurements from one person or device must usually stay in the same split.

+ #strong[Who or what is missing?] The dataset may not represent the full population where the model will be used.


#heading(level: 2)[A safe order of operations]


Some preparation is a fixed rule: a date format, a unit conversion, a typo in a label. It would be done the same way whatever the data said, so it can happen before the split. Other preparation learns something from the data: a median to fill gaps, a mean to scale by. Those steps look at numbers, and they may look only at training rows.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/34d95e99597b0511.cetz.json")], caption: [A safe order of operations: define what the data mean, apply fixed rules, split honestly, and only then learn any preparation from the training rows.]) <fig:safe-order>

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Examples], [Why it belongs there],),
    table.hline(),
    [Before the split], [Validate columns, keys, and values; parse dates; standardize units and whitespace.], [These are fixed rules. They do not use the label or any statistic estimated from the data.],
    [After the split], [Learn imputation, scaling, category mappings, outlier thresholds, feature selection, and resampling rules.], [Fit data-dependent choices on training rows only.],
    [After modeling], [Evaluate test performance once, document limits, and monitor data quality and drift.], [Keep the test set for final evaluation, not design decisions.],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Fixed rules, such as unit conversions, may precede splitting. Estimate medians, scales, category mappings, and cutoffs from training rows only.]


#heading(level: 2)[Feature and label types]


The type of a column decides how a model can use it. A number can go in almost as it is. A word has to be turned into numbers first, and the way you do that can invent an order that was never there.

#block[
lll

Type & Example & Typical treatment \
Numerical & age, temperature, income & keep numeric; scale or transform when needed Nominal category & country, product type & one-hot encode or use a model that handles categories Ordinal category & low, medium, high & encode in the true order, but do not assume equal gaps without reason Date or time & purchase date, hour & extract useful parts such as elapsed time, weekday, or season Text & review, message & convert to numerical counts or other classical text features

]

Labels usually fall into two basic groups:

- A #strong[continuous number] suggests regression, such as price or temperature.

- A #strong[category] suggests classification, such as fraud/not fraud or animal species.


#heading(level: 2)[Clean structural problems before modeling]
 <sec:cleaning>

Make stored values match their documented meaning using reproducible code, so that anyone can rerun the cleaning and see what it changed. Here is a small messy extract of a student table. It has one duplicated student, an age of $- 1$, study hours written as the word `five`, stray spaces, a programme spelled two ways, and one suspicious 30 hours.

#source-code("/MACHINE LEARNING/all_experiments/book_checks/demo_foundations.py", first: 39, last: 61, lang: "python")

Running it prints the cleaned table and, more importantly, the log:

#code-block("student_id  age  hours programme  mark  hours_suspicious\n        101 19.0    6.0        CS    58             False\n        102 20.0    8.0        CS    64             False\n        103  NaN   30.0        IT    71              True\n        104 22.0    4.0        IT    49             False\n        105  NaN    NaN        CS    66             False\n{'rows in': 6, 'duplicate rows dropped': 1, 'hours that would not parse': 1,\n 'impossible ages set to missing': 1, 'unusual hours flagged': 1, 'rows out': 5}", lang: "text")

Notice what the code did not do. It never used the mark to decide anything, and it did not delete the student who claimed 30 hours. That value is unusual, not impossible, so it gets a flag and stays.


#heading(level: 3)[Confirm row identity and handle duplicates]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Pattern], [What it may mean], [Safe response],),
    table.hline(),
    [Exact repeated row], [Duplicate import or distinct events lacking identifiers], [Remove only if repetition is meaningless; log the count.],
    [Repeated key], [Key conflict, multiple versions, or valid one-to-many data], [Investigate: keep the latest, aggregate, repair the key, or redefine rows.],
    [Same person, different visits], [Valid repeated measurements], [Keep rows; group splits by person to prevent overlap.],
    [Near duplicate], [Spelling, rounding, or record-linkage differences], [Define matching rules and review uncertain matches.],
  )]
  , kind: table
  )


#heading(level: 3)[Repair types, labels, dates, and units]


+ #strong[Preserve the raw value.] Keep the source file unchanged and create a cleaned copy or scripted transformation.

+ #strong[Parse explicitly.] Convert numbers and dates with known rules, and count values that fail to parse.

+ #strong[Normalize representation.] Trim accidental whitespace, standardize case where case has no meaning, and map documented synonyms to one label.

+ #strong[Normalize units.] Convert to one stated unit using a known conversion; never mix unit conversion with statistical scaling.

+ #strong[Validate the result.] Check allowed categories, ranges, key uniqueness, and date order with assertions.


#heading(level: 3)[Distinguish impossible values from unusual values]


An age of $- 1$ breaks a rule of the world, so it is an #strong[impossible value]. A very large purchase may be perfectly real, so it is only a #strong[rare value]. They call for different responses.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Action], [When to use it],),
    table.hline(),
    [Correct], [Only when an authoritative source or deterministic rule reveals the true value.],
    [Set missing], [When the stored value is known to be invalid but the true value is unknown. Impute later inside the training pipeline if appropriate.],
    [Drop], [When the row cannot answer the project question and a documented inclusion rule justifies removal. Report the count and check whether exclusions are concentrated in a group.],
    [Flag], [When a suspicious value may still be real. A binary quality flag lets the model or analyst retain that information.],
    [Keep], [When a value is valid, even if it is inconvenient. Rare cases may be exactly where a useful model is most needed.],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[Do not remove difficult cases merely to improve scores; they may occur after deployment.]


#heading(level: 3)[Keep a cleaning log]


Log each rule's reason, columns, affected row count and action: correction, missingness, exclusion or flagging. Retain identifiers for tracing changes, not as model features.


#heading(level: 2)[Training, validation, and test sets]
 <sec:data-splits>

#callout("analogy", title: [Analogy])[Think of how a student prepares for a final. Worked past papers are for learning. A mock exam tells you which study method works best, and you may sit it more than once, which is why it slowly stops being a fair test. The final is sat once, and its score is the one that counts. Those are the training, validation and test sets.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/185eaadb9d6f3f21.cetz.json")], caption: [The three splits and their jobs: the training set learns parameters, the validation set chooses settings, and the test set gives the final check.]) <fig:three-splits>

/ Training set: #block[
Used to fit model parameters and data-dependent preprocessing steps.
]

/ Validation set: #block[
Used to compare models, thresholds, and hyperparameters.
]

/ Test set: #block[
Used only for the final estimate after all choices are complete.
]

Training often uses 60--80% of rows. Choose proportions for dataset size while preserving separate validation and test roles.

#callout("pitfall", title: [Common mistake])[If you look at the test score and then change anything, the test set has become a second validation set, and its score is no longer a fair estimate. Decide what the test set is for, seal it, and open it once.]


#heading(level: 2)[Choose a split that imitates the future]


A random split is honest only when future rows are independent of past rows and drawn the same way. Ask how the model will really be used, and make the split imitate that.

/ Stratified split: #block[
Keeps class proportions similar across subsets.
]

/ Group split: #block[
Keeps all rows from one person, device, school, or customer in one subset.
]

/ Time split: #block[
Trains on the past and evaluates on later periods.
]

/ Spatial split: #block[
Separates locations when nearby observations are strongly related.
]

#callout("workedexample", title: [Worked example])[#strong[Patients.] With five visits per patient, a random row split lets the model meet the same patient in training and in validation. It may then recognize patients rather than learn medicine. Group by patient when the model is meant for new patients.

#strong[Hotel bookings.] Lab~2's cancellation forest scores ROC AUC 0.841 when it trains on arrivals up to the end of 2016 and predicts 2017, which is how a hotel would really use it. Shuffle the bookings first, and the same model on the same data scores 0.911. It looks better only because it was allowed to train on bookings from the very weeks it predicts: 9,366 of the 29,848 shuffled validation bookings have an exact twin among the training rows.]

#callout("pitfall", title: [Common mistake])[An unrealistic split gives an unrealistic performance estimate, and nothing downstream can repair that.]


#heading(level: 2)[Data leakage]
 <sec:data-leakage>

#callout("analogy", title: [Analogy])[A class scores 95% on an exam. It later turns out that the paper circulated the night before. The score was real, but it measured the wrong thing, and it predicts nothing about next year. #strong[Data leakage] is the same accident: information the model would not have at prediction time, or information from the held-out rows, finds its way into the features, the preprocessing, the choice of model, or the split.]

Examples include:

- predicting hospital readmission using a field recorded after discharge;

- calculating the mean for standardization using the entire dataset;

- selecting features using test-set performance;

- placing near-duplicate rows in both training and test data;

- using future values to predict an earlier point in time;

- including an identifier or proxy that effectively reveals the label, such as a claim-resolution code when predicting whether a claim will be approved.

The safe rule is simple: fit every data-dependent choice on training data only, then apply the learned transformation unchanged to validation and test data.

The diagram contrasts fitting the preprocessing before and after the split. Only the training rows should decide what a fitted transformation does.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/1dc6e61fb40d0b90.cetz.json")], caption: [Leakage through preprocessing. Fitting the preparation on all the data lets the test rows influence the scaler; splitting first and fitting on the training rows only keeps the test honest.]) <fig:prep-leakage>

#callout("workedexample", title: [Worked example])[How much can leakage inflate a score? Build a table with no signal in it at all: 100 rows, 1,000 columns of random noise, and labels from coin flips. Honest accuracy has to be near 0.5. The listing below picks the 20 columns that look most related to the labels, then cross-validates. It runs the same experiment twice, and only the place where the columns are picked differs.

#source-code("/MACHINE LEARNING/all_experiments/book_checks/demo_foundations.py", first: 100, last: 108, lang: "python")

Picking on all the rows reports 0.80. Picking inside each fold reports 0.52. With a thousand noise columns, some match the coin flips by luck, and the first version tested the model on the very rows that made those columns look good. Nothing in that first run looks broken, which is what makes leakage dangerous.

Lab~1 shows the other common kind, a column from the future. Deciding before a sales call whether the customer will sign up scores a ROC AUC of 0.80. Adding the call's duration lifts it to 0.94, a triumph that could never be delivered, because nobody knows how long a call will last before making it.]


#heading(level: 2)[Missing values: meaning and strategy]


A blank cell is a fact about how the data was collected. It may mean the value was never measured, does not apply, cost too much to collect, or is related to the outcome itself.

+ Measure how much is missing in each feature and group.

+ Investigate why it is missing and whether the pattern carries information.

+ Choose a treatment and fit it on training rows only (#ref(label("sec:data-leakage"), supplement: [Section])).

+ Add a missing-value indicator when the fact that a value is missing may matter.

+ Check whether the treatment changes important distributions.

#callout("workedexample", title: [Worked example])[Training ages are 19, 20, 22, 21, 58, 23 and two blanks. The mean is 27.2, a value no student near the center has, because one mature student pulls it up. The median is 21.5, so a median fill stays with the bulk of the group. The test rows are then filled with that same 21.5, even if their own median differs. If blanks turn out to be informative, add a yes/no column saying the age was missing.]

Use numerical medians, a separate missing category, or model-based imputation when justified.

#strong[MCAR]: missing independently of values. #strong[MAR]: missingness explained by observed values. #strong[MNAR]: missingness depends on unobserved values. The table alone cannot identify the mechanism; investigate causes and compare treatments.


#heading(level: 2)[Encoding categorical features]


Most algorithms need numerical inputs, and the encoding must preserve what the category means. Suppose the programme column holds CS, IT and EE. Coding them 1, 2, 3 tells a linear model that EE is three times CS and that IT sits halfway between the other two. Nothing in the world says that. #strong[One-hot encoding] gives each category its own yes/no column instead, so CS becomes $\( 1 \, 0 \, 0 \)$, IT becomes $\( 0 \, 1 \, 0 \)$ and EE becomes $\( 0 \, 0 \, 1 \)$.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Encoding method], [How it works],),
    table.hline(),
    [One-hot encoding], [Creates one binary column per category. It is a safe default for nominal features with a manageable number of values.],
    [Ordinal encoding], [Uses ordered numbers only when the categories truly have an order.],
    [Frequency encoding], [Replaces a category with how often it appears in training data.],
    [Label-informed mean encoding], [Uses label statistics; apply the leakage rule from #ref(label("sec:data-leakage"), supplement: [Section]).],
  )]
  , kind: table
  )

Define how the pipeline handles unseen categories, because a new programme will eventually appear after deployment. All the labs use `OneHotEncoder(handle_unknown="ignore")`, which gives an unseen category all zeros instead of crashing.


#heading(level: 2)[Scaling and transforming numerical features]
 <sec:scaling>

#callout("analogy", title: [Analogy])[Ask whether two customers are similar, and measure one column in years and another in dollars. A gap of ten years is 10 and a gap of 500 dollars is 500, so the second gap wins before any judgment has happened. Scaling hands every column the same ruler.]

Distances, margins, penalties and gradient steps all let large numerical units dominate smaller ones. The change can alter the answer, not just the arithmetic.

#callout("workedexample", title: [Worked example])[Three customers, written as (age, income): $A = \( 30 \, #h(0em) 50 \, 000 \)$, $B = \( 40 \, #h(0em) 90 \, 000 \)$ and $C = \( 60 \, #h(0em) 52 \, 000 \)$. Who is nearest to $A$? $ d \( A \, B \) = sqrt(10^2 + 40 \, 000^2) = 40 \, 000.00 \, #h(2em) d \( A \, C \) = sqrt(30^2 + 2 \, 000^2) = 2 \, 000.22 . $ In raw units $C$ wins, and age barely counts. Now divide each column by its standard deviation, 20 years and 100,000 dollars: $ d \( A \, B \) = sqrt(0.50^2 + 0.40^2) = 0.64 \, #h(2em) d \( A \, C \) = sqrt(1.50^2 + 0.02^2) = 1.50 . $ Now $B$ is nearest. The customers did not change; the measuring stick did. #ref(label("fig:scaling-geometry"), supplement: [Figure]) draws the $A$--$B$ gap.]

The three course scalers answer three different questions:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Method], [Transformation], [Best first use],),
    table.hline(),
    [Standard scaling], [$z = \( x - mu \) \/ sigma$], [General default for SVM, $k$-NN, clustering, and regularized linear models when mean and standard deviation are meaningful.],
    [Min--max scaling], [$x' = \( x - x_min \) \/ \( x_max - x_min \)$], [Put a feature into $\[ 0 \, 1 \]$ when a bounded range is convenient and extreme values are not dominating the observed range.],
    [Robust scaling], [$x' = \( x - "median" \( x \) \) \/ "IQR" \( x \)$], [Data with strong outliers, because the median and interquartile range are less affected by extreme observations.],
  )]
  , kind: table
  )

Fit every scaler on training rows only (#ref(label("sec:data-leakage"), supplement: [Section])).

#callout("workedexample", title: [Worked example])[Take the skewed column $\[ 2400 \, med 36 \, med 23075 \, med 70 \, med 1 \, med 905 \]$.

#strong[Min--max] maps 1 to 0 and 23,075 to 1, which leaves everything else crushed near zero: 905 becomes 0.039 and 2,400 becomes 0.104.

#strong[Robust scaling] uses the median, 487.5, and the IQR, 1,981.75. Now 2,400 becomes 0.97 and 905 becomes 0.21, so the ordinary values stay spread out, while the extreme one lands at 11.40 and can be seen for what it is.]

Not every model cares. Trees compare one column to a threshold, so stretching a column changes nothing about the order of its values.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Model family], [Scale-sensitive?], [Why],),
    table.hline(),
    [$k$-NN, $K$-means, DBSCAN], [Usually yes], [Their neighborhoods or clusters are defined by distance.],
    [SVM / SVR], [Usually yes], [Margin and kernel distances depend directly on feature magnitude.],
    [Ridge, lasso, elastic net, logistic regression], [Usually yes], [The penalty compares coefficient sizes across features; unequal units distort that comparison.],
    [Decision trees and tree ensembles], [Usually no], [Splits depend on ordering and thresholds, which monotonic rescaling preserves.],
    [Naive Bayes], [Depends on variant], [Gaussian naive Bayes does not need it; other variants expect counts or binary inputs, so match the preprocessing to the variant.],
  )]
  , kind: table
  )

A $log \( 1 + x \)$ or power transform changes the shape of a distribution, while scaling mainly changes units and location. Hotel lead times show why that can matter: across Lab~1's 119,390 bookings the median lead time is 69 days, the mean 104 and the largest 737, a skew of 1.35. After $log \( 1 + x \)$ the skew is $- 0.87$: the long right tail is gone, but the transform pulls so hard that the shape now leans the other way. A transform is a choice to check on a histogram, not a cure. Lab~1 keeps both the raw lead time and its log, `log_lead_time`, and lets the model use either.


#heading(level: 3)[Scaling changes the geometry, drawn]


#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/36a72217c5399dd5.cetz.json")], caption: [Scaling changes the geometry. Before scaling, raw Euclidean distance is almost entirely the income column; after standardization both features contribute on comparable measuring sticks.]) <fig:scaling-geometry>

#callout("keyidea", title: [Key idea])[Changing units can change neighbors, margins, and clusters without changing observations or labels.]


#heading(level: 2)[Outliers, imbalance, and rare cases]


Outliers may be valid rare events or evidence of mixed populations. Investigate before deleting them; learn percentile or IQR cutoffs from training rows only.

Record class counts and retain rare cases. Stratify when random splitting is appropriate.

#callout("keyidea", title: [Key idea])[Choose evaluation metrics before an imbalance intervention (#ref(label("ch:evaluation"), supplement: [Chapter])). #ref(label("ch:training"), supplement: [Chapter]) covers weights, thresholds, and resampling, including SMOTE; #ref(label("ch:knn-nb"), supplement: [Chapter]) explains its neighbor geometry.]


#heading(level: 2)[Feature engineering]


#strong[Feature engineering] creates useful inputs from raw data, and it is often the cheapest improvement available. In Lab~1 the same logistic regression on the same split moves from a validation ROC AUC of 0.846 to 0.855 when it is handed the total nights, the number of guests, whether children come along, the log of the lead time, and whether the customer has cancelled before. No new model was needed, and five-fold cross-validation confirms the gain: 0.858 against 0.848. Typical ideas include:

- price per unit, body-mass index, or another meaningful ratio;

- elapsed time between two dates;

- weekday, month, or cyclical time features;

- interactions such as area multiplied by location score;

- counts or averages from past behavior, calculated without using the future.


#heading(level: 3, numbering: none)[Feature engineering by data type]
 Choose transformations that preserve meaning and use only prediction-time information.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Data type], [Common transformation ideas], [Main safety question],),
    table.hline(),
    [Categorical], [One-hot or ordinal encoding; rare-category grouping], [Does encoding respect category order and use training-only mappings?],
    [Numeric], [Logs, powers, ratios, interactions, polynomials, scaling], [Are units and meaning respected, with parameters fitted on training data only?],
    [Temporal], [Lags, elapsed time, rolling summaries, seasonality], [Were all inputs available at prediction time?],
    [Text or images], [Counts, embeddings, handcrafted or learned features], [Is task-relevant structure retained without label or future leakage?],
  )]
  , kind: table
  )


#heading(level: 3)[A safety test for engineered features]
 For each derived feature, ask what information it uses and when that information becomes available.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Feature type], [Example], [Safe treatment],),
    table.hline(),
    [Deterministic], [BMI from height and weight; hour from timestamp], [Compute reproducibly from legitimately available inputs.],
    [Distribution-fitted], [Power transforms, frequency encoding, clipping, category grouping], [Fit on training rows only, usually in a pipeline.],
    [Label-aware], [Mean encoding, supervised selection, label-based category merging], [Fit within training folds, never on all labels before validation (#ref(label("ch:training"), supplement: [Chapter])).],
    [Temporal aggregate], [Lags, rolling means, prior-week counts], [Use only data available at prediction time; never fill past gaps with future values.],
  )]
  , kind: table
  )


#heading(level: 2)[Use a preprocessing pipeline]
 <sec:preprocessing-pipeline>

A #strong[pipeline] joins the preparation steps and the model into one object. When it is fitted, every step learns from the training rows alone. When it predicts, every step reapplies what it learned. It cannot accidentally peek at held-out rows, and it can be saved and reused as one file. Keep feature selection and resampling within training folds too (#ref(label("ch:training"), supplement: [Chapter])). All of Labs~1--3 use this one helper, which fills gaps, scales the numbers and one-hot encodes the categories:

#source-code("/MACHINE LEARNING/all_experiments/lab01_features/lab01_features_worked.py", first: 92, last: 102, lang: "python")

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/cf241a713984eb00.cetz.json")], caption: [A preprocessing pipeline. Fixed schema and quality rules come before the honest split; every data-dependent step after it is fitted on the training rows only and then reused unchanged.]) <fig:prep-pipeline>

Document the data source, collection period, row definition, feature units, label timing, inclusion rules, split logic, random seed, known bias and privacy limits.

#callout("keyidea", title: [Key idea])[Validate the whole pipeline, refitting it inside each cross-validation training fold (#ref(label("ch:evaluation"), supplement: [Chapter])).]

#callout("debugtask", title: [Debugging task])[A teammate computes median values, standardization statistics, and a label-informed mean encoding on the complete labeled table, then creates the train--test split. Identify every quantity that carried information from the future holdout backward. Rewrite the order of operations in six lines of pseudocode.]

#callout("chapterrecap", title: [Chapter recap])[- Before modeling, know what one row is, what each column means, when each value becomes available, which rows are related, and who is missing.

- Fixed rules may run before the split, and they get logged. Anything learned from data is fitted on training rows only.

- Training is for learning, validation for choosing, and the test set for one final check. The split must imitate how the model will be used, which is why time series split by date.

- Leakage inflates scores silently. Selecting columns on all the rows made pure noise look 80% accurate.

- Scale for distance-based and penalized models, one-hot encode categories without an order, and put every step in a pipeline.]

#callout("quickcheck", title: [Check your understanding])[+ Why must train/test splitting happen before any preprocessing step that learns from the data?

+ What is the difference between an identifier, a feature, and a label?

+ Why do you need to know the moment of prediction before you can say whether a feature is leakage?

+ Lab~2's hotel forest scores ROC AUC 0.841 on a date-order split and 0.911 on a shuffled split. Which number should you report, and why?

+ A column is coded 1 for red, 2 for green, 3 for blue and fed to a linear model. What false assumption has been added?

+ In the three-customer example, which step changed the nearest neighbor of $A$, and did it change any customer?]
