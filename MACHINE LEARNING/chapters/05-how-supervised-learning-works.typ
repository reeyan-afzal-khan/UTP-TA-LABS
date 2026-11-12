#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-how-supervised-learning-works")

= How Supervised Learning Works <ch:supervised>

#chapterguide[Stages 1 and 2: prepared data, basic statistics, vectors, and distance measures.][frame a problem as regression or classification; write the objective a model minimizes; compute and compare losses by hand; tell parametric from non-parametric models; and set a baseline every model must beat.]

An apprentice learns by checking finished work against an answer key: try a problem, see the right answer, adjust, repeat. Supervised learning is that loop, with a table as the stack of finished work. The study log has the answers in a column, so a model can guess a mark, compare it with the real one, and improve. This chapter settles what “compare” means. The chapters after it are different ways to guess.

== Two kinds of labels

#describe-nextline(1.25in)[
  / Regression: Predict a continuous value, such as price or temperature; measure error magnitude.
  / Classification: Predict a category, such as spam/not spam, optionally with class probabilities.
]

The label defines the task, not the data. Predicting the exact mark is regression. Predicting pass or fail from the same table is classification. Counts and ordered categories may need special treatment (#secref(<sec:special-regression-labels>), #secref(<sec:ordinal-labels>)).

== The supervised-learning objective

Write the data as pairs of inputs and answers, and write the model’s guess with its changeable numbers $bold(theta)$ showing:

$ cal(D)=( { (bold(x)_i,y_i) } )_(i=1)^n, wide hat(y)_i=f_(bold(theta))(bold(x)_i). $

A #term[loss function] $cal(L)$ charges a penalty for each row. Training finds the $bold(theta)$ with the smallest average penalty, the #term[empirical risk]:

$ hat(R)(bold(theta)) =frac(1, n) sum _(i=1)^n cal(L)(y_i,f_(bold(theta))(bold(x)_i)). $

#workedexample[
  This formula is less forbidding than it looks. Take the line $"mark"=2 times "hours"+47$ and the first six students, with squared error as the loss.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center),
    header: ([Student], [A], [B], [C], [D], [E], [F]),
    [True mark $y_i$], [47], [50], [59], [65], [68], [77],
    [Guess $hat(y)_i$], [51], [55], [59], [63], [67], [71],
    [Error $y_i-hat(y)_i$], [$-4$], [$-5$], [0], [2], [1], [6],
    [Squared], [16], [25], [0], [4], [1], [36],
  )

  #raggedright[
  #v(6pt)
  The sum is 82, and the risk is $82\/6=13.67$. Look at the error row: it adds to exactly zero. A plain average of errors would call this wrong line perfect, because misses above and below cancel. A loss must count a miss as a miss whichever side it falls on.
  ]]]
]

#keyidea[
  Training loss measures fit to known examples; validation and test metrics estimate performance on new ones.
]

== Loss functions: how wrongness is measured

There are two standard ways to stop misses from canceling: square them, or take their absolute value. With error $e=y-hat(y)$,

$ cal(L)_("squared")(e)=e^2, wide cal(L)_("absolute")(e)=|e|. $

#workedexample[
  Compare one miss of 8 marks with four misses of 2 marks. Both add to 8 marks of error.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    align: (left, center, center),
    header: ([], [One miss of 8], [Four misses of 2]),
    [Absolute loss], [8], [$2+2+2+2=8$],
    [Squared loss], [64], [$4+4+4+4=16$],
  )

  #raggedright[
  #v(6pt)
  Absolute loss calls them equal. Squared loss says being badly wrong once is four times as bad. That is a choice we are making about what we care about, and the data does not force it on us. Huber loss, with its corner at 1, charges 0.125, 1.5 and 7.5 for errors of 0.5, 2 and 8: squared near zero, straight beyond.
  ]]]
]

For classification, the natural loss simply counts mistakes, the #term[0--1 loss]. It is useless to an optimizer: a small change in the numbers usually changes no decision, so its slope is zero almost everywhere. Smooth stand-ins replace it, such as #term[cross-entropy] (#chapref(<ch:classification>)) and #term[hinge loss] (#chapref(<ch:svm>)). The model then reports with whatever metric suits the task.

#utpfig([Loss functions compared. Squared loss grows quadratically, absolute loss linearly, and Huber loss is quadratic near zero and linear beyond it; cross-entropy grows without bound as a confident prediction turns out wrong.], label: <fig:losses>)[
  #box(baseline: 100%, canvas({
    axis(width: 7.227cm, height: 4.8cm, axis-lines: "left", title-style: font("small", weight: "bold", fill: navy) + (yshift: 3.9851pt), title: [Regression losses], xlabel: [Error $(y-hat(y))$], ylabel: [Penalty], label-style: font("script", fill: muted), tick-label-style: font("script", fill: muted), legend-style: (size: font("script").size, draw: none, fill: white, at: (0.5, 0.94), anchor: "north", columns: 3), domain: (-3, 3), samples: 101, xmin: -3, xmax: 3, ymin: 0, ymax: 6.5, ytick: (0, 2, 4, 6),
      addplot(draw: blue, line-width: widths.very-thick, x => calc.pow(x, 2), legend: [squared]),
      addplot(draw: teal, line-width: widths.very-thick, x => calc.abs(x), legend: [absolute]),
      addplot(draw: orange, line-width: widths.very-thick, dash: "dashed", x => (if calc.abs(x) < 1 { 0.5 * calc.pow(x, 2) } else { calc.abs(x) - 0.5 }), legend: [Huber]),
    )
  }))
  #h(1fr)#box(baseline: 100%, canvas({
    axis(width: 7.227cm, height: 4.8cm, axis-lines: "left", title-style: font("small", weight: "bold", fill: navy) + (yshift: 3.9851pt), title: [Cross-entropy loss], xlabel: [Predicted probability of the true class], ylabel: [Penalty], label-style: font("script", fill: muted), tick-label-style: font("script", fill: muted), domain: (0.02, 1), samples: 101, xmin: 0, xmax: 1, ymin: 0, ymax: 4,
      addplot(draw: red, line-width: widths.very-thick, x => -calc.ln(x)),
      {
        node((0.43, 3.2), [confident \
  and wrong], font: font("script", fill: red), align: center, fill: white, fill-opacity: 88%, opacity: 100%, rounded: 0.5mm, inner-sep: 1.4944pt)
        node((0.78, 0.75), [confident \
  and right], font: font("script", fill: green), align: center, fill: white, fill-opacity: 88%, opacity: 100%, rounded: 0.5mm, inner-sep: 1.4944pt)
      },
    )
  }))
]

#intuition[
  Doubling an error quadruples squared loss, so large errors pull hard on the fit. Absolute loss grows steadily. Cross-entropy has no upper limit at all: as the probability given to the true class approaches zero, the fee climbs without bound. Being confident and wrong is the most expensive thing a probabilistic model can do.
]

#keyidea[
  Use squared loss when large errors deserve extra weight; absolute or Huber loss reduces their influence.
]

== Parametric and non-parametric models

Some models commit to a fixed form in advance. A straight line has two numbers, and it keeps two numbers however many students you collect. Others grow with the data: nearest neighbors keeps every row it has seen, and a tree adds branches as rows justify them.

#utptable[
  #tabularx(
    columns: (21%, 38%, 1fr),
    styles: (navy-bold,),
    header: ([Model family], [Structure and examples], [Trade-off]),
    [Parametric models], [Fixed form and parameter count, independent of sample size: linear regression, logistic regression, naive Bayes.], [Often fast and interpretable, but limited by the assumed form.],
    [Non-parametric models], [Complexity can grow with data: nearest neighbors stores training examples; trees add branches.], [Flexible relationships, but often need more data and careful overfitting control.],
  )
]

The right parametric form can work well with little data; flexible non-parametric models often need more.

== Always start with a baseline <sec:baselines>

#analogy[
  A weather forecaster who says “tomorrow will be like today” is right surprisingly often. A forecasting system that cannot beat that rule has not earned its electricity bill. A #term[baseline] is the rule that costs nothing, evaluated with the same split and the same metric as the models.
]

- for regression, predict the training-set mean (or median) of the label for every observation;
- for classification, predict the most common class for every observation;
- when domain rules exist (“flag any transaction over \$10,000”), evaluate those too.

Baselines reveal class imbalance, and they show what added complexity actually buys. Here are the course’s own numbers, on the labs’ own splits:

#utptable[
  #tabularx(
    columns: (26%, 20%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Task], [Metric], [Baseline], [Lab’s model]),
    [Used-car prices (Lab~2)], [MAE, dollars], [15,408: always the training mean], [9,009: linear regression],
    [Hotel cancellations in 2017 (Lab~2)], [Accuracy], [0.613: always “kept”], [0.764: logistic regression],
    [Sign-up before a bank call (Lab~1)], [Accuracy], [0.887: always “no”], [0.899: logistic regression],
  )
]

Read the bank row closely. Nearly nine customers in ten say no, so always predicting “no” is already 88.7% accurate, and the logistic model adds only 1.2 points. That modest gain is all that accuracy can show on this task, so Lab~1 scores the same model by ROC AUC, 0.802, which rewards putting the likely yeses first. Without the baseline, 0.899 would sound like an achievement or a failure depending on who was speaking.

#workedexample[
  If 950 of 1,000 emails are legitimate, predicting “not spam” gives 95% accuracy and zero spam recall. Report rare-class precision and recall (#chapref(<ch:evaluation>)).
]

#utpfig([Climb the ladder one rung at a time: a baseline, a simple model, a stronger model, then a tuned one. Stop at the first rung that is good enough for the task.], label: <fig:model-ladder>)[
  #canvas({
    let bx = (draw: blue, fill: pale-blue, rounded: 1.5mm, min-width: 3.1, min-height: 0.95, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [Baseline \
  always guess the average], name: "b0", ..bx, fill: pale-gray, draw: muted)
    node(right-of("b0", 0.6), [Simple model \
  linear or a shallow tree], name: "b1", ..bx)
    node(right-of("b1", 0.6), [Stronger model \
  forest or boosting], name: "b2", ..bx)
    node(right-of("b2", 0.6), [Tuned model \
  cross-validated settings], name: "b3", ..bx)
    connect("b0", "b1", ..arr)
    connect("b1", "b2", ..arr)
    connect("b2", "b3", ..arr)
    node(below-of("b1", 0.05), [stop here if it is good enough], font: font("script", style: "italic", fill: muted))
  })
]

#analogy[
  Climb one rung at a time. Increase complexity only when validation gains justify it, and stop at the simplest model that meets the task’s needs.
]

#pitfall[
  Unexpectedly strong results warrant leakage checks: outcome-revealing identifiers, late-recorded features, or duplicates across splits.
]

== A map of the algorithms ahead

The next six model chapters apply the workflow of the next two chapters, organized by their core ideas. Each one ends with its recipe card, so you can compare them on the same three lines.

#utptable[
  #tabularx(
    columns: (12%, 42%, 1fr),
    styles: ((size: sizes.footnote), (size: sizes.footnote), (size: sizes.footnote)),
    header: ([Chapter], [Algorithms], [Core idea]),
    [@ch:regression], [Linear, polynomial, ridge, lasso, elastic net regression], [Fit a weighted sum of features; penalize large weights],
    [@ch:classification], [Logistic regression, softmax, LDA, QDA, perceptron], [Draw a linear boundary between classes],
    [@ch:knn-nb], [$k$-nearest neighbors, naive Bayes], [Predict from similar examples; predict from per-feature probabilities],
    [@ch:decision-trees], [Decision trees (CART)], [Ask a sequence of yes/no questions],
    [@ch:ensembles], [Bagging, random forests, AdaBoost, gradient boosting, stacking], [Combine many models into one predictor],
    [@ch:svm], [Support vector machines, kernels, SVR], [Maximize the margin; separate after mapping to a richer space],
  )
]

#keyidea[
  Supervised models differ in representable functions, assumptions, and data needs. Learn these trade-offs rather than formulas alone.
]

#modelcard[Supervised Learning - Project Checklist][
  #tabularx(
    columns: (17%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Question 1], [Is the label a number, a category, or a special type such as a count or ordered category?],
    [Question 2], [What simple baseline should the model beat?],
    [Question 3], [Which loss guides training, and which metric matches the real cost of mistakes?],
    [Question 4], [How will the split imitate future predictions?],
    [Question 5], [Does the final model need interpretability, probabilities, speed, or a nonlinear boundary?],
  )
]

#chapterrecap[
  - The label defines the task: a number means regression, and a category means classification.
  - Training minimizes the average loss on training rows, the empirical risk. Raw errors cancel, so losses square them or take absolute values.
  - Squaring is a decision to punish one large miss far more than several small ones. Cross-entropy punishes confident mistakes without limit.
  - Parametric models keep a fixed form; non-parametric models grow with the data.
  - A baseline tells you what a model’s score actually means. Always compute one on the same split.
]

#quickcheck[
  + How does a regression label differ from a classification label, and what does that change about the kind of prediction produced?
  + For true marks $50,60,70$ and guesses $55,60,65$, what are the average error, the MAE and the MSE? What does the average error hide?
  + Why can the loss used for fitting differ from the metric used to report practical performance?
  + A churn model reports 92% accuracy, and 92% of customers do not churn. What should you conclude?
  + What does a learned model have to demonstrate beyond beating its own training loss?
]
