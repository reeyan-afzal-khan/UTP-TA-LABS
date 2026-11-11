#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-validation-preprocessing")


#heading(level: 1)[Model Validation, Preprocessing, and Responsible Evaluation]
 <ch:validation> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should be able to fit and evaluate a supervised model on a held-out test set.

*By the end, you can:* explain cross-validation, avoid preprocessing leakage, compare thresholds, recognise overfitting, and report model limitations responsibly.]


#heading(level: 2)[One split is one random experiment]
 A single train/test split can produce an optimistic or pessimistic estimate depending on which rows happen to land in the test set. #strong[Cross-validation] repeats the evaluation across several held-out folds.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/ea3b58c02684491a.svg")], caption: [Each fold acts as validation once while the remaining folds train the model. The final performance summary combines the held-out results.]) <fig:five-fold>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/validation_fold_variation.svg", width: 90%)], caption: [Each bar is held-out accuracy from a different fold of the same five-fold procedure. The variation is part of the uncertainty in generalisation performance.]) <fig:validation-fold-variation>


#heading(level: 2)[Cross-validation estimates a process, not one final model]
 In $k$-fold cross-validation, $k$ temporary models are fitted to estimate how the training procedure generalises. After model choices are fixed, a final model can be refit on all available training data. The fold models are therefore evaluation instruments rather than necessarily the models that will be deployed.

Stratification is useful for classification because it keeps class proportions more consistent across folds. Grouped cross-validation is needed when observations from the same entity must stay together, such as multiple visits from one patient. Time-series data often require forward-chaining splits rather than random folds because future observations must not train models evaluated on the past.


#heading(level: 2)[Preprocessing is learned from data]
 Centering, scaling, imputation, feature selection, and encoding all estimate information from data. Therefore they belong inside the training process.

Correct order:

+ Split training and validation/test observations.

+ Estimate preprocessing parameters from training observations only.

+ Apply those fixed parameters to validation/test observations.

+ Fit the model on processed training data and evaluate on processed held-out data.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/d1ec1d0f24d72422.svg")], caption: [Any step that estimates information from data must be fitted inside the training portion of each fold. The validation rows receive parameters learned elsewhere; they do not help create them.]) <fig:validation-pipeline>

#callout("pitfall", title: [Analytical pitfall])[Scaling the full dataset before cross-validation lets each validation fold influence its own preprocessing. The leakage may be small in some datasets, but the evaluation principle is still broken.]


#heading(level: 2)[Standardisation aligns feature scales]
 For feature $x$, standardisation uses $ z = frac(x - mu_(t r a i n), sigma_(t r a i n)) . $ This is important for distance-based and regularised methods. Tree-based models are much less sensitive to monotonic scaling, which is why preprocessing should match the algorithm rather than be applied ritualistically.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/validation_scaling.svg", width: 90%)], caption: [Raw features can have completely different numerical ranges. Standardisation places them in standard-deviation units, which matters when distances or coefficient penalties compare features directly.]) <fig:validation-scaling>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/validation_scaled_distributions.svg", width: 90%)], caption: [After standardisation the selected features share center and scale units, but their shapes remain different. Preprocessing changes representation; it does not make the data Gaussian or remove outliers.]) <fig:validation-scaled-shapes>


#heading(level: 2)[Hyperparameter tuning needs its own validation logic]
 When cross-validation is used repeatedly to choose model complexity, features, or hyperparameters, the chosen configuration can become optimistic with respect to those same folds. A separate final test set or nested cross-validation provides a cleaner estimate of performance after tuning.

This principle generalises: any choice influenced by evaluation data---including threshold selection, feature selection, and architecture choice---has consumed some information from those data.


#heading(level: 2)[Overfitting is a gap between fit and generalisation]
 Overfitting occurs when a model captures training-specific noise or idiosyncrasy. Symptoms include excellent training performance with substantially poorer held-out performance and unstable results across folds.


#heading(level: 2)[Thresholds, metrics, and stakeholder costs]
 Different thresholds produce different confusion matrices. Model evaluation should include the metrics relevant to the actual action: detecting positives, avoiding false alarms, controlling workload, or balancing costs.


#heading(level: 2)[Report the distribution of performance, not only the mean]
 A mean cross-validation score can hide instability. Report fold scores, their spread, and any unusually weak fold. If performance depends strongly on one split, investigate whether data scarcity, subgroup imbalance, temporal drift, or duplicated entities are responsible.


#heading(level: 2)[Subgroup evaluation needs careful denominators]
 When performance is compared across groups, show group sample sizes and uncertainty as well as point metrics. A large difference in estimated error rates can be mostly sampling noise when a subgroup is small. Conversely, a good overall score can hide systematic failure in an important subgroup.


#heading(level: 2)[Responsible evaluation goes beyond a single metric]
 Check performance by meaningful subgroups when appropriate, report data provenance and exclusions, disclose uncertainty, and distinguish a teaching exercise from a deployable system. Protected or sensitive attributes require particularly careful governance and fairness analysis.

#callout("keyidea", title: [Key idea])[A model report should make failure visible: where the data came from, what preprocessing was learned, how validation was performed, which errors remain, and where the model should not be used.]

#callout("workedexample", title: [Worked example])[Lab 9 estimates scaling parameters separately inside each fold before fitting logistic regression. This small implementation detail is a core scientific principle: held-out data must remain genuinely held out.]

#callout("quickcheck", title: [Check your understanding])[+ What does cross-validation improve compared with one random split?

+ Which data should determine the scaling mean and standard deviation?

+ Name one symptom of overfitting.

+ Why might two stakeholders choose different classification thresholds for the same model?]


#heading(level: 2)[Worked validation problem: rare-event fraud detection]


Credit-card fraud is a classic example of why validation metrics must match the data-generating problem. In the bundled 10,000-transaction file, only 151 records are labelled fraud---a prevalence of 1.51%.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/validation_fraud_imbalance.svg", width: 90%)], caption: [A classifier that predicts every transaction as legitimate would already achieve 98.49% accuracy. The right panel shows that some features nevertheless differ sharply between fraud and legitimate transactions.]) <fig:val-fraud-imbalance>

This is why precision, recall/sensitivity, specificity, false-positive rate, and threshold choice must be considered together. The best operating point depends on the relative cost of interrupting a legitimate customer versus missing a fraudulent transaction.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/validation_fraud_thresholds.svg", width: 90%)], caption: [Changing the decision threshold moves the model along a precision--recall trade-off. Validation should compare thresholds on held-out data rather than selecting a threshold from training performance.]) <fig:val-fraud-threshold>

Fraud examples also make preprocessing leakage easier to understand. If scaling parameters, category encodings, resampling rules, or threshold choices are tuned using the full dataset before cross-validation, information from validation folds has influenced the training pipeline even if the final model never directly sees their labels.


#heading(level: 2)[Calibration is a validation target when probabilities drive action]


A classifier can rank cases well while producing probabilities that are systematically too high or too low. This distinction matters when a probability is used for triage, pricing, resource allocation, or threshold selection. Calibration compares predicted probability with observed event frequency among cases receiving similar scores.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/validation_heart_calibration.svg", width: 90%)], caption: [Points near the diagonal indicate agreement between predicted probability and observed positive frequency within score bins. Departures from the diagonal are a reason to investigate calibration, sample size, model specification, or distribution shift.]) <fig:validation-heart-calibration>

Calibration should be estimated on data that did not fit the model. If a separate calibration method is learned, it needs its own validation discipline as well. A well-calibrated probability is still not a causal probability, and good calibration in one population does not guarantee calibration after deployment conditions change.
