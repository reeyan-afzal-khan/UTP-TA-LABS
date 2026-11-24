#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: Graph storage, BFS, DFS, and exact-length paths])

#strong[File:] `graph_traversal.cpp`.

#strong[Chapter connection:] Adjacency list; Breadth-first search; Depth-first search.

Store an undirected edge in both lists. BFS marks on enqueue; DFS records on entry. The exact-length simple-path search uses branch-local markers and undoes a failed branch. Stored neighbour order determines the printed traversal order.

#include "../visuals/program-graph_traversal.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `graph_traversal.cpp` --- lines 16--29.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 16, last: 29, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement bfs, visited, dfs.]
  ]

  `graph_traversal.cpp` --- lines 30--62.
]

#include "../visuals/bfs.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 30, last: 62, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Implement dfsStack, visited, pathOfLength.]
  ]

  `graph_traversal.cpp` --- lines 63--97.
]

#include "../visuals/walk-dfs-code.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 63, last: 97, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Connect the test cases in main.]
  ]

  `graph_traversal.cpp` --- lines 98--133.
]

#include "../visuals/walk-graph-storage.typ"

#strong[Trace checkpoint for the supplied main.] The given seven undirected edges create fourteen adjacency entries. BFS marks discoveries so cycles do not enqueue a vertex repeatedly. DFS follows the stored neighbour order; reversing lists changes the visiting sequence without changing the reachable set. Distinguish global visited for traversal from onPath in the simple-path search, where backtracking must release the current branch’s mark.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 98, last: 133, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    5. #strong[Compare traversal orders and reverse neighbour order.]
  ]

  `graph_traversal.cpp` --- lines 134--163. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 134, last: 163, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    6. #strong[Test exact-length paths with fresh visit markers.]
  ]

  `graph_traversal.cpp` --- lines 164--181. Continue in the same file; do not add another header or opening brace.
]

#include "../visuals/walk-path.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 164, last: 181, lang: "cpp")

#strong[Queue versus stack, on one graph.] BFS and DFS both start at A and read each neighbour list in the same order. The only difference is the container that holds the vertices waiting their turn.

```terminal
== Adjacency list (5 vertices, 7 edges) ==
  A: B C D
  B: A D E
  C: A D
  D: A B C E
  E: B D
  [ok]   every edge is stored in both endpoints' lists exactly once (undirected)
  [ok]   the degree sum is twice the edge count
== Traversals from A ==
  BFS (queue):          A B C D E
  DFS (recursion):      A B D C E
  DFS (explicit stack): A B D C E
  [ok]   BFS gives A B C D E: all of A's neighbours before E
  [ok]   DFS gives A B D C E: it follows one branch as deep as it can
  [ok]   recursive and explicit-stack DFS agree
  [ok]   each vertex is visited exactly once although the graph has cycles
== Try it: reverse every adjacency list and traverse again ==
  A: D C B
  B: E D A
  C: D A
  D: E C B A
  E: D B
  BFS: A D C B E    DFS: A D E B C
  [ok]   the visiting ORDER changes with the list order
  [ok]   the SET of vertices reached does not
== Path of a given length from A to E ==
  length 1: no
  length 2: yes, A B E
  length 3: yes, A B D E
  length 4: yes, A C D B E
  length 5: no
  [ok]   no path of length 1 (A and E are not adjacent)
  [ok]   a path of length 4 visits all five vertices
  [ok]   no simple path of length 5 exists in a 5-vertex graph
```

BFS takes A's three neighbours, B, C and D, before it reaches E, two edges away. DFS goes from A to B and on to B's first unvisited neighbour, D, then to C; C has nothing new left, so the search backs up to D and takes E. Reversing every list changes both orders but not the set of vertices reached: the order belongs to the stored lists, not to the graph. The degree sum, 3~+~3~+~2~+~4~+~2~=~14, is twice the 7 edges because every undirected edge sits in two lists.

#strong[Reuse the markers and watch it fail.] Ask `pathOfLength` for a path from C to E of length 2 (C D E), then of length 3 (C A B E). Use one `onPath` vector for both calls and mark C before the first call only. The second call fails although the path exists: the first search succeeded and returned without clearing its marks, so D and E still look used. Give each query a fresh vector, as `main` does, and both succeed.
