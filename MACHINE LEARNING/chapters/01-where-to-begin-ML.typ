#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "01-where-to-begin-ML")

= Where to Begin <ch:orientation>

#chapterguide[No previous machine-learning knowledge is required. High-school algebra is enough for this chapter.][name the observation, features, target, model and metric of a problem; describe any method as a model, a loss and an optimizer; place a problem on the map of learning settings; follow the project workflow; and explain why good training performance proves little.]

Linear regression, gradient descent, logistic regression, $K$-means, PCA. Taught one chapter at a time, these names feel like a pile of unrelated tricks, and a chart of them looks like a maze. They are less separate than they look. Almost every method in this book repeats the same three moves: make a guess, score how wrong it is, improve the guess. This chapter sets up that idea on one small notebook that we will keep returning to, small enough to check everything with a pen.

== One tutor, one notebook

A tutor runs a weekly revision group of ten students and wants to plan who needs extra help before the next exam. After the last exam the tutor wrote one line per student: hours studied in the final week, lectures attended out of 14, hours slept the night before, and the mark out of 100.

#utpfig([The study log. Ten rows and four columns are all the data this running example ever uses. A mark of 50 or more is a pass.], label: <fig:study-log>)[
  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (center, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Student], [Hours studied], [Lectures attended], [Hours slept], [Mark], [Passed?]),
    [A], [2], [8], [8], [47], [no],
    [B], [4], [6], [8], [50], [yes],
    [C], [6], [7], [7], [59], [yes],
    [D], [8], [9], [7], [65], [yes],
    [E], [10], [11], [7], [68], [yes],
    [F], [12], [13], [6], [77], [yes],
    [G], [14], [12], [5], [62], [yes],
    [H], [16], [10], [4], [52], [yes],
    [I], [18], [5], [3], [43], [no],
    [J], [20], [3], [2], [38], [no],
  )
]

Read the hours and the mark together. Marks climb with study from student A to student F, then fall away: students I and J studied the most, attended the least, barely slept, and failed. Keep that bend in mind, because it comes back in several chapters.

The tutor can ask four different questions of this one notebook, and each question leads to a different kind of method:

- #emph[What mark should a student expect after nine hours of study?] The answer is a number (#chapref(<ch:regression>)).
- #emph[Will this student pass?] The answer is yes or no, and it would help to know how sure we are (#chapref(<ch:classification>)).
- #emph[What kinds of student are in this group?] Nobody wrote the kinds down, so the method has to find them (#chapref(<ch:clustering>)).
- #emph[Can four columns fit on one chart?] The answer is a smaller set of columns that keeps most of the story (#chapref(<ch:dimred>)).

== The five parts of a machine-learning problem

Machine learning builds systems that learn useful patterns from examples instead of following a rule written by hand for every situation. Any such problem has five parts, and it is worth naming them before touching any code.

#utptable[
  #tabularx(
    columns: (16%, 1fr, 34%),
    styles: (navy-bold,),
    header: ([Part], [Meaning], [In the study log]),
    [Observation], [One example, usually one row of a table.], [One student],
    [Feature], [An input known before the prediction is made.], [Hours studied, lectures attended, hours slept],
    [Target], [The answer the model should learn to predict. Also called the label.], [The mark, or whether the student passed],
    [Model], [A mathematical rule that turns features into a prediction.], [$"mark"=3 times "hours"+40$],
    [Metric], [A number that judges whether the model is useful on data it has not seen.], [Average size of the miss, in marks],
  )
]

#emph[Training] means learning the rule from rows whose answers are known. #emph[Prediction] means applying that rule to a new row whose answer is missing. A used-car price model has the same five parts: one listing per row, age and mileage as features, asking price as the target, a weighted sum as the model, and mean absolute error as the metric.

== The recipe behind every method <sec:recipe>

Here is the idea this whole book rests on. Choosing a method means filling in three blanks.

#utpfig([The recipe. A model makes a guess, a loss scores how wrong the guess is, and an optimizer improves the numbers inside the model. When you meet a new method name, ask which of the three steps it changes.], label: <fig:recipe>)[
  #canvas({
    node((0, 0), [#strong[1\. Model] \
  make a guess: a formula with numbers we are allowed to change], name: "m", font: font("small"), ..recipebox())
    node((5.1, 0), [#strong[2\. Loss] \
  score how wrong it is: all the errors become one number], name: "l", font: font("small"), ..recipebox())
    node((10.2, 0), [#strong[3\. Optimizer] \
  improve the guess: find numbers that make the score smaller], name: "o", font: font("small"), ..recipebox(), fill: pale-orange, draw: orange)
    connect("m", "l", ..utparrow)
    connect("l", "o", ..utparrow)
    connect("o.south", (rel: (0, -0.62), to: "o.south"), "-|", "m.south", ..utparrow)
    node((5.1, -1.42), [repeat until the score stops improving], font: font("small"), ..utplabel, fill: white)
  })
]

#workedexample[
  Take the first six students and the guess $"mark"=2 times "hours"+47$.

  / Model.: A straight line with two changeable numbers, the 2 and the 47.
  / Loss.: Student B studied 4 hours, so the guess is $2 times 4+47=55$. The real mark was 50, a miss of $-5$. Square each of the six misses and average them: the score is 13.67.
  / Optimizer.: Try other numbers. The line $"mark"=3 times "hours"+40$ scores 2.00, and no other straight line scores lower. #chapref(<ch:regression>) shows how to find it without trying them all.
]

The numbers the optimizer changes are the model’s #term[parameters]. Some settings are not learned at all: you fix them before training, or choose among them by experiment. Those are #term[hyperparameters]. A loss guides fitting; a metric reports how useful the result is to the people who will use it. The two may differ, as they do when a model trains on squared error but is reported by its average miss in marks.

#utptable[
  #tabularx(
    columns: (20%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Term], [Who chooses it?], [Example]),
    [Parameter], [Learned from training data], [A regression coefficient or a tree split],
    [Hyperparameter], [Chosen before or during model selection], [Number of neighbors, tree depth, regularization strength],
    [Loss], [Used by the training process to measure wrongness], [Squared error, cross-entropy],
    [Metric], [Used to report practical performance], [Accuracy, recall, MAE, RMSE],
  )
]

== Does your log hold the answers? <sec:map>

Before picking a method, ask one question about your data. Look back at the study log. If you want to predict the mark, the answers are sitting in a column: every past student shows what happened, so a model can learn from them. If you want to know what kinds of student there are, no column holds the answer, and nobody can mark a guess right or wrong. That single difference splits the map of machine learning in two (#figref(<fig:ml-map>)).

#utpfig([The map. One question splits the field, and a second question names the job. Most methods in Stages 3 and 4 of this book live in one of these four corners.], label: <fig:ml-map>)[
  #canvas({
    node((0, 2.65), [Does your log hold the answers?], name: "q", font: font("small"), ..mapgate)
    node((-3.65, 1.45), [#strong[Yes: supervised learning] \
  learn from the answers], name: "y", font: font("small"), ..utpstep, fill: pale-blue, draw: blue, text-width: 4.2)
    node((3.65, 1.45), [#strong[No: unsupervised learning] \
  look for structure instead], name: "n", font: font("small"), ..utpstep, fill: pale-orange, draw: orange, text-width: 4.2)
    connect("q.south", (rel: (0, -0.25), to: "q.south"), "-|", "y.north", ..utparrow)
    connect("q.south", (rel: (0, -0.25), to: "q.south"), "-|", "n.north", ..utparrow)
    node((-5.45, -0.25), [#strong[You want a number] \
  regression \ #v(0.9963pt)
  #emph[linear regression] \
  what mark to expect], name: "a", font: font("small"), ..mapleaf)
    node((-1.85, -0.25), [#strong[You want a category] \
  classification \ #v(0.9963pt)
  #emph[logistic regression] \
  pass or fail], name: "b", font: font("small"), ..mapleaf)
    node((1.85, -0.25), [#strong[You want groups] \
  clustering \ #v(0.9963pt)
  #emph[$K$-means] \
  what kinds of student], name: "c", font: font("small"), ..mapleafb)
    node((5.45, -0.25), [#strong[You want fewer columns] \
  dimensionality reduction \ #v(0.9963pt)
  #emph[PCA] \
  four columns on one chart], name: "d", font: font("small"), ..mapleafb)
    connect("y.south", "a.north", ..utparrow)
    connect("y.south", "b.north", ..utparrow)
    connect("n.south", "c.north", ..utparrow)
    connect("n.south", "d.north", ..utparrow)
  })
]

Two settings sit beside this map, because their feedback is different. In #term[semi-supervised learning] only a few rows have answers, so unlabeled rows must help (#chapref(<ch:semi-supervised>)). In #term[reinforcement learning] no answers exist at all, only a score that arrives after the learner acts (#chapref(<ch:rl>)). Neural networks (#chapref(<ch:deep>)) do not get their own corner: they are a richer kind of model that can be used in any of them. #figref(<fig:field-map>) puts the four settings side by side.

#utpfig([The field map: four learning settings, told apart by the feedback available. Supervised learning has an answer for every example, semi-supervised for some, unsupervised for none, and reinforcement learning receives a score after it acts.], label: <fig:field-map>)[
  #canvas({
    let hd = (draw: navy, fill: navy, text: white, rounded: 1.5mm, min-width: 3.35, min-height: 0.62, align: center, font: font("small", weight: "bold"))
    let bx = (draw: blue, fill: pale-blue, rounded: 1.5mm, min-width: 3.35, min-height: 1.5, align: center, font: font("script", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [Supervised], name: "h1", ..hd)
    node(right-of("h1", 0.55), [Semi-supervised], name: "h2", ..hd)
    node(right-of("h2", 0.55), [Unsupervised], name: "h3", ..hd)
    node(right-of("h3", 0.55), [Reinforcement], name: "h4", ..hd)
    node(below-of("h1", 0.28), [You are given the \
  answer for every example. \ #v(0.25em)
  #strong[“This email is spam.”] \ #v(0.25em)
  Goal: copy the mapping], name: "b1", ..bx)
    node(below-of("h2", 0.28), [You are given answers \
  for only some examples. \ #v(0.25em)
  #strong[“A few emails are labeled.”] \ #v(0.25em)
  Goal: learn from both sets], name: "b2", ..bx)
    node(below-of("h3", 0.28), [You are given no answers \
  at all, only the examples. \ #v(0.25em)
  #strong[“Here are 10 000 emails.”] \ #v(0.25em)
  Goal: find the structure], name: "b3", ..bx)
    node(below-of("h4", 0.28), [You are given a score \
  after you act. \ #v(0.25em)
  #strong[“That move lost you 3 points.”] \ #v(0.25em)
  Goal: act better next time], name: "b4", ..bx)
  })
]

#intuition[
  #term[Self-supervised learning] creates targets from the data itself, such as hidden words or image regions, to learn representations. #term[Active learning] chooses which examples to send to a person for labeling. Both change where the feedback comes from, which is why this map is drawn around feedback and not around algorithms.
]

== The complete workflow

The recipe describes how one model learns. A real project wraps it in a longer routine, because a model is only as good as the question and the data around it.

#utpfig([The complete workflow, from defining the problem to explaining and monitoring the model. The steps are described in the list that follows.], label: <fig:ml-workflow>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 3.35, min-height: 0.9, inner-xsep: 2.9888pt, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.2mm, line: widths.thick))
    node((0, 0), [1\. Define the problem], name: "a", ..box-style)
    node(right-of("a", 0.55), [2\. Understand the data], name: "b", ..box-style)
    node(right-of("b", 0.55), [3\. Split correctly], name: "c", ..box-style)
    node(right-of("c", 0.55), [4\. Prepare the features], name: "d", ..box-style)
    node(below-of("d", 0.65), [5\. Build a baseline], name: "e", ..box-style)
    node(left-of("e", 0.55), [6\. Train and tune models], name: "f", ..box-style)
    node(left-of("f", 0.55), [7\. Evaluate fairly], name: "g", ..box-style)
    node(left-of("g", 0.55), [8\. Explain and monitor], name: "h", ..box-style)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
    connect("d", "e", ..arr)
    connect("e", "f", ..arr)
    connect("f", "g", ..arr)
    connect("g", "h", ..arr)
  })
]

#utpsteps[
  + #term[Define the decision.] State what must be predicted, who will use the result, and what a wrong prediction costs.
  + #term[Validate the data.] Check rows, keys, units, missingness, timing, and bias. Apply only fixed, label-blind corrections before splitting.
  + #term[Split the data.] Create training, validation, and test data in a way that matches future use.
  + #term[Prepare the features.] Learn imputation, category encoding, scaling, and other data-dependent transformations from training data inside a pipeline.
  + #term[Build a baseline.] Start with a simple rule, such as predicting the average or most common class.
  + #term[Train and tune.] Fit candidate models on training data and choose settings with validation data.
  + #term[Evaluate once on the test set.] Use the untouched test data for the final estimate.
  + #term[Explain, deploy, and monitor.] Document limitations and check whether the data or performance changes over time.
]

Fit preprocessing on training data only, and never select a model using the test set. #secref(<sec:data-splits>) and #secref(<sec:data-leakage>) explain why.

== Generalization: the real goal

A student who memorizes last year’s paper can score full marks on last year’s paper and still fail this year. Memorizing is not understanding, and the difference shows only on questions the student has not seen. Models behave the same way. A model #term[generalizes] when it performs well on new examples from the setting where it will be used.

#workedexample[
  Fit a curve to all ten students, predicting the mark from hours. A wigglier curve can always match the rows it trains on more closely, so we also hide each student in turn, fit on the other nine, and predict the hidden one.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    align: (left, center, center),
    header: ([Curve], [Mean squared error on the rows it saw], [On the student it never saw]),
    [Straight line (degree 1)], [125.44], [206.83],
    [Simple arch (degree 2)], [18.34], [43.48],
    [Very wiggly (degree 7)], [3.48], [3907.53],
  )

  #raggedright[
  #v(6pt)
  The wiggly curve has the best score on what it saw and by far the worst on what it did not. It memorized the notebook. #chapref(<ch:training>) returns to this table.
  ]]]
]

Three outcomes are common:

#utptable[
  #tabularx(
    columns: (15%, 1fr),
    styles: (navy-bold,),
    header: ([Outcome], [Model behavior]),
    [Underfitting], [The model is too simple and performs poorly on both training and unseen data.],
    [Good fit], [The model captures useful structure and performs similarly on training and unseen data.],
    [Overfitting], [The model performs very well on training data but poorly on unseen data.],
  )
]

== What a wrong prediction costs

A smoke alarm can fail in two ways: it can ring when there is no fire, or stay silent when there is one. Nobody treats those as equal, and nobody should treat a model’s two kinds of mistake as equal without asking what each one costs. State the cost of each error type before choosing a model.

#utptable[
  #tabularx(
    columns: (25%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Problem], [Cost of a false alarm], [Cost of a miss]),
    [Spam filter], [A real email is hidden --- irritating and occasionally serious], [A spam email arrives --- mildly annoying],
    [Disease screening], [An unnecessary follow-up test --- costly and stressful], [An untreated illness --- potentially fatal],
    [Fraud detection], [A legitimate card is blocked --- an angry customer], [Money is lost --- direct financial damage],
    [Movie recommendation], [A poor suggestion --- ignored], [A good movie is not shown --- an invisible loss],
  )
]

Error costs determine which metrics matter. #chapref(<ch:evaluation>) develops precision, recall, ranking and thresholds for exactly these trade-offs.

#tryit[
  Choose an automated decision you meet every week, such as a spam filter, a ride-hailing price or a playlist. Name its observation, features, target, model and metric, and the cost of each error type. Then say which corner of #figref(<fig:ml-map>) it lives in.
]

== What to learn first

Follow the course map: tools and foundations first, each workflow before its models, then limited labels and rewards, deep learning, text, a model put to work, and the capstone. Chapters that follow the study log (#chapsref(<ch:regression>, <ch:classification>), @ch:clustering and~@ch:dimred) can be read as one connected story. To see every step of it run, use `python all_experiments/book_checks/demo_study_log.py`.

#chapterrecap[
  - A problem has five parts: observation, features, target, model and metric. Name them first.
  - Almost every method is one recipe: a model makes a guess, a loss scores it, an optimizer improves it. A new method usually changes one of the three.
  - One question splits the map: does your log hold the answers? With answers you predict a number or a category; without them you look for groups or for fewer columns.
  - Parameters are learned; hyperparameters are chosen; the loss guides fitting; the metric reports usefulness.
  - The goal is generalization. A low score on the rows a model has seen can be memorization.
]

#quickcheck[
  + What are the observation, features, target, model and metric in a problem that predicts whether a loan payment will be late?
  + Name which step of the recipe each phrase belongs to: “squared error”, “a straight line with two numbers”, “solve the formula for the best two numbers”.
  + Why is a learned model parameter different from a hyperparameter chosen during model selection?
  + A shop has years of sales records and wants to know which customers tend to buy together. It has no column saying which group anyone is in. Which corner of the map is this?
  + In the worked example above, why can excellent training performance still be evidence of a poor model?
]
