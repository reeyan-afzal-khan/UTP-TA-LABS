#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "08-linear-models-for-regression")

= Linear Models for Regression <ch:regression>

#chapterguide[#chapref(<ch:supervised>), #chapref(<ch:training>), and vectors and matrices from #chapref(<ch:foundations>).][fit a line by hand and by formula; explain why squared error makes a bowl; read a slope and an intercept; diagnose residuals; add curved and interaction terms; and regularize coefficients with ridge and lasso.]

The tutor wants a formula: type in the hours a student studied, read off the mark to expect. We will build it by keeping to the first six students, whose marks climb in steady steps. Every step of the recipe gets filled in by hand, so you can see each number being produced. This chapter is the template for every model after it.

== The model: a line with two numbers

Plot the six students, with hours across the bottom and marks up the side (#figref(<fig:line-guesses>)). Each extra two hours brings about six more marks, so a straight line is a sensible shape. A straight line has exactly two numbers in it:

$ hat(y)=w thin x+b. $

The #term[slope] $w$ is how many marks one extra hour is worth. The #term[intercept] $b$ is where the line sits at zero hours. Those two numbers are the model’s parameters, and fitting means choosing them. With more features the same idea becomes a weighted sum, $hat(y)= beta _0+ beta _1 x_1+ dots.c + beta _p x_p$, where each $beta _j$ is the change in the prediction per unit of $x_j$ with the other features held fixed.

#utpfig([The first six students with two guessed lines and the fitted line. Guess A runs too flat and guess B too steep, yet both pass through the average student at (7, 61). The fitted line has an MSE of 2.00, against 13.67 and 48.67.], label: <fig:line-guesses>)[
  #canvas({
    axis(..logaxis, width: 11.8844cm, height: 6cm, xlabel: [hours studied], ylabel: [mark], xmin: 0, xmax: 14, ymin: 30, ymax: 90, legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.03, 0.97), anchor: "north-west"),
      addplot(draw: orange, line-width: widths.thick, domain: (0.5, 13.5), x => 2 * x + 47, legend: [guess A: $2 x+47$]),
      addplot(draw: red, line-width: widths.thick, dash: "dashed", domain: (0.8, 13), x => 5 * x + 26, legend: [guess B: $5 x+26$]),
      addplot(draw: green, line-width: widths.very-thick, domain: (0.5, 13.5), x => 3 * x + 40, legend: [best: $3 x+40$]),
      addplot(..logdots, skip-between: (6, 10), forget: true, table: studylog, x: "hours", y: "mark", meta: "name"),
      addplot(only-marks: true, mark: "x", mark-size: 2.9888pt, draw: navy, line-width: widths.thick, forget: true, coords: ((7, 61),)),
      {
        node((7.2, 60), [average student (7, 61)], font: font("script", fill: navy), anchor: "north-west")
      },
    )
  })
]

== The loss: why squared error

#chapref(<ch:supervised>) showed that raw errors cancel. Guess A misses by $-4,-5,0,2,1,6$ and guess B by $11,4,3,-1,-8,-9$. Both lists add to exactly zero, so an average of raw errors would call both lines perfect. Squaring fixes that: the mean squared error is 13.67 for guess A and 48.67 for guess B, so a bad line finally gets a bad score.

#analogy[
  Picture a rubber band from each dot straight up or down to the line. The further a band stretches, the harder it pulls, so distant dots pull much harder than near ones. Let go, and the line settles where all the pulling balances. That resting place is the line with the smallest total of squared stretches, which is exactly the line #term[ordinary least squares (OLS)] chooses.
]

Ordinary least squares (OLS) chooses coefficients that minimize the residual sum of squares:

$ min_(bold(beta)) sum _(i=1)^n((y_i-hat(y)_i))^2. $

A #term[residual], $y_i-hat(y)_i$, is the observed minus predicted value.

== The optimizer: the bottom of a bowl

Two unknowns at once are hard to think about, so let the rubber bands remove one. Slide any line up and down: the bands above and below pull against each other, and they balance when the line passes through the average student. Whatever the best slope turns out to be, its line goes through $(macron(x),macron(y))=(7,61)$, so

$ b=macron(y)-w macron(x)=61-7 w. $

Now only $w$ is left to choose. For each slope, compute the loss of its line through $(7,61)$:

#utptable[
  #align(center)[

  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center, center),
    header: ([Slope $w$], [0], [1], [2], [3], [4], [5], [6]),
    [MSE], [107.00], [48.67], [13.67], [#strong[2.00]], [13.67], [48.67], [107.00],
  )

  ]
]

#utpfig([The loss against the slope. Substituting $b=61-7 w$ turns the loss into a formula whose highest power is $w^2$, so its graph is a bowl with exactly one lowest point, at $w=3$.], label: <fig:bowl>)[
  #canvas({
    axis(..logaxis, width: 9.9572cm, height: 4.8cm, xlabel: [slope $w$], ylabel: [MSE], xmin: -0.3, xmax: 6.3, ymin: 0, ymax: 115,
      addplot(draw: blue, line-width: widths.thick, domain: (0, 6), samples: 60, x => 2 + 70 / 6 * calc.pow((x - 3), 2)),
      addplot(only-marks: true, mark: "*", mark-size: 1.6936pt, draw: blue, fill: blue, coords: ((0, 107), (1, 48.67), (2, 13.67), (4, 13.67), (5, 48.67), (6, 107))),
      addplot(only-marks: true, mark: "*", mark-size: 2.5903pt, draw: orange, fill: orange, coords: ((3, 2),)),
      {
        connect((3, 28), (3, 6), line-width: widths.thin, draw: muted)
        node((3, 28), [bottom: $w=3$, MSE 2.00], font: font("script", fill: navy), anchor: "south")
      },
    )
  })
]

So $w=3$ and $b=61-7 times 3=40$, giving

$ "mark"=3 times "hours"+40. $

The six errors are $1,-2,1,1,-2,1$. They still add to zero, and their squares average to 2.00, so this line misses by about 1.41 marks on a typical row (the RMSE). No other line does better. A bowl is what makes this dependable: one lowest point means there is nothing to get stuck on.

#keyidea[
  Score every line with one number, and the best line is where that number is smallest. Squared error makes that place easy to find.
]

=== Reading the line, and where it stops being true

The 3 is a rate: among these six students, one extra hour goes with about three more marks. The 40 is the line’s height at zero hours, the prediction for a student who did not study at all. For nine hours the line says $3 times 9+40=67$.

Now try 20 hours. The line says 100. Student J studied 20 hours and scored 38. The line was fitted to students between 2 and 12 hours, and nothing in that range warned it about the bend. Lines do not know where their data ended, which is why extrapolating beyond the training range is the most common way to misuse one.

=== Skipping the plot: the exact formula

We found the bottom by tabulating the bowl. With one feature there is a formula that jumps straight there:

$ hat(beta)_1 =frac(sum _(i=1)^n(x_i-macron(x))(y_i-macron(y)), sum _(i=1)^n((x_i-macron(x)))^2), wide hat(beta)_0=macron(y)-hat(beta)_1 macron(x). $

Slope is covariance divided by feature variance. The intercept makes the line pass through $(macron(x),macron(y))$.

#workedexample[
  For the six students, the deviations from the means are $-5,-3,-1,1,3,5$ for hours and $-14,-11,-2,4,7,16$ for marks. The sum of products is $70+33+2+4+21+80=210$, and the sum of squared hour deviations is $25+9+1+1+9+25=70$. So $w=210\/70=3$ and $b=61-3 times 7=40$, as before.
]

#workedexample[
  Fit a line to three points by hand: $(1,2)$, $(2,3)$, $(3,5)$.
  The means are $macron(x)=2$ and $macron(y)=10\/3$. The deviations from the means are $(-1,0,1)$ for $x$ and $(-inline(frac(4, 3)),-inline(frac(1, 3)),inline(frac(5, 3)))$ for $y$. Then

  $ hat(beta)_1 =frac((-1)(-inline(frac(4, 3)))+(0)(-inline(frac(1, 3)))+(1)(inline(frac(5, 3))), ((-1))^2+0^2+1^2) =frac(3, 2)=1.5, wide hat(beta)_0=inline(frac(10, 3))-1.5 times 2=inline(frac(1, 3)) approx 0.33. $

  The fitted line is $hat(y)=0.33+1.5 x$, giving predictions $1.83$, $3.33$, and $4.83$ with residuals $+0.17$, $-0.33$, and $+0.17$. The residuals sum to zero --- a general property of least squares with an intercept.
]

== Many features: the matrix view

The formula has a version that works for any number of columns. Stack the rows into a matrix $X$ with a leading column of ones to carry the intercept, stack the answers into a vector $bold(y)$, and the whole model is one multiplication, $hat(bold(y))=X bold(beta)$. The loss and its gradient are

$ J(bold(beta))=frac(1, n) || X bold(beta)-bold(y) || _2^2, wide nabla _(bold(beta))J =frac(2, n)X^(sans(T))(X bold(beta)-bold(y)). $

At the bottom of the bowl the gradient is zero, which gives the #term[normal equations] $X^(sans(T))X bold(beta)=X^(sans(T))bold(y)$.

#workedexample[
  For the six students, each entry of these blocks is something you can check by hand: 6 is the row count, 42 the sum of hours, 364 the sum of squared hours, 366 the sum of marks, and 2,772 the sum of hours times marks.

  $ mat(delim: "[", 6, 42; 42, 364) mat(delim: "[", b; w) = mat(delim: "[", 366; 2772). $

  Multiply the first row by 7 and subtract it from the second: $70 w=210$, so $w=3$, and then $6 b=366-126$, so $b=40$. This is the code that does it:

  #lstinput("/MACHINE LEARNING/all_experiments/book_checks/demo_study_log.py", first: 38, last: 48, lang: "python")

  NumPy’s `polyfit(hours, mark, 1)` prints the same pair the other way round, 3 and then 40.
]

Software solves the system with a stable factorization instead of computing an inverse. For very large tables you can walk instead: gradient descent on the same six rows, with hours centered on 7, arrives at $w=3.000$ and an intercept of 61.000 after 1,000 steps of size 0.01. That is the same line, $3("hours"-7)+61$. Having both routes matters: linear regression has a formula, and the next chapter’s model does not.

=== Reading the coefficients honestly

- Coefficients are in the label’s units per unit of the feature, so their sizes are not comparable unless the features are standardized first.
- #term[Multicollinearity]: correlated features make individual coefficients unstable, even when predictions remain accurate.
- Coefficients are associations, not causal effects (#secref(<sec:correlation>)); adding or removing one feature can change the sign of another coefficient.

Lab~2’s used-car price model shows all of this. It one-hot encodes each make into its own column and standardizes the numbers, so a one-unit change in mileage means one standard deviation of mileage, about 47,000 miles. One standard deviation of mileage takes about \$8,553 off the predicted price, and one of age, 5.6 years, another \$3,302; the gap between the Porsche and Toyota coefficients is \$37,920. Age and mileage are correlated (0.61), so with mileage held fixed an older car loses less than you might expect: the model credits much of the wear to the odometer. These are associations inside this model. They do not say what would happen if someone wound back an odometer.

=== The assumptions, in plain words

Classical OLS assumptions include linearity in the chosen features, independent errors, constant error variance, and no exact collinearity. Violations can undermine coefficient interpretation and uncertainty estimates; inspect residuals for warning signs.

== Reading residuals: the diagnostic that matters most

A #term[residual] is what the line left unexplained. Plot residuals against predictions and you are asking whether anything is left that the model could have used.

#utpfig([Two residual plots. A healthy fit leaves a formless cloud around zero; an obvious curve is structure the model has missed.], label: <fig:residuals>)[
  #box(baseline: 100%, canvas({
    axis(width: 7.3876cm, height: 4.1cm, axis-lines: "left", title-style: font("small", weight: "bold", fill: green), title: [Healthy: a formless cloud], xlabel: [Prediction $hat(y)$], ylabel: [Residual], label-style: font("script", fill: muted), tick-label-style: font("script", fill: muted), xmin: 0, xmax: 10, ymin: -3, ymax: 3,
      addplot(only-marks: true, mark: "*", mark-size: 1.1955pt, draw: green, coords: ((0.6, 0.7), (1.2, -0.9), (1.8, 0.3), (2.4, -1.4), (3, 1.1), (3.6, -0.4), (4.2, 1.6), (4.8, -1.1), (5.4, 0.2), (6, -1.7), (6.6, 1.3), (7.2, -0.6), (7.8, 0.9), (8.4, -1.2), (9, 0.5), (9.5, -0.3))),
      {
        connect((0, 0), (10, 0), line-width: widths.thick, dash: "dashed", draw: navy)
      },
    )
  }))
  #h(1fr)#box(baseline: 100%, canvas({
    axis(width: 7.3876cm, height: 4.1cm, axis-lines: "left", title-style: font("small", weight: "bold", fill: red), title: [Sick: an obvious curve], xlabel: [Prediction $hat(y)$], ylabel: [Residual], label-style: font("script", fill: muted), tick-label-style: font("script", fill: muted), xmin: 0, xmax: 10, ymin: -3, ymax: 3,
      addplot(only-marks: true, mark: "*", mark-size: 1.1955pt, draw: red, coords: ((0.6, 2.1), (1.2, 1.4), (1.8, 0.6), (2.4, 0.1), (3, -0.6), (3.6, -1.2), (4.2, -1.6), (4.8, -1.9), (5.4, -1.8), (6, -1.5), (6.6, -1), (7.2, -0.3), (7.8, 0.5), (8.4, 1.3), (9, 2), (9.5, 2.5))),
      {
        connect((0, 0), (10, 0), line-width: widths.thick, dash: "dashed", draw: navy)
      },
    )
  }))
]

#workedexample[
  In Lab~2, the car-price model’s residuals form a widening funnel instead of a cloud: their spread grows from \$9,172 on the cheapest quarter of predictions to \$23,079 on the dearest. The model knows a car’s age, mileage and make but not which car it is, and two cars of the same make and age can be very different cars. No amount of regularization will fix a missing idea. So add the idea: the car’s `model`, one-hot encoded into one column for each of its 1,147 models.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    align: (left, center, center),
    header: ([Linear regression on the same split], [$R^2$], [MAE]),
    [Lab~2’s columns], [0.575], [\$9,009],
    [Plus the car’s model], [0.792], [\$5,754],
  )

  ]]
]

#keyidea[
  Residual patterns suggest missing structure: curvature suggests nonlinear terms; a widening funnel suggests unequal error variance. Lab~2’s car-price funnel points to a missing idea, which car it is.
]

== Polynomial regression: curves from a linear model

All ten students trace an arch, so the best straight line through them is nearly flat and useless: $"mark"=-0.50 times "hours"+61.60$, with an MSE of 125.44. A straight line in #emph[hours] is the wrong shape. But the model is called linear because it is linear in its #emph[parameters], not its inputs. Add $x^2$ as a new column, and the same machinery fits a curve:

$ hat(y)= beta _0+ beta _1 x+ beta _2 x^2+ dots.c + beta _d x^d. $

For the log this gives $"mark"=-0.356 thin "hours"^2+7.333 thin "hours"+30.267$, with an MSE of 18.34 and a peak at 10.3 hours. Degree $d$ controls capacity, and #figref(<fig:three-fits>) shows what happens when it runs away: degree 7 has an MSE of 3.48 on the rows it saw and 3,907.53 on students it did not. Select the degree with validation, never training fit. Polynomial feature counts also grow quickly with several inputs, which motivates the next two sections.

== Ridge regression: shrink everything a little

#term[Ridge regression] adds an $L_2$ penalty on coefficient size to the least-squares objective. For centered features and label (so the intercept has been removed), its solution is

$ hat(bold(beta))_(upright("ridge")) =op("arg min", limits: #true)_(bold(beta)) || X bold(beta)-bold(y) || _2^2 + lambda || bold(beta) || _2^2 =((X^(sans(T))X+ lambda I))^(-1)X^(sans(T))bold(y). $

The penalty trades fit against coefficient size. At $lambda =0$ ridge is OLS, and increasing $lambda$ shrinks the coefficients. Software usually leaves the intercept unpenalized and recovers it from the means.

#workedexample[
  Give the runaway degree-7 curve a ridge penalty, on scaled hours:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto),
    align: (center, center, center, center),
    header: ([$lambda$], [MSE on rows it saw], [Left-out MSE], [Largest coefficient]),
    [0], [3.48], [3907.53], [37.93],
    [0.01], [4.28], [122.19], [28.60],
    [0.1], [7.50], [101.01], [16.63],
    [1], [14.43], [394.31], [8.28],
    [10], [42.24], [381.39], [2.07],
  )

  #raggedright[
  #v(6pt)
  A very small penalty rescues the curve: the fit on seen rows gets slightly worse and the left-out error falls by a factor of nearly 40. Push $lambda$ too far and the model underfits again. Choose it by validation.
  ]]]
]

== Lasso: shrink some coefficients to exactly zero

#term[Lasso regression] swaps the penalty for an $L_1$ norm:

$ hat(bold(beta))_(upright("lasso")) =op("arg min", limits: #true)_(bold(beta)) || X bold(beta)-bold(y) || _2^2 + lambda || bold(beta) || _1. $

Lasso sets some coefficients exactly to zero, producing sparse models. Among strongly correlated features, however, it may choose one somewhat arbitrarily.

Lab~1 puts the same $L_1$ penalty inside a logistic regression (#chapref(<ch:classification>)) to choose among 62 encoded columns of a bank’s call records. scikit-learn sets its strength through $C$, the inverse of $lambda$, so a smaller $C$ is a stronger penalty. At $C=0.001$ it keeps 2 columns with a validation ROC AUC of 0.765; at 0.03 it keeps 21 with 0.801; at 1 it keeps 49 with 0.802. Two thirds of the table could go without loss.

=== Why the penalties behave differently

Regularization constrains a coefficient budget. Least-squares contours touch an $L_1$ diamond often at axis corners, where coefficients are zero; an $L_2$ disk has no such corners.

#utpfig([Why the penalties behave differently. The least-squares contours often first touch the $L_1$ diamond at a corner, where a coefficient is exactly zero; the $L_2$ disk has no corners, so ridge shrinks both coefficients without zeroing either.], label: <fig:lasso-ridge>)[
  #canvas(x: 0.92cm, y: 0.92cm, {
    draw.scope({
      connect((-1.5, 0), (3.6, 0), end: tip("Stealth", length: 2mm, line: 0.4pt))
      node(along((-1.5, 0), (3.6, 0), t: 100%), [$beta _1$], font: font("small"), anchor: "north")
      connect((0, -1.1), (0, 2.2), end: tip("Stealth", length: 2mm, line: 0.4pt))
      node((0, 1.9), [$beta _2$], font: font("small"), anchor: "east")
      connect((1, 0), (0, 1), (-1, 0), (0, -1), (1, 0), line-width: widths.thick, fill: pale-blue)
      draw.scope({
        draw.rotate((39) * 1deg, origin: (2.1, 0.9))
        circle-at((2.1, 0.9), (0.52, 0.25))
      })
      draw.scope({
        draw.rotate((39) * 1deg, origin: (2.1, 0.9))
        circle-at((2.1, 0.9), (0.95, 0.45))
      })
      draw.scope({
        draw.rotate((39) * 1deg, origin: (2.1, 0.9))
        circle-at((2.1, 0.9), (1.42, 0.67))
      })
      circle-at((2.1, 0.9), 1.594pt, fill: auto, draw: none)
      node((2.1, 0.9), [OLS fit], font: font("small"), yshift: 0pt, xshift: 0pt, anchor: "south-west")
      circle-at((1, 0), 1.9925pt, fill: auto, draw: none)
      node((1, -1.22), [lasso fit: $beta _2=0$], anchor: "north", align: center, font: font("footnote"))
      node((0.35, 2.65), [$L_1$ budget (diamond)], font: font("small"), anchor: "west")
    })
    draw.scope({
      draw.translate((6.5217, 0))
      connect((-1.5, 0), (3.6, 0), end: tip("Stealth", length: 2mm, line: 0.4pt))
      node(along((-1.5, 0), (3.6, 0), t: 100%), [$beta _1$], font: font("small"), anchor: "north")
      connect((0, -1.1), (0, 2.2), end: tip("Stealth", length: 2mm, line: 0.4pt))
      node((0, 1.9), [$beta _2$], font: font("small"), anchor: "east")
      circle-at((0, 0), 1, line-width: widths.thick, fill: pale-blue)
      draw.scope({
        draw.rotate((39) * 1deg, origin: (2.1, 0.9))
        circle-at((2.1, 0.9), (0.52, 0.25))
      })
      draw.scope({
        draw.rotate((39) * 1deg, origin: (2.1, 0.9))
        circle-at((2.1, 0.9), (0.95, 0.45))
      })
      draw.scope({
        draw.rotate((39) * 1deg, origin: (2.1, 0.9))
        circle-at((2.1, 0.9), (1.35, 0.64))
      })
      circle-at((2.1, 0.9), 1.594pt, fill: auto, draw: none)
      node((2.1, 0.9), [OLS fit], font: font("small"), yshift: 0pt, xshift: 0pt, anchor: "south-west")
      circle-at((0.98, 0.19), 1.9925pt, fill: auto, draw: none)
      node((1, -1.22), [ridge fit: both small, neither zero], anchor: "north", align: center, font: font("footnote"))
      node((0.35, 2.65), [$L_2$ budget (disk)], font: font("small"), anchor: "west")
    })
  })
]

#intuition[
  Regularization pulls coefficients toward zero: ridge shrinks them smoothly, while lasso can remove them entirely.
]

== Elastic net and practical guidance

#term[Elastic net] combines both penalties,

$ lambda ( rho thin || bold(beta) || _1 +(1- rho ) thin || bold(beta) || _2^2 ), $

gaining lasso’s sparsity while sharing weight across correlated features like ridge. The mixing parameter $rho$ and strength $lambda$ are both tuned on validation data.

Working habits that apply to every model in this chapter:

- #term[Standardize features] so penalties act on comparable scales. Usually leave the intercept unpenalized.
- #term[Tune $lambda$ with cross-validation] (#chapref(<ch:evaluation>)), searching over a logarithmic grid such as $10^(-3)$, $10^(-2)$, …, $10^2$.
- #term[Starting choices:] ridge for many small effects; lasso for sparsity; elastic net for correlated groups.
- Consider #term[Huber loss] when extreme residuals dominate squared-error fitting.

#keyidea[
  A weighted-sum model, richer features, and a validated complexity penalty form a reusable modeling pattern.
]

#recipecard([Linear regression], [A weighted sum of features, $hat(y)=w thin x+b$ in the simplest case.], [Mean squared error, optionally plus a penalty on coefficient size.], [An exact solve of the normal equations, or gradient descent on very large tables. Ridge also has an exact solve; lasso needs an iterative one.])

#modelcard[Linear Regression Family - Quick Guide][
  #tabularx(
    columns: (24%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Best when], [The label is numerical, a weighted-sum relationship is a useful approximation, and interpretability matters.],
    [Start with], [Ordinary linear regression, residual plots, and a mean/median baseline.],
    [Preprocessing], [Encode categories; standardize before ridge, lasso, or elastic net; inspect skew and outliers.],
    [Main controls], [Polynomial degree, regularization strength $lambda$, and elastic-net mixing parameter.],
    [Watch for], [Nonlinearity, influential outliers, multicollinearity, leakage, and unsafe extrapolation beyond the training range.],
  )
]

== When ordinary squared error is the wrong model for the label <sec:special-regression-labels>

Use a different loss or distribution when the label structure or decision warrants it, not merely to make the model more elaborate.

#utptable[
  #tabularx(
    columns: (22%, 29%, 1fr),
    header: ([Label structure], [Useful starting point], [Main caution]),
    [Continuous values with occasional large errors], [Robust regression loss], [Robustness changes which errors receive the most influence; validate against the real evaluation objective.],
    [Conditional quantiles matter], [Quantile regression], [Different quantiles answer different questions and should not be interpreted as conditional means.],
    [Non-negative counts], [Count-aware generalized linear model], [The chosen distributional assumptions must be plausible for the observed mean--variance relationship.],
    [Positively skewed outcomes], [Log-scale modeling or an appropriate positive-response model], [Back-transformation changes the interpretation of average predictions and errors.],
  )
]

Validate specialized losses against the task metric and check prediction plausibility (#chapref(<ch:evaluation>)).

#chapterrecap[
  - A line has two parameters: the slope is a rate, and the intercept is a height.
  - Raw errors cancel, so least squares minimizes squared errors, like rubber bands settling. The best line passes through the average point.
  - Squared error makes a bowl with one bottom, and the normal equations jump straight to it.
  - Coefficients are associations in this model and depend on scale. Residual patterns show what the model missed; adding the car’s model lifted Lab~2’s car-price $R^2$ from 0.575 to 0.792.
  - Linear means linear in the parameters, so curves come from added columns. Ridge shrinks and lasso can delete; both are tuned on validation.
]

#quickcheck[
  + For $"mark"=3 times "hours"+40$, what does the 3 say, and what does the line predict for 7 hours?
  + Why can the average of raw errors be zero for a line that is wrong on most rows?
  + Why must the best line pass through $(macron(x),macron(y))$?
  + What does a regression coefficient mean when the other modeled features are held fixed, and why is that not automatically a causal effect?
  + How do ridge and lasso change coefficient estimates differently as regularization becomes stronger?
  + How can an interaction or polynomial feature let a model remain linear in its parameters while representing a nonlinear relationship in the original inputs?
]
