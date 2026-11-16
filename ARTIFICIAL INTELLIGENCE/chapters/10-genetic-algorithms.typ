#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-genetic-algorithms")

= Genetic Algorithms <ch:ga>

#chapterguide[Know local search from #chapref(<ch:localsearch>), be comfortable with NumPy arrays and random numbers, and know what a regression model and its RMSE are.][name the parts of a genetic algorithm and what each contributes; encode a real-valued problem as a chromosome; implement tournament selection, blend crossover, Gaussian mutation and elitism; evaluate a stochastic optimiser over repeated seeds; and decide when an evolutionary method is justified against an exact one.]

Every search in #chapref(<ch:localsearch>) changes one candidate at a time: one queen on one board, one word added to one sentence. Each option only ever grows by itself. But two half-good solutions often have complementary strengths. What if they could combine?

Nature does this all the time, with two parents and a child that gets a bit of each. A #term[genetic algorithm] (GA) applies the same idea to candidate solutions. It improves a whole population through selection, recombination and random mutation, and it needs only a scoring function, not derivatives or convexity. Lab~8 tests a GA on a known one-dimensional function, then fits linear-regression coefficients. Ordinary least squares provides an exact, faster reference, so the aim is to evaluate a stochastic optimiser, not to claim it beats an exact method.

== Breeding boards: the idea on eight queens

Start with the puzzle from #chapref(<ch:localsearch>). A GA keeps a population of boards, say 50 random ones, and writes each board as eight digits, one per column, each saying which row that column’s queen is in. Each board gets a #term[fitness]: the fewer attacking pairs, the fitter it is.

Think of a raffle for the right to breed. Eight queens make 28 pairs, and a board gets one ticket for every pair that does #emph[not] attack. A board with 3 attacking pairs holds 25 tickets, and one with 10 holds 18. Draw two tickets to choose two parents. Fitter boards are likelier to be drawn, but even a poor board has a chance, which keeps variety in the population.

Two more steps make a child. In #term[crossover] we cut both parents at a random column and join the pieces. In #term[mutation], now and then, one queen in the child jumps to a random row, which can create a row neither parent had (#figref(<fig:breeding>)).

#utpfig([A lucky pairing, chosen to show both operators. Each digit gives the row of one column’s queen. Crossover cuts both parents after the same column and joins the left of one to the right of the other, and the child has only one attacking pair. Mutation then changes one digit to a row neither parent had in that column, and this board is solved.], label: <fig:breeding>)[
  #canvas({
    let ga = (..cell, min-width: 0.58, min-height: 0.6, font: font("small", weight: "bold", fill: navy))
    let gb = (..cellalt, min-width: 0.58, min-height: 0.6, font: font("small", weight: "bold", fill: navy))
    let gm = (..cellbad, min-width: 0.58, min-height: 0.6, font: font("small", weight: "bold", fill: red))
    let s = 0.6
    node((-0.3, 1.42), [parent 1: 5 attacking pairs], font: font("small"), ..tagb, anchor: "south-west")
    node((-0.3, -0.22), [parent 2: 6 attacking pairs], font: font("small"), ..tagb, anchor: "north-west")
    for (i, d) in (1, 4, 6, 3, 1, 6, 2, 5).enumerate() {
      node((s * i, 1.1), [#d], font: font("small"), ..ga)
    }
    for (i, d) in (1, 4, 2, 2, 0, 7, 4, 2).enumerate() {
      node((s * i, 0.1), [#d], font: font("small"), ..gb)
    }
    connect((s * 3 + s / 2, 1.42), (s * 3 + s / 2, -0.22), draw: red, dash: "dashed", line-width: widths.thick)
    node((s * 3 + s / 2 + 0.05, 0.6), [cut], font: font("small"), ..utplabel, anchor: "west", text: red)
    connect((4.7, 0.6), (6, 0.6), ..utparrow)
    node(along((4.7, 0.6), (6, 0.6), t: 50%), [crossover], font: font("small"), ..utplabel, anchor: "south")
    draw.scope({
      draw.translate((6.45, 0))
      node((s * 3.5, 0.92), [child: 1 attacking pair], font: font("small"), ..tagb, anchor: "south")
      for (i, d) in (1, 4, 6, 3).enumerate() {
        node((s * i, 0.6), [#d], font: font("small"), ..ga)
      }
      for (i, d) in (0, 7, 4, 2).enumerate(start: 4) {
        node((s * i, 0.6), [#d], font: font("small"), ..gb)
      }
    })
    draw.scope({
      draw.translate((6.45, 0))
      draw.translate((0, -0.75))
      for (i, d) in (1, 4, 6, 3).enumerate() {
        node((s * i, 0), [#d], font: font("small"), ..ga)
      }
      for (i, d) in (0, 7).enumerate(start: 4) {
        node((s * i, 0), [#d], font: font("small"), ..gb)
      }
      node((s * 6, 0), [5], font: font("small"), ..gm)
      node((s * 7, 0), [2], font: font("small"), ..gb)
      node((s * 3.5, -0.34), [after mutation: no attacks, solved], font: font("small"), ..tagb, anchor: "north")
      connect((s * 6, 0.98), (s * 6, 0.34), ..utpptr, draw: red)
      node((s * 7 + 0.42, 0.68), [mutate $4 arrow.r 5$], font: font("small"), ..utplabel, anchor: "west", text: red)
    })
  })
]

Repeat this to fill a new generation and let the children replace the population. Good pieces from two parents can then meet in one child, in a single step that a hill climber could not take. Here is that loop in Python, as the demo runs it:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/demo_local_search.py", first: 79, last: 98, lang: "python")

Now the honest part. How well does it work on eight queens? In the demo, 171 of 200 runs find a solution within 1,000 generations, with a median of 328 generations among those that succeed. The work comes to about 27,000 boards per puzzle solved. Simulated annealing needed about 1,100.

#note[
  Breeding boards sounds like the coolest idea in this book, and on eight queens the dumbest-sounding idea, annealing, does the job with less than a tenth of the work. When an idea sounds exciting, race it against a simple one first.
]

GAs still earn their keep elsewhere. NASA used an evolutionary algorithm, a cousin of this one, to design an antenna for its Space Technology 5 mission. The result looks like a bent paper clip, nothing a human designer would draw, and it flew in space in 2006. Lab~8 tests the method on a problem where we know the exact answer, which is the fairest test of all.

== Vocabulary

#utptable[
  #tabularx(
    columns: (14%, 34%, 21%, 1fr),
    styles: (navy-bold,),
    header: ([Term], [Meaning], [On eight queens], [In Lab~8]),
    [Chromosome], [One candidate solution, as a vector of genes], [Eight digits, one per column], [Five real numbers: intercept plus four coefficients],
    [Gene], [One component of a chromosome], [One queen’s row], [One coefficient],
    [Population], [The set of chromosomes alive in one generation], [50 boards], [100 (or 40 in the sensitivity study)],
    [Fitness], [The score to be optimised], [Pairs not attacking; higher is better], [Training mean squared error; lower is better],
    [Selection], [Choosing parents, biased towards good fitness], [Tickets (roulette wheel)], [Tournament of three],
    [Crossover], [Combining two parents into children], [Cut and join], [Blend crossover],
    [Mutation], [Random perturbation of a child], [One queen jumps], [Gaussian noise on a random subset of genes],
    [Elitism], [Copying the best chromosomes unchanged into the next generation], [None], [The best 4 (or 2) survive],
    [Generation], [One pass of evaluate, select, cross, mutate, replace], [Up to 1,000 passes], [160 passes per run],
  )
]

== One generation

#figref(<fig:ga-loop>) combines selection pressure, recombination, mutation and preservation of the best candidates.

#utpfig([Selection favours better solutions, crossover recombines parents, mutation introduces variation, and elitism preserves the best candidates.], label: <fig:ga-loop>)[
  #canvas({
    let b = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.4, min-height: 0.9, align: center, font: font("script", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [Population], name: "p", ..b)
    node(right-of("p", 0.35), [Evaluate \
  fitness], name: "fit", ..b)
    node(right-of("fit", 0.35), [Select \
  parents], name: "sel", ..b)
    node(right-of("sel", 0.35), [Crossover], name: "cross", ..b)
    node(right-of("cross", 0.35), [Mutation], name: "mut", ..b)
    node(below-of("sel", 1), [New generation \
  \= elites + children], name: "rep", ..b, fill: pale-teal, draw: green)
    connect("p", "fit", ..arr)
    connect("fit", "sel", ..arr)
    connect("sel", "cross", ..arr)
    connect("cross", "mut", ..arr)
    connect("mut.south", "|-", "rep.east", ..arr)
    connect("rep.west", "-|", "p.south", ..arr)
    connect("fit.south", (rel: (0, -0.55), to: "fit.south"), "-|", "rep.north", ..arr, draw: green, dash: "dashed")
    node(along((rel: (0, -0.55), to: "fit.south"), ((rel: (0, -0.55), to: "fit.south"), "-|", "rep.north"), t: 50%), [best few copied unchanged (elitism)], xshift: -1cm, ..utplabel, text: green, anchor: "north")
  })
]

The lab uses the same loop for a single number $x$ and for a five-gene vector. The single-number version, which minimises $(x-3)^2$, shows all the moving parts in a few lines:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 28, last: 39, lang: "python")

Vectorised operators avoid looping over individuals, so 160 generations of 100 chromosomes take a few hundredths of a second.

== Encoding: the chromosome is the answer

For $hat(y)=p_0+p_1 x_1+ dots.h +p_4 x_4$, encode each chromosome as five real coefficients. The GA searches the same space as least squares, which is what makes a direct comparison possible. Two details matter:

/ Initialisation matters.: Charges are in thousands of dollars. Draw coefficients with mean~0 and standard deviation~5000, then shift the intercept towards the mean charge. Starting from $cal(N)(0,1)$ would place the whole population far from useful values.
/ Standardise the inputs.: Age (18--64) and smoker status (0--1) have very different scales. Standardise all four predictors using training statistics so that a mutation step means roughly the same thing for each coefficient.

#note[
  The chromosome #emph[is] the candidate answer, read by the fitness function. Operators depend on the encoding: blend crossover suits real coefficients, cut-and-join suits eight-queens boards, and neither would make sense on a route that must visit every city exactly once.
]

== The operators

=== Fitness

Fitness is training mean squared error. The lab evaluates it for the whole population in one matrix product:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 66, last: 68, lang: "python")

Evaluating 100 five-gene chromosomes on 1,070 training rows produces a $100 times 1(,)070$ prediction matrix, computed in one step rather than in a Python loop.

=== Selection

#term[Tournament selection] samples $k$ chromosomes and keeps the fittest, like picking the winner of a small heat; Lab~8 uses $k=3$. Unlike #term[roulette-wheel] selection (#figref(<fig:roulette>)), which is the raffle from eight queens, it does not depend on the scale of the fitness values and needs no conversion when lower is better. The tournament size sets the selection pressure. With $k=1$ there is no selection at all, and on Lab~8 the seed-to-seed spread jumps from $0.002$ to about 11.5.

#utpfig([Arc widths are proportional to fitness: B is selected four times as often as D. Tournament selection favours fitter candidates without depending on fitness scale.], label: <fig:roulette>)[
  #canvas({
    node((0, 2.1), [Selection probabilities], ..utplabel, font: font("small", weight: "bold", fill: navy))
    let rad = 1.75
    for (a, b, lbl, col) in ((0, 144, "B", blue), (144, 252, "A", teal), (252, 324, "C", orange), (324, 360, "D", red)) {
      arc-at((angle: (a) * 1deg, radius: rad), a, b, rad, line-width: widths.thick, fill: mix(col, 28%), draw: none)
      connect((0, 0), (angle: (a) * 1deg, radius: rad), line-width: widths.thick, fill: mix(col, 28%), draw: none)
      let mid = (a + b) / 2
      node((angle: (mid) * 1deg, radius: 0.65 * rad), [#lbl], font: font("small", weight: "bold", fill: navy))
    }
    node((0, -2), [Fitness $(B,A,C,D)=(4,3,2,1)$], font: font("small"), ..utplabel, anchor: "north", align: center)
    draw.scope({
      draw.translate((4, 0))
      draw.translate((0, -0.4))
      let L = 7.2
      node((0.5 * L, 2.5), [Cumulative probability], ..utplabel, font: font("small", weight: "bold", fill: navy))
      for (s, ee, lbl, col) in ((0, 0.4, "B", blue), (0.4, 0.7, "A", teal), (0.7, 0.9, "C", orange), (0.9, 1, "D", red)) {
        let x = s * L
        let w = (ee - s) * L
        rectangle((x, 0), (rel: (w, 0.85), to: (x, 0)), line-width: widths.thick, fill: mix(col, 28%), draw: none)
        node((x + w / 2, 0.42), [#lbl], font: font("small", weight: "bold", fill: navy))
      }
      for (vv, x) in ((0, 0), (0.4, 0.4), (0.7, 0.7), (0.9, 0.9), (1, 1)) {
        let xx = x * L
        node((xx, -0.28), [#vv], font: font("small"), ..utplabel)
      }
      connect((0.54 * L, 1.5), (0.54 * L, 0.95), line-width: 1.1955pt, draw: navy, end: arrow-tip("Stealth", length: 2.4mm, line: 1.1955pt))
      node((0.54 * L, 1.55), [`rand` $=0.54 space arrow.r.double$ pick A], font: font("small"), ..utplabel, anchor: "south", text: navy)
      node((0.5 * L, -0.75), [The draw $0.54$ falls in A\'s interval, $0.40$ to $0.70$.], font: font("small"), ..utplabel, anchor: "north", align: center, text-width: 6.8)
    })
  })
]

=== Crossover and mutation

Cutting a list of real coefficients and joining the pieces would work poorly, because a good value of one gene is not tied to a position. #term[Blend crossover] forms $alpha thin a+(1- alpha ) thin b$ from two parents instead. With $alpha in [0,1]$, children lie between them. The regression GA uses $alpha in [-0.1,1.1]$, which allows a child to land just beyond a parent (#figref(<fig:crossover>)). #term[Gaussian mutation] adds noise to a random 15 % of genes using per-gene step sizes. Without it the population can only contract: with the mutation rate set to zero, Lab~8’s median test RMSE stays stuck at about 6,534 instead of reaching 5,829.

#utpfig([Left: blend crossover places children between parents or slightly beyond them. Right: Gaussian mutation perturbs a child by a random step.], label: <fig:crossover>)[
  #canvas({
    draw.scope({
      node((2, 2.65), [Blend crossover], font: font("normal", weight: "bold", fill: navy))
      connect((-0.2, 0), (4.4, 0), draw: muted, end: arrow-tip("Stealth", length: 2mm, line: 0.4pt))
      node(along((-0.2, 0), (4.4, 0), t: 100%), [$p_1$], font: font("script"), anchor: "west")
      connect((0, -0.2), (0, 1.85), draw: muted, end: arrow-tip("Stealth", length: 2mm, line: 0.4pt))
      node(along((0, -0.2), (0, 1.85), t: 100%), [$p_2$], font: font("script"), anchor: "south")
      node((0.7, 1.35), [], name: "P1", font: font("small"), shape: "circle", fill: blue, inner-sep: 2.1918pt)
      node("P1" + ".north", [parent $a$], font: font("small"), ..utplabel, anchor: "south", text: blue)
      node((3.6, 0.45), [], name: "P2", font: font("small"), shape: "circle", fill: teal, inner-sep: 2.1918pt)
      node("P2" + ".south", [parent $b$], font: font("small"), ..utplabel, anchor: "north", text: teal)
      connect("P1", "P2", draw: mix(muted, 60%), dash: "dashed")
      node((1.86, 1), [], name: "Ch", font: font("small"), shape: "circle", fill: orange, inner-sep: 2.1918pt)
      node((2, 1.28), [child, $alpha =0.6$], font: font("small"), ..utplabel, anchor: "west", text: orange)
      node((2, -1.15), [$alpha in [-0.1,1.1]$ lets a child land just beyond a parent], font: font("small"), ..utplabel, anchor: "north", align: center, text-width: 4.8)
    })
    draw.scope({
      draw.translate((6.6, 0))
      node((2.2, 2.65), [Gaussian mutation], font: font("normal", weight: "bold", fill: navy))
      connect((-0.2, 0), (4.4, 0), draw: muted, end: arrow-tip("Stealth", length: 2mm, line: 0.4pt))
      node(along((-0.2, 0), (4.4, 0), t: 100%), [$p_1$], font: font("script"), anchor: "west")
      connect((0, -0.2), (0, 1.85), draw: muted, end: arrow-tip("Stealth", length: 2mm, line: 0.4pt))
      node(along((0, -0.2), (0, 1.85), t: 100%), [$p_2$], font: font("script"), anchor: "south")
      node((1.9, 0.9), [], name: "C", font: font("small"), shape: "circle", fill: orange, inner-sep: 2.1918pt)
      node("C" + ".south", [child], font: font("small"), ..utplabel, anchor: "north", text: orange)
      circle-at((1.9, 0.9), 0.75, draw: mix(orange, 35%), fill: mix(orange, 10%))
      node((2.45, 1.3), [], name: "M", font: font("small"), shape: "circle", fill: red, inner-sep: 2.1918pt)
      node("M" + ".north-east", [mutated child], font: font("small"), ..utplabel, anchor: "south-west", text: red)
      connect("C", "M", ..utpptr, draw: red)
      node((2.2, -1.15), [each gene moves by $cal(N)(0, sigma )$ with probability $0.15$; $sigma$ is set per gene], font: font("small"), ..utplabel, anchor: "north", align: center, text-width: 5.2)
    })
  })
]

=== Elitism

#term[Elitism] copies the best chromosomes unchanged into the next generation, so that selection or mutation cannot lose them. Think of an athletics squad that always keeps its current record holder. It costs a few population slots and means that the best fitness in the population can never get worse. Without elites, the best member of the population got worse in 54 of 159 generations on one Lab~8 run.

#note[
  Selection favours good candidates, crossover recombines, mutation explores and elitism preserves. Tournament size~3, 15 % mutation and four elites are one workable balance, not universal settings.
]

== Verifying before trusting

Wrong fitness signs or mutation scales may not raise any error message: the code just runs and gives poor answers. So Lab~8 first minimises $f(x)=(x-3)^2$, whose answer we know, reaching about $10^(-5)$ from $x=3$ in 80 generations. Only then does it move on to regression, where least squares supplies a second check.

== Judging a stochastic optimiser

A GA uses random numbers, so one seed shows only one outcome. Lab~8 reports results over ten seeds and compares them with an exact method.

#utptable[
  #tabularx(
    columns: (28%, 1fr, 1fr, 1fr),
    align: (left, center, center, center),
    styles: (navy-bold,),
    header: ([Method], [Median test RMSE], [SD across seeds], [Median runtime]),
    [GA, population 100], [5829.38], [0.002], [0.04 s],
    [GA, population 40], [5829.38], [0.026], [0.02 s],
    [Ordinary least squares], [5829.38], [---], [$<$ 0.001 s],
  )
]

Three lessons follow:

/ The GA approaches the optimum.: Runs agree within a few thousandths and match OLS performance, and the median coefficients match OLS to one decimal place.
/ It did not beat the optimum.: Least squares solves the same problem exactly and faster. Agreement verifies the GA; it shows no advantage over OLS.
/ Population size trades speed for spread.: Forty chromosomes halve the runtime with the same median, but increase seed-to-seed standard deviation by an order of magnitude. Judge that trade against the cost of a poor run.

#warning[
  Report the median and spread across independent seeds, not one run or the best run presented as typical. A lucky seed says nothing about the next one. On eight queens the median successful run took 328 generations, and 29 of the 200 runs did not finish at all.
]

== When is a genetic algorithm the right tool?

Least squares suits Lab~8’s smooth, convex, unconstrained objective. Recall the bowl from #chapref(<ch:fuzzy>): one lowest point and a formula that jumps straight there. Consider a GA when the problem is nothing like a bowl:

- the objective is #strong[non-differentiable] or only available as a black box (a simulation, a physical test rig);
- some variables are #strong[discrete or mixed] (which features to include, which route to take, which schedule to run), so there is no gradient to follow;
- the objective is #strong[multimodal], with many local optima that trap gradient methods;
- the constraints are #strong[awkward]: business rules, integer budgets, or feasibility checks that are easy to test and impossible to write as equations.

Integer coefficients, penalties on non-zero coefficients or a plateaued loss would invalidate ordinary least squares. A GA would need a revised fitness function and possibly new operators, and the deliverable asks you to identify one such change.

#summary[
  - A GA evolves a population: fitter candidates are selected, recombined and mutated, and the best may be kept unchanged.
  - The encoding decides the operators. Eight digits suit cut-and-join; real coefficients suit blending and Gaussian noise.
  - Verify on a problem with a known answer, then report the median and spread over independent seeds.
  - A GA that matches an exact method has been verified, not vindicated. Race it against something simple, and reach for it when the problem has no formula and no gradient.
]

#questions[
  + What is the chromosome in Lab~8, and how many genes does it have?
  + Why does the lab standardise the predictors before running the GA, when least squares would give the same fit either way?
  + What can happen to the best fitness in the population without elitism, and why?
  + Blend crossover with $alpha in [0,1]$ can only produce children between the parents. What does that do to a population over many generations, and which two choices in the lab counteract it?
  + Ten seeds gave test RMSE within $0.002$ of each other. Why is that a stronger statement than one run that hit the OLS value exactly?
  + On eight queens, a board has 4 attacking pairs. How many raffle tickets does it hold?
]
