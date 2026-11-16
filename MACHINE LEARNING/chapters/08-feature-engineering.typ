#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "08-feature-engineering")

#let explore = "/MACHINE LEARNING/all_experiments/book_checks/demo_exploration.py"

= Feature Engineering <ch:feature-engineering>

#chapterguide[#chapref(<ch:data>): pipelines, leakage, one-hot encoding and scaling. #chapref(<ch:eda>): what a table shows when you look. #chapref(<ch:inference>): skew and the $F$ score.][say which features a given kind of model needs help with; reshape a skewed number with a log or a fitted power; cut a number into bands when its effect bends; build ratios, products and squares; transform a regression target; encode a date, including on a circle; handle a category with a thousand values without leaking the label; and keep a ledger that decides which features stay.]

A model does arithmetic on numbers and nothing else. It does not know that 31 August is the end of the summer, that a car with 100,000 miles after three years has been driven hard, or that a booking for zero nights is somebody using a room for the day. #term[Feature engineering] is translation: you take what you know about the world and write it in columns the model's arithmetic can use.

It is also, usually, the cheapest improvement on offer. This chapter keeps a running score on two tables you have met, the hotel bookings of Lab~1 and the used cars of Lab~2, and every number in it is printed by `all_experiments/book_checks/demo_exploration.py`.

== The model decides what a good feature is

Bookings at the two hotels were cancelled at very different rates depending on how many nights were booked (#figref(<fig:nights>)).

#utpfig([Cancellation rate by the number of nights booked. The rate jumps from 5% for a day visit to 44% for two nights, then drifts down. No straight line follows that shape.], label: <fig:nights>)[
  #canvas({
    axis(width: 11.5cm, height: 4.6cm, ..logaxis, xlabel: [nights booked (8 means eight or more)], ylabel: [cancellation rate], ybar: auto, bar-width: 18pt, xmin: -0.7, xmax: 8.7, ymin: 0, ymax: 0.5, xtick: (0, 1, 2, 3, 4, 5, 6, 7, 8), ytick: (0, 0.1, 0.2, 0.3, 0.4, 0.5),
      addplot(fill: pale-blue, draw: blue, coords: ((0, 0.049), (1, 0.251), (2, 0.44), (3, 0.419), (4, 0.366), (5, 0.342), (6, 0.398), (7, 0.343), (8, 0.357))),
    )
  })
]

Give that one column to three models and ask each to rank the bookings by their chance of being cancelled. ROC AUC is 0.5 for a random ranking and 1 for a perfect one (#chapref(<ch:evaluation>)).

#utptable[
  #tabularx(
    columns: (1fr, auto),
    align: (left, center),
    styles: (navy-bold,),
    header: ([How the nights are given to the model], [Validation ROC AUC]),
    [Logistic regression, nights as one number], [0.519],
    [Logistic regression, nights as nine bands, one column each], [0.582],
    [A small decision tree, nights as one number], [0.581],
  )
]

A logistic regression gives the column one weight, so it can only say "more nights, more cancellations" or the reverse. Neither is true, and it scores barely above chance. Cut the same column into bands and the same model can give each band its own weight: 0.582. The tree needed no help, because a tree works by choosing thresholds, and it found the bands for itself.

So the first question of feature engineering is not "what could I compute?" but "what can this model not see?".

#utptable[
  #tabularx(
    columns: (25%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Model family], [Finds on its own], [Needs you to supply]),
    [Linear and logistic models], [A steady rise or fall in each column], [Bends, bands, products of two columns, and anything that is not a number yet],
    [Trees and tree ensembles], [Thresholds, and combinations of thresholds across columns], [Ratios, differences and sums across columns; positions on a cycle],
    [Distance-based models: $k$-NN, $K$-means, SVM], [Whatever "close" means in the columns given], [Columns on comparable scales, in which closeness means similarity],
    [Neural networks], [Bends and combinations, given enough data], [Scaled inputs, and sensible encodings of categories and dates],
  )
]

== Reshaping a number

=== Logs and powers

#chapref(<ch:eda>) measured skew, and #chapref(<ch:inference>) showed why a long right tail lets a few rows dominate. The usual remedy is a logarithm. It is one member of a family, and not always the right one.

#utptable[
  #tabularx(
    columns: (1fr, auto),
    align: (left, center),
    styles: (navy-bold,),
    header: ([Mileage of 62,116 used cars], [Skew]),
    [In miles, as listed], [2.37],
    [Square root], [0.42],
    [Logarithm], [$-0.99$],
    [Power fitted to the training rows (0.29)], [$-0.06$],
  )
]

The logarithm overshoots: it pulls the long right tail in so hard that the column now leans left. A square root does better, and a power of 0.29, fitted by scikit-learn's `PowerTransformer`, gets the column almost symmetric. Because the power is #emph[learned] from the data, it is fitted on training rows inside the pipeline, like a scaler. For a column with zeros use $ln(1 + x)$, written `np.log1p`, since $ln 0$ does not exist.

What does such a transform buy? Less than you might hope for a ranking, and more for a probability. Predicting cancellation from the lead time alone:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto),
    align: (left, center, center),
    styles: (navy-bold,),
    header: ([Logistic regression on], [ROC AUC], [Log loss]),
    [Lead time in days], [0.690], [0.6163],
    [$ln(1 + "lead time")$], [0.690], [0.6015],
  )
]

The AUC does not move, and it cannot: a logarithm never changes which of two bookings has the longer lead time, so a model with one input ranks them the same way. The log loss, which scores the probabilities themselves (#chapref(<ch:evaluation>)), improves, because the chance of cancelling rises quickly over the first weeks and slowly after that, which is the shape of a logarithm. With several inputs the better-shaped column changes the ranking too, which is part of why Lab~1’s engineered columns lift its AUC from 0.846 to 0.855.

=== Bands

Cutting a number into bands, also called #term[binning] or #term[discretization], is the tool for an effect that bends or jumps, as the nights did. It costs something: inside a band the model can no longer tell a low value from a high one. Choose edges that mean something, such as "under a week", or let `KBinsDiscretizer` place them at quantiles of the training rows, and keep both the bands and the original number when in doubt.

=== Squares, products and ratios

A #term[polynomial feature] is a column multiplied by itself, and an #term[interaction] is a column multiplied by another. Both let a linear model draw a curve, as the bend in the study log needed a squared term in #chapref(<ch:orientation>). A #term[ratio] carries meaning that neither of its parts has alone.

`PolynomialFeatures` builds every square and product automatically, and the count grows fast: ten columns become 65 at degree two, and a hundred become 5,150. Most of those are noise for the model to fit. Build the few that you can explain instead. The ledger at the end of this chapter tries three on the used cars.

== Transforming the target

A feature is not the only thing that can be reshaped. Lab~2 fits a ridge regression to the asking prices of used cars, and its residual plot fans out: the model is off by far more on expensive cars. Price is skewed, 2.28, and its logarithm is not, $-0.40$. So predict the logarithm of the price, and turn the prediction back into dollars at the end.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto),
    align: (left, center, center, center),
    styles: (navy-bold,),
    header: ([Ridge regression predicting], [Mean absolute error], [Typical miss], [Prices below zero]),
    [The price in dollars], [\$9,062], [22.3%], [377],
    [The logarithm of the price], [\$7,759], [17.8%], [0],
  )
]

Same model, same columns, \$1,300 closer on an average car. Three things changed at once. An error in the logarithm is an error in #emph[percent], so a 10% miss counts the same on a \$100,000 car as on a \$10,000 one, where before the dear car dominated the fit. A straight line in the logarithm is a curve in dollars, which suits a car losing a share of its value each year. And $e$ raised to any power is positive, so the 377 negative prices are gone.

#codefrom(explore, "def price_model(prepare,", "return mean_absolute_error(y_valid, predicted), predicted, model")

scikit-learn wraps the two steps in `TransformedTargetRegressor(regressor, func=np.log, inverse_func=np.exp)`, so that a saved model takes and returns dollars.

#warning[
  Compare models in the units people use. A mean squared error on log prices cannot be set beside one on dollars. Turn every prediction back into dollars first, as the listing does, and then score.
]

== Dates and cycles

A raw date is useless to a model: it is a label that never repeats. Its value is in what it can be translated into.

#utptable[
  #tabularx(
    columns: (26%, 1fr, 30%),
    styles: (navy-bold,),
    header: ([From a date], [What it tells the model], [Example]),
    [A part of it], [Position in a cycle: hour, weekday, month], [Arrivals on Thursday],
    [A gap between two dates], [How long something has lasted, or how far ahead it was planned], [Lead time; tenure],
    [A flag], [A special day], [Public holiday; month-end],
    [A summary of the past], [What usually happened before this row], [Bookings this customer cancelled before],
  )
]

A summary of the past must be computed from the past only, as it stood at the moment of prediction (#secref(<sec:data-leakage>)). The date itself still has one job: ordering the rows for a split in time.

=== A month is a place on a circle

Code the months 1 to 12 and December is as far as possible from January, eleven steps, when on the calendar they are neighbours. Place the months on a circle instead, like the hours on a clock, and give the model the two coordinates of each month's position:

$ "month"_(sin) = sin(frac(2 pi m, 12)), wide "month"_(cos) = cos(frac(2 pi m, 12)). $

#utpfig([Months as positions on a circle. As plain numbers, December and January are 11 apart and December and June only 6. On the circle the first pair is 0.518 apart and the second 2.000, the full width: neighbours are near again, and opposites are far.], label: <fig:month-circle>)[
  #canvas({
    let r = 2.05
    let place(m) = (r * calc.sin(m * 30deg), r * calc.cos(m * 30deg))
    circle-at((0, 0), r, draw: mix(blue, 40%), line-width: widths.thick)
    let names = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
    for m in range(1, 13) {
      let p = place(m)
      let hot = m in (12, 1, 6)
      circle-at(p, 2.2pt, draw: if hot { orange } else { blue }, fill: if hot { orange } else { white }, line-width: 0.8pt)
      node((1.22 * p.at(0), 1.19 * p.at(1)), [#names.at(m - 1)], font: font("script", weight: if hot { "bold" } else { "regular" }, fill: if hot { orange } else { muted }))
    }
    connect(place(12), place(1), draw: teal, line-width: widths.very-thick)
    connect(place(12), place(6), draw: red, line-width: widths.thick, dash: "dashed")
    node((4.0, 1.35), [December to January: #strong[0.518]], font: font("script", fill: teal), anchor: "west")
    node((4.0, 0.85), [as numbers: 11], font: font("script", fill: muted), anchor: "west")
    node((4.0, -0.2), [December to June: #strong[2.000]], font: font("script", fill: red), anchor: "west")
    node((4.0, -0.7), [as numbers: 6], font: font("script", fill: muted), anchor: "west")
  })
]

Whether this helps depends, as always, on the model. Predicting cancellation from the arrival month alone:

#utptable[
  #tabularx(
    columns: (1fr, auto),
    align: (left, center),
    styles: (navy-bold,),
    header: ([The arrival month, given to a logistic regression as], [Validation ROC AUC]),
    [One number, 1 to 12], [0.508],
    [Two columns: its position on the circle], [0.532],
    [Twelve columns: one-hot], [0.546],
  )
]

The circle beats the plain number, and one-hot beats the circle. Cancellations do not rise and fall in one smooth wave over the year; April is high and March is not. Twelve separate weights can follow that, and two cannot. With only twelve values, one-hot is affordable. The circle earns its place when the cycle has many positions, such as the minute of the day, and for any model that works with distances.

== Categories with too many values

#chapref(<ch:data>) one-hot encoded categories: one yes or no column per value. That is the right default, and it stops being comfortable when a column has a great many values. The used-car table has a `model` column: Corolla, F-150, Model 3, and more.

```terminal
model: 1,102 distinct values, 191 seen once, 50 validation listings of a model never seen
```

A thousand new columns, 191 of which describe a single car each, and 50 cars on the validation side whose model the training rows never mentioned. There are four ways to handle such a column, and the hotel table's `agent`, with 333 values of which 152 have fewer than 20 bookings, poses the same choice.

#utptable[
  #tabularx(
    columns: (22%, 1fr, 17%, 15%),
    align: (left, left, center, center),
    styles: (navy-bold,),
    header: ([Encoding], [What it does], [Columns in the model], [Error on car prices]),
    [One-hot], [One column per value. An unseen value gets all zeros.], [1,195], [\$4,822],
    [One-hot, rare values grouped], [Values with fewer than 20 training rows share one "infrequent" column.], [469], [\$5,086],
    [Target encoding], [Replace each value by the average of the target among its training rows.], [94], [\$5,751],
    [Frequency], [Replace each value by how often it occurs in the training rows.], [94], [\$7,520],
  )
]

Without the `model` column the error was \$7,527, so the column is worth a great deal: one-hot brings the error down to \$4,822. It is the most accurate encoding here, because a ridge regression on 62,116 rows copes well with a thousand sparse columns. It is also the widest, and width is what hurts distance-based models and slows down trees. Grouping the rare values gives up \$264 of accuracy for 726 fewer columns, and target encoding squeezes the whole column into one number for another \$665. Frequency encoding does nothing at all, \$7,520 against \$7,527, because how common a car model is says almost nothing about what it costs. Which trade to take depends on the model that comes next, so the choice belongs in the validation loop like any other.

=== Target encoding, and the smoothing it needs

#term[Target encoding] turns the whole column into one number: for each car model, the average price of its training listings. The trouble is the car models with one listing. Their "average" is one car's own price, a number that says more about that listing than about the model.

The fix is #term[smoothing]: blend each value's own mean with the overall mean, trusting its own mean in proportion to the rows behind it.

$ "encoded value" = frac(n times "own mean" + m times "overall mean", n + m) $

Here $n$ is the number of training rows with that value and $m$ sets how many rows it takes to be believed.

#example[
  The mean price of the training cars is \$32,892, and take $m = 20$.

  A model seen #strong[once], listed at \$150,000: $ frac(1 times 150","000 + 20 times 32","892, 21) = \$38","469. $ One listing moved the estimate only a little above the overall mean.

  A model seen #strong[500 times], with a mean of \$30,000: $ frac(500 times 30","000 + 20 times 32","892, 520) = \$30","111. $ Five hundred listings are believed almost completely.
]

=== The leak inside target encoding

Target encoding uses the label to build a feature, so it can leak. To see how badly, encode a column that means nothing at all: give each of the 62,116 training cars a random group number from 20,000 groups, about three cars per group, and replace each number by the mean log price of its group.

```terminal
a random group, encoded by its mean log price: correlation with the label 0.55 on the rows
that built it, -0.00 when each row is encoded from other rows, -0.00 on new rows
```

A meaningless column has become a feature with a correlation of 0.55 with the price, on the rows that built it. Each car's own price is a third of its group's mean, so the feature is partly the answer. On new cars the same feature has a correlation of zero. A model trained on it would look brilliant in training and fail in use, and the rarer the values, the worse the leak.

#note[
  Any feature built from the label must be built for each row from #emph[other] rows. scikit-learn's `TargetEncoder` does this for you: inside `fit_transform` it splits the training rows into folds and encodes each fold from the others. That only happens if the encoder sits inside the pipeline, so that it is refitted within every training fold.
]

== Flags and counts

Two small kinds of feature are easy to overlook.

/ A flag for what is missing.: #chapref(<ch:eda>) found that patients with no cholesterol reading had heart disease 89.9% of the time, and a 0/1 column saying "not measured" took a weight of 0.71 in the model. When a gap has a cause, the flag carries the cause.
/ A count of what came before.: In Lab~1, customers who had cancelled a booking before cancelled again 91.6% of the time, against 33.9% for the rest. Counts and averages of a row's own history are often the strongest features a table can offer, provided that they count only what had already happened.

== A safety test for every feature

Before a feature goes into the pipeline, ask two questions: what information does it use, and when does that information exist?

#utptable[
  #tabularx(
    columns: (20%, 31%, 1fr),
    styles: (navy-bold,),
    header: ([Kind of feature], [Examples], [Safe treatment]),
    [A fixed rule], [Total nights; a ratio of two columns; the weekday of a date], [It reads only the row's own fields, so it may be computed anywhere, even before the split.],
    [Fitted to the data], [A fitted power; quantile bands; frequency encoding; grouping of rare values], [Fit on training rows only, inside the pipeline.],
    [Built from the label], [Target encoding; any feature chosen because it tracks the target], [Fit within training folds, each row encoded from other rows.],
    [Built from history], [Counts, averages and lags of earlier rows], [Use only rows dated before the moment of prediction.],
  )
]

== Keep a ledger

Every feature in this chapter was an idea first, and ideas are cheap. What makes the work honest is a record of which ideas were tried and what happened: same model, same split, one change at a time.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto),
    align: (left, center, left),
    styles: (navy-bold,),
    header: ([Used-car price model, ridge on log price], [Validation error], [Decision]),
    [Age, mileage and four categories], [\$7,759], [The baseline],
    [+ age squared], [\$7,527], [Keep],
    [+ miles driven per year], [\$7,709], [A small gain; keep only if it is easy to explain],
    [+ logarithm of mileage], [\$7,798], [Drop: slightly worse],
    [+ age squared, + the car's model, one-hot], [\$4,822], [Keep: by far the largest gain],
  )
]

Three of those four ideas are equally sensible on paper. One made the model worse, two helped a little, and the one that mattered most was not clever at all: it was a column that had been left out. Judge a feature by the validation score and not by how good the idea sounded, and stop adding features when the score stops moving.

#codefrom(explore, "def add_car_features(table):", "log_mileage=np.log(table[\"mileage_miles\"]))")

== Which columns to keep: a first look

Engineering adds columns, and more columns are not free. Each one is something the model can fit by accident, something to compute and check every time the model is used, and something to explain. So adding features is followed by pruning them.

Lab~1 uses the two simplest pruning tools. `SelectKBest(f_classif, k=10)` scores each prepared column on its own against the target, with the $F$ of #chapref(<ch:inference>), and keeps the ten with the highest scores. An #term[L1 penalty] does the choosing inside the model itself, by pushing the weights of unhelpful columns to exactly zero (#chapref(<ch:regression>) explains how). Both sit inside the pipeline, for the reason the target encoder does: choosing columns by looking at the label is a way of learning from the label. #chapref(<ch:feature-selection>) returns to this with the full set of tools, once the models they rely on have been introduced.

#summary[
  - Feature engineering turns what you know into columns. Ask first what this model cannot see.
  - A linear model needs bands for a bend, a square for a curve and a product for an interaction; a tree finds thresholds itself. Nights scored 0.519 as a number, 0.582 in bands, 0.581 in a tree.
  - A logarithm is one of a family of powers. For mileage a fitted power of 0.29 removed the skew where the logarithm overshot.
  - Predicting the logarithm of a price cut the error on used cars from \$9,062 to \$7,759 and removed every negative prediction.
  - A cycle belongs on a circle: two columns, a sine and a cosine. With few positions, one-hot may still do better.
  - A category with a thousand values can be one-hot encoded, grouped, counted, or target encoded. Target encoding needs smoothing, and each row must be encoded from other rows.
  - Keep a ledger: one change at a time, judged on the same validation rows.
]

#exercises[
  In `demo_exploration.py`, give `add_car_features` a fourth column, `high_mileage`: 1 when a car has done more than 15,000 miles for each year of its age, with a line in the ledger. First write down how much you expect the error to fall; then run it and compare.
]

#questions[
  + The cancellation rate rises from zero nights to two nights and then falls. Why can a logistic regression given the nights as one number not use this, and what are two different remedies?
  + A logistic regression on the lead time alone has the same ROC AUC whether the lead time is logged or not, but a better log loss when it is. Explain both halves.
  + Give one reason why predicting the logarithm of a price cannot produce a negative price, and one reason why it treats a \$5,000 error on a \$10,000 car as worse than on a \$100,000 car.
  + On the month circle, which month is furthest from March? What is the distance between two neighbouring months, to three decimals?
  + With $m = 20$ and an overall mean of \$32,892, what is the smoothed encoding of a car model seen 20 times with a mean price of \$50,000?
  + A colleague target encodes a customer ID column, with one row per customer, and reports an excellent training score. What has the model learned, and what will happen on new customers?
  + Classify each feature with the safety table: (a) price per area; (b) the median income of the customer's postcode, from the training rows; (c) the mean target of each product category; (d) the customer's orders in the previous 30 days.
]
