#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-fuzzy-logic-and-anfis")

= Fuzzy Logic and ANFIS <ch:fuzzy>

#chapterguide[Know Boolean true/false logic and be comfortable with NumPy arrays and a scikit-learn train/test split.][express a graded concept as a membership function; trace the four stages of a fuzzy inference system on one reading; distinguish Mamdani from Sugeno rules; explain what ANFIS learns and how; and evaluate a learned model without leaking test data into its selection.]

Search needs exact facts: a cell is either a wall or it is not. Much of what we know about the world is not like that. Is $29^(compose)$C hot? Is 55 % humidity uncomfortable? People handle such questions easily, with rules of thumb full of vague words, and this chapter shows how to make those rules run on a computer.

Lab~4 uses one air-quality dataset for two tasks. A hand-written #term[fuzzy controller] maps temperature and humidity to ventilation demand. An #term[ANFIS] regressor predicts carbon monoxide from two gas sensors, fitting its rule parameters to about 5,000 measurements. We examine the controller first, then the learner.

== From crisp truth to fuzzy membership

Classical logic has two answers, true and false. Fuzzy logic allows a #term[degree of membership] $0 <= mu (x) <= 1$. Suppose a ventilation fan follows the rule “if it is hot, run at full speed” and “hot” means above $30^(compose)$C. At $29.9^(compose)$C the fan is idle, and at $30.1^(compose)$C it is at full speed. A change you could not feel on your skin flips the whole system.

An ordinary light switch is either off or on. A dimmer sweeps smoothly from dark to full brightness and cannot go past either end. Crisp logic is the switch. Fuzzy logic is the dimmer: “hot” can be 0.47 on, and the fan responds in proportion.

#utpfig([“Hot” as a crisp set and as a fuzzy set, the second using the set from Lab~4. The crisp version forces a decision at one point. The fuzzy version reports a degree, so $35^(compose)$C is hot to degree $0.47$.], label: <fig:crisp-fuzzy>)[
  #canvas({
    axis(name: "crisp", width: 6.6cm, height: 4.2cm, xlabel: [temperature ($""^(compose)$C)], ylabel: [$mu (x)$], title: [Crisp set: “hot”], xmin: 0, xmax: 50, ymin: -0.08, ymax: 1.18, ytick: (0, 0.5, 1), xtick: (0, 10, 20, 30, 40, 50), axis-lines: "left", grid: "major", grid-style: (draw: pale-blue),
      addplot(draw: red, line-width: widths.thick, coords: ((0, 0), (30, 0))),
      addplot(draw: red, line-width: widths.thick, coords: ((30, 1), (50, 1))),
      addplot(draw: red, dash: "dashed", line-width: widths.thin, coords: ((30, 0), (30, 1))),
      addplot(only-marks: true, mark: "*", draw: red, mark-size: 1.3948pt, coords: ((30, 1),)),
      addplot(only-marks: true, mark: "o", draw: red, mark-size: 1.3948pt, coords: ((30, 0),)),
    )
    axis(anchor: "left-of-south-west", width: 6.6cm, height: 4.2cm, xlabel: [temperature ($""^(compose)$C)], ylabel: [$mu (x)$], title: [Fuzzy set: “hot”], xmin: 0, xmax: 50, ymin: -0.08, ymax: 1.18, ytick: (0, 0.5, 1), xtick: (0, 10, 20, 26, 35, 45), axis-lines: "left", grid: "major", grid-style: (draw: pale-blue), at: (rel: (1.15, 0), to: "crisp.right-of-south-east"),
      addplot(draw: green, line-width: widths.thick, coords: ((0, 0), (26, 0), (45, 1), (50, 1))),
      addplot(draw: orange, dash: "dashed", line-width: widths.thin, coords: ((35, 0), (35, 0.47))),
      addplot(draw: orange, dash: "dashed", line-width: widths.thin, coords: ((0, 0.47), (35, 0.47))),
      addplot(only-marks: true, mark: "*", draw: orange, mark-size: 1.594pt, coords: ((35, 0.47),)),
      {
        node((36, 0.36), [$mu (35)=0.47$], font: font("script", fill: orange), anchor: "west")
      },
    )
  })
]

#warning[
  A membership of 0.47 is not a 47 % chance that it is hot. The temperature is known exactly, and nothing about it is uncertain. The word “hot” is what has edges that fade. Fuzzy logic models vague words; probability models unknown facts.
]

#note[
  Fuzzy logic attaches numbers to graded words such as “cold”, “humid” and “fast”, which makes verbal rules executable. You already adjust a shower this way: nobody solves an equation, you just think “a bit too cold, so a little hotter”.
]

== Membership functions

A #term[membership function] maps a crisp value to a degree. The lab uses triangles, the simplest shape that rises to 1 and falls back to 0, defined by three points $a <= b <= c$:

$ mu (x)=max(0, med min(frac(x-a, b-a), med frac(c-x, c-b))). $

The outer sets are #term[shoulders]: $a=b$ gives membership~1 below the peak, and $b=c$ gives membership~1 above it, so extreme readings still activate rules. The temperature sets are cold $(0,0,18)$, mild $(12,22,32)$ and hot $(26,45,45)$ (#figref(<fig:membership>)). They overlap on purpose. At $15^(compose)$C the reading is partly cold and partly mild at the same time, and that overlap is what makes the output change smoothly.

#utpfig([Cold and hot are shoulders; mild is triangular. At $15^(compose)$C, cold membership is $(18-15)\/18=0.17$ and mild membership is $(15-12)\/10=0.30$, so rules for both will fire.], label: <fig:membership>)[
  #canvas({
    axis(width: 14.1328cm, height: 5.6cm, xmin: 0, xmax: 45, ymin: 0, ymax: 1.08, xlabel: [Temperature ($""^(compose)$C)], ylabel: [Membership], xtick: (0, 12, 15, 18, 22, 26, 32, 45), ytick: (0, 0.17, 0.3, 0.5, 1), yticklabels: ([0], [0.17], [0.30], [0.5], [1]), legend-columns: 3, legend-style: (at: (0.5, -0.26), anchor: "north"), clip: false,
      addplot(draw: blue, line-width: widths.very-thick, coords: ((0, 1), (18, 0), (45, 0)), legend: [cold $(0,0,18)$]),
      addplot(draw: teal, line-width: widths.very-thick, coords: ((0, 0), (12, 0), (22, 1), (32, 0), (45, 0)), legend: [mild $(12,22,32)$]),
      addplot(draw: orange, line-width: widths.very-thick, coords: ((0, 0), (26, 0), (45, 1)), legend: [hot $(26,45,45)$]),
      addplot(draw: red, dash: "dashed", line-width: widths.thick, coords: ((15, 0), (15, 1.02))),
      addplot(only-marks: true, mark: "*", mark-size: 2.1918pt, draw: blue, coords: ((15, 0.167),)),
      addplot(only-marks: true, mark: "*", mark-size: 2.1918pt, draw: teal, coords: ((15, 0.3),)),
      {
        node((15.6, 0.12), [$mu _("cold")(15)=0.17$], font: font("script", fill: blue), anchor: "west")
        node((15.6, 0.36), [$mu _("mild")(15)=0.30$], font: font("script", fill: teal), anchor: "west")
      },
    )
  })
]

The lab implements the triangle in a few lines, with the shoulder cases written out explicitly:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 38, last: 43, lang: "python")

#warning[
  A `trimf` that assumes $a<b<c$ divides by zero for shoulders or returns incorrect zero memberships. This can disable the “cold” and “dry” rules, leaving only a fallback output. Question~3 of the lab catches this by checking five points with known answers.
]

== The four stages of a fuzzy inference system

A #term[fuzzy inference system] (FIS) turns crisp inputs into a crisp output by passing through words in between (#figref(<fig:fis-pipeline>)). The numbers go in, become degrees of “cold” and “comfortable”, meet the rules, and come back out as one number for the fan.

#utpfig([Inputs of $15^(compose)$C and 45 % become membership degrees, activate rules and yield one crisp ventilation demand.], label: <fig:fis-pipeline>)[
  #canvas({
    node((0, 0), [crisp in \
  #strong[$15^(compose)$C, 45 %]], name: "in", ..utpbox, min-width: 1.65, min-height: 0.9, fill: pale-gray, draw: muted, font: font("script", fill: navy))
    node((2.5, 0), [#strong[Fuzzification] \
  $arrow.r$ degrees], name: "fz", ..utpbox, min-width: 2.25, min-height: 0.9, font: font("script", fill: navy))
    node((5.2, 0), [#strong[Rule base] \
  IF--THEN], name: "rb", ..utpbox, min-width: 2.25, min-height: 0.9, font: font("script", fill: navy))
    node((7.9, 0), [#strong[Inference] \
  combine rules], name: "ie", ..utpbox, min-width: 2.25, min-height: 0.9, font: font("script", fill: navy))
    node((10.6, 0), [#strong[Defuzzification] \
  $arrow.r$ one number], name: "df", ..utpbox, min-width: 2.25, min-height: 0.9, font: font("script", fill: navy))
    node((13, 0), [crisp out \
  #strong[40.4 %]], name: "out", ..utpbox, min-width: 1.55, min-height: 0.9, fill: pale-teal, draw: green, font: font("script", fill: navy))
    for (a, b) in (("in", "fz"), ("fz", "rb"), ("rb", "ie"), ("ie", "df"), ("df", "out")) {
      connect(a, b, ..utparrow)
    }
    node((2.5, -0.6), [cold $0.17$, mild $0.30$ \
  comfortable $0.75$], font: font("small"), ..utplabel, anchor: "north", align: center, text: orange)
    node((5.2, -0.6), [low fires $0.17$ \
  medium fires $0.30$], font: font("small"), ..utplabel, anchor: "north", align: center, text: orange)
    node((7.9, -0.6), [clipped sets \
  joined by max], font: font("small"), ..utplabel, anchor: "north", align: center, text: orange)
    node((10.6, -0.6), [centroid of \
  that shape], font: font("small"), ..utplabel, anchor: "north", align: center, text: orange)
    connect((1.4, 0.68), (11.8, 0.68), ..utpbrace)
    node((6.6, 1), [everything inside this brace is fuzzy; the two ends are not], font: font("small"), ..utplabel, anchor: "south", text: navy)
  })
]

#utptable[
  #tabularx(
    columns: (20%, 1fr),
    styles: (navy-bold,),
    header: ([Stage], [What happens, and where it is in the lab code]),
    [Fuzzification], [Each crisp input is turned into one degree per set: `degree(T_range, mf, temperature)` for every set.],
    [Rule base], [IF--THEN rules over the set names. AND is `min`; rules with the same conclusion are joined with `max`.],
    [Inference], [Each output set is clipped at its rule’s strength; the clipped sets are joined with `np.maximum.reduce`.],
    [Defuzzification], [The centroid of the joined shape: $sum x thin mu (x) thin \/ thin sum mu (x)$ over the output range.],
  )
]

=== The rule base

The controller has six rules, written so that heat or humidity raises the demand and cool, dry conditions lower it:

#utptable[
  #tabularx(
    columns: (12%, 1fr),
    styles: (navy-bold,),
    header: ([Output], [Fires when]),
    [low], [cold AND dry, #h(1em)or #h(1em)cold AND comfortable],
    [medium], [mild AND dry, #h(1em)or #h(1em)mild AND comfortable, #h(1em)or #h(1em)cold AND humid],
    [high], [hot, #h(1em)or #h(1em)humid],
  )
]

In code the three outputs take three lines:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.py", first: 60, last: 63, lang: "python")

Two small choices make this work. AND takes the `min`, because a chain is only as strong as its weakest link: “cold AND comfortable” cannot be truer than its less true part. Alternatives take the `max`, because a conclusion with several possible reasons is as well supported as its best reason.

=== Defuzzification by centroid

The rules produce a fuzzy output set, but the fan needs a number. At $15^(compose)$C and 45 %, clip the “low” output set at $0.17$ and the “medium” set at $0.30$, combine them, and report the centroid (#figref(<fig:defuzz>)). If you cut that shape out of cardboard, the centroid is the point where it would balance on a fingertip. A stronger rule adds weight to its side and pulls the balance point towards it.

#utpfig([Defuzzifying the $15^(compose)$C, 45 % reading. Low is clipped at $0.17$ and medium at $0.30$; high does not fire. The centre of area of their union is $40.4 thin %$. A stronger medium rule would pull the centroid to the right.], label: <fig:defuzz>)[
  #canvas({
    axis(width: 13.1692cm, height: 5.4cm, xmin: 0, xmax: 100, ymin: 0, ymax: 1.12, xlabel: [Ventilation demand (%)], ylabel: [Membership], xtick: (0, 25, 40.4, 50, 75, 100), xticklabels: ([0], [25], [40.4], [50], [75], [100]), ytick: (0, 0.17, 0.3, 0.6, 1), yticklabels: ([0], [0.17], [0.30], [0.6], [1]), axis-lines: "left", grid: "major", grid-style: (draw: pale-blue), clip: false,
      addplot(draw: mix(muted, 45%), line-width: widths.thin, coords: ((0, 1), (45, 0))),
      addplot(draw: mix(muted, 45%), line-width: widths.thin, coords: ((25, 0), (50, 1), (75, 0))),
      addplot(draw: mix(muted, 45%), line-width: widths.thin, coords: ((55, 0), (100, 1))),
      addplot(draw: teal, line-width: widths.very-thick, fill: pale-teal, fill-opacity: 75%, coords: ((0, 0), (0, 0.167), (29.2, 0.167), (32.5, 0.3), (67.5, 0.3), (75, 0), (0, 0))),
      addplot(draw: red, dash: "dashed", line-width: widths.thick, coords: ((40.4, 0), (40.4, 0.62))),
      addplot(only-marks: true, mark: "*", mark-size: 2.391pt, draw: red, coords: ((40.4, 0.3),)),
      {
        node((40.4, 0.65), [centroid $=40.4$], font: font("script", fill: red), anchor: "south")
        node((2, 0.25), [low clipped at $0.17$], font: font("script", fill: blue), anchor: "west")
        node((44, 0.38), [medium clipped at $0.30$], font: font("script", fill: teal), anchor: "west")
        node((78, 0.5), [high: not fired], font: font("script", fill: muted), anchor: "west")
      },
    )
  })
]

#example[
  At $15^(compose)$C and 45 % relative humidity the memberships are cold $0.17$, mild $0.30$, comfortable $(45-30)\/20=0.75$, and all others~$0$. The rule strengths follow:

  $ "low"=min(0.17,0.75)=0.17, wide "medium"=min(0.30,0.75)=0.30, wide "high"=0. $

  Clipping the low and medium output sets at those strengths and taking the centroid of their union gives a ventilation demand of $40.4 thin %$: a little below “medium”, pulled down by the cold rule.
]

#exercises[
  Trace $28^(compose)$C and 45 % by hand before reading on. Which temperature sets are non-zero, which rules fire, and with what strength? Then run `ventilation(28, 45)` in the Lab~4 notebook.

  #emph[Answer.] Mild is $(32-28)\/10=0.40$ and hot is $(28-26)\/19=0.11$; comfortable is still $0.75$. So low $=0$, medium $=min(0.40,0.75)=0.40$ and high $=0.11$. The output set now has weight on the high side, and the code returns $55.5 thin %$.
]

== Validating a controller

Check the controller against expectations written down #emph[before] viewing its output. Lab~4 uses two checks:

/ Fixed points.: Five operating conditions with a qualitative expected answer: $(10^(compose), 30 thin % )$ should be low, $(20^(compose), 50 thin % )$ medium, and $(35^(compose), 50 thin % )$, $(25^(compose), 80 thin % )$ and $(40^(compose), 80 thin % )$ high. The controller returns 18.9, 50.0, 82.3, 83.8 and 84.2 %. Each lands in its band.
/ The control surface.: Plot the output over a temperature--humidity grid. It should rise towards hot, humid conditions without cliffs or unexplained plateaus, which can reveal membership gaps or inactive rules.

A surface also exposes gaps in coverage. Every reading must fire at least one rule. If you delete “humid” from the `high` rule, then at $(25^(compose), 80 thin % )$ no rule fires, the output set is empty, and the centroid becomes a division by zero. That happens on 99 of the 1,886 grid points. The full rule base has no such gap.

#note[
  Check known inputs and the full control surface. One plausible output can hide inactive rules.
]

== Mamdani and Sugeno systems

The controller above is a #term[Mamdani] system: each rule outputs a fuzzy #emph[set], and those sets are combined and defuzzified. A #term[Sugeno] rule instead outputs a formula, such as $0.6 thin x_1+0.2 thin x_2+1.3$, and the final output is the firing-strength-weighted average of those formulas (#figref(<fig:mamdani-sugeno>)). One way to picture it: each Sugeno rule is a small straight-line model that is valid in its own neighbourhood, and the memberships decide how much each one gets to say at any given input (#figref(<fig:sugeno-blend>)).

#utpfig([Mamdani combines fuzzy output sets and defuzzifies them. Sugeno averages numeric rule outputs by firing strength, enabling ANFIS training.], label: <fig:mamdani-sugeno>)[
  #canvas({
    draw.scope({
      node((2.5, 2.2), [Mamdani], font: font("normal", weight: "bold", fill: navy))
      node((2.5, 1.5), [IF sensor is High THEN CO is #strong[High]], name: "r1", ..utpbox, min-width: 4.6, font: font("script", fill: navy))
      node((2.5, 1.05), [#strong[High] is a fuzzy set], font: font("small"), ..utplabel, anchor: "north", text: orange)
      draw.scope({
        draw.translate((1.35, 0))
        draw.translate((0, -0.55))
        connect((-0.2, 0), (4, 0), draw: mix(muted, 60%), end: arrow-tip("Stealth", length: 1.6mm, line: 0.4pt))
        connect((0, -0.2), (0, 1.35), draw: mix(muted, 60%), end: arrow-tip("Stealth", length: 1.6mm, line: 0.4pt))
        connect((0.4, 0), (1.8, 1.1), (3.2, 0), line-width: widths.very-thick, draw: orange)
        connect((0.4, 0), (1.8, 1.1), (3.2, 0), (0.4, 0), opacity: 20%, fill: orange, draw: none)
      })
      node((2.5, -1.35), [needs joining, then a centroid], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((7.6, 0))
      node((2.5, 2.2), [Sugeno], font: font("normal", weight: "bold", fill: navy))
      node((2.5, 1.5), [IF sensor is High THEN CO $=p_0+p_1 x_1+p_2 x_2$], name: "r2", ..utpbox, min-width: 5.1, font: font("script", fill: navy), fill: pale-teal, draw: green)
      node((2.5, 1.05), [the consequent is a formula], font: font("small"), ..utplabel, anchor: "north", text: green)
      node((2.5, 0.15), [output $= sum _r macron(w)_r thin f_r(x)$], ..utpcell, min-width: 3.2, min-height: 0.65, fill: pale-teal, draw: green, font: font("script", weight: "bold"))
      node((2.5, -1.35), [weighted average, no centroid], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

#utpfig([An illustrative one-input Sugeno system with two rules. Bottom: the two memberships say which rule applies where. Top: the two dashed straight lines are the rule outputs, and the solid curve is their weighted average. It follows one line on the left, the other on the right, and bends smoothly between them. Blending straight lines is how ANFIS fits a curved response.], label: <fig:sugeno-blend>)[
  #canvas({
    let mone(x) = calc.exp(-0.5 * calc.pow((x + 1), 2))
    let mtwo(x) = calc.exp(-0.5 * calc.pow((x - 1), 2))
    let wone(x) = mone(x) / (mone(x) + mtwo(x))
    let fone(x) = 0.5 + 0.15 * x
    let ftwo(x) = -0.6 + 1.2 * x
    let blend(x) = wone(x) * fone(x) + (1 - wone(x)) * ftwo(x)
    axis(name: "top", width: 11.242cm, height: 4.5cm, xmin: -3, xmax: 3, ymin: -1.2, ymax: 3.2, xticklabels: (), ylabel: [output], axis-lines: "left", grid: "major", grid-style: (draw: pale-blue), domain: (-3, 3), samples: 61,
      addplot(draw: blue, dash: "dashed", line-width: widths.thick, x => fone(x)),
      addplot(draw: orange, dash: "dashed", line-width: widths.thick, x => ftwo(x)),
      addplot(draw: green, line-width: widths.very-thick, x => blend(x)),
      {
        node((-2.9, 0.15), [rule 1 output], font: font("script", fill: blue), anchor: "south-west")
        node((0.15, -0.8), [rule 2 output], font: font("script", fill: mix(orange, 85%, other: black)), anchor: "west")
        node((2.2, 1.95), [blended output], font: font("script", weight: "bold", fill: green), anchor: "south-east")
      },
    )
    axis(anchor: "north-west", width: 11.242cm, height: 2.9cm, xmin: -3, xmax: 3, ymin: 0, ymax: 1.15, xlabel: [input $x$], ylabel: [membership], ytick: (0, 1), axis-lines: "left", grid: "major", grid-style: (draw: pale-blue), domain: (-3, 3), samples: 61, at: (rel: (0, -0.25), to: "top.south-west"),
      addplot(draw: blue, line-width: widths.thick, x => mone(x)),
      addplot(draw: orange, line-width: widths.thick, x => mtwo(x)),
    )
  })
]

#utptable[
  #tabularx(
    columns: (15%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([], [Mamdani], [Sugeno]),
    [Rule conclusion], [A fuzzy set over the output], [A function of the inputs],
    [Output], [Centroid of the joined, clipped sets], [Weighted average of the rule functions],
    [Strength], [Readable: every conclusion is a word], [Trainable: every conclusion is a set of coefficients],
    [Used in Lab~4 by], [The ventilation controller], [ANFIS],
  )
]

The Sugeno form is what makes learning possible. Once the firing strengths are fixed, the output is #emph[linear] in the consequent coefficients $p$, so the best coefficients for a training set can be found by ordinary least squares in one step.

== ANFIS: a fuzzy system that learns

Writing rules by hand works when an expert knows the numbers. What if nobody knows exactly where “high sensor reading” begins? An #term[Adaptive Neuro-Fuzzy Inference System] (ANFIS) expresses a Sugeno FIS as a five-layer network with learnable parameters (#figref(<fig:anfis>)). The inference structure stays the same, and data determine the parameters.

#utpfig([ANFIS with two inputs and two memberships each. Layers 1 and 4 contain trainable parameters; layers 2, 3 and 5 perform fixed arithmetic.], label: <fig:anfis>)[
  #canvas({
    let L = (shape: "circle", draw: blue, fill: pale-blue, min-size: 0.75, font: font("script", fill: navy), inner-sep: 0.4981pt)
    let T = (shape: "circle", draw: orange, fill: pale-orange, min-size: 0.75, line-width: 0.8966pt, font: font("script", fill: navy), inner-sep: 0.4981pt)
    let dx = 2.45
    node((-dx, 0.75), [$x_1$], name: "x", ..utplabel, font: font("small", weight: "bold", fill: navy))
    node((-dx, -0.75), [$x_2$], name: "y", ..utplabel, font: font("small", weight: "bold", fill: navy))
    node((0, 1.35), [$A_1$], name: "A1", font: font("small"), ..T)
    node((0, 0.45), [$A_2$], name: "A2", font: font("small"), ..T)
    node((0, -0.45), [$B_1$], name: "B1", font: font("small"), ..T)
    node((0, -1.35), [$B_2$], name: "B2", font: font("small"), ..T)
    node((dx, 0.9), [$Pi$], name: "P1", font: font("small"), ..L)
    node((dx, -0.9), [$Pi$], name: "P2", font: font("small"), ..L)
    node((2 * dx, 0.9), [$N$], name: "N1", font: font("small"), ..L)
    node((2 * dx, -0.9), [$N$], name: "N2", font: font("small"), ..L)
    node((3 * dx, 0.9), [$f_1$], name: "C1", font: font("small"), ..T)
    node((3 * dx, -0.9), [$f_2$], name: "C2", font: font("small"), ..T)
    node((4 * dx, 0), [$Sigma$], name: "S", font: font("small"), ..L)
    node((4 * dx + 1.15, 0), [output], name: "out", ..utplabel, font: font("small", weight: "bold", fill: navy))
    for t in ("A1", "A2") {
      connect("x", t, ..utpptr)
    }
    for t in ("B1", "B2") {
      connect("y", t, ..utpptr)
    }
    connect("A1", "P1", ..utpptr)
    connect("B1", "P1", ..utpptr)
    connect("A2", "P2", ..utpptr)
    connect("B2", "P2", ..utpptr)
    connect("P1", "N1", ..utpptr)
    connect("P2", "N2", ..utpptr)
    connect("P1", "N2", ..utpptr)
    connect("P2", "N1", ..utpptr)
    connect("N1", "C1", ..utpptr)
    connect("N2", "C2", ..utpptr)
    connect("C1", "S", ..utpptr)
    connect("C2", "S", ..utpptr)
    connect("S", "out", ..utpptr)
    for (i, lbl) in ((0, [1\. fuzzify]), (1, [2\. rule \
  strength]), (2, [3\. normalise]), (3, [4\. rule \
  output]), (4, [5\. aggregate])) {
      node((i * dx, -1.95), [#lbl], font: font("small"), ..utplabel, anchor: "north", align: center)
    }
    node((-dx - 0.55, -3.15), [shaded nodes hold the parameters ANFIS trains; the rest is fixed arithmetic], font: font("small"), ..utplabel, anchor: "west", text: orange)
  })
]

The lab’s `SugenoANFIS` class is this diagram in code. With $m$ Gaussian memberships per input and two inputs there are $m^2$ rules, one for every combination of an $A$ set with a $B$ set:

#utptable[
  #tabularx(
    columns: (13%, 36%, 1fr),
    styles: (navy-bold,),
    header: ([Layer], [Computes], [Parameters]),
    [1], [Gaussian membership $mu (x)=exp(-inline(frac(1, 2))(inline(frac(x-c, sigma)))^2)$ per set], [centres $c$, widths $sigma$: the #emph[premise] parameters],
    [2], [Rule strength $w_r$: the product of one membership per input], [none],
    [3], [Normalised strength $macron(w)_r=w_r\/ sum _k w_k$], [none],
    [4], [Rule output $macron(w)_r thin (p_(r 0)+p_(r 1)x_1+p_(r 2)x_2)$], [coefficients $p$: the #emph[consequent] parameters],
    [5], [Sum over rules], [none],
  )
]

Layers 1--3 are the method `_weights`, layer~4 is `_design`, and layer~5 is the matrix product in `predict`.

=== Hybrid learning

Most of machine learning follows one recipe: make a guess, score how wrong it is, improve the guess. In the usual words that is a #term[model], a #term[loss] and an #term[optimiser]. ANFIS fills in the recipe like this: the model is the Sugeno system, the loss is the training mean squared error, and the optimiser comes in two parts, because the two parameter groups have very different landscapes.

/ Consequents by least squares.: With the premises fixed, the loss is shaped like a smooth bowl in $p$, and a bowl has exactly one lowest point. There is no need to walk to the bottom, because a formula jumps straight there. `_solve_outputs` solves that linear system, with a small ridge term for numerical stability.
/ Premises by numerical optimisation.: Centres and widths have no such formula. SciPy’s L-BFGS-B walks downhill on training MSE, re-solving the consequents at every evaluation and keeping the widths inside fixed bounds.

Picture standing on a hillside in thick fog. Your position is the set of centres and widths, your height is the loss, and the fog hides the valley. Your feet can feel which way the ground slopes, though, and that is enough to keep walking downhill. At every step you check your altitude by solving the bowl exactly, which is cheap. Chapter~@ch:localsearch returns to this picture and to what can go wrong on it.

Re-solving the consequents leaves only $2 m$ centres and $2 m$ widths to walk over, rather than an additional $3 m^2$ coefficients. With $m=3$ that is 12 parameters to search and 27 solved exactly.

#note[
  Use a hand-written fuzzy system when the rules are the knowledge you want to encode and audit. Use ANFIS when data should decide the numbers and the rule structure is only a flexible, interpretable family of functions.
]

== Evaluating a learned model honestly

ANFIS is a regressor, and it is judged like one: by its error on data it never saw. Think of the data as three stacks of exam papers. Training rows are the worked examples. Validation rows are the mock exam, which you may sit as often as you like to choose how to study. Test rows are the final, sealed until the very end. Three rules in the lab protect that arrangement.

/ Split once, before anything else.: 7,344 complete rows are divided 70/15/15 into training, validation and test with a fixed seed, and the assignment is saved to `split.csv`. The test rows are read once, in the final question.
/ Fit the scaler on training rows only.: Use `StandardScaler().fit(X[train])`, then `transform(X)`. Fitting on all rows would leak validation and test statistics into the model.
/ Select on validation, report on test.: Two ANFIS sizes are trained. The one with the lower validation RMSE is chosen, and only its test RMSE is reported, next to the linear baseline’s.

#utptable[
  #tabularx(
    columns: (26%, 1fr, 1fr, 1fr),
    align: (left, center, center, center),
    styles: (navy-bold,),
    header: ([Model], [Validation RMSE], [Test RMSE], [Test MAE]),
    [Linear regression], [0.510], [0.537], [0.382],
    [ANFIS, 2 sets per input], [0.455], [0.472], [0.326],
    [ANFIS, 3 sets per input (selected)], [0.449], [0.467], [0.325],
  )
]

The selected ANFIS lowers test RMSE by 13 % relative to the linear baseline. The predicted-versus-actual plot shows where the gain comes from: the straight line predicts negative CO at very low concentrations and under-predicts at high ones, whereas the blend of local linear rules stays near the diagonal at both ends. Because L-BFGS-B differs slightly between SciPy versions, your third decimal may not match this table, but the ordering of the models should.

#warning[
  #strong[Do not select on test RMSE.] Choosing the better of two test results makes the reported score a selected best result, not an unbiased estimate on new data. Seeing the final exam early does not make you better at the subject.
]

A random split of hourly readings ignores time order and sensor drift, so it may overstate long-term performance. Note too that the controller encodes a policy while the regressor fits measurements, so a lower RMSE would not make one a substitute for the other.

#summary[
  - Fuzzy logic replaces true/false with a degree between 0 and 1: a dimmer rather than a switch. It models vague words, not unknown facts.
  - A FIS fuzzifies its inputs, applies rules with `min` and `max`, combines the clipped outputs and defuzzifies to one number.
  - Mamdani conclusions are readable fuzzy sets. Sugeno conclusions are formulas, which makes them trainable.
  - ANFIS learns a Sugeno system by least squares on the consequents and a downhill walk on the memberships.
  - Fit everything on training rows, choose on validation rows, and read the test rows once.
]

#questions[
  + A temperature of $28^(compose)$C: which of the lab’s three temperature sets have non-zero membership, and roughly what are the degrees?
  + Why is AND implemented with `min` and the joining of rules with `max`?
  + Which single change turns the Mamdani controller into a Sugeno one, and why does that change make least-squares training possible?
  + ANFIS with three sets per input and two inputs has how many rules, and how many consequent coefficients?
  + The scaler in Lab~4 is fitted on the training rows only. What would be wrong with the reported test RMSE if it had been fitted on all rows?
]
