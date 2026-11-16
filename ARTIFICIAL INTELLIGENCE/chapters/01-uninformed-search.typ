#import "/.shared/typst/utp.typ": *
#import "robot-maze-figures.typ": *
#unit("chapters", "01-uninformed-search")

= Uninformed Search: BFS, DFS, and Uniform-Cost Search <ch:uninformed>

#chapterguide[Read a graph drawn as nodes and edges, and use a Python list, set, dictionary and `for` loop.][write any route-finding task down as a search problem; explain the search loop and its to-do list; trace BFS, DFS and UCS by hand; say which quantity each one optimises; read the search code in `utils/core.py`; and judge a search by completeness, optimality, time and memory.]

In 1997 a computer beat the world chess champion, Garry Kasparov. In 2016 another beat Lee Sedol, one of the strongest Go players alive. Every time your phone finds the fastest way home, a third program is at work. Underneath, all three do one thing: they #term[search].

The names that come with search (breadth-first, uniform-cost, A$""^(star.op)$, minimax) are usually taught one chapter at a time, so they feel like separate tricks. They are not. Almost every search in this book is the same short loop, and one line in that loop decides what to look at next. This chapter builds the loop on a small robot in a small maze, small enough to check every step by hand, and then moves the same code to the real question of Lab~1: #emph[how do you fly from Kuala Lumpur to Keflavík without a direct flight?]

Five questions organise all the search material in the book. By the last chapter you will have met every search in the table below and seen how each one grows out of the same loop.

#utptable[
  #tabularx(
    columns: (5%, 37%, 1fr, 13%),
    align: (center, left, left, center),
    styles: (navy-bold,),
    header: ([], [The question], [The searches that answer it], [Where]),
    [1], [How do we find any route at all?], [Breadth-first, depth-first, bidirectional], [Chapter~@ch:uninformed],
    [2], [How do we find the cheapest route?], [Uniform-cost (Dijkstra’s algorithm)], [Chapter~@ch:uninformed],
    [3], [How do we explore fewer states?], [Greedy best-first, A$""^(star.op)$], [Chapter~@ch:informed],
    [4], [What if only the final answer counts?], [Hill climbing, simulated annealing, beam search, genetic algorithms], [Chapters~#ref(<ch:localsearch>)--@ch:ga],
    [5], [What if someone fights back?], [Minimax, Monte Carlo Tree Search], [Chapter~@ch:games],
  )
]

== A robot, a battery and a maze

A small robot is stranded on the far side of a maze and has to reach its charger. Its battery holds 15 units, and every step onto a floor cell uses one (#figref(<fig:robot-maze>)).

#utpfig([The maze seen from above. R is the robot, C its charger, and dark cells are walls. We name a cell by its row and column, counting from zero at the top left, so the robot starts at $(5,1)$ and the charger sits at $(2,9)$.], label: <fig:robot-maze>)[
  #canvas({
    mazegrid("m", mazedry, size: 0.62)
    mazeaxes("m")
    mazepins("m", size: 0.62)
    node((rel: (0.45, 0), to: "m-3-9.east"), [#strong[The numbers we will keep using] \ #v(2.9888pt)
   48 floor cells \
   15 units of battery, 1 unit per step \
   11 steps on the shortest route \ #v(2.9888pt)
   #fsize("script")[#text(fill: muted)[Every count in this chapter is printed and checked by `all_experiments/demo_robot_maze.py`.]]], anchor: "west", align: left, text-width: 6.1, font: font("small", fill: navy))
  })
]

We can see the whole maze at once, so the answer looks obvious to us. A planner cannot rely on that. A real maze may have thousands of corridors and a road network has millions of junctions, so we want one method that solves any of them.

Suppose the robot simply wanders, picking a random direction at every cell. Over 10,000 simulated walks it needs 315 steps on average to stumble onto a charger that is only 11 steps away. With 15 units of battery it stops long before that. So the robot should think before it moves: it has the map, so it can work out a whole route in its head and then drive it once. Planning a route ahead of time like this is what AI calls #term[search].

#note[
  Watch a search program run and nothing looks brilliant. It tries possibilities one after another, very fast. All of the intelligence sits in one decision, repeated over and over: #emph[which possibility do I try next?] That decision is the whole difference between one search algorithm and another.
]

== Writing the problem down

Before one method can solve any maze, any maze has to be written down the same way. Start with the idea of a #term[state]: a snapshot of everything that matters right now. For our robot that is a single fact, which cell it is on, so the maze has 48 states. Draw a dot for each state and a line between any two cells one step apart, and the walls disappear (#figref(<fig:state-space>)). What remains is the #term[state space]. Searching means finding a path through those dots, from the robot’s dot to the charger’s.

#utpfig([The same maze twice. Left: as the robot sees it. Right: as the search sees it, one dot per state and one line per possible step. Nothing about walls survives except which lines are missing.], label: <fig:state-space>)[
  #canvas({
    draw.scope({
      mazegrid("a", mazedry, size: 0.52)
      mazepins("a", size: 0.52)
    })
    connect((5.2, -1.55), (6.85, -1.55), ..utparrow)
    node(along((5.2, -1.55), (6.85, -1.55), t: 50%), [fade the walls], yshift: 1.9925pt, ..utplabel, anchor: "south")
    draw.scope({
      draw.translate((7.3, 0))
      mazegraph("g", mazedry, size: 0.52)
      node("g-5-1", [R], ..mzrobot(0.52), min-size: 0.44)
      node("g-2-9", [C], ..mzcharger(0.52), min-size: 0.44)
    })
  })
]

Five pieces turn a state space into a #term[search problem]. Writing them down is called #term[problem formulation], and it is the first thing to do with any new problem.

#utptable[
  #tabularx(
    columns: (15%, 20%, 26%, 1fr),
    styles: (navy-bold,),
    header: ([Piece], [Question it answers], [Robot maze], [Lab~1 airline network]),
    [Initial state], [Where do we start?], [Cell $(5,1)$], [The origin airport, named by its IATA code (`KUL`)],
    [Actions], [What can we do here?], [Step up, right, down or left], [Take any direct route out of this airport],
    [Transition model], [Where does an action lead?], [One cell over; a step into a wall goes nowhere], [The destination of that route],
    [Goal test], [Are we done?], [Am I on the charger?], [Is this the destination airport?],
    [Path cost], [What does a route cost?], [One unit of battery per step], [Number of legs, #emph[or] the sum of great-circle distances in km],
  )
]

Actions and the transition model together give a state’s #term[successors], the states one action away. Code usually stores those directly. In Python the graph is a dictionary from each state to a list of `(neighbour, cost)` pairs, and it has the same shape for a maze and for an airline network:

```python
build_graph()[(5, 1)]     # the robot's cell: up, right, down, left
# [((4, 1), 1.0), ((5, 2), 1.0), ((6, 1), 1.0), ((5, 0), 1.0)]

graph["KUL"][:3]          # Kuala Lumpur: the first three of its 112 direct routes
# [('ADL', 5681.8), ('AKL', 8703.4), ('ALA', 5130.5)]
```

The cost definition matters more than it looks. BFS and DFS treat each route as one step, while UCS sums kilometres, so “shortest route” means nothing until the cost is stated. The cleaned OpenFlights graph has 6,464 airports and 37,337 directed routes; distance is an educational stand-in for fares, schedules and connection costs.

#note[
  The problem supplies successors; the search algorithm chooses which state to examine next. Airport details belong to the first job, and the difference between BFS, DFS and UCS belongs to the second. Keeping those jobs apart is why one search function can serve a maze, an airline network and a sliding puzzle.
]

The five pieces describe far more than mazes:

#utptable[
  #tabularx(
    columns: (15%, 24%, 19%, 17%, 1fr),
    styles: (navy-bold,),
    header: ([Problem], [State], [Action], [Goal], [Cost]),
    [8-puzzle], [Where the eight tiles sit (181,440 reachable arrangements)], [Slide a tile into the gap], [Tiles in order], [1 per slide],
    [Rubik’s cube], [The colour layout (about $4.3 times 10^19$ states)], [Turn one face], [Every face one colour], [1 per turn],
    [Road navigation], [A junction on the road network], [Drive one stretch of road], [The destination], [Minutes of driving],
    [Sudoku], [The grid filled in so far], [Write one digit], [A full grid with no repeats], [None: only the final grid is judged],
    [Predictive text], [The words typed so far], [Add one word], [A finished message], [None: judged on the likely whole message],
    [Chess], [The board and whose turn it is], [One legal move], [Checkmate], [An opponent moves against you],
  )
]

Read the last column from top to bottom. The first three problems charge for every step, and those are the problems of this chapter and the next. Sudoku and predictive text care only about the finished answer, which is question~4 in our table. Chess has someone fighting back, which is question~5.

== Planning with and without a memory

How does the robot plan? It imagines its moves one at a time. From its cell it can step up, right, down or left, so draw a #term[search tree] with the start at the top and one branch for each move. Then each branch grows branches of its own. Every path from the top down is one complete plan (#figref(<fig:search-tree>)).

#utpfig([The first three levels of the search tree from the robot’s cell, written as row,column. Every path from the top down is one plan. The red nodes are cells some earlier plan has already reached. A tree has no memory, so it grows them all again; a search graph skips them.], label: <fig:search-tree>)[
  #canvas({
    let tn = (..utpnode, min-size: 0.74, font: font("tiny", weight: "bold", fill: navy))
    let trep = (shape: "circle", draw: red, fill: pale-red, min-size: 0.74, inner-sep: 0.4981pt, font: font("tiny", weight: "bold", fill: red))
    let tline = (line-width: widths.semithick, draw: mix(teal, 75%))
    let tmove = (..utplabel, fill: white, inner-sep: 0.797pt)
    node((0, 0), [5,1], name: "root", ..utpnodehot, min-size: 0.74, font: font("tiny", weight: "bold", fill: navy))
    node((-5, -1.45), [4,1], name: "a", font: font("small"), ..tn)
    node((-1.45, -1.45), [5,2], name: "b", font: font("small"), ..tn)
    node((1.65, -1.45), [6,1], name: "c", font: font("small"), ..tn)
    node((4.9, -1.45), [5,0], name: "d", font: font("small"), ..tn)
    connect("root", "a", ..tline)
    node(along("root", "a", t: 50%), [up], font: font("small"), ..tmove)
    connect("root", "b", ..tline)
    node(along("root", "b", t: 50%), [right], font: font("small"), ..tmove)
    connect("root", "c", ..tline)
    node(along("root", "c", t: 50%), [down], font: font("small"), ..tmove)
    connect("root", "d", ..tline)
    node(along("root", "d", t: 50%), [left], font: font("small"), ..tmove)
    node((-6.2, -2.85), [3,1], name: "a1", font: font("small"), ..tn)
    node((-5, -2.85), [5,1], name: "a2", font: font("small"), ..trep)
    node((-3.8, -2.85), [4,0], name: "a3", font: font("small"), ..tn)
    node((-2.05, -2.85), [6,2], name: "b1", font: font("small"), ..tn)
    node((-0.85, -2.85), [5,1], name: "b2", font: font("small"), ..trep)
    node((1.05, -2.85), [5,1], name: "c1", font: font("small"), ..trep)
    node((2.25, -2.85), [6,2], name: "c2", font: font("small"), ..trep)
    node((4.3, -2.85), [4,0], name: "d1", font: font("small"), ..trep)
    node((5.5, -2.85), [5,1], name: "d2", font: font("small"), ..trep)
    for (p, q) in (("a", "a1"), ("a", "a2"), ("a", "a3"), ("b", "b1"), ("b", "b2"), ("c", "c1"), ("c", "c2"), ("d", "d1"), ("d", "d2")) {
      connect(p, q, ..tline)
    }
    node((-5, -3.3), [“up, then down” is back at the start], font: font("small"), ..utplabel, anchor: "north", text: red)
  })
]

Follow the branch “up, then down”. The robot is back where it started, and the tree has no idea. It plans those cells again, and again, and that adds up quickly: planned this way, the robot looks at 43,288 plans before it finds the charger, even though the maze has only 48 cells. Most of those plans just shuffle back and forth.

The fix is a memory. The robot writes down every cell it has reached and skips any cell already on that list. Each cell now appears only once, the tree folds back into the map, and the search looks at no more than 48 cells. That version is called a #term[search graph] (or graph search).

#note[
  A search tree forgets where it has been. A search graph remembers.
]

== The search loop

How does the robot choose which cell to examine first, and which one next? It keeps a to-do list of the cells it has found but not yet examined. The textbook name for that list is the #term[frontier]. At the start the list holds only the robot’s own cell. Examining a cell then takes three moves:

#utpsteps[
  + Take one cell off the to-do list.
  + Check it: is this the charger? If so, stop and rebuild the route.
  + If not, put its neighbours on the list, skipping any already reached, and write down which cell each one was reached from.
]

Repeat until the charger comes off the list. If the list runs empty first, no route exists. We say a cell is #term[expanded] when step~3 runs on it, and we count those cells for every search; the goal itself is never expanded. #figref(<fig:search-loop>) draws the loop.

#utpfig([The search loop. The frontier is the to-do list. BFS, DFS and UCS share every box; only the highlighted choice differs, and it selects the oldest, newest or cheapest entry respectively.], label: <fig:search-loop>)[
  #canvas({
    node((0, 0), [Start \
  state], name: "start", font: font("small"), ..utpbox, min-width: 2.3)
    node((3.6, 0), [#strong[Select from] \
  #strong[frontier]], name: "pick", font: font("small"), ..utpbox, min-width: 2.6, fill: pale-orange, draw: orange, line-width: 0.9963pt)
    node((7.2, 0), [Goal \
  test?], name: "goal", font: font("small"), ..utpbox, min-width: 2.4)
    node((10.7, 0), [Return \
  the path], name: "done", font: font("small"), ..utpbox, min-width: 2.6, fill: pale-teal, draw: green)
    node((7.2, -2.1), [Generate \
  successors], name: "expand", font: font("small"), ..utpbox, min-width: 2.6)
    node((3.6, -2.1), [Not already \
  seen?], name: "vis", font: font("small"), ..utpbox, min-width: 2.6)
    connect("start", "pick", ..utparrow)
    connect("pick", "goal", ..utparrow)
    connect("goal", "done", ..utparrow)
    node(along("goal", "done", t: 50%), [yes], font: font("small"), ..utplabel, text: green, anchor: "south")
    connect("goal", "expand", ..utparrow)
    node(along("goal", "expand", t: 50%), [no], font: font("small"), ..utplabel, text: red, anchor: "west")
    connect("expand", "vis", ..utparrow)
    connect("vis", "pick", ..utparrow)
    node(along("vis", "pick", t: 50%), [keep], font: font("small"), ..utplabel, text: green, anchor: "west")
    node((3.6, 0.72), [#strong[the only line that changes:] FIFO / LIFO / min-cost], font: font("small"), ..utplabel, anchor: "south", align: center, text: orange)
    node((2.15, -2.1), [discard \
  duplicates], font: font("small"), ..utplabel, anchor: "east", align: right)
  })
]

Two bookkeeping choices are shared by every implementation in `utils/core.py`:

/ Parent links instead of copied paths.: Record each state’s predecessor, then follow those links backwards from the goal to rebuild the route. This saves storing a full path in every frontier entry.
/ Effort counters.: Count states `expanded` and the peak size of the frontier. Unlike runtime, these depend only on the graph and the algorithm, so they can be compared between machines.

Here is the loop in Python, exactly as the labs run it. The `parent` dictionary does two jobs: it stores the arrows back towards the start, and it is the robot’s memory.

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 56, last: 72, lang: "python")

#warning[
  Mark a state as seen when it is #emph[added] to the frontier, not when it is removed. The `parent` dictionary does this: a state gets a parent the moment it is discovered. Marking on removal lets the same airport be queued many times by different neighbours, which inflates the frontier and, for BFS, can attach a longer path than necessary.
]

The rest of this chapter is one question: #emph[which cell do we take off the list?] Every answer has a name.

== Breadth-first search: take the oldest

The simplest answer is to take the cell that has waited longest. New cells join the back of the list and the front of the list is served next, like people in a line at a shop. That list is a first-in, first-out #term[queue], and the search is #term[Breadth-First Search (BFS)].

#example[
  BFS from the robot’s cell. Each row takes the front of the queue and adds any new neighbours to the back, in the order up, right, down, left.

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto),
    header: ([Take], [New cells], [Queue afterwards, front on the left]),
    [$(5,1)$], [$(4,1)$ $(5,2)$ $(6,1)$ $(5,0)$], [$(4,1)$ $(5,2)$ $(6,1)$ $(5,0)$],
    [$(4,1)$], [$(3,1)$ $(4,0)$], [$(5,2)$ $(6,1)$ $(5,0)$ $(3,1)$ $(4,0)$],
    [$(5,2)$], [$(6,2)$], [$(6,1)$ $(5,0)$ $(3,1)$ $(4,0)$ $(6,2)$],
    [$(6,1)$], [none], [$(5,0)$ $(3,1)$ $(4,0)$ $(6,2)$],
    [$(5,0)$], [none], [$(3,1)$ $(4,0)$ $(6,2)$],
    [$(3,1)$], [$(2,1)$ $(3,2)$], [$(4,0)$ $(6,2)$ $(2,1)$ $(3,2)$],
  )

  #raggedright[
  #v(6pt)
  Every cell one step from the robot is examined before any cell two steps away. After the fifth row the queue holds exactly the cells two steps away.
  ]]]
]

Drop a stone into a still pond. The ripple spreads outward in a circle and touches every point one step away before any point two steps away. BFS spreads the same way, ring by ring. If you use LinkedIn you have already seen these rings: your first-degree connections are the people you know, second-degree connections are the people they know, and third-degree is the next ring out.

#utpfig([Each number is the step at which BFS first reaches that cell, and the tint deepens with distance. The ripple touches the charger on ring 11. Following the parent links back from the charger gives the orange route.], label: <fig:bfs-wave>)[
  #canvas({
    mazegrid("r", mazerings, size: 0.62)
    mazeroute("r", routecorridor)
    mazelabels("r", mazerings)
    mazepins("r", size: 0.62)
    node((rel: (0.45, 0), to: "r-3-9.east"), [#strong[Why this route is the shortest] \ #v(2.9888pt)
   The ripple finishes every ring before it starts the next. When it first touches the charger, on ring 11, no shorter route can exist, because an earlier ring would have touched it first. \ #v(2.9888pt)
   #fsize("script")[#text(fill: muted)[On the airline graph the rings are airports one leg away, two legs away, and so on.]]], anchor: "west", align: left, text-width: 5.6, font: font("small", fill: navy))
  })
]

BFS finds the 11-step route after expanding 45 of the 48 cells. Only three are spared: the charger, and two cells still waiting in the queue when the charger came off it.

#note[
  Oldest first means nearest first, and nearest first means the fewest steps. That guarantee comes straight from the shape of the list.
]

#example[
  BFS from `KUL` to `KEF` expands 284 airports and returns `KUL -> AMS -> KEF`: two legs, 12,274~km. This minimises legs, not kilometres. BFS never reads the distances stored in the graph.
]

== Depth-first search: take the newest

BFS explored nearly the whole maze. Another answer is to take the newest cell instead. The list now behaves like a pile of plates: the last plate put on is the first one taken off. That list is a #term[stack], and the search is #term[Depth-First Search (DFS)]. #figref(<fig:queue-stack>) puts the two lists side by side at the same moment.

#utpfig([The same five cells on two kinds of to-do list, just after the robot’s cell and $(4,1)$ have been examined. The queue serves its oldest entry next, $(5,2)$. The stack serves its newest, $(3,1)$, right beside the cell just examined. That single difference separates BFS from DFS.], label: <fig:queue-stack>)[
  #canvas({
    let qitem = (..utpcell, min-width: 1, min-height: 0.6, font: font("script", weight: "bold", fill: navy))
    let qnext = (..utphot, min-width: 1, min-height: 0.6, font: font("script", weight: "bold", fill: navy))
    let pitem = (..utpcell, min-width: 2.1, min-height: 0.44, rounded: 1mm, font: font("script", weight: "bold", fill: navy))
    let pnext = (..utphot, min-width: 2.1, min-height: 0.44, rounded: 1mm, font: font("script", weight: "bold", fill: navy))
    node((2, 1.05), [Queue: a line at a shop], font: font("normal", weight: "bold", fill: navy))
    node((0, 0.2), [5,2], font: font("small"), ..qnext)
    for (t, i) in (((6, 1), 1), ((5, 0), 2), ((3, 1), 3), ((4, 0), 4)) {
      node((1 * i, 0.2), [#t], font: font("small"), ..qitem)
    }
    connect((0, -0.75), (0, -0.15), ..utpptr, draw: orange)
    node((0, -0.78), [served next], font: font("small"), ..utplabel, anchor: "north", text: orange)
    connect((4, -0.15), (4, -0.75), ..utpptr)
    connect((5.1, 0.2), (4.56, 0.2), ..utpptr)
    node((5.12, 0.2), [new cells join here], font: font("small"), ..utplabel, anchor: "west")
    node((4, -0.78), [newest], font: font("small"), ..utplabel, anchor: "north")
    node((-0.5, -1.45), [first in, first out  `frontier.popleft()`], font: font("small"), ..utplabel, align: left, anchor: "west")
    draw.scope({
      draw.translate((9.9, 0))
      node((0, 1.05), [Stack: a pile of plates], font: font("normal", weight: "bold", fill: navy))
      node((0, 0.42), [3,1], font: font("small"), ..pnext)
      for (t, y) in (((4, 0), -0.04), ((5, 2), -0.5), ((6, 1), -0.96), ((5, 0), -1.42)) {
        node((0, y), [#t], font: font("small"), ..pitem)
      }
      connect((1.2, 0.42), (1.65, 0.42), ..utpptr, draw: orange)
      node((1.68, 0.42), [served next; \
  new cells land here], font: font("small"), ..utplabel, anchor: "west", align: left, text: orange)
      node((1.25, -0.98), [last in, first out \
  `frontier.pop()`], font: font("small"), ..utplabel, anchor: "west", align: left)
    })
  })
]

Because the next pick is always right beside the last one, DFS dives down one corridor as far as it can before it tries another, and it backs up only when it runs out of new cells. On our maze, with neighbours listed up, right, down, left, it runs straight up the left side, along the top and down to the charger (#figref(<fig:bfs-dfs-routes>)). It expands only 15 cells. But its route also takes 15 steps, so the robot reaches the charger with its battery at exactly zero.

#utpfig([Blue cells were expanded. BFS expands 45 cells and returns the shortest route, 11 steps. DFS expands 15 cells and returns a 15-step route. DFS looked at far less of the maze and paid for it in route length.], label: <fig:bfs-dfs-routes>)[
  #canvas({
    draw.scope({
      node((2.34, 0.55), [BFS: 45 expanded, 11 steps], ..mztitle)
      mazegrid("b", mazebfs, size: 0.52)
      mazeroute("b", routecorridor)
      mazepins("b", size: 0.52)
    })
    draw.scope({
      draw.translate((7.3, 0))
      node((2.34, 0.55), [DFS: 15 expanded, 15 steps], ..mztitle)
      mazegrid("d", mazedfs, size: 0.52)
      mazeroute("d", routetop)
      mazepins("d", size: 0.52)
    })
  })
]

That result is partly luck. Reverse the neighbour order to left, down, right, up and DFS expands 36 cells and returns a 33-step route, far beyond the battery. In `utils/core.py` the code differs from BFS in two lines: `frontier.pop()` takes the newest entry, and the successors are pushed in reverse order so that the first listed neighbour is popped first. That second line is why DFS is #term[order dependent]. It commits to whichever neighbour the graph happens to list first and reconsiders only when that whole branch fails.

#figref(<fig:bfs-dfs-order>) shows the same contrast on a tree small enough to read at a glance.

#utpfig([Numbered visit orders on one tree. BFS completes each level; DFS exhausts B\'s subtree before C. After A and B have been visited, both lists hold the same three states, but in a different order, so each serves a different state next.], label: <fig:bfs-dfs-order>)[
  #canvas({
    draw.scope({
      node((0, 2.05), [BFS (queue)], font: font("normal", weight: "bold", fill: navy))
      node((0, 1.3), [A], name: "ba", font: font("small"), ..utpnode, min-size: 0.75)
      node((-1.3, 0.25), [B], name: "bb", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.3, 0.25), [C], name: "bc", font: font("small"), ..utpnode, min-size: 0.75)
      node((-1.95, -0.8), [D], name: "bd", font: font("small"), ..utpnode, min-size: 0.75)
      node((-0.65, -0.8), [E], name: "be", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.65, -0.8), [F], name: "bf", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.95, -0.8), [G], name: "bg", font: font("small"), ..utpnode, min-size: 0.75)
      connect("ba", "bb", ..utpedge)
      connect("ba", "bc", ..utpedge)
      connect("bb", "bd", ..utpedge)
      connect("bb", "be", ..utpedge)
      connect("bc", "bf", ..utpedge)
      connect("bc", "bg", ..utpedge)
      for (n, o) in (("ba", 1), ("bb", 2), ("bc", 3), ("bd", 4), ("be", 5), ("bf", 6)) {
        node((rel: (0.055, 0.055), to: n + ".north-east"), [#o], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      }
      node((rel: (0.055, 0.055), to: "bg.north-east"), [7], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      node((0, -1.35), [order: A B C D E F G], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((5.2, 0))
      node((0, 2.05), [DFS (stack)], font: font("normal", weight: "bold", fill: navy))
      node((0, 1.3), [A], name: "da", font: font("small"), ..utpnode, min-size: 0.75)
      node((-1.3, 0.25), [B], name: "db", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.3, 0.25), [C], name: "dc", font: font("small"), ..utpnode, min-size: 0.75)
      node((-1.95, -0.8), [D], name: "dd", font: font("small"), ..utpnode, min-size: 0.75)
      node((-0.65, -0.8), [E], name: "de", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.65, -0.8), [F], name: "df", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.95, -0.8), [G], name: "dg", font: font("small"), ..utpnode, min-size: 0.75)
      connect("da", "db", ..utpedge)
      connect("da", "dc", ..utpedge)
      connect("db", "dd", ..utpedge)
      connect("db", "de", ..utpedge)
      connect("dc", "df", ..utpedge)
      connect("dc", "dg", ..utpedge)
      for (n, o) in (("da", 1), ("db", 2), ("dc", 5), ("dd", 3), ("de", 4), ("df", 6)) {
        node((rel: (0.055, 0.055), to: n + ".north-east"), [#o], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      }
      node((rel: (0.055, 0.055), to: "dg.north-east"), [7], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      node((0, -1.35), [order: A B D E C F G], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((8.25, 0))
      draw.translate((0, 1.2))
      node((0, 0.5), [#strong[after visiting A and B]], font: font("small"), ..utplabel, anchor: "west", text: navy)
      node((1.05, 0), [C D E], ..utpcell, min-width: 1.9, min-height: 0.5, font: font("script", weight: "bold"))
      node((2.15, 0), [BFS: C next], font: font("small"), ..utplabel, anchor: "west", text: blue)
      node((1.05, -0.75), [D E C], ..utpcell, min-width: 1.9, min-height: 0.5, font: font("script", weight: "bold"), fill: pale-teal, draw: green)
      node((2.15, -0.75), [DFS: D next], font: font("small"), ..utplabel, anchor: "west", text: green)
      node((0, -1.85), [On a deep space a BFS frontier grows to $O(b^d)$ states; a DFS that keeps only its current path needs $O(b m)$.], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 3.7)
    })
  })
]

#example[
  From `KUL`, DFS commits to the alphabetically first neighbour, `ADL` (Adelaide), then to Adelaide’s first neighbour, and so on. It reaches Keflavík after 23 legs and 41,768~km, more than the circumference of the Earth, and expands 2,112 airports on the way, far more than the 284 of BFS. Reversing every neighbour list gives a different route of 8 legs. Neither is a meaningful travel plan: DFS answers “is there #emph[a] route?”, not “what is a good one?”.
]

#note[
  BFS expands a ripple; DFS follows one thread. The ripple is expensive to store but arrives by the fewest steps. The thread can be cheap to store but says nothing about how good its path is.
]

== A fair way to compare searches

We now have two ways to choose, and more are coming, so we need a fair comparison. Textbooks judge a search on four properties. Think of them as a scorecard that every new search has to fill in.

#utptable[
  #tabularx(
    columns: (16%, 1fr, 14%, 14%),
    align: (left, left, center, center),
    styles: (navy-bold,),
    header: ([Property], [The question], [BFS on maze], [DFS on maze]),
    [Complete], [If a route exists, is it guaranteed to be found?], [Yes], [Yes (finite, with memory)],
    [Optimal], [Is the route it returns the cheapest?], [Yes, 11 steps], [No, 15 steps],
    [Time], [How many states does it expand?], [45], [15],
    [Space], [How many states must it hold at once? (peak frontier)], [6], [12],
  )
]

The space row may surprise you, because the usual advice is that DFS needs less memory. On a narrow maze the ripple is only ever a few cells wide, while DFS leaves untried side branches behind on its pile. On the bushy airline network the usual advice holds: from `KUL` to `KEF` the BFS frontier peaks at 1,679 airports and the DFS frontier at 859. The formal results below describe large spaces. Small problems can go either way, so measure.

For the formal version, write $b$ for the #term[branching factor] (successors per state), $d$ for the depth of the shallowest goal, and $m$ for the maximum depth of the space.

#utptable[
  #tabularx(
    columns: (10%, 19%, 25%, 24%, 1fr),
    align: (center, left, left, center, center),
    styles: (navy-bold,),
    header: ([Method], [Complete?], [Optimal?], [Time], [Space]),
    [BFS], [Yes, if $b$ is finite], [Only when every step costs the same], [$O(b^d)$], [$O(b^d)$],
    [DFS], [Not in general], [No], [$O(b^m)$], [$O(b m)$],
    [UCS], [Yes, if step costs $>= epsilon >0$], [Yes, for non-negative costs], [$O(b^(1+ floor.l C^(star.op)\/ epsilon floor.r))$], [same as time],
  )
]

Here $C^(star.op)$ is the cost of the optimal solution and $epsilon$ the smallest step cost. The $O(b m)$ assumes DFS keeps only its current path and untried siblings. The version in `core.py` also keeps the `parent` table, which is what makes it safe on graphs with cycles, so it stores more than that.

#figref(<fig:branching>) shows what $O(b^d)$ means in practice. At branching factor 3 a goal eight levels down leaves about 9,800 states in memory; at branching factor 5 the same depth needs nearly 500,000. The airline graph has a mean branching factor near 6, but its largest hubs have more than 200 routes each (Frankfurt has 239). That is why the frontier in Lab~1 reaches 1,679 airports for a two-leg BFS answer.

#utpfig([States a BFS frontier may hold at depth $d$, for three branching factors. The vertical axis is logarithmic, so each straight line is exponential growth. DFS, keeping only its current path, stores $O(b m)$, which on these scales is a nearly flat line at the bottom.], label: <fig:branching>)[
  #canvas({
    axis(width: 11.5632cm, height: 5.2cm, xlabel: [depth $d$], ylabel: [states stored], xmin: 1, xmax: 10, ymin: 1, ymax: 20000000, ymode: "log", axis-lines: "left", grid: "major", grid-style: (draw: pale-blue), legend-columns: 4, legend-style: (at: (0.5, -0.28), anchor: "north"), domain: (1, 10), samples: 10,
      addplot(draw: green, line-width: widths.very-thick, x => calc.pow(2, x), legend: [$b=2$]),
      addplot(draw: blue, line-width: widths.very-thick, x => calc.pow(3, x), legend: [$b=3$]),
      addplot(draw: red, line-width: widths.very-thick, x => calc.pow(5, x), legend: [$b=5$]),
      addplot(draw: muted, dash: "dashed", line-width: widths.thick, x => 5 * x, legend: [DFS, $O(b m)$]),
    )
  })
]

== Bidirectional search: two ripples

BFS kept the 11-step route, but its ripple filled 45 of the 48 cells, because it had to grow all the way from the robot to the charger. Can we keep the route and explore less? Start a second ripple from the charger. The two take turns, one ring each, and stop the moment they touch. At the meeting cell we join the robot’s half to the charger’s half. That is #term[bidirectional search].

Two tunnelling crews start from opposite sides of a mountain and meet in the middle. Neither crew digs the whole tunnel. Ripples behave the same way, only more so, because a ripple covers more and more ground the further it spreads: two small ripples that each go halfway cover much less ground than one big ripple that goes all the way.

On our maze the ripples touch at $(3,5)$ with the route still 11 steps long, after expanding 18 cells on the robot’s side and 13 on the charger’s: 31 in all, against 45 for BFS. The saving is modest here because the maze’s rings are small. On a problem whose rings grow quickly the saving is enormous. The 8-puzzle board traced in `all_experiments/demo_sliding_puzzle.py` needs 22 slides: one ripple expands 89,296 arrangements, and two ripples expand 1,240 (#figref(<fig:bidirectional>)).

#utpfig([Left: the two ripples on the maze, robot side in blue and charger side in teal, touching at the orange cell. Right: how many 8-puzzle arrangements lie in each ring around the traced board. Rings grow by a factor of about 1.56 each, so most of the work sits in the last few. Two ripples that each stop near the halfway line never reach them.], label: <fig:bidirectional>)[
  #box(baseline: 50%, canvas({
    mazegrid("b", mazebidir, size: 0.46)
    mazepins("b", size: 0.46)
    node((2.07, -3), [robot side 18 + charger side 13 = 31 cells], ..mznote, anchor: "north")
  }))#h(0.5cm)#box(baseline: 50%, canvas({
    axis(width: 8.4cm, height: 4.7cm, ybar: auto, bar-width: 4.1843pt, xlabel: [ring (slides from the start)], ylabel: [arrangements in the ring], xmin: -1, xmax: 23, ymin: 0, ymax: 26000, xtick: (0, 5, 11, 15, 22), ytick: (0, 10000, 20000), scaled-y-ticks: false, axis-lines: "left", ymajorgrids: true, grid-style: (draw: pale-blue), clip: false,
      addplot(fill: teal, draw: none, coords: ((0, 1), (1, 2), (2, 4), (3, 8), (4, 16), (5, 20), (6, 39), (7, 62), (8, 116), (9, 152), (10, 286), (11, 396))),
      addplot(fill: mix(blue, 70%), draw: none, coords: ((12, 748), (13, 1024), (14, 1893), (15, 2512), (16, 4485), (17, 5638), (18, 9529), (19, 10878), (20, 16993), (21, 17110), (22, 23952))),
      {
        connect((11.5, 0), (11.5, 21000), draw: orange, dash: "dashed", line-width: widths.thick)
        node((11.5, 21000), [two ripples stop near here], font: font("script", fill: mix(orange, 85%, other: black)), anchor: "south")
      },
    )
  }))
]

#warning[
  Bidirectional search needs to know exactly where the goal is, so the second ripple has somewhere to start, and it must be able to run backwards. A maze has one charger. A chess game has countless ways to end in checkmate, and nobody can start a ripple from all of them. On the airline network routes are one-way, so a backward ripple has to follow reversed edges, which is how Lab~2 builds its exact cost table.
]

#exercises[
  Run `python all_experiments/demo_robot_maze.py` from the course folder and find each number from this chapter in its output. Then copy the file, set `CHECK_BOOK_NUMBERS = False`, turn the floor cell at $(3,3)$ into a wall, and predict before running: what does BFS return now? Its ripple can no longer use the middle corridor, so the answer should be the 13-step route along the bottom.
]

== Uniform-cost search: take the cheapest

So far every step has cost the same, so the fewest steps was also the cheapest route and BFS was optimal. Now it starts to rain. Two puddles form in the middle corridor, marked in #figref(<fig:rain-routes>), and splashing through one drains 5 units of battery instead of 1.

BFS does not know about battery. It only counts steps, so it still takes its 11-step route through both puddles: nine dry steps plus two puddles, $9+5+5=19$ units. The battery holds 15, so the robot runs dry at $(3,6)$, four cells short of the charger. Yet a better route exists along the bottom: 13 steps, all dry, 13 units, and the robot arrives with 2 to spare.

#note[
  Fewest steps does not mean cheapest. To find the cheapest route, a search has to count what it spends.
]

So choose by battery: take the cell with the least battery spent so far. That is #term[Uniform-Cost Search (UCS)]. The battery spent so far gets a short name, $g$, written $g(n)$ for cell $n$. “Uniform” does not mean every step costs the same. It means the search spreads in waves of equal battery spent, the way BFS spreads in rings of equal steps.

The loop stays the same. The big change is the list: UCS keeps its frontier in a #term[priority queue], which always hands back the cell with the smallest $g$ no matter when it joined. Think of an emergency ward, where patients are seen by urgency and not by arrival time. #figref(<fig:three-lists>) shows a real moment from the rainy maze. The puddle cell $(3,2)$ has already joined the list, but at $g=7$ it waits behind everything cheaper.

#utpfig([The UCS frontier just after $(3,1)$ has been expanded on the rainy maze. Cells are served by the battery spent to reach them, smallest first, and the join order breaks ties. The puddle cell waits behind every cheaper dry cell, including cells that will join later.], label: <fig:three-lists>)[
  #canvas({
    let pq = (..utpcell, min-width: 1.45, min-height: 0.95, align: center, font: font("script", fill: navy))
    let pqnext = (..utphot, min-width: 1.45, min-height: 0.95, align: center, font: font("script", fill: navy))
    let pqwet = (min-width: 1.45, min-height: 0.95, align: center, font: font("script", fill: navy), draw: teal, fill: mix(teal, 30%))
    node((0, 0), [#strong[(4,0)] \
  $g=2$], name: "p1", font: font("small"), ..pqnext)
    node((1.65, 0), [#strong[(6,2)] \
  $g=2$], name: "p2", font: font("small"), ..pq)
    node((3.3, 0), [#strong[(2,1)] \
  $g=3$], name: "p3", font: font("small"), ..pq)
    node((4.95, 0), [#strong[(3,2)] \
  $g=7$], name: "p4", font: font("small"), ..pqwet)
    connect((0, -1.05), (0, -0.55), ..utpptr, draw: orange)
    node((0, -1.07), [served next], font: font("small"), ..utplabel, anchor: "north", text: orange)
    node((4.95, -0.6), [puddle: \
  $2+5=7$], font: font("small"), ..utplabel, anchor: "north", align: center, text: mix(teal, 70%, other: black))
    node((6.1, 0), [#strong[One data structure, three names.] BFS keeps this list as a queue, DFS as a stack, UCS as a priority queue. The structure holding the frontier decides which cell the “select” box hands back.], anchor: "west", align: left, text-width: 5.4, font: font("script", fill: navy))
  })
]

#utpfig([The rainy maze. Left: the three routes home, with the battery each one costs. Right: the battery UCS spends to reach each cell. Cost climbs sharply across the puddles at $(3,2)$ and $(3,4)$, so the wave coming from the bottom reaches $(3,7)$ with $g=10$ first.], label: <fig:rain-routes>)[
  #canvas({
    draw.scope({
      mazegrid("w", mazerain, size: 0.52)
      mazeroute("w", routecorridor, ..mzroutebad)
      mazeroute("w", routebottom, ..mzroutealt)
      mazeroute("w", routetop, line-width: 1.2951pt, draw: muted, dash: (2.9888pt, 1.9925pt))
      mazepins("w", size: 0.52)
      node((2.34, -3.42), [#text(fill: red)[#strong[middle]]: 11 steps, 19 units, runs dry \
   #text(fill: green)[#strong[bottom]]: 13 steps, 13 units, best \
   #strong[top]: 15 steps, 15 units, arrives empty], ..mznote, anchor: "north", align: left)
    })
    draw.scope({
      draw.translate((7.3, 0))
      mazegrid("c", mazecost, size: 0.52)
      mazeroute("c", routebottom, ..mzroutealt)
      mazelabels("c", mazecost)
      mazepins("c", size: 0.52)
      node((2.34, -3.42), [$g$: battery spent reaching each cell], ..mznote, anchor: "north")
    })
  })
]

UCS needs two small changes to the BFS loop. It adds a table of $g$ values, adding each step’s cost as it goes. And it changes the memory check: in the rain, the first way we find to a cell is not always the cheapest, so when a cheaper way turns up we write down the new $g$ and the new parent and put the cell on the list again. In `utils/core.py`, UCS, GBFS and A$""^(star.op)$ share one function, `best_first`, because they differ only in the priority they attach to a frontier entry. The frontier is a Python `heapq` of tuples `(priority, counter, state, g)`:

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 118, last: 132, lang: "python")

Three details in that loop are easy to miss. Test for the goal when a state is #emph[popped], not when it is generated, or you may return the first path found rather than the cheapest. A cheaper path may leave an older, costlier entry for the same state behind in the heap, and `expanded_states` skips those stale copies. The `counter` breaks priority ties by insertion order without comparing states, which may not even be comparable (#chapref(<ch:searchpatterns>)).

Why is the result always the cheapest route? UCS examines cells in order of battery spent, so it cannot take the charger off the list by an expensive route while a cheaper route is still waiting. Cheapest first means the cheapest route, provided no step has a negative cost.

#figref(<fig:ucs-vs-bfs>) shows BFS and UCS disagreeing on a smaller graph. Both routes use three edges, so BFS has no reason to prefer either; UCS adds the weights and finds that one costs twice the other.

#utpfig([The same weighted graph solved twice. BFS returns the first three-edge path it meets, costing 8. UCS orders its frontier by accumulated cost $g(n)$ and returns the three-edge path costing 4. Neither is wrong; they answer different questions.], label: <fig:ucs-vs-bfs>)[
  #canvas({
    draw.scope({
      node((2.25, 2.35), [BFS: fewest edges], font: font("normal", weight: "bold", fill: navy))
      node((0, 0), [A], name: "pA", font: font("small"), ..utpnode, min-size: 0.7)
      node((1.5, 0.95), [B], name: "pB", font: font("small"), ..utpnode, min-size: 0.7)
      node((1.5, -0.95), [C], name: "pC", font: font("small"), ..utpnode, min-size: 0.7)
      node((3, 1.6), [D], name: "pD", font: font("small"), ..utpnode, min-size: 0.7)
      node((3, 0.35), [E], name: "pE", font: font("small"), ..utpnode, min-size: 0.7)
      node((3, -0.95), [F], name: "pF", font: font("small"), ..utpnode, min-size: 0.7)
      node((4.5, 0), [G], name: "pG", font: font("small"), ..utpnode, min-size: 0.7)
      connect("pA", "pC", ..utpedge, draw: mix(muted, 45%))
      node(along("pA", "pC", t: 50%), [4], font: font("small"), ..utplabel, anchor: "north")
      connect("pB", "pE", ..utpedge, draw: mix(muted, 45%))
      node(along("pB", "pE", t: 50%), [2], font: font("small"), ..utplabel, anchor: "south")
      connect("pC", "pF", ..utpedge, draw: mix(muted, 45%))
      node(along("pC", "pF", t: 50%), [5], font: font("small"), ..utplabel, anchor: "north")
      connect("pE", "pG", ..utpedge, draw: mix(muted, 45%))
      node(along("pE", "pG", t: 50%), [1], font: font("small"), ..utplabel, anchor: "north")
      connect("pF", "pG", ..utpedge, draw: mix(muted, 45%))
      node(along("pF", "pG", t: 50%), [2], font: font("small"), ..utplabel, anchor: "north")
      connect("pA", "pB", ..utpedge, draw: red, line-width: 1.1955pt)
      node(along("pA", "pB", t: 50%), [1], font: font("small"), ..utplabel, text: red, anchor: "south")
      connect("pB", "pD", ..utpedge, draw: red, line-width: 1.1955pt)
      node(along("pB", "pD", t: 50%), [3], font: font("small"), ..utplabel, text: red, anchor: "south")
      connect("pD", "pG", ..utpedge, draw: red, line-width: 1.1955pt)
      node(along("pD", "pG", t: 50%), [4], font: font("small"), ..utplabel, text: red, anchor: "south")
      node((2.25, -1.75), [A $arrow.r$ B $arrow.r$ D $arrow.r$ G \
  3 edges, cost $1+3+4=bold(upright(8))$], font: font("small"), ..utplabel, anchor: "north", align: center, text: red)
    })
    draw.scope({
      draw.translate((6.5, 0))
      node((2.25, 2.35), [UCS: cheapest total], font: font("normal", weight: "bold", fill: navy))
      node((0, 0), [A], name: "qA", font: font("small"), ..utpnode, min-size: 0.7)
      node((1.5, 0.95), [B], name: "qB", font: font("small"), ..utpnode, min-size: 0.7)
      node((1.5, -0.95), [C], name: "qC", font: font("small"), ..utpnode, min-size: 0.7)
      node((3, 1.6), [D], name: "qD", font: font("small"), ..utpnode, min-size: 0.7)
      node((3, 0.35), [E], name: "qE", font: font("small"), ..utpnode, min-size: 0.7)
      node((3, -0.95), [F], name: "qF", font: font("small"), ..utpnode, min-size: 0.7)
      node((4.5, 0), [G], name: "qG", font: font("small"), ..utpnode, min-size: 0.7)
      connect("qA", "qC", ..utpedge, draw: mix(muted, 45%))
      node(along("qA", "qC", t: 50%), [4], font: font("small"), ..utplabel, anchor: "north")
      connect("qB", "qD", ..utpedge, draw: mix(muted, 45%))
      node(along("qB", "qD", t: 50%), [3], font: font("small"), ..utplabel, anchor: "south")
      connect("qC", "qF", ..utpedge, draw: mix(muted, 45%))
      node(along("qC", "qF", t: 50%), [5], font: font("small"), ..utplabel, anchor: "north")
      connect("qD", "qG", ..utpedge, draw: mix(muted, 45%))
      node(along("qD", "qG", t: 50%), [4], font: font("small"), ..utplabel, anchor: "south")
      connect("qF", "qG", ..utpedge, draw: mix(muted, 45%))
      node(along("qF", "qG", t: 50%), [2], font: font("small"), ..utplabel, anchor: "north")
      connect("qA", "qB", ..utpedge, draw: green, line-width: 1.1955pt)
      node(along("qA", "qB", t: 50%), [1], font: font("small"), ..utplabel, text: green, anchor: "south")
      connect("qB", "qE", ..utpedge, draw: green, line-width: 1.1955pt)
      node(along("qB", "qE", t: 50%), [2], font: font("small"), ..utplabel, text: green, anchor: "south")
      connect("qE", "qG", ..utpedge, draw: green, line-width: 1.1955pt)
      node(along("qE", "qG", t: 50%), [1], font: font("small"), ..utplabel, text: green, anchor: "north")
      node((2.25, -1.75), [A $arrow.r$ B $arrow.r$ E $arrow.r$ G \
  3 edges, cost $1+2+1=bold(upright(4))$], font: font("small"), ..utplabel, anchor: "north", align: center, text: green)
    })
  })
]

#example[
  Trace UCS on the graph of #figref(<fig:ucs-vs-bfs>). The frontier holds $(g,"state")$ pairs and always pops the smallest $g$.

  $ #table(columns: 2, stroke: none, inset: (x: 5pt, y: 2.6pt), align: (center, left), table.vline(x: 1, stroke: 0.4pt), [$"expand"$], [$"frontier after expansion"$], table.hline(y: 1, stroke: 0.4pt), [$A space (0)$], [$(1,B), space (4,C)$], [$B space (1)$], [$(3,E), space (4,C), space (4,D)$], [$E space (3)$], [$(4,C), space (4,D), space (4,G)$], [$C space (4)$], [$(4,D), space (4,G), space (9,F)$], [$D space (4)$], [$(4,G), space (9,F) wide "(" G " via " D " would cost 8: not pushed)"$], [$G space (4)$], [$"goal popped: return " A arrow.r B arrow.r E arrow.r G " at cost " 4$]) $

  When $D$ is expanded it offers a route to $G$ costing $4+4=8$, which is worse than the known cost of~4, so nothing is pushed. Equal-cost ties ($C$, $D$, $G$ all at 4) are broken by insertion order, which does not affect the minimum cost.
]

#note[
  UCS is a version of #term[Dijkstra’s algorithm]. Edsger Dijkstra, a Dutch computer scientist, worked it out in about twenty minutes on a café terrace in Amsterdam and published it in 1959. Route planners use the same idea on road networks, where the cells become junctions and the battery becomes minutes of driving.
]

== Comparing the methods so far

#note[
  BFS orders the frontier by discovery time, DFS by recency, UCS by accumulated cost. The graph, the successor function and the goal test never change. Only the frontier policy does, and that single choice is the name of the algorithm.
]

In the table below, #emph[Rain] is the battery the returned route costs on the rainy maze, against a battery of 15, and #emph[Cells] is the number of cells expanded.

#utptable[
  #tabularx(
    columns: (13%, 13%, 16%, 1fr, 8%, 6%),
    align: (center, center, center, left, center, center),
    styles: (navy-bold,),
    header: ([Method], [Take next], [The list], [What it optimises], [Rain], [Cells]),
    [BFS], [Oldest], [Queue (`deque`)], [Fewest steps; every step counts as one], [19], [45],
    [DFS], [Newest], [Stack (list)], [Nothing: finds #emph[a] path, order dependent], [15], [15],
    [Bidirectional], [Oldest, both ends], [Two queues], [Fewest steps; needs a known goal], [19], [31],
    [UCS], [Lowest $g(n)$], [Priority queue (`heapq`)], [Cheapest total cost], [13], [47],
  )
]

#keepspace(4cm)

#warning[
  #strong[“BFS is optimal”] requires #emph[equal] step costs. BFS returns `KUL -> AMS -> KEF` at 12,274~km; UCS returns `KUL -> HKT -> LED -> HEL -> KEF` at 11,461~km: more legs, fewer kilometres.

  #strong[“DFS is not complete”] concerns infinite spaces or cycles without a seen set. On finite lab graphs, the `parent` dictionary lets DFS terminate and find any reachable goal, though not an optimal path.
]

== What the lab measures

Lab~1 runs each algorithm on three queries and records the following fields.

#utptable[
  #tabularx(
    columns: (20%, 1fr),
    styles: (navy-bold,),
    header: ([Field], [What it tells you]),
    [`hops`, `path_cost_km`], [The two objectives. Compare BFS on the first, UCS on the second.],
    [`expanded`], [States whose successors were generated: machine-independent effort.],
    [`max_frontier`], [Peak memory demand in states; the space row of the scorecard, measured.],
    [`runtime_ms`], [Wall-clock time. Useful within one machine, meaningless across machines.],
    [`path`], [The evidence. Every leg must exist in the graph and the legs must sum to the cost.],
  )
]

Validate results independently: Lab~1 checks every returned leg against the graph and recomputes its cost from the edge list, catching impossible paths before reporting them.

#example[
  The three queries of Lab~1, as the notebook reports them:

  $ #table(columns: 7, stroke: none, inset: (x: 5pt, y: 2.6pt), align: (left, right, right, right, right, right, right), table.vline(x: 1, stroke: 0.4pt), table.vline(x: 3, stroke: 0.4pt), table.vline(x: 5, stroke: 0.4pt), [$$], table.cell(colspan: 2, align: center)[$"BFS"$], table.cell(colspan: 2, align: center)[$"DFS"$], table.cell(colspan: 2, align: center)[$"UCS"$], [$"query"$], [$"hops"$], [$"km"$], [$"hops"$], [$"km"$], [$"hops"$], [$"km"$], table.hline(y: 2, stroke: 0.4pt), [$"KUL" arrow.r "KEF"$], [$2$], [$12(,)274$], [$23$], [$41(,)768$], [$4$], [$11(,)461$], [$"SIN" arrow.r "EZE"$], [$2$], [$21(,)976$], [$39$], [$65(,)214$], [$3$], [$17(,)817$], [$"NRT" arrow.r "CPT"$], [$2$], [$19(,)006$], [$64$], [$91(,)541$], [$3$], [$14(,)813$]) $

  BFS minimises hops, UCS kilometres, and DFS neither. UCS uses one or two extra legs to save 800--4,200~km.
]

#summary[
  - A search problem is five pieces: initial state, actions, transition model, goal test and path cost. Search means planning a route through the state space before moving.
  - A search tree forgets where it has been; a search graph remembers, and that memory is what keeps the work bounded.
  - Every search here is one loop around a to-do list called the frontier. Take the oldest and you have BFS, the newest and you have DFS, the cheapest and you have UCS.
  - BFS finds the fewest steps, UCS the lowest cost, and DFS only some route. Two ripples can replace one when the goal is known.
  - Judge any search on completeness, optimality, time and space, and count expansions rather than milliseconds.
]

#questions[
  + Why does BFS ignore the distances stored in the graph even though they are available to it?
  + Which two lines change when `bfs` is turned into `dfs`, and which of them makes DFS order dependent?
  + UCS tests for the goal when a state is popped from the heap. What could go wrong if it tested when the state was first generated?
  + Lab~1 reports `expanded` and `runtime_ms`. Which one should you use to compare BFS and UCS with a classmate’s run on a different laptop, and why?
  + In the rain, why does the robot run out of battery if it follows the route BFS returns, and at which cell?
]
