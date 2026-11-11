#import "/.shared/typst/utp.typ": *

#strong[Program 1: Graph storage, BFS, DFS, and exact-length paths.]

#strong[File:] `graph_traversal.cpp`.

#strong[Chapter connection:] Adjacency list; Breadth-first search; Depth-first search.

Store an undirected edge in both lists. BFS marks on enqueue; DFS records on entry. The exact-length simple-path search uses branch-local markers and undoes a failed branch. Stored neighbour order determines the printed traversal order.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-graph_traversal.typ"


+ #strong[Headers and initial definitions.]

`graph_traversal.cpp` --- lines 16--29.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 16, last: 29, lang: "text")

+ #strong[Implement bfs, visited, dfs.]

`graph_traversal.cpp` --- lines 30--62.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/bfs.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 30, last: 62, lang: "text")

+ #strong[Implement dfsStack, visited, pathOfLength.]

`graph_traversal.cpp` --- lines 63--97.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-dfs-code.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 63, last: 97, lang: "text")

+ #strong[Connect the test cases in main.]

`graph_traversal.cpp` --- lines 98--133.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-graph-storage.typ"


#strong[Trace checkpoint for the supplied main.] The given seven undirected edges create fourteen adjacency entries. BFS marks discoveries so cycles do not enqueue a vertex repeatedly. DFS follows the stored neighbour order; reversing lists changes the visiting sequence without changing the reachable set. Distinguish global visited for traversal from onPath in the simple-path search, where backtracking must release the current branch's mark.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 98, last: 133, lang: "text")

+ #strong[Compare traversal orders and reverse neighbour order.]

`graph_traversal.cpp` --- lines 134--163. Continue in the same file; do not add another header or opening brace.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 134, last: 163, lang: "text")

+ #strong[Test exact-length paths with fresh visit markers.]

`graph_traversal.cpp` --- lines 164--181. Continue in the same file; do not add another header or opening brace.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-path.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/graph_traversal.cpp", first: 164, last: 181, lang: "text")

#strong[Build, run, and inspect graph\_traversal.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra graph_traversal.cpp -o graph_traversal.exe\n\n.\\graph_traversal.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Adjacency list (5 vertices, 7 edges) ==\n  A: B C D \n  B: A D E \n  C: A D \n  D: A B C E \n  E: B D \n  [ok]   every edge is stored in both endpoints' lists exactly once (undirected)\n  [ok]   the degree sum is twice the edge count\n\n== Traversals from A ==\n  BFS (queue):          A B C D E \n  DFS (recursion):      A B D C E \n  DFS (explicit stack): A B D C E \n  [ok]   BFS gives A B C D E: all of A's neighbours before E\n  [ok]   DFS gives A B D C E: it follows one branch as deep as it can", lang: "text")

The complete captured run is in `labs/outputs/graph_traversal.txt`.

#callout("tryit", title: [Try it yourself])[Reverse neighbour order and repeat both traversals. For the exact-length path A to E, lengths 1 and 5 must fail; 2 and 4 have simple paths. Reset markers before each new query.]
