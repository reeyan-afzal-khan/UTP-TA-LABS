#import "/.shared/typst/utp.typ": *
#unit("chapters", "07-regression")

= Regression for Numeric Prediction <ch:regression>

#chapterguide[You should understand relationships, sampling uncertainty, and the difference between exploration and validation.][fit a multiple linear regression, interpret coefficients cautiously, evaluate predictions on held-out data, and diagnose residual errors.]

== Regression predicts a numeric target

In supervised learning, the dataset includes an outcome to be predicted. #term[Regression] is used when that target is numeric, such as price, demand, temperature, or concentration.

A multiple linear model has the form

$ hat(y)= beta _0 + beta _1 x_1 + dots.c + beta _p x_p. $

The coefficients describe modelled changes in the prediction while holding the other included features fixed. That is not automatically a causal effect.

== What a fitted line is minimising

Ordinary least squares chooses coefficients to minimise the sum of squared residuals. In a one-feature model, each residual is the vertical difference between the observed target and the fitted line.

#utpfig([The vertical segments are residuals. Squaring them makes large errors contribute disproportionately to the least-squares objective.], label: <fig:regression-geometry>)[
  #image("/DATA SCIENCE/figures/regression_residual_geometry.pdf", width: 80%)
]

In multiple regression, the geometry lives in higher-dimensional feature space, but the interpretation is similar: predictions are linear combinations of the included features and residuals measure unexplained target variation.

== Training error is not enough

A flexible model can fit patterns specific to the observed sample. To evaluate generalisation, split the data so some observations are not used to fit the model.

#utpfig([Model parameters are learned from the training set. The test set is touched only after the model and preprocessing choices are fixed.], label: <fig:train-test-regression>)[
  #canvas(x: 16.06cm, {
    let card = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.27 * 16.06, min-width: 0.34 * 16.06, min-height: 1.18, inner-xsep: 4mm, inner-ysep: 2mm, align: center, font: font("script", fill: navy))
    let flow = (line-width: 0.8966pt, draw: teal, end: arrow-tip("Stealth", length: 2.2mm, width: 1.6mm, line: 0.8966pt))
    let testflow = (line-width: 0.8966pt, draw: mix(orange, 85%, other: black), end: arrow-tip("Stealth", length: 2.2mm, width: 1.6mm, line: 0.8966pt))
    let targetflow = (line-width: 0.797pt, draw: mix(orange, 85%, other: black), dash: "dashed", end: arrow-tip("Stealth", length: 2.2mm, width: 1.6mm, line: 0.797pt))
    let flowlabel = (fill: white, rounded: 1mm, inner-xsep: 2.5mm, inner-ysep: 1mm, font: font("tiny", weight: "bold"))
    node((0.5, 4.2), [#text(fill: teal)[#strong[01 AVAILABLE DATA]] \ #v(3.9851pt)
   Features and target \
  before splitting], name: "all", ..card, draw: mix(teal, 80%), fill: pale-teal)
    node((0.28, 0.85), [#text(fill: blue)[#strong[02A TRAINING PARTITION]] \ #v(3.9851pt)
   Used to learn \
  model parameters], name: "train", ..card)
    node((0.72, 0.85), [#text(fill: mix(orange, 85%, other: black))[#strong[02B TEST PARTITION]] \ #v(3.9851pt)
   Held out from \
  model fitting], name: "test", ..card, draw: mix(orange, 80%), fill: pale-orange)
    node((0.28, -1.15), [#text(fill: blue)[#strong[03A FIT + FREEZE]] \ #v(3.9851pt)
   Model and preprocessing \
  are now fixed], name: "model", ..card)
    node((0.72, -1.15), [#text(fill: mix(orange, 85%, other: black))[#strong[03B TEST FEATURES]] \ #v(3.9851pt)
   Apply frozen \
  preprocessing only], name: "features", ..card, draw: mix(orange, 80%), fill: pale-orange)
    node((0.5, -3.15), [#text(fill: teal)[#strong[04 TEST PREDICTIONS]] \ #v(3.9851pt)
   Fixed model applied \
  to test features], name: "pred", ..card, draw: mix(teal, 80%), fill: pale-teal)
    node((0.5, -5.05), [#text(fill: teal)[#strong[05 EVALUATE]] \ #v(3.9851pt)
   MAE, RMSE, and \
  residual diagnostics], name: "eval", ..card, draw: mix(teal, 80%), fill: pale-teal)
    coordinate("branch", (0.5, 2.45))
    connect("all.south", "branch", draw: teal, line-width: 0.8966pt)
    circle-at("branch", 1.1955pt, fill: teal, draw: none)
    node((0.5, 2.95), [TRAIN / TEST SPLIT], ..flowlabel, text: teal)
    connect("branch", "-|", "train.north", ..flow)
    connect("branch", "-|", "test.north", ..testflow)
    connect("train.south", "model.north", ..flow)
    connect("test.south", "features.north", ..testflow)
    coordinate("merge", (0.5, -2.15))
    connect("model.south", "|-", "merge", draw: teal, line-width: 0.8966pt)
    connect("features.south", "|-", "merge", draw: mix(orange, 85%, other: black), line-width: 0.8966pt)
    circle-at("merge", 1.1457pt, fill: teal, draw: none)
    connect("merge", "pred.north", ..flow)
    connect("pred.south", "eval.north", ..flow)
    connect("test.east", (rel: (0.09 * 16.06, 0), to: "test.east"), "|-", "eval.east", ..targetflow)
    node((0.82, -4.78), [HELD-OUT TARGETS], ..flowlabel, text: mix(orange, 85%, other: black))
  })
]

== Coefficient interpretation is conditional

In a multiple linear model, $beta _j$ describes the fitted change in the prediction associated with a one-unit increase in $x_j$ while the other included features are held fixed. This is a model-based conditional association. If features are strongly correlated, “holding all others fixed” may describe combinations that are rare in the data and coefficients can become unstable.

Categorical variables are represented through indicator variables relative to a reference group. Interactions allow the effect of one feature to change depending on another feature, which makes the fitted relationship more flexible but also changes how main coefficients should be interpreted.

== Error metrics answer different questions

For residuals $e_i=y_i-hat(y)_i$:

$ M A E=frac(1, n) sum |e_i|, wide R M S E=sqrt(frac(1, n) sum e_i^2). $

MAE is an average absolute miss in target units. RMSE penalises large misses more strongly. $R^2$ compares squared error with a mean-only baseline but should not replace error in meaningful units.

#utptable[
  #tabularx(
    columns: (1.8cm, 1fr, 5.8cm),
    styles: (navy-bold,),
    header: ([Metric], [Useful interpretation], [Limitation]),
    [MAE], [typical absolute error], [treats all misses linearly],
    [RMSE], [emphasises large errors], [sensitive to extreme errors],
    [$R^2$], [fraction of baseline variance explained], [less direct operational meaning],
  )
]

#utpfig([Perfect predictions would fall on the dashed 45-degree line. Distance from that line is prediction error; systematic deviations suggest bias in some part of the target range.], label: <fig:regression-pred-actual>)[
  #image("/DATA SCIENCE/figures/regression_predicted_actual.pdf", width: 66%)
]

== Linear-model assumptions are diagnostic questions

For inference on coefficients, common assumptions include approximate linearity of the conditional mean, independent errors, constant error variance, and an error distribution suitable for the inferential approximation. For prediction, the practical emphasis shifts toward whether residual patterns indicate systematic failure on cases like those to be predicted.

#utpfig([A useful residual plot looks roughly patternless around zero. Curvature, funnels, clusters, or isolated points suggest model misspecification or heterogeneous error.], label: <fig:regression-residual-plot>)[
  #image("/DATA SCIENCE/figures/regression_residual_plot.pdf", width: 79%)
]

== Residuals reveal model failures

Residual plots can expose curvature, non-constant variance, influential observations, or systematic subgroup errors. A single average metric can hide all of these.

#warning[
  Evaluating the model on the same rows used for fitting answers “How well did the model remember the training data?” rather than “How well might it generalise?”
]

== Underfitting and overfitting are both prediction problems

A model that is too rigid can miss genuine structure; a model that is too flexible can fit sample-specific noise. Training error usually decreases with complexity, so model selection must rely on held-out or cross-validated performance.

#utpfig([Training error can keep improving while validation error eventually worsens. The useful level of complexity is determined by generalisation, not by the lowest training error.], label: <fig:regression-complexity>)[
  #image("/DATA SCIENCE/figures/regression_complexity.pdf", width: 80%)
]

== Baselines make metrics meaningful

Compare the regression against a simple baseline such as predicting the training-set mean for every case. A model that cannot improve on a naive baseline is not useful merely because it produced coefficients.

#example[
  In Lab 7, alcohol is predicted from several other chemical measurements. The point is not to claim a production-ready chemistry model; it is to practise the complete supervised workflow: define target and features, split, fit, predict, evaluate, and inspect residuals.
]

#note[
  A predictive model is an empirical claim about unseen cases. Its credibility comes from validation data and transparent error analysis, not from how impressive the training summary looks.
]

#questions[
  + Why can a low training error be misleading?
  + How do MAE and RMSE differ in their treatment of large errors?
  + What can residuals reveal that $R^2$ cannot?
  + Why is a simple baseline useful?
]

== Worked regression context: Ames Housing

Ames Housing is deliberately more realistic than a small textbook regression table: 2,930 properties, 82 columns, mixed variable types, and substantial missingness in some attributes. The median sale price is \$160,000. Two strong raw associations are `Overall Qual` with sale price (correlation about 0.80) and above-ground living area with sale price (about 0.71).

#utpfig([Living area is positively related to sale price, but colour by overall quality reveals that similarly sized homes can occupy very different price ranges. Multivariable regression is useful precisely because one predictor rarely carries the whole structure.], label: <fig:reg-ames-area>)[
  #image("/DATA SCIENCE/figures/regression_ames_area_price.pdf", width: 86%)
]

A model can report a respectable $R^2$ and still fail in patterned ways. Diagnostic plots are therefore part of the model, not optional decoration.

#utpfig([Residuals are observed minus fitted sale price. Curvature, changing spread, or extreme vertical deviations indicate information not captured by a simple linear specification.], label: <fig:reg-ames-residuals>)[
  #image("/DATA SCIENCE/figures/regression_ames_residuals.pdf", width: 82%)
]

Ames also introduces an important modelling decision: many categorical variables such as neighbourhood, building type, and exterior quality may be predictive, but including them requires careful encoding and stronger validation. The Lab 7 model starts with a small interpretable subset so students can diagnose the workflow before increasing complexity.

== Categorical predictors can carry structure that numeric summaries miss

Ames Housing contains many categorical variables whose levels represent location, construction, or condition. Neighbourhood is a useful example because it produces clear price differences while also raising modelling questions about sparse levels, interpretation, and generalisation to future properties.

#utpfig([The figure shows median sale price for neighbourhoods with at least 40 observations. The labels report group size so that a large median difference is not interpreted without knowing how much evidence supports it.], label: <fig:reg-ames-neighborhood>)[
  #image("/DATA SCIENCE/figures/regression_ames_neighborhood.pdf", width: 88%)
]

A regression model cannot consume neighbourhood names as unordered text. Common approaches create indicator variables, combine rare levels, or use regularised encodings learned only from the training set. Whatever representation is chosen becomes part of the preprocessing pipeline and must therefore be reproduced exactly at prediction time.

#warning[
  Encoding a category using the target mean calculated from the full dataset is leakage. If target encoding is used, the encoding itself must be learned inside the training fold and applied to the corresponding validation fold without using its outcomes.
]
