#import "/.shared/typst/utp.typ": *

#strong[Program 2: A complete Kruskal program.]

#strong[File:] `minimum_spanning_tree.cpp`.

#strong[Chapter connection:] Weighted and unweighted graphs; Spanning trees.

Sort edges by weight. DisjointSet tracks connected components; unite rejects an edge whose endpoints already share a component. main verifies connectivity and acyclicity, then checks every four-edge subset of this small graph to confirm the minimum weight.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-minimum_spanning_tree.typ"


+ #strong[Headers and initial definitions.]

`minimum_spanning_tree.cpp` --- lines 15--26.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 15, last: 26, lang: "text")

+ #strong[Implement find, unite, label and helpers.]

`minimum_spanning_tree.cpp` --- lines 27--59.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-mst.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 27, last: 59, lang: "text")

+ #strong[Connect the test cases in main.]

`minimum_spanning_tree.cpp` --- lines 60--97.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 60, last: 97, lang: "text")

+ #strong[Connect the test cases in main.]

`minimum_spanning_tree.cpp` --- lines 98--115. Continue in the same file; do not add another header or opening brace.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab09/minimum_spanning_tree.cpp", first: 98, last: 115, lang: "text")

#strong[Build, run, and inspect minimum\_spanning\_tree.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra minimum_spanning_tree.cpp -o minimum_spanning_tree.exe\n\n.\\minimum_spanning_tree.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Weighted undirected graph ==\n  A-B (4)\n  A-C (2)\n  A-D (5)\n  B-D (3)\n  B-E (6)\n  C-D (1)\n  D-E (7)\n\n== Kruskal: edges in increasing weight ==\n  C-D (1)  accept\n  A-C (2)  accept\n  B-D (3)  accept\n  A-B (4)  reject: would close a cycle\n  A-D (5)  reject: would close a cycle", lang: "text")

The complete captured run is in `labs/outputs/minimum_spanning_tree.txt`.

#callout("tryit", title: [Try it yourself])[Remove BE and DE so E is isolated. The returned forest has fewer than V-1 edges and isSpanningTree must report false; do not describe it as a spanning tree.]
