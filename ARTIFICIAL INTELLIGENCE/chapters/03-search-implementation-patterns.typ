#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-search-implementation-patterns")

= Search Engineering: One Loop, Five Algorithms, Tested <ch:searchpatterns>

#chapterguide[Know what BFS, DFS, UCS, GBFS and A$""^(star.op)$ each optimise (#chapsref(<ch:uninformed>, <ch:informed>)).][explain why the five algorithms are one loop with a pluggable frontier; read and extend the `utils` package; write a unit test for a search function; run the toolkit from the command line; and design a benchmark whose numbers can be compared fairly.]

You have now met five searches, and every one of them is the same loop with its own answer to one question: #emph[what do we look at next?] A programmer should find that suspicious in a useful way, because a single idea written out five times is five places for bugs to hide. Lab~3 turns the search code from Labs~1--2 into reusable software: a package with a common interface, tests you can check by hand, a command-line interface and a broader benchmark.

== The pluggable frontier

The graph supplies states and successors, and the query supplies the goal test. The frontier policy alone determines the algorithm (#figref(<fig:pluggable>)).

#analogy[
  Think of a battery drill. The motor, the handle and the trigger stay the same, and you change what it does by swapping the bit. The search loop is the drill. The frontier policy is the bit.
]

#utpfig([States, successors and the goal test come from the problem. The frontier policy determines the search algorithm.], label: <fig:pluggable>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.7, min-height: 0.9, align: center, font: font("small", weight: "bold", fill: navy))
    let policy = (draw: mix(orange, 70%, other: black), fill: pale-orange, rounded: 1.5mm, min-width: 1.55, min-height: 0.65, align: center, font: font("script", weight: "bold", fill: mix(orange, 85%, other: black)))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [State \
  representation], name: "state", ..box-style)
    node(right-of("state", 0.7), [Successor \
  function], name: "succ", ..box-style)
    node(right-of("succ", 0.7), [Frontier \
  policy], name: "frontier", ..box-style)
    node(right-of("frontier", 0.7), [Goal test \
  and result], name: "result", ..box-style)
    connect("state", "succ", ..arr)
    connect("succ", "frontier", ..arr)
    connect("frontier", "result", ..arr)
    node(below-of("frontier", 0.75), [BFS: depth], name: "bfs", ..policy, xshift: -3.2cm)
    node(right-of("bfs", 0.18), [DFS: recency], name: "dfs", ..policy)
    node(right-of("dfs", 0.18), [UCS: $g$], name: "ucs", ..policy)
    node(right-of("ucs", 0.18), [GBFS: $h$], name: "gbfs", ..policy)
    node(right-of("gbfs", 0.18), [A\*: $g+h$], name: "astar", ..policy)
    connect("ucs.north", "frontier.south", ..arr)
    node((0.55, -2.35), [swap one line $arrow.r$ different algorithm], font: font("script", fill: muted))
  })
]

In `utils/core.py`, BFS and DFS use `popleft` and `pop`, respectively. UCS, GBFS and A$""^(star.op)$ wrap `best_first`, whose `mode` selects the priority. Weighted A$""^(star.op)$ reuses it with the heuristic multiplied by 1.5.

#utptable[
  #tabularx(
    columns: (12%, 30%, 1fr),
    styles: (navy-bold,),
    header: ([Algorithm], [Frontier structure], [Entry and priority]),
    [BFS], [`collections.deque`], [state; oldest first],
    [DFS], [Python list as a stack], [state; newest first],
    [UCS], [`heapq` min-heap], [`(g, counter, state, g)`],
    [GBFS], [`heapq` min-heap], [`(h(state), counter, state, g)`],
    [A$""^(star.op)$], [`heapq` min-heap], [`(g + h(state), counter, state, g)`],
  )
]

== One result type for every algorithm

Every algorithm returns the same frozen dataclass, which lets one benchmark loop compare them all:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 17, last: 30, lang: "python")

Three design decisions are hidden in those seven fields.

/ The cost is recomputed from the path.: A helper sums edge weights after the search rather than reusing its stored $g$, which keeps `path_cost_km` consistent with the path actually returned.
/ Failure has a shape.: An unreachable goal returns `found=False`, an empty path, `hops=-1` and infinite cost. Callers check `result.found` instead of catching an exception.
/ Effort is part of the answer.: `expanded` and `max_frontier` are counted inside the loop, so every comparison in Labs 1--3 comes from the same counters.

`as_dict()` converts a result into a pandas row via `{**result.as_dict()}`, as used in every lab metrics file.

== Separating responsibilities

`utils` has five working modules, and each knows nothing about the others’ concerns (#figref(<fig:domains>)). A well-run kitchen works the same way: the person who sources the vegetables does not need to know the recipes, and the cook does not need to know the supplier.

#utptable[
  #tabularx(
    columns: (20%, 1fr),
    styles: (navy-bold,),
    header: ([Module], [Responsibility]),
    [`core.py`], [The five algorithms and `SearchResult`. Works on any `{state: [(neighbour, cost)]}` dictionary; never mentions airports.],
    [`openflights.py`], [Reads the two CSV files, cleans them, computes Haversine distances, returns the graph. Never searches.],
    [`plotting.py`], [Draws routes on longitude/latitude axes.],
    [`__main__.py`], [The command-line interface: parses arguments, loads the graph, calls one algorithm, prints.],
    [`test_search.py`], [The unit tests, on graphs of four to five states. Calls the search functions only.],
  )
]

#utpfig([Graph-specific loaders below the dashed line produce `{state: [(neighbour, cost)]}` dictionaries for shared search code above it. Every search number in Chapters~@ch:uninformed to~@ch:searchpatterns came through this one boundary.], label: <fig:domains>)[
  #canvas({
    node((0, 1.5), [#strong[`core.py`: the shared search loop]   frontier $dot.op$ seen set $dot.op$ goal test $dot.op$ path building], name: "shared", font: font("small"), ..utpbox, fill: pale-teal, draw: green, min-width: 12.6, min-height: 1)
    connect((-6.5, 0.72), (6.5, 0.72), dash: "dashed", draw: mix(muted, 70%))
    node((6.45, 0.55), [domain boundary], font: font("small"), ..utplabel, anchor: "east", text: muted)
    node((-4.8, -0.75), [#strong[OpenFlights] \ #v(1.9925pt)
  `openflights.py` \
  6,464 airports \
  Haversine costs], name: "of", ..utpbox, min-width: 2.85, min-height: 1.45, align: center, font: font("script", fill: navy))
    connect("of.north", ("of.north", "|-", "shared.south"), ..utparrow)
    node((-1.6, -0.75), [#strong[Hand-made graph] \ #v(1.9925pt)
  `test_search.py` \
  4--5 states \
  costs chosen by hand], name: "ty", ..utpbox, min-width: 2.85, min-height: 1.45, align: center, font: font("script", fill: navy))
    connect("ty.north", ("ty.north", "|-", "shared.south"), ..utparrow)
    node((1.6, -0.75), [#strong[Robot maze] \ #v(1.9925pt)
  `demo_robot_maze.py` \
  48 cells, 4 moves \
  battery costs], name: "rd", ..utpbox, min-width: 2.85, min-height: 1.45, align: center, font: font("script", fill: navy))
    connect("rd.north", ("rd.north", "|-", "shared.south"), ..utparrow)
    node((4.8, -0.75), [#strong[8-puzzle] \ #v(1.9925pt)
  `demo_sliding_puzzle.py` \
  181,440 boards \
  1 per slide], name: "gd", ..utpbox, min-width: 2.85, min-height: 1.45, align: center, font: font("script", fill: navy))
    connect("gd.north", ("gd.north", "|-", "shared.south"), ..utparrow)
    node((0, -1.85), [four graph sources, one identical caller], font: font("small"), ..utplabel, anchor: "north", align: center, text: muted)
  })
]

A road network would need a new loader, not new search code or tests. A new algorithm changes `core.py`, not the loader, CLI or benchmark. Lab~3 asks you to identify this boundary.

== Priority queues and tuple ordering

Python’s `heapq` pops the smallest tuple, comparing element by element from the left. The frontier entries in `best_first` are `(priority, counter, state, g)`, and the `counter` is there for a reason (#figref(<fig:tuple>)).

#utpfig([Heap tuples compare left to right. A unique counter breaks priority ties by insertion order, avoiding comparisons between states.], label: <fig:tuple>)[
  #canvas({
    for (a, b, c, y) in ((4, 17, "'LED'", 0.7), (4, 23, "'HEL'", 0)) {
      node((0, y), [#a], ..utphot, min-width: 1, min-height: 0.6, font: font("script", weight: "bold"))
      node((1.15, y), [#b], ..utpcell, min-width: 1, min-height: 0.6, font: font("script", weight: "bold"))
      node((2.9, y), [#c], ..utpcell, min-width: 2.3, min-height: 0.6, font: font("script", family: "mono"))
    }
    node((0, 1.12), [priority], font: font("small"), ..utplabel, anchor: "south")
    node((1.15, 1.12), [counter], font: font("small"), ..utplabel, anchor: "south")
    node((2.9, 1.12), [state], font: font("small"), ..utplabel, anchor: "south")
    brace((-0.55, -0.36), (-0.55, 1.06), amplitude: 3.4869pt, raise: 1.9925pt, draw: red, line-width: widths.semithick)
    node((-0.85, 0.35), [tie \
  here], font: font("small"), ..utplabel, anchor: "east", align: right, text: red)
    connect((1.15, -0.42), (1.15, -0.75), ..utpptr, draw: green)
    node((1.15, -0.78), [so the counter decides], font: font("small"), ..utplabel, anchor: "north", text: green)
    node((4.4, 0.35), [Without the counter the heap would compare the states. Strings compare, so airports happen to work, but a dictionary state or a mixed type raises `TypeError`, and even when it works the tie is broken by name rather than by the search.], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
  })
]

#pitfall[
  Placing a payload directly after the priority makes ties depend on payload comparisons, and possibly on state names. Insert a unique increasing counter to resolve ties by insertion order without comparing payloads.
]

== Testing search code

A successful run on 6,464 airports can hide wrong costs, wrong expansion counts or broken cycle handling, because nobody can check those answers by eye. Tiny graphs make such errors checkable by hand. `utils/test_search.py` contains eight tests, one per way a search can fail:

#utptable[
  #tabularx(
    columns: (34%, 1fr),
    styles: (navy-bold,),
    header: ([Test], [What a failure would mean]),
    [start equals goal], [The goal test runs before any expansion; hops and cost are zero.],
    [unreachable goal], [Failure is reported as `found=False`, not an exception or a wrong path.],
    [cycles terminate], [The seen set stops DFS from looping forever.],
    [BFS and UCS optimise different objectives], [The two algorithms give different answers on a graph built so that they must.],
    [frontier update finds the cheaper path], [A state first reached expensively is later replaced by a cheaper route.],
    [A$""^(star.op)$ matches UCS with a consistent heuristic], [The optimality guarantee holds on a hand-checked graph.],
    [GBFS is not assumed optimal], [The test asserts the #emph[expected] suboptimality rather than pretending it away.],
    [negative cost is rejected], [The precondition of UCS is enforced with a clear error.],
  )
]

One test in full shows the pattern: a tiny graph, an expectation worked out by hand, and an assertion.

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/test_search.py", first: 38, last: 42, lang: "python")

Walk it through. From A, the direct edge reaches B at cost 10, while the route through C reaches B at cost 2, then G at cost 3. UCS first records B at 10, finds the cheaper way, and replaces it. If that update were broken, the test would return a path costing 11 and fail immediately. The tests need no dataset, run in under a second, and work on any machine or continuous-integration server.

#keyidea[
  Test the algorithm on the smallest graph that can expose the bug, and test the dataset loader separately. A test that needs real data tests both at once and diagnoses neither.
]

== A command-line interface

`utils/__main__.py` makes the package runnable outside a notebook:

```terminal
cd all_experiments
python -m utils --algorithm astar --start KUL --goal KEF
ASTAR: found=True, hops=4, cost_km=11461.3, expanded=69, runtime_ms=3.75
KUL -> HKT -> LED -> HEL -> KEF
```

The short module parses its options, loads the graph, selects an algorithm and prints the result. It calls the existing search and cleaning code and reproduces Lab~2’s answer. Lab~3 runs it as a subprocess and checks that it exits with status~0.

== Benchmarking fairly

Lab~3 benchmarks BFS, UCS, GBFS and A$""^(star.op)$ on ten route pairs in `utils/search_queries.csv`:

#utptable[
  #tabularx(
    columns: (12%, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Algorithm], [Success rate], [Mean cost (km)], [Mean hops], [Mean expanded]),
    [BFS], [1.0], [16,469], [1.8], [324],
    [UCS], [1.0], [14,321], [2.2], [2,700],
    [GBFS], [1.0], [15,087], [2.1], [2.1],
    [A$""^(star.op)$], [1.0], [14,321], [2.2], [63],
  )
]

A race is only fair if every runner runs the same course. The notebook enforces four conditions:

- #strong[Same graph, same queries, same machine.] Every algorithm sees the identical cleaned graph and the identical ten pairs.
- #strong[Success rate before averages.] Averaging only solved queries hides failures on hard cases. All four methods solve all ten queries here.
- #strong[Effort in expansions, not milliseconds.] The runtime column is kept but is not the basis for conclusions.
- #strong[Every path validated.] The notebook checks that A$""^(star.op)$’s cost equals UCS’s on all ten queries and counts the queries on which GBFS is costlier (seven of ten).

For these kilometre-based queries, A$""^(star.op)$ matches UCS at about 2 % of its effort. Choose BFS when fewest legs is the real objective, and GBFS when reduced effort matters more than optimal cost.

== The scorecard so far

The table below collects every route search from these three chapters on one small problem. Read it across, and notice that no row wins every column. That is why several searches are worth knowing.

#utptable[
  #tabularx(
    columns: (20%, 13%, 11%, 11%, 11%, 1fr),
    align: (left, center, center, center, center, left),
    styles: (navy-bold,),
    header: ([Search, rainy maze], [Take next], [Steps], [Battery], [Expanded], [Verdict]),
    [BFS], [oldest], [11], [19], [45], [Fewest steps, but runs dry],
    [DFS], [newest], [15], [15], [15], [Arrives empty, by luck of neighbour order],
    [Bidirectional], [oldest, both ends], [11], [19], [31], [Same route as BFS with less work; runs dry],
    [UCS], [lowest $g$], [13], [13], [47], [Cheapest, and looks at everything],
    [GBFS], [lowest $h$], [11], [19], [13], [Least work; runs dry],
    [A$""^(star.op)$], [lowest $g+h$], [13], [13], [28], [Cheapest, with far less work than UCS],
    [A$""^(star.op)$ with $3 h$], [lowest $g+3 h$], [11], [19], [16], [Guess too bold: guarantee lost, runs dry],
  )
]

#tryit[
  Paste the table above into your notes, then change one thing in a copy of `demo_robot_maze.py`: set `PUDDLE_COST = 2`. Predict which rows change before you run it. With puddles that cheap, the middle corridor costs 13 and ties with the bottom route, so BFS should stop running dry while A$""^(star.op)$ still returns a 13-unit route. Remember to set `CHECK_BOOK_NUMBERS = False`.
]

#chapterrecap[
  - Five algorithms are one loop with a swappable frontier policy, so write the loop once.
  - A single result type lets one benchmark compare everything; effort counts belong in the result.
  - Keep loaders, search, plotting and the command line apart. A new domain then needs a new loader and nothing else.
  - Test on the smallest graph that can expose the bug, and judge a benchmark by the same graph, the same queries, validated paths and expansion counts.
]

#quickcheck[
  + Which #emph[one] function differs between UCS and A$""^(star.op)$ in `best_first`, and which module would you edit to add a fourth mode?
  + Why is `path_cost_km` recomputed from the returned path instead of taken from the search’s $g$ value?
  + What is the `counter` in the heap tuple for, and what goes wrong without it when states cannot be compared?
  + Why do the tests use a five-state graph rather than the airline network?
  + The benchmark reports GBFS as costlier than UCS on seven of ten queries. Why is “seven of ten” more informative than the mean cost gap alone?
]
