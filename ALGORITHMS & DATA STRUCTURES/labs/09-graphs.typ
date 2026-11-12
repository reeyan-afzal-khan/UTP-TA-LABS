#import "/.shared/typst/utp.typ": *
#unit("labs", "09-graphs")

#labsection(9, label: <sec:lab09>)[Graph representation, traversal, and spanning trees]

#sourcealignment[Official Lab Manual --- Lab IX][
  Adjacency lists, BFS/DFS, exact path length, and a greedy spanning-tree method.
]

#labproject[Build, traverse, and analyze one graph][
  #strong[Goal.] Store, traverse, and find a minimum spanning tree of one graph.

  #strong[Recall first.] Review the #link(<ch:graphs>)[Graphs] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Build one program at a time from its `all_experiments/Lab09` folder.

  #include "programs/graph_traversal.typ"

  #colbreak()

  #include "programs/minimum_spanning_tree.typ"
]

#verification[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
