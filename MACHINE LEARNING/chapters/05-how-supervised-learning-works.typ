#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-how-supervised-learning-works")


#heading(level: 1)[How Supervised Learning Works]
 <ch:supervised>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Stages 1 and 2: prepared data, basic statistics, vectors, and distance measures.

*By the end, you can:* frame a problem as regression or classification; write the objective a model minimizes; compute and compare losses by hand; tell parametric from non-parametric models; and set a baseline every model must beat.]

An apprentice learns by checking finished work against an answer key: try a problem, see the right answer, adjust, repeat. Supervised learning is that loop, with a table as the stack of finished work. The study log has the answers in a column, so a model can guess a mark, compare it with the real one, and improve. This chapter settles what "compare" means. The chapters after it are different ways to guess.


#heading(level: 2)[Two kinds of labels]


/ Regression: #block[
Predict a continuous value, such as price or temperature; measure error magnitude.
]

/ Classification: #block[
Predict a category, such as spam/not spam, optionally with class probabilities.
]

The label defines the task, not the data. Predicting the exact mark is regression. Predicting pass or fail from the same table is classification. Counts and ordered categories may need special treatment (#ref(label("sec:special-regression-labels"), supplement: [Section]), #ref(label("sec:ordinal-labels"), supplement: [Section])).


#heading(level: 2)[The supervised-learning objective]


Write the data as pairs of inputs and answers, and write the model's guess with its changeable numbers $bold(theta)$ showing: $ cal(D) = {\( bold(x)_i \, y_i \)}_(i = 1)^n \, #h(2em) hat(y)_i = f_(bold(theta)) \( bold(x)_i \) . $ A #strong[loss function] $cal(L)$ charges a penalty for each row. Training finds the $bold(theta)$ with the smallest average penalty, the #strong[empirical risk]: $ hat(R) \( bold(theta) \) = 1 / n sum_(i = 1)^n cal(L) #h(-1em) (y_i \, f_(bold(theta)) \( bold(x)_i \)) . $

#callout("workedexample", title: [Worked example])[This formula is less forbidding than it looks. Take the line $upright("mark") = 2 times upright("hours") + 47$ and the first six students, with squared error as the loss.

#figure(
  align(center)[#table(
    columns: 7,
    align: (left,center,center,center,center,center,center,),
    table.header([Student], [A], [B], [C], [D], [E], [F],),
    table.hline(),
    [True mark $y_i$], [47], [50], [59], [65], [68], [77],
    [Guess $hat(y)_i$], [51], [55], [59], [63], [67], [71],
    [Error $y_i - hat(y)_i$], [$- 4$], [$- 5$], [0], [2], [1], [6],
    [Squared], [16], [25], [0], [4], [1], [36],
  )]
  , kind: table
  )

The sum is 82, and the risk is $82 \/ 6 = 13.67$. Look at the error row: it adds to exactly zero. A plain average of errors would call this wrong line perfect, because misses above and below cancel. A loss must count a miss as a miss whichever side it falls on.]

#callout("keyidea", title: [Key idea])[Training loss measures fit to known examples; validation and test metrics estimate performance on new ones.]


#heading(level: 2)[Loss functions: how wrongness is measured]


There are two standard ways to stop misses from canceling: square them, or take their absolute value. With error $e = y - hat(y)$, $ cal(L)_(upright("squared")) \( e \) = e^2 \, #h(2em) cal(L)_(upright("absolute")) \( e \) = \| e \| . $

#callout("workedexample", title: [Worked example])[Compare one miss of 8 marks with four misses of 2 marks. Both add to 8 marks of error.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,center,),
    table.header([], [One miss of 8], [Four misses of 2],),
    table.hline(),
    [Absolute loss], [8], [$2 + 2 + 2 + 2 = 8$],
    [Squared loss], [64], [$4 + 4 + 4 + 4 = 16$],
  )]
  , kind: table
  )

Absolute loss calls them equal. Squared loss says being badly wrong once is four times as bad. That is a choice we are making about what we care about, and the data does not force it on us. Huber loss, with its corner at 1, charges 0.125, 1.5 and 7.5 for errors of 0.5, 2 and 8: squared near zero, straight beyond.]

For classification, the natural loss simply counts mistakes, the #strong[0--1 loss]. It is useless to an optimizer: a small change in the numbers usually changes no decision, so its slope is zero almost everywhere. Smooth stand-ins replace it, such as #strong[cross-entropy] (#ref(label("ch:classification"), supplement: [Chapter])) and #strong[hinge loss] (#ref(label("ch:svm"), supplement: [Chapter])). The model then reports with whatever metric suits the task.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/0a98d6d526a4c718.cetz.json") #diagram-drawing("/MACHINE LEARNING/figures/diagrams/6d4a845038659da1.cetz.json")], caption: [Loss functions compared. Squared loss grows quadratically, absolute loss linearly, and Huber loss is quadratic near zero and linear beyond it; cross-entropy grows without bound as a confident prediction turns out wrong.]) <fig:losses>

#callout("intuition", title: [Plain idea])[Doubling an error quadruples squared loss, so large errors pull hard on the fit. Absolute loss grows steadily. Cross-entropy has no upper limit at all: as the probability given to the true class approaches zero, the fee climbs without bound. Being confident and wrong is the most expensive thing a probabilistic model can do.]

#callout("keyidea", title: [Key idea])[Use squared loss when large errors deserve extra weight; absolute or Huber loss reduces their influence.]


#heading(level: 2)[Parametric and non-parametric models]


Some models commit to a fixed form in advance. A straight line has two numbers, and it keeps two numbers however many students you collect. Others grow with the data: nearest neighbors keeps every row it has seen, and a tree adds branches as rows justify them.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Model family], [Structure and examples], [Trade-off],),
    table.hline(),
    [Parametric models], [Fixed form and parameter count, independent of sample size: linear regression, logistic regression, naive Bayes.], [Often fast and interpretable, but limited by the assumed form.],
    [Non-parametric models], [Complexity can grow with data: nearest neighbors stores training examples; trees add branches.], [Flexible relationships, but often need more data and careful overfitting control.],
  )]
  , kind: table
  )

The right parametric form can work well with little data; flexible non-parametric models often need more.


#heading(level: 2)[Always start with a baseline]
 <sec:baselines>

#callout("analogy", title: [Analogy])[A weather forecaster who says "tomorrow will be like today" is right surprisingly often. A forecasting system that cannot beat that rule has not earned its electricity bill. A #strong[baseline] is the rule that costs nothing, evaluated with the same split and the same metric as the models.]

- for regression, predict the training-set mean (or median) of the label for every observation;

- for classification, predict the most common class for every observation;

- when domain rules exist ("flag any transaction over \$10,000"), evaluate those too.

Baselines reveal class imbalance, and they show what added complexity actually buys. Here are the course's own numbers, on the labs' own splits:

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Task], [Metric], [Baseline], [Lab's model],),
    table.hline(),
    [Used-car prices (Lab~2)], [MAE, dollars], [15,408: always the training mean], [9,009: linear regression],
    [Hotel cancellations in 2017 (Lab~2)], [Accuracy], [0.613: always "kept"], [0.764: logistic regression],
    [Sign-up before a bank call (Lab~1)], [Accuracy], [0.887: always "no"], [0.899: logistic regression],
  )]
  , kind: table
  )

Read the bank row closely. Nearly nine customers in ten say no, so always predicting "no" is already 88.7% accurate, and the logistic model adds only 1.2 points. That modest gain is all that accuracy can show on this task, so Lab~1 scores the same model by ROC AUC, 0.802, which rewards putting the likely yeses first. Without the baseline, 0.899 would sound like an achievement or a failure depending on who was speaking.

#callout("workedexample", title: [Worked example])[If 950 of 1,000 emails are legitimate, predicting "not spam" gives 95% accuracy and zero spam recall. Report rare-class precision and recall (#ref(label("ch:evaluation"), supplement: [Chapter])).]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/530fc157c181d1ad.cetz.json")], caption: [Climb the ladder one rung at a time: a baseline, a simple model, a stronger model, then a tuned one. Stop at the first rung that is good enough for the task.]) <fig:model-ladder>

#callout("analogy", title: [Analogy])[Climb one rung at a time. Increase complexity only when validation gains justify it, and stop at the simplest model that meets the task's needs.]

#callout("pitfall", title: [Common mistake])[Unexpectedly strong results warrant leakage checks: outcome-revealing identifiers, late-recorded features, or duplicates across splits.]


#heading(level: 2)[A map of the algorithms ahead]


The next six model chapters apply the workflow of the next two chapters, organized by their core ideas. Each one ends with its recipe card, so you can compare them on the same three lines.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Chapter], [Algorithms], [Core idea],),
    table.hline(),
    [#ref(label("ch:regression"), supplement: none)], [Linear, polynomial, ridge, lasso, elastic net regression], [Fit a weighted sum of features; penalize large weights],
    [#ref(label("ch:classification"), supplement: none)], [Logistic regression, softmax, LDA, QDA, perceptron], [Draw a linear boundary between classes],
    [#ref(label("ch:knn-nb"), supplement: none)], [$k$-nearest neighbors, naive Bayes], [Predict from similar examples; predict from per-feature probabilities],
    [#ref(label("ch:decision-trees"), supplement: none)], [Decision trees (CART)], [Ask a sequence of yes/no questions],
    [#ref(label("ch:ensembles"), supplement: none)], [Bagging, random forests, AdaBoost, gradient boosting, stacking], [Combine many models into one predictor],
    [#ref(label("ch:svm"), supplement: none)], [Support vector machines, kernels, SVR], [Maximize the margin; separate after mapping to a richer space],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Supervised models differ in representable functions, assumptions, and data needs. Learn these trade-offs rather than formulas alone.]

#callout("modelcard", title: [Supervised Learning - Project Checklist])[#block[
ll Question 1 & Is the label a number, a category, or a special type such as a count or ordered category? Question 2 & What simple baseline should the model beat? Question 3 & Which loss guides training, and which metric matches the real cost of mistakes? Question 4 & How will the split imitate future predictions? Question 5 & Does the final model need interpretability, probabilities, speed, or a nonlinear boundary?

]]

#callout("chapterrecap", title: [Chapter recap])[- The label defines the task: a number means regression, and a category means classification.

- Training minimizes the average loss on training rows, the empirical risk. Raw errors cancel, so losses square them or take absolute values.

- Squaring is a decision to punish one large miss far more than several small ones. Cross-entropy punishes confident mistakes without limit.

- Parametric models keep a fixed form; non-parametric models grow with the data.

- A baseline tells you what a model's score actually means. Always compute one on the same split.]

#callout("quickcheck", title: [Check your understanding])[+ How does a regression label differ from a classification label, and what does that change about the kind of prediction produced?

+ For true marks $50 \, 60 \, 70$ and guesses $55 \, 60 \, 65$, what are the average error, the MAE and the MSE? What does the average error hide?

+ Why can the loss used for fitting differ from the metric used to report practical performance?

+ A churn model reports 92% accuracy, and 92% of customers do not churn. What should you conclude?

+ What does a learned model have to demonstrate beyond beating its own training loss?]
