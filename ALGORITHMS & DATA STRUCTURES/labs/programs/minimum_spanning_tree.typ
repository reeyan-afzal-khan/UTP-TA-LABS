#import "/.shared/typst/utp.typ": *

#strong[Program 2: A complete Kruskal program.]

#strong[File:] `minimum_spanning_tree.cpp`.

#strong[Chapter connection:] Weighted and unweighted graphs; Spanning trees.

Sort edges by weight. DisjointSet tracks connected components; unite rejects an edge whose endpoints already share a component. main verifies connectivity and acyclicity, then checks every four-edge subset of this small graph to confirm the minimum weight.

#include "../visuals/program-minimum_spanning_tree.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`minimum_spanning_tree.cpp` --- lines 15--26.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 15, last: 26, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement find, unite, label and helpers.]
]

`minimum_spanning_tree.cpp` --- lines 27--59.

#include "../visuals/walk-mst.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 27, last: 59, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`minimum_spanning_tree.cpp` --- lines 60--97.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 60, last: 97, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Connect the test cases in main.]
]

`minimum_spanning_tree.cpp` --- lines 98--115. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 98, last: 115, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect minimum\_spanning\_tree.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra minimum_spanning_tree.cpp -o minimum_spanning_tree.exe

.\minimum_spanning_tree.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/minimum_spanning_tree.txt`.

#exercises[
  Remove BE and DE so E is isolated. The returned forest has fewer than V-1 edges and isSpanningTree must report false; do not describe it as a spanning tree.
]
