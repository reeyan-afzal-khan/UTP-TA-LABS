#import "/.shared/typst/utp.typ": *
#unit("chapters", "17-anomaly-detection")


#heading(level: 1)[Anomaly Detection]
 <ch:anomaly>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* #ref(label("ch:unsupervised"), supplement: [Chapter]), distributions and quantiles from #ref(label("ch:foundations"), supplement: [Chapter]), plus clustering and density ideas from #ref(label("ch:clustering"), supplement: [Chapter]).

*By the end, you can:* score anomalies with statistical rules and see how they fail; compare distance, local density and isolation; turn a score into a review list; and evaluate alerts at a real budget.]

A security guard on a quiet night watches for whatever does not fit. Nobody gave the guard a catalog of every possible burglar. The guard knows what normal looks like, and notices departures. #strong[Anomaly detection] works the same way: it ranks departures from a reference pattern, such as fraud, sensor failures or data-entry errors. Examples of the thing you are looking for are rare, expensive to label, and tomorrow's may look nothing like yesterday's.


#heading(level: 2)[Two setups, one name]


Two closely related setups share the name:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Setup], [Training data], [Goal],),
    table.hline(),
    [Outlier detection], [The training data itself is contaminated with anomalies.], [Find the anomalous observations already present in the data.],
    [Novelty detection], [The training data contains clean "normal" behavior.], [Flag future observations that deviate from the learned normal pattern.],
  )]
  , kind: table
  )

Because anomalies are rare and costly to label, many methods learn a reference pattern and score departures from it.


#heading(level: 2)[Statistical rules: z-scores and IQR fences]


For a single roughly bell-shaped feature, the #strong[z-score] measures how many standard deviations an observation sits from the mean: $ z = frac(x - macron(x), s) \, $ with $\| z \| > 3$ a customary alarm threshold, because under a normal distribution only about $0.3 %$ of values land that far out.

#callout("workedexample", title: [Worked example])[A temperature sensor averages $macron(x) = 50$ with standard deviation $s = 5$. A reading of $68$ has $z = \( 68 - 50 \) \/ 5 = 3.6$: flagged. A reading of $57$ has $z = 1.4$: unremarkable.]

There is a trap in this rule: an outlier can hide itself, because it inflates the very mean and standard deviation that are supposed to expose it.

#callout("workedexample", title: [Worked example])[A sensor reads $10 \, med 11 \, med 9 \, med 10 \, med 12 \, med 11 \, med 10 \, med 60$. The 60 is obviously wrong. Yet the mean is 16.62 and the standard deviation 17.55, so its z-score is only $\( 60 - 16.62 \) \/ 17.55 = 2.47$, which does not raise the alarm. The outlier has #emph[masked] itself.

Robust statistics resist this. The median is 10.5, and the median absolute deviation (MAD) is 0.5, so the robust z-score of 60 is $0.6745 times \( 60 - 10.5 \) \/ 0.5 = 66.8$. The IQR fences agree: with $Q_1 = 10$ and $Q_3 = 11.25$, the fences are 8.125 and 13.125, and 60 lies far outside them.]

#strong[IQR fences] use quartiles (#ref(label("ch:foundations"), supplement: [Chapter])): $ \[ thin Q_1 - 1.5 "IQR" \, med Q_3 + 1.5 "IQR" thin \] . $ For $Q_1 = 20$ and $Q_3 = 30$ minutes, the fences are 5 and 45, so a 60-minute delivery is flagged without assuming normality.

Per-feature checks can miss unusual combinations of individually plausible values. Multivariate methods capture these relationships.


#heading(level: 2)[Distance and local density]


Distance to the $k$-th nearest neighbor measures isolation, but naturally sparse groups can look anomalous. #strong[Local outlier factor (LOF)] instead compares a point's density with that of its neighbors: near 1 is locally typical, and much larger values indicate local isolation.

#callout("workedexample", title: [Worked example])[A tight group has points 0.1 apart, a loose group has points 1 apart, and one stranger sits 1.0 away from the tight group.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,center,),
    table.header([Point], [Distance to third neighbor], [Local outlier factor],),
    table.hline(),
    [Member of the tight group], [0.20], [1.00],
    [Member of the loose group], [2.00], [1.00],
    [The stranger], [1.20], [4.71],
  )]
  , kind: table
  )

By plain distance, an ordinary loose-group member looks more anomalous than the stranger. LOF asks "unusual compared with whom?" and flags only the stranger.]


#heading(level: 2)[Model-based scores]


Fit a Gaussian or mixture to reference data and flag low-likelihood cases (#ref(label("ch:clustering"), supplement: [Chapter])). A #strong[one-class SVM] instead learns a boundary around the reference population.


#heading(level: 2)[Isolation forests]
 <sec:isolation-forest>

#callout("analogy", title: [Analogy])[Play a game of Guess Who with a crowd. To pick out someone with very unusual features takes one or two questions. To pick out one average person from among many similar ones takes a long time. An #strong[isolation forest] plays this with random questions: it builds trees of random feature thresholds, and it scores each row by how quickly it becomes isolated.]

#callout("workedexample", title: [Worked example])[Take 99 ordinary values drawn from a bell curve and one stranger at 8. Cut the range at a random point, keep the side the target is on, and repeat until the target is alone. On average the stranger takes 1.6 cuts and an ordinary value takes 9.6.]

Isolation forests need no distance metric. #strong[Contamination] sets a threshold, not the true anomaly rate; Lab~5 ranks raw scores instead.


#heading(level: 2)[Evaluating and using anomaly detectors]


Never trust the headline number alone. Lab~5's isolation forest ranks 85,443 held-out card transactions, of which 148 are fraud (0.17%). It never sees the fraud column while fitting. Its ROC AUC is 0.95, which sounds superb. Its average precision is 0.22, which is 126 times the base rate and still modest. What a review team cares about is the list.

#figure(
  align(center)[#table(
    columns: 4,
    align: (center,center,center,center,),
    table.header([Cases reviewed], [Frauds found], [Precision], [Recall],),
    table.hline(),
    [10], [7], [0.700], [0.047],
    [50], [25], [0.500], [0.169],
    [100], [39], [0.390], [0.264],
    [200], [50], [0.250], [0.338],
    [300], [63], [0.210], [0.426],
    [500], [69], [0.138], [0.466],
    [1000], [99], [0.099], [0.669],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/3c2eac2616312f4d.svg")], caption: [Lab~5's isolation forest on 85,443 held-out transactions. Reviewing more cases finds more fraud at a falling hit rate. The base rate of 0.17% is what reviewing at random would achieve.]) <fig:precision-at-k>

- For distance- and kernel-based detectors, apply the scaling rule from #ref(label("sec:scaling"), supplement: [Section]).

- Choose thresholds from consequences --- how many alarms per day can be investigated? --- not from statistical custom.

- Anomalies may be errors or important rare events. Investigate before deleting.


#heading(level: 2)[The shape of an anomaly problem]


Anomaly detection differs from classification in one important way: you usually cannot see many examples of the thing you are looking for.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/cd1d8d13ff4f6ff2.svg")], caption: [Two views of an anomaly problem. Distance and density place anomalies outside the normal region; a score and a threshold you choose turn that into a list of flagged cases.]) <fig:anomaly-views>

#callout("keyidea", title: [Key idea])[Choose thresholds or review batches for actual capacity and error costs; a high score is not a verdict.]


#heading(level: 2)[From anomaly score to investigation]


Define the review process alongside the scoring model.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Question], [Practical consequence],),
    table.hline(),
    [How many cases can be reviewed?], [Choose a top-$k$ or score threshold that respects review capacity.],
    [What happens after a flag?], [Define whether the case is blocked, queued, inspected, or merely logged.],
    [Which false alert is costly?], [Track precision among reviewed cases and the burden on users or analysts.],
    [Can normal behavior change?], [Monitor score distributions and retrain or recalibrate when the reference population drifts.],
    [Can labels arrive later?], [Use confirmed outcomes to evaluate ranking quality and eventually consider a supervised model.],
  )]
  , kind: table
  )

#callout("modelcard", title: [The recipe: Isolation forest])[*1. Model* Many trees of random splits. A row's score comes from how shallow its leaf is on average.

*2. Loss* None in the usual sense: the method has no target and no loss to reduce.

*3. Optimizer* None. Trees are grown at random, and the only choices are their number and the sample size.]

#callout("modelcard", title: [Anomaly Detection - Quick Guide])[#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    [Anomaly detection asks], [Which observations are unusually inconsistent with a reference pattern?],
    [Useful methods], [Robust statistical rules, distance/local-density methods, isolation forest, and one-class models.],
    [Output], [An anomaly score or ranking; a later policy converts that score into an alert.],
    [Evaluation], [Precision among reviewed cases, PR AUC when labels exist, stability, and downstream review value.],
    [Main risks], [Rare does not always mean harmful; distribution shift can make yesterday's normality model obsolete.],
  )]
  , kind: table
  )]

#callout("chapterrecap", title: [Chapter recap])[- An anomaly score ranks departures from a reference pattern. It is not a probability of fraud.

- The z-score can be masked by the outlier itself, so prefer the median, the MAD and the IQR.

- Distance alone penalizes naturally sparse groups; LOF judges a point against its own neighborhood.

- Isolation forests need no distance: strangers separate after a few random cuts.

- Evaluate at the real review budget. A ROC AUC of 0.95 and a 39% hit rate in the top 100 describe the same ranking.]

#callout("quickcheck", title: [Check your understanding])[+ Why is an anomaly score not automatically a probability of fraud, failure or error?

+ How does a fixed review capacity turn anomaly detection into a ranking problem?

+ What is the difference between detecting outliers in the training sample and novelty detection for future observations?

+ Readings are $5 \, 5 \, 6 \, 4 \, 5 \, 50$. Compute the median and MAD. Is the 50 flagged by a robust z-score above 3?

+ In the fraud table above, why does recall keep rising when precision falls?]
