#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-graphs")


#heading(level: 1)[Graphs]
<ch:graphs>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Understand non-linear structures, linked representations, and queue/stack behavior.

*By the end, you can:* define $G \( V \, E \)$, distinguish directed and undirected graphs, represent a graph with an adjacency matrix or adjacency list, trace BFS and DFS, and explain the spanning-tree constraints stated in the slides.]

A #strong[graph] generalizes the idea of connected data. The graph $G \( V \, E \)$ contains a set of vertices $V$ and a set of edges $E$ that connect vertices.


#heading(level: 2)[Vertices and edges]


The graph example in the slides uses $ V = { A \, B \, C \, D \, E } $ and $ E = { \( A \, B \) \, \( B \, E \) \, \( A \, D \) \, \( A \, C \) \, \( C \, D \) \, \( D \, E \) \, \( B \, D \) } . $

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/e416f69c8297fdb5.cetz.json")], caption: [The running example graph used throughout this chapter: five vertices and seven undirected edges. Vertex D is adjacent to every other vertex, while C reaches E only by passing through A, B, or D.]) <fig:graph-base>

The slides contrast trees and graphs by noting that a tree is acyclic while a graph may contain cycles. They also motivate graphs with a city-distance example: cities become vertices and distances become edge information.


#heading(level: 2)[Directed and undirected graphs]


/ Directed graph: #block[
Edges have direction. $\( a \, b \)$ and $\( b \, a \)$ can represent different relationships.
]

/ Undirected graph: #block[
Edges have no direction. $\( a \, b \)$ and $\( b \, a \)$ are equivalent descriptions of the same connection.
]

#callout("utpfigure", title: [])[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/550c479e719a9bd1.cetz.json")]


#heading(level: 2)[Weighted and unweighted graphs]


The official lab manual extends the graph classification beyond direction.

/ Weighted graph: #block[
Each edge carries an associated value such as distance or cost. The manual's examples include distances between cities and communication cost between workstations.
]

/ Unweighted graph: #block[
Edges indicate that two vertices are related, but no numerical edge weight is attached.
]

#callout("utpfigure", title: [])[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/801831f66819f82c.cetz.json")]

#callout("keyidea", title: [Key idea])[Direction and weight are separate properties. A graph can be directed and weighted, directed and unweighted, undirected and weighted, or undirected and unweighted.]


#heading(level: 2)[Graph representations]


The graph deck teaches two storage strategies:

- sequential or #strong[adjacency matrix] representation;

- linked or #strong[adjacency list] representation.


#heading(level: 3)[Adjacency matrix]


An adjacency matrix uses a matrix entry $A_(i j)$ to represent the connection or associated edge weight from node $i$ to node $j$.

For the undirected example above, a simple unweighted 0/1 matrix is

#figure(
  align(center)[#table(
    columns: 6,
    align: (center,center,center,center,center,center,),
    table.header([], [A], [B], [C], [D], [E],),
    table.hline(),
    [A], [0], [1], [1], [1], [0],
    [B], [1], [0], [0], [1], [1],
    [C], [1], [0], [0], [1], [0],
    [D], [1], [1], [1], [0], [1],
    [E], [0], [1], [0], [1], [0],
  )]
  , kind: table
  )

#callout("clarification", title: [Clarification])[The slide image appears to show a 1 on the $D \, D$ diagonal entry, while the edge set printed on the preceding slide does not list a self-loop $\( D \, D \)$. The matrix above follows the printed edge set. This discrepancy is made explicit rather than silently copied.]

#ref(label("fig:graph-repr"), supplement: [Figure]) puts both representations of #ref(label("fig:graph-base"), supplement: [Figure]) side by side. They hold identical information; they differ in what they make cheap. The matrix answers "is A adjacent to E?" in one lookup but always occupies $V^2$ cells. The list stores only the edges that exist, so it is far smaller on a sparse graph, but the same question requires scanning A's neighbours.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/c65b46109c963c64.cetz.json")], caption: [The same graph as an adjacency matrix and an adjacency list. Row A of the matrix and the chain hanging off A carry exactly the same fact --- that A neighbours B, C, and D --- but the matrix also stores the two zeros recording what A is #emph[not] connected to.]) <fig:graph-repr>


#heading(level: 3)[Adjacency list]


An adjacency list stores, for each vertex, the vertices connected to it. The slides emphasize that it is storage-efficient because values are stored for edges rather than allocating a full matrix.

#code-block("vector<vector<int>> adj(5);\n\n// A=0, B=1, C=2, D=3, E=4\nadj[0] = {1, 2, 3};\nadj[1] = {0, 3, 4};\nadj[2] = {0, 3};\nadj[3] = {0, 1, 2, 4};\nadj[4] = {1, 3};", lang: "text")


#heading(level: 2)[Breadth-first search (BFS)]


The slide deck states that BFS traverses breadth-wise and uses a queue to move to the next node.

#code-block("void bfs(const vector<vector<int>>& adj, int start) {\n    vector<bool> visited(adj.size(), false);\n    queue<int> q;\n\n    visited[start] = true;\n    q.push(start);\n\n    while (!q.empty()) {\n        int u = q.front();\n        q.pop();\n        cout << u << ' ';\n\n        for (int v : adj[u]) {\n            if (!visited[v]) {\n                visited[v] = true;\n                q.push(v);\n            }\n        }\n    }\n}", lang: "text")

For the slide example, one shown BFS order is $A \, B \, C \, D \, E$.

BFS spreads outward in rings: every vertex at distance~1 is visited before any vertex at distance~2. The queue is what enforces that, because it hands back discovered vertices in the order they were found (#ref(label("fig:bfs"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/b0e85a9b8eeaad86.cetz.json")], caption: [BFS from A, with the queue shown after each step. Vertices are shaded as they are discovered and outlined once processed. Because the queue is FIFO, the whole of level~1 is drained before E --- the only level-2 vertex --- is reached.]) <fig:bfs>


#heading(level: 2)[Depth-first search (DFS)]


The slides state that DFS traverses depth-wise and uses a stack to reach the next nodes. Recursion is another way to obtain stack behavior.

#code-block("void dfs(const vector<vector<int>>& adj,\n         int u, vector<bool>& visited) {\n    visited[u] = true;\n    cout << u << ' ';\n\n    for (int v : adj[u]) {\n        if (!visited[v]) dfs(adj, v, visited);\n    }\n}", lang: "text")

One DFS order shown by the deck is $A \, B \, E \, D \, C$.

DFS commits to one branch and follows it as far as it goes before considering any alternative. The stack holds the trail of vertices it may still need to back up through (#ref(label("fig:dfs"), supplement: [Figure])). Comparing it against #ref(label("fig:bfs"), supplement: [Figure]) on the same graph isolates the one thing that differs: a queue returns the #emph[oldest] discovered vertex, a stack returns the #emph[newest].

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/a55e9c63323cdf56.cetz.json")], caption: [DFS from A, with the stack shown after each step. The walk plunges A$arrow.r$B$arrow.r$E$arrow.r$D before backtracking to pick up C. Swapping the queue in #ref(label("fig:bfs"), supplement: [Figure]) for a stack is the entire difference between the two algorithms.]) <fig:dfs>

#callout("clarification", title: [Clarification])[BFS and DFS traversal orders are not unique unless the neighbor-visiting order is fixed. The sequences in the slides are valid for a particular ordering of adjacent vertices; different adjacency-list orderings can produce different, equally valid traversals.]


#heading(level: 2)[Why a visited set matters]


Graphs may contain cycles. Without a visited marker, a traversal could keep moving around a cycle indefinitely.

#ref(label("fig:visited"), supplement: [Figure]) shows the loop. In a tree, moving away from the root can never bring you back to it, so recursion terminates on its own. A graph has no such guarantee: the cycle A$arrow.r$B$arrow.r$D$arrow.r$A returns the traversal to a vertex it has already processed, and without a record of that fact the program will circle forever.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/3f96875c4214906b.cetz.json")], caption: [Why traversal needs a visited set. Following edges from A around the cycle leads back to A. The visited markers are the only thing that distinguishes "arrive at A for the first time" from "arrive at A again", and therefore the only thing that terminates the walk.]) <fig:visited>

#callout("keyidea", title: [Key idea])[The queue or stack determines #emph[which discovered vertex to process next]. The visited structure determines #emph[whether a vertex should be processed again].]


#heading(level: 2)[Spanning trees]


The slides define a spanning tree as a subset of a graph that covers all vertices using the minimum possible number of edges, has no cycles, and is connected.

For a connected graph with $\| V \|$ vertices, a spanning tree has $\| V \| - 1$ edges.

The lab then asks students to find a #strong[minimum spanning tree] of an undirected graph using a greedy approach.

#callout("clarification", title: [Clarification])[The deck requests a greedy minimum-spanning-tree implementation but does not name a specific algorithm. Common textbook choices are Prim's algorithm and Kruskal's algorithm; naming them here is additional context, not material explicitly taught in the supplied slides.]

#callout("quickcheck", title: [Check your understanding])[Why is an adjacency matrix often more wasteful for a sparse graph than an adjacency list? Which earlier ADT is directly reused by BFS, and which is reused by DFS?]
