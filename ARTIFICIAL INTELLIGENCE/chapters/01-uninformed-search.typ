#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-uninformed-search")


#heading(level: 1)[Uninformed Search: BFS, DFS, and Uniform-Cost Search]
 <ch:uninformed>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Read a graph drawn as nodes and edges, and use a Python list, set, dictionary and `for` loop.

*By the end, you can:* write any route-finding task down as a search problem; explain the search loop and its to-do list; trace BFS, DFS and UCS by hand; say which quantity each one optimises; read the search code in `utils/core.py`; and judge a search by completeness, optimality, time and memory.]

In 1997 a computer beat the world chess champion, Garry Kasparov. In 2016 another beat Lee Sedol, one of the strongest Go players alive. Every time your phone finds the fastest way home, a third program is at work. Underneath, all three do one thing: they #strong[search].

The names that come with search (breadth-first, uniform-cost, A$""^star.op$, minimax) are usually taught one chapter at a time, so they feel like separate tricks. They are not. Almost every search in this book is the same short loop, and one line in that loop decides what to look at next. This chapter builds the loop on a small robot in a small maze, small enough to check every step by hand, and then moves the same code to the real question of Lab~1: #emph[how do you fly from Kuala Lumpur to Keflavík without a direct flight?]

Five questions organise all the search material in the book. By the last chapter you will have met every search in the table below and seen how each one grows out of the same loop.

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([], [The question], [The searches that answer it], [Where],),
    table.hline(),
    [1], [How do we find any route at all?], [Breadth-first, depth-first, bidirectional], [Chapter~#ref(label("ch:uninformed"), supplement: none)],
    [2], [How do we find the cheapest route?], [Uniform-cost (Dijkstra's algorithm)], [Chapter~#ref(label("ch:uninformed"), supplement: none)],
    [3], [How do we explore fewer states?], [Greedy best-first, A$""^star.op$], [Chapter~#ref(label("ch:informed"), supplement: none)],
    [4], [What if only the final answer counts?], [Hill climbing, simulated annealing, beam search, genetic algorithms], [Chapters~#ref(label("ch:localsearch"), supplement: none)--#ref(label("ch:ga"), supplement: none)],
    [5], [What if someone fights back?], [Minimax, Monte Carlo Tree Search], [Chapter~#ref(label("ch:games"), supplement: none)],
  )]
  , kind: table
  )


#heading(level: 2)[A robot, a battery and a maze]


A small robot is stranded on the far side of a maze and has to reach its charger. Its battery holds 15 units, and every step onto a floor cell uses one (#ref(label("fig:robot-maze"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/46885276f185cc1f.svg")], caption: [The maze seen from above. R is the robot, C its charger, and dark cells are walls. We name a cell by its row and column, counting from zero at the top left, so the robot starts at $\( 5 \, 1 \)$ and the charger sits at $\( 2 \, 9 \)$.]) <fig:robot-maze>

We can see the whole maze at once, so the answer looks obvious to us. A planner cannot rely on that. A real maze may have thousands of corridors and a road network has millions of junctions, so we want one method that solves any of them.

Suppose the robot simply wanders, picking a random direction at every cell. Over 10,000 simulated walks it needs 315 steps on average to stumble onto a charger that is only 11 steps away. With 15 units of battery it stops long before that. So the robot should think before it moves: it has the map, so it can work out a whole route in its head and then drive it once. Planning a route ahead of time like this is what AI calls #strong[search].

#callout("intuition", title: [Conceptual intuition])[Watch a search program run and nothing looks brilliant. It tries possibilities one after another, very fast. All of the intelligence sits in one decision, repeated over and over: #emph[which possibility do I try next?] That decision is the whole difference between one search algorithm and another.]


#heading(level: 2)[Writing the problem down]


Before one method can solve any maze, any maze has to be written down the same way. Start with the idea of a #strong[state]: a snapshot of everything that matters right now. For our robot that is a single fact, which cell it is on, so the maze has 48 states. Draw a dot for each state and a line between any two cells one step apart, and the walls disappear (#ref(label("fig:state-space"), supplement: [Figure])). What remains is the #strong[state space]. Searching means finding a path through those dots, from the robot's dot to the charger's.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/42ccb062f3bf9899.svg")], caption: [The same maze twice. Left: as the robot sees it. Right: as the search sees it, one dot per state and one line per possible step. Nothing about walls survives except which lines are missing.]) <fig:state-space>

Five pieces turn a state space into a #strong[search problem]. Writing them down is called #strong[problem formulation], and it is the first thing to do with any new problem.

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Piece], [Question it answers], [Robot maze], [Lab~1 airline network],),
    table.hline(),
    [Initial state], [Where do we start?], [Cell $\( 5 \, 1 \)$], [The origin airport, named by its IATA code (`KUL`)],
    [Actions], [What can we do here?], [Step up, right, down or left], [Take any direct route out of this airport],
    [Transition model], [Where does an action lead?], [One cell over; a step into a wall goes nowhere], [The destination of that route],
    [Goal test], [Are we done?], [Am I on the charger?], [Is this the destination airport?],
    [Path cost], [What does a route cost?], [One unit of battery per step], [Number of legs, #emph[or] the sum of great-circle distances in km],
  )]
  , kind: table
  )

Actions and the transition model together give a state's #strong[successors], the states one action away. Code usually stores those directly. In Python the graph is a dictionary from each state to a list of `(neighbour, cost)` pairs, and it has the same shape for a maze and for an airline network:

#code-block("build_graph()[(5, 1)]     # the robot's cell: up, right, down, left\n# [((4, 1), 1.0), ((5, 2), 1.0), ((6, 1), 1.0), ((5, 0), 1.0)]\n\ngraph[\"KUL\"][:3]          # Kuala Lumpur: the first three of its 112 direct routes\n# [('ADL', 5681.8), ('AKL', 8703.4), ('ALA', 5130.5)]", lang: "python")

The cost definition matters more than it looks. BFS and DFS treat each route as one step, while UCS sums kilometres, so "shortest route" means nothing until the cost is stated. The cleaned OpenFlights graph has 6,464 airports and 37,337 directed routes; distance is an educational stand-in for fares, schedules and connection costs.

#callout("intuition", title: [Conceptual intuition])[The problem supplies successors; the search algorithm chooses which state to examine next. Airport details belong to the first job, and the difference between BFS, DFS and UCS belongs to the second. Keeping those jobs apart is why one search function can serve a maze, an airline network and a sliding puzzle.]

The five pieces describe far more than mazes:

#figure(
  align(center)[#table(
    columns: 5,
    align: (left,left,left,left,left,),
    table.header([Problem], [State], [Action], [Goal], [Cost],),
    table.hline(),
    [8-puzzle], [Where the eight tiles sit (181,440 reachable arrangements)], [Slide a tile into the gap], [Tiles in order], [1 per slide],
    [Rubik's cube], [The colour layout (about $4.3 times 10^19$ states)], [Turn one face], [Every face one colour], [1 per turn],
    [Road navigation], [A junction on the road network], [Drive one stretch of road], [The destination], [Minutes of driving],
    [Sudoku], [The grid filled in so far], [Write one digit], [A full grid with no repeats], [None: only the final grid is judged],
    [Predictive text], [The words typed so far], [Add one word], [A finished message], [None: judged on the likely whole message],
    [Chess], [The board and whose turn it is], [One legal move], [Checkmate], [An opponent moves against you],
  )]
  , kind: table
  )

Read the last column from top to bottom. The first three problems charge for every step, and those are the problems of this chapter and the next. Sudoku and predictive text care only about the finished answer, which is question~4 in our table. Chess has someone fighting back, which is question~5.


#heading(level: 2)[Planning with and without a memory]


How does the robot plan? It imagines its moves one at a time. From its cell it can step up, right, down or left, so draw a #strong[search tree] with the start at the top and one branch for each move. Then each branch grows branches of its own. Every path from the top down is one complete plan (#ref(label("fig:search-tree"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/c1871ca30837a4be.svg")], caption: [The first three levels of the search tree from the robot's cell, written as row,column. Every path from the top down is one plan. The red nodes are cells some earlier plan has already reached. A tree has no memory, so it grows them all again; a search graph skips them.]) <fig:search-tree>

Follow the branch "up, then down". The robot is back where it started, and the tree has no idea. It plans those cells again, and again, and that adds up quickly: planned this way, the robot looks at 43,288 plans before it finds the charger, even though the maze has only 48 cells. Most of those plans just shuffle back and forth.

The fix is a memory. The robot writes down every cell it has reached and skips any cell already on that list. Each cell now appears only once, the tree folds back into the map, and the search looks at no more than 48 cells. That version is called a #strong[search graph] (or graph search).

#callout("keyidea", title: [Key idea])[A search tree forgets where it has been. A search graph remembers.]


#heading(level: 2)[The search loop]


How does the robot choose which cell to examine first, and which one next? It keeps a to-do list of the cells it has found but not yet examined. The textbook name for that list is the #strong[frontier]. At the start the list holds only the robot's own cell. Examining a cell then takes three moves:

+ Take one cell off the to-do list.

+ Check it: is this the charger? If so, stop and rebuild the route.

+ If not, put its neighbours on the list, skipping any already reached, and write down which cell each one was reached from.

Repeat until the charger comes off the list. If the list runs empty first, no route exists. We say a cell is #strong[expanded] when step~3 runs on it, and we count those cells for every search; the goal itself is never expanded. #ref(label("fig:search-loop"), supplement: [Figure]) draws the loop.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/2240442f06799c6d.svg")], caption: [The search loop. The frontier is the to-do list. BFS, DFS and UCS share every box; only the highlighted choice differs, and it selects the oldest, newest or cheapest entry respectively.]) <fig:search-loop>

Two bookkeeping choices are shared by every implementation in `utils/core.py`:

/ Parent links instead of copied paths.: #block[
Record each state's predecessor, then follow those links backwards from the goal to rebuild the route. This saves storing a full path in every frontier entry.
]

/ Effort counters.: #block[
Count states `expanded` and the peak size of the frontier. Unlike runtime, these depend only on the graph and the algorithm, so they can be compared between machines.
]

Here is the loop in Python, exactly as the labs run it. The `parent` dictionary does two jobs: it stores the arrows back towards the start, and it is the robot's memory.

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 56, last: 72, lang: "python")

#callout("pitfall", title: [Common mistake])[Mark a state as seen when it is #emph[added] to the frontier, not when it is removed. The `parent` dictionary does this: a state gets a parent the moment it is discovered. Marking on removal lets the same airport be queued many times by different neighbours, which inflates the frontier and, for BFS, can attach a longer path than necessary.]

The rest of this chapter is one question: #emph[which cell do we take off the list?] Every answer has a name.


#heading(level: 2)[Breadth-first search: take the oldest]


The simplest answer is to take the cell that has waited longest. New cells join the back of the list and the front of the list is served next, like people in a line at a shop. That list is a first-in, first-out #strong[queue], and the search is #strong[Breadth-First Search (BFS)].

#callout("workedexample", title: [Worked example])[BFS from the robot's cell. Each row takes the front of the queue and adds any new neighbours to the back, in the order up, right, down, left.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Take], [New cells], [Queue afterwards, front on the left],),
    table.hline(),
    [$\( 5 \, 1 \)$], [$\( 4 \, 1 \)$ $\( 5 \, 2 \)$ $\( 6 \, 1 \)$ $\( 5 \, 0 \)$], [$\( 4 \, 1 \)$ $\( 5 \, 2 \)$ $\( 6 \, 1 \)$ $\( 5 \, 0 \)$],
    [$\( 4 \, 1 \)$], [$\( 3 \, 1 \)$ $\( 4 \, 0 \)$], [$\( 5 \, 2 \)$ $\( 6 \, 1 \)$ $\( 5 \, 0 \)$ $\( 3 \, 1 \)$ $\( 4 \, 0 \)$],
    [$\( 5 \, 2 \)$], [$\( 6 \, 2 \)$], [$\( 6 \, 1 \)$ $\( 5 \, 0 \)$ $\( 3 \, 1 \)$ $\( 4 \, 0 \)$ $\( 6 \, 2 \)$],
    [$\( 6 \, 1 \)$], [none], [$\( 5 \, 0 \)$ $\( 3 \, 1 \)$ $\( 4 \, 0 \)$ $\( 6 \, 2 \)$],
    [$\( 5 \, 0 \)$], [none], [$\( 3 \, 1 \)$ $\( 4 \, 0 \)$ $\( 6 \, 2 \)$],
    [$\( 3 \, 1 \)$], [$\( 2 \, 1 \)$ $\( 3 \, 2 \)$], [$\( 4 \, 0 \)$ $\( 6 \, 2 \)$ $\( 2 \, 1 \)$ $\( 3 \, 2 \)$],
  )]
  , kind: table
  )

Every cell one step from the robot is examined before any cell two steps away. After the fifth row the queue holds exactly the cells two steps away.]

#callout("analogy", title: [Analogy])[Drop a stone into a still pond. The ripple spreads outward in a circle and touches every point one step away before any point two steps away. BFS spreads the same way, ring by ring. If you use LinkedIn you have already seen these rings: your first-degree connections are the people you know, second-degree connections are the people they know, and third-degree is the next ring out.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/536969beae95f752.svg")], caption: [Each number is the step at which BFS first reaches that cell, and the tint deepens with distance. The ripple touches the charger on ring 11. Following the parent links back from the charger gives the orange route.]) <fig:bfs-wave>

BFS finds the 11-step route after expanding 45 of the 48 cells. Only three are spared: the charger, and two cells still waiting in the queue when the charger came off it.

#callout("keyidea", title: [Key idea])[Oldest first means nearest first, and nearest first means the fewest steps. That guarantee comes straight from the shape of the list.]

#callout("workedexample", title: [Worked example])[BFS from `KUL` to `KEF` expands 284 airports and returns `KUL -> AMS -> KEF`: two legs, 12,274~km. This minimises legs, not kilometres. BFS never reads the distances stored in the graph.]


#heading(level: 2)[Depth-first search: take the newest]


BFS explored nearly the whole maze. Another answer is to take the newest cell instead. The list now behaves like a pile of plates: the last plate put on is the first one taken off. That list is a #strong[stack], and the search is #strong[Depth-First Search (DFS)]. #ref(label("fig:queue-stack"), supplement: [Figure]) puts the two lists side by side at the same moment.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/4919c3f554d2a95b.svg")], caption: [The same five cells on two kinds of to-do list, just after the robot's cell and $\( 4 \, 1 \)$ have been examined. The queue serves its oldest entry next, $\( 5 \, 2 \)$. The stack serves its newest, $\( 3 \, 1 \)$, right beside the cell just examined. That single difference separates BFS from DFS.]) <fig:queue-stack>

Because the next pick is always right beside the last one, DFS dives down one corridor as far as it can before it tries another, and it backs up only when it runs out of new cells. On our maze, with neighbours listed up, right, down, left, it runs straight up the left side, along the top and down to the charger (#ref(label("fig:bfs-dfs-routes"), supplement: [Figure])). It expands only 15 cells. But its route also takes 15 steps, so the robot reaches the charger with its battery at exactly zero.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/c05904d335e9b6a9.svg")], caption: [Blue cells were expanded. BFS expands 45 cells and returns the shortest route, 11 steps. DFS expands 15 cells and returns a 15-step route. DFS looked at far less of the maze and paid for it in route length.]) <fig:bfs-dfs-routes>

That result is partly luck. Reverse the neighbour order to left, down, right, up and DFS expands 36 cells and returns a 33-step route, far beyond the battery. In `utils/core.py` the code differs from BFS in two lines: `frontier.pop()` takes the newest entry, and the successors are pushed in reverse order so that the first listed neighbour is popped first. That second line is why DFS is #strong[order dependent]. It commits to whichever neighbour the graph happens to list first and reconsiders only when that whole branch fails.

#ref(label("fig:bfs-dfs-order"), supplement: [Figure]) shows the same contrast on a tree small enough to read at a glance.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/9e5cabb6b91b13e6.svg")], caption: [Numbered visit orders on one tree. BFS completes each level; DFS exhausts B\'s subtree before C. After A and B have been visited, both lists hold the same three states, but in a different order, so each serves a different state next.]) <fig:bfs-dfs-order>

#callout("workedexample", title: [Worked example])[From `KUL`, DFS commits to the alphabetically first neighbour, `ADL` (Adelaide), then to Adelaide's first neighbour, and so on. It reaches Keflavík after 23 legs and 41,768~km, more than the circumference of the Earth, and expands 2,112 airports on the way, far more than the 284 of BFS. Reversing every neighbour list gives a different route of 8 legs. Neither is a meaningful travel plan: DFS answers "is there #emph[a] route?", not "what is a good one?".]

#callout("intuition", title: [Conceptual intuition])[BFS expands a ripple; DFS follows one thread. The ripple is expensive to store but arrives by the fewest steps. The thread can be cheap to store but says nothing about how good its path is.]


#heading(level: 2)[A fair way to compare searches]


We now have two ways to choose, and more are coming, so we need a fair comparison. Textbooks judge a search on four properties. Think of them as a scorecard that every new search has to fill in.

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Property], [The question], [BFS on maze], [DFS on maze],),
    table.hline(),
    [Complete], [If a route exists, is it guaranteed to be found?], [Yes], [Yes (finite, with memory)],
    [Optimal], [Is the route it returns the cheapest?], [Yes, 11 steps], [No, 15 steps],
    [Time], [How many states does it expand?], [45], [15],
    [Space], [How many states must it hold at once? (peak frontier)], [6], [12],
  )]
  , kind: table
  )

The space row may surprise you, because the usual advice is that DFS needs less memory. On a narrow maze the ripple is only ever a few cells wide, while DFS leaves untried side branches behind on its pile. On the bushy airline network the usual advice holds: from `KUL` to `KEF` the BFS frontier peaks at 1,679 airports and the DFS frontier at 859. The formal results below describe large spaces. Small problems can go either way, so measure.

For the formal version, write $b$ for the #strong[branching factor] (successors per state), $d$ for the depth of the shallowest goal, and $m$ for the maximum depth of the space.

#figure(
  align(center)[#table(
    columns: 5,
    align: (left,left,left,left,left,),
    table.header([Method], [Complete?], [Optimal?], [Time], [Space],),
    table.hline(),
    [BFS], [Yes, if $b$ is finite], [Only when every step costs the same], [$O \( b^d \)$], [$O \( b^d \)$],
    [DFS], [Not in general], [No], [$O \( b^m \)$], [$O \( b m \)$],
    [UCS], [Yes, if step costs $gt.eq epsilon > 0$], [Yes, for non-negative costs], [$O \( b^(1 + floor.l C^star.op \/ epsilon floor.r) \)$], [same as time],
  )]
  , kind: table
  )

Here $C^star.op$ is the cost of the optimal solution and $epsilon$ the smallest step cost. The $O \( b m \)$ assumes DFS keeps only its current path and untried siblings. The version in `core.py` also keeps the `parent` table, which is what makes it safe on graphs with cycles, so it stores more than that.

#ref(label("fig:branching"), supplement: [Figure]) shows what $O \( b^d \)$ means in practice. At branching factor 3 a goal eight levels down leaves about 9,800 states in memory; at branching factor 5 the same depth needs nearly 500,000. The airline graph has a mean branching factor near 6, but its largest hubs have more than 200 routes each (Frankfurt has 239). That is why the frontier in Lab~1 reaches 1,679 airports for a two-leg BFS answer.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/361f0fecbd19d9b6.svg")], caption: [States a BFS frontier may hold at depth $d$, for three branching factors. The vertical axis is logarithmic, so each straight line is exponential growth. DFS, keeping only its current path, stores $O \( b m \)$, which on these scales is a nearly flat line at the bottom.]) <fig:branching>


#heading(level: 2)[Bidirectional search: two ripples]


BFS kept the 11-step route, but its ripple filled 45 of the 48 cells, because it had to grow all the way from the robot to the charger. Can we keep the route and explore less? Start a second ripple from the charger. The two take turns, one ring each, and stop the moment they touch. At the meeting cell we join the robot's half to the charger's half. That is #strong[bidirectional search].

#callout("analogy", title: [Analogy])[Two tunnelling crews start from opposite sides of a mountain and meet in the middle. Neither crew digs the whole tunnel. Ripples behave the same way, only more so, because a ripple covers more and more ground the further it spreads: two small ripples that each go halfway cover much less ground than one big ripple that goes all the way.]

On our maze the ripples touch at $\( 3 \, 5 \)$ with the route still 11 steps long, after expanding 18 cells on the robot's side and 13 on the charger's: 31 in all, against 45 for BFS. The saving is modest here because the maze's rings are small. On a problem whose rings grow quickly the saving is enormous. The 8-puzzle board traced in `all_experiments/demo_sliding_puzzle.py` needs 22 slides: one ripple expands 89,296 arrangements, and two ripples expand 1,240 (#ref(label("fig:bidirectional"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/1a38fff4b926b476.svg") #diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/b4cb9485c702e738.svg")], caption: [Left: the two ripples on the maze, robot side in blue and charger side in teal, touching at the orange cell. Right: how many 8-puzzle arrangements lie in each ring around the traced board. Rings grow by a factor of about 1.56 each, so most of the work sits in the last few. Two ripples that each stop near the halfway line never reach them.]) <fig:bidirectional>

#callout("pitfall", title: [Common mistake])[Bidirectional search needs to know exactly where the goal is, so the second ripple has somewhere to start, and it must be able to run backwards. A maze has one charger. A chess game has countless ways to end in checkmate, and nobody can start a ripple from all of them. On the airline network routes are one-way, so a backward ripple has to follow reversed edges, which is how Lab~2 builds its exact cost table.]

#callout("tryit", title: [Practice])[Run `python all_experiments/demo_robot_maze.py` from the course folder and find each number from this chapter in its output. Then copy the file, set `CHECK_BOOK_NUMBERS = False`, turn the floor cell at $\( 3 \, 3 \)$ into a wall, and predict before running: what does BFS return now? Its ripple can no longer use the middle corridor, so the answer should be the 13-step route along the bottom.]


#heading(level: 2)[Uniform-cost search: take the cheapest]


So far every step has cost the same, so the fewest steps was also the cheapest route and BFS was optimal. Now it starts to rain. Two puddles form in the middle corridor, marked in #ref(label("fig:rain-routes"), supplement: [Figure]), and splashing through one drains 5 units of battery instead of 1.

BFS does not know about battery. It only counts steps, so it still takes its 11-step route through both puddles: nine dry steps plus two puddles, $9 + 5 + 5 = 19$ units. The battery holds 15, so the robot runs dry at $\( 3 \, 6 \)$, four cells short of the charger. Yet a better route exists along the bottom: 13 steps, all dry, 13 units, and the robot arrives with 2 to spare.

#callout("keyidea", title: [Key idea])[Fewest steps does not mean cheapest. To find the cheapest route, a search has to count what it spends.]

So choose by battery: take the cell with the least battery spent so far. That is #strong[Uniform-Cost Search (UCS)]. The battery spent so far gets a short name, $g$, written $g \( n \)$ for cell $n$. "Uniform" does not mean every step costs the same. It means the search spreads in waves of equal battery spent, the way BFS spreads in rings of equal steps.

The loop stays the same. The big change is the list: UCS keeps its frontier in a #strong[priority queue], which always hands back the cell with the smallest $g$ no matter when it joined. Think of an emergency ward, where patients are seen by urgency and not by arrival time. #ref(label("fig:three-lists"), supplement: [Figure]) shows a real moment from the rainy maze. The puddle cell $\( 3 \, 2 \)$ has already joined the list, but at $g = 7$ it waits behind everything cheaper.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/eac269074d0225c5.svg")], caption: [The UCS frontier just after $\( 3 \, 1 \)$ has been expanded on the rainy maze. Cells are served by the battery spent to reach them, smallest first, and the join order breaks ties. The puddle cell waits behind every cheaper dry cell, including cells that will join later.]) <fig:three-lists>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/c37ac50abc85d47d.svg")], caption: [The rainy maze. Left: the three routes home, with the battery each one costs. Right: the battery UCS spends to reach each cell. Cost climbs sharply across the puddles at $\( 3 \, 2 \)$ and $\( 3 \, 4 \)$, so the wave coming from the bottom reaches $\( 3 \, 7 \)$ with $g = 10$ first.]) <fig:rain-routes>

UCS needs two small changes to the BFS loop. It adds a table of $g$ values, adding each step's cost as it goes. And it changes the memory check: in the rain, the first way we find to a cell is not always the cheapest, so when a cheaper way turns up we write down the new $g$ and the new parent and put the cell on the list again. In `utils/core.py`, UCS, GBFS and A$""^star.op$ share one function, `best_first`, because they differ only in the priority they attach to a frontier entry. The frontier is a Python `heapq` of tuples `(priority, counter, state, g)`:

#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 118, last: 132, lang: "python")

Three details in that loop are easy to miss. Test for the goal when a state is #emph[popped], not when it is generated, or you may return the first path found rather than the cheapest. A cheaper path may leave an older, costlier entry for the same state behind in the heap, and `expanded_states` skips those stale copies. The `counter` breaks priority ties by insertion order without comparing states, which may not even be comparable (#ref(label("ch:searchpatterns"), supplement: [Chapter])).

Why is the result always the cheapest route? UCS examines cells in order of battery spent, so it cannot take the charger off the list by an expensive route while a cheaper route is still waiting. Cheapest first means the cheapest route, provided no step has a negative cost.

#ref(label("fig:ucs-vs-bfs"), supplement: [Figure]) shows BFS and UCS disagreeing on a smaller graph. Both routes use three edges, so BFS has no reason to prefer either; UCS adds the weights and finds that one costs twice the other.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/ef4aa6020d664efb.svg")], caption: [The same weighted graph solved twice. BFS returns the first three-edge path it meets, costing 8. UCS orders its frontier by accumulated cost $g \( n \)$ and returns the three-edge path costing 4. Neither is wrong; they answer different questions.]) <fig:ucs-vs-bfs>

#callout("workedexample", title: [Worked example])[Trace UCS on the graph of #ref(label("fig:ucs-vs-bfs"), supplement: [Figure]). The frontier holds $\( g \, upright("state") \)$ pairs and always pops the smallest $g$. $ upright("expand") & upright("frontier after expansion")\
A med \( 0 \) & \( 1 \, B \) \, med \( 4 \, C \)\
B med \( 1 \) & \( 3 \, E \) \, med \( 4 \, C \) \, med \( 4 \, D \)\
E med \( 3 \) & \( 4 \, C \) \, med \( 4 \, D \) \, med \( 4 \, G \)\
C med \( 4 \) & \( 4 \, D \) \, med \( 4 \, G \) \, med \( 9 \, F \)\
D med \( 4 \) & \( 4 \, G \) \, med \( 9 \, F \) #h(2em) upright("(") G upright(" via ") D upright(" would cost 8: not pushed)")\
G med \( 4 \) & upright("goal popped: return ") A arrow.r B arrow.r E arrow.r G upright(" at cost ") 4 $ When $D$ is expanded it offers a route to $G$ costing $4 + 4 = 8$, which is worse than the known cost of~4, so nothing is pushed. Equal-cost ties ($C$, $D$, $G$ all at 4) are broken by insertion order, which does not affect the minimum cost.]

#callout("libnote", title: [Reference note])[UCS is a version of #strong[Dijkstra's algorithm]. Edsger Dijkstra, a Dutch computer scientist, worked it out in about twenty minutes on a café terrace in Amsterdam and published it in 1959. Route planners use the same idea on road networks, where the cells become junctions and the battery becomes minutes of driving.]


#heading(level: 2)[Comparing the methods so far]


#callout("keyidea", title: [Key idea])[BFS orders the frontier by discovery time, DFS by recency, UCS by accumulated cost. The graph, the successor function and the goal test never change. Only the frontier policy does, and that single choice is the name of the algorithm.]

In the table below, #emph[Rain] is the battery the returned route costs on the rainy maze, against a battery of 15, and #emph[Cells] is the number of cells expanded.

#figure(
  align(center)[#table(
    columns: 6,
    align: (left,left,left,left,left,left,),
    table.header([Method], [Take next], [The list], [What it optimises], [Rain], [Cells],),
    table.hline(),
    [BFS], [Oldest], [Queue (`deque`)], [Fewest steps; every step counts as one], [19], [45],
    [DFS], [Newest], [Stack (list)], [Nothing: finds #emph[a] path, order dependent], [15], [15],
    [Bidirectional], [Oldest, both ends], [Two queues], [Fewest steps; needs a known goal], [19], [31],
    [UCS], [Lowest $g \( n \)$], [Priority queue (`heapq`)], [Cheapest total cost], [13], [47],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[#strong["BFS is optimal"] requires #emph[equal] step costs. BFS returns `KUL -> AMS -> KEF` at 12,274~km; UCS returns `KUL -> HKT -> LED -> HEL -> KEF` at 11,461~km: more legs, fewer kilometres.

#strong["DFS is not complete"] concerns infinite spaces or cycles without a seen set. On finite lab graphs, the `parent` dictionary lets DFS terminate and find any reachable goal, though not an optimal path.]


#heading(level: 2)[What the lab measures]


Lab~1 runs each algorithm on three queries and records the following fields.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Field], [What it tells you],),
    table.hline(),
    [`hops`, `path_cost_km`], [The two objectives. Compare BFS on the first, UCS on the second.],
    [`expanded`], [States whose successors were generated: machine-independent effort.],
    [`max_frontier`], [Peak memory demand in states; the space row of the scorecard, measured.],
    [`runtime_ms`], [Wall-clock time. Useful within one machine, meaningless across machines.],
    [`path`], [The evidence. Every leg must exist in the graph and the legs must sum to the cost.],
  )]
  , kind: table
  )

Validate results independently: Lab~1 checks every returned leg against the graph and recomputes its cost from the edge list, catching impossible paths before reporting them.

#callout("workedexample", title: [Worked example])[The three queries of Lab~1, as the notebook reports them: #figure(
  align(center)[#table(
    columns: 7,
    align: (left,right,right,right,right,right,right,),
    [], table.cell(align: center, colspan: 2)[BFS], table.cell(align: center, colspan: 2)[DFS], table.cell(align: center, colspan: 2)[UCS],
    [query], [hops], [km], [hops], [km], [hops], [km],
    [KUL → KEF], [2], [12,274], [23], [41,768], [4], [11,461],
    [SIN → EZE], [2], [21,976], [39], [65,214], [3], [17,817],
    [NRT → CPT], [2], [19,006], [64], [91,541], [3], [14,813],
  )]
  , kind: table
  ) BFS minimises hops, UCS kilometres, and DFS neither. UCS uses one or two extra legs to save 800--4,200~km.]

#callout("chapterrecap", title: [Chapter recap])[- A search problem is five pieces: initial state, actions, transition model, goal test and path cost. Search means planning a route through the state space before moving.

- A search tree forgets where it has been; a search graph remembers, and that memory is what keeps the work bounded.

- Every search here is one loop around a to-do list called the frontier. Take the oldest and you have BFS, the newest and you have DFS, the cheapest and you have UCS.

- BFS finds the fewest steps, UCS the lowest cost, and DFS only some route. Two ripples can replace one when the goal is known.

- Judge any search on completeness, optimality, time and space, and count expansions rather than milliseconds.]

#callout("quickcheck", title: [Check your understanding])[+ Why does BFS ignore the distances stored in the graph even though they are available to it?

+ Which two lines change when `bfs` is turned into `dfs`, and which of them makes DFS order dependent?

+ UCS tests for the goal when a state is popped from the heap. What could go wrong if it tested when the state was first generated?

+ Lab~1 reports `expanded` and `runtime_ms`. Which one should you use to compare BFS and UCS with a classmate's run on a different laptop, and why?

+ In the rain, why does the robot run out of battery if it follows the route BFS returns, and at which cell?]
