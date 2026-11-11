#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-search-implementation-patterns")


#heading(level: 1)[Search Engineering: One Loop, Five Algorithms, Tested]
 <ch:searchpatterns>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know what BFS, DFS, UCS, GBFS and A$""^star.op$ each optimise (Chapters #ref(label("ch:uninformed"), supplement: none)--#ref(label("ch:informed"), supplement: none)).

*By the end, you can:* explain why the five algorithms are one loop with a pluggable frontier; read and extend the `utils` package; write a unit test for a search function; run the toolkit from the command line; and design a benchmark whose numbers can be compared fairly.]

You have now met five searches, and every one of them is the same loop with its own answer to one question: #emph[what do we look at next?] A programmer should find that suspicious in a useful way, because a single idea written out five times is five places for bugs to hide. Lab~3 turns the search code from Labs~1--2 into reusable software: a package with a common interface, tests you can check by hand, a command-line interface and a broader benchmark.


#heading(level: 2)[The pluggable frontier]


The graph supplies states and successors, and the query supplies the goal test. The frontier policy alone determines the algorithm (#ref(label("fig:pluggable"), supplement: [Figure])).

#callout("analogy", title: [Analogy])[Think of a battery drill. The motor, the handle and the trigger stay the same, and you change what it does by swapping the bit. The search loop is the drill. The frontier policy is the bit.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/4be97ef8fea7ab16.cetz.json")], caption: [States, successors and the goal test come from the problem. The frontier policy determines the search algorithm.]) <fig:pluggable>

In `utils/core.py`, BFS and DFS use `popleft` and `pop`, respectively. UCS, GBFS and A$""^star.op$ wrap `best_first`, whose `mode` selects the priority. Weighted A$""^star.op$ reuses it with the heuristic multiplied by 1.5.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Algorithm], [Frontier structure], [Entry and priority],),
    table.hline(),
    [BFS], [`collections.deque`], [state; oldest first],
    [DFS], [Python list as a stack], [state; newest first],
    [UCS], [`heapq` min-heap], [`(g, counter, state, g)`],
    [GBFS], [`heapq` min-heap], [`(h(state), counter, state, g)`],
    [A$""^star.op$], [`heapq` min-heap], [`(g + h(state), counter, state, g)`],
  )]
  , kind: table
  )


#heading(level: 2)[One result type for every algorithm]


Every algorithm returns the same frozen dataclass, which lets one benchmark loop compare them all:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 17, last: 30, lang: "python")

Three design decisions are hidden in those seven fields.

/ The cost is recomputed from the path.: #block[
A helper sums edge weights after the search rather than reusing its stored $g$, which keeps `path_cost_km` consistent with the path actually returned.
]

/ Failure has a shape.: #block[
An unreachable goal returns `found=False`, an empty path, `hops=-1` and infinite cost. Callers check `result.found` instead of catching an exception.
]

/ Effort is part of the answer.: #block[
`expanded` and `max_frontier` are counted inside the loop, so every comparison in Labs 1--3 comes from the same counters.
]

`as_dict()` converts a result into a pandas row via `{**result.as_dict()}`, as used in every lab metrics file.


#heading(level: 2)[Separating responsibilities]


`utils` has five working modules, and each knows nothing about the others' concerns (#ref(label("fig:domains"), supplement: [Figure])). A well-run kitchen works the same way: the person who sources the vegetables does not need to know the recipes, and the cook does not need to know the supplier.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Module], [Responsibility],),
    table.hline(),
    [`core.py`], [The five algorithms and `SearchResult`. Works on any `{state: [(neighbour, cost)]}` dictionary; never mentions airports.],
    [`openflights.py`], [Reads the two CSV files, cleans them, computes Haversine distances, returns the graph. Never searches.],
    [`plotting.py`], [Draws routes on longitude/latitude axes.],
    [`__main__.py`], [The command-line interface: parses arguments, loads the graph, calls one algorithm, prints.],
    [`test_search.py`], [The unit tests, on graphs of four to five states. Calls the search functions only.],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/c7c9985ea129a61d.cetz.json")], caption: [Graph-specific loaders below the dashed line produce `{state: [(neighbour, cost)]}` dictionaries for shared search code above it. Every search number in Chapters~#ref(label("ch:uninformed"), supplement: none) to~#ref(label("ch:searchpatterns"), supplement: none) came through this one boundary.]) <fig:domains>

A road network would need a new loader, not new search code or tests. A new algorithm changes `core.py`, not the loader, CLI or benchmark. Lab~3 asks you to identify this boundary.


#heading(level: 2)[Priority queues and tuple ordering]


Python's `heapq` pops the smallest tuple, comparing element by element from the left. The frontier entries in `best_first` are `(priority, counter, state, g)`, and the `counter` is there for a reason (#ref(label("fig:tuple"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/2fa9f29a7d70264d.cetz.json")], caption: [Heap tuples compare left to right. A unique counter breaks priority ties by insertion order, avoiding comparisons between states.]) <fig:tuple>

#callout("pitfall", title: [Common mistake])[Placing a payload directly after the priority makes ties depend on payload comparisons, and possibly on state names. Insert a unique increasing counter to resolve ties by insertion order without comparing payloads.]


#heading(level: 2)[Testing search code]


A successful run on 6,464 airports can hide wrong costs, wrong expansion counts or broken cycle handling, because nobody can check those answers by eye. Tiny graphs make such errors checkable by hand. `utils/test_search.py` contains eight tests, one per way a search can fail:

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Test], [What a failure would mean],),
    table.hline(),
    [start equals goal], [The goal test runs before any expansion; hops and cost are zero.],
    [unreachable goal], [Failure is reported as `found=False`, not an exception or a wrong path.],
    [cycles terminate], [The seen set stops DFS from looping forever.],
    [BFS and UCS optimise different objectives], [The two algorithms give different answers on a graph built so that they must.],
    [frontier update finds the cheaper path], [A state first reached expensively is later replaced by a cheaper route.],
    [A$""^star.op$ matches UCS with a consistent heuristic], [The optimality guarantee holds on a hand-checked graph.],
    [GBFS is not assumed optimal], [The test asserts the #emph[expected] suboptimality rather than pretending it away.],
    [negative cost is rejected], [The precondition of UCS is enforced with a clear error.],
  )]
  , kind: table
  )

One test in full shows the pattern: a tiny graph, an expectation worked out by hand, and an assertion.

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/test_search.py", first: 38, last: 42, lang: "python")

Walk it through. From A, the direct edge reaches B at cost 10, while the route through C reaches B at cost 2, then G at cost 3. UCS first records B at 10, finds the cheaper way, and replaces it. If that update were broken, the test would return a path costing 11 and fail immediately. The tests need no dataset, run in under a second, and work on any machine or continuous-integration server.

#callout("keyidea", title: [Key idea])[Test the algorithm on the smallest graph that can expose the bug, and test the dataset loader separately. A test that needs real data tests both at once and diagnoses neither.]


#heading(level: 2)[A command-line interface]


`utils/__main__.py` makes the package runnable outside a notebook:

#code-block("cd all_experiments\npython -m utils --algorithm astar --start KUL --goal KEF\nASTAR: found=True, hops=4, cost_km=11461.3, expanded=69, runtime_ms=3.75\nKUL -> HKT -> LED -> HEL -> KEF", lang: "text")

The short module parses its options, loads the graph, selects an algorithm and prints the result. It calls the existing search and cleaning code and reproduces Lab~2's answer. Lab~3 runs it as a subprocess and checks that it exits with status~0.


#heading(level: 2)[Benchmarking fairly]


Lab~3 benchmarks BFS, UCS, GBFS and A$""^star.op$ on ten route pairs in `utils/search_queries.csv`:

#figure(
  align(center)[#table(
    columns: 5,
    align: (left,left,left,left,left,),
    table.header([Algorithm], [Success rate], [Mean cost (km)], [Mean hops], [Mean expanded],),
    table.hline(),
    [BFS], [1.0], [16,469], [1.8], [324],
    [UCS], [1.0], [14,321], [2.2], [2,700],
    [GBFS], [1.0], [15,087], [2.1], [2.1],
    [A$""^star.op$], [1.0], [14,321], [2.2], [63],
  )]
  , kind: table
  )

A race is only fair if every runner runs the same course. The notebook enforces four conditions:

- #strong[Same graph, same queries, same machine.] Every algorithm sees the identical cleaned graph and the identical ten pairs.

- #strong[Success rate before averages.] Averaging only solved queries hides failures on hard cases. All four methods solve all ten queries here.

- #strong[Effort in expansions, not milliseconds.] The runtime column is kept but is not the basis for conclusions.

- #strong[Every path validated.] The notebook checks that A$""^star.op$'s cost equals UCS's on all ten queries and counts the queries on which GBFS is costlier (seven of ten).

For these kilometre-based queries, A$""^star.op$ matches UCS at about 2 % of its effort. Choose BFS when fewest legs is the real objective, and GBFS when reduced effort matters more than optimal cost.


#heading(level: 2)[The scorecard so far]


The table below collects every route search from these three chapters on one small problem. Read it across, and notice that no row wins every column. That is why several searches are worth knowing.

#figure(
  align(center)[#table(
    columns: 6,
    align: (left,left,left,left,left,left,),
    table.header([Search, rainy maze], [Take next], [Steps], [Battery], [Expanded], [Verdict],),
    table.hline(),
    [BFS], [oldest], [11], [19], [45], [Fewest steps, but runs dry],
    [DFS], [newest], [15], [15], [15], [Arrives empty, by luck of neighbour order],
    [Bidirectional], [oldest, both ends], [11], [19], [31], [Same route as BFS with less work; runs dry],
    [UCS], [lowest $g$], [13], [13], [47], [Cheapest, and looks at everything],
    [GBFS], [lowest $h$], [11], [19], [13], [Least work; runs dry],
    [A$""^star.op$], [lowest $g + h$], [13], [13], [28], [Cheapest, with far less work than UCS],
    [A$""^star.op$ with $3 h$], [lowest $g + 3 h$], [11], [19], [16], [Guess too bold: guarantee lost, runs dry],
  )]
  , kind: table
  )

#callout("tryit", title: [Practice])[Paste the table above into your notes, then change one thing in a copy of `demo_robot_maze.py`: set `PUDDLE_COST = 2`. Predict which rows change before you run it. With puddles that cheap, the middle corridor costs 13 and ties with the bottom route, so BFS should stop running dry while A$""^star.op$ still returns a 13-unit route. Remember to set `CHECK_BOOK_NUMBERS = False`.]

#callout("chapterrecap", title: [Chapter recap])[- Five algorithms are one loop with a swappable frontier policy, so write the loop once.

- A single result type lets one benchmark compare everything; effort counts belong in the result.

- Keep loaders, search, plotting and the command line apart. A new domain then needs a new loader and nothing else.

- Test on the smallest graph that can expose the bug, and judge a benchmark by the same graph, the same queries, validated paths and expansion counts.]

#callout("quickcheck", title: [Check your understanding])[+ Which #emph[one] function differs between UCS and A$""^star.op$ in `best_first`, and which module would you edit to add a fourth mode?

+ Why is `path_cost_km` recomputed from the returned path instead of taken from the search's $g$ value?

+ What is the `counter` in the heap tuple for, and what goes wrong without it when states cannot be compared?

+ Why do the tests use a five-state graph rather than the airline network?

+ The benchmark reports GBFS as costlier than UCS on seven of ten queries. Why is "seven of ten" more informative than the mean cost gap alone?]
