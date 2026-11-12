#import "/.shared/typst/utp.typ": *
#unit("chapters", "07-trees-i")

= Trees I: Terminology, Traversal, and Binary Trees <ch:trees-i>

#chapterguide[Know linear and non-linear classification, linked-node representation, and basic pointer-based traversal.][define a tree and subtree, use root/parent/sibling/level/height terminology, trace inorder/preorder/postorder traversal, and explain array and linked representations of a binary tree.]

A #term[tree] is a non-linear data structure in which data is stored hierarchically. The Trees I deck defines a tree recursively: there is a specially designated #term[root], and the remaining nodes can be partitioned into disjoint subtrees of that root.

== Root and subtrees

The slide example uses root $A$ with the following structure.

#utpfigure[
  #canvas({
    let node-style = (shape: "circle", draw: blue, fill: pale-blue, min-size: 0.75, font: font("script", weight: "bold", fill: navy))
    let edge = (line-width: widths.thick, draw: teal)
    node((0, 0), [A], name: "A", ..node-style)
    node((-3, -1.1), [B], name: "B", ..node-style)
    node((0, -1.1), [C], name: "C", ..node-style)
    node((3, -1.1), [D], name: "D", ..node-style)
    node((-4, -2.2), [E], name: "E", ..node-style)
    node((-2, -2.2), [F], name: "F", ..node-style)
    node((0, -2.2), [G], name: "G", ..node-style)
    node((2, -2.2), [H], name: "H", ..node-style)
    node((3, -2.2), [I], name: "I", ..node-style)
    node((4, -2.2), [J], name: "J", ..node-style)
    node((-4.6, -3.3), [K], name: "K", ..node-style)
    node((-3.4, -3.3), [L], name: "L", ..node-style)
    node((2, -3.3), [M], name: "M", ..node-style)
    for (u, vv) in (("A", "B"), ("A", "C"), ("A", "D"), ("B", "E"), ("B", "F"), ("C", "G"), ("D", "H"), ("D", "I"), ("D", "J"), ("E", "K"), ("E", "L"), ("H", "M")) {
      connect(u, vv, ..edge)
    }
    node(right-of("A", 0.25), [root], font: font("script", weight: "bold", fill: orange))
  })
]

The Trees I slide explicitly identifies the subtree rooted at $B$ as one subtree of $A$, and similarly identifies the $C$ and $D$ branches as other subtrees.

== Tree terminology

=== Edge

An #term[edge] is the connecting link between two nodes.

#clarification[
  The slide says that with $N$ nodes there will be a #emph[maximum] of $N-1$ edges. For an ordinary connected tree with $N$ nodes, the standard invariant is stronger: it has #emph[exactly] $N-1$ edges. The slide wording is preserved here and the standard property is supplied as clarification.
]

=== Parent and sibling

If node $N$ is the immediate predecessor of node $X$, then $N$ is the parent of $X$. Nodes with the same parent are siblings. In the slide example, $A$ is a parent of $B$, $C$, and $D$; $E$ and $F$ are siblings.

=== Internal node

An internal node has at least one child. In the diagram above, examples include $A$, $B$, $C$, $D$, $E$, and $H$.

#clarification[
  One slide lists $A,B,C,D,E,F,G,H,I,J$ as internal nodes, but the accompanying diagram shows several of those nodes without children. These notes use the slide’s own definition --- “has at least one child” --- when classifying the drawn example.
]

=== Level

The #term[level] of a node is the number of edges on the path from that node to the root. The root is at level 0. If a node is at level $ell$, its children are at level $ell +1$.

=== Height

The slides define the height of a node as the number of edges on the longest path from that node down to a leaf. In the example, $H$ has one child $M$, so its height is 1.

#workedexample[
  Using the recreated slide tree: $A$ is at level 0, $D$ is at level 1, $H$ is at level 2, and $M$ is at level 3. The height of $H$ is 1 because the longest downward path is $H arrow.r M$.
]

== Tree traversal

Traversal means visiting every node exactly once. The Trees I deck teaches three depth-first traversal orders.

#utptable[
  #tabularx(
    columns: (22%, 1fr),
    styles: (navy-bold,),
    header: ([Traversal], [Rule]),
    [Inorder], [Left subtree $arrow.r$ root $arrow.r$ right subtree],
    [Preorder], [Root $arrow.r$ left subtree $arrow.r$ right subtree],
    [Postorder], [Left subtree $arrow.r$ right subtree $arrow.r$ root],
  )
]

These traversal rules are most naturally applied to binary trees, because each node has a clear left and right subtree.

The three orders differ in one respect only: #emph[when the root is visited] relative to its
subtrees. #figref(<fig:traversals>) applies all three to the same tree, numbering each node
with its position in the output sequence.

#utpfig([The same binary tree under all three depth-first traversals. The shape of the walk is identical in every case --- down the left, down the right, back up --- and only the moment at which a node is #emph[recorded] moves. Inorder on a search tree yields sorted output, which is why it is the one used most often.], label: <fig:traversals>)[
  #canvas({
    draw.scope({
      draw.translate((0, 0))
      node((0, 1.35), [Inorder], font: font("normal", weight: "bold", fill: navy))
      node((0, 0.55), [A], name: "n1", font: font("small"), ..utpnode, min-size: 0.75)
      node((-0.95, -0.45), [B], name: "n2", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.95, -0.45), [C], name: "n3", font: font("small"), ..utpnode, min-size: 0.75)
      node((-1.5, -1.45), [D], name: "n4", font: font("small"), ..utpnode, min-size: 0.75)
      node((-0.4, -1.45), [E], name: "n5", font: font("small"), ..utpnode, min-size: 0.75)
      connect("n1", "n2", ..utpedge)
      connect("n1", "n3", ..utpedge)
      connect("n2", "n4", ..utpedge)
      connect("n2", "n5", ..utpedge)
      for (nd, ord) in (("n4", 1), ("n2", 2), ("n5", 3), ("n1", 4), ("n3", 5)) {
        node((rel: (0.055, 0.055), to: nd + ".north-east"), [#ord], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      }
      node((0, -2.05), [left, #strong[root], right], font: font("small"), ..utplabel, anchor: "north", align: center, text: muted)
      node((0, -2.42), [D B E A C], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((5.6, 0))
      node((0, 1.35), [Preorder], font: font("normal", weight: "bold", fill: navy))
      node((0, 0.55), [A], name: "n1", font: font("small"), ..utpnode, min-size: 0.75)
      node((-0.95, -0.45), [B], name: "n2", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.95, -0.45), [C], name: "n3", font: font("small"), ..utpnode, min-size: 0.75)
      node((-1.5, -1.45), [D], name: "n4", font: font("small"), ..utpnode, min-size: 0.75)
      node((-0.4, -1.45), [E], name: "n5", font: font("small"), ..utpnode, min-size: 0.75)
      connect("n1", "n2", ..utpedge)
      connect("n1", "n3", ..utpedge)
      connect("n2", "n4", ..utpedge)
      connect("n2", "n5", ..utpedge)
      for (nd, ord) in (("n1", 1), ("n2", 2), ("n4", 3), ("n5", 4), ("n3", 5)) {
        node((rel: (0.055, 0.055), to: nd + ".north-east"), [#ord], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      }
      node((0, -2.05), [#strong[root], left, right], font: font("small"), ..utplabel, anchor: "north", align: center, text: muted)
      node((0, -2.42), [A B D E C], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((11.2, 0))
      node((0, 1.35), [Postorder], font: font("normal", weight: "bold", fill: navy))
      node((0, 0.55), [A], name: "n1", font: font("small"), ..utpnode, min-size: 0.75)
      node((-0.95, -0.45), [B], name: "n2", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.95, -0.45), [C], name: "n3", font: font("small"), ..utpnode, min-size: 0.75)
      node((-1.5, -1.45), [D], name: "n4", font: font("small"), ..utpnode, min-size: 0.75)
      node((-0.4, -1.45), [E], name: "n5", font: font("small"), ..utpnode, min-size: 0.75)
      connect("n1", "n2", ..utpedge)
      connect("n1", "n3", ..utpedge)
      connect("n2", "n4", ..utpedge)
      connect("n2", "n5", ..utpedge)
      for (nd, ord) in (("n4", 1), ("n5", 2), ("n2", 3), ("n3", 4), ("n1", 5)) {
        node((rel: (0.055, 0.055), to: nd + ".north-east"), [#ord], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      }
      node((0, -2.05), [left, right, #strong[root]], font: font("small"), ..utplabel, anchor: "north", align: center, text: muted)
      node((0, -2.42), [D E B C A], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

== Binary trees

A #term[binary tree] is a tree in which each node has at most two children. A binary-tree node can be represented with two pointers.

```cpp
    int data;
    TreeNode* left;
    TreeNode* right;
};
```

=== Recursive traversal code

```cpp
    if (root == nullptr) return;
    inorder(root->left);
    cout << root->data << ' ';
    inorder(root->right);
}

void preorder(TreeNode* root) {
    if (root == nullptr) return;
    cout << root->data << ' ';
    preorder(root->left);
    preorder(root->right);
}

void postorder(TreeNode* root) {
    if (root == nullptr) return;
    postorder(root->left);
    postorder(root->right);
    cout << root->data << ' ';
}
```

== Array representation of a binary tree

The Trees I slide states that if a root is stored at array index $I$, then the left child is at $2 I$ and the right child at $2 I+1$.

#clarification[
  Those formulas correspond to a #strong[1-based] array representation. C++ raw arrays are usually indexed from 0. With a zero-based representation, the common formulas are

  $ "left"(i)=2 i+1, wide "right"(i)=2 i+2, $

  and the parent of a non-root node is $floor.l (i-1)\/2 floor.r$.
]

#workedexample[
  Using zero-based indexing, node at index 2 has left child at $2(2)+1=5$ and right child at $2(2)+2=6$. Using the slide’s 1-based convention, a node at index 2 has children at 4 and 5.
]

#figref(<fig:tree-array>) shows the mapping directly. Reading the tree level by level, left to
right, and writing the values into consecutive array slots is all the representation does ---
the parent-child links are then recoverable by arithmetic, with no pointers stored at all.

#strong[#utpfig([A complete binary tree stored in an array, zero-based. Level-order position becomes array index, so the children of index $i$ sit at $2 i+1$ and $2 i+2$. This is the same layout the heap in #chapref(<ch:trees-ii>) relies on.], label: <fig:tree-array>)[
  #canvas({
    node((2.55, 1.5), [8], name: "v0", font: font("small"), ..utpnode, min-size: 0.8)
    node((1.25, 0.45), [4], name: "v1", font: font("small"), ..utpnode, min-size: 0.8)
    node((3.85, 0.45), [12], name: "v2", font: font("small"), ..utpnode, min-size: 0.8)
    node((0.6, -0.6), [2], name: "v3", font: font("small"), ..utpnode, min-size: 0.8)
    node((1.9, -0.6), [6], name: "v4", font: font("small"), ..utpnode, min-size: 0.8)
    node((3.2, -0.6), [10], name: "v5", font: font("small"), ..utpnode, min-size: 0.8)
    connect("v0", "v1", ..utpedge)
    connect("v0", "v2", ..utpedge)
    connect("v1", "v3", ..utpedge)
    connect("v1", "v4", ..utpedge)
    connect("v2", "v5", ..utpedge)
    for (n, idx) in (("v0", 0), ("v1", 1), ("v2", 2), ("v3", 3), ("v4", 4), ("v5", 5)) {
      node((rel: (0.06, 0.06), to: n + ".north-east"), [#idx], shape: "circle", fill: blue, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
    }
    draw.scope({
      draw.translate((0, -2.35))
      for (i, vv) in (8, 4, 12, 2, 6, 10).enumerate() {
        node((1.05 * i, 0), [#vv], name: "g" + str(i), font: font("small"), ..utpcell, min-width: 1, min-height: 0.82)
        node((1.05 * i, 0.55), [#i], name: "arrayindex" + str(i), shape: "circle", fill: blue, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      }
      node((-0.65, 0), [array], font: font("small"), ..utplabel, anchor: "east")
    })
    curve("v1.east", (2.55, -0.35), (2.15, 0.45), (2.55, 0.22), ..utpptr, draw: orange, dash: "dashed")
    curve((2.55, -0.35), (2.55, -1.5), (2.55, -0.95), (2.55, -1.38), ..utpptr, draw: orange, dash: "dashed")
    curve((2.55, -1.5), (1.575, -1.55), (2.35, -1.62), (1.9, -1.55), ..utpptr, draw: orange, dash: "dashed")
    connect((1.575, -1.55), "arrayindex1.center", ..utpptr, draw: orange, dash: "dashed")
    node((6.6, -0.1), [index 1 holds 4 \
  children: $2(1)+1=3$ \
  #hide[children:]$2(1)+2=4$ \
  $arrow.r$ 2 and 6 ✓], font: font("small"), ..utptag, anchor: "west", align: left)
  })
]]

== Linked representation of a binary tree

A linked representation stores data plus two pointers: one to the left child and one to the right child. A missing child is represented by a null pointer.

#utpfigure[
  #canvas({
    let node-style = (shape: "circle", draw: blue, fill: pale-blue, min-size: 0.8, font: font("small", weight: "bold"))
    let edge = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [8], name: "a", ..node-style)
    node(below-left-of("a", 0.9, 1.2), [4], name: "b", ..node-style)
    node(below-right-of("a", 0.9, 1.2), [12], name: "c", ..node-style)
    node(below-left-of("b", 0.9, 0.5), [2], name: "d", ..node-style)
    node(below-right-of("b", 0.9, 0.5), [6], name: "e", ..node-style)
    connect("a", "b", ..edge)
    connect("a", "c", ..edge)
    connect("b", "d", ..edge)
    connect("b", "e", ..edge)
  })
]

#quickcheck[
  State the inorder, preorder, and postorder rules without looking back. What indexing assumption is required for the slide formula $2 I$ and $2 I+1$?
]
