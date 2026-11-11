#import "/.shared/typst/utp.typ": *
#unit("chapters", "07-trees-i")


#heading(level: 1)[Trees I: Terminology, Traversal, and Binary Trees]
<ch:trees-i>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know linear and non-linear classification, linked-node representation, and basic pointer-based traversal.

*By the end, you can:* define a tree and subtree, use root/parent/sibling/level/height terminology, trace inorder/preorder/postorder traversal, and explain array and linked representations of a binary tree.]

A #strong[tree] is a non-linear data structure in which data is stored hierarchically. The Trees I deck defines a tree recursively: there is a specially designated #strong[root], and the remaining nodes can be partitioned into disjoint subtrees of that root.


#heading(level: 2)[Root and subtrees]


The slide example uses root $A$ with the following structure.

#callout("utpfigure", title: [])[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/610e3140510de703.cetz.json")]

The Trees I slide explicitly identifies the subtree rooted at $B$ as one subtree of $A$, and similarly identifies the $C$ and $D$ branches as other subtrees.


#heading(level: 2)[Tree terminology]



#heading(level: 3)[Edge]
 An #strong[edge] is the connecting link between two nodes.

#callout("clarification", title: [Clarification])[The slide says that with $N$ nodes there will be a #emph[maximum] of $N - 1$ edges. For an ordinary connected tree with $N$ nodes, the standard invariant is stronger: it has #emph[exactly] $N - 1$ edges. The slide wording is preserved here and the standard property is supplied as clarification.]


#heading(level: 3)[Parent and sibling]
 If node $N$ is the immediate predecessor of node $X$, then $N$ is the parent of $X$. Nodes with the same parent are siblings. In the slide example, $A$ is a parent of $B$, $C$, and $D$; $E$ and $F$ are siblings.


#heading(level: 3)[Internal node]
 An internal node has at least one child. In the diagram above, examples include $A$, $B$, $C$, $D$, $E$, and $H$.

#callout("clarification", title: [Clarification])[One slide lists $A \, B \, C \, D \, E \, F \, G \, H \, I \, J$ as internal nodes, but the accompanying diagram shows several of those nodes without children. These notes use the slide's own definition --- "has at least one child" --- when classifying the drawn example.]


#heading(level: 3)[Level]
 The #strong[level] of a node is the number of edges on the path from that node to the root. The root is at level 0. If a node is at level $ell$, its children are at level $ell + 1$.


#heading(level: 3)[Height]
 The slides define the height of a node as the number of edges on the longest path from that node down to a leaf. In the example, $H$ has one child $M$, so its height is 1.

#callout("workedexample", title: [Worked example])[Using the recreated slide tree: $A$ is at level 0, $D$ is at level 1, $H$ is at level 2, and $M$ is at level 3. The height of $H$ is 1 because the longest downward path is $H arrow.r M$.]


#heading(level: 2)[Tree traversal]


Traversal means visiting every node exactly once. The Trees I deck teaches three depth-first traversal orders.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Traversal], [Rule],),
    table.hline(),
    [Inorder], [Left subtree $arrow.r$ root $arrow.r$ right subtree],
    [Preorder], [Root $arrow.r$ left subtree $arrow.r$ right subtree],
    [Postorder], [Left subtree $arrow.r$ right subtree $arrow.r$ root],
  )]
  , kind: table
  )

These traversal rules are most naturally applied to binary trees, because each node has a clear left and right subtree.

The three orders differ in one respect only: #emph[when the root is visited] relative to its subtrees. #ref(label("fig:traversals"), supplement: [Figure]) applies all three to the same tree, numbering each node with its position in the output sequence.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/dde0d4a2f7a243ed.cetz.json")], caption: [The same binary tree under all three depth-first traversals. The shape of the walk is identical in every case --- down the left, down the right, back up --- and only the moment at which a node is #emph[recorded] moves. Inorder on a search tree yields sorted output, which is why it is the one used most often.]) <fig:traversals>


#heading(level: 2)[Binary trees]


A #strong[binary tree] is a tree in which each node has at most two children. A binary-tree node can be represented with two pointers.

#code-block("struct TreeNode {\n    int data;\n    TreeNode* left;\n    TreeNode* right;\n};", lang: "text")


#heading(level: 3)[Recursive traversal code]


#code-block("void inorder(TreeNode* root) {\n    if (root == nullptr) return;\n    inorder(root->left);\n    cout << root->data << ' ';\n    inorder(root->right);\n}\n\nvoid preorder(TreeNode* root) {\n    if (root == nullptr) return;\n    cout << root->data << ' ';\n    preorder(root->left);\n    preorder(root->right);\n}\n\nvoid postorder(TreeNode* root) {\n    if (root == nullptr) return;\n    postorder(root->left);\n    postorder(root->right);\n    cout << root->data << ' ';\n}", lang: "text")


#heading(level: 2)[Array representation of a binary tree]


The Trees I slide states that if a root is stored at array index $I$, then the left child is at $2 I$ and the right child at $2 I + 1$.

#callout("clarification", title: [Clarification])[Those formulas correspond to a #strong[1-based] array representation. C++ raw arrays are usually indexed from 0. With a zero-based representation, the common formulas are $ upright("left") \( i \) = 2 i + 1 \, #h(2em) upright("right") \( i \) = 2 i + 2 \, $ and the parent of a non-root node is $floor.l \( i - 1 \) \/ 2 floor.r$.]

#callout("workedexample", title: [Worked example])[Using zero-based indexing, node at index 2 has left child at $2 \( 2 \) + 1 = 5$ and right child at $2 \( 2 \) + 2 = 6$. Using the slide's 1-based convention, a node at index 2 has children at 4 and 5.]

#ref(label("fig:tree-array"), supplement: [Figure]) shows the mapping directly. Reading the tree level by level, left to right, and writing the values into consecutive array slots is all the representation does --- the parent-child links are then recoverable by arithmetic, with no pointers stored at all.

#strong[#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/cd8192bb28335fc9.cetz.json")], caption: [A complete binary tree stored in an array, zero-based. Level-order position becomes array index, so the children of index $i$ sit at $2 i + 1$ and $2 i + 2$. This is the same layout the heap in #ref(label("ch:trees-ii"), supplement: [Chapter]) relies on.]) <fig:tree-array>]


#heading(level: 2)[Linked representation of a binary tree]


A linked representation stores data plus two pointers: one to the left child and one to the right child. A missing child is represented by a null pointer.

#callout("utpfigure", title: [])[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/69d26c13d495ac9c.cetz.json")]

#callout("quickcheck", title: [Check your understanding])[State the inorder, preorder, and postorder rules without looking back. What indexing assumption is required for the slide formula $2 I$ and $2 I + 1$?]
