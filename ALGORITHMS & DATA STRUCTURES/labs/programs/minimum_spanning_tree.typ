#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 2: A complete Kruskal program])

#strong[File:] `minimum_spanning_tree.cpp`.

#strong[Chapter connection:] Weighted and unweighted graphs; Spanning trees.

Sort edges by weight. DisjointSet tracks connected components; unite rejects an edge whose endpoints already share a component. main verifies connectivity and acyclicity, then checks every four-edge subset of this small graph to confirm the minimum weight.

#include "../visuals/program-minimum_spanning_tree.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `minimum_spanning_tree.cpp` --- lines 15--26.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 15, last: 26, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement find, unite, label and helpers.]
  ]

  `minimum_spanning_tree.cpp` --- lines 27--59.
]

#include "../visuals/walk-mst.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 27, last: 59, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `minimum_spanning_tree.cpp` --- lines 60--97.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 60, last: 97, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Connect the test cases in main.]
  ]

  `minimum_spanning_tree.cpp` --- lines 98--115. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 98, last: 115, lang: "cpp")

#strong[Greedy, and provably right here.] Kruskal's algorithm takes the edges from lightest to heaviest and keeps each one that does not close a cycle.

```terminal
== Weighted undirected graph ==
  A-B (4)
  A-C (2)
  A-D (5)
  B-D (3)
  B-E (6)
  C-D (1)
  D-E (7)
== Kruskal: edges in increasing weight ==
  C-D (1)  accept
  A-C (2)  accept
  B-D (3)  accept
  A-B (4)  reject: would close a cycle
  A-D (5)  reject: would close a cycle
  B-E (6)  accept
== Minimum spanning tree ==
  C-D (1)
  A-C (2)
  B-D (3)
  B-E (6)
  total weight: 12
  [ok]   the tree has |V| - 1 = 4 edges
  [ok]   it includes every vertex and contains no cycle
  brute force: 21 spanning trees, the lightest weighs 12
  [ok]   no spanning tree is lighter than the greedy one
```

A-B, weight 4, is the first edge refused: A and B are already joined through C and D. The algorithm stops after B-E because the tree then has |V|~-~1~=~4 edges, so D-E is never examined. The brute-force line checks all 21 spanning trees of this graph and finds none lighter than 12, which is what Kruskal's algorithm guarantees for every connected graph.

#strong[Cut E off.] Remove the edges B-E and D-E, leaving E with no edges at all, and predict the run. Kruskal accepts C-D, A-C and B-D, then runs out of edges with 3 instead of 4. Those edges form a minimum spanning forest of weight 6, not a spanning tree, so all three checks must now print `[FAIL]`, and the brute-force search finds 0 spanning trees to compare with.
