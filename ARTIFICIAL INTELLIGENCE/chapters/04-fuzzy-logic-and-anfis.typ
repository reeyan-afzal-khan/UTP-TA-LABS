#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-fuzzy-logic-and-anfis")


#heading(level: 1)[Fuzzy Logic and ANFIS]
 <ch:fuzzy>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know Boolean true/false logic and be comfortable with NumPy arrays and a scikit-learn train/test split.

*By the end, you can:* express a graded concept as a membership function; trace the four stages of a fuzzy inference system on one reading; distinguish Mamdani from Sugeno rules; explain what ANFIS learns and how; and evaluate a learned model without leaking test data into its selection.]

Search needs exact facts: a cell is either a wall or it is not. Much of what we know about the world is not like that. Is $29^compose$C hot? Is 55 % humidity uncomfortable? People handle such questions easily, with rules of thumb full of vague words, and this chapter shows how to make those rules run on a computer.

Lab~4 uses one air-quality dataset for two tasks. A hand-written #strong[fuzzy controller] maps temperature and humidity to ventilation demand. An #strong[ANFIS] regressor predicts carbon monoxide from two gas sensors, fitting its rule parameters to about 5,000 measurements. We examine the controller first, then the learner.


#heading(level: 2)[From crisp truth to fuzzy membership]


Classical logic has two answers, true and false. Fuzzy logic allows a #strong[degree of membership] $0 lt.eq mu \( x \) lt.eq 1$. Suppose a ventilation fan follows the rule "if it is hot, run at full speed" and "hot" means above $30^compose$C. At $29.9^compose$C the fan is idle, and at $30.1^compose$C it is at full speed. A change you could not feel on your skin flips the whole system.

#callout("analogy", title: [Analogy])[An ordinary light switch is either off or on. A dimmer sweeps smoothly from dark to full brightness and cannot go past either end. Crisp logic is the switch. Fuzzy logic is the dimmer: "hot" can be 0.47 on, and the fan responds in proportion.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/a0216e77a314759a.cetz.json")], caption: ["Hot" as a crisp set and as a fuzzy set, the second using the set from Lab~4. The crisp version forces a decision at one point. The fuzzy version reports a degree, so $35^compose$C is hot to degree $0.47$.]) <fig:crisp-fuzzy>

#callout("pitfall", title: [Common mistake])[A membership of 0.47 is not a 47 % chance that it is hot. The temperature is known exactly, and nothing about it is uncertain. The word "hot" is what has edges that fade. Fuzzy logic models vague words; probability models unknown facts.]

#callout("intuition", title: [Conceptual intuition])[Fuzzy logic attaches numbers to graded words such as "cold", "humid" and "fast", which makes verbal rules executable. You already adjust a shower this way: nobody solves an equation, you just think "a bit too cold, so a little hotter".]


#heading(level: 2)[Membership functions]


A #strong[membership function] maps a crisp value to a degree. The lab uses triangles, the simplest shape that rises to 1 and falls back to 0, defined by three points $a lt.eq b lt.eq c$: $ mu \( x \) = max #h(-1em) #scale(x: 180%, y: 180%)[\(] 0 \, #h(0em) min #h(-1em) #scale(x: 180%, y: 180%)[\(] frac(x - a, b - a) \, #h(0em) frac(c - x, c - b) #scale(x: 180%, y: 180%)[\)] #scale(x: 180%, y: 180%)[\)] . $ The outer sets are #strong[shoulders]: $a = b$ gives membership~1 below the peak, and $b = c$ gives membership~1 above it, so extreme readings still activate rules. The temperature sets are cold $\( 0 \, 0 \, 18 \)$, mild $\( 12 \, 22 \, 32 \)$ and hot $\( 26 \, 45 \, 45 \)$ (#ref(label("fig:membership"), supplement: [Figure])). They overlap on purpose. At $15^compose$C the reading is partly cold and partly mild at the same time, and that overlap is what makes the output change smoothly.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/383d8c10333d972b.cetz.json")], caption: [Cold and hot are shoulders; mild is triangular. At $15^compose$C, cold membership is $\( 18 - 15 \) \/ 18 = 0.17$ and mild membership is $\( 15 - 12 \) \/ 10 = 0.30$, so rules for both will fire.]) <fig:membership>

The lab implements the triangle in a few lines, with the shoulder cases written out explicitly:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 38, last: 43, lang: "python")

#callout("pitfall", title: [Common mistake])[A `trimf` that assumes $a < b < c$ divides by zero for shoulders or returns incorrect zero memberships. This can disable the "cold" and "dry" rules, leaving only a fallback output. Question~3 of the lab catches this by checking five points with known answers.]


#heading(level: 2)[The four stages of a fuzzy inference system]


A #strong[fuzzy inference system] (FIS) turns crisp inputs into a crisp output by passing through words in between (#ref(label("fig:fis-pipeline"), supplement: [Figure])). The numbers go in, become degrees of "cold" and "comfortable", meet the rules, and come back out as one number for the fan.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/2c9b553bc4aeb4bb.cetz.json")], caption: [Inputs of $15^compose$C and 45 % become membership degrees, activate rules and yield one crisp ventilation demand.]) <fig:fis-pipeline>

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Stage], [What happens, and where it is in the lab code],),
    table.hline(),
    [Fuzzification], [Each crisp input is turned into one degree per set: `degree(T_range, mf, temperature)` for every set.],
    [Rule base], [IF--THEN rules over the set names. AND is `min`; rules with the same conclusion are joined with `max`.],
    [Inference], [Each output set is clipped at its rule's strength; the clipped sets are joined with `np.maximum.reduce`.],
    [Defuzzification], [The centroid of the joined shape: $sum x thin mu \( x \) thin \/ thin sum mu \( x \)$ over the output range.],
  )]
  , kind: table
  )


#heading(level: 3)[The rule base]


The controller has six rules, written so that heat or humidity raises the demand and cool, dry conditions lower it:

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Output], [Fires when],),
    table.hline(),
    [low], [cold AND dry, or cold AND comfortable],
    [medium], [mild AND dry, or mild AND comfortable, or cold AND humid],
    [high], [hot, or humid],
  )]
  , kind: table
  )

In code the three outputs take three lines:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 60, last: 63, lang: "python")

Two small choices make this work. AND takes the `min`, because a chain is only as strong as its weakest link: "cold AND comfortable" cannot be truer than its less true part. Alternatives take the `max`, because a conclusion with several possible reasons is as well supported as its best reason.


#heading(level: 3)[Defuzzification by centroid]


The rules produce a fuzzy output set, but the fan needs a number. At $15^compose$C and 45 %, clip the "low" output set at $0.17$ and the "medium" set at $0.30$, combine them, and report the centroid (#ref(label("fig:defuzz"), supplement: [Figure])). If you cut that shape out of cardboard, the centroid is the point where it would balance on a fingertip. A stronger rule adds weight to its side and pulls the balance point towards it.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/b452663a95406fc8.cetz.json")], caption: [Defuzzifying the $15^compose$C, 45 % reading. Low is clipped at $0.17$ and medium at $0.30$; high does not fire. The centre of area of their union is $40.4 thin %$. A stronger medium rule would pull the centroid to the right.]) <fig:defuzz>

#callout("workedexample", title: [Worked example])[At $15^compose$C and 45 % relative humidity the memberships are cold $0.17$, mild $0.30$, comfortable $\( 45 - 30 \) \/ 20 = 0.75$, and all others~$0$. The rule strengths follow: $ upright("low") = min \( 0.17 \, 0.75 \) = 0.17 \, #h(2em) upright("medium") = min \( 0.30 \, 0.75 \) = 0.30 \, #h(2em) upright("high") = 0 . $ Clipping the low and medium output sets at those strengths and taking the centroid of their union gives a ventilation demand of $40.4 thin %$: a little below "medium", pulled down by the cold rule.]

#callout("tryit", title: [Practice])[Trace $28^compose$C and 45 % by hand before reading on. Which temperature sets are non-zero, which rules fire, and with what strength? Then run `ventilation(28, 45)` in the Lab~4 notebook.

#emph[Answer.] Mild is $\( 32 - 28 \) \/ 10 = 0.40$ and hot is $\( 28 - 26 \) \/ 19 = 0.11$; comfortable is still $0.75$. So low $= 0$, medium $= min \( 0.40 \, 0.75 \) = 0.40$ and high $= 0.11$. The output set now has weight on the high side, and the code returns $55.5 thin %$.]


#heading(level: 2)[Validating a controller]


Check the controller against expectations written down #emph[before] viewing its output. Lab~4 uses two checks:

/ Fixed points.: #block[
Five operating conditions with a qualitative expected answer: $\( 10^compose \, 30 thin % \)$ should be low, $\( 20^compose \, 50 thin % \)$ medium, and $\( 35^compose \, 50 thin % \)$, $\( 25^compose \, 80 thin % \)$ and $\( 40^compose \, 80 thin % \)$ high. The controller returns 18.9, 50.0, 82.3, 83.8 and 84.2 %. Each lands in its band.
]

/ The control surface.: #block[
Plot the output over a temperature--humidity grid. It should rise towards hot, humid conditions without cliffs or unexplained plateaus, which can reveal membership gaps or inactive rules.
]

A surface also exposes gaps in coverage. Every reading must fire at least one rule. If you delete "humid" from the `high` rule, then at $\( 25^compose \, 80 thin % \)$ no rule fires, the output set is empty, and the centroid becomes a division by zero. That happens on 99 of the 1,886 grid points. The full rule base has no such gap.

#callout("keyidea", title: [Key idea])[Check known inputs and the full control surface. One plausible output can hide inactive rules.]


#heading(level: 2)[Mamdani and Sugeno systems]


The controller above is a #strong[Mamdani] system: each rule outputs a fuzzy #emph[set], and those sets are combined and defuzzified. A #strong[Sugeno] rule instead outputs a formula, such as $0.6 thin x_1 + 0.2 thin x_2 + 1.3$, and the final output is the firing-strength-weighted average of those formulas (#ref(label("fig:mamdani-sugeno"), supplement: [Figure])). One way to picture it: each Sugeno rule is a small straight-line model that is valid in its own neighbourhood, and the memberships decide how much each one gets to say at any given input (#ref(label("fig:sugeno-blend"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/d14febfc5500a361.cetz.json")], caption: [Mamdani combines fuzzy output sets and defuzzifies them. Sugeno averages numeric rule outputs by firing strength, enabling ANFIS training.]) <fig:mamdani-sugeno>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/9a516d3d93cf2ce9.cetz.json")], caption: [An illustrative one-input Sugeno system with two rules. Bottom: the two memberships say which rule applies where. Top: the two dashed straight lines are the rule outputs, and the solid curve is their weighted average. It follows one line on the left, the other on the right, and bends smoothly between them. Blending straight lines is how ANFIS fits a curved response.]) <fig:sugeno-blend>

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([], [Mamdani], [Sugeno],),
    table.hline(),
    [Rule conclusion], [A fuzzy set over the output], [A function of the inputs],
    [Output], [Centroid of the joined, clipped sets], [Weighted average of the rule functions],
    [Strength], [Readable: every conclusion is a word], [Trainable: every conclusion is a set of coefficients],
    [Used in Lab~4 by], [The ventilation controller], [ANFIS],
  )]
  , kind: table
  )

The Sugeno form is what makes learning possible. Once the firing strengths are fixed, the output is #emph[linear] in the consequent coefficients $p$, so the best coefficients for a training set can be found by ordinary least squares in one step.


#heading(level: 2)[ANFIS: a fuzzy system that learns]


Writing rules by hand works when an expert knows the numbers. What if nobody knows exactly where "high sensor reading" begins? An #strong[Adaptive Neuro-Fuzzy Inference System] (ANFIS) expresses a Sugeno FIS as a five-layer network with learnable parameters (#ref(label("fig:anfis"), supplement: [Figure])). The inference structure stays the same, and data determine the parameters.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/29338b16e8af3a53.cetz.json")], caption: [ANFIS with two inputs and two memberships each. Layers 1 and 4 contain trainable parameters; layers 2, 3 and 5 perform fixed arithmetic.]) <fig:anfis>

The lab's `SugenoANFIS` class is this diagram in code. With $m$ Gaussian memberships per input and two inputs there are $m^2$ rules, one for every combination of an $A$ set with a $B$ set:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Layer], [Computes], [Parameters],),
    table.hline(),
    [1], [Gaussian membership $mu \( x \) = exp #h(-1em) #scale(x: 120%, y: 120%)[\(] - 1 / 2 #scale(x: 120%, y: 120%)[\(] frac(x - c, sigma) #scale(x: 120%, y: 120%)[\)]^2 #scale(x: 120%, y: 120%)[\)]$ per set], [centres $c$, widths $sigma$: the #emph[premise] parameters],
    [2], [Rule strength $w_r$: the product of one membership per input], [none],
    [3], [Normalised strength $macron(w)_r = w_r \/ sum_k w_k$], [none],
    [4], [Rule output $macron(w)_r thin \( p_(r 0) + p_(r 1) x_1 + p_(r 2) x_2 \)$], [coefficients $p$: the #emph[consequent] parameters],
    [5], [Sum over rules], [none],
  )]
  , kind: table
  )

Layers 1--3 are the method `_weights`, layer~4 is `_design`, and layer~5 is the matrix product in `predict`.


#heading(level: 3)[Hybrid learning]


Most of machine learning follows one recipe: make a guess, score how wrong it is, improve the guess. In the usual words that is a #strong[model], a #strong[loss] and an #strong[optimiser]. ANFIS fills in the recipe like this: the model is the Sugeno system, the loss is the training mean squared error, and the optimiser comes in two parts, because the two parameter groups have very different landscapes.

/ Consequents by least squares.: #block[
With the premises fixed, the loss is shaped like a smooth bowl in $p$, and a bowl has exactly one lowest point. There is no need to walk to the bottom, because a formula jumps straight there. `_solve_outputs` solves that linear system, with a small ridge term for numerical stability.
]

/ Premises by numerical optimisation.: #block[
Centres and widths have no such formula. SciPy's L-BFGS-B walks downhill on training MSE, re-solving the consequents at every evaluation and keeping the widths inside fixed bounds.
]

#callout("analogy", title: [Analogy])[Picture standing on a hillside in thick fog. Your position is the set of centres and widths, your height is the loss, and the fog hides the valley. Your feet can feel which way the ground slopes, though, and that is enough to keep walking downhill. At every step you check your altitude by solving the bowl exactly, which is cheap. Chapter~#ref(label("ch:localsearch"), supplement: none) returns to this picture and to what can go wrong on it.]

Re-solving the consequents leaves only $2 m$ centres and $2 m$ widths to walk over, rather than an additional $3 m^2$ coefficients. With $m = 3$ that is 12 parameters to search and 27 solved exactly.

#callout("keyidea", title: [Key idea])[Use a hand-written fuzzy system when the rules are the knowledge you want to encode and audit. Use ANFIS when data should decide the numbers and the rule structure is only a flexible, interpretable family of functions.]


#heading(level: 2)[Evaluating a learned model honestly]


ANFIS is a regressor, and it is judged like one: by its error on data it never saw. Think of the data as three stacks of exam papers. Training rows are the worked examples. Validation rows are the mock exam, which you may sit as often as you like to choose how to study. Test rows are the final, sealed until the very end. Three rules in the lab protect that arrangement.

/ Split once, before anything else.: #block[
7,344 complete rows are divided 70/15/15 into training, validation and test with a fixed seed, and the assignment is saved to `split.csv`. The test rows are read once, in the final question.
]

/ Fit the scaler on training rows only.: #block[
Use `StandardScaler().fit(X[train])`, then `transform(X)`. Fitting on all rows would leak validation and test statistics into the model.
]

/ Select on validation, report on test.: #block[
Two ANFIS sizes are trained. The one with the lower validation RMSE is chosen, and only its test RMSE is reported, next to the linear baseline's.
]

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Model], [Validation RMSE], [Test RMSE], [Test MAE],),
    table.hline(),
    [Linear regression], [0.510], [0.537], [0.382],
    [ANFIS, 2 sets per input], [0.455], [0.472], [0.326],
    [ANFIS, 3 sets per input (selected)], [0.449], [0.467], [0.325],
  )]
  , kind: table
  )

The selected ANFIS lowers test RMSE by 13 % relative to the linear baseline. The predicted-versus-actual plot shows where the gain comes from: the straight line predicts negative CO at very low concentrations and under-predicts at high ones, whereas the blend of local linear rules stays near the diagonal at both ends. Because L-BFGS-B differs slightly between SciPy versions, your third decimal may not match this table, but the ordering of the models should.

#callout("pitfall", title: [Common mistake])[#strong[Do not select on test RMSE.] Choosing the better of two test results makes the reported score a selected best result, not an unbiased estimate on new data. Seeing the final exam early does not make you better at the subject.]

A random split of hourly readings ignores time order and sensor drift, so it may overstate long-term performance. Note too that the controller encodes a policy while the regressor fits measurements, so a lower RMSE would not make one a substitute for the other.

#callout("chapterrecap", title: [Chapter recap])[- Fuzzy logic replaces true/false with a degree between 0 and 1: a dimmer rather than a switch. It models vague words, not unknown facts.

- A FIS fuzzifies its inputs, applies rules with `min` and `max`, combines the clipped outputs and defuzzifies to one number.

- Mamdani conclusions are readable fuzzy sets. Sugeno conclusions are formulas, which makes them trainable.

- ANFIS learns a Sugeno system by least squares on the consequents and a downhill walk on the memberships.

- Fit everything on training rows, choose on validation rows, and read the test rows once.]

#callout("quickcheck", title: [Check your understanding])[+ A temperature of $28^compose$C: which of the lab's three temperature sets have non-zero membership, and roughly what are the degrees?

+ Why is AND implemented with `min` and the joining of rules with `max`?

+ Which single change turns the Mamdani controller into a Sugeno one, and why does that change make least-squares training possible?

+ ANFIS with three sets per input and two inputs has how many rules, and how many consequent coefficients?

+ The scaler in Lab~4 is fitted on the training rows only. What would be wrong with the reported test RMSE if it had been fitted on all rows?]
