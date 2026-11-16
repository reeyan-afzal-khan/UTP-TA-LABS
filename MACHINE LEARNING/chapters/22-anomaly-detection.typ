#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "22-anomaly-detection")

= Anomaly Detection <ch:anomaly>

#chapterguide[#chapref(<ch:unsupervised>), distributions and quantiles from #chapref(<ch:foundations>), plus clustering and density ideas from #chapref(<ch:clustering>).][score anomalies with statistical rules and see how they fail; compare distance, local density and isolation; turn a score into a review list; and evaluate alerts at a real budget.]

A security guard on a quiet night watches for whatever does not fit. Nobody gave the guard a catalog of every possible burglar. The guard knows what normal looks like, and notices departures. #term[Anomaly detection] works the same way: it ranks departures from a reference pattern, such as fraud, sensor failures or data-entry errors. Examples of the thing you are looking for are rare, expensive to label, and tomorrow’s may look nothing like yesterday’s.

== Two setups, one name

Two closely related setups share the name:

#utptable[
  #tabularx(
    columns: (22%, 36%, 1fr),
    styles: (navy-bold,),
    header: ([Setup], [Training data], [Goal]),
    [Outlier detection], [The training data itself is contaminated with anomalies.], [Find the anomalous observations already present in the data.],
    [Novelty detection], [The training data contains clean “normal” behavior.], [Flag future observations that deviate from the learned normal pattern.],
  )
]

Because anomalies are rare and costly to label, many methods learn a reference pattern and score departures from it.

== Statistical rules: z-scores and IQR fences

For a single roughly bell-shaped feature, the #term[z-score] measures how many standard deviations an observation sits from the mean:

$ z=frac(x-macron(x), s), $

with $|z|>3$ a customary alarm threshold, because under a normal distribution only about $0.3 %$ of values land that far out.

#example[
  A temperature sensor averages $macron(x)=50$ with standard deviation $s=5$. A reading of $68$ has $z=(68-50)\/5=3.6$: flagged. A reading of $57$ has $z=1.4$: unremarkable.
]

There is a trap in this rule: an outlier can hide itself, because it inflates the very mean and standard deviation that are supposed to expose it.

#example[
  A sensor reads $10, space 11, space 9, space 10, space 12, space 11, space 10, space 60$. The 60 is obviously wrong. Yet the mean is 16.62 and the standard deviation 17.55, so its z-score is only $(60-16.62)\/17.55=2.47$, which does not raise the alarm. The outlier has #emph[masked] itself.

  Robust statistics resist this. The median is 10.5, and the median absolute deviation (MAD) is 0.5, so the robust z-score of 60 is $0.6745 times (60-10.5)\/0.5=66.8$. The IQR fences agree: with $Q_1=10$ and $Q_3=11.25$, the fences are 8.125 and 13.125, and 60 lies far outside them.
]

#term[IQR fences] use quartiles (#chapref(<ch:foundations>)):

$ [ thin Q_1-1.5 op("IQR"), space Q_3+1.5 op("IQR") thin ]. $

For $Q_1=20$ and $Q_3=30$ minutes, the fences are 5 and 45, so a 60-minute delivery is flagged without assuming normality.

Per-feature checks can miss unusual combinations of individually plausible values. Multivariate methods capture these relationships.

== Distance and local density

Distance to the $k$-th nearest neighbor measures isolation, but naturally sparse groups can look anomalous. #term[Local outlier factor (LOF)] instead compares a point’s density with that of its neighbors: near 1 is locally typical, and much larger values indicate local isolation.

#example[
  A tight group has points 0.1 apart, a loose group has points 1 apart, and one stranger sits 1.0 away from the tight group.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    align: (left, center, center),
    header: ([Point], [Distance to third neighbor], [Local outlier factor]),
    [Member of the tight group], [0.20], [1.00],
    [Member of the loose group], [2.00], [1.00],
    [The stranger], [1.20], [4.71],
  )

  #raggedright[
  #v(6pt)
  By plain distance, an ordinary loose-group member looks more anomalous than the stranger. LOF asks “unusual compared with whom?” and flags only the stranger.
  ]]]
]

== Model-based scores

Fit a Gaussian or mixture to reference data and flag low-likelihood cases (#chapref(<ch:clustering>)). A #term[one-class SVM] instead learns a boundary around the reference population.

== Isolation forests <sec:isolation-forest>

Play a game of Guess Who with a crowd. To pick out someone with very unusual features takes one or two questions. To pick out one average person from among many similar ones takes a long time. An #term[isolation forest] plays this with random questions: it builds trees of random feature thresholds, and it scores each row by how quickly it becomes isolated.

#example[
  Take 99 ordinary values drawn from a bell curve and one stranger at 8. Cut the range at a random point, keep the side the target is on, and repeat until the target is alone. On average the stranger takes 1.6 cuts and an ordinary value takes 9.6.
]

Isolation forests need no distance metric. #term[Contamination] sets a threshold, not the true anomaly rate; Lab~5 ranks raw scores instead.

== Evaluating and using anomaly detectors

Never trust the headline number alone. Lab~5’s isolation forest ranks 85,443 held-out card transactions, of which 148 are fraud (0.17%). It never sees the fraud column while fitting. Its ROC AUC is 0.95, which sounds superb. Its average precision is 0.22, which is 126 times the base rate and still modest. What a review team cares about is the list.

#utptable[
  #align(center)[

  #tabularx(
    columns: (auto, auto, auto, auto),
    align: (center, center, center, center),
    header: ([Cases reviewed], [Frauds found], [Precision], [Recall]),
    [10], [7], [0.700], [0.047],
    [50], [25], [0.500], [0.169],
    [100], [39], [0.390], [0.264],
    [200], [50], [0.250], [0.338],
    [300], [63], [0.210], [0.426],
    [500], [69], [0.138], [0.466],
    [1000], [99], [0.099], [0.669],
  )

  ]
]

#utpfig([Lab~5’s isolation forest on 85,443 held-out transactions. Reviewing more cases finds more fraud at a falling hit rate. The base rate of 0.17% is what reviewing at random would achieve.], label: <fig:precision-at-k>)[
  #canvas({
    axis(..logaxis, width: 11.5632cm, height: 4.8cm, xlabel: [cases reviewed], ylabel: [share], xmin: 0, xmax: 1050, ymin: 0, ymax: 1.05, legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.97, 0.55), anchor: "east"),
      addplot(draw: blue, mark: "*", mark-size: 1.3948pt, line-width: widths.thick, coords: ((10, 0.7), (50, 0.5), (100, 0.39), (200, 0.25), (300, 0.21), (500, 0.138), (1000, 0.099)), legend: [precision: fraud rate in the list]),
      addplot(draw: orange, mark: "square*", mark-size: 1.3948pt, line-width: widths.thick, coords: ((10, 0.047), (50, 0.169), (100, 0.264), (200, 0.338), (300, 0.426), (500, 0.466), (1000, 0.669)), legend: [recall: share of all fraud found]),
      addplot(draw: muted, dash: "dashed", domain: (0, 1050), x => 0.0017, legend: [base rate, 0.17%]),
    )
  })
]

- For distance- and kernel-based detectors, apply the scaling rule from #secref(<sec:scaling>).
- Choose thresholds from consequences --- how many alarms per day can be investigated? --- not from statistical custom.
- Anomalies may be errors or important rare events. Investigate before deleting.

== The shape of an anomaly problem

Anomaly detection differs from classification in one important way: you usually cannot see many examples of the thing you are looking for.

#utpfig([Two views of an anomaly problem. Distance and density place anomalies outside the normal region; a score and a threshold you choose turn that into a list of flagged cases.], label: <fig:anomaly-views>)[
  #canvas({
    draw.scope({
      rectangle((0, 0), (4.2, 2.9), draw: muted, fill: white)
      for p in ((1.5, 1.4), (1.8, 1.6), (1.6, 1.1), (2, 1.3), (1.3, 1.7), (2.2, 1.6), (1.9, 0.9), (1.4, 1.25), (2.1, 1.1), (1.7, 1.45), (2.3, 1.35), (1.55, 0.85), (2.05, 1.65)) {
        circle-at(p, 2.391pt, fill: blue, draw: none)
      }
      circle-at((1.8, 1.32), 0.95, line-width: widths.thick, dash: "dashed", draw: teal)
      circle-at((3.5, 2.4), 2.7895pt, fill: red, draw: none)
      circle-at((0.5, 0.4), 2.7895pt, fill: red, draw: none)
      node((4.15, 2.72), [anomalies], font: font("script"), anchor: "east", text: red)
      node((1.8, -0.35), [the \"normal\" region], font: font("script"), text: teal)
      node((2.1, 3.25), [Distance / density view], font: font("small", weight: "bold", fill: navy))
    })
    draw.scope({
      draw.translate((5.6, 0))
      rectangle((0, 0), (4.6, 2.9), draw: muted, fill: white)
      connect((0.3, 0.45), (4.35, 0.45), draw: muted, end: arrow-tip("Stealth", length: 2mm, line: 0.4pt))
      node((2.3, 0.4), [anomaly score], font: font("script"), anchor: "north", inner-sep: 0.9963pt, text: muted)
      smooth-path(..range(60).map(k => { let x = 0.4 + k * (4.3 - (0.4)) / 59; (x, 0.45 + 2 * calc.exp(-(calc.pow((x - 1.3), 2)) / 0.28)) }), line-width: widths.very-thick, draw: blue)
      connect((2.85, 0.45), (2.85, 2.6), line-width: widths.very-thick, dash: "dashed", draw: red)
      node((2.95, 2.2), [threshold \
  you choose], font: font("script"), anchor: "west", align: left, text: red)
      node((1.3, 2.68), [normal], font: font("script"), text: green)
      node((3.1, 0.85), [flagged], font: font("script"), anchor: "west", text: red)
      node((2.3, 3.25), [Score-and-threshold view], font: font("small", weight: "bold", fill: navy))
    })
  })
]

#note[
  Choose thresholds or review batches for actual capacity and error costs; a high score is not a verdict.
]

== From anomaly score to investigation

Define the review process alongside the scoring model.

#utptable[
  #tabularx(
    columns: (35%, 1fr),
    styles: (navy-bold,),
    header: ([Question], [Practical consequence]),
    [How many cases can be reviewed?], [Choose a top-$k$ or score threshold that respects review capacity.],
    [What happens after a flag?], [Define whether the case is blocked, queued, inspected, or merely logged.],
    [Which false alert is costly?], [Track precision among reviewed cases and the burden on users or analysts.],
    [Can normal behavior change?], [Monitor score distributions and retrain or recalibrate when the reference population drifts.],
    [Can labels arrive later?], [Use confirmed outcomes to evaluate ranking quality and eventually consider a supervised model.],
  )
]

#recipecard([Isolation forest], [Many trees of random splits. A row’s score comes from how shallow its leaf is on average.], [None in the usual sense: the method has no target and no loss to reduce.], [None. Trees are grown at random, and the only choices are their number and the sample size.])

#checklist(title: [Anomaly Detection - Quick Guide])[
  #tabularx(
    columns: (25%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Anomaly detection asks], [Which observations are unusually inconsistent with a reference pattern?],
    [Useful methods], [Robust statistical rules, distance/local-density methods, isolation forest, and one-class models.],
    [Output], [An anomaly score or ranking; a later policy converts that score into an alert.],
    [Evaluation], [Precision among reviewed cases, PR AUC when labels exist, stability, and downstream review value.],
    [Main risks], [Rare does not always mean harmful; distribution shift can make yesterday’s normality model obsolete.],
  )
]

#summary[
  - An anomaly score ranks departures from a reference pattern. It is not a probability of fraud.
  - The z-score can be masked by the outlier itself, so prefer the median, the MAD and the IQR.
  - Distance alone penalizes naturally sparse groups; LOF judges a point against its own neighborhood.
  - Isolation forests need no distance: strangers separate after a few random cuts.
  - Evaluate at the real review budget. A ROC AUC of 0.95 and a 39% hit rate in the top 100 describe the same ranking.
]

#questions[
  + Why is an anomaly score not automatically a probability of fraud, failure or error?
  + How does a fixed review capacity turn anomaly detection into a ranking problem?
  + What is the difference between detecting outliers in the training sample and novelty detection for future observations?
  + Readings are $5,5,6,4,5,50$. Compute the median and MAD. Is the 50 flagged by a robust z-score above 3?
  + In the fraud table above, why does recall keep rising when precision falls?
]
