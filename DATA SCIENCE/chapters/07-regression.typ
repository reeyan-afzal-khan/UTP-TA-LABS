#import "/.shared/typst/utp.typ": *
#unit("chapters", "07-regression")


#heading(level: 1)[Regression for Numeric Prediction]
 <ch:regression> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand relationships, sampling uncertainty, and the difference between exploration and validation.

*By the end, you can:* fit a multiple linear regression, interpret coefficients cautiously, evaluate predictions on held-out data, and diagnose residual errors.]


#heading(level: 2)[Regression predicts a numeric target]
 In supervised learning, the dataset includes an outcome to be predicted. #strong[Regression] is used when that target is numeric, such as price, demand, temperature, or concentration.

A multiple linear model has the form $ hat(y) = beta_0 + beta_1 x_1 + dots.h.c + beta_p x_p . $ The coefficients describe modelled changes in the prediction while holding the other included features fixed. That is not automatically a causal effect.


#heading(level: 2)[What a fitted line is minimising]
 Ordinary least squares chooses coefficients to minimise the sum of squared residuals. In a one-feature model, each residual is the vertical difference between the observed target and the fitted line.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/regression_residual_geometry.svg", width: 90%)], caption: [The vertical segments are residuals. Squaring them makes large errors contribute disproportionately to the least-squares objective.]) <fig:regression-geometry>

In multiple regression, the geometry lives in higher-dimensional feature space, but the interpretation is similar: predictions are linear combinations of the included features and residuals measure unexplained target variation.


#heading(level: 2)[Training error is not enough]
 A flexible model can fit patterns specific to the observed sample. To evaluate generalisation, split the data so some observations are not used to fit the model.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA SCIENCE/figures/diagrams/414a3566bf7ad485.svg")], caption: [Model parameters are learned from the training set. The test set is touched only after the model and preprocessing choices are fixed.]) <fig:train-test-regression>


#heading(level: 2)[Coefficient interpretation is conditional]
 In a multiple linear model, $beta_j$ describes the fitted change in the prediction associated with a one-unit increase in $x_j$ while the other included features are held fixed. This is a model-based conditional association. If features are strongly correlated, "holding all others fixed" may describe combinations that are rare in the data and coefficients can become unstable.

Categorical variables are represented through indicator variables relative to a reference group. Interactions allow the effect of one feature to change depending on another feature, which makes the fitted relationship more flexible but also changes how main coefficients should be interpreted.


#heading(level: 2)[Error metrics answer different questions]
 For residuals $e_i = y_i - hat(y)_i$: $ M A E = 1 / n sum \| e_i \| \, #h(2em) R M S E = sqrt(1 / n sum e_i^2) . $ MAE is an average absolute miss in target units. RMSE penalises large misses more strongly. $R^2$ compares squared error with a mean-only baseline but should not replace error in meaningful units.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Metric], [Useful interpretation], [Limitation],),
    table.hline(),
    [MAE], [typical absolute error], [treats all misses linearly],
    [RMSE], [emphasises large errors], [sensitive to extreme errors],
    [$R^2$], [fraction of baseline variance explained], [less direct operational meaning],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/regression_predicted_actual.svg", width: 90%)], caption: [Perfect predictions would fall on the dashed 45-degree line. Distance from that line is prediction error; systematic deviations suggest bias in some part of the target range.]) <fig:regression-pred-actual>


#heading(level: 2)[Linear-model assumptions are diagnostic questions]
 For inference on coefficients, common assumptions include approximate linearity of the conditional mean, independent errors, constant error variance, and an error distribution suitable for the inferential approximation. For prediction, the practical emphasis shifts toward whether residual patterns indicate systematic failure on cases like those to be predicted.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/regression_residual_plot.svg", width: 90%)], caption: [A useful residual plot looks roughly patternless around zero. Curvature, funnels, clusters, or isolated points suggest model misspecification or heterogeneous error.]) <fig:regression-residual-plot>


#heading(level: 2)[Residuals reveal model failures]
 Residual plots can expose curvature, non-constant variance, influential observations, or systematic subgroup errors. A single average metric can hide all of these.

#callout("pitfall", title: [Analytical pitfall])[Evaluating the model on the same rows used for fitting answers "How well did the model remember the training data?" rather than "How well might it generalise?"]


#heading(level: 2)[Underfitting and overfitting are both prediction problems]
 A model that is too rigid can miss genuine structure; a model that is too flexible can fit sample-specific noise. Training error usually decreases with complexity, so model selection must rely on held-out or cross-validated performance.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/regression_complexity.svg", width: 90%)], caption: [Training error can keep improving while validation error eventually worsens. The useful level of complexity is determined by generalisation, not by the lowest training error.]) <fig:regression-complexity>


#heading(level: 2)[Baselines make metrics meaningful]
 Compare the regression against a simple baseline such as predicting the training-set mean for every case. A model that cannot improve on a naive baseline is not useful merely because it produced coefficients.

#callout("workedexample", title: [Worked example])[In Lab 7, alcohol is predicted from several other chemical measurements. The point is not to claim a production-ready chemistry model; it is to practise the complete supervised workflow: define target and features, split, fit, predict, evaluate, and inspect residuals.]

#callout("keyidea", title: [Key idea])[A predictive model is an empirical claim about unseen cases. Its credibility comes from validation data and transparent error analysis, not from how impressive the training summary looks.]

#callout("quickcheck", title: [Check your understanding])[+ Why can a low training error be misleading?

+ How do MAE and RMSE differ in their treatment of large errors?

+ What can residuals reveal that $R^2$ cannot?

+ Why is a simple baseline useful?]


#heading(level: 2)[Worked regression context: Ames Housing]


Ames Housing is deliberately more realistic than a small textbook regression table: 2,930 properties, 82 columns, mixed variable types, and substantial missingness in some attributes. The median sale price is \$160,000. Two strong raw associations are `Overall Qual` with sale price (correlation about 0.80) and above-ground living area with sale price (about 0.71).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/regression_ames_area_price.svg", width: 90%)], caption: [Living area is positively related to sale price, but colour by overall quality reveals that similarly sized homes can occupy very different price ranges. Multivariable regression is useful precisely because one predictor rarely carries the whole structure.]) <fig:reg-ames-area>

A model can report a respectable $R^2$ and still fail in patterned ways. Diagnostic plots are therefore part of the model, not optional decoration.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/regression_ames_residuals.svg", width: 90%)], caption: [Residuals are observed minus fitted sale price. Curvature, changing spread, or extreme vertical deviations indicate information not captured by a simple linear specification.]) <fig:reg-ames-residuals>

Ames also introduces an important modelling decision: many categorical variables such as neighbourhood, building type, and exterior quality may be predictive, but including them requires careful encoding and stronger validation. The Lab 7 model starts with a small interpretable subset so students can diagnose the workflow before increasing complexity.


#heading(level: 2)[Categorical predictors can carry structure that numeric summaries miss]


Ames Housing contains many categorical variables whose levels represent location, construction, or condition. Neighbourhood is a useful example because it produces clear price differences while also raising modelling questions about sparse levels, interpretation, and generalisation to future properties.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA SCIENCE/figures/regression_ames_neighborhood.svg", width: 90%)], caption: [The figure shows median sale price for neighbourhoods with at least 40 observations. The labels report group size so that a large median difference is not interpreted without knowing how much evidence supports it.]) <fig:reg-ames-neighborhood>

A regression model cannot consume neighbourhood names as unordered text. Common approaches create indicator variables, combine rare levels, or use regularised encodings learned only from the training set. Whatever representation is chosen becomes part of the preprocessing pipeline and must therefore be reproduced exactly at prediction time.

#callout("pitfall", title: [Analytical pitfall])[Encoding a category using the target mean calculated from the full dataset is leakage. If target encoding is used, the encoding itself must be learned inside the training fold and applied to the corresponding validation fold without using its outcomes.]
