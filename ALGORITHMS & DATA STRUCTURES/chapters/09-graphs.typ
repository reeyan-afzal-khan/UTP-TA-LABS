#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-graphs")

= Graphs <ch:graphs>

#chapterguide[Understand non-linear structures, linked representations, and queue/stack behavior.][define $G(V,E)$, distinguish directed and undirected graphs, represent a graph with an adjacency matrix or adjacency list, trace BFS and DFS, and explain the spanning-tree constraints stated in the slides.]

A #term[graph] generalizes the idea of connected data. The graph $G(V,E)$ contains a set of vertices $V$ and a set of edges $E$ that connect vertices.

== Vertices and edges

The graph example in the slides uses

$ V= { A,B,C,D,E } $

and

$ E= { (A,B),(B,E),(A,D),(A,C),(C,D),(D,E),(B,D) } . $

#utpfig([The running example graph used throughout this chapter: five vertices and seven undirected edges. Vertex D is adjacent to every other vertex, while C reaches E only by passing through A, B, or D.], label: <fig:graph-base>)[
  #canvas({
    node((0, 1.5), [A], name: "A", font: font("small"), ..utpnode)
    node((2.4, 1.5), [B], name: "B", font: font("small"), ..utpnode)
    node((0, 0), [C], name: "C", font: font("small"), ..utpnode)
    node((2.4, 0), [D], name: "D", font: font("small"), ..utpnode)
    node((4.2, 0.75), [E], name: "E", font: font("small"), ..utpnode)
    for (u, vv) in (("A", "B"), ("B", "E"), ("A", "D"), ("A", "C"), ("C", "D"), ("D", "E"), ("B", "D")) {
      connect(u, vv, ..utpedge)
    }
    node((5, 0.75), [5 vertices, 7 edges \
  degree of D $=4$], font: font("small"), ..utplabel, anchor: "west", align: left)
  })
]

The slides contrast trees and graphs by noting that a tree is acyclic while a graph may contain cycles. They also motivate graphs with a city-distance example: cities become vertices and distances become edge information.

== Directed and undirected graphs

#describe-nextline(1.4in)[
  / Directed graph: Edges have direction. $(a,b)$ and $(b,a)$ can represent different relationships.
  / Undirected graph: Edges have no direction. $(a,b)$ and $(b,a)$ are equivalent descriptions of the same connection.
]

#utpfigure[
  #canvas({
    let node-style = (shape: "circle", draw: blue, fill: pale-blue, min-size: 0.8, font: font("small", weight: "bold"))
    let darr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    let uarr = (line-width: widths.thick, draw: orange)
    node((0, 0), [A], name: "a", ..node-style)
    node(right-of("a", 1.4), [B], name: "b", ..node-style)
    connect("a", "b", ..darr)
    node(above-of("a", 0.3), [directed], xshift: 0.7cm, font: font("script", fill: muted))
    node(right-of("a", 4.2), [A], name: "c", ..node-style)
    node(right-of("c", 1.4), [B], name: "d", ..node-style)
    connect("c", "d", ..uarr)
    node(above-of("c", 0.3), [undirected], xshift: 0.7cm, font: font("script", fill: muted))
  })
]

== Weighted and unweighted graphs

The official lab manual extends the graph classification beyond direction.

#describe-nextline(1.45in)[
  / Weighted graph: Each edge carries an associated value such as distance or cost. The manual’s examples include distances between cities and communication cost between workstations.
  / Unweighted graph: Edges indicate that two vertices are related, but no numerical edge weight is attached.
]

#utpfigure[
  #canvas({
    let node-style = (shape: "circle", draw: blue, fill: pale-blue, min-size: 0.8, font: font("small", weight: "bold"))
    let edge = (line-width: widths.thick, draw: teal)
    node((0, 0), [A], name: "A", ..node-style)
    node((2, 0.8), [B], name: "B", ..node-style)
    node((2, -0.8), [C], name: "C", ..node-style)
    connect("A", "B", ..edge)
    node(along("A", "B", t: 50%), [7], font: font("script", fill: orange), anchor: "south")
    connect("A", "C", ..edge)
    node(along("A", "C", t: 50%), [3], font: font("script", fill: orange), anchor: "north")
    connect("B", "C", ..edge)
    node(along("B", "C", t: 50%), [4], font: font("script", fill: orange), anchor: "west")
    node(right-of("B", 1), [The same topology can be \
  weighted by distance, cost, time, etc.], font: font("small", fill: muted), align: left)
  })
]

#note[
  Direction and weight are separate properties. A graph can be directed and weighted, directed and unweighted, undirected and weighted, or undirected and unweighted.
]

== Graph representations

The graph deck teaches two storage strategies:

- sequential or #term[adjacency matrix] representation;
- linked or #term[adjacency list] representation.

=== Adjacency matrix

An adjacency matrix uses a matrix entry $A_(i j)$ to represent the connection or associated edge weight from node $i$ to node $j$.

For the undirected example above, a simple unweighted 0/1 matrix is

#utptable[
  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (center, center, center, center, center, center),
    header: ([], [A], [B], [C], [D], [E]),
    [A], [0], [1], [1], [1], [0],
    [B], [1], [0], [0], [1], [1],
    [C], [1], [0], [0], [1], [0],
    [D], [1], [1], [1], [0], [1],
    [E], [0], [1], [0], [1], [0],
  )
]

#note[
  The slide image appears to show a 1 on the $D,D$ diagonal entry, while the edge set printed on the preceding slide does not list a self-loop $(D,D)$. The matrix above follows the printed edge set. This discrepancy is made explicit rather than silently copied.
]

#figref(<fig:graph-repr>) puts both representations of #figref(<fig:graph-base>) side by side.
They hold identical information; they differ in what they make cheap. The matrix answers
“is A adjacent to E?” in one lookup but always occupies $V^2$ cells. The list stores only
the edges that exist, so it is far smaller on a sparse graph, but the same question requires
scanning A’s neighbours.

#utpfig([The same graph as an adjacency matrix and an adjacency list. Row A of the matrix and the chain hanging off A carry exactly the same fact --- that A neighbours B, C, and D --- but the matrix also stores the two zeros recording what A is #emph[not] connected to.], label: <fig:graph-repr>)[
  #canvas({
    draw.scope({
      node((1.4, 1.55), [Adjacency matrix], font: font("normal", weight: "bold", fill: navy))
      for (j, c) in ("A", "B", "C", "D", "E").enumerate() {
        node((0.56 * j, 0.95), [#c], ..utplabel, font: font("script", weight: "bold", fill: navy))
        node((-0.56, 0.39 - 0.56 * j), [#c], ..utplabel, font: font("script", weight: "bold", fill: navy))
      }
      for (i, row) in ((0, 1, 1, 1, 0), (1, 0, 0, 1, 1), (1, 0, 0, 1, 0), (1, 1, 1, 0, 1), (0, 1, 0, 1, 0)).enumerate() {
        for (j, val) in row.enumerate() {
          if val == 1 {
            node((0.56 * j, 0.39 - 0.56 * i), [#val], ..utpcell, min-width: 0.56, min-height: 0.56, font: font("script", weight: "bold", fill: navy))
          } else {
            node((0.56 * j, 0.39 - 0.56 * i), [#val], ..utpdim, min-width: 0.56, min-height: 0.56, font: font("script", fill: muted))
          }
        }
      }
      rectangle((-0.31, 0.66), (2.53, 0.12), draw: orange, line-width: 0.9963pt, rounded: 0.9963pt)
      node((1.12, -2.15), [$V^2=25$ cells always stored \
  “A--E?” is one lookup: #cxg[$O(1)$]], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((6.3, 0))
      draw.translate((0, 0.15))
      node((2.3, 1.4), [Adjacency list], font: font("normal", weight: "bold", fill: navy))
      for (i, (vv, nbrs)) in (("A", ("B", "C", "D")), ("B", ("A", "D", "E")), ("C", ("A", "D")), ("D", ("A", "B", "C", "E")), ("E", ("B", "D"))).enumerate() {
        node((0, 0.62 - 0.62 * i), [#vv], name: "h" + str(i), ..utpcell, min-width: 0.56, min-height: 0.52, font: font("script", weight: "bold"))
        for (k, n) in nbrs.enumerate() {
          node((0.95 + 0.78 * k, 0.62 - 0.62 * i), [#n], name: "c" + str(i) + str(k), ..utpcell, min-width: 0.52, min-height: 0.52, fill: white, font: font("script", fill: navy))
        }
      }
      for (i, last) in ((0, 2), (1, 2), (2, 1), (3, 3), (4, 1)) {
        connect("h" + str(i) + ".east", "c" + str(i) + "0" + ".west", ..utpptr)
        for k in range(0, 3) {
          if k < last {
            let m = int(k + 1)
            connect("c" + str(i) + str(k) + ".east", "c" + str(i) + str(m) + ".west", ..utpptr)
          }
        }
      }
      node((1.6, -2.3), [only the 14 directed entries stored \
  “A--E?” scans A’s list: #cxo[$O(deg)$]], font: font("small"), ..utplabel, anchor: "north", align: center)
      rectangle((-0.32, 0.88), (2.78, 0.36), draw: orange, line-width: 0.9963pt, rounded: 0.9963pt)
    })
  })
]

=== Adjacency list

An adjacency list stores, for each vertex, the vertices connected to it. The slides emphasize that it is storage-efficient because values are stored for edges rather than allocating a full matrix.

```cpp

// A=0, B=1, C=2, D=3, E=4
adj[0] = {1, 2, 3};
adj[1] = {0, 3, 4};
adj[2] = {0, 3};
adj[3] = {0, 1, 2, 4};
adj[4] = {1, 3};
```

== Breadth-first search (BFS)

The slide deck states that BFS traverses breadth-wise and uses a queue to move to the next node.

```cpp
    vector<bool> visited(adj.size(), false);
    queue<int> q;

    visited[start] = true;
    q.push(start);

    while (!q.empty()) {
        int u = q.front();
        q.pop();
        cout << u << ' ';

        for (int v : adj[u]) {
            if (!visited[v]) {
                visited[v] = true;
                q.push(v);
            }
        }
    }
}
```

For the slide example, one shown BFS order is $A,B,C,D,E$.

BFS spreads outward in rings: every vertex at distance~1 is visited before any vertex at
distance~2. The queue is what enforces that, because it hands back discovered vertices in
the order they were found (#figref(<fig:bfs>)).

#utpfig([BFS from A, with the queue shown after each step. Vertices are shaded as they are discovered and outlined once processed. Because the queue is FIFO, the whole of level~1 is drained before E --- the only level-2 vertex --- is reached.], label: <fig:bfs>)[
  #canvas({
    draw.scope({
      node((0, 1.5), [A], name: "A", font: font("small"), ..utpnodedone)
      node((2.1, 1.5), [B], name: "B", font: font("small"), ..utpnodehot)
      node((0, 0), [C], name: "C", font: font("small"), ..utpnodehot)
      node((2.1, 0), [D], name: "D", font: font("small"), ..utpnodehot)
      node((3.9, 0.75), [E], name: "E", font: font("small"), ..utpnode)
      for (u, vv) in (("B", "E"), ("C", "D"), ("D", "E"), ("B", "D")) {
        connect(u, vv, ..utpedge, draw: mix(muted, 40%))
      }
      for (u, vv) in (("A", "B"), ("A", "C"), ("A", "D")) {
        connect(u, vv, ..utpedge, draw: orange, line-width: 1.0959pt)
      }
      connect("B", "E", ..utpedge, draw: green, line-width: 1.0959pt)
      node((0, 2.05), [level 0], font: font("small"), ..utplabel, anchor: "south", text: green)
      node((2.1, 2.05), [level 1], font: font("small"), ..utplabel, anchor: "south", text: orange)
      node((3.9, 1.35), [level 2], font: font("small"), ..utplabel, anchor: "south", text: blue)
    })
    draw.scope({
      draw.translate((6.9, 0))
      draw.translate((0, 1.35))
      for (i, (act, qs)) in (("visit A", "B C D"), ("pop B, find E", "C D E"), ("pop C", "D E"), ("pop D", "E"), ("pop E", "empty")).enumerate() {
        node((0, -0.56 * i), [#act], ..utplabel, anchor: "east", font: font("script", family: "mono"))
        node((1.35, -0.56 * i), [#qs], ..utpcell, min-width: 2.1, min-height: 0.44, font: font("script", fill: navy, family: "mono"))
      }
      node((1.35, 0.32), [#strong[queue after step]], font: font("small"), ..utplabel, anchor: "south", text: navy)
      node((0.9, -2.75), [output: A B C D E], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

== Depth-first search (DFS)

The slides state that DFS traverses depth-wise and uses a stack to reach the next nodes. Recursion is another way to obtain stack behavior.

```cpp
         int u, vector<bool>& visited) {
    visited[u] = true;
    cout << u << ' ';

    for (int v : adj[u]) {
        if (!visited[v]) dfs(adj, v, visited);
    }
}
```

One DFS order shown by the deck is $A,B,E,D,C$.

DFS commits to one branch and follows it as far as it goes before considering any
alternative. The stack holds the trail of vertices it may still need to back up through
(#figref(<fig:dfs>)). Comparing it against #figref(<fig:bfs>) on the same graph isolates the one
thing that differs: a queue returns the #emph[oldest] discovered vertex, a stack returns the
#emph[newest].

#utpfig([DFS from A, with the stack shown after each step. The walk plunges A$arrow.r$B$arrow.r$E$arrow.r$D before backtracking to pick up C. Swapping the queue in #figref(<fig:bfs>) for a stack is the entire difference between the two algorithms.], label: <fig:dfs>)[
  #canvas({
    draw.scope({
      node((0, 1.5), [A], name: "A", font: font("small"), ..utpnodedone)
      node((2.1, 1.5), [B], name: "B", font: font("small"), ..utpnodedone)
      node((0, 0), [C], name: "C", font: font("small"), ..utpnodehot)
      node((2.1, 0), [D], name: "D", font: font("small"), ..utpnodedone)
      node((3.9, 0.75), [E], name: "E", font: font("small"), ..utpnodedone)
      for (u, vv) in (("A", "C"), ("A", "D"), ("C", "D"), ("B", "D")) {
        connect(u, vv, ..utpedge, draw: mix(muted, 40%))
      }
      for (u, vv) in (("A", "B"), ("B", "E"), ("D", "E")) {
        connect(u, vv, ..utpedge, draw: green, line-width: 1.0959pt)
      }
      connect("D", "C", ..utpedge, draw: orange, line-width: 1.0959pt, dash: "dashed")
      for (n, ord) in (("A", 1), ("B", 2), ("E", 3), ("D", 4), ("C", 5)) {
        node((rel: (0.06, 0.06), to: n + ".north-east"), [#ord], shape: "circle", fill: navy, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      }
      node((1.95, -0.55), [solid: the descent #h(1em)dashed: backtrack], font: font("small"), ..utplabel, anchor: "north", align: center, text: green)
    })
    draw.scope({
      draw.translate((6.9, 0))
      draw.translate((0, 1.35))
      for (i, (act, ss)) in (("visit A", "A"), ("visit B", "A B"), ("visit E", "A B E"), ("visit D", "A B E D"), ("visit C", "A B E D C")).enumerate() {
        node((0, -0.56 * i), [#act], ..utplabel, anchor: "east", font: font("script", family: "mono"))
        node((1.35, -0.56 * i), [#ss], ..utpcell, min-width: 2.1, min-height: 0.44, font: font("script", fill: navy, family: "mono"))
      }
      node((1.35, 0.32), [#strong[stack after step]], font: font("small"), ..utplabel, anchor: "south", text: navy)
      node((0.9, -2.75), [output: A B E D C], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

#note[
  BFS and DFS traversal orders are not unique unless the neighbor-visiting order is fixed. The sequences in the slides are valid for a particular ordering of adjacent vertices; different adjacency-list orderings can produce different, equally valid traversals.
]

== Why a visited set matters

Graphs may contain cycles. Without a visited marker, a traversal could keep moving around a cycle indefinitely.

#figref(<fig:visited>) shows the loop. In a tree, moving away from the root can never bring you
back to it, so recursion terminates on its own. A graph has no such guarantee: the cycle
A$arrow.r$B$arrow.r$D$arrow.r$A returns the traversal to a vertex it has already processed, and without a
record of that fact the program will circle forever.

#utpfig([Why traversal needs a visited set. Following edges from A around the cycle leads back to A. The visited markers are the only thing that distinguishes “arrive at A for the first time” from “arrive at A again”, and therefore the only thing that terminates the walk.], label: <fig:visited>)[
  #canvas({
    node((0, 0.9), [A], name: "a", font: font("small"), ..utpnodedone)
    node((1.7, 0.9), [B], name: "b", font: font("small"), ..utpnodedone)
    node((0.85, -0.5), [D], name: "d", font: font("small"), ..utpnodedone)
    connect("a", "b", bend: 18deg, line-width: 0.9963pt, draw: red, end: arrow-tip("Stealth", length: 2.4mm, line: 0.9963pt), name: "curve-1")
    connect("b", "d", bend: 18deg, line-width: 0.9963pt, draw: red, end: arrow-tip("Stealth", length: 2.4mm, line: 0.9963pt), name: "curve-2")
    connect("d", "a", bend: 18deg, line-width: 0.9963pt, draw: red, end: arrow-tip("Stealth", length: 2.4mm, line: 0.9963pt), name: "curve-3")
    node((2.7, 0.2), [without `visited`: \
  A, B, D, A, B, D, … \
  the loop never ends], font: font("small"), ..utplabel, anchor: "west", align: left, text: red)
    draw.scope({
      draw.translate((8.2, 0))
      node((0.9, 1.35), [#strong[visited array]], font: font("small"), ..utplabel, anchor: "south", text: navy)
      for (i, vv) in ("A", "B", "C", "D", "E").enumerate() {
        node((0.62 * i, 0.75), [#vv], ..utpcell, min-width: 0.6, min-height: 0.5, font: font("script", weight: "bold"))
      }
      for (i, m) in ("T", "T", "F", "T", "F").enumerate() {
        node((0.62 * i, 0.25), [#m], ..utpdim, min-width: 0.6, min-height: 0.5, font: font("script"))
      }
      node((1.24, -0.15), [second arrival at A finds `true` \
  and the branch is abandoned], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

#note[
  The queue or stack determines #emph[which discovered vertex to process next]. The visited structure determines #emph[whether a vertex should be processed again].
]

== Spanning trees

The slides define a spanning tree as a subset of a graph that covers all vertices using the minimum possible number of edges, has no cycles, and is connected.

For a connected graph with $|V|$ vertices, a spanning tree has $|V|-1$ edges.

The lab then asks students to find a #term[minimum spanning tree] of an undirected graph using a greedy approach.

#note[
  The deck requests a greedy minimum-spanning-tree implementation but does not name a specific algorithm. Common textbook choices are Prim’s algorithm and Kruskal’s algorithm; naming them here is additional context, not material explicitly taught in the supplied slides.
]

#questions[
  Why is an adjacency matrix often more wasteful for a sparse graph than an adjacency list? Which earlier ADT is directly reused by BFS, and which is reused by DFS?
]
