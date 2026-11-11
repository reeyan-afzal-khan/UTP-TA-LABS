#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-informed-search")


#heading(level: 1)[Informed Search: Greedy Best-First Search and A\*]
 <ch:informed>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Trace BFS, DFS and UCS (#ref(label("ch:uninformed"), supplement: [Chapter])) and explain what a priority queue does.

*By the end, you can:* define a heuristic and compute $g$, $h$ and $f$ for a state; trace Greedy Best-First Search and A$""^star.op$; decide whether a heuristic is admissible and why that matters; explain why a sharper guess saves work; and read the effort-versus-quality trade-off in Lab~2's tables.]

Look at where UCS went on the rainy maze. It spread evenly in every direction, even away from the charger, and expanded 47 of the 48 cells. It only counts the battery it has spent, so it has no idea which way the charger is. On the airline network the same blindness costs 1,851 expanded airports for the route from Kuala Lumpur to Keflavík.

If you were standing in that maze you would head towards the charger, because you can roughly see where it is. This chapter gives the search that same sense of direction: a #strong[heuristic], a quick guess of how far is left. Lab~2 then measures what the guess does to search effort and to route quality.


#heading(level: 2)[A guess of what is left]


Give the robot a simple guess. For any cell, count the steps across plus the steps up or down to the charger, and pretend walls and puddles do not exist. From the robot's cell at $\( 5 \, 1 \)$ that is 8 columns across and 3 rows up, so its guess is 11. Do this for every cell and you get a number in each one, 0 on the charger and bigger further away (#ref(label("fig:manhattan"), supplement: [Figure])). In code it is one line:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/demo_robot_maze.py", first: 56, last: 58, lang: "python")

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/de8097de85d15bbc.svg")], caption: [The guess for every cell: rows apart plus columns apart, ignoring what is in the way. The robot's cell guesses 11, but the cheapest real route in the rain costs 13, because the guess cannot see walls or puddles.]) <fig:manhattan>

A guess like this is written $h \( n \)$. It is quick to work out and it is only an estimate. A search that uses one is called #strong[informed]; BFS and UCS, which have no guess, are #strong[uninformed], or blind.


#heading(level: 2)[Three quantities on one path]


Every informed method reasons about a frontier state $n$ using up to three numbers:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Quantity], [Meaning], [Used by],),
    table.hline(),
    [$g \( n \)$], [Exact cost of the cheapest known path from the start to $n$: what you have already spent], [UCS, A$""^star.op$],
    [$h \( n \)$], [Estimated cost from $n$ to the goal: a guess of what is left], [GBFS, A$""^star.op$],
    [$f \( n \) = g \( n \) + h \( n \)$], [Estimated total cost of a whole trip that passes through $n$], [A$""^star.op$],
  )]
  , kind: table
  )

#callout("analogy", title: [Analogy])[On a road trip, the odometer tells you how far you have driven and the map tells you roughly how far is left. The odometer is exact and backward-looking; it is $g$. The map is an estimate and forward-looking; it is $h$. Add them and you have a fair estimate of the whole trip, which is the number you would use to compare two possible routes.]

#ref(label("fig:fgh"), supplement: [Figure]) separates known cost from estimated remaining cost. UCS uses the former, GBFS the latter, and A$""^star.op$ both.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/87c0851dd20a7a3f.svg")], caption: [$f \( n \) = g \( n \) + h \( n \)$ combines known cost with estimated remaining cost. UCS prioritises $g$, GBFS $h$, and A$""^star.op$ their sum.]) <fig:fgh>


#heading(level: 2)[Greedy best-first search: go where it looks closest]


The simplest way to use the guess is to take the cell whose guess is smallest, the one that #emph[looks] closest to the charger. That is #strong[Greedy Best-First Search (GBFS)]: best-first because it always explores the best-looking cell, greedy because it only cares about getting closer right now. It uses the same priority queue as UCS. Only the number changes: UCS sorts by $g$, GBFS by $h$.

Walk it on the rainy maze. From the robot, the cells above and to the right both guess 10, and the one above joined first, so GBFS goes up. It climbs to $\( 2 \, 1 \)$ on the charger's row, where the guess is 8, and meets a wall. The next best-looking cell is $\( 3 \, 2 \)$, also guessing 8, so it steps straight into the first puddle without noticing and runs along the corridor from there, every step bringing the guess down by one. It never looks at the bottom of the maze.

GBFS reaches the charger after expanding only 13 cells, the least work of anything so far. But its route is the middle corridor at 19 units of battery, and the robot runs dry four cells short. GBFS looks only at what is left. It never counts what it has already spent.

#callout("workedexample", title: [Worked example])[On the airline network GBFS expands two airports for `KUL -> LHR -> KEF`: 12,500~km, 9 % above the optimum. London looks close to Iceland, but the first leg alone exceeds the optimal route through Phuket, St Petersburg and Helsinki. Its `NRT`$arrow.r$`CPT` route is 6.7 % too long, and its `SIN`$arrow.r$`EZE` route happens to be optimal.]

#callout("pitfall", title: [Common mistake])[Because GBFS ignores $g$, a small $h$ can conceal an expensive path. How good its route is depends on what the graph looks like around the goal, so one good result proves nothing about the next query.]


#heading(level: 2)[A\* search: what you spent plus what is left]


Neither search does both jobs. UCS gets the robot home but looks at every cell. GBFS heads straight for the charger but runs out of battery. UCS counts what is spent, $g$. GBFS guesses what is left, $h$. So add them up, $f \( n \) = g \( n \) + h \( n \)$, and take the cell with the smallest $f$. That is #strong[A$""^star.op$], the same priority queue again, sorted by a third number. In `utils/core.py` the three algorithms share `best_first`, and these lines are all that separates them:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 104, last: 109, lang: "python")

#ref(label("fig:astar-cells"), supplement: [Figure]) shows how to read the three numbers on a cell. Follow the first few picks on the rainy maze, keeping an eye on $\( 3 \, 2 \)$.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/ceb36e4051f1ed62.svg")], caption: [Four cells from the first picks of A$""^star.op$ on the rainy maze. The big number is $f$, the sum of $g$ (top left) and $h$ (top right). Stepping into the puddle at $\( 3 \, 2 \)$ costs 5, so its $f$ jumps to 15 and it waits behind every cell with $f = 13$.]) <fig:astar-cells>

#callout("workedexample", title: [Worked example])[The first five picks of A$""^star.op$. Each cell added to the frontier is shown with its $f$.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Pick], [Its $f$], [Added to the frontier (with $f$)],),
    table.hline(),
    [$\( 5 \, 1 \)$], [11], [$\( 4 \, 1 \)$ 11,~~$\( 5 \, 2 \)$ 11,~~$\( 6 \, 1 \)$ 13,~~$\( 5 \, 0 \)$ 13],
    [$\( 4 \, 1 \)$], [11], [$\( 3 \, 1 \)$ 11,~~$\( 4 \, 0 \)$ 13],
    [$\( 5 \, 2 \)$], [11], [$\( 6 \, 2 \)$ 13],
    [$\( 3 \, 1 \)$], [11], [$\( 2 \, 1 \)$ 11,~~$\( 3 \, 2 \)$ #strong[15] (the puddle)],
    [$\( 2 \, 1 \)$], [11], [$\( 1 \, 1 \)$ 13,~~$\( 2 \, 0 \)$ 13],
  )]
  , kind: table
  )

The frontier now holds several cells with $f = 13$ and one with $f = 15$. A$""^star.op$ clears every 13 first, and those cells lead along the bottom row to the charger.]

A$""^star.op$ reaches the charger with $g = 13$. That is the route UCS found, but A$""^star.op$ expanded only 28 cells instead of 47 (#ref(label("fig:expansion"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/d6c470ee72a402cd.svg")], caption: [The rainy maze solved three ways, with the same battery of 15. Blue cells were expanded. UCS spreads everywhere and finds the 13-unit route. GBFS barely explores, but its route costs 19 and the robot runs dry. A$""^star.op$ finds the 13-unit route and leaves the top and the corridor alone.]) <fig:expansion>

Why did A$""^star.op$ get to skip so much? Colour every cell by the best $f$ it can have, using the cheapest way to reach it (#ref(label("fig:fmap"), supplement: [Figure])). A$""^star.op$ expanded exactly the cells with $f lt.eq 13$, and every cell it skipped has $f gt.eq 15$. The guess never exceeds the real remaining cost, because walls can only make a route longer and puddles can only make it dearer. So any route through a skipped cell costs at least 15, more than the 13 already in hand, and there was never a reason to look.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/a33a5386c43590a8.svg")], caption: [Each cell shows the best possible $f = g + h$ on the rainy maze. Blue cells have $f lt.eq 13$ and are exactly the ones A$""^star.op$ expanded. Grey cells have $f gt.eq 15$: any route through them must cost at least that, so with a 13-unit route in hand they can be ignored.]) <fig:fmap>

#callout("keyidea", title: [Key idea])[GBFS asks which frontier state #emph[looks] closest to the goal. A$""^star.op$ also accounts for the cost already paid and, with a suitable heuristic, guarantees the cheapest path.]

#callout("workedexample", title: [Worked example])[Suppose frontier state $X$ has $\( g \, h \) = \( 5 \, 3 \)$ and $Y$ has $\( 1 \, 5 \)$. GBFS chooses $X$ because $3 < 5$. A$""^star.op$ chooses $Y$ because $f \( Y \) = 6 < f \( X \) = 8$: the cheaper path so far is worth the extra estimated distance.]

#callout("libnote", title: [Reference note])[Peter Hart, Nils Nilsson and Bertram Raphael published A$""^star.op$ in 1968 at the Stanford Research Institute. They developed it for Shakey, one of the first mobile robots able to plan its own actions. Their example heuristic for cities joined by roads was the airline distance, the same as-the-crow-flies guess you will use in Lab~2. A$""^star.op$ with $h = 0$ is exactly UCS, so A$""^star.op$ is Dijkstra's algorithm with a guess added.]


#heading(level: 2)[The one rule: never overestimate]


The guess made A$""^star.op$ faster, so why not trust it even more? Multiply every guess by three. On the robot's cell the guess of 11 becomes 33, far above the real cost of 13, and from every cell A$""^star.op$ now believes the charger is much further away than it is. The tripled guess is so much bigger than the battery spent that it decides almost every pick. A$""^star.op$ heads straight for the charger like GBFS, expands only 16 cells, and returns the 19-unit corridor. The robot runs dry again (#ref(label("fig:triple"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/d977e21a1169f7cd.svg")], caption: [A$""^star.op$ on the rainy maze with the honest guess and with the guess multiplied by three. Trusting the guess too much saves 12 expansions and loses the cheapest route.]) <fig:triple>


#heading(level: 3)[Admissibility and consistency]


So there is one rule. A heuristic is #strong[admissible] when it never overestimates the cheapest remaining cost: $ h \( n \) #h(0em) lt.eq #h(0em) h^star.op \( n \) quad upright("for every state ") n \, $ where $h^star.op \( n \)$ is the true cost of the cheapest path from $n$ to the goal. If that holds, A$""^star.op$ is guaranteed to return a cheapest path. Our Manhattan guess qualifies: on the robot's cell it is 11 against a true 13.

A stronger and more convenient condition is #strong[consistency]: for every edge $n arrow.r n'$ of cost $c$, $h \( n \) lt.eq c + h \( n' \)$. In words, one step cannot make the guess drop by more than the step cost. Consistency implies admissibility and guarantees that the first time A$""^star.op$ pops a state, it has found the cheapest path to it, which is what allows the closed-set implementation in `utils` to skip re-expansions. Its picture is the triangle inequality (#ref(label("fig:triangle"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/69ea9bec8895264d.svg")], caption: [The direct line from $n$ to the goal can never be longer than going via $n'$ first. The same is true on a sphere, which is why the great-circle distance is a consistent heuristic for airline routes: no sequence of flights can beat flying straight there.]) <fig:triangle>

#callout("intuition", title: [Conceptual intuition])[An inadmissible heuristic makes A$""^star.op$ behave like GBFS: it trusts the estimate too much and commits to a branch before the cost evidence justifies it. Admissibility keeps the $g$ term in charge whenever the two disagree.]


#heading(level: 3)[The Haversine heuristic]


Any heuristic should be cheap to compute and use the same units as the path cost. For kilometre-based routes, use the great-circle distance to the goal, whether or not a direct flight exists. The #strong[Haversine formula] computes it from latitude--longitude pairs: $ h \( n \) = 2 R thin arcsin #h(-1em) sqrt(sin^2 #h(-1em) frac(Delta phi, 2) + cos phi_n cos phi_(upright("goal")) sin^2 #h(-1em) frac(Delta lambda, 2)) $ with $R approx 6371$~km. The same formula gives every edge weight in the graph, so $h$ and $g$ are directly comparable. In Lab~2 the heuristic is a small function that fixes the goal and returns a function of the airport:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 36, last: 41, lang: "python")

`utils/core.py` accepts any state-to-number callable, so changing the heuristic requires no change to the search code.

Theory says Haversine is safe. Lab~2 checks it anyway: it runs Dijkstra backwards from each goal to get the exact cost $h^star.op$, samples ten airports across the range for each of three goals, and confirms $h lt.eq h^star.op$. In #ref(label("fig:admissible"), supplement: [Figure]), every sampled point must lie on or below the diagonal.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/c4e9ed7ab258e2a6.svg")], caption: [A heuristic plotted against the true remaining cost, with illustrative points. Admissibility requires every point to lie on or below the dashed line. The red points overestimate and void the A$""^star.op$ guarantee. The Haversine heuristic in Lab~2 produces only green points, with slack from 0 up to about 26,000~km.]) <fig:admissible>


#heading(level: 3)[Weighted A\*: trading the guarantee for speed]


Sometimes a good answer now beats the best answer later. #strong[Weighted A$""^star.op$] uses $g + w thin h$ with $w > 1$, deliberately giving up the guarantee for a more goal-directed search. The tripled guess above was weighted A$""^star.op$ with $w = 3$. At $w = 1.5$, Lab~2 uses two, three and four expansions, with routes 7.1 %, 0 % and 0.8 % above optimum. Inflating $h$ discourages useful detours away from the goal, so the cost changes exactly when the best route takes one.


#heading(level: 2)[A sharper guess means less work]


Not all admissible guesses are equally good. The 8-puzzle shows how much the quality of the guess matters. Here are two guesses for how many slides are left, both never overestimating:

/ Misplaced tiles.: #block[
Count the tiles not on their home square. Every misplaced tile needs at least one slide.
]

/ Tile distance.: #block[
Add up each tile's Manhattan distance from its home square. Every tile needs at least that many slides.
]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/ec7fc1a68d147f06.svg")], caption: [The board traced by `demo_sliding_puzzle.py`, next to the goal. Seven tiles are misplaced, so the weak guess is 7. The small orange number on each tile is its distance from home, and these add up to the sharper guess of 16. The true answer is 22 slides.]) <fig:puzzle-guess>

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Search on the traced board], [Guess at the start], [Slides returned], [States expanded],),
    table.hline(),
    [BFS, no guess], [---], [22], [89,296],
    [A$""^star.op$, misplaced tiles], [7], [22], [7,356],
    [A$""^star.op$, tile distance], [16], [22], [417],
  )]
  , kind: table
  )

Sixteen is much closer to the truth than seven, so A$""^star.op$ wastes far less time. Among admissible guesses, the larger the better: a guess that is closer to the true cost prunes more of the space without ever losing the guarantee.


#heading(level: 2)[UCS, GBFS and A\* side by side]


#figure(
  align(center)[#table(
    columns: 5,
    align: (left,left,left,left,left,),
    table.header([Method], [Priority], [Optimal?], [Rainy maze], [Behaviour in Lab~2],),
    table.hline(),
    [UCS], [$g \( n \)$], [Yes], [47 cells, 13 units], [Exact but blind: 1,851--3,042 expansions per query],
    [GBFS], [$h \( n \)$], [No], [13 cells, 19 units], [2--3 expansions; routes up to 9 % too long],
    [A$""^star.op$], [$g \( n \) + h \( n \)$], [Yes, if $h$ consistent], [28 cells, 13 units], [Same cost as UCS with 96 % fewer expansions],
    [Weighted A$""^star.op$], [$g \( n \) + w thin h \( n \)$], [No], [16 cells, 19 units ($w = 3$)], [2--4 expansions at $w = 1.5$; routes up to 7 % too long],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[A$""^star.op$ combines low effort with optimality because its heuristic is consistent. UCS explores without guidance; GBFS reduces effort but gives up the guarantee.]


#heading(level: 2)[Reading the lab's evidence]


`metrics.csv` records cost, hops, expansions, peak frontier, runtime and the #strong[optimality gap]: the percentage by which a route costs more than the UCS route. A$""^star.op$ has zero gap on every query, and any positive GBFS or weighted A$""^star.op$ gap is the measured price of speed. `heuristic_check.csv` compares $h$ with $h^star.op$ for thirty sampled airports. A single failed check would invalidate the admissibility claim.

#callout("chapterrecap", title: [Chapter recap])[- A heuristic $h \( n \)$ is a cheap guess of the cost left. $g \( n \)$ is what you have spent, and $f \( n \) = g \( n \) + h \( n \)$ estimates the whole trip.

- UCS, GBFS and A$""^star.op$ are one priority queue sorted by $g$, $h$ and $g + h$. GBFS is quick and can be badly wrong; A$""^star.op$ is both quick and correct.

- The one rule: an admissible heuristic never overestimates. Break it, as weighted A$""^star.op$ does on purpose, and speed comes at the price of the guarantee.

- Among admissible heuristics, the one closest to the true cost does the least work.]

#callout("quickcheck", title: [Check your understanding])[+ Which quantity does GBFS ignore that A$""^star.op$ uses, and which failure in Lab~2 does that explain?

+ Frontier states $X$ and $Y$ have $\( g \, h \) = \( 8 \, 2 \)$ and $\( 3 \, 6 \)$. Which does UCS expand first? GBFS? A$""^star.op$?

+ Why must $h$ be expressed in the same units as the edge costs?

+ Lab~2 computes $h^star.op$ by running Dijkstra on the #emph[reversed] graph from the goal. Why reversed?

+ Weighted A$""^star.op$ with $w = 1.5$ changed the cost for KUL$arrow.r$KEF but not for SIN$arrow.r$EZE. What property of the SIN$arrow.r$EZE route explains this?

+ On the rainy maze, cell $\( 3 \, 2 \)$ has $g = 7$ and $h = 8$. Why does A$""^star.op$ never expand it, even though it joined the frontier early?]
