#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-validation-preprocessing")

= Model Validation, Preprocessing, and Responsible Evaluation <ch:validation>

#chapterguide[You should be able to fit and evaluate a supervised model on a held-out test set.][explain cross-validation, avoid preprocessing leakage, compare thresholds, recognise overfitting, and report model limitations responsibly.]

== One split is one random experiment

A single train/test split can produce an optimistic or pessimistic estimate depending on which rows happen to land in the test set. #term[Cross-validation] repeats the evaluation across several held-out folds.

#utpfig([Each fold acts as validation once while the remaining folds train the model. The final performance summary combines the held-out results.], label: <fig:five-fold>)[
  #canvas(x: 16.06cm, {
    let foldcell = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1mm, line-width: 0.5978pt, text-width: 0.13 * 16.06, min-height: 0.62, inner-xsep: 1mm, inner-ysep: 1mm, align: center, font: font("script", fill: navy))
    let heldout = (..foldcell, draw: mix(teal, 80%), fill: pale-teal, font: font("script", weight: "bold", fill: navy))
    let heading-style = (font: font("script", weight: "bold", fill: navy), inner-sep: 0pt)
    node((0.095, 0.65), [Run], ..heading-style, anchor: "east")
    for c in range(0, 5) {
      let foldnumber = int(c + 1)
      node((0.2 + c * 0.16, 0.65), [Fold #foldnumber], ..heading-style)
    }
    for r in range(0, 5) {
      let runnumber = int(r + 1)
      node((0.095, -r * 0.78), [#runnumber], ..heading-style, anchor: "east")
      for c in range(0, 5) {
        if r == c {
          node((0.2 + c * 0.16, -r * 0.78), [Validate], ..heldout)
        } else {
          node((0.2 + c * 0.16, -r * 0.78), [Train], ..foldcell)
        }
      }
    }
    node((0.5, -3.85), [Each run uses four training folds and one held-out validation fold.], font: font("script", fill: muted), align: center, text-width: 0.86 * 16.06)
  })
]

#utpfig([Each bar is held-out accuracy from a different fold of the same five-fold procedure. The variation is part of the uncertainty in generalisation performance.], label: <fig:validation-fold-variation>)[
  #image("/DATA SCIENCE/figures/validation_fold_variation.pdf", width: 79%)
]

== Cross-validation estimates a process, not one final model

In $k$-fold cross-validation, $k$ temporary models are fitted to estimate how the training procedure generalises. After model choices are fixed, a final model can be refit on all available training data. The fold models are therefore evaluation instruments rather than necessarily the models that will be deployed.

Stratification is useful for classification because it keeps class proportions more consistent across folds. Grouped cross-validation is needed when observations from the same entity must stay together, such as multiple visits from one patient. Time-series data often require forward-chaining splits rather than random folds because future observations must not train models evaluated on the past.

== Preprocessing is learned from data

Centering, scaling, imputation, feature selection, and encoding all estimate information from data. Therefore they belong inside the training process.

Correct order:

#utpsteps[
  + Split training and validation/test observations.
  + Estimate preprocessing parameters from training observations only.
  + Apply those fixed parameters to validation/test observations.
  + Fit the model on processed training data and evaluate on processed held-out data.
]

#utpfig([Any step that estimates information from data must be fitted inside the training portion of each fold. The validation rows receive parameters learned elsewhere; they do not help create them.], label: <fig:validation-pipeline>)[
  #canvas(x: 16.06cm, {
    let card = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.5978pt, text-width: 0.26 * 16.06, min-height: 1.45, inner-xsep: 2.5mm, inner-ysep: 2mm, align: center, font: font("script", fill: navy))
    let warning = (..card, draw: mix(red, 80%), fill: pale-red)
    let flow = (line-width: 0.797pt, draw: teal, rounded: 1.5mm, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.797pt))
    let heading-style = (font: font("script", weight: "bold", fill: navy), anchor: "west")
    node((-0.145, 1.1), [Correct: learn preprocessing from training rows only], ..heading-style, text: mix(teal, 85%, other: black))
    node((0, 0), [#strong[Training fold] \ #v(3.9851pt)
   Training observations \
  only], name: "tr", ..card)
    node((0.335, 0), [#strong[Fit preprocessing] \ #v(3.9851pt)
   Imputer, scaler, \
  and feature selector], name: "fit", ..card)
    node((0.335, -1.8), [#strong[Validation fold] \ #v(3.9851pt)
   Held-out observations \
  Never used for fitting], name: "va", ..card, draw: mix(orange, 80%), fill: pale-orange)
    node((0.67, 0), [#strong[Transform / evaluate] \ #v(3.9851pt)
   Apply fixed training rules \
  to held-out data], name: "ev", ..card, draw: mix(teal, 80%), fill: pale-teal)
    connect("tr.east", "fit.west", ..flow)
    connect("fit.east", "ev.west", ..flow)
    connect("va.east", (0.67, -1.8), "ev.south", ..flow)
    connect((-0.145, -2.9), (0.815, -2.9), line-width: 0.4981pt, draw: mix(muted, 35%))
    node((-0.145, -3.3), [Leaky: validation rows influence preprocessing], ..heading-style, text: mix(red, 85%, other: black))
    node((0, -4.4), [#strong[All observations] \ #v(3.9851pt)
   Training and validation \
  rows combined], name: "all", ..warning)
    node((0.335, -4.4), [#strong[Fit preprocessing] \ #v(3.9851pt)
   Learn parameters \
  from all rows], name: "leakyfit", ..warning)
    node((0.67, -4.4), [#strong[Split / validate] \ #v(3.9851pt)
   Held-out information \
  has already leaked], name: "split", ..warning)
    connect("all.east", "leakyfit.west", ..flow, draw: mix(red, 80%))
    connect("leakyfit.east", "split.west", ..flow, draw: mix(red, 80%))
  })
]

#pitfall[
  Scaling the full dataset before cross-validation lets each validation fold influence its own preprocessing. The leakage may be small in some datasets, but the evaluation principle is still broken.
]

== Standardisation aligns feature scales

For feature $x$, standardisation uses

$ z=frac(x- mu _(t r a i n), sigma _(t r a i n)). $

This is important for distance-based and regularised methods. Tree-based models are much less sensitive to monotonic scaling, which is why preprocessing should match the algorithm rather than be applied ritualistically.

#utpfig([Raw features can have completely different numerical ranges. Standardisation places them in standard-deviation units, which matters when distances or coefficient penalties compare features directly.], label: <fig:validation-scaling>)[
  #image("/DATA SCIENCE/figures/validation_scaling.pdf", width: 92%)
]

#utpfig([After standardisation the selected features share center and scale units, but their shapes remain different. Preprocessing changes representation; it does not make the data Gaussian or remove outliers.], label: <fig:validation-scaled-shapes>)[
  #image("/DATA SCIENCE/figures/validation_scaled_distributions.pdf", width: 80%)
]

== Hyperparameter tuning needs its own validation logic

When cross-validation is used repeatedly to choose model complexity, features, or hyperparameters, the chosen configuration can become optimistic with respect to those same folds. A separate final test set or nested cross-validation provides a cleaner estimate of performance after tuning.

This principle generalises: any choice influenced by evaluation data---including threshold selection, feature selection, and architecture choice---has consumed some information from those data.

== Overfitting is a gap between fit and generalisation

Overfitting occurs when a model captures training-specific noise or idiosyncrasy. Symptoms include excellent training performance with substantially poorer held-out performance and unstable results across folds.

== Thresholds, metrics, and stakeholder costs

Different thresholds produce different confusion matrices. Model evaluation should include the metrics relevant to the actual action: detecting positives, avoiding false alarms, controlling workload, or balancing costs.

== Report the distribution of performance, not only the mean

A mean cross-validation score can hide instability. Report fold scores, their spread, and any unusually weak fold. If performance depends strongly on one split, investigate whether data scarcity, subgroup imbalance, temporal drift, or duplicated entities are responsible.

== Subgroup evaluation needs careful denominators

When performance is compared across groups, show group sample sizes and uncertainty as well as point metrics. A large difference in estimated error rates can be mostly sampling noise when a subgroup is small. Conversely, a good overall score can hide systematic failure in an important subgroup.

== Responsible evaluation goes beyond a single metric

Check performance by meaningful subgroups when appropriate, report data provenance and exclusions, disclose uncertainty, and distinguish a teaching exercise from a deployable system. Protected or sensitive attributes require particularly careful governance and fairness analysis.

#keyidea[
  A model report should make failure visible: where the data came from, what preprocessing was learned, how validation was performed, which errors remain, and where the model should not be used.
]

#workedexample[
  Lab 9 estimates scaling parameters separately inside each fold before fitting logistic regression. This small implementation detail is a core scientific principle: held-out data must remain genuinely held out.
]

#quickcheck[
  + What does cross-validation improve compared with one random split?
  + Which data should determine the scaling mean and standard deviation?
  + Name one symptom of overfitting.
  + Why might two stakeholders choose different classification thresholds for the same model?
]

== Worked validation problem: rare-event fraud detection

Credit-card fraud is a classic example of why validation metrics must match the data-generating problem. In the bundled 10,000-transaction file, only 151 records are labelled fraud---a prevalence of 1.51%.

#utpfig([A classifier that predicts every transaction as legitimate would already achieve 98.49% accuracy. The right panel shows that some features nevertheless differ sharply between fraud and legitimate transactions.], label: <fig:val-fraud-imbalance>)[
  #image("/DATA SCIENCE/figures/validation_fraud_imbalance.pdf", width: 90%)
]

This is why precision, recall/sensitivity, specificity, false-positive rate, and threshold choice must be considered together. The best operating point depends on the relative cost of interrupting a legitimate customer versus missing a fraudulent transaction.

#utpfig([Changing the decision threshold moves the model along a precision--recall trade-off. Validation should compare thresholds on held-out data rather than selecting a threshold from training performance.], label: <fig:val-fraud-threshold>)[
  #image("/DATA SCIENCE/figures/validation_fraud_thresholds.pdf", width: 82%)
]

Fraud examples also make preprocessing leakage easier to understand. If scaling parameters, category encodings, resampling rules, or threshold choices are tuned using the full dataset before cross-validation, information from validation folds has influenced the training pipeline even if the final model never directly sees their labels.

== Calibration is a validation target when probabilities drive action

A classifier can rank cases well while producing probabilities that are systematically too high or too low. This distinction matters when a probability is used for triage, pricing, resource allocation, or threshold selection. Calibration compares predicted probability with observed event frequency among cases receiving similar scores.

#utpfig([Points near the diagonal indicate agreement between predicted probability and observed positive frequency within score bins. Departures from the diagonal are a reason to investigate calibration, sample size, model specification, or distribution shift.], label: <fig:validation-heart-calibration>)[
  #image("/DATA SCIENCE/figures/validation_heart_calibration.pdf", width: 68%)
]

Calibration should be estimated on data that did not fit the model. If a separate calibration method is learned, it needs its own validation discipline as well. A well-calibrated probability is still not a causal probability, and good calibration in one population does not guarantee calibration after deployment conditions change.
