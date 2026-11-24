#import "/.shared/typst/utp.typ": *
#unit("labs", "09-graphs")

#labsection(9, label: <sec:lab09>)[Graph representation, traversal, and spanning trees]

#labproject[Build, traverse, and analyze one graph][
  #note[
    #strong[Official Lab Manual --- Lab IX.] Adjacency lists, BFS/DFS, exact path length, and a greedy spanning-tree method.
  ]

  #strong[Goal.] Store, traverse, and find a minimum spanning tree of one graph.

  #strong[Recall first.] Review the #link(<ch:graphs>)[Graphs] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Save each one in your `Lab09` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab09`.

  #include "programs/graph_traversal.typ"

  #include "programs/minimum_spanning_tree.typ"
]

#element-head([Count the connected pieces])

A BFS started at one vertex reaches exactly the connected piece, or component, that contains it. Write `countComponents`: loop over the vertices, start a new BFS from each vertex not yet visited, and count the starts. The graph of Program 1 has one component. Remove B-E and D-E and it has two, one holding A, B, C and D and one holding E alone; add a sixth vertex F with no edges and it has three. Then run Kruskal from Program 2 on the graph without B-E and D-E. It returns 3 edges, the number of vertices minus the number of components, 5~-~2. Explain why that rule holds for every graph.
