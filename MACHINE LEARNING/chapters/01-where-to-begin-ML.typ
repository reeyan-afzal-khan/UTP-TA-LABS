#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-where-to-begin-ML")


#heading(level: 1)[Where to Begin]
 <ch:orientation>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* No previous machine-learning knowledge is required. High-school algebra is enough for this chapter.

*By the end, you can:* name the observation, features, target, model and metric of a problem; describe any method as a model, a loss and an optimizer; place a problem on the map of learning settings; follow the project workflow; and explain why good training performance proves little.]

Linear regression, gradient descent, logistic regression, $K$-means, PCA. Taught one chapter at a time, these names feel like a pile of unrelated tricks, and a chart of them looks like a maze. They are less separate than they look. Almost every method in this book repeats the same three moves: make a guess, score how wrong it is, improve the guess. This chapter sets up that idea on one small notebook that we will keep returning to, small enough to check everything with a pen.


#heading(level: 2)[One tutor, one notebook]


A tutor runs a weekly revision group of ten students and wants to plan who needs extra help before the next exam. After the last exam the tutor wrote one line per student: hours studied in the final week, lectures attended out of 14, hours slept the night before, and the mark out of 100.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#figure(
  align(center)[#table(
    columns: 6,
    align: (center,center,center,center,center,center,),
    table.header([Student], [Hours studied], [Lectures attended], [Hours slept], [Mark], [Passed?],),
    table.hline(),
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
  )]
  , kind: table
  )], caption: [The study log. Ten rows and four columns are all the data this running example ever uses. A mark of 50 or more is a pass.]) <fig:study-log>

Read the hours and the mark together. Marks climb with study from student A to student F, then fall away: students I and J studied the most, attended the least, barely slept, and failed. Keep that bend in mind, because it comes back in several chapters.

The tutor can ask four different questions of this one notebook, and each question leads to a different kind of method:

- #emph[What mark should a student expect after nine hours of study?] The answer is a number (#ref(label("ch:regression"), supplement: [Chapter])).

- #emph[Will this student pass?] The answer is yes or no, and it would help to know how sure we are (#ref(label("ch:classification"), supplement: [Chapter])).

- #emph[What kinds of student are in this group?] Nobody wrote the kinds down, so the method has to find them (#ref(label("ch:clustering"), supplement: [Chapter])).

- #emph[Can four columns fit on one chart?] The answer is a smaller set of columns that keeps most of the story (#ref(label("ch:dimred"), supplement: [Chapter])).


#heading(level: 2)[The five parts of a machine-learning problem]


Machine learning builds systems that learn useful patterns from examples instead of following a rule written by hand for every situation. Any such problem has five parts, and it is worth naming them before touching any code.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Part], [Meaning], [In the study log],),
    table.hline(),
    [Observation], [One example, usually one row of a table.], [One student],
    [Feature], [An input known before the prediction is made.], [Hours studied, lectures attended, hours slept],
    [Target], [The answer the model should learn to predict. Also called the label.], [The mark, or whether the student passed],
    [Model], [A mathematical rule that turns features into a prediction.], [$upright("mark") = 3 times upright("hours") + 40$],
    [Metric], [A number that judges whether the model is useful on data it has not seen.], [Average size of the miss, in marks],
  )]
  , kind: table
  )

#emph[Training] means learning the rule from rows whose answers are known. #emph[Prediction] means applying that rule to a new row whose answer is missing. A used-car price model has the same five parts: one listing per row, age and mileage as features, asking price as the target, a weighted sum as the model, and mean absolute error as the metric.


#heading(level: 2)[The recipe behind every method]
 <sec:recipe>

Here is the idea this whole book rests on. Choosing a method means filling in three blanks.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/0c45b58dfb04caff.svg")], caption: [The recipe. A model makes a guess, a loss scores how wrong the guess is, and an optimizer improves the numbers inside the model. When you meet a new method name, ask which of the three steps it changes.]) <fig:recipe>

#callout("workedexample", title: [Worked example])[Take the first six students and the guess $upright("mark") = 2 times upright("hours") + 47$.

/ Model.: #block[
A straight line with two changeable numbers, the 2 and the 47.
]

/ Loss.: #block[
Student B studied 4 hours, so the guess is $2 times 4 + 47 = 55$. The real mark was 50, a miss of $- 5$. Square each of the six misses and average them: the score is 13.67.
]

/ Optimizer.: #block[
Try other numbers. The line $upright("mark") = 3 times upright("hours") + 40$ scores 2.00, and no other straight line scores lower. #ref(label("ch:regression"), supplement: [Chapter]) shows how to find it without trying them all.
]]

The numbers the optimizer changes are the model's #strong[parameters]. Some settings are not learned at all: you fix them before training, or choose among them by experiment. Those are #strong[hyperparameters]. A loss guides fitting; a metric reports how useful the result is to the people who will use it. The two may differ, as they do when a model trains on squared error but is reported by its average miss in marks.

#block[
ll l

Term & Who chooses it? & Example \
Parameter & Learned from training data & A regression coefficient or a tree split Hyperparameter & Chosen before or during model selection & Number of neighbors, tree depth, regularization strength Loss & Used by the training process to measure wrongness & Squared error, cross-entropy Metric & Used to report practical performance & Accuracy, recall, MAE, RMSE

]


#heading(level: 2)[Does your log hold the answers?]
 <sec:map>

Before picking a method, ask one question about your data. Look back at the study log. If you want to predict the mark, the answers are sitting in a column: every past student shows what happened, so a model can learn from them. If you want to know what kinds of student there are, no column holds the answer, and nobody can mark a guess right or wrong. That single difference splits the map of machine learning in two (#ref(label("fig:ml-map"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/33a5bfead437ec0f.svg")], caption: [The map. One question splits the field, and a second question names the job. Every method in Stages 3 and 4 of this book lives in one of these four corners.]) <fig:ml-map>

Two settings sit beside this map, because their feedback is different. In #strong[semi-supervised learning] only a few rows have answers, so unlabeled rows must help (#ref(label("ch:semi-supervised"), supplement: [Chapter])). In #strong[reinforcement learning] no answers exist at all, only a score that arrives after the learner acts (#ref(label("ch:rl"), supplement: [Chapter])). Neural networks (#ref(label("ch:deep"), supplement: [Chapter])) do not get their own corner: they are a richer kind of model that can be used in any of them.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Learning setting], [How it works],),
    table.hline(),
    [Supervised learning], [Learns from labeled examples to predict values or classes.],
    [Unsupervised learning], [Finds groups, patterns, or unusual cases without labels.],
    [Semi-supervised learning], [Combines a small labeled set with a larger unlabeled set.],
    [Reinforcement learning], [Learns actions through interaction and rewards over time.],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/4c05dd224a043b3c.svg")], caption: [The field map: four learning settings, told apart by the feedback available. Supervised learning has an answer for every example, semi-supervised for some, unsupervised for none, and reinforcement learning receives a score after it acts.]) <fig:field-map>

#callout("intuition", title: [Plain idea])[#strong[Self-supervised learning] creates targets from the data itself, such as hidden words or image regions, to learn representations. #strong[Active learning] chooses which examples to send to a person for labeling. Both change where the feedback comes from, which is why this map is drawn around feedback and not around algorithms.]


#heading(level: 2)[The complete workflow]


The recipe describes how one model learns. A real project wraps it in a longer routine, because a model is only as good as the question and the data around it.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/MACHINE LEARNING/figures/diagrams/4f979068b9464280.svg")], caption: [The complete workflow, from defining the problem to explaining and monitoring the model. The steps are described in the list that follows.]) <fig:ml-workflow>

+ #strong[Define the decision.] State what must be predicted, who will use the result, and what a wrong prediction costs.

+ #strong[Validate the data.] Check rows, keys, units, missingness, timing, and bias. Apply only fixed, label-blind corrections before splitting.

+ #strong[Split the data.] Create training, validation, and test data in a way that matches future use.

+ #strong[Prepare the features.] Learn imputation, category encoding, scaling, and other data-dependent transformations from training data inside a pipeline.

+ #strong[Build a baseline.] Start with a simple rule, such as predicting the average or most common class.

+ #strong[Train and tune.] Fit candidate models on training data and choose settings with validation data.

+ #strong[Evaluate once on the test set.] Use the untouched test data for the final estimate.

+ #strong[Explain, deploy, and monitor.] Document limitations and check whether the data or performance changes over time.

Fit preprocessing on training data only, and never select a model using the test set. #ref(label("sec:data-splits"), supplement: [Section]) and #ref(label("sec:data-leakage"), supplement: [Section]) explain why.


#heading(level: 2)[Generalization: the real goal]


A student who memorizes last year's paper can score full marks on last year's paper and still fail this year. Memorizing is not understanding, and the difference shows only on questions the student has not seen. Models behave the same way. A model #strong[generalizes] when it performs well on new examples from the setting where it will be used.

#callout("workedexample", title: [Worked example])[Fit a curve to all ten students, predicting the mark from hours. A wigglier curve can always match the rows it trains on more closely, so we also hide each student in turn, fit on the other nine, and predict the hidden one.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,center,),
    table.header([Curve], [Mean squared error on the rows it saw], [On the student it never saw],),
    table.hline(),
    [Straight line (degree 1)], [125.44], [206.83],
    [Simple arch (degree 2)], [18.34], [43.48],
    [Very wiggly (degree 7)], [3.48], [3907.53],
  )]
  , kind: table
  )

The wiggly curve has the best score on what it saw and by far the worst on what it did not. It memorized the notebook. #ref(label("ch:training"), supplement: [Chapter]) returns to this table.]

Three outcomes are common:

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Outcome], [Model behavior],),
    table.hline(),
    [Underfitting], [The model is too simple and performs poorly on both training and unseen data.],
    [Good fit], [The model captures useful structure and performs similarly on training and unseen data.],
    [Overfitting], [The model performs very well on training data but poorly on unseen data.],
  )]
  , kind: table
  )


#heading(level: 2)[What a wrong prediction costs]


A smoke alarm can fail in two ways: it can ring when there is no fire, or stay silent when there is one. Nobody treats those as equal, and nobody should treat a model's two kinds of mistake as equal without asking what each one costs. State the cost of each error type before choosing a model.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Problem], [Cost of a false alarm], [Cost of a miss],),
    table.hline(),
    [Spam filter], [A real email is hidden --- irritating and occasionally serious], [A spam email arrives --- mildly annoying],
    [Disease screening], [An unnecessary follow-up test --- costly and stressful], [An untreated illness --- potentially fatal],
    [Fraud detection], [A legitimate card is blocked --- an angry customer], [Money is lost --- direct financial damage],
    [Movie recommendation], [A poor suggestion --- ignored], [A good movie is not shown --- an invisible loss],
  )]
  , kind: table
  )

Error costs determine which metrics matter. #ref(label("ch:evaluation"), supplement: [Chapter]) develops precision, recall, ranking and thresholds for exactly these trade-offs.

#callout("tryit", title: [Try it yourself])[Choose an automated decision you meet every week, such as a spam filter, a ride-hailing price or a playlist. Name its observation, features, target, model and metric, and the cost of each error type. Then say which corner of #ref(label("fig:ml-map"), supplement: [Figure]) it lives in.]


#heading(level: 2)[What to learn first]


Follow the course map: tools and foundations first, each workflow before its models, then advanced topics and the capstone. Chapters that follow the study log (Chapters #ref(label("ch:regression"), supplement: none)--#ref(label("ch:classification"), supplement: none), #ref(label("ch:clustering"), supplement: none) and~#ref(label("ch:dimred"), supplement: none)) can be read as one connected story. To see every step of it run, use `python all_experiments/ demo_study_log.py`.

#callout("chapterrecap", title: [Chapter recap])[- A problem has five parts: observation, features, target, model and metric. Name them first.

- Almost every method is one recipe: a model makes a guess, a loss scores it, an optimizer improves it. A new method usually changes one of the three.

- One question splits the map: does your log hold the answers? With answers you predict a number or a category; without them you look for groups or for fewer columns.

- Parameters are learned; hyperparameters are chosen; the loss guides fitting; the metric reports usefulness.

- The goal is generalization. A low score on the rows a model has seen can be memorization.]

#callout("quickcheck", title: [Check your understanding])[+ What are the observation, features, target, model and metric in a problem that predicts whether a loan payment will be late?

+ Name which step of the recipe each phrase belongs to: "squared error", "a straight line with two numbers", "solve the formula for the best two numbers".

+ Why is a learned model parameter different from a hyperparameter chosen during model selection?

+ A shop has years of sales records and wants to know which customers tend to buy together. It has no column saying which group anyone is in. Which corner of the map is this?

+ In the worked example above, why can excellent training performance still be evidence of a poor model?]
