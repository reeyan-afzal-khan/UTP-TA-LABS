#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "06-evaluating-supervised-models")

= Evaluating Supervised Models <ch:evaluation>

#chapterguide[#chapref(<ch:data>) and #chapref(<ch:foundations>): honest holdouts, label types, averages, spread, and sampling uncertainty.][compute regression and classification metrics by hand; read a confusion matrix; move a threshold on purpose; compute a ROC AUC by counting pairs; choose a cross-validation splitter; and say how much a score can be trusted.]

Think about a smoke alarm. You could score it by how often it is “correct”: in a house with no fires it stays silent every day of the year, so even an alarm with no battery in it scores above 99%. That number is true and useless. What you want to know is whether it rings when there is a fire, and whether it leaves you alone when you make toast. Evaluation is the habit of asking the question that matters, on data the model has not seen, against a baseline that costs nothing.

== Evaluation begins with the real objective

Choose metrics for the supported decision and its error costs.

A useful evaluation plan states:

- the unit being predicted and the population of interest;
- how the data split imitates future use;
- the baseline that must be beaten;
- the primary metric used for model selection;
- secondary metrics and subgroup checks;
- acceptable failure rates and operational constraints.

Prespecify the primary metric to avoid selective reporting.

== Regression metrics <sec:regression-metrics>

For true values $y_i$ and predictions $hat(y)_i$, mean squared error and root mean squared error are

$ op("MSE") =frac(1, n) sum _(i=1)^n((y_i-hat(y)_i))^2, wide op("RMSE")=sqrt(op("MSE")). $

MSE strongly penalizes large errors. RMSE is easier to interpret because it uses the same units as the label.

#keepspace(176.15pt)

#workedexample[
  Five delivery times, in minutes. Four predictions are nearly right; one is badly wrong.

  #utptable[
    #fsize("small")[

    #tabularx(
      columns: (auto, auto, auto, auto, auto, auto),
      align: (left, center, center, center, center, center),
      styles: (navy-bold,),
      header: ([True $y$], [10], [12], [14], [16], [48]),
      [Predicted $hat(y)$], [11], [13], [13], [15], [20],
      [Error $y-hat(y)$], [$-1$], [$-1$], [$+1$], [$+1$], [$+28$],
    )

    ]
  ]

  The absolute errors are $1,1,1,1,28$, so

  $ op("MAE")=frac(1+1+1+1+28, 5)=frac(32, 5)=6.4, wide op("MedAE")=1. $

  Squaring first gives $1,1,1,1,784$, so

  $ op("MSE")=frac(788, 5)=157.6, wide op("RMSE")=sqrt(157.6) approx 12.55. $

  For $R^2$, the mean of the true values is $macron(y)=100\/5=20$, and

  $ sum ((y_i-macron(y)))^2=100+64+36+16+784=1000, wide R^2=1-frac(788, 1000)=0.212. $

  MedAE $=1$, MAE $=6.4$, and RMSE $approx 12.55$ describe different aspects of error. One row contributes $784\/788=99.5 %$ of squared error; inspect extremes when RMSE greatly exceeds MAE.
]

#pitfall[
  Binning a continuous label changes the task to classification. Do so only when predefined categories match the decision.
]

== Additional regression metrics

Mean absolute error is

$ op("MAE") =frac(1, n) sum _(i=1)^n|y_i-hat(y)_i|. $

MAE weights errors linearly; median absolute error describes a typical miss and is more robust.

Mean absolute percentage error is

$ op("MAPE") =frac(100, n) sum _(i=1)^n |frac(y_i-hat(y)_i, y_i)|. $

MAPE is undefined at zero, unstable near zero, and asymmetric between over- and underprediction.

For asymmetric real-world costs, a custom loss or quantile loss may be more appropriate. Quantile regression can estimate an interval of plausible outcomes rather than only a conditional mean.

== Classification metrics: start with the confusion matrix <sec:classification-metrics>

Almost every classification metric is a different way of reading the same four boxes.

#utpfig([The confusion matrix. Almost every classification metric is a different way of reading these four boxes.], label: <fig:confusion-matrix>)[
  #canvas({
    node((5.225, 4.95), [Predicted class], font: font("small", weight: "bold", fill: navy))
    node((1, 2.5), [Actual class], font: font("small", weight: "bold", fill: navy), rotate: (90) * 1deg)
    node((3.55, 4.5), [Positive], font: font("script"), draw: mix(blue, 35%), fill: pale-blue, rounded: 1mm, min-width: 3.1, min-height: 0.48, text: navy)
    node((6.9, 4.5), [Negative], font: font("script"), draw: mix(blue, 35%), fill: pale-blue, rounded: 1mm, min-width: 3.1, min-height: 0.48, text: navy)
    node((1.65, 3.4), [Positive], font: font("script"), draw: mix(blue, 35%), fill: pale-blue, rounded: 1mm, min-width: 1.5, min-height: 0.48, text: navy, rotate: (90) * 1deg)
    node((1.65, 1.6), [Negative], font: font("script"), draw: mix(blue, 35%), fill: pale-blue, rounded: 1mm, min-width: 1.5, min-height: 0.48, text: navy, rotate: (90) * 1deg)
    rectangle((2, 2.65), (5.1, 4.15), fill: pale-teal, draw: green, rounded: 1mm)
    rectangle((5.35, 2.65), (8.45, 4.15), fill: pale-red, draw: red, rounded: 1mm)
    rectangle((2, 0.85), (5.1, 2.35), fill: pale-red, draw: red, rounded: 1mm)
    rectangle((5.35, 0.85), (8.45, 2.35), fill: pale-teal, draw: green, rounded: 1mm)
    node((3.55, 3.4), [#strong[True positive (TP)] \
  caught it], font: font("script"), align: center, text: navy)
    node((6.9, 3.4), [#strong[False negative (FN)] \
  missed it], font: font("script"), align: center, text: navy)
    node((3.55, 1.6), [#strong[False positive (FP)] \
  false alarm], font: font("script"), align: center, text: navy)
    node((6.9, 1.6), [#strong[True negative (TN)] \
  correctly ignored], font: font("script"), align: center, text: navy)
    node((10.95, 3.4), [#strong[Recall] reads across the actual-positive row: $T P+F N$.], name: "recall", font: font("script"), draw: orange, fill: pale-orange, rounded: 1mm, align: left, text-width: 3.25, min-height: 1.15, text: navy)
    connect((8.67, 2.65), (8.67, 4.15), line-width: widths.thick, draw: orange)
    connect((8.55, 2.65), (8.67, 2.65), line-width: widths.thick, draw: orange)
    connect((8.55, 4.15), (8.67, 4.15), line-width: widths.thick, draw: orange)
    connect((8.67, 3.4), "recall.west", line-width: widths.thick, draw: orange, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    node((10.95, 1.45), [#strong[Precision] reads down the predicted-positive column: $T P+F P$.], name: "precision", font: font("script"), draw: blue, fill: pale-blue, rounded: 1mm, align: left, text-width: 3.25, min-height: 1.15, text: navy)
    connect((2, 0.63), (5.1, 0.63), line-width: widths.thick, draw: blue)
    connect((2, 0.63), (2, 0.75), line-width: widths.thick, draw: blue)
    connect((5.1, 0.63), (5.1, 0.75), line-width: widths.thick, draw: blue)
    connect((3.55, 0.63), (3.55, 0.42), (8.85, 0.42), (8.85, 1.45), "precision.west", line-width: widths.thick, draw: blue, end: tip("Stealth", length: 1.8mm, line: widths.thick))
  })
]

#analogy[
  Back to the alarm. #term[Precision] asks: when it rings, is there really a fire? An alarm that rings at every piece of toast has poor precision. #term[Recall] asks: when there is a fire, does it ring? An alarm with a dead battery has zero recall, and its precision is undefined because it never rang. Turning the sensitivity up or down trades one against the other.
]

#utptable[
  #tabularx(
    columns: (18%, 26%, 1fr),
    styles: (navy-bold,),
    header: ([Metric], [Formula], [Answers the question]),
    [Accuracy], [$display(frac(T P+T N, "all"))$], [How often is the model right overall?],
    [Precision], [$display(frac(T P, T P+F P))$], [When it says yes, is it right?],
    [Recall], [$display(frac(T P, T P+F N))$], [Does it find the ones that matter?],
    [F1], [$2 dot.op display(frac(P dot.op R, P+R))$], [One number balancing the two],
    [Specificity], [$display(frac(T N, T N+F P))$], [Does it leave the negatives alone?],
  )
]

#pitfall[
  Read confusion-matrix axis labels; actual/predicted conventions vary.
]

#workedexample[
  Of 1,000 emails, 100 are spam. The filter flags 80, of which 60 are spam:

  $ T P=60, wide F P=80-60=20, wide F N=100-60=40, wide T N=900-20=880. $

  (Check the total: $60+20+40+880=1000$.) Now every metric is arithmetic:

  $ "Accuracy"=frac(60+880, 1000)=0.940, wide "Precision"=frac(60, 80)=0.750, wide "Recall"=frac(60, 100)=0.600, $

  $ F_1=2 dot.op frac(0.750 times 0.600, 0.750+0.600) =frac(0.900, 1.350) approx 0.667. $

  The no-alert baseline reaches 90% accuracy; the model reaches 94% but misses 40 spam emails. Recall exposes those misses.
]

== Additional confusion-matrix measures

In addition to precision and recall, useful classification measures include

$ "Specificity"=frac(T N, T N+F P), wide "False-positive rate"=frac(F P, F P+T N). $

Balanced accuracy averages recall for the positive and negative classes:

$ "Balanced accuracy" =frac(1, 2) ("Recall"+"Specificity"). $

It is more informative than ordinary accuracy when classes are imbalanced.

The Matthews correlation coefficient (MCC) summarizes the entire confusion matrix in one number:

$ op("MCC") =frac(T P dot.op T N-F P dot.op F N, sqrt((T P+F P)(T P+F N)(T N+F P)(T N+F N))). $

MCC ranges from $-1$ to $1$; near zero indicates little association. Using all four cells makes it useful under imbalance.

#workedexample[
  Continuing the spam filter ($T P=60$, $F P=20$, $F N=40$, $T N=880$):

  $ "Specificity"=frac(880, 900) approx 0.978, wide "Balanced accuracy"=frac(0.600+0.978, 2) approx 0.789. $

  Accuracy is $0.940$, dominated by 900 negatives. Balanced accuracy is $0.789$, weighting each class equally.

  MCC uses all four cells at once. The numerator is

  $ T P dot.op T N-F P dot.op F N=60(880)-20(40)=52(,)800-800=52(,)000, $

  and the denominator is

  $ sqrt((80)(100)(900)(920))=sqrt(6(,)624(,)000(,)000) approx 81(,)388, $

  so $op("MCC") approx 52(,)000\/81(,)388 approx 0.639$.

  Accuracy, balanced accuracy, and MCC answer different questions; do not report accuracy alone under imbalance.
]

#term[Multiclass] problems need one more decision: how to combine the classes. #term[Macro averaging] weights classes equally, #term[micro averaging] pools every decision, and #term[weighted averaging] weights classes by frequency.

#workedexample[
  Three classes have 100, 10 and 2 rows, and a model gets 90, 5 and 1 of them right. Micro-averaged recall pools them: $96\/112=0.857$. Macro-averaged recall averages the three recalls: $(0.90+0.50+0.50)\/3=0.633$. The large class flatters the first number, and the second shows the small classes are at a coin flip. If small classes matter, report macro.
]

== Thresholds, ROC curves, and precision-recall curves

A probability model becomes a yes-or-no classifier only after someone picks a threshold. The model supplies a score, and the threshold is a policy. Lowering it catches more positives and raises more false alarms; raising it does the reverse.

#workedexample[
  Eight cases, already ranked by the model. Orange circles are real positives and blue dots are real negatives (#figref(<fig:threshold-shift>)).

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: (center, center, center, center, center, center, center),
    header: ([Threshold], [TP], [FP], [FN], [TN], [Precision], [Recall]),
    [0.90], [1], [0], [3], [4], [1.00], [0.25],
    [0.65], [2], [1], [2], [3], [0.67], [0.50],
    [0.50], [3], [2], [1], [2], [0.60], [0.75],
    [0.35], [4], [2], [0], [2], [0.67], [1.00],
    [0.05], [4], [4], [0], [0], [0.50], [1.00],
  )

  #raggedright[
  #v(6pt)
  Recall can only rise as the threshold falls. Precision wanders, because each new flag may be right or wrong. Nothing about the model changed between these rows.
  ]]]
]

#utpfig([Thresholds move the operating point. The eight scores stay fixed. Lowering the threshold from 0.65 to 0.35 catches the two remaining positives, at the cost of one more false alarm.], label: <fig:threshold-shift>)[
  #canvas(x: 11cm, {
    connect((0, 0), (1.03, 0), draw: muted, end: tip("Stealth", length: 2mm, line: 0.4pt))
    node(along((0, 0), (1.03, 0), t: 100%), [score], font: font("script"), anchor: "west")
    for (x, lab-v) in ((0, 0), (0.2, 0.2), (0.4, 0.4), (0.6, 0.6), (0.8, 0.8), (1, 1)) {
      connect((x, 0.06), (x, -0.06), draw: muted)
      node(along((x, 0.06), (x, -0.06), t: 100%), [#lab-v], font: font("script"), yshift: -1.9925pt, anchor: "north")
    }
    for x in (0.1, 0.3, 0.55, 0.7) {
      circle-at((x, 0.48), 2.6899pt, fill: blue, draw: none)
    }
    for x in (0.4, 0.6, 0.85, 0.95) {
      circle-at((x, 0.48), 2.9888pt, line-width: widths.very-thick, draw: orange)
    }
    node((0.02, 1.25), [$bullet$ actually negative], font: font("script"), anchor: "west", text: blue)
    node((0.27, 1.25), [$compose$ actually positive], font: font("script"), anchor: "west", text: orange)
    connect((0.65, -0.28), (0.65, 1), line-width: widths.very-thick, draw: navy)
    node((0.665, 0.98), [threshold 0.65], font: font("script"), align: left, text: navy, anchor: "west")
    connect((0.35, -0.28), (0.35, 1), line-width: widths.very-thick, dash: "dashed", draw: red)
    node((0.335, 0.98), [threshold 0.35], font: font("script"), align: right, text: red, anchor: "east")
    connect((0.63, -0.2), (0.37, -0.2), line-width: widths.thick, draw: red, end: tip("Stealth", length: 1.8mm, line: widths.thick))
  })
]

#keyidea[
  Lower thresholds increase positive decisions and can never reduce recall. Higher thresholds reduce alerts and may miss positives. Choose the threshold on validation data from costs or capacity, and lock it before test evaluation (Lab~2, Part~C).
]

=== ROC AUC by counting pairs

The #term[ROC curve] plots true-positive rate against false-positive rate as the threshold sweeps from high to low. The area under it has a plain meaning: it is the chance that a randomly chosen positive gets a higher score than a randomly chosen negative.

#workedexample[
  Use the same eight cases. Positives scored 0.95, 0.85, 0.60, 0.40 and negatives scored 0.70, 0.55, 0.30, 0.10, so there are $4 times 4=16$ pairs. The positive at 0.60 loses to the negative at 0.70. The positive at 0.40 loses to the negatives at 0.70 and 0.55. All the rest are ranked correctly: $13\/16$, so ROC AUC is 0.8125. You can check any ROC AUC this way, and it shows that the metric cares only about order, not about any threshold.
]

=== Capacity and cost metrics <sec:capacity-metrics>

When only $k$ cases can be reviewed, rank all eligible cases and report

$ op("precision@")k=frac("positives in top " k, k), wide op("recall@")k=frac("positives in top " k, "all positives"), $

$ op("lift@")k= frac(op("precision@")k, "positive prevalence"). $

Report error costs when defensible. For fixed review capacity, evaluate the ranked batch, as in Lab~5’s top 100 fraud alerts.

#workedexample[
  A team can call five of 20 customers. Ranked outcomes follow; $1$ denotes churn:

  #align(center)[
    #mono[#fsize("small")[1#h(1em)1#h(1em)0#h(1em)1#h(1em)0  |  0#h(1em)0#h(1em)1#h(1em)0#h(1em)0#h(1em)0#h(1em)0#h(1em)0#h(1em)0#h(1em)0#h(1em)0#h(1em)0#h(1em)0#h(1em)0#h(1em)0
    ]]
  ]

  The bar marks the capacity cutoff at $k=5$. There are $4$ churners in the batch of $20$, so the prevalence is $4\/20=0.20$. Of the top five, three churned:

  $ op("precision@")5=frac(3, 5)=0.60, wide op("recall@")5=frac(3, 4)=0.75, wide op("lift@")5=frac(0.60, 0.20)=3.0. $

  Randomly calling five customers would reach one churner on average; this ranking reaches three, giving lift~3. The constraint is five calls, not a probability threshold.
]

#pitfall[
  Churn risk is not persuadability. Ranking metrics cannot establish that contact causes retention; use a causal design such as randomization.
]

=== Two real models on one chart

#figref(<fig:pr-curves>) shows two logistic models from the labs: Lab~2’s hotel cancellations, scored on the bookings of 2017, and Lab~3’s loan defaults. The hotel model ranks well, with a ROC AUC of 0.824; the loan model is harder pressed, at 0.731. Their positive rates differ, 0.387 and 0.192, so each precision--recall curve has its own baseline: a model that guesses scores its positive rate, not 0.5.

#utpfig([ROC and precision-recall curves for two logistic models on their validation rows, Lab~2’s hotel cancellations and Lab~3’s loan defaults, read at 21 thresholds. The ROC baseline is the diagonal; each precision-recall baseline is that table’s positive rate, 0.39 for the hotel and 0.19 for the loans.], label: <fig:pr-curves>)[
  #canvas({
    groupplot(group-size: (2, 1), horizontal-sep: 1.3cm, ..logaxis, width: 7.4cm, height: 5cm, xmin: 0, xmax: 1, ymin: 0, ymax: 1.03,
      nextgroupplot(title: [ROC curve], xlabel: [False-positive rate], ylabel: [True-positive rate], legend-style: (at: (0.97, 0.05), anchor: "south-east"),
        addplot(draw: blue, line-width: widths.thick, coords: ((0, 0), (0, 0.002), (0.002, 0.013), (0.005, 0.025), (0.01, 0.056), (0.02, 0.098), (0.038, 0.164), (0.061, 0.231), (0.093, 0.302), (0.135, 0.397), (0.199, 0.506), (0.302, 0.647), (0.463, 0.794), (0.704, 0.922), (0.949, 0.991), (1, 1)), legend: [loan defaults, 0.731]),
        addplot(draw: orange, line-width: widths.thick, coords: ((0, 0), (0, 0.262), (0.001, 0.263), (0.001, 0.265), (0.003, 0.274), (0.008, 0.294), (0.024, 0.361), (0.059, 0.45), (0.08, 0.51), (0.099, 0.547), (0.131, 0.594), (0.19, 0.662), (0.256, 0.731), (0.315, 0.774), (0.414, 0.834), (0.518, 0.897), (0.617, 0.94), (0.732, 0.972), (0.845, 0.992), (1, 1)), legend: [hotel, 0.824]),
        addplot(draw: muted, dash: "dashed", domain: (0, 1), x => x, legend: [random, 0.50]),
      ),
      nextgroupplot(title: [Precision-recall curve], xlabel: [Recall], ylabel: [Precision], legend-style: (at: (0.03, 0.05), anchor: "south-west"),
        addplot(draw: blue, line-width: widths.thick, coords: ((0.002, 0.667), (0.013, 0.632), (0.025, 0.545), (0.056, 0.568), (0.098, 0.537), (0.164, 0.503), (0.231, 0.475), (0.302, 0.437), (0.397, 0.411), (0.506, 0.377), (0.647, 0.337), (0.794, 0.289), (0.922, 0.237), (0.991, 0.199), (1, 0.192)), legend: [loan defaults]),
        addplot(draw: orange, line-width: widths.thick, coords: ((0.262, 0.997), (0.263, 0.994), (0.265, 0.992), (0.274, 0.983), (0.294, 0.96), (0.361, 0.903), (0.45, 0.829), (0.51, 0.8), (0.547, 0.777), (0.594, 0.741), (0.662, 0.687), (0.731, 0.643), (0.774, 0.608), (0.834, 0.56), (0.897, 0.522), (0.94, 0.49), (0.972, 0.456), (0.992, 0.426), (1, 0.387)), legend: [hotel]),
        addplot(draw: muted, dash: "dashed", domain: (0, 1), x => 0.387, legend: [hotel positive rate]),
        addplot(draw: mix(blue, 50%), dash: "dashed", domain: (0, 1), x => 0.192, legend: [loan positive rate]),
      ),
    )
  })
]

Rarity changes the story. Lab~5’s fraud ranking has a ROC AUC of 0.95, which sounds excellent. Fraud is 0.17% of those 85,443 transactions, so among the top 100 flagged ones only 39 are fraud, and its average precision is 0.22. Most of the ROC credit comes from correctly ranking tens of thousands of ordinary transactions below a few hundred unusual ones.

#keyidea[
  For rare positives, inspect precision--recall at the intended operating point. Strong ROC AUC can coexist with poor alert precision.
]

== Cross-validation <sec:cross-validation>

#analogy[
  One mock exam can be easy or hard by chance. Set five, each covering a different part of the syllabus, and the average tells you far more. #term[$k$-fold cross-validation] does this with your data: train on $k-1$ folds, validate on the remaining one, and rotate until every fold has been held out.
]

#utpfig([Five-fold cross-validation stays inside the development data. Each round validates on one fold and trains on the other four; the untouched test set is not a sixth fold and is never used for tuning.], label: <fig:cv-folds>)[
  #canvas({
    node((0, 3.55), [Five-fold cross-validation stays inside the development data], font: font("small", weight: "bold", fill: navy), anchor: "west")
    for (r, yy, lab-v) in ((0, 2.85, 1), (1, 2.33, 2), (2, 1.81, 3), (3, 1.29, 4), (4, 0.77, 5)) {
      node((0.85, yy), [round #lab-v], font: font("script"), anchor: "east", text: muted)
      for (c, xx) in ((0, 1.05), (1, 2.43), (2, 3.81), (3, 5.19), (4, 6.57)) {
        let isvalid = int(c == r)
        if isvalid == 1 {
          rectangle((xx, yy - 0.2), (xx + 1.23, yy + 0.2), fill: pale-orange, draw: orange, rounded: 0.7mm)
          node((xx + 0.615, yy), [validate], font: font("script"), text: orange)
        } else {
          rectangle((xx, yy - 0.2), (xx + 1.23, yy + 0.2), fill: pale-blue, draw: mix(blue, 65%), rounded: 0.7mm)
          node((xx + 0.615, yy), [train], font: font("script"), text: blue)
        }
      }
    }
    rectangle((8.45, 0.45), (11.2, 2.95), line-width: widths.very-thick, rounded: 1mm, draw: red)
    node((9.825, 2.1), [Untouched \
  test set], align: center, font: font("small", weight: "bold", fill: red))
    node((9.825, 1.15), [not a sixth fold \
  not used for tuning], font: font("script"), align: center, text: muted)
    connect((7.95, 1.7), (8.32, 1.7), line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((6.25, 0.05), [average the five validation scores, choose the model, then evaluate the locked choice once], font: font("script"), align: center, text: teal)
  })
]

#workedexample[
  Lab~2’s churn model, five folds of the training rows: ROC AUC 0.860, 0.863, 0.824, 0.835, 0.841. The mean is 0.844 and the standard deviation 0.015. Any claim that one model beats this one by 0.01 should be met with suspicion, since the folds themselves disagree by more than that.
]

Cross-validation must preserve the data structure:

- stratify folds for imbalanced classification;
- keep related observations in the same group fold;
- use forward or rolling validation for time series;
- fit preprocessing and feature selection separately inside each training fold.

After selecting a model and hyperparameters, refit on the allowed training data and evaluate once on the untouched test set.

#keepspace(216.8pt)

=== Choose the cross-validation splitter that matches the data

#utptable[
  #tabularx(
    columns: (27%, 33%, 1fr),
    styles: (navy-bold,),
    header: ([Splitter (scikit-learn)], [Use it when], [Course example]),
    [`KFold`], [Rows are independent and the label is a number.], [House prices in Lab~3],
    [`StratifiedKFold`], [Classification, especially with an imbalanced label; every fold keeps the class proportions.], [Churn in Lab~2, loan defaults in Lab~3],
    [`GroupKFold`], [Several rows belong to one person, device, or school; all of them must land in the same fold.], [Repeated patient visits],
    [`TimeSeriesSplit`], [Rows are ordered in time; each fold trains on the past and validates on what came next.], [Hotel bookings in Lab~2 use one chronological cut for the same reason],
  )
]

#keyidea[
  Use the same splitter for every candidate so comparisons measure model differences.
]

#secondpass[
  The core workflow is complete. Return to probability quality, uncertainty, subgroup analysis, and shift when the application requires them.
]

== Evaluating probabilities

Some applications need accurate probabilities, not merely correct rankings. Binary log loss is

$ -frac(1, n) sum _(i=1)^n [y_i log p_i+(1-y_i)log(1-p_i)]. $

The Brier score is the mean squared probability error:

$ op("Brier") =frac(1, n) sum _(i=1)^n((p_i-y_i))^2. $

#workedexample[
  Four predictions, with the per-row cost under each score. Log loss charges $-log p$ when $y=1$ and $-log(1-p)$ when $y=0$; Brier charges $((p-y))^2$ either way.

  #utptable[
    #fsize("small")[

    #tabularx(
      columns: (auto, auto, auto, auto),
      align: (center, center, center, center),
      header: ([True $y$], [Predicted $p$], [Log loss], [Brier]),
      [1], [0.90], [$-ln 0.90 = 0.105$], [$0.01$],
      [1], [0.60], [$-ln 0.60 = 0.511$], [$0.16$],
      [0], [0.30], [$-ln 0.70 = 0.357$], [$0.09$],
      [0], [0.05], [$-ln 0.95 = 0.051$], [$0.0025$],
      table.hline(stroke: 0.55pt + rule-color),
      multicolumn(2, right)[mean], [$0.256$], [$0.0656$],
    )

    ]
  ]

  Now add one confidently wrong row: the true answer is $1$ and the model said $0.02$. Its Brier cost is $((0.02-1))^2=0.960$. Its log loss cost is $-ln 0.02 = 3.912$.

  Brier is bounded by~1 per binary prediction; log loss is unbounded. Reducing the wrong prediction to $p=0.001$ changes Brier from $0.960$ to $0.998$, but log loss from $3.912$ to $6.9$.

  Log loss therefore penalizes extreme confidence in a wrong answer more strongly.
]

== Uncertainty and repeated experiments

A score computed on 1,761 rows has error bars whether you draw them or not. Quantify the uncertainty with confidence intervals, the bootstrap, repeated cross-validation, or several seeds.

#workedexample[
  Lab~2’s churn model scores ROC AUC 0.846 on its 1,761 test customers. A bootstrap of those rows gives a 95% interval of 0.826 to 0.866. Refit the same model on five other random splits, and the score comes out as 0.844, 0.838, 0.855, 0.847 and 0.847. So when a rival model scores 0.856 on the same rows, nothing is settled.
]

Compare models through paired errors on the same cases. Statistical significance does not imply practical value.

== Error and subgroup analysis

Aggregate metrics can hide systematic failures. Inspect errors by class, label range, data source, time period, device type, location, and relevant demographic or operational groups.

Error analysis asks:

- Which examples have the largest or most costly errors?
- Are labels ambiguous, delayed, or incorrect?
- Are failures concentrated in rare or underrepresented groups?
- Does performance degrade as data becomes older or differs from training data?
- Are confident mistakes more common than uncertain mistakes?

Use error analysis to identify needed changes in data, features, labels, thresholds, or models.

== Evaluation under distribution shift

A test set drawn from the same source as the training data may still not look like the data the model meets after deployment. Three kinds of change have names: covariate shift (the inputs change), label shift (the class frequencies change), and concept drift (the relationship between inputs and label changes).

Stress-test missing or corrupted inputs, rare groups, seasons, and plausible worst cases. Monitor inputs, predictions, calibration, and delayed outcomes after deployment.

#keyidea[
  No single metric proves that a model is useful. Reliable evaluation combines a realistic split, a relevant baseline, task-specific metrics, uncertainty, subgroup analysis, and examination of actual errors.
]

#modelcard[Evaluation - Practical Checklist][
  #tabularx(
    columns: (24%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Objective], [Define the real decision and the cost of each kind of error.],
    [Split], [Match future use; respect time, groups, location, and repeated observations.],
    [Baseline], [Compare with a simple rule using the same data and metric.],
    [Uncertainty], [Use cross-validation, repeated splits, or confidence intervals where appropriate.],
    [Diagnosis], [Inspect errors, subgroups, calibration, threshold behavior, and distribution shift.],
    [Final report], [State the data period, metric, uncertainty, limits and untouched test result.],
  )
]

#chapterrecap[
  - Choose metrics from the decision and its error costs, before seeing results. Accuracy alone is misleading when classes are unbalanced.
  - MAE reports a typical miss, RMSE punishes large ones, and $R^2$ compares with guessing the mean.
  - The confusion matrix holds four counts. Precision asks whether a flag is right; recall asks whether positives are found.
  - A threshold is a policy, chosen on validation data. ROC AUC is the chance a positive outranks a negative. When positives are rare, look at precision at your capacity.
  - Cross-validation must respect groups, time and class balance. Scores on small sets carry wide error bars, so report them.
]

#quickcheck[
  + Describe one situation where recall should matter more than precision, and one the other way round.
  + A filter flags 50 of 500 emails. Of those 50, 30 are spam; there are 40 spam emails in all. Compute precision, recall and accuracy.
  + What usually happens to recall and false positives when a classification threshold is lowered?
  + Scores for positives are 0.9 and 0.4; scores for negatives are 0.6 and 0.2. What is the ROC AUC?
  + Why must a cross-validation splitter respect groups, time order and class balance?
  + Model A scores AUC 0.85 and model B 0.84 on 200 rows. What do you want to see before preferring A?
]
