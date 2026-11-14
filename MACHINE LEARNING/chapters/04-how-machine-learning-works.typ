#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "04-how-machine-learning-works")

= How Machine Learning Works <ch:learning>

#chapterguide[#chapref(<ch:orientation>)’s recipe and #chapref(<ch:data>): a trustworthy table and a split that matches the real prediction setting.][say what feedback a problem offers and which learning setting follows; state a learning objective; walk downhill by gradient descent by hand; choose a sensible learning rate; and separate lowering a training loss from generalizing.]

#chapref(<ch:orientation>) gave the recipe in three words: model, loss, optimizer. This chapter looks at what fills each blank. The feedback in your data decides the first two. The third is, more often than not, a walk down a hill in thick fog.

#keyidea[
  Labels guide prediction; unlabeled data supports structure discovery; rewards guide actions. Whichever you have, you still write down a number to make small, and you still search for the settings that make it small.
]

== Start with the learning signal

#chapref(<ch:orientation>) sorted the field by the feedback a problem offers (#figref(<fig:field-map>)). The feedback decides what a learner is given, and so what it can learn:

#utptable[
  #tabularx(
    columns: (21%, 22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Setting], [Given], [What is learned?], [Typical question]),
    [Supervised], [$X$ and label $y$], [A mapping from features to a label], [“What value or class should I predict?”],
    [Unsupervised], [$X$ only], [Structure, representation, density, or unusualness in the features], [“What patterns are present when no answer key is supplied?”],
    [Semi-supervised / active], [$X$ plus some labels], [A predictive mapping that also uses unlabeled structure or selectively requests labels], [“How can scarce labels be used efficiently?”],
    [Reinforcement], [States, actions, rewards, transitions], [A policy or value rule for sequential decisions], [“Which action leads to good long-term outcomes?”],
  )
]

== What changes between supervised and unsupervised learning

Every setting follows the workflow of #figref(<fig:ml-workflow>): define the question, prepare the data, fit, evaluate, then use and monitor the result. What changes most from one setting to the next is the evaluation. Supervised learning compares predictions with labels. Unsupervised learning needs evidence beyond an answer key. Reinforcement learning evaluates behavior across whole sequences of actions.

#utptable[
  #tabularx(
    columns: (25%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Question], [Supervised learning], [Unsupervised learning]),
    [Data?], [Features $X$ and labels $y$], [Features $X$ only],
    [Fitting objective?], [Minimize prediction loss], [Cluster compactness, reconstruction, variance, density, or isolation],
    [Output?], [Predictions, scores, or probabilities], [Groups, representations, densities, anomalies, or patterns],
    [Baseline?], [Mean, median, majority, or domain rule], [A trivial structure to beat: one cluster, a random partition, or the mean as the reconstruction],
    [What counts as “good”?], [Strong performance on realistic unseen data], [Structure that is stable, makes sense to a domain expert, and is useful for a downstream task],
  )
]

#pitfall[
  A cluster need not be a class, a PCA component is not a prediction, and an anomaly score is not a fraud probability. Choose evaluation to match the objective.
]

== The recipe, filled in four times

Here are the four core methods of this book written in the same three lines. You do not need to understand each cell yet; the point is that the table has the same shape all the way down.

#utptable[
  #tabularx(
    columns: (20%, 1fr, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Method], [Model], [Loss], [Optimizer]),
    [Linear regression (#chapref(<ch:regression>))], [A straight line with a slope and an intercept], [Mean squared error], [An exact formula],
    [Logistic regression (#chapref(<ch:classification>))], [The same line, squashed into a probability], [Log loss], [Gradient descent],
    [$K$-means (#chapref(<ch:clustering>))], [$K$ landmarks], [Total squared distance to the nearest landmark], [Assign, move, repeat],
    [PCA (#chapref(<ch:dimred>))], [A few directions to flatten the data onto], [The spread lost by flattening], [An exact matrix routine],
  )
]

The optimizer column shows two kinds of answer. Sometimes mathematics hands you the best numbers directly, and you are done in one step. Often it does not, and you have to search. The most important search in machine learning is next.

== A first look at optimization: walking down a hill in fog <sec:gradient-descent>

#analogy[
  You are standing on a hillside in fog so thick you cannot see the valley. You can, however, feel the slope under your feet. So you do the only sensible thing: take a small step in the direction that goes downhill, feel the slope again, and repeat. Where you stand is the model’s numbers, your height is the loss, and the slope under your feet is the gradient.
]

Practice on the simplest hill there is. Let $J(v)=(v-4)^2$. Its graph is a bowl with one lowest point, at $v=4$, but pretend you do not know that, and start at $v=0$.

#emph[How steep is it here?] You can measure this without any calculus. Nudge $v$ from $0$ to $0.001$. The height drops from 16 to 15.992001, a change of $-0.007999$ for a nudge of $0.001$, so the slope is about $-8$. The formula from calculus says the same: $J'(v)=2(v-4)$, which at $v=0$ is $-8$. A negative slope means that going right goes down.

#emph[Take a step.] Move against the slope by a small multiple of it:

$ v arrow.l v- alpha thin J'(v). $

The multiplier $alpha$ is the #term[learning rate]. With $alpha =0.1$ the first step is $v arrow.l 0-0.1 times (-8)=0.8$. Here are five steps, printed by the code below.

#workedexample[
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto, auto),
    align: (center, center, center, center, center),
    header: ([Step], [$v$], [Height $J(v)$], [Slope $2(v-4)$], [Move $-0.1 times$slope]),
    [0], [0.0000], [16.0000], [$-8.00$], [$+0.80$],
    [1], [0.8000], [10.2400], [$-6.40$], [$+0.64$],
    [2], [1.4400], [6.5536], [$-5.12$], [$+0.51$],
    [3], [1.9520], [4.1943], [$-4.10$], [$+0.41$],
    [4], [2.3616], [2.6844], [$-3.28$], [$+0.33$],
    [5], [2.6893], [1.7180], [], [],
  )

  #raggedright[
  #v(6pt)
  Each step is shorter than the last, because the bowl flattens as you approach the bottom. Nobody told the loop that the answer was 4; after 30 steps it stands at 3.9950.
  ]]]
]

#codefrom("/MACHINE LEARNING/all_experiments/book_checks/demo_study_log.py", "def walk(", "return path")

With many parameters, $v$ becomes a whole vector $bold(theta)$ and the slope becomes the #term[gradient] $nabla J(bold(theta))$, one slope per parameter (#chapref(<ch:foundations>)). The rule keeps its shape:

$ bold(theta) arrow.l bold(theta)- alpha nabla J(bold(theta)). $

This one line trains logistic regression in #chapref(<ch:classification>) and the neural networks in #chapref(<ch:deep>).

== The one number you must choose

The learning rate is a hyperparameter: nothing in the data sets it, and it decides whether the walk works at all (#figref(<fig:learning-rates>)).

#utpfig([Five steps from $v=0$ on the bowl $J(v)=(v-4)^2$, with three learning rates. Too small crawls, a sensible rate arrives, and too large leaps across the bowl and climbs the far side. The rate of 1.1 leaps to 8.80, then to $-1.76$, and its next step, 10.91, is off the chart.], label: <fig:learning-rates>)[
  #canvas({
    groupplot(group-size: (3, 1), horizontal-sep: 0.75cm, ..logaxis, width: 5.65cm, height: 4.3cm, xmin: -2.5, xmax: 10.5, ymin: 0, ymax: 36, xlabel: [$v$], xtick: (0, 4, 8), ytick: (0, 10, 20, 30), enlargelimits: false, clip: true,
      nextgroupplot(title: [$alpha =0.01$: crawls], ylabel: [$J(v)$],
        addplot(draw: mix(muted, 70%), domain: (-2.5, 10.5), samples: 60, x => calc.pow((x - 4), 2)),
        addplot(draw: orange, mark: "*", mark-size: 1.3948pt, line-width: widths.thick, coords: ((0, 16), (0.08, 15.3664), (0.1584, 14.7579), (0.2352, 14.1737), (0.3105, 13.6124), (0.3843, 13.0733))),
      ),
      nextgroupplot(title: [$alpha =0.1$: arrives], yticklabels: (),
        addplot(draw: mix(muted, 70%), domain: (-2.5, 10.5), samples: 60, x => calc.pow((x - 4), 2)),
        addplot(draw: blue, mark: "*", mark-size: 1.3948pt, line-width: widths.thick, coords: ((0, 16), (0.8, 10.24), (1.44, 6.5536), (1.952, 4.1943), (2.3616, 2.6844), (2.6893, 1.718))),
      ),
      nextgroupplot(title: [$alpha =1.1$: overshoots], yticklabels: (),
        addplot(draw: mix(muted, 70%), domain: (-2.5, 10.5), samples: 60, x => calc.pow((x - 4), 2)),
        addplot(draw: red, mark: "*", mark-size: 1.3948pt, line-width: widths.thick, coords: ((0, 16), (8.8, 23.04), (-1.76, 33.18))),
      ),
    )
  })
]

#keepspace(176.15pt)

#workedexample[
  Five steps from $v=0$ with three learning rates:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center),
    header: ([Rate], [0], [1], [2], [3], [4], [5]),
    [0.01], [0], [0.08], [0.16], [0.24], [0.31], [0.38],
    [0.1], [0], [0.80], [1.44], [1.95], [2.36], [2.69],
    [1.1], [0], [8.80], [$-1.76$], [10.91], [$-4.29$], [13.95],
  )

  #raggedright[
  #v(6pt)
  At 1.1 the walk jumps over the bottom, lands higher on the far side, and gets worse with every step. When a training loss climbs or turns into `nan`, this is the first thing to suspect. Lab~7 shows the same failure on a real network: a learning rate 100 times too large leaves the CNN at chance level.
  ]]]
]

#intuition[
  The gradient sets the direction and the learning rate sets the stride. Small strides are safe and slow; large strides are fast until they are not.
]

== Bowls, and hills that are not bowls

The bowl above has exactly one lowest point, so any sensible walk ends in the same place. The losses of linear regression and logistic regression have that shape too, which makes them dependable. Losses of $K$-means and neural networks do not: they have many dips, so a walk can stop in a local one, and where you start matters. #chapref(<ch:clustering>) shows this on the study log, where one starting choice ends with a score of 340.67 and another with 778.50.

#keyidea[
  Reducing training loss does not establish generalization. An optimizer’s job is to make one number small on the rows it can see, and it will memorize those rows if the model allows. Evaluate on unseen data.
]

== Now learn only the mathematics that the workflow needs

#chapref(<ch:foundations>) collects the mathematics this workflow leans on: center, spread, probability, vectors, matrix shapes, dot products, distances and gradients. Learn those first, and revisit deeper results when a model needs them.

#chapterrecap[
  - The available feedback picks the setting: labels, some labels, no labels, or rewards.
  - Every method fills in the same three blanks. Some optimizers are exact formulas, and others are searches.
  - Gradient descent walks downhill: measure the slope, step against it, repeat. You can measure a slope by nudging, with no calculus.
  - The learning rate is the stride. At $alpha =0.1$ the practice bowl took 30 steps to reach 3.995; at $alpha =1.1$ the walk diverged.
  - A low training loss is not the goal. Generalization is.
]

#quickcheck[
  + What feedback signal separates supervised, unsupervised, limited-label and reinforcement-learning problems?
  + On the bowl $J(v)=(v-4)^2$, standing at $v=6$ with $alpha =0.1$, what is the next value of $v$?
  + Why does the size of each step shrink on a bowl, even though $alpha$ stays the same?
  + Your training loss rises steadily from the first epoch. Which setting do you check first, and in which direction do you change it?
  + Why can two learning settings share data preparation and monitoring while needing different fitting objectives?
  + What is the difference between reducing a training objective and demonstrating generalization?
]
