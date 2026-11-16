#import "/.shared/typst/utp.typ": *

#strong[Program 1: Graph storage, BFS, DFS, and exact-length paths.]

#strong[File:] `graph_traversal.cpp`.

#strong[Chapter connection:] Adjacency list; Breadth-first search; Depth-first search.

Store an undirected edge in both lists. BFS marks on enqueue; DFS records on entry. The exact-length simple-path search uses branch-local markers and undoes a failed branch. Stored neighbour order determines the printed traversal order.

#include "../visuals/program-graph_traversal.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`graph_traversal.cpp` --- lines 16--29.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 16, last: 29, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement bfs, visited, dfs.]
]

`graph_traversal.cpp` --- lines 30--62.

#include "../visuals/bfs.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 30, last: 62, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Implement dfsStack, visited, pathOfLength.]
]

`graph_traversal.cpp` --- lines 63--97.

#include "../visuals/walk-dfs-code.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 63, last: 97, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Connect the test cases in main.]
]

`graph_traversal.cpp` --- lines 98--133.

#include "../visuals/walk-graph-storage.typ"

#strong[Trace checkpoint for the supplied main.] The given seven undirected edges create fourteen adjacency entries. BFS marks discoveries so cycles do not enqueue a vertex repeatedly. DFS follows the stored neighbour order; reversing lists changes the visiting sequence without changing the reachable set. Distinguish global visited for traversal from onPath in the simple-path search, where backtracking must release the current branch’s mark.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 98, last: 133, lang: "cpp")

#colbreak()

#utpsteps[
  5. #strong[Compare traversal orders and reverse neighbour order.]
]

`graph_traversal.cpp` --- lines 134--163. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 134, last: 163, lang: "cpp")

#colbreak()

#utpsteps[
  6. #strong[Test exact-length paths with fresh visit markers.]
]

`graph_traversal.cpp` --- lines 164--181. Continue in the same file; do not add another header or opening brace.

#include "../visuals/walk-path.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 164, last: 181, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect graph\_traversal.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra graph_traversal.cpp -o graph_traversal.exe

.\graph_traversal.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/graph_traversal.txt`.

#exercises[
  Reverse neighbour order and repeat both traversals. For the exact-length path A to E, lengths 1 and 5 must fail; 2 and 4 have simple paths. Reset markers before each new query.
]
