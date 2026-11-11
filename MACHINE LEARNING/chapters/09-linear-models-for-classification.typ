#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-linear-models-for-classification")


#heading(level: 1)[Linear Models for Classification]
 <ch:classification>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* #ref(label("ch:regression"), supplement: [Chapter]), #ref(label("ch:training"), supplement: [Chapter]), the gradient-descent walk of #ref(label("sec:gradient-descent"), supplement: [Section]), and probability from #ref(label("ch:foundations"), supplement: [Chapter]).

*By the end, you can:* explain why a line cannot output a probability; turn a score into a probability with the sigmoid; compute log loss by hand and say why it beats squared error; fit a logistic model by gradient descent; move a threshold on purpose; and compare softmax, LDA, QDA and the perceptron.]

The tutor's next question has a different kind of answer: will this student pass? A mark can be any number, but a pass is yes or no. And because a wrong answer costs something (a student who needed help gets none, or tutoring hours go to a student who was fine), the tutor wants more than a verdict. The tutor wants to know how sure the model is.


#heading(level: 2)[Why not just use linear regression?]


Look at the lectures column against who passed. Students who attended 3 and 5 lectures failed, and those who attended 9 or more passed. In between it is mixed: B passed with 6, and A failed with 8. Write fail as 0 and pass as 1, and fit the same straight line as before: $ hat(y) = 0.100 times upright("lectures") - 0.136 . $ The fit runs without complaint until you read what it says. At 13 lectures the answer is 1.158, a 116% chance. At 0 lectures it is $- 0.136$, a chance of minus 14%. A straight line has no idea that a probability must stop at 0 and at 1 (#ref(label("fig:s-curve"), supplement: [Figure])).


#heading(level: 2)[The dimmer switch]


#callout("analogy", title: [Analogy])[A light switch is off or on, like our labels. A dimmer sweeps smoothly from dark to full brightness, and however far you turn the dial, the light cannot go below off or above fully on. Keep the straight line as the dial, and pass its output through a dimmer. The dial position is the #strong[score], and the brightness is the probability.]

That dimmer is the #strong[sigmoid], a name that just means S-shaped: $ sigma \( z \) = frac(1, 1 + e^(- z)) \, #h(2em) z = w thin x + b . $ Here $e approx 2.72$ is a fixed number. A score of 0 gives exactly 0.5, because $e^0 = 1$. A score of 2 gives 0.881 and a score of $- 2$ gives 0.119. The sign of the score picks the side, and its size sets the confidence. The combined model is called #strong[logistic regression]. The name is confusing, since it does classification, but it is the old name and everyone uses it.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/8c6d4e2f1bde7e4d.cetz.json")], caption: [Pass or fail against lectures attended. The straight line leaves the possible range at both ends, shown in red. The fitted S-curve stays between 0 and 1 and crosses 0.5 at 6.30 lectures. Student A failed with 8 lectures, and student B passed with 6.]) <fig:s-curve>


#heading(level: 2)[From probabilities to odds to a linear model]


The sigmoid has a neat reverse reading, which explains what the slope means. #strong[Odds] are $p \/ \( 1 - p \)$: $p = 0.75$ gives odds of 3. Their logarithm, the #strong[logit], spans the whole number line, and logistic regression assumes it is linear in the features:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Probability], [Odds], [Read aloud],),
    table.hline(),
    [$50 %$], [$1 : 1$], [equally likely either way],
    [$75 %$], [$3 : 1$], [three chances for, one against],
    [$90 %$], [$9 : 1$], [nine chances for, one against],
  )]
  , kind: table
  )

$ log frac(p, 1 - p) = beta_0 + bold(beta)^(sans(T)) bold(x) \, #h(2em) upright("equivalently") #h(2em) P \( Y = 1 divides bold(x) \) = sigma \( beta_0 + bold(beta)^(sans(T)) bold(x) \) . $

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/90e37ac2acbe8e76.cetz.json")], caption: [The sigmoid maps an unrestricted score to a probability. Scores near zero give probabilities near $0.5$; large positive or negative scores give confident answers.]) <fig:sigmoid>

A unit increase in $x_j$ multiplies the odds by $e^(beta_j)$, holding other features fixed. So $beta_j = 0.7$ roughly doubles the odds and $- 0.7$ roughly halves them. The effect on the probability depends on where you start, because the curve is steep in the middle and flat at the ends.

#callout("workedexample", title: [Worked example])[Suppose a pass/fail model based on hours studied has $beta_0 = - 4$ and $beta_1 = 0.08$. A student with $x = 60$ hours has score $z = - 4 + 0.08 times 60 = 0.8$ and pass probability $sigma \( 0.8 \) approx 0.69$. A student with $x = 30$ hours has $z = - 1.6$ and $sigma \( - 1.6 \) approx 0.17$. Each additional hour multiplies the odds of passing by $e^0.08 approx 1.083$ --- about an $8 %$ increase in the odds, regardless of the starting point.]


#heading(level: 2)[The loss: confident and wrong]


We need to score a probability. Reaching for squared error again seems natural, so try it on a student who failed, with the model giving three different chances of passing.

#callout("workedexample", title: [Worked example])[#figure(
  align(center)[#table(
    columns: 4,
    align: (left,center,center,center,),
    table.header([Chance given to "pass"], [The lean], [Squared error], [Log-loss fee],),
    table.hline(),
    [0.60], [mild], [$0.60^2 = 0.360$], [$- ln \( 0.40 \) = 0.916$],
    [0.90], [strong], [$0.90^2 = 0.810$], [$- ln \( 0.10 \) = 2.303$],
    [0.99], [certain], [$0.99^2 = 0.980$], [$- ln \( 0.01 \) = 4.605$],
  )]
  , kind: table
  )

Squared error cannot pass 1, so being certain and wrong costs 0.98, barely more than the 0.81 for merely leaning that way. It has run out of room exactly where the mistake is worst. The fee on the right has no ceiling.]

The better score is #strong[log loss], also called #strong[cross-entropy]: the fee is minus the logarithm of the probability the model gave to what actually happened. $ cal(L) \( y \, p \) = - \[ y log p + \( 1 - y \) log \( 1 - p \) \] . $ A probability is below 1, so its logarithm is negative, and the minus sign turns that into a positive fee. A sure right answer is almost free. A sure wrong answer is ruinous. A model that says 50% pays 0.693 whichever way the case goes (#ref(label("fig:fees"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/2a64660650d7e876.cetz.json")], caption: [The log-loss fee against the chance given to "pass", for a student who passed and a student who failed. The two curves cross at 0.5, where the fee is 0.693, and each climbs without limit as the model grows confident and wrong. Squared error for a failing student is shown for comparison.]) <fig:fees>


#heading(level: 2)[The optimizer: walking down]


Unlike squared error on a line, log loss has no exact formula for its best $w$ and $b$, so the model has to walk. Everything you need is already here: the model, the loss, and the gradient-descent rule from #ref(label("sec:gradient-descent"), supplement: [Section]). The two slopes work out neatly: for each row, the slope is simply the prediction minus the truth, $\( p_i - y_i \)$, weighted by the feature. $ frac(partial J, partial w) = 1 / n sum_i \( p_i - y_i \) thin x_i \, #h(2em) frac(partial J, partial b) = 1 / n sum_i \( p_i - y_i \) . $ We center the lectures on 8, because that keeps the numbers small. Nothing else changes. The whole fit, in code:

#source-code("/MACHINE LEARNING/all_experiments/book_checks/demo_study_log.py", first: 61, last: 80, lang: "python")

#callout("workedexample", title: [Worked example])[At the start, $w = b = 0$, so every $p$ is 0.5. The formula gives a slope of $- 1.0000$ for $w$. Nudging $w$ by 0.001 and remeasuring the loss gives $- 0.9988$, so the formula checks out. With a learning rate of 0.1:

#figure(
  align(center)[#table(
    columns: 4,
    align: (center,center,center,center,),
    table.header([Step], [$w$], [$b$], [Log loss],),
    table.hline(),
    [1], [0.1000], [0.0200], [0.6011],
    [10], [0.4497], [0.1612], [0.4285],
    [100], [0.6819], [0.8664], [0.3528],
    [500], [0.7827], [1.3163], [0.3430],
    [2000], [0.7885], [1.3371], [0.3430],
  )]
  , kind: table
  )

The loss falls fast and then barely moves, because the walk has reached the flat bottom.]


#heading(level: 2)[What the fitted model says]


Follow one student all the way through. Student A attended 8 lectures, so the centered value is 0. The score is $0.7885 times 0 + 1.3371 = 1.337$, and the chance of passing is $sigma \( 1.337 \) = 0.792$. The score can be any number at all; the probability can never leave 0 to 1.

#figure(
  align(center)[#table(
    columns: 7,
    align: (center,center,center,center,center,center,center,),
    table.header([Student], [Lectures], [Passed?], [Score], [Chance], [Verdict], [Right?],),
    table.hline(),
    [J], [3], [no], [$- 2.605$], [0.069], [fail], [yes],
    [I], [5], [no], [$- 1.028$], [0.263], [fail], [yes],
    [B], [6], [yes], [$- 0.240$], [0.440], [fail], [#strong[no]],
    [C], [7], [yes], [0.549], [0.634], [pass], [yes],
    [A], [8], [no], [1.337], [0.792], [pass], [#strong[no]],
    [D], [9], [yes], [2.126], [0.893], [pass], [yes],
    [H], [10], [yes], [2.914], [0.949], [pass], [yes],
    [E], [11], [yes], [3.703], [0.976], [pass], [yes],
    [G], [12], [yes], [4.491], [0.989], [pass], [yes],
    [F], [13], [yes], [5.280], [0.995], [pass], [yes],
  )]
  , kind: table
  )

The model is right on 8 of 10. Its two mistakes differ in kind. Student B was a near thing at 0.44, and pays a fee of 0.820. Student A is the expensive one: the model was 79% sure, and A failed, for a fee of 1.570. A's two hours of study are not visible to a model that sees only lectures, which is a reminder that a model can be only as good as its columns.

Each extra lecture multiplies the odds of passing by $e^0.7885 = 2.20$. The score is zero, and the chance exactly 0.5, at $8 - 1.3371 \/ 0.7885 = 6.30$ lectures. That point is the #strong[decision boundary].


#heading(level: 3)[The decision boundary and the threshold]


At threshold $0.5$, class~1 means $z gt.eq 0$, giving the boundary $beta_0 + bold(beta)^(sans(T)) bold(x) = 0$. With two features that boundary is a straight line, and with more it is a flat plane, which is why logistic regression is called a linear classifier even though its output curve is not straight.

The probability and the decision are separate objects. The model supplies the first. The threshold is a policy, chosen to reflect error costs on validation or out-of-fold predictions (#ref(label("ch:evaluation"), supplement: [Chapter])). These are Lab~2's results for one fitted model on the 40,687 hotel bookings of 2017, Part~C, where a flagged booking is treated as a likely cancellation:

#figure(
  align(center)[#table(
    columns: 6,
    align: (left,center,center,center,center,left,),
    table.header([Threshold], [Flagged], [Precision], [Recall], [Cancellations missed], [What changed],),
    table.hline(),
    [0.30], [20,052], [0.61], [0.77], [3,558], [many bookings flagged; most cancellations caught],
    [0.50], [11,095], [0.78], [0.55], [7,129], [the default],
    [0.70], [4,822], [0.96], [0.29], [11,117], [few flagged, almost all right; most cancellations missed],
  )]
  , kind: table
  )

Choose the operating point from a stated cost or capacity. Then refit on all training data and assess the locked rule on the test set once.


#heading(level: 3)[Regularization]


Use $L_1$ or $L_2$ penalties with appropriately scaled features and validation-selected strength (#ref(label("ch:regression"), supplement: [Chapter])). Regularization also stops coefficients diverging on perfectly separable data, where a steeper S always scores better and the walk would never end. Lab~2's grid search tunes this strength as $C$, and in scikit-learn a larger $C$ means a weaker penalty.

#callout("modelcard", title: [The recipe: Logistic regression])[*1. Model* The straight line's score, squashed by the sigmoid into a probability.

*2. Loss* Log loss, which is very large when the model is confident and wrong.

*3. Optimizer* Gradient descent or a Newton-type method. No exact formula exists.]


#heading(level: 2)[Softmax regression for multiple classes]


For $K$ classes, each class $k$ receives its own weight vector, and the #strong[softmax] function converts the $K$ linear scores into probabilities: $ P \( Y = k divides bold(x) \) = frac(exp \( bold(beta)_k^(sans(T)) bold(x) \), sum_(j = 1)^K exp \( bold(beta)_j^(sans(T)) bold(x) \)) . $ Exponentiating and normalizing preserves score order and makes probabilities sum to one. Training minimizes $cal(L) = - log P \( Y = y divides bold(x) \)$.

#strong[One-vs-rest] trains $K$ binary classifiers, one class against all others, and predicts the highest-scoring class.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/MACHINE LEARNING/figures/diagrams/096175a048ec7e37.cetz.json")], caption: [Softmax turns class scores into probabilities. Scores 1.2, 3.4 and 2.0 become 0.08, 0.74 and 0.18: the order is preserved and the probabilities add to one.]) <fig:softmax>

#callout("workedexample", title: [Worked example])[For scores $1.2 \, med 3.4 \, med 2.0$, the exponentials are $3.32 \, med 29.96 \, med 7.39$, which add to $40.67$. Dividing gives $0.082 \, med 0.737 \, med 0.182$.]

#callout("keyidea", title: [Key idea])[Softmax preserves score order while normalizing exponentials to a probability distribution.]


#heading(level: 2)[Ordered categories are not ordinary multiclass labels]
 <sec:ordinal-labels>

#strong[Ordinal labels] have order, such as low $<$ medium $<$ high. Softmax ignores order; numerical coding for regression assumes meaningful gaps.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Approach], [When it makes sense],),
    table.hline(),
    [Ordinary multiclass classifier], [Use when categories are genuinely unordered or when order is irrelevant to the decision.],
    [Ordinal model / order-aware loss], [Prefer when confusing adjacent levels is meaningfully less serious than confusing the two extremes.],
    [Regression on integer codes], [Use only when the numerical spacing itself is defensible; do not use it merely because the labels can be numbered.],
  )]
  , kind: table
  )

Choose order-aware methods or metrics when warranted, and validate whether they help.


#heading(level: 2)[Linear discriminant analysis]


Logistic regression learns the boundary directly. Another way to classify is to describe each class by itself, and then ask which description fits a new row better.

Logistic regression is #strong[discriminative]: it models $P \( y divides bold(x) \)$. #strong[Linear discriminant analysis (LDA)] is #strong[generative]: it models each class's feature distribution and applies Bayes' theorem.

LDA assumes Gaussian classes with means $bold(mu)_k$, shared covariance $Sigma$, and priors $pi_k$. Choose the largest discriminant score: $ delta_k \( bold(x) \) = bold(x)^(sans(T)) Sigma^(- 1) bold(mu)_k - 1 / 2 bold(mu)_k^(sans(T)) Sigma^(- 1) bold(mu)_k + log pi_k . $ Estimate priors from frequencies, means within classes, and covariance from pooled within-class variation. Linear dependence on $bold(x)$ gives flat boundaries.

#callout("workedexample", title: [Worked example])[On the lectures column of the log, passing students average 9.71 lectures and failing students 5.33, with a pooled variance of 6.51. With equal class sizes the boundary would be the midpoint, 7.52. Passing is more common here (7 of 10), and the prior moves the boundary down to 6.26, close to logistic regression's 6.30.]

#callout("intuition", title: [Plain idea])[With equal-shaped Gaussian class densities, the tie boundary is linear; class priors shift its position.]

When to prefer which:

- LDA can be stable on small datasets when Gaussian assumptions are reasonable.

- Logistic regression assumes less about the features and is more robust when classes are far from Gaussian (heavy tails, strong outliers, many binary features).

- LDA also finds up to $K - 1$ supervised projection directions for $K$ classes (#ref(label("ch:dimred"), supplement: [Chapter])).

#strong[Quadratic discriminant analysis (QDA)] drops the shared-covariance assumption and gives each class its own $Sigma_k$. The boundaries become curved (quadratic), which is more flexible but requires estimating many more parameters --- QDA needs considerably more data per class to stay reliable.


#heading(level: 2)[The perceptron]


The perceptron is the simplest trainer there is, and the ancestor of the neural networks in #ref(label("ch:deep"), supplement: [Chapter]). It has no probabilities and no loss curve: when it makes a mistake it moves the line, and when it does not, it does nothing.

The #strong[perceptron] predicts $hat(y) = "sign" \( bold(w)^(sans(T)) bold(x) + b \)$ for $y in { - 1 \, + 1 }$. For each misclassified example, update $ bold(w) arrow.l bold(w) + eta thin y_i thin bold(x)_i \, #h(2em) b arrow.l b + eta thin y_i . $ Correct predictions cause no update. Separable data yields convergence; otherwise convergence is not guaranteed. The boundary depends on the training path and supplies no probabilities.

#callout("workedexample", title: [Worked example])[Four points: $\( 2 \, 2 \)$ and $\( 0 \, 2 \)$ are $+ 1$; $\( - 1 \, - 1 \)$ and $\( 1 \, - 1 \)$ are $- 1$. Start with $bold(w) = \( 0 \, 0 \)$, $b = 0$ and $eta = 1$.

/ $\( 2 \, 2 \)$: #block[
The score is 0, which counts as a mistake, so $bold(w) = \( 2 \, 2 \)$ and $b = 1$.
]

/ $\( - 1 \, - 1 \)$: #block[
The score is $- 3$, which is correct, so nothing changes.
]

/ $\( 1 \, - 1 \)$: #block[
The score is $+ 1$, a mistake, so $bold(w) = \( 1 \, 3 \)$ and $b = 0$.
]

/ $\( 0 \, 2 \)$: #block[
The score is $+ 6$, which is correct.
]

A second pass makes no mistakes, so training stops with $bold(w) = \( 1 \, 3 \)$ and $b = 0$.]


#heading(level: 2)[Choosing among linear classifiers]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Model], [Useful strengths], [Important limitations],),
    table.hline(),
    [Logistic regression], [Strong probability baseline, convex training, interpretable odds ratios], [Linear boundary; probabilities can still be miscalibrated under misspecification or shift],
    [LDA], [Very fast, stable on small data, gives class-separating directions], [Assumes Gaussian classes with shared covariance],
    [QDA], [Curved boundaries, per-class covariance], [Many parameters; needs much more data],
    [Perceptron], [Simplest possible trainer; historically important], [No probabilities; unreliable when classes overlap],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Logistic regression fits conditional probabilities; LDA models class distributions; the perceptron updates after mistakes. All use flat boundaries, while QDA's separate covariance matrices allow curves.]

#callout("modelcard", title: [Linear Classifiers - Quick Guide])[#block[
ll Best when & A linear boundary is reasonable, fast prediction matters, or coefficients need to be interpreted. Start with & Logistic regression for probabilities; softmax regression for several classes. Preprocessing & Encode categories, standardize numerical features for regularization, and handle imbalance with suitable metrics or weights. Main controls & Regularization strength, penalty type, and the probability threshold used for decisions. Watch for & Nonlinear class structure, poorly calibrated probabilities, rare classes, and causal over-interpretation (#ref(label("sec:correlation"), supplement: [Section])).

]]

#callout("workedexample", title: [Worked example])[For an "hours studied" coefficient of $0.62$, each extra hour multiplies passing odds by $e^0.62 approx 1.86$, holding other features fixed. The probability increase depends on the starting probability.]

#callout("tryit", title: [Try it yourself])[Fit logistic regression and obtain out-of-fold training probabilities. Sweep thresholds from 0.05 to 0.95 in steps of 0.05; plot precision against recall without using test data.]

#callout("debugtask", title: [Debugging task])[A teammate lowers the probability threshold until test-set recall reaches the desired value, then reports that same test recall as final performance. Explain the leakage in model selection and show where threshold tuning belongs instead.]

#callout("decisionmemo", title: [Decision memo])[For a rare positive class, choose between an unweighted logistic model, class weighting, and a lower decision threshold. State which quantity each intervention changes, which validation metric you would inspect, and why the three options are not interchangeable.]

#callout("chapterrecap", title: [Chapter recap])[- A straight line on 0/1 labels leaves the range of a probability, so logistic regression passes its score through the sigmoid, a dimmer that stops at 0 and 1.

- The score's sign picks the side and its size sets the confidence. A unit of a feature multiplies the odds by $e^beta$.

- Log loss charges minus the log of the probability given to what happened, so confident and wrong is ruinous. Squared error cannot punish it enough.

- There is no formula, so the model walks down by gradient descent. Each row's slope is the prediction minus the truth, weighted by the feature.

- The probability and the threshold are separate. Softmax extends the model to many classes; LDA models each class; the perceptron just corrects its mistakes.]

#callout("quickcheck", title: [Check your understanding])[+ A score is exactly 0. What probability does the sigmoid give, and why?

+ With the fitted model, what chance of passing does a student with 7 lectures get, and which side of a 0.5 threshold is that?

+ A model gives 0.95 to a case that turns out negative. What does it pay in log loss? And for a case that turns out positive?

+ Why is logistic regression called a linear classifier even though it outputs a nonlinear sigmoid probability?

+ Why should the probability model and the operational classification threshold be treated as separate objects?

+ What changes when binary logistic regression is extended to a multiclass softmax model?]
