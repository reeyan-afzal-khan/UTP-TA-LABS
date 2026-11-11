#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-genetic-algorithms")


#heading(level: 1)[Genetic Algorithms]
 <ch:ga>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know local search from #ref(label("ch:localsearch"), supplement: [Chapter]), be comfortable with NumPy arrays and random numbers, and know what a regression model and its RMSE are.

*By the end, you can:* name the parts of a genetic algorithm and what each contributes; encode a real-valued problem as a chromosome; implement tournament selection, blend crossover, Gaussian mutation and elitism; evaluate a stochastic optimiser over repeated seeds; and decide when an evolutionary method is justified against an exact one.]

Every search in #ref(label("ch:localsearch"), supplement: [Chapter]) changes one candidate at a time: one queen on one board, one word added to one sentence. Each option only ever grows by itself. But two half-good solutions often have complementary strengths. What if they could combine?

Nature does this all the time, with two parents and a child that gets a bit of each. A #strong[genetic algorithm] (GA) applies the same idea to candidate solutions. It improves a whole population through selection, recombination and random mutation, and it needs only a scoring function, not derivatives or convexity. Lab~8 tests a GA on a known one-dimensional function, then fits linear-regression coefficients. Ordinary least squares provides an exact, faster reference, so the aim is to evaluate a stochastic optimiser, not to claim it beats an exact method.


#heading(level: 2)[Breeding boards: the idea on eight queens]


Start with the puzzle from #ref(label("ch:localsearch"), supplement: [Chapter]). A GA keeps a population of boards, say 50 random ones, and writes each board as eight digits, one per column, each saying which row that column's queen is in. Each board gets a #strong[fitness]: the fewer attacking pairs, the fitter it is.

#callout("analogy", title: [Analogy])[Think of a raffle for the right to breed. Eight queens make 28 pairs, and a board gets one ticket for every pair that does #emph[not] attack. A board with 3 attacking pairs holds 25 tickets, and one with 10 holds 18. Draw two tickets to choose two parents. Fitter boards are likelier to be drawn, but even a poor board has a chance, which keeps variety in the population.]

Two more steps make a child. In #strong[crossover] we cut both parents at a random column and join the pieces. In #strong[mutation], now and then, one queen in the child jumps to a random row, which can create a row neither parent had (#ref(label("fig:breeding"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/60aaebd845837474.svg")], caption: [A lucky pairing, chosen to show both operators. Each digit gives the row of one column's queen. Crossover cuts both parents after the same column and joins the left of one to the right of the other, and the child has only one attacking pair. Mutation then changes one digit to a row neither parent had in that column, and this board is solved.]) <fig:breeding>

Repeat this to fill a new generation and let the children replace the population. Good pieces from two parents can then meet in one child, in a single step that a hill climber could not take. Here is that loop in Python, as the demo runs it:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/demo_local_search.py", first: 79, last: 98, lang: "python")

Now the honest part. How well does it work on eight queens? In the demo, 171 of 200 runs find a solution within 1,000 generations, with a median of 328 generations among those that succeed. The work comes to about 27,000 boards per puzzle solved. Simulated annealing needed about 1,100.

#callout("keyidea", title: [Key idea])[Breeding boards sounds like the coolest idea in this book, and on eight queens the dumbest-sounding idea, annealing, does the job with less than a tenth of the work. When an idea sounds exciting, race it against a simple one first.]

GAs still earn their keep elsewhere. NASA used an evolutionary algorithm, a cousin of this one, to design an antenna for its Space Technology 5 mission. The result looks like a bent paper clip, nothing a human designer would draw, and it flew in space in 2006. Lab~8 tests the method on a problem where we know the exact answer, which is the fairest test of all.


#heading(level: 2)[Vocabulary]


#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Term], [Meaning], [On eight queens], [In Lab~8],),
    table.hline(),
    [Chromosome], [One candidate solution, as a vector of genes], [Eight digits, one per column], [Five real numbers: intercept plus four coefficients],
    [Gene], [One component of a chromosome], [One queen's row], [One coefficient],
    [Population], [The set of chromosomes alive in one generation], [50 boards], [100 (or 40 in the sensitivity study)],
    [Fitness], [The score to be optimised], [Pairs not attacking; higher is better], [Training mean squared error; lower is better],
    [Selection], [Choosing parents, biased towards good fitness], [Tickets (roulette wheel)], [Tournament of three],
    [Crossover], [Combining two parents into children], [Cut and join], [Blend crossover],
    [Mutation], [Random perturbation of a child], [One queen jumps], [Gaussian noise on a random subset of genes],
    [Elitism], [Copying the best chromosomes unchanged into the next generation], [None], [The best 4 (or 2) survive],
    [Generation], [One pass of evaluate, select, cross, mutate, replace], [Up to 1,000 passes], [160 passes per run],
  )]
  , kind: table
  )


#heading(level: 2)[One generation]


#ref(label("fig:ga-loop"), supplement: [Figure]) combines selection pressure, recombination, mutation and preservation of the best candidates.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/13b8832decf49deb.svg")], caption: [Selection favours better solutions, crossover recombines parents, mutation introduces variation, and elitism preserves the best candidates.]) <fig:ga-loop>

The lab uses the same loop for a single number $x$ and for a five-gene vector. The single-number version, which minimises $\( x - 3 \)^2$, shows all the moving parts in a few lines:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 28, last: 39, lang: "python")

Vectorised operators avoid looping over individuals, so 160 generations of 100 chromosomes take a few hundredths of a second.


#heading(level: 2)[Encoding: the chromosome is the answer]


For $hat(y) = p_0 + p_1 x_1 + dots.h + p_4 x_4$, encode each chromosome as five real coefficients. The GA searches the same space as least squares, which is what makes a direct comparison possible. Two details matter:

/ Initialisation matters.: #block[
Charges are in thousands of dollars. Draw coefficients with mean~0 and standard deviation~5000, then shift the intercept towards the mean charge. Starting from $cal(N) \( 0 \, 1 \)$ would place the whole population far from useful values.
]

/ Standardise the inputs.: #block[
Age (18--64) and smoker status (0--1) have very different scales. Standardise all four predictors using training statistics so that a mutation step means roughly the same thing for each coefficient.
]

#callout("intuition", title: [Conceptual intuition])[The chromosome #emph[is] the candidate answer, read by the fitness function. Operators depend on the encoding: blend crossover suits real coefficients, cut-and-join suits eight-queens boards, and neither would make sense on a route that must visit every city exactly once.]


#heading(level: 2)[The operators]



#heading(level: 3)[Fitness]


Fitness is training mean squared error. The lab evaluates it for the whole population in one matrix product:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.py", first: 66, last: 68, lang: "python")

Evaluating 100 five-gene chromosomes on 1,070 training rows produces a $100 times 1 \, 070$ prediction matrix, computed in one step rather than in a Python loop.


#heading(level: 3)[Selection]


#strong[Tournament selection] samples $k$ chromosomes and keeps the fittest, like picking the winner of a small heat; Lab~8 uses $k = 3$. Unlike #strong[roulette-wheel] selection (#ref(label("fig:roulette"), supplement: [Figure])), which is the raffle from eight queens, it does not depend on the scale of the fitness values and needs no conversion when lower is better. The tournament size sets the selection pressure. With $k = 1$ there is no selection at all, and on Lab~8 the seed-to-seed spread jumps from $0.002$ to about 11.5.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/66f6691301f0158a.svg")], caption: [Arc widths are proportional to fitness: B is selected four times as often as D. Tournament selection favours fitter candidates without depending on fitness scale.]) <fig:roulette>


#heading(level: 3)[Crossover and mutation]


Cutting a list of real coefficients and joining the pieces would work poorly, because a good value of one gene is not tied to a position. #strong[Blend crossover] forms $alpha thin a + \( 1 - alpha \) thin b$ from two parents instead. With $alpha in \[ 0 \, 1 \]$, children lie between them. The regression GA uses $alpha in \[ - 0.1 \, 1.1 \]$, which allows a child to land just beyond a parent (#ref(label("fig:crossover"), supplement: [Figure])). #strong[Gaussian mutation] adds noise to a random 15 % of genes using per-gene step sizes. Without it the population can only contract: with the mutation rate set to zero, Lab~8's median test RMSE stays stuck at about 6,534 instead of reaching 5,829.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/9dfe22e406161bbb.svg")], caption: [Left: blend crossover places children between parents or slightly beyond them. Right: Gaussian mutation perturbs a child by a random step.]) <fig:crossover>


#heading(level: 3)[Elitism]


#strong[Elitism] copies the best chromosomes unchanged into the next generation, so that selection or mutation cannot lose them. Think of an athletics squad that always keeps its current record holder. It costs a few population slots and means that the best fitness in the population can never get worse. Without elites, the best member of the population got worse in 54 of 159 generations on one Lab~8 run.

#callout("keyidea", title: [Key idea])[Selection favours good candidates, crossover recombines, mutation explores and elitism preserves. Tournament size~3, 15 % mutation and four elites are one workable balance, not universal settings.]


#heading(level: 2)[Verifying before trusting]


Wrong fitness signs or mutation scales may not raise any error message: the code just runs and gives poor answers. So Lab~8 first minimises $f \( x \) = \( x - 3 \)^2$, whose answer we know, reaching about $10^(- 5)$ from $x = 3$ in 80 generations. Only then does it move on to regression, where least squares supplies a second check.


#heading(level: 2)[Judging a stochastic optimiser]


A GA uses random numbers, so one seed shows only one outcome. Lab~8 reports results over ten seeds and compares them with an exact method.

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Method], [Median test RMSE], [SD across seeds], [Median runtime],),
    table.hline(),
    [GA, population 100], [5829.38], [0.002], [0.04 s],
    [GA, population 40], [5829.38], [0.026], [0.02 s],
    [Ordinary least squares], [5829.38], [---], [$<$ 0.001 s],
  )]
  , kind: table
  )

Three lessons follow:

/ The GA approaches the optimum.: #block[
Runs agree within a few thousandths and match OLS performance, and the median coefficients match OLS to one decimal place.
]

/ It did not beat the optimum.: #block[
Least squares solves the same problem exactly and faster. Agreement verifies the GA; it shows no advantage over OLS.
]

/ Population size trades speed for spread.: #block[
Forty chromosomes halve the runtime with the same median, but increase seed-to-seed standard deviation by an order of magnitude. Judge that trade against the cost of a poor run.
]

#callout("pitfall", title: [Common mistake])[Report the median and spread across independent seeds, not one run or the best run presented as typical. A lucky seed says nothing about the next one. On eight queens the median successful run took 328 generations, and 29 of the 200 runs did not finish at all.]


#heading(level: 2)[When is a genetic algorithm the right tool?]


Least squares suits Lab~8's smooth, convex, unconstrained objective. Recall the bowl from #ref(label("ch:fuzzy"), supplement: [Chapter]): one lowest point and a formula that jumps straight there. Consider a GA when the problem is nothing like a bowl:

- the objective is #strong[non-differentiable] or only available as a black box (a simulation, a physical test rig);

- some variables are #strong[discrete or mixed] (which features to include, which route to take, which schedule to run), so there is no gradient to follow;

- the objective is #strong[multimodal], with many local optima that trap gradient methods;

- the constraints are #strong[awkward]: business rules, integer budgets, or feasibility checks that are easy to test and impossible to write as equations.

Integer coefficients, penalties on non-zero coefficients or a plateaued loss would invalidate ordinary least squares. A GA would need a revised fitness function and possibly new operators, and the deliverable asks you to identify one such change.

#callout("chapterrecap", title: [Chapter recap])[- A GA evolves a population: fitter candidates are selected, recombined and mutated, and the best may be kept unchanged.

- The encoding decides the operators. Eight digits suit cut-and-join; real coefficients suit blending and Gaussian noise.

- Verify on a problem with a known answer, then report the median and spread over independent seeds.

- A GA that matches an exact method has been verified, not vindicated. Race it against something simple, and reach for it when the problem has no formula and no gradient.]

#callout("quickcheck", title: [Check your understanding])[+ What is the chromosome in Lab~8, and how many genes does it have?

+ Why does the lab standardise the predictors before running the GA, when least squares would give the same fit either way?

+ What can happen to the best fitness in the population without elitism, and why?

+ Blend crossover with $alpha in \[ 0 \, 1 \]$ can only produce children between the parents. What does that do to a population over many generations, and which two choices in the lab counteract it?

+ Ten seeds gave test RMSE within $0.002$ of each other. Why is that a stronger statement than one run that hit the OLS value exactly?

+ On eight queens, a board has 4 attacking pairs. How many raffle tickets does it hold?]
