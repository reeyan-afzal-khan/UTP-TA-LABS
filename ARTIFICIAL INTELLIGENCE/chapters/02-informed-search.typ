#import "/.shared/typst/utp.typ": *
#import "robot-maze-figures.typ": *
#unit("chapters", "02-informed-search")

= Informed Search: Greedy Best-First Search and A\* <ch:informed>

#chapterguide[Trace BFS, DFS and UCS (#chapref(<ch:uninformed>)) and explain what a priority queue does.][define a heuristic and compute $g$, $h$ and $f$ for a state; trace Greedy Best-First Search and A$""^(star.op)$; decide whether a heuristic is admissible and why that matters; explain why a sharper guess saves work; and read the effort-versus-quality trade-off in Lab~2’s tables.]

Look at where UCS went on the rainy maze. It spread evenly in every direction, even away from the charger, and expanded 47 of the 48 cells. It only counts the battery it has spent, so it has no idea which way the charger is. On the airline network the same blindness costs 1,851 expanded airports for the route from Kuala Lumpur to Keflavík.

If you were standing in that maze you would head towards the charger, because you can roughly see where it is. This chapter gives the search that same sense of direction: a #term[heuristic], a quick guess of how far is left. Lab~2 then measures what the guess does to search effort and to route quality.

== A guess of what is left

Give the robot a simple guess. For any cell, count the steps across plus the steps up or down to the charger, and pretend walls and puddles do not exist. From the robot’s cell at $(5,1)$ that is 8 columns across and 3 rows up, so its guess is 11. Do this for every cell and you get a number in each one, 0 on the charger and bigger further away (#figref(<fig:manhattan>)). In code it is one line:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/demo_robot_maze.py", first: 56, last: 58, lang: "python")

#utpfig([The guess for every cell: rows apart plus columns apart, ignoring what is in the way. The robot’s cell guesses 11, but the cheapest real route in the rain costs 13, because the guess cannot see walls or puddles.], label: <fig:manhattan>)[
  #canvas({
    mazegrid("h", mazeguess, size: 0.62, step: 4)
    mazepins("h", size: 0.62)
    node((rel: (0.45, 0), to: "h-3-9.east"), [#strong[Two everyday guesses] \ #v(2.9888pt)
   This count is the #term[Manhattan distance], named after counting blocks in a city laid out on a grid. \ #v(2.9888pt)
   On a map you would use the straight-line distance, #emph[as the crow flies]. Lab~2 uses that one for airports. It ignores what lies in the way, too.], anchor: "west", align: left, text-width: 5.6, font: font("small", fill: navy))
  })
]

A guess like this is written $h(n)$. It is quick to work out and it is only an estimate. A search that uses one is called #term[informed]; BFS and UCS, which have no guess, are #term[uninformed], or blind.

== Three quantities on one path

Every informed method reasons about a frontier state $n$ using up to three numbers:

#utptable[
  #tabularx(
    columns: (14%, 1fr, 20%),
    align: (center, left, center),
    styles: (navy-bold,),
    header: ([Quantity], [Meaning], [Used by]),
    [$g(n)$], [Exact cost of the cheapest known path from the start to $n$: what you have already spent], [UCS, A$""^(star.op)$],
    [$h(n)$], [Estimated cost from $n$ to the goal: a guess of what is left], [GBFS, A$""^(star.op)$],
    [$f(n)=g(n)+h(n)$], [Estimated total cost of a whole trip that passes through $n$], [A$""^(star.op)$],
  )
]

On a road trip, the odometer tells you how far you have driven and the map tells you roughly how far is left. The odometer is exact and backward-looking; it is $g$. The map is an estimate and forward-looking; it is $h$. Add them and you have a fair estimate of the whole trip, which is the number you would use to compare two possible routes.

#figref(<fig:fgh>) separates known cost from estimated remaining cost. UCS uses the former, GBFS the latter, and A$""^(star.op)$ both.

#utpfig([$f(n)=g(n)+h(n)$ combines known cost with estimated remaining cost. UCS prioritises $g$, GBFS $h$, and A$""^(star.op)$ their sum.], label: <fig:fgh>)[
  #canvas({
    let method = (rounded: 2mm, text-width: 2.75, min-height: 1.02, align: center, font: font("script", fill: navy), inner-sep: 1.5mm, line-width: 0.7472pt)
    node((0, 0), [S], name: "S", font: font("small"), ..utpnodedone, min-size: 0.9)
    node((4, 0), [$n$], name: "N", font: font("small"), ..utpnodehot, min-size: 0.9)
    node((8, 0), [G], name: "G", font: font("small"), ..utpnode, min-size: 0.9, fill: pale-teal, draw: green)
    connect("S", (1.15, 0.48), (2.55, -0.32), "N", ..utpedge, draw: blue, line-width: 1.2951pt)
    connect("N", "G", ..utpedge, draw: mix(muted, 55%), line-width: 1.1955pt, dash: "dashed")
    connect((-0.3, 0.92), (4, 0.92), ..utpbrace, draw: blue)
    connect((4, 0.92), (8.3, 0.92), ..utpbrace, draw: orange)
    node((1.85, 1.22), [$g(n)$ --- exact cost \
  from start to $n$], font: font("small"), ..utplabel, anchor: "south", align: center, text: blue)
    node((6.15, 1.22), [$h(n)$ --- estimated cost \
  from $n$ to goal], font: font("small"), ..utplabel, anchor: "south", align: center, text: orange)
    node((0.75, -1.65), [#strong[UCS] \
  priority $g(n)$ \
  actual cost only], name: "ucs", font: font("small"), ..method, draw: blue, fill: pale-blue)
    node((4, -1.65), [#strong[GBFS] \
  priority $h(n)$ \
  estimate only], name: "gbfs", font: font("small"), ..method, draw: orange, fill: pale-orange)
    node((7.25, -1.65), [#strong[A\*] \
  priority $f(n)=g(n)+h(n)$ \
  combines both], name: "astar", font: font("small"), ..method, draw: green, fill: pale-teal)
  })
]

== Greedy best-first search: go where it looks closest

The simplest way to use the guess is to take the cell whose guess is smallest, the one that #emph[looks] closest to the charger. That is #term[Greedy Best-First Search (GBFS)]: best-first because it always explores the best-looking cell, greedy because it only cares about getting closer right now. It uses the same priority queue as UCS. Only the number changes: UCS sorts by $g$, GBFS by $h$.

Walk it on the rainy maze. From the robot, the cells above and to the right both guess 10, and the one above joined first, so GBFS goes up. It climbs to $(2,1)$ on the charger’s row, where the guess is 8, and meets a wall. The next best-looking cell is $(3,2)$, also guessing 8, so it steps straight into the first puddle without noticing and runs along the corridor from there, every step bringing the guess down by one. It never looks at the bottom of the maze.

GBFS reaches the charger after expanding only 13 cells, the least work of anything so far. But its route is the middle corridor at 19 units of battery, and the robot runs dry four cells short. GBFS looks only at what is left. It never counts what it has already spent.

#example[
  On the airline network GBFS expands two airports for `KUL -> LHR -> KEF`: 12,500~km, 9 % above the optimum. London looks close to Iceland, but the first leg alone exceeds the optimal route through Phuket, St Petersburg and Helsinki. Its `NRT`$arrow.r$`CPT` route is 6.7 % too long, and its `SIN`$arrow.r$`EZE` route happens to be optimal.
]

#warning[
  Because GBFS ignores $g$, a small $h$ can conceal an expensive path. How good its route is depends on what the graph looks like around the goal, so one good result proves nothing about the next query.
]

== A\* search: what you spent plus what is left

Neither search does both jobs. UCS gets the robot home but looks at every cell. GBFS heads straight for the charger but runs out of battery. UCS counts what is spent, $g$. GBFS guesses what is left, $h$. So add them up, $f(n)=g(n)+h(n)$, and take the cell with the smallest $f$. That is #term[A$""^(star.op)$], the same priority queue again, sorted by a third number. In `utils/core.py` the three algorithms share `best_first`, and these lines are all that separates them:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 104, last: 109, lang: "python")

#figref(<fig:astar-cells>) shows how to read the three numbers on a cell. Follow the first few picks on the rainy maze, keeping an eye on $(3,2)$.

#utpfig([Four cells from the first picks of A$""^(star.op)$ on the rainy maze. The big number is $f$, the sum of $g$ (top left) and $h$ (top right). Stepping into the puddle at $(3,2)$ costs 5, so its $f$ jumps to 15 and it waits behind every cell with $f=13$.], label: <fig:astar-cells>)[
  #canvas({
    node((0, 0), [], name: "a", font: font("small"), draw: orange, fill: pale-orange, min-width: 1.92, min-height: 1.55, inner-sep: 0pt)
    node("a.north-west", [$g=0$], anchor: "north-west", font: font("script", fill: blue), inner-sep: 2.4907pt)
    node("a.north-east", [$h=11$], anchor: "north-east", font: font("script", fill: mix(orange, 85%, other: black)), inner-sep: 2.4907pt)
    node((rel: (0, -0.16), to: "a.center"), [11], font: font("large", weight: "bold", fill: navy))
    node("a.south", [robot’s cell \
  $(5,1)$], font: font("small"), ..utplabel, anchor: "north", align: center)
    node((2.25, 0), [], name: "b", font: font("small"), draw: mix(blue, 55%), fill: pale-blue, min-width: 1.92, min-height: 1.55, inner-sep: 0pt)
    node("b.north-west", [$g=1$], anchor: "north-west", font: font("script", fill: blue), inner-sep: 2.4907pt)
    node("b.north-east", [$h=10$], anchor: "north-east", font: font("script", fill: mix(orange, 85%, other: black)), inner-sep: 2.4907pt)
    node((rel: (0, -0.16), to: "b.center"), [11], font: font("large", weight: "bold", fill: navy))
    node("b.south", [one step right \
  $(5,2)$], font: font("small"), ..utplabel, anchor: "north", align: center)
    node((4.5, 0), [], name: "c", font: font("small"), draw: mix(blue, 55%), fill: pale-blue, min-width: 1.92, min-height: 1.55, inner-sep: 0pt)
    node("c.north-west", [$g=2$], anchor: "north-west", font: font("script", fill: blue), inner-sep: 2.4907pt)
    node("c.north-east", [$h=11$], anchor: "north-east", font: font("script", fill: mix(orange, 85%, other: black)), inner-sep: 2.4907pt)
    node((rel: (0, -0.16), to: "c.center"), [13], font: font("large", weight: "bold", fill: navy))
    node("c.south", [then one down \
  $(6,2)$], font: font("small"), ..utplabel, anchor: "north", align: center)
    node((6.75, 0), [], name: "d", font: font("small"), draw: teal, fill: mix(teal, 30%), min-width: 1.92, min-height: 1.55, inner-sep: 0pt)
    node("d.north-west", [$g=7$], anchor: "north-west", font: font("script", fill: blue), inner-sep: 2.4907pt)
    node("d.north-east", [$h=8$], anchor: "north-east", font: font("script", fill: mix(orange, 85%, other: black)), inner-sep: 2.4907pt)
    node((rel: (0, -0.16), to: "d.center"), [15], font: font("large", weight: "bold", fill: navy))
    node("d.south", [first puddle \
  $(3,2)$: $g=2+5$], font: font("small"), ..utplabel, anchor: "north", align: center)
    node((8, 0), [#strong[Along the bottom row] every step adds 1 to $g$ and takes 1 off $h$, so $f$ stays at 13 all the way. A$""^(star.op)$ follows it and never expands the puddle.], anchor: "west", align: left, text-width: 4.5, font: font("script", fill: navy))
  })
]

#example[
  The first five picks of A$""^(star.op)$. Each cell added to the frontier is shown with its $f$.

  #v(6pt)

  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    header: ([Pick], [Its $f$], [Added to the frontier (with $f$)]),
    [$(5,1)$], [11], [$(4,1)$ 11,  $(5,2)$ 11,  $(6,1)$ 13,  $(5,0)$ 13],
    [$(4,1)$], [11], [$(3,1)$ 11,  $(4,0)$ 13],
    [$(5,2)$], [11], [$(6,2)$ 13],
    [$(3,1)$], [11], [$(2,1)$ 11,  $(3,2)$ #strong[15] (the puddle)],
    [$(2,1)$], [11], [$(1,1)$ 13,  $(2,0)$ 13],
  )

  #raggedright[
  #v(6pt)
  The frontier now holds several cells with $f=13$ and one with $f=15$. A$""^(star.op)$ clears every 13 first, and those cells lead along the bottom row to the charger.
  ]]]
]

A$""^(star.op)$ reaches the charger with $g=13$. That is the route UCS found, but A$""^(star.op)$ expanded only 28 cells instead of 47 (#figref(<fig:expansion>)).

#utpfig([The rainy maze solved three ways, with the same battery of 15. Blue cells were expanded. UCS spreads everywhere and finds the 13-unit route. GBFS barely explores, but its route costs 19 and the robot runs dry. A$""^(star.op)$ finds the 13-unit route and leaves the top and the corridor alone.], label: <fig:expansion>)[
  #canvas({
    draw.scope({
      node((1.8, 0.48), [UCS (sorts on $g$)], ..mztitle)
      mazegrid("u", mazeucs, size: 0.4)
      mazeroute("u", routebottom)
      mazepins("u", size: 0.4)
      node((1.8, -2.65), [47 expanded, 13 units], ..mznote, anchor: "north")
    })
    draw.scope({
      draw.translate((5.2, 0))
      node((1.8, 0.48), [GBFS (sorts on $h$)], ..mztitle)
      mazegrid("g", mazegreedy, size: 0.4)
      mazeroute("g", routecorridor, ..mzroutebad)
      mazepins("g", size: 0.4)
      node((1.8, -2.65), [13 expanded, 19 units: runs dry], ..mznote, anchor: "north")
    })
    draw.scope({
      draw.translate((10.4, 0))
      node((1.8, 0.48), [A\* (sorts on $g+h$)], ..mztitle)
      mazegrid("a", mazeastar, size: 0.4)
      mazeroute("a", routebottom)
      mazepins("a", size: 0.4)
      node((1.8, -2.65), [28 expanded, 13 units], ..mznote, anchor: "north")
    })
  })
]

Why did A$""^(star.op)$ get to skip so much? Colour every cell by the best $f$ it can have, using the cheapest way to reach it (#figref(<fig:fmap>)). A$""^(star.op)$ expanded exactly the cells with $f <= 13$, and every cell it skipped has $f >= 15$. The guess never exceeds the real remaining cost, because walls can only make a route longer and puddles can only make it dearer. So any route through a skipped cell costs at least 15, more than the 13 already in hand, and there was never a reason to look.

#utpfig([Each cell shows the best possible $f=g+h$ on the rainy maze. Blue cells have $f <= 13$ and are exactly the ones A$""^(star.op)$ expanded. Grey cells have $f >= 15$: any route through them must cost at least that, so with a 13-unit route in hand they can be ignored.], label: <fig:fmap>)[
  #canvas({
    let drawnumber(prefix, r, c, v, s) = {
      if v > 13 {
        node((s * c, -s * r), [#v], name: prefix + "-" + str(r) + "-" + str(c), ..mzcell(s), draw: mix(muted, 45%), fill: pale-gray, font: font("script", fill: muted))
      } else {
        node((s * c, -s * r), [#v], name: prefix + "-" + str(r) + "-" + str(c), ..mzcell(s), draw: mix(blue, 50%), fill: mix(blue, 24%))
      }
    }
    mazegrid("f", mazef, size: 0.62, number: drawnumber)
    mazeroute("f", routebottom)
    mazelabels("f", mazef)
    mazepins("f", size: 0.62)
    node((rel: (0.45, 0), to: "f-3-9.east"), [#strong[A$""^(star.op)$’s trick] \ #v(2.9888pt)
   What you have spent plus a guess of what is left that never runs high. A$""^(star.op)$ only explores cells that could still lie on the cheapest route.], anchor: "west", align: left, text-width: 5.6, font: font("small", fill: navy))
  })
]

#note[
  GBFS asks which frontier state #emph[looks] closest to the goal. A$""^(star.op)$ also accounts for the cost already paid and, with a suitable heuristic, guarantees the cheapest path.
]

#example[
  Suppose frontier state $X$ has $(g,h)=(5,3)$ and $Y$ has $(1,5)$. GBFS chooses $X$ because $3<5$. A$""^(star.op)$ chooses $Y$ because $f(Y)=6<f(X)=8$: the cheaper path so far is worth the extra estimated distance.
]

#note[
  Peter Hart, Nils Nilsson and Bertram Raphael published A$""^(star.op)$ in 1968 at the Stanford Research Institute. They developed it for Shakey, one of the first mobile robots able to plan its own actions. Their example heuristic for cities joined by roads was the airline distance, the same as-the-crow-flies guess you will use in Lab~2. A$""^(star.op)$ with $h=0$ is exactly UCS, so A$""^(star.op)$ is Dijkstra’s algorithm with a guess added.
]

== The one rule: never overestimate

The guess made A$""^(star.op)$ faster, so why not trust it even more? Multiply every guess by three. On the robot’s cell the guess of 11 becomes 33, far above the real cost of 13, and from every cell A$""^(star.op)$ now believes the charger is much further away than it is. The tripled guess is so much bigger than the battery spent that it decides almost every pick. A$""^(star.op)$ heads straight for the charger like GBFS, expands only 16 cells, and returns the 19-unit corridor. The robot runs dry again (#figref(<fig:triple>)).

#utpfig([A$""^(star.op)$ on the rainy maze with the honest guess and with the guess multiplied by three. Trusting the guess too much saves 12 expansions and loses the cheapest route.], label: <fig:triple>)[
  #canvas({
    draw.scope({
      node((2.16, 0.5), [$f=g+h$], ..mztitle)
      mazegrid("a", mazeastar, size: 0.48)
      mazeroute("a", routebottom)
      mazepins("a", size: 0.48)
      node((2.16, -3.15), [28 expanded, 13 units, reaches the charger], ..mznote, anchor: "north")
    })
    draw.scope({
      draw.translate((7, 0))
      node((2.16, 0.5), [$f=g+3 h$], ..mztitle)
      mazegrid("t", mazetriple, size: 0.48)
      mazeroute("t", routecorridor, ..mzroutebad)
      mazepins("t", size: 0.48)
      node((2.16, -3.15), [16 expanded, 19 units, runs dry], ..mznote, anchor: "north")
    })
  })
]

=== Admissibility and consistency

So there is one rule. A heuristic is #term[admissible] when it never overestimates the cheapest remaining cost:

$ h(n) med <= med h^(star.op)(n) quad "for every state " n, $

where $h^(star.op)(n)$ is the true cost of the cheapest path from $n$ to the goal. If that holds, A$""^(star.op)$ is guaranteed to return a cheapest path. Our Manhattan guess qualifies: on the robot’s cell it is 11 against a true 13.

A stronger and more convenient condition is #term[consistency]: for every edge $n arrow.r n'$ of cost $c$, $h(n) <= c+h(n')$. In words, one step cannot make the guess drop by more than the step cost. Consistency implies admissibility and guarantees that the first time A$""^(star.op)$ pops a state, it has found the cheapest path to it, which is what allows the closed-set implementation in `utils` to skip re-expansions. Its picture is the triangle inequality (#figref(<fig:triangle>)).

#utpfig([The direct line from $n$ to the goal can never be longer than going via $n'$ first. The same is true on a sphere, which is why the great-circle distance is a consistent heuristic for airline routes: no sequence of flights can beat flying straight there.], label: <fig:triangle>)[
  #canvas({
    node((0, 0), [$n$], name: "N", font: font("small"), ..utpnodehot, min-size: 0.8)
    node((3.1, 1.55), [$n'$], name: "P", font: font("small"), ..utpnode, min-size: 0.8)
    node((6.2, 0), [G], name: "G", font: font("small"), ..utpnodedone, min-size: 0.8)
    connect("N", "P", ..utpptr, draw: blue, line-width: 0.9963pt)
    node(along("N", "P", t: 50%), [$c$: one real flight], font: font("small"), ..utplabel, text: blue, anchor: "south-east")
    connect("P", "G", ..utpptr, draw: orange, dash: "dashed", line-width: 0.9963pt)
    node(along("P", "G", t: 50%), [$h(n')$: straight line], font: font("small"), ..utplabel, text: mix(orange, 85%, other: black), anchor: "south-west")
    connect("N", "G", ..utpptr, draw: orange, dash: "dashed", line-width: 0.9963pt)
    node(along("N", "G", t: 50%), [$h(n)$: straight line], font: font("small"), ..utplabel, text: mix(orange, 85%, other: black), anchor: "north")
    node((7.2, 0.7), [$h(n) space <= space c+h(n')$], anchor: "west", font: font("small", fill: navy))
  })
]

#note[
  An inadmissible heuristic makes A$""^(star.op)$ behave like GBFS: it trusts the estimate too much and commits to a branch before the cost evidence justifies it. Admissibility keeps the $g$ term in charge whenever the two disagree.
]

=== The Haversine heuristic

Any heuristic should be cheap to compute and use the same units as the path cost. For kilometre-based routes, use the great-circle distance to the goal, whether or not a direct flight exists. The #term[Haversine formula] computes it from latitude--longitude pairs:

$ h(n)=2 R thin arcsin sqrt(sin ^2 inline(frac(Delta phi, 2))+cos phi _n cos phi _("goal")sin ^2 inline(frac(Delta lambda, 2))) $

with $R approx 6371$~km. The same formula gives every edge weight in the graph, so $h$ and $g$ are directly comparable. In Lab~2 the heuristic is a small function that fixes the goal and returns a function of the airport:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 36, last: 41, lang: "python")

`utils/core.py` accepts any state-to-number callable, so changing the heuristic requires no change to the search code.

Theory says Haversine is safe. Lab~2 checks it anyway: it runs Dijkstra backwards from each goal to get the exact cost $h^(star.op)$, samples ten airports across the range for each of three goals, and confirms $h <= h^(star.op)$. In #figref(<fig:admissible>), every sampled point must lie on or below the diagonal.

#utpfig([A heuristic plotted against the true remaining cost, with illustrative points. Admissibility requires every point to lie on or below the dashed line. The red points overestimate and void the A$""^(star.op)$ guarantee. The Haversine heuristic in Lab~2 produces only green points, with slack from 0 up to about 26,000~km.], label: <fig:admissible>)[
  #canvas({
    axis(width: 9.9572cm, height: 5.4cm, xlabel: [true remaining cost $h^(star.op)(n)$], ylabel: [heuristic $h(n)$], xmin: 0, xmax: 7, ymin: 0, ymax: 7.6, xtick: (0, 1, 2, 3, 4, 5, 6, 7), ytick: (0, 2, 4, 6), axis-lines: "left", grid: "major", grid-style: (draw: pale-blue), clip: false,
      addplot(draw: muted, dash: "dashed", line-width: widths.thick, coords: ((0, 0), (7, 7))),
      addplot(only-marks: true, mark: "*", mark-size: 2.391pt, draw: red, coords: ((4, 7), (3, 6), (1, 2))),
      addplot(only-marks: true, mark: "*", mark-size: 2.391pt, draw: green, coords: ((6, 4), (2, 2), (0, 0), (5, 3.2), (3.5, 1.8))),
      {
        node((4.4, 4.1), [$h=h^(star.op)$], font: font("script", fill: muted), anchor: "west")
        node((0.3, 6.2), [above the line: \
  overestimates], font: font("script", fill: red), anchor: "west", align: left)
        node((4.6, 1.4), [on or below: \
  admissible], font: font("script", fill: green), anchor: "west", align: left)
      },
    )
  })
]

=== Weighted A\*: trading the guarantee for speed

Sometimes a good answer now beats the best answer later. #term[Weighted A$""^(star.op)$] uses $g+w thin h$ with $w>1$, deliberately giving up the guarantee for a more goal-directed search. The tripled guess above was weighted A$""^(star.op)$ with $w=3$. At $w=1.5$, Lab~2 uses two, three and four expansions, with routes 7.1 %, 0 % and 0.8 % above optimum. Inflating $h$ discourages useful detours away from the goal, so the cost changes exactly when the best route takes one.

== A sharper guess means less work

Not all admissible guesses are equally good. The 8-puzzle shows how much the quality of the guess matters. Here are two guesses for how many slides are left, both never overestimating:

/ Misplaced tiles.: Count the tiles not on their home square. Every misplaced tile needs at least one slide.
/ Tile distance.: Add up each tile’s Manhattan distance from its home square. Every tile needs at least that many slides.

#utpfig([The board traced by `demo_sliding_puzzle.py`, next to the goal. Seven tiles are misplaced, so the weak guess is 7. The small orange number on each tile is its distance from home, and these add up to the sharper guess of 16. The true answer is 22 slides.], label: <fig:puzzle-guess>)[
  #canvas({
    let tile = (..utpcell, min-width: 0.92, min-height: 0.92, font: font("normal", weight: "bold", fill: navy))
    let gap = (..utpdim, min-width: 0.92, min-height: 0.92)
    let away = (shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
    node((0.92, 0.85), [Traced board], font: font("small"), ..mztitle)
    for (t, d, c, r) in ((8, 3, 0, 0), (2, 0, 1, 0), (6, 2, 0, 1), (1, 2, 1, 1), (7, 3, 2, 1), (4, 1, 0, 2), (3, 3, 1, 2), (5, 2, 2, 2)) {
      node((0.92 * c, -0.92 * r), [#t], name: "t" + str(t), font: font("small"), ..tile)
      node((rel: (-0.13, -0.13), to: "t" + str(t) + ".north-east"), [#d], font: font("small"), ..away)
    }
    node((1.84, 0), [], font: font("small"), ..gap)
    node((5.72, 0.85), [Goal], font: font("small"), ..mztitle)
    for (t, c, r) in ((1, 0, 0), (2, 1, 0), (3, 2, 0), (4, 0, 1), (5, 1, 1), (6, 2, 1), (7, 0, 2), (8, 1, 2)) {
      node((4.8 + 0.92 * c, -0.92 * r), [#t], ..utpdone, min-width: 0.92, min-height: 0.92, font: font("normal", weight: "bold", fill: navy))
    }
    node((6.64, -1.84), [], font: font("small"), ..gap)
    node((7.9, -0.92), [Tile distance: $3+0+2+2+3+1+3+2=16$. \ #v(2.9888pt)
   Misplaced: every tile except 2, so 7. \ #v(2.9888pt)
   Both are below the true 22, so both are admissible, and A$""^(star.op)$ finds a 22-slide solution with either.], anchor: "west", align: left, text-width: 5.2, font: font("script", fill: navy))
  })
]

#utptable[
  #tabularx(
    columns: (34%, 1fr, 1fr, 1fr),
    align: (left, center, center, center),
    styles: (navy-bold,),
    header: ([Search on the traced board], [Guess at the start], [Slides returned], [States expanded]),
    [BFS, no guess], [---], [22], [89,296],
    [A$""^(star.op)$, misplaced tiles], [7], [22], [7,356],
    [A$""^(star.op)$, tile distance], [16], [22], [417],
  )
]

Sixteen is much closer to the truth than seven, so A$""^(star.op)$ wastes far less time. Among admissible guesses, the larger the better: a guess that is closer to the true cost prunes more of the space without ever losing the guarantee.

== UCS, GBFS and A\* side by side

#utptable[
  #tabularx(
    columns: (14%, 14%, 16%, 17%, 1fr),
    align: (center, center, center, center, left),
    styles: (navy-bold,),
    header: ([Method], [Priority], [Optimal?], [Rainy maze], [Behaviour in Lab~2]),
    [UCS], [$g(n)$], [Yes], [47 cells, 13 units], [Exact but blind: 1,851--3,042 expansions per query],
    [GBFS], [$h(n)$], [No], [13 cells, 19 units], [2--3 expansions; routes up to 9 % too long],
    [A$""^(star.op)$], [$g(n)+h(n)$], [Yes, if $h$ consistent], [28 cells, 13 units], [Same cost as UCS with 96 % fewer expansions],
    [Weighted A$""^(star.op)$], [$g(n)+w thin h(n)$], [No], [16 cells, 19 units ($w=3$)], [2--4 expansions at $w=1.5$; routes up to 7 % too long],
  )
]

#note[
  A$""^(star.op)$ combines low effort with optimality because its heuristic is consistent. UCS explores without guidance; GBFS reduces effort but gives up the guarantee.
]

== Reading the lab’s evidence

`metrics.csv` records cost, hops, expansions, peak frontier, runtime and the #term[optimality gap]: the percentage by which a route costs more than the UCS route. A$""^(star.op)$ has zero gap on every query, and any positive GBFS or weighted A$""^(star.op)$ gap is the measured price of speed. `heuristic_check.csv` compares $h$ with $h^(star.op)$ for thirty sampled airports. A single failed check would invalidate the admissibility claim.

#summary[
  - A heuristic $h(n)$ is a cheap guess of the cost left. $g(n)$ is what you have spent, and $f(n)=g(n)+h(n)$ estimates the whole trip.
  - UCS, GBFS and A$""^(star.op)$ are one priority queue sorted by $g$, $h$ and $g+h$. GBFS is quick and can be badly wrong; A$""^(star.op)$ is both quick and correct.
  - The one rule: an admissible heuristic never overestimates. Break it, as weighted A$""^(star.op)$ does on purpose, and speed comes at the price of the guarantee.
  - Among admissible heuristics, the one closest to the true cost does the least work.
]

#questions[
  + Which quantity does GBFS ignore that A$""^(star.op)$ uses, and which failure in Lab~2 does that explain?
  + Frontier states $X$ and $Y$ have $(g,h)=(8,2)$ and $(3,6)$. Which does UCS expand first? GBFS? A$""^(star.op)$?
  + Why must $h$ be expressed in the same units as the edge costs?
  + Lab~2 computes $h^(star.op)$ by running Dijkstra on the #emph[reversed] graph from the goal. Why reversed?
  + Weighted A$""^(star.op)$ with $w=1.5$ changed the cost for KUL$arrow.r$KEF but not for SIN$arrow.r$EZE. What property of the SIN$arrow.r$EZE route explains this?
  + On the rainy maze, cell $(3,2)$ has $g=7$ and $h=8$. Why does A$""^(star.op)$ never expand it, even though it joined the frontier early?
]
