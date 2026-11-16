#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "06-exploratory-data-analysis")

#let explore = "/MACHINE LEARNING/all_experiments/book_checks/demo_exploration.py"

= Exploratory Data Analysis <ch:eda>

#chapterguide[#chapref(<ch:pydata>): masks, `groupby` and the five everyday charts. #chapref(<ch:data>): what a row is, the three splits, and leakage.][run the first look at any table; study one column at a time and catch a value that cannot be true; read a box plot and its fences; compare a feature with the target and with other features; tell an informative gap from a random one; and turn what you saw into a short list of decisions.]

A doctor does not prescribe from a form. She looks at the patient, asks a few questions, and notices the thing the form left out. #term[Exploratory data analysis], EDA for short, is that examination, carried out on a table before any model is fitted. Its product is a short list of decisions: this column needs repair, that one cannot be trusted, these two say the same thing, this pattern is worth a feature.

This chapter runs one complete examination on one table, 918 patients tested for heart disease, and every number in it comes from `all_experiments/book_checks/demo_exploration.py`. Lab~0 repeats the examination step by step in a notebook.

== The loop: ask, look, note, decide

EDA has a reputation for being aimless: draw every chart and hope. It works better as a loop with four beats (#figref(<fig:eda-loop>)). You ask a plain question, pick the summary or chart that answers it, write down what you saw in one sentence, and decide what to do about it. The decision often raises the next question.

#utpfig([The loop of an exploration. Each pass ends in a written decision, and the list of decisions is what the exploration hands to the modelling stage.], label: <fig:eda-loop>)[
  #canvas({
    let step = (..utpbox, text-width: 2.75, min-height: 1.3)
    node((0, 0), [#strong[1\. Ask] \ one plain question about the table], name: "a", font: font("small"), ..step)
    node((3.75, 0), [#strong[2\. Look] \ the summary or chart that answers it], name: "b", font: font("small"), ..step)
    node((7.5, 0), [#strong[3\. Note] \ what you saw, in one sentence], name: "c", font: font("small"), ..step)
    node((11.25, 0), [#strong[4\. Decide] \ repair, flag, drop, engineer or leave], name: "d", font: font("small"), ..step, fill: pale-orange, draw: orange)
    connect("a", "b", ..utparrow)
    connect("b", "c", ..utparrow)
    connect("c", "d", ..utparrow)
    connect("d.south", (rel: (0, -0.6), to: "d.south"), "-|", "a.south", ..utparrow)
    node((5.6, -1.45), [the decision raises the next question], font: font("small"), ..utplabel, fill: white)
  })
]

The questions come in a fixed order, from the whole table inwards:

#utpsteps[
  + #term[The table.] How big is it, what is a row, what type is each column, and is anything blank or repeated?
  + #term[One column at a time.] Where do its values sit, how far do they spread, and are any of them impossible?
  + #term[Each column against the target.] Does knowing this column change what you expect of the answer?
  + #term[Columns against each other.] Which columns move together, and which carry the same information twice?
  + #term[The decisions.] What goes into the pipeline, and what does the first model have to beat?
]

== The first look

The table has one row per patient and twelve columns. Its data card, `all_datasets/supervised/heart_disease/README.md`, says what each column means and in which units, and it is read before the data. Five columns are measurements: age, resting blood pressure, cholesterol, the highest heart rate reached in an exercise test, and `Oldpeak`, a reading from the heart trace during that test. Six are categories, such as the type of chest pain. `HeartDisease` is the target.

#codefrom(explore, "def first_look(heart):", "print(\"zeros:\"")

```terminal
shape: (918, 12)  blank cells: 0  repeated rows: 0
distinct values: {'Age': 50, 'Sex': 2, 'ChestPainType': 4, 'RestingBP': 67, 'Cholesterol': 222,
                  'FastingBS': 2, 'RestingECG': 3, 'MaxHR': 119, 'ExerciseAngina': 2, 'Oldpeak': 53,
                  'ST_Slope': 3, 'HeartDisease': 2}
      Age  RestingBP  Cholesterol  MaxHR  Oldpeak
min  28.0        0.0          0.0   60.0     -2.6
50%  54.0      130.0        223.0  138.0      0.6
max  77.0      200.0        603.0  202.0      6.2
zeros: {'RestingBP': 1, 'Cholesterol': 172}  negative Oldpeak: 13
```

Three observations come out of ten lines of output, and each one is a decision.

#utptable[
  #tabularx(
    columns: (40%, 1fr),
    header: ([What the first look shows], [The decision]),
    [No blank cells and no repeated rows.], [Nothing to drop. Be suspicious anyway: a table this tidy has usually been filled in by someone.],
    [`FastingBS` holds numbers but only two distinct values.], [It is a yes/no category stored as 0 and 1. The count of distinct values, not the type, says how to treat a column.],
    [The smallest blood pressure and the smallest cholesterol are 0.], [Nobody alive has either. One blood pressure and 172 cholesterol values, 18.7% of the column, are zeros that mean "not measured".],
  )
]

That last row is the most useful single habit in this chapter: #emph[read the minimum and the maximum of every number column and ask whether a person, a price or a date could really have that value.] A blank cell announces itself. A zero, a 999, a `-1` or a date in 1900 hides in plain sight and is averaged along with everything else. Lab~1’s bank table hides its gaps the same way, as the word `unknown` and the number 999.

The repair is a fixed rule that comes from the meaning of the column, not from any statistic, so it may run before the split (#secref(<sec:cleaning>)).

#codefrom(explore, "def mark_missing(heart):", "return cleaned")

#note[
  A value that cannot be true is a missing value in disguise. Find it with the minimum and the maximum, mark it as missing, and let the pipeline fill it later, where the fill is learned from training rows only.
]

=== Seal the test set before you look further

Everything up to here asked what the columns #emph[are]. From here on the questions are about how the columns relate to the answer, and those relationships are exactly what a model will learn. If you study them on every row, your choices of features and repairs have seen the test rows, and the final score flatters them. So the test set is sealed now, and the rest of this chapter looks at the 734 training patients only.

```terminal
training rows: 734  test rows: 184  disease rate in training: 0.553
```

A model that always answers "disease" is right 55.3% of the time. That is the number every later idea has to beat.

== One column at a time

=== A number column: the picture and the summary disagree

Summaries compress a column into a few numbers. A histogram shows all of it. When the two disagree, believe the histogram.

#utpfig([Cholesterol of the 734 training patients, in bands of 50 mg/dl. The spike on the left is 129 patients recorded as 0. A summary of the column mixes those zeros in: it reports a mean of 203.2, a value in the thin left tail of the real readings, whose mean is 246.6.], label: <fig:chol-hist>)[
  #canvas({
    axis(width: 12.6cm, height: 5.2cm, ..logaxis, xlabel: [cholesterol (mg/dl)], ylabel: [patients], ybar: auto, bar-width: 20pt, xmin: -20, xmax: 660, ymin: 0, ymax: 260, xtick: (0, 100, 200, 300, 400, 500, 600), ytick: (0, 50, 100, 150, 200, 250),
      addplot(fill: pale-blue, draw: blue, coords: ((75, 1), (125, 16), (175, 92), (225, 236), (275, 170), (325, 67), (375, 12), (425, 4), (475, 4), (525, 1), (575, 1), (625, 1))),
      {
        rectangle((3, 0), (47, 129), fill: pale-red, draw: red)
        node((58, 150), [129 patients at 0: \ not measured], font: font("script", fill: red), anchor: "west", align: left)
        connect((203.2, 0), (203.2, 250), dash: "dashed", draw: orange, line-width: widths.thick)
        node((198, 252), [mean with zeros 203.2], font: font("script", fill: orange), anchor: "east")
        connect((246.6, 0), (246.6, 250), dash: "dashed", draw: teal, line-width: widths.thick)
        node((252, 252), [mean of real readings 246.6], font: font("script", fill: teal), anchor: "west")
      },
    )
  })
]

```terminal
Cholesterol with the zeros:    {'mean': 203.2, '50%': 225.0, 'min': 0.0}  skew -0.64
Cholesterol, zeros as missing: {'count': 605.0, 'mean': 246.6, '50%': 238.0, 'min': 85.0}  skew 1.24
```

Marking the zeros as missing moves the mean by 43 mg/dl and reverses the direction of the skew. With the zeros the column appears to have a long tail to the left; without them the tail is on the right, where a few patients have very high cholesterol. A fill value, a scaler and an outlier rule computed on the first version would all have been computed on a column that does not exist.

=== The five-number summary and the box plot

Five numbers describe a column without assuming any shape: the minimum, the first quartile $Q_1$, the median, the third quartile $Q_3$ and the maximum. #chapref(<ch:foundations>) defined the quartiles and the interquartile range. A #term[box plot] draws them. The box runs from $Q_1$ to $Q_3$ and so holds the middle half of the values, and the line inside it is the median.

Two #term[fences] are then placed one and a half box-lengths beyond the box:

$ "low fence" = Q_1 - 1.5 times op("IQR"), wide "high fence" = Q_3 + 1.5 times op("IQR"), wide op("IQR") = Q_3 - Q_1. $

The whiskers reach out to the last real value inside each fence, and every value beyond a fence is drawn as its own dot.

#example[
  For the 605 measured cholesterol values, $Q_1 = 210$, the median is 238 and $Q_3 = 277$, so $op("IQR") = 67$.

  $ "low fence" = 210 - 1.5 times 67 = 109.5, wide "high fence" = 277 + 1.5 times 67 = 377.5. $

  The whiskers stop at 113 and 369, the last readings inside the fences. Three patients lie below the low fence and seventeen above the high one. #figref(<fig:boxplot>) draws all of it.
]

#utpfig([A box plot of the 605 measured cholesterol values, with every part named. The twenty dots are real patients. The fences themselves are not drawn on an ordinary box plot; they are shown here because they decide where the whiskers stop.], label: <fig:boxplot>)[
  #canvas({
    let x(v) = (v - 60) / 560 * 13.4
    let y0 = 0
    // axis
    connect((x(60), -1.75), (x(620), -1.75), draw: muted)
    for v in (100, 200, 300, 400, 500, 600) {
      connect((x(v), -1.75), (x(v), -1.85), draw: muted)
      node((x(v), -2.1), [#v], font: font("script", fill: muted))
    }
    node((x(340), -2.6), [cholesterol (mg/dl)], font: font("script", fill: navy))
    // fences
    connect((x(109.5), -0.75), (x(109.5), 0.75), dash: "dashed", draw: mix(red, 70%))
    connect((x(377.5), -0.75), (x(377.5), 0.75), dash: "dashed", draw: mix(red, 70%))
    node((x(109.5), 1.0), [low fence 109.5], font: font("script", fill: red))
    node((x(377.5), 1.0), [high fence 377.5], font: font("script", fill: red))
    // whiskers and box
    connect((x(113), y0), (x(210), y0), draw: blue, line-width: widths.thick)
    connect((x(277), y0), (x(369), y0), draw: blue, line-width: widths.thick)
    connect((x(113), -0.22), (x(113), 0.22), draw: blue, line-width: widths.thick)
    connect((x(369), -0.22), (x(369), 0.22), draw: blue, line-width: widths.thick)
    rectangle((x(210), -0.45), (x(277), 0.45), fill: pale-blue, draw: blue, line-width: widths.thick)
    connect((x(238), -0.45), (x(238), 0.45), draw: orange, line-width: widths.very-thick)
    // outside points
    for v in (85, 100, 100.01, 384, 385, 392, 393, 394, 394.01, 407, 409, 412, 417, 458, 466, 468, 491, 529, 564, 603) {
      circle-at((x(v), y0), 1.5pt, draw: red, fill: white, line-width: 0.7pt)
    }
    // labels
    node((x(210), -0.72), [$Q_1$ 210], font: font("script", fill: navy))
    node((x(250), 0.72), [median 238], font: font("script", fill: orange))
    node((x(285), -0.72), [$Q_3$ 277], font: font("script", fill: navy))
    node((x(160), 0.35), [whisker], font: font("script", fill: blue))
    node((x(490), 0.42), [17 values beyond the fence], font: font("script", fill: red))
    node((x(88), -0.42), [3], font: font("script", fill: red))
    brace((x(210), -0.98), (x(277), -0.98), ..utpbrace, mirror: true)
    node((x(243), -1.22), [IQR 67: the middle half of the patients], font: font("script", fill: muted), anchor: "north")
  })
]

A rival rule flags any value more than three standard deviations from the mean. The two rules disagree, because the mean and the standard deviation are themselves dragged about by the extreme values they are supposed to judge.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Column], [$Q_1$], [Median], [$Q_3$], [Skew], [Outside the fences], [Beyond 3 SD]),
    [Age], [47], [55], [61], [$-0.21$], [0], [0],
    [RestingBP], [120], [130], [141], [0.63], [20], [6],
    [Cholesterol], [210], [238], [277], [1.24], [20], [7],
    [MaxHR], [119], [138], [156], [$-0.19$], [2], [0],
    [Oldpeak], [0.0], [0.5], [1.5], [0.95], [13], [6],
  )
]

#warning[
  A point beyond a fence is a point to look at, not a point to delete. The 17 high cholesterol readings are real patients, and several of them are exactly the people a heart-disease model exists for. Remove a value only when it is impossible, as the zeros were. For a value that is merely extreme, the gentler tools are a transform that pulls the tail in (#chapref(<ch:feature-engineering>)), a robust scaler (#secref(<sec:scaling>)), or a cap at a percentile learned from the training rows.
]

=== Skew, in one number

#term[Skewness] is zero for a symmetric column, positive when the long tail points right and negative when it points left. As a rough guide, a value beyond $plus.minus 1$ is strong. Cholesterol at 1.24 and `Oldpeak` at 0.95 lean right, and the other three are close to symmetric. Skew matters most to models that average or measure distances, because a long tail gives a handful of rows most of the influence.

`Oldpeak` teaches a second lesson: 41.4% of its training values are exactly 0. A column with a pile at one value and a tail beyond it is two facts in one, "was there any drop at all?" and "how large was it?", and it is often worth offering a model both.

=== A category column: counts first

For a category the summary is a count per value, and the questions are different. Are two values really one, spelled two ways? Is any value so rare that a rate computed from it will be mostly luck? Chest pain type has four values among the training patients: 403 with no chest pain, 155 with non-anginal pain, 136 with atypical angina and 40 with typical angina. That last group is 5.4% of the table, and it will matter in a moment.

== Each column against the target

Now the question changes from "what does this column look like?" to "does it tell me anything about the answer?".

=== A number against a yes/no target

Split the patients by the target and compare the column in the two groups.

```terminal
                 Age  RestingBP  Cholesterol   MaxHR  Oldpeak
HeartDisease
0             51.28     130.82       241.91  148.07     0.42
1             55.92     134.53       251.61  126.93     1.22
```

Patients with heart disease are older by about five years, reach a top heart rate 21 beats lower, and have an `Oldpeak` nearly three times as large. Blood pressure and cholesterol hardly differ. Averages can hide almost anything, though, so draw the two groups on one chart (#figref(<fig:maxhr-groups>)).

#utpfig([Highest heart rate reached, for training patients with and without heart disease. The two groups are shifted, not separated: below about 120 beats most patients have the disease, above about 150 most do not, and in between the column alone cannot say.], label: <fig:maxhr-groups>)[
  #canvas({
    axis(width: 12.6cm, height: 5cm, ..logaxis, xlabel: [highest heart rate in the exercise test (beats per minute)], ylabel: [patients], xmin: 55, xmax: 215, ymin: 0, ymax: 120, xtick: (60, 90, 120, 150, 180, 210), ytick: (0, 30, 60, 90, 120),
      addplot(draw: orange, mark: "*", mark-size: 1.5pt, line-width: widths.thick, coords: ((67.5, 8), (82.5, 14), (97.5, 45), (112.5, 82), (127.5, 108), (142.5, 67), (157.5, 54), (172.5, 24), (187.5, 4), (202.5, 0)), legend: [heart disease]),
      addplot(draw: blue, mark: "square*", mark-size: 1.5pt, line-width: widths.thick, coords: ((67.5, 1), (82.5, 2), (97.5, 11), (112.5, 25), (127.5, 42), (142.5, 74), (157.5, 87), (172.5, 62), (187.5, 23), (202.5, 1)), legend: [no heart disease]),
    )
  })
]

#note[
  Two humps that sit apart mean the column carries signal. Two humps on top of each other mean it carries little on its own. Most real columns look like #figref(<fig:maxhr-groups>): shifted but overlapping. That is why models combine many weak columns instead of waiting for one strong one.
]

=== A category against the target: a rate and a count

For a category, compute the share of each group that has the disease, and always print the size of the group beside it.

#utptable[
  #tabularx(
    columns: (30%, 1fr, 15%, 18%),
    align: (left, left, center, center),
    styles: (navy-bold,),
    header: ([Column], [Value], [Patients], [Disease rate]),
    [Chest pain type], [No chest pain (`ASY`)], [403], [78.7%],
    [], [Typical angina (`TA`)], [40], [45.0%],
    [], [Non-anginal pain (`NAP`)], [155], [33.5%],
    [], [Atypical angina (`ATA`)], [136], [14.0%],
    [Slope of the ST segment], [Flat], [374], [83.2%],
    [], [Down], [47], [83.0%],
    [], [Up], [313], [17.9%],
    [Chest pain during exercise], [Yes], [300], [84.7%],
    [], [No], [434], [35.0%],
    [Sex], [Men], [579], [62.5%],
    [], [Women], [155], [28.4%],
    [Fasting blood sugar above 120], [Yes], [168], [79.2%],
    [], [No], [566], [48.2%],
  )
]

These categories separate the patients far better than any of the numbers did. A patient whose ST slope is `Up` has a 17.9% chance of disease, and one whose slope is `Flat` has 83.2%. One finding looks backwards: patients with #emph[no] chest pain have the highest rate, 78.7%. That is not a mistake in the data. People are sent for a heart examination for a reason, and those who arrive without chest pain were usually sent because of something more serious. A table records who was measured, and how they came to be measured shapes every rate in it.

#example[
  How far can the 45.0% for typical angina be trusted? It rests on 40 patients. A rate is the mean of a column of zeros and ones, so the standard error of #chapref(<ch:foundations>) applies to it, and for a rate $p$ measured on $n$ rows it works out to $sqrt(p(1-p)\/n)$. Two standard errors either way is

  $ 1.96 times sqrt(frac(0.45 times 0.55, 40)) = 0.15. $

  The true rate could plausibly be anywhere from 30% to 60%. The 78.7% for the 403 patients without chest pain is known far more tightly. A rate without its count invites you to treat the two as equally solid.
]

=== A gap against the target

There is one more column to compare with the target: the fact that a value is missing.

```terminal
disease rate when cholesterol was not measured 0.899, when it was 0.479
```

Of the 129 training patients with no cholesterol reading, 89.9% have heart disease, against 47.9% of the rest. The gap is not random. The table joins five hospitals, and the zeros come from the ones that did not record cholesterol and whose patients were sicker. #chapref(<ch:data>) called this kind of gap informative. Here it is the strongest signal the cholesterol column has, and it has nothing to do with cholesterol.

== Columns against each other

A correlation table puts a number on every pair of number columns (#secref(<sec:correlation>)). It is drawn as a grid of colours, a #term[heatmap], when there are too many pairs to read. Here are the correlations of cholesterol with the other columns, computed twice.

#utptable[
  #tabularx(
    columns: (34%, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Correlation of cholesterol with], [Age], [RestingBP], [MaxHR], [Oldpeak], [Heart disease]),
    [Zeros left in], [$-0.10$], [0.08], [0.26], [0.09], [$bold(-0.24)$],
    [Zeros marked as missing], [0.03], [0.10], [0.00], [0.06], [$bold(0.08)$],
  )
]

With the zeros left in, cholesterol has a correlation of $-0.24$ with heart disease: higher cholesterol, #emph[less] disease. That would be a remarkable medical finding. It is produced entirely by the 129 zeros, which belong to sick patients and sit at the bottom of the scale. Mark them as missing and the correlation is $+0.08$, small and in the direction any doctor expects. The correlation of 0.26 with heart rate disappears completely. A data-quality problem had manufactured two relationships.

Among the columns that survive, the strongest pair is age and highest heart rate at $-0.40$: older patients reach lower heart rates, which is ordinary physiology. Nothing here is near $plus.minus 0.9$, so no column simply repeats another.

#warning[
  Do not drop a column because its correlation with the target is small. Correlation measures straight-line association between two number columns, and nothing else. It misses a column whose effect bends, as hours and marks did in the study log at $-0.25$. It misses a column that only matters in combination with another. It is meaningless for a category coded as arbitrary numbers. And as cholesterol just showed, it can be created or destroyed by a handful of bad values. Screen features with a model that is validated honestly (#chapref(<ch:feature-selection>)), and use correlation to find questions, not answers.
]

== From observations to decisions

An exploration is finished when it has been written down. This is the whole log for the heart table, and it is the specification for the pipeline.

#utptable[
  #tabularx(
    columns: (35%, 30%, 1fr),
    styles: ((:), (:), (:)),
    header: ([Observation], [Decision], [Where it happens]),
    [Blood pressure and cholesterol contain zeros that mean "not measured".], [Mark as missing.], [A fixed rule, before the split.],
    [The gap in cholesterol goes with the disease.], [Fill with the median and add a flag column saying the value was missing.], [In the pipeline, fitted on training rows.],
    [`FastingBS` is 0/1.], [Treat as a category.], [In the pipeline.],
    [Cholesterol and `Oldpeak` are right-skewed; some readings lie beyond the fences.], [Keep every patient. Scale the numbers; try a transform later and judge it by validation.], [In the pipeline.],
    [Categories separate the patients better than numbers.], [One-hot encode all six.], [In the pipeline.],
    [Typical angina has only 40 patients.], [Keep the category, and read its effect with caution.], [In the report.],
    [Men are 79% of the patients.], [Report results for women separately.], [In the evaluation.],
  )
]

=== What the first model has to beat

The exploration also sets the bar. Three baselines come straight from the tables above, with no fitting at all for the first two.

```terminal
always say disease: 0.553   one rule on ST_Slope: 0.827
zeros left in            accuracy 0.853 (+/- 0.041)  ROC AUC 0.925  weights {'num__Cholesterol': -0.49}
zeros as missing         accuracy 0.847 (+/- 0.030)  ROC AUC 0.922  weights {'num__Cholesterol': 0.05}
zeros as missing + flag  accuracy 0.857 (+/- 0.039)  ROC AUC 0.928  weights {'num__Cholesterol': 0.04,
                                                                             'num__missingindicator_Cholesterol': 0.71}
```

One sentence read off the rate table, "disease unless the ST slope is `Up`", is right for 82.7% of the training patients. A logistic regression on all eleven columns, scored by five-fold cross-validation (#chapref(<ch:evaluation>)), reaches about 85%. So a model with eleven inputs beats one rule by three points, and whether that is worth its complexity is a question for the people who would use it.

Now compare the three logistic rows. Their accuracies differ by one point, well inside the spread of four points between folds, so the score cannot tell them apart. The weights can. With the zeros left in, the model gives cholesterol a weight of $-0.49$: it has learned that low cholesterol predicts heart disease, because zero is the lowest value there is. The model scores well and has learned something false. With the zeros marked as missing and a flag added, the weight on cholesterol itself is 0.04, and the flag carries 0.71: the model now says, correctly, that #emph[not having been measured] is what goes with the disease.

#note[
  A validation score tells you how well a model predicts on data like the training data. It does not tell you whether the model has learned something true. The first model above would fail at any hospital that measures every patient's cholesterol, and only looking at the column revealed why.
]

The chosen pipeline is then fitted on all 734 training patients and scored once on the sealed test set.

```terminal
sealed test set: accuracy 0.897, ROC AUC 0.932, confusion matrix [[71, 11], [8, 94]]
```

Of the 184 test patients it calls 165 correctly. It raises 11 false alarms and misses 8 of the 102 patients who have the disease. #chapref(<ch:evaluation>) asks which of those two errors costs more, and what to do about it.

== The examination, as a checklist

#utptable[
  #tabularx(
    columns: (24%, 1fr, 28%),
    styles: (navy-bold,),
    header: ([Stage], [Ask], [Look with]),
    [The table], [What is one row? How many rows and columns? Which types? Any blanks or repeats?], [`shape`, `info`, `nunique`, `duplicated`],
    [Each number], [Could the minimum and maximum be real? One hump or two? Which way does the tail point?], [`describe`, a histogram, a box plot, `skew`],
    [Each category], [Which values, how often? Any twins or rare values?], [`value_counts`],
    [Against the target], [Do the groups differ? By how much, on how many rows?], [`groupby` means and rates with counts, overlaid histograms],
    [Gaps], [Is a missing value more common in one class?], [the rate of the target where the value is missing],
    [Pairs of columns], [Which move together? Does one repeat another?], [a scatter plot, `corr`, a heatmap],
    [Decisions], [What will the pipeline do about each finding? What is the baseline?], [a written log],
  )
]

#summary[
  - EDA is a loop: ask, look, note, decide. Its product is a written list of decisions for the pipeline.
  - Work inwards: the table, each column alone, each column against the target, columns against each other.
  - Read the minimum and maximum of every number column. A value that cannot be true is a missing value in disguise; the heart table hides 172 of them as zeros.
  - Believe the histogram over the summary. A box plot's fences sit 1.5 IQR beyond the box, and a point beyond them is a point to look at, not to delete.
  - Seal the test set before studying any relationship with the target.
  - Print a rate together with its count. A rate from 40 rows can be off by 15 points either way.
  - A gap can carry signal of its own: flag it. A correlation can be manufactured by bad values: cholesterol went from $-0.24$ to $+0.08$.
  - A good score does not prove the model learned something true. Look at what it learned.
]

#exercises[
  Run `python all_experiments/book_checks/demo_exploration.py` and read its output beside this chapter. Then pick one decision from the log and argue the opposite. For example: what would you lose, and what would you gain, by dropping the 129 patients with no cholesterol reading instead of flagging them? Use the disease rates of the two groups in your answer.
]

#questions[
  + A column of ages has a minimum of 0 and a maximum of 120 in a table of adult bank customers. What do you check, and what are two different things the zeros might mean?
  + For a column with $Q_1 = 20$ and $Q_3 = 30$, where are the fences? A value of 44 is in the column: where does the box plot draw it?
  + Why is the test set sealed before comparing features with the target, but not before checking column types and impossible values?
  + Two groups have disease rates of 60% and 40%. One has 500 patients and the other 12. What should you say about the difference?
  + The correlation between cholesterol and heart disease changed sign when the zeros were marked as missing. Explain in two sentences how 129 rows can do that to a table of 734.
  + The model with the zeros left in and the model with a missing-value flag have the same cross-validated accuracy. Give one reason to prefer the second that the score does not show.
  + A teammate proposes dropping every row that has any value beyond a box-plot fence. Using the counts in this chapter, estimate how many training patients that could remove, and name one risk.
]
