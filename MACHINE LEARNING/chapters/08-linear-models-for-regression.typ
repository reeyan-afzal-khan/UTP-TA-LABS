#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-linear-models-for-regression")


#heading(level: 1)[Linear Models for Regression]
 <ch:regression>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* #ref(label("ch:supervised"), supplement: [Chapter]), #ref(label("ch:training"), supplement: [Chapter]), and vectors and matrices from #ref(label("ch:foundations"), supplement: [Chapter]).

*By the end, you can:* fit a line by hand and by formula; explain why squared error makes a bowl; read a slope and an intercept; diagnose residuals; add curved and interaction terms; and regularize coefficients with ridge and lasso.]

The tutor wants a formula: type in the hours a student studied, read off the mark to expect. We will build it by keeping to the first six students, whose marks climb in steady steps. Every step of the recipe gets filled in by hand, so you can see each number being produced. This chapter is the template for every model after it.


#heading(level: 2)[The model: a line with two numbers]


Plot the six students, with hours across the bottom and marks up the side (#ref(label("fig:line-guesses"), supplement: [Figure])). Each extra two hours brings about six more marks, so a straight line is a sensible shape. A straight line has exactly two numbers in it: $ hat(y) = w thin x + b . $ The #strong[slope] $w$ is how many marks one extra hour is worth. The #strong[intercept] $b$ is where the line sits at zero hours. Those two numbers are the model's parameters, and fitting means choosing them. With more features the same idea becomes a weighted sum, $hat(y) = beta_0 + beta_1 x_1 + dots.h.c + beta_p x_p$, where each $beta_j$ is the change in the prediction per unit of $x_j$ with the other features held fixed.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/f14a4338d5a3e8ad.svg")], caption: [The first six students with two guessed lines and the fitted line. Guess A runs too flat and guess B too steep, yet both pass through the average student at (7, 61). The fitted line has an MSE of 2.00, against 13.67 and 48.67.]) <fig:line-guesses>


#heading(level: 2)[The loss: why squared error]


#ref(label("ch:supervised"), supplement: [Chapter]) showed that raw errors cancel. Guess A misses by $- 4 \, - 5 \, 0 \, 2 \, 1 \, 6$ and guess B by $11 \, 4 \, 3 \, - 1 \, - 8 \, - 9$. Both lists add to exactly zero, so an average of raw errors would call both lines perfect. Squaring fixes that: the mean squared error is 13.67 for guess A and 48.67 for guess B, so a bad line finally gets a bad score.

#callout("analogy", title: [Analogy])[Picture a rubber band from each dot straight up or down to the line. The further a band stretches, the harder it pulls, so distant dots pull much harder than near ones. Let go, and the line settles where all the pulling balances. That resting place is the line with the smallest total of squared stretches, which is exactly the line #strong[ordinary least squares (OLS)] chooses.]

Ordinary least squares (OLS) chooses coefficients that minimize the residual sum of squares: $ min_(bold(beta)) sum_(i = 1)^n \( y_i - hat(y)_i \)^2 . $ A #strong[residual], $y_i - hat(y)_i$, is the observed minus predicted value.


#heading(level: 2)[The optimizer: the bottom of a bowl]


Two unknowns at once are hard to think about, so let the rubber bands remove one. Slide any line up and down: the bands above and below pull against each other, and they balance when the line passes through the average student. Whatever the best slope turns out to be, its line goes through $\( macron(x) \, macron(y) \) = \( 7 \, 61 \)$, so $ b = macron(y) - w macron(x) = 61 - 7 w . $ Now only $w$ is left to choose. For each slope, compute the loss of its line through $\( 7 \, 61 \)$:

#figure(
  align(center)[#table(
    columns: 8,
    align: (left,center,center,center,center,center,center,center,),
    table.header([Slope $w$], [0], [1], [2], [3], [4], [5], [6],),
    table.hline(),
    [MSE], [107.00], [48.67], [13.67], [#strong[2.00]], [13.67], [48.67], [107.00],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/585f716067583a90.svg")], caption: [The loss against the slope. Substituting $b = 61 - 7 w$ turns the loss into a formula whose highest power is $w^2$, so its graph is a bowl with exactly one lowest point, at $w = 3$.]) <fig:bowl>

So $w = 3$ and $b = 61 - 7 times 3 = 40$, giving $ upright("mark") = 3 times upright("hours") + 40 . $ The six errors are $1 \, - 2 \, 1 \, 1 \, - 2 \, 1$. They still add to zero, and their squares average to 2.00, so this line misses by about 1.41 marks on a typical row (the RMSE). No other line does better. A bowl is what makes this dependable: one lowest point means there is nothing to get stuck on.

#callout("keyidea", title: [Key idea])[Score every line with one number, and the best line is where that number is smallest. Squared error makes that place easy to find.]


#heading(level: 3)[Reading the line, and where it stops being true]


The 3 is a rate: among these six students, one extra hour goes with about three more marks. The 40 is the line's height at zero hours, the prediction for a student who did not study at all. For nine hours the line says $3 times 9 + 40 = 67$.

Now try 20 hours. The line says 100. Student J studied 20 hours and scored 38. The line was fitted to students between 2 and 12 hours, and nothing in that range warned it about the bend. Lines do not know where their data ended, which is why extrapolating beyond the training range is the most common way to misuse one.


#heading(level: 3)[Skipping the plot: the exact formula]


We found the bottom by tabulating the bowl. With one feature there is a formula that jumps straight there:

$ hat(beta)_1 = frac(sum_(i = 1)^n \( x_i - macron(x) \) \( y_i - macron(y) \), sum_(i = 1)^n \( x_i - macron(x) \)^2) \, #h(2em) hat(beta)_0 = macron(y) - hat(beta)_1 macron(x) . $ Slope is covariance divided by feature variance. The intercept makes the line pass through $\( macron(x) \, macron(y) \)$.

#callout("workedexample", title: [Worked example])[For the six students, the deviations from the means are $- 5 \, - 3 \, - 1 \, 1 \, 3 \, 5$ for hours and $- 14 \, - 11 \, - 2 \, 4 \, 7 \, 16$ for marks. The sum of products is $70 + 33 + 2 + 4 + 21 + 80 = 210$, and the sum of squared hour deviations is $25 + 9 + 1 + 1 + 9 + 25 = 70$. So $w = 210 \/ 70 = 3$ and $b = 61 - 3 times 7 = 40$, as before.]

#callout("workedexample", title: [Worked example])[Fit a line to three points by hand: $\( 1 \, 2 \)$, $\( 2 \, 3 \)$, $\( 3 \, 5 \)$. The means are $macron(x) = 2$ and $macron(y) = 10 \/ 3$. The deviations from the means are $\( - 1 \, 0 \, 1 \)$ for $x$ and $\( - 4 / 3 \, - 1 / 3 \, 5 / 3 \)$ for $y$. Then $ hat(beta)_1 = frac(\( - 1 \) \( - 4 / 3 \) + \( 0 \) \( - 1 / 3 \) + \( 1 \) \( 5 / 3 \), \( - 1 \)^2 + 0^2 + 1^2) = 3 / 2 = 1.5 \, #h(2em) hat(beta)_0 = 10 / 3 - 1.5 times 2 = 1 / 3 approx 0.33 . $ The fitted line is $hat(y) = 0.33 + 1.5 x$, giving predictions $1.83$, $3.33$, and $4.83$ with residuals $+ 0.17$, $- 0.33$, and $+ 0.17$. The residuals sum to zero --- a general property of least squares with an intercept.]


#heading(level: 2)[Many features: the matrix view]


The formula has a version that works for any number of columns. Stack the rows into a matrix $X$ with a leading column of ones to carry the intercept, stack the answers into a vector $bold(y)$, and the whole model is one multiplication, $hat(bold(y)) = X bold(beta)$. The loss and its gradient are $ J \( bold(beta) \) = 1 / n parallel X bold(beta) - bold(y) parallel_2^2 \, #h(2em) nabla_(bold(beta)) J = 2 / n X^(sans(T)) \( X bold(beta) - bold(y) \) . $ At the bottom of the bowl the gradient is zero, which gives the #strong[normal equations] $X^(sans(T)) X bold(beta) = X^(sans(T)) bold(y)$.

#callout("workedexample", title: [Worked example])[For the six students, each entry of these blocks is something you can check by hand: 6 is the row count, 42 the sum of hours, 364 the sum of squared hours, 366 the sum of marks, and 2,772 the sum of hours times marks. $ mat(delim: "[", 6, 42; 42, 364) mat(delim: "[", b; w) = mat(delim: "[", 366; 2772) . $ Multiply the first row by 7 and subtract it from the second: $70 w = 210$, so $w = 3$, and then $6 b = 366 - 126$, so $b = 40$. This is the code that does it:

#source-code("/MACHINE LEARNING/all_experiments/book_checks/demo_study_log.py", first: 38, last: 48, lang: "python")

NumPy's `polyfit(hours, mark, 1)` prints the same pair the other way round, 3 and then 40.]

Software solves the system with a stable factorization instead of computing an inverse. For very large tables you can walk instead: gradient descent on the same six rows, with hours centered on 7, arrives at $w = 3.000$ and an intercept of 61.000 after 1,000 steps of size 0.01. That is the same line, $3 \( upright("hours") - 7 \) + 61$. Having both routes matters: linear regression has a formula, and the next chapter's model does not.


#heading(level: 3)[Reading the coefficients honestly]


- Coefficients are in the label's units per unit of the feature, so their sizes are not comparable unless the features are standardized first.

- #strong[Multicollinearity]: correlated features make individual coefficients unstable, even when predictions remain accurate.

- Coefficients are associations, not causal effects (#ref(label("sec:correlation"), supplement: [Section])); adding or removing one feature can change the sign of another coefficient.

Lab~2's used-car price model shows all of this. It one-hot encodes each make into its own column and standardizes the numbers, so a one-unit change in mileage means one standard deviation of mileage, about 47,000 miles. One standard deviation of mileage takes about \$8,553 off the predicted price, and one of age, 5.6 years, another \$3,302; the gap between the Porsche and Toyota coefficients is \$37,920. Age and mileage are correlated (0.61), so with mileage held fixed an older car loses less than you might expect: the model credits much of the wear to the odometer. These are associations inside this model. They do not say what would happen if someone wound back an odometer.


#heading(level: 3)[The assumptions, in plain words]


Classical OLS assumptions include linearity in the chosen features, independent errors, constant error variance, and no exact collinearity. Violations can undermine coefficient interpretation and uncertainty estimates; inspect residuals for warning signs.


#heading(level: 2)[Reading residuals: the diagnostic that matters most]


A #strong[residual] is what the line left unexplained. Plot residuals against predictions and you are asking whether anything is left that the model could have used.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/fe78b2d0d3b823e2.svg") #diagram-image("/MACHINE LEARNING/figures/diagrams/baed8f50d744e678.svg")], caption: [Two residual plots. A healthy fit leaves a formless cloud around zero; an obvious curve is structure the model has missed.]) <fig:residuals>

#callout("workedexample", title: [Worked example])[In Lab~2, the car-price model's residuals form a widening funnel instead of a cloud: their spread grows from \$9,172 on the cheapest quarter of predictions to \$23,079 on the dearest. The model knows a car's age, mileage and make but not which car it is, and two cars of the same make and age can be very different cars. No amount of regularization will fix a missing idea. So add the idea: the car's `model`, one-hot encoded into one column for each of its 1,147 models.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,center,),
    table.header([Linear regression on the same split], [$R^2$], [MAE],),
    table.hline(),
    [Lab~2's columns], [0.575], [\$9,009],
    [Plus the car's model], [0.792], [\$5,754],
  )]
  , kind: table
  )]

#callout("keyidea", title: [Key idea])[Residual patterns suggest missing structure: curvature suggests nonlinear terms; a widening funnel suggests unequal error variance. Lab~2's car-price funnel points to a missing idea, which car it is.]


#heading(level: 2)[Polynomial regression: curves from a linear model]


All ten students trace an arch, so the best straight line through them is nearly flat and useless: $upright("mark") = - 0.50 times upright("hours") + 61.60$, with an MSE of 125.44. A straight line in #emph[hours] is the wrong shape. But the model is called linear because it is linear in its #emph[parameters], not its inputs. Add $x^2$ as a new column, and the same machinery fits a curve: $ hat(y) = beta_0 + beta_1 x + beta_2 x^2 + dots.h.c + beta_d x^d . $ For the log this gives $upright("mark") = - 0.356 thin upright("hours")^2 + 7.333 thin upright("hours") + 30.267$, with an MSE of 18.34 and a peak at 10.3 hours. Degree $d$ controls capacity, and #ref(label("fig:three-fits"), supplement: [Figure]) shows what happens when it runs away: degree 7 has an MSE of 3.48 on the rows it saw and 3,907.53 on students it did not. Select the degree with validation, never training fit. Polynomial feature counts also grow quickly with several inputs, which motivates the next two sections.


#heading(level: 2)[Ridge regression: shrink everything a little]


#strong[Ridge regression] adds an $L_2$ penalty on coefficient size to the least-squares objective. For centered features and label (so the intercept has been removed), its solution is $ hat(bold(beta))_(upright(r i d g e)) = "argmin"_(bold(beta)) parallel X bold(beta) - bold(y) parallel_2^2 + lambda parallel bold(beta) parallel_2^2 = \( X^(sans(T)) X + lambda I \)^(- 1) X^(sans(T)) bold(y) . $ The penalty trades fit against coefficient size. At $lambda = 0$ ridge is OLS, and increasing $lambda$ shrinks the coefficients. Software usually leaves the intercept unpenalized and recovers it from the means.

#callout("workedexample", title: [Worked example])[Give the runaway degree-7 curve a ridge penalty, on scaled hours:

#figure(
  align(center)[#table(
    columns: 4,
    align: (center,center,center,center,),
    table.header([$lambda$], [MSE on rows it saw], [Left-out MSE], [Largest coefficient],),
    table.hline(),
    [0], [3.48], [3907.53], [37.93],
    [0.01], [4.28], [122.19], [28.60],
    [0.1], [7.50], [101.01], [16.63],
    [1], [14.43], [394.31], [8.28],
    [10], [42.24], [381.39], [2.07],
  )]
  , kind: table
  )

A very small penalty rescues the curve: the fit on seen rows gets slightly worse and the left-out error falls by a factor of nearly 40. Push $lambda$ too far and the model underfits again. Choose it by validation.]


#heading(level: 2)[Lasso: shrink some coefficients to exactly zero]


#strong[Lasso regression] swaps the penalty for an $L_1$ norm: $ hat(bold(beta))_(upright(l a s s o)) = "argmin"_(bold(beta)) parallel X bold(beta) - bold(y) parallel_2^2 + lambda parallel bold(beta) parallel_1 . $ Lasso sets some coefficients exactly to zero, producing sparse models. Among strongly correlated features, however, it may choose one somewhat arbitrarily.

Lab~1 puts the same $L_1$ penalty inside a logistic regression (#ref(label("ch:classification"), supplement: [Chapter])) to choose among 62 encoded columns of a bank's call records. scikit-learn sets its strength through $C$, the inverse of $lambda$, so a smaller $C$ is a stronger penalty. At $C = 0.001$ it keeps 2 columns with a validation ROC AUC of 0.765; at 0.03 it keeps 21 with 0.801; at 1 it keeps 49 with 0.802. Two thirds of the table could go without loss.


#heading(level: 3)[Why the penalties behave differently]


Regularization constrains a coefficient budget. Least-squares contours touch an $L_1$ diamond often at axis corners, where coefficients are zero; an $L_2$ disk has no such corners.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/38aba2c0d1272f6c.svg")], caption: [Why the penalties behave differently. The least-squares contours often first touch the $L_1$ diamond at a corner, where a coefficient is exactly zero; the $L_2$ disk has no corners, so ridge shrinks both coefficients without zeroing either.]) <fig:lasso-ridge>

#callout("intuition", title: [Plain idea])[Regularization pulls coefficients toward zero: ridge shrinks them smoothly, while lasso can remove them entirely.]


#heading(level: 2)[Elastic net and practical guidance]


#strong[Elastic net] combines both penalties, $ lambda #h(-1em) (rho thin parallel bold(beta) parallel_1 + \( 1 - rho \) thin parallel bold(beta) parallel_2^2) \, $ gaining lasso's sparsity while sharing weight across correlated features like ridge. The mixing parameter $rho$ and strength $lambda$ are both tuned on validation data.

Working habits that apply to every model in this chapter:

- #strong[Standardize features] so penalties act on comparable scales. Usually leave the intercept unpenalized.

- #strong[Tune $lambda$ with cross-validation] (#ref(label("ch:evaluation"), supplement: [Chapter])), searching over a logarithmic grid such as $10^(- 3)$, $10^(- 2)$, …, $10^2$.

- #strong[Starting choices:] ridge for many small effects; lasso for sparsity; elastic net for correlated groups.

- Consider #strong[Huber loss] when extreme residuals dominate squared-error fitting.

#callout("keyidea", title: [Key idea])[A weighted-sum model, richer features, and a validated complexity penalty form a reusable modeling pattern.]

#callout("modelcard", title: [The recipe: Linear regression])[*1. Model* A weighted sum of features, $hat(y) = w thin x + b$ in the simplest case.

*2. Loss* Mean squared error, optionally plus a penalty on coefficient size.

*3. Optimizer* An exact solve of the normal equations, or gradient descent on very large tables. Ridge also has an exact solve; lasso needs an iterative one.]

#callout("modelcard", title: [Linear Regression Family - Quick Guide])[#block[
ll Best when & The label is numerical, a weighted-sum relationship is a useful approximation, and interpretability matters. Start with & Ordinary linear regression, residual plots, and a mean/median baseline. Preprocessing & Encode categories; standardize before ridge, lasso, or elastic net; inspect skew and outliers. Main controls & Polynomial degree, regularization strength $lambda$, and elastic-net mixing parameter. Watch for & Nonlinearity, influential outliers, multicollinearity, leakage, and unsafe extrapolation beyond the training range.

]]


#heading(level: 2)[When ordinary squared error is the wrong model for the label]
 <sec:special-regression-labels>

Use a different loss or distribution when the label structure or decision warrants it, not merely to make the model more elaborate.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Label structure], [Useful starting point], [Main caution],),
    table.hline(),
    [Continuous values with occasional large errors], [Robust regression loss], [Robustness changes which errors receive the most influence; validate against the real evaluation objective.],
    [Conditional quantiles matter], [Quantile regression], [Different quantiles answer different questions and should not be interpreted as conditional means.],
    [Non-negative counts], [Count-aware generalized linear model], [The chosen distributional assumptions must be plausible for the observed mean--variance relationship.],
    [Positively skewed outcomes], [Log-scale modeling or an appropriate positive-response model], [Back-transformation changes the interpretation of average predictions and errors.],
  )]
  , kind: table
  )

Validate specialized losses against the task metric and check prediction plausibility (#ref(label("ch:evaluation"), supplement: [Chapter])).

#callout("chapterrecap", title: [Chapter recap])[- A line has two parameters: the slope is a rate, and the intercept is a height.

- Raw errors cancel, so least squares minimizes squared errors, like rubber bands settling. The best line passes through the average point.

- Squared error makes a bowl with one bottom, and the normal equations jump straight to it.

- Coefficients are associations in this model and depend on scale. Residual patterns show what the model missed; adding the car's model lifted Lab~2's car-price $R^2$ from 0.575 to 0.792.

- Linear means linear in the parameters, so curves come from added columns. Ridge shrinks and lasso can delete; both are tuned on validation.]

#callout("quickcheck", title: [Check your understanding])[+ For $upright("mark") = 3 times upright("hours") + 40$, what does the 3 say, and what does the line predict for 7 hours?

+ Why can the average of raw errors be zero for a line that is wrong on most rows?

+ Why must the best line pass through $\( macron(x) \, macron(y) \)$?

+ What does a regression coefficient mean when the other modeled features are held fixed, and why is that not automatically a causal effect?

+ How do ridge and lasso change coefficient estimates differently as regularization becomes stronger?

+ How can an interaction or polynomial feature let a model remain linear in its parameters while representing a nonlinear relationship in the original inputs?]
