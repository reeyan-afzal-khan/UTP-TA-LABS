#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-classification")

= Classification and Decision Thresholds <ch:classification>

#chapterguide[You should understand train/test evaluation and numeric prediction metrics.][fit a binary logistic model, convert probabilities to decisions, construct a confusion matrix, and explain accuracy, precision, sensitivity, and specificity.]

== Classification predicts categories

A binary classifier estimates evidence for one of two outcomes, such as fraud/not fraud, churn/stay, or malignant/benign. Many classifiers first produce a probability-like score and then apply a threshold to make a class decision.

For logistic regression,

$ P(Y=1 divides x)=frac(1, 1+e^(- eta)), wide eta = beta _0+ beta _1 x_1+ dots.c + beta _p x_p. $

== Logistic regression models log-odds linearly

The logistic curve converts the unconstrained linear predictor $eta$ into a value between zero and one. Equivalently,

$ log(frac(p, 1-p))= beta _0+ beta _1 x_1+ dots.c + beta _p x_p, $

so each coefficient changes the #term[log-odds] of the positive class conditionally on the other included variables. Exponentiating a coefficient gives an odds ratio for a one-unit feature change, but this remains an associational model unless the design supports causal interpretation.

#utpfig([The S-shaped logistic function compresses extreme linear scores toward probabilities near 0 and 1 while mapping a score of zero to probability 0.5.], label: <fig:classification-sigmoid>)[
  #image("/DATA SCIENCE/figures/classification_sigmoid.pdf", width: 80%)
]

== The confusion matrix is the evaluation foundation

#utptable[
  #tabularx(
    columns: (2.8cm, 1fr, 5.5cm),
    styles: (navy-bold,),
    header: ([Outcome], [Meaning], [Example in a medical screening context]),
    [True positive], [predicted positive, actually positive], [malignant case flagged],
    [False positive], [predicted positive, actually negative], [benign case flagged],
    [True negative], [predicted negative, actually negative], [benign case not flagged],
    [False negative], [predicted negative, actually positive], [malignant case missed],
  )
]

From these counts:

$ "Sensitivity"=frac(T P, T P+F N), wide "Specificity"=frac(T N, T N+F P), wide "Precision"=frac(T P, T P+F P). $

Accuracy is $(T P+T N)\/N$.

#utpfig([Counts retain the direction of each mistake. Reporting only accuracy would hide whether errors are mostly false positives or false negatives.], label: <fig:classification-cm>)[
  #image("/DATA SCIENCE/figures/classification_confusion_matrix.pdf", width: 58%)
]

== Metrics answer different operational questions

Sensitivity asks, “Of the actual positives, how many did we find?” Specificity asks the corresponding question for negatives. Precision asks, “Of the cases we flagged positive, how many were actually positive?” These denominators differ, so the metrics answer different questions.

Precision is especially sensitive to prevalence. A classifier can have similar sensitivity and specificity in two populations but very different precision if the event is much rarer in one population.

== Accuracy can fail on imbalanced data

If 99% of cases are negative, predicting “negative” every time yields 99% accuracy and zero ability to find positives. Metric choice must reflect the operational cost of mistakes.

#warning[
  There is no universally correct threshold of 0.5. Lowering the threshold usually catches more positives but also creates more false positives. The right trade-off depends on consequences, prevalence, and downstream capacity.
]

#utpfig([Predicted-score distributions for the two classes overlap. Moving the threshold changes which part of the overlap becomes false positive or false negative.], label: <fig:classification-overlap>)[
  #image("/DATA SCIENCE/figures/classification_score_overlap.pdf", width: 82%)
]

#utpfig([The probability model and the decision rule are separate. Changing the threshold can change false-negative and false-positive rates without refitting the model.], label: <fig:threshold-tradeoff>)[
  #canvas(x: 16.06cm, {
    let stage = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.14 * 16.06, min-width: 0.19 * 16.06, min-height: 1.7, inner-xsep: 3mm, inner-ysep: 2.5mm, align: center, font: font("script", fill: navy))
    let flow = (line-width: 0.8966pt, draw: teal, end: arrow-tip("Stealth", length: 2.2mm, width: 1.6mm, line: 0.8966pt))
    node((0.11, 0), [#text(fill: teal)[#strong[01 SCORE]] \ #v(4.9813pt)
   #strong[Model outputs] \ #v(3.9851pt)
   Scores or probabilities], name: "p", ..stage, draw: mix(teal, 80%), fill: pale-teal)
    node((0.37, 0), [#text(fill: mix(orange, 85%, other: black))[#strong[02 THRESHOLD]] \ #v(4.9813pt)
   #strong[Choose cutoff] \ #v(3.9851pt)
   Set the decision rule], name: "t", ..stage, draw: mix(orange, 80%), fill: pale-orange)
    node((0.63, 0), [#text(fill: blue)[#strong[03 DECIDE]] \ #v(4.9813pt)
   #strong[Class decisions] \ #v(3.9851pt)
   Positive or negative], name: "d", ..stage)
    node((0.89, 0), [#text(fill: teal)[#strong[04 EVALUATE]] \ #v(4.9813pt)
   #strong[Measure errors] \ #v(3.9851pt)
   Confusion matrix and costs], name: "c", ..stage, draw: mix(teal, 80%), fill: pale-teal)
    connect("p.east", "t.west", ..flow)
    connect("t.east", "d.west", ..flow)
    connect("d.east", "c.west", ..flow)
  })
]

#utpfig([Sensitivity, specificity, and precision move differently as the same fitted model is evaluated at different decision thresholds. The choice must be connected to real error costs.], label: <fig:classification-threshold-metrics>)[
  #image("/DATA SCIENCE/figures/classification_threshold_metrics.pdf", width: 84%)
]

== Ranking, discrimination, and calibration are different

A model can rank positive cases above negative cases well but still produce poorly calibrated probabilities. Conversely, a model can be reasonably calibrated overall yet weak at separating individual cases. Receiver-operating-characteristic and precision--recall curves summarise threshold behaviour across many cutoffs, while calibration plots compare predicted probabilities with observed event frequencies.

No single curve removes the need to choose an operating point when the system must ultimately make decisions.

== Probabilities need interpretation, not just labels

A probability output lets analysts rank cases and choose thresholds. It should still be checked for calibration: among cases assigned around 0.8 risk, does the event occur roughly 80% of the time? Calibration is distinct from classification accuracy.

#example[
  In Lab 8 the target is `HeartDisease` in the bundled heart-failure dataset. The exercise demonstrates probability estimation and error metrics. It is not a clinical diagnostic system and should not be interpreted as one.
]

#note[
  Classification performance is multi-dimensional. Always ask which error matters, for whom, and under what prevalence and deployment conditions.
]

#questions[
  + Why can accuracy be misleading with rare positive cases?
  + What does sensitivity measure?
  + What happens to false positives and false negatives when a threshold changes?
  + Why is calibration different from accuracy?
]

== Two classification datasets, two different lessons

The Heart Failure and Breast Cancer datasets both have binary outcomes, but they illustrate different modelling issues.

#utpfig([Age and maximum heart rate provide useful signal but no clean separating boundary. Logistic regression therefore estimates a probability rather than claiming that one measurement combination deterministically defines disease.], label: <fig:class-heart>)[
  #image("/DATA SCIENCE/figures/classification_heart_age_maxhr.pdf", width: 80%)
]

Heart disease is present in about 55.3% of the 918 records. Mean maximum heart rate is lower in the labelled heart-disease group (about 128) than in the non-disease group (about 148), but the distributions overlap. Categorical predictors such as chest-pain type and ST slope contribute information that cannot be represented by this two-dimensional picture.

#utpfig([Mean radius and mean texture separate many benign and malignant records, yet overlap remains. The full dataset includes many related measurements, creating both predictive opportunity and redundancy.], label: <fig:class-breast>)[
  #image("/DATA SCIENCE/figures/classification_breast_features.pdf", width: 80%)
]

In the Breast Cancer file, about 37.3% of records are malignant. Mean radius averages about 17.46 for malignant records versus 12.15 for benign records. A classifier can exploit such differences, but evaluation must be performed on unseen data and should report error types that match the decision context.

== High-dimensional extension: handwritten digits

The bundled `optical_recognition_handwritten_digits.zip` contains a training file with 3,823 examples and a test file with 1,797 examples. Each observation contains 64 pixel-intensity features arranged conceptually as an $8 times 8$ image plus a digit label from 0 to 9. The values range from 0 to 16 and describe local pixel density rather than a photograph stored as an image file.

#utpfig([The ten panels reconstruct one example of each digit from the 64 numeric feature values. The classifier receives a vector of numbers; the image layout is domain knowledge that helps humans understand what those numbers mean.], label: <fig:class-digits-examples>)[
  #image("/DATA SCIENCE/figures/classification_digits_examples.pdf", width: 86%)
]

This dataset extends binary classification in three important ways. First, the outcome has ten classes, so evaluation needs a $10 times 10$ confusion matrix or per-class metrics rather than one sensitivity/specificity pair. Second, 64 dimensions make direct visualisation impossible. Third, the supplied train/test split reflects different writers, which can be more demanding than randomly mixing records from the same writer across both sets.

#utpfig([PCA compresses the 64 standardised pixel features into two directions for visual inspection. Some digits form visible regions, but extensive overlap remains; a two-dimensional plot is an interpretation tool, not the classifier itself.], label: <fig:class-digits-pca>)[
  #image("/DATA SCIENCE/figures/classification_digits_pca.pdf", width: 80%)
]

Multiclass performance should be reported at more than one level. Overall accuracy answers “how often is the label correct?” while a confusion matrix reveals which digits are confused. Macro-averaged metrics give each digit equal weight; frequency-weighted metrics emphasise common digits. These choices matter whenever class frequencies differ.

#note[
  High dimensionality is not only “many columns.” It changes distance, visualisation, model complexity, and validation. The digits data provide a bridge from classification to PCA and representation learning while also showing why the data-generating split matters.
]
