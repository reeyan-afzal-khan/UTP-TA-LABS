#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-classification")


#heading(level: 1)[Classification and Decision Thresholds]
 <ch:classification> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand train/test evaluation and numeric prediction metrics.

*By the end, you can:* fit a binary logistic model, convert probabilities to decisions, construct a confusion matrix, and explain accuracy, precision, sensitivity, and specificity.]


#heading(level: 2)[Classification predicts categories]
 A binary classifier estimates evidence for one of two outcomes, such as fraud/not fraud, churn/stay, or malignant/benign. Many classifiers first produce a probability-like score and then apply a threshold to make a class decision.

For logistic regression, $ P \( Y = 1 divides x \) = frac(1, 1 + e^(- eta)) \, #h(2em) eta = beta_0 + beta_1 x_1 + dots.h.c + beta_p x_p . $


#heading(level: 2)[Logistic regression models log-odds linearly]
 The logistic curve converts the unconstrained linear predictor $eta$ into a value between zero and one. Equivalently, $ log (frac(p, 1 - p)) = beta_0 + beta_1 x_1 + dots.h.c + beta_p x_p \, $ so each coefficient changes the #strong[log-odds] of the positive class conditionally on the other included variables. Exponentiating a coefficient gives an odds ratio for a one-unit feature change, but this remains an associational model unless the design supports causal interpretation.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/classification_sigmoid.svg", width: 90%)], caption: [The S-shaped logistic function compresses extreme linear scores toward probabilities near 0 and 1 while mapping a score of zero to probability 0.5.]) <fig:classification-sigmoid>


#heading(level: 2)[The confusion matrix is the evaluation foundation]
 #figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Outcome], [Meaning], [Example in a medical screening context],),
    table.hline(),
    [True positive], [predicted positive, actually positive], [malignant case flagged],
    [False positive], [predicted positive, actually negative], [benign case flagged],
    [True negative], [predicted negative, actually negative], [benign case not flagged],
    [False negative], [predicted negative, actually positive], [malignant case missed],
  )]
  , kind: table
  )

From these counts: $ upright("Sensitivity") = frac(T P, T P + F N) \, #h(2em) upright("Specificity") = frac(T N, T N + F P) \, #h(2em) upright("Precision") = frac(T P, T P + F P) . $ Accuracy is $\( T P + T N \) \/ N$.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/classification_confusion_matrix.svg", width: 90%)], caption: [Counts retain the direction of each mistake. Reporting only accuracy would hide whether errors are mostly false positives or false negatives.]) <fig:classification-cm>


#heading(level: 2)[Metrics answer different operational questions]
 Sensitivity asks, "Of the actual positives, how many did we find?" Specificity asks the corresponding question for negatives. Precision asks, "Of the cases we flagged positive, how many were actually positive?" These denominators differ, so the metrics answer different questions.

Precision is especially sensitive to prevalence. A classifier can have similar sensitivity and specificity in two populations but very different precision if the event is much rarer in one population.


#heading(level: 2)[Accuracy can fail on imbalanced data]
 If 99% of cases are negative, predicting "negative" every time yields 99% accuracy and zero ability to find positives. Metric choice must reflect the operational cost of mistakes.

#callout("pitfall", title: [Analytical pitfall])[There is no universally correct threshold of 0.5. Lowering the threshold usually catches more positives but also creates more false positives. The right trade-off depends on consequences, prevalence, and downstream capacity.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/classification_score_overlap.svg", width: 90%)], caption: [Predicted-score distributions for the two classes overlap. Moving the threshold changes which part of the overlap becomes false positive or false negative.]) <fig:classification-overlap>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/2a1b2e5ff995d5b0.svg")], caption: [The probability model and the decision rule are separate. Changing the threshold can change false-negative and false-positive rates without refitting the model.]) <fig:threshold-tradeoff>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/classification_threshold_metrics.svg", width: 90%)], caption: [Sensitivity, specificity, and precision move differently as the same fitted model is evaluated at different decision thresholds. The choice must be connected to real error costs.]) <fig:classification-threshold-metrics>


#heading(level: 2)[Ranking, discrimination, and calibration are different]
 A model can rank positive cases above negative cases well but still produce poorly calibrated probabilities. Conversely, a model can be reasonably calibrated overall yet weak at separating individual cases. Receiver-operating-characteristic and precision--recall curves summarise threshold behaviour across many cutoffs, while calibration plots compare predicted probabilities with observed event frequencies.

No single curve removes the need to choose an operating point when the system must ultimately make decisions.


#heading(level: 2)[Probabilities need interpretation, not just labels]
 A probability output lets analysts rank cases and choose thresholds. It should still be checked for calibration: among cases assigned around 0.8 risk, does the event occur roughly 80% of the time? Calibration is distinct from classification accuracy.

#callout("workedexample", title: [Worked example])[In Lab 8 the target is `HeartDisease` in the bundled heart-failure dataset. The exercise demonstrates probability estimation and error metrics. It is not a clinical diagnostic system and should not be interpreted as one.]

#callout("keyidea", title: [Key idea])[Classification performance is multi-dimensional. Always ask which error matters, for whom, and under what prevalence and deployment conditions.] #callout("quickcheck", title: [Check your understanding])[+ Why can accuracy be misleading with rare positive cases?

+ What does sensitivity measure?

+ What happens to false positives and false negatives when a threshold changes?

+ Why is calibration different from accuracy?]


#heading(level: 2)[Two classification datasets, two different lessons]


The Heart Failure and Breast Cancer datasets both have binary outcomes, but they illustrate different modelling issues.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/classification_heart_age_maxhr.svg", width: 90%)], caption: [Age and maximum heart rate provide useful signal but no clean separating boundary. Logistic regression therefore estimates a probability rather than claiming that one measurement combination deterministically defines disease.]) <fig:class-heart>

Heart disease is present in about 55.3% of the 918 records. Mean maximum heart rate is lower in the labelled heart-disease group (about 128) than in the non-disease group (about 148), but the distributions overlap. Categorical predictors such as chest-pain type and ST slope contribute information that cannot be represented by this two-dimensional picture.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/classification_breast_features.svg", width: 90%)], caption: [Mean radius and mean texture separate many benign and malignant records, yet overlap remains. The full dataset includes many related measurements, creating both predictive opportunity and redundancy.]) <fig:class-breast>

In the Breast Cancer file, about 37.3% of records are malignant. Mean radius averages about 17.46 for malignant records versus 12.15 for benign records. A classifier can exploit such differences, but evaluation must be performed on unseen data and should report error types that match the decision context.


#heading(level: 2)[High-dimensional extension: handwritten digits]


The bundled `optical_recognition_handwritten_digits.zip` contains a training file with 3,823 examples and a test file with 1,797 examples. Each observation contains 64 pixel-intensity features arranged conceptually as an $8 times 8$ image plus a digit label from 0 to 9. The values range from 0 to 16 and describe local pixel density rather than a photograph stored as an image file.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/classification_digits_examples.svg", width: 90%)], caption: [The ten panels reconstruct one example of each digit from the 64 numeric feature values. The classifier receives a vector of numbers; the image layout is domain knowledge that helps humans understand what those numbers mean.]) <fig:class-digits-examples>

This dataset extends binary classification in three important ways. First, the outcome has ten classes, so evaluation needs a $10 times 10$ confusion matrix or per-class metrics rather than one sensitivity/specificity pair. Second, 64 dimensions make direct visualisation impossible. Third, the supplied train/test split reflects different writers, which can be more demanding than randomly mixing records from the same writer across both sets.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/classification_digits_pca.svg", width: 90%)], caption: [PCA compresses the 64 standardised pixel features into two directions for visual inspection. Some digits form visible regions, but extensive overlap remains; a two-dimensional plot is an interpretation tool, not the classifier itself.]) <fig:class-digits-pca>

Multiclass performance should be reported at more than one level. Overall accuracy answers "how often is the label correct?" while a confusion matrix reveals which digits are confused. Macro-averaged metrics give each digit equal weight; frequency-weighted metrics emphasise common digits. These choices matter whenever class frequencies differ.

#callout("keyidea", title: [Key idea])[High dimensionality is not only "many columns." It changes distance, visualisation, model complexity, and validation. The digits data provide a bridge from classification to PCA and representation learning while also showing why the data-generating split matters.]
