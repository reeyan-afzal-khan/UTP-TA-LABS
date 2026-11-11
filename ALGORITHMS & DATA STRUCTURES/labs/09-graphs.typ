#import "/.shared/typst/utp.typ": *
#unit("labs", "09-graphs")

#lab("9")[Graph representation, traversal, and spanning trees] <sec:lab09>

#callout("sourcealignment", title: [Official Lab Manual --- Lab IX])[Adjacency lists, BFS/DFS, exact path length, and a greedy spanning-tree method.]

#callout("labproject", title: [Build, traverse, and analyze one graph])[#strong[Goal.] Store, traverse, and find a minimum spanning tree of one graph.

#strong[Recall first.] Review the #link(label("ch:graphs"))[Graphs] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab09` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/graph_traversal.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/minimum_spanning_tree.typ"
]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
