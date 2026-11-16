#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-trees-ii")

= Trees II: BSTs, Heaps, and Height Balancing <ch:trees-ii>

#chapterguide[Understand binary trees, node height, and the array/linked representations from #chapref(<ch:trees-i>).][state the BST ordering rule, distinguish almost-complete and heap structures, compare max-heaps and min-heaps, and explain the purpose of height balancing.]

The Trees II slides specialize the general binary-tree idea into structures that impose additional rules. Those rules are valuable because they constrain where values can appear.

== Binary search tree (BST)

A #term[binary search tree] is a binary tree with an ordering restriction. In the slide wording, the root value is larger than any value in its left subtree and smaller than any value in its right subtree. The same ordering idea is applied recursively at each node.

#utpfig([The BST ordering rule, and the search path it produces. Every comparison discards an entire subtree, so searching for 6 touches three nodes rather than seven.], label: <fig:bst-search>)[
  #canvas({
    draw.scope({
      node((0, 0.9), [8], name: "a", font: font("small"), ..utpnode)
      node((-1.35, -0.2), [4], name: "b", font: font("small"), ..utpnode)
      node((1.35, -0.2), [12], name: "c", font: font("small"), ..utpnode)
      node((-2, -1.3), [2], name: "d", font: font("small"), ..utpnode)
      node((-0.7, -1.3), [6], name: "e", font: font("small"), ..utpnode)
      node((0.7, -1.3), [10], name: "f", font: font("small"), ..utpnode)
      node((2, -1.3), [14], name: "g", font: font("small"), ..utpnode)
      for (u, vv) in (("a", "b"), ("a", "c"), ("b", "d"), ("b", "e"), ("c", "f"), ("c", "g")) {
        connect(u, vv, ..utpedge)
      }
      connect((-2.45, -1.78), (-0.25, -1.78), ..utpbrace)
      connect((0.25, -1.78), (2.45, -1.78), ..utpbrace)
      node((-1.35, -2.18), [all $<8$], font: font("small"), ..utplabel, anchor: "north", text: blue)
      node((1.35, -2.18), [all $>8$], font: font("small"), ..utplabel, anchor: "north", text: blue)
    })
    draw.scope({
      draw.translate((7, 0))
      node((0, 0.9), [8], name: "h", font: font("small"), ..utpnodehot)
      node((-1.35, -0.2), [4], name: "i", font: font("small"), ..utpnodehot)
      node((1.35, -0.2), [12], name: "j", font: font("small"), ..utpnode)
      node((-2, -1.3), [2], name: "k", font: font("small"), ..utpnode)
      node((-0.7, -1.3), [6], name: "l", font: font("small"), ..utpnodedone)
      node((0.7, -1.3), [10], name: "m", font: font("small"), ..utpnode)
      node((2, -1.3), [14], name: "n", font: font("small"), ..utpnode)
      for (u, vv) in (("h", "j"), ("i", "k"), ("j", "m"), ("j", "n")) {
        connect(u, vv, ..utpedge, draw: mix(muted, 40%))
      }
      connect("h", "i", ..utpedge, draw: orange, line-width: 1.0959pt)
      connect("i", "l", ..utpedge, draw: orange, line-width: 1.0959pt)
      node((0.62, 1.02), [$6<8$: go left], font: font("small"), ..utplabel, anchor: "west", text: orange)
      node((-1.78, -0.42), [$6>4$: go right], font: font("small"), ..utplabel, anchor: "east", text: orange)
      node((-0.7, -1.75), [found], font: font("small"), ..utplabel, anchor: "north", text: green)
      node((0.9, -2.15), [greyed subtrees are never examined], font: font("small"), ..utplabel, anchor: "north", align: center, text: muted)
    })
  })
]

Searching compares the target with the current node and chooses one subtree.

```cpp
    while (root != nullptr) {
        if (target == root->data) return true;
        if (target < root->data) root = root->left;
        else root = root->right;
    }
    return false;
}
```

#note[
  The slide states that BST searching is reduced to $O(log N)$. That is the expected/balanced-tree behavior. A plain BST can become highly unbalanced (for example, inserting already sorted keys), in which case search can degrade to $O(N)$. The later height-balancing concept explains why keeping height controlled matters.
]

#figref(<fig:bst-degenerate>) makes that failure concrete. Inserting the same seven keys in
sorted order produces a tree that is really a linked list: every node has one child, the
height grows with $N$ rather than $log N$, and the search advantage disappears entirely.

#utpfig([The same seven keys, two insertion orders. Balanced insertion gives height~2 and at most three comparisons; sorted insertion gives height~6 and up to seven. The BST ordering rule is satisfied in both cases --- only the shape differs, and the shape is what determines the cost.], label: <fig:bst-degenerate>)[
  #canvas({
    draw.scope({
      node((0, 1.55), [inserted 8, 4, 12, 2, 6, 10, 14 \
  #strong[#text(fill: green)[height 2]], search #cxg[$O(log n)$]], font: font("small"), ..utplabel, anchor: "south", align: center)
      node((0, 0.75), [8], name: "a", font: font("small"), ..utpnode, min-size: 0.75)
      node((-1.15, -0.2), [4], name: "b", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.15, -0.2), [12], name: "c", font: font("small"), ..utpnode, min-size: 0.75)
      node((-1.75, -1.15), [2], name: "d", font: font("small"), ..utpnode, min-size: 0.75)
      node((-0.55, -1.15), [6], name: "e", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.55, -1.15), [10], name: "f", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.75, -1.15), [14], name: "g", font: font("small"), ..utpnode, min-size: 0.75)
      for (u, vv) in (("a", "b"), ("a", "c"), ("b", "d"), ("b", "e"), ("c", "f"), ("c", "g")) {
        connect(u, vv, ..utpedge)
      }
    })
    draw.scope({
      draw.translate((6.2, 0))
      draw.translate((0, 0.15))
      node((2.04, 1.4), [inserted 2, 4, 6, 8, 10, 12, 14 \
  #strong[#text(fill: red)[height 6]], search #cxr[$O(n)$]], font: font("small"), ..utplabel, anchor: "south", align: center)
      for (i, vv) in range(2, 15, step: 2).enumerate() {
        node((0.68 * i, 0.6 - 0.52 * i), [#vv], name: "p" + str(i), font: font("small"), ..utpnode, min-size: 0.75, draw: red, fill: pale-red)
      }
      for i in range(0, 6) {
        let j = int(i + 1)
        connect("p" + str(i), "p" + str(j), ..utpedge, draw: mix(red, 70%))
      }
      node((4.25, -0.6), [every node has one child: \
  this is a linked list \
  wearing a tree’s notation], font: font("small"), ..utplabel, anchor: "west", align: left, text: red)
    })
  })
]

== BST insertion

Insertion follows the same comparisons used by search.

```cpp
    if (root == nullptr) {
        return new TreeNode{value, nullptr, nullptr};
    }

    if (value < root->data)
        root->left = insertBST(root->left, value);
    else if (value > root->data)
        root->right = insertBST(root->right, value);

    return root;
}
```

The slide deck does not specify how duplicate keys should be handled, so the example above simply ignores duplicates.

== BST deletion

Deletion is the one BST operation with genuinely distinct cases, because removing a node
must leave the ordering rule intact for everything below it (#figref(<fig:bst-delete>)).

#utpfig([The three deletion cases. A leaf simply goes. A node with one child is replaced by that child. A node with two children keeps its position in the tree but takes the value of its #emph[inorder successor] --- the smallest key in its right subtree --- which is then deleted from below, where it is guaranteed to have at most one child.], label: <fig:bst-delete>)[
  #canvas({
    draw.scope({
      node((0, 1.35), [#strong[1\. Leaf]], font: font("small"), ..utplabel, anchor: "south", align: center, text: navy)
      node((0, 0.55), [8], name: "a0", font: font("small"), ..utpnode, min-size: 0.7)
      node((-0.85, -0.45), [4], name: "a1", font: font("small"), ..utpnode, min-size: 0.7)
      node((0.85, -0.45), [12], name: "a2", font: font("small"), ..utpnode, min-size: 0.7)
      node((-1.5, -1.45), [2], name: "a3", font: font("small"), ..utpdim, shape: "circle", min-size: 0.7)
      connect("a0", "a1", ..utpedge)
      connect("a0", "a2", ..utpedge)
      connect("a1", "a3", ..utpedge, draw: mix(muted, 40%))
      connect((-1.75, -1.7), (-1.25, -1.2), draw: red, line-width: 0.6974pt)
      connect((-1.75, -1.2), (-1.25, -1.7), draw: red, line-width: 0.6974pt)
      node((0, -2), [delete it, \
  clear the parent link], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((5, 0))
      node((0, 1.35), [#strong[2\. One child]], font: font("small"), ..utplabel, anchor: "south", align: center, text: navy)
      node((0, 0.55), [8], name: "b0", font: font("small"), ..utpnode, min-size: 0.7)
      node((-0.85, -0.45), [4], name: "b1", font: font("small"), ..utpnodehot, min-size: 0.7)
      node((0.85, -0.45), [12], name: "b2", font: font("small"), ..utpnode, min-size: 0.7)
      node((-1.5, -1.45), [2], name: "b3", font: font("small"), ..utpnodedone, min-size: 0.7)
      connect("b0", "b1", ..utpedge)
      connect("b0", "b2", ..utpedge)
      connect("b1", "b3", ..utpedge)
      curve("b3.west", "b1.west", (-2.35, -1.35), (-2.35, -0.35), dash: (2.9888pt, 1.4944pt), shorten-start: 2.4907pt, shorten-end: 2.4907pt, draw: white, line-width: 2.9888pt, end: arrow-tip("Stealth", length: 2.7mm, width: 1.9mm, line: 2.9888pt))
      curve("b3.west", "b1.west", (-2.35, -1.35), (-2.35, -0.35), draw: green, line-width: 1.0461pt, dash: (2.9888pt, 1.4944pt), shorten-start: 2.4907pt, shorten-end: 2.4907pt, end: arrow-tip("Stealth", length: 2.7mm, width: 1.9mm, line: 1.0461pt))
      node((0, -2), [promote the child \
  into the gap], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((10.6, 0))
      node((0, 1.35), [#strong[3\. Two children]], font: font("small"), ..utplabel, anchor: "south", align: center, text: navy)
      node((0, 0.55), [8], name: "c0", font: font("small"), ..utpnodehot, min-size: 0.7)
      node((-0.9, -0.45), [4], name: "c1", font: font("small"), ..utpnode, min-size: 0.7)
      node((0.9, -0.45), [12], name: "c2", font: font("small"), ..utpnode, min-size: 0.7)
      node((0.25, -1.45), [10], name: "c3", font: font("small"), ..utpnodedone, min-size: 0.7)
      node((1.55, -1.45), [14], name: "c4", font: font("small"), ..utpnode, min-size: 0.7)
      connect("c0", "c1", ..utpedge)
      connect("c0", "c2", ..utpedge)
      connect("c2", "c3", ..utpedge)
      connect("c2", "c4", ..utpedge)
      curve("c3.south-west", "c0.west", (-1.9, -1.75), (-1.9, 0.85), dash: (2.9888pt, 1.4944pt), shorten-start: 2.4907pt, shorten-end: 2.4907pt, draw: white, line-width: 2.9888pt, end: arrow-tip("Stealth", length: 2.7mm, width: 1.9mm, line: 2.9888pt))
      curve("c3.south-west", "c0.west", (-1.9, -1.75), (-1.9, 0.85), draw: green, line-width: 1.0461pt, dash: (2.9888pt, 1.4944pt), shorten-start: 2.4907pt, shorten-end: 2.4907pt, end: arrow-tip("Stealth", length: 2.7mm, width: 1.9mm, line: 1.0461pt))
      node((0.2, -2), [copy up the inorder successor, \
  then delete it below], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

#note[
  Deletion is not spelled out in the supplied Trees II material. The three-case treatment above
  is the standard formulation, included so the operation can be implemented for the lab and the
  final project.
]

== Almost complete binary tree

The slides define an #term[almost complete binary tree] as a binary tree where all levels are full except possibly the last, and the last level is filled from the left as far as possible.

This shape is important for heaps because it allows a compact array representation without arbitrary gaps.

== Heaps

A #term[heap] is a tree-based structure whose shape is a complete/almost-complete binary tree and whose values satisfy a heap-order rule.

#utptable[
  #tabularx(
    columns: (22%, 1fr),
    styles: (navy-bold,),
    header: ([Heap type], [Rule from the slides]),
    [Max-heap], [The root key is maximum among its children, and the same property holds recursively in every subtree.],
    [Min-heap], [The root key is minimum among its children, and the same property holds recursively in every subtree.],
  )
]

#utpfig([A max-heap and its array. The heap-order rule constrains each parent against its own children only --- it says nothing about left-to-right order, which is why 50 may sit to the left of 60. Because the shape is almost complete, the tree packs into the array with no gaps.], label: <fig:max-heap>)[
  #canvas({
    node((1.9, 1.5), [90], name: "a", font: font("small"), ..utpnode)
    node((0.8, 0.45), [70], name: "b", font: font("small"), ..utpnode)
    node((3, 0.45), [60], name: "c", font: font("small"), ..utpnode)
    node((0.2, -0.6), [20], name: "d", font: font("small"), ..utpnode)
    node((1.4, -0.6), [50], name: "e", font: font("small"), ..utpnode)
    node((2.6, -0.6), [40], name: "f", font: font("small"), ..utpnode)
    for (u, vv) in (("a", "b"), ("a", "c"), ("b", "d"), ("b", "e"), ("c", "f")) {
      connect(u, vv, ..utpedge)
    }
    for (n, idx) in (("a", 0), ("b", 1), ("c", 2), ("d", 3), ("e", 4), ("f", 5)) {
      node((rel: (0.06, 0.06), to: n + ".north-east"), [#idx], shape: "circle", fill: blue, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
    }
    node((4.3, 1), [every parent $>=$ its children; \
  no rule between siblings], font: font("small"), ..utplabel, anchor: "west", align: left)
    draw.scope({
      draw.translate((0, -2.15))
      for (i, vv) in (90, 70, 60, 20, 50, 40).enumerate() {
        node((1.05 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 1, min-height: 0.8)
        node((1.05 * i, 0.53), [#i], shape: "circle", fill: blue, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      }
      node((5.9, 0), [no pointers stored: \
  parent of $i$ is $floor.l (i-1)\/2 floor.r$], font: font("small"), ..utplabel, anchor: "west", align: left)
    })
  })
]

== Array representation of a heap

Using zero-based indexing, the binary-tree relationships are

$ "left"(i)=2 i+1, wide "right"(i)=2 i+2, wide "parent"(i)= floor.l frac(i-1, 2) floor.r . $

The nearly complete shape makes these formulas practical.

== Insertion into a max-heap

A standard implementation inserts at the next available array position and then moves the new value upward while the heap-order property is violated.

```cpp
    heap.push_back(value);
    int i = static_cast<int>(heap.size()) - 1;

    while (i > 0) {
        int p = (i - 1) / 2;
        if (heap[p] >= heap[i]) break;
        swap(heap[p], heap[i]);
        i = p;
    }
}
```

#note[
  The Trees II slides require heap creation plus insertion and deletion in the lab, but they do not spell out heapify-up/heapify-down algorithms. The code here is an implementation expansion of that lab requirement.
]

#figref(<fig:heap-siftup>) traces that loop. The new value enters at the only position the
shape allows --- the next free array slot --- and then climbs, swapping with its parent until
a larger parent stops it. Because the tree’s height is $log n$, the climb is bounded by
#cxg[$O(log n)$] swaps.

#utpfig([Inserting 95 into the max-heap. The value is appended at index 6, then swapped upward past 60 and 90 until the heap-order rule holds again. Only nodes on the path from the insertion point to the root are ever touched.], label: <fig:heap-siftup>)[
  #canvas({
    draw.scope({
      node((1.05, 1), [90], name: "r1", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.15, 0.05), [70], name: "l1", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.95, 0.05), [60], name: "q1", font: font("small"), ..utpnode, min-size: 0.75)
      node((2.55, -0.9), [95], name: "x1", font: font("small"), ..utpnodehot, min-size: 0.75)
      connect("r1", "l1", ..utpedge)
      connect("r1", "q1", ..utpedge)
      connect("q1", "x1", ..utpedge)
      node((1.05, -1.55), [#strong[1\.] append at index 6 \
  $95>60$: violation], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((4.6, 0))
      node((1.05, 1), [90], name: "r2", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.15, 0.05), [70], name: "l2", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.95, 0.05), [95], name: "q2", font: font("small"), ..utpnodehot, min-size: 0.75)
      node((2.55, -0.9), [60], name: "x2", font: font("small"), ..utpnode, min-size: 0.75)
      connect("r2", "l2", ..utpedge)
      connect("r2", "q2", ..utpedge)
      connect("q2", "x2", ..utpedge)
      curve("x2.east", "q2.east", (3.2, -0.72), (3.05, 0.02), shorten-start: 2.4907pt, shorten-end: 2.4907pt, draw: white, line-width: 2.9888pt, end: arrow-tip("Stealth", length: 2.2mm, width: 1.5mm, line: 2.9888pt))
      curve("x2.east", "q2.east", (3.2, -0.72), (3.05, 0.02), draw: orange, line-width: 1.0461pt, shorten-start: 2.4907pt, shorten-end: 2.4907pt, end: arrow-tip("Stealth", length: 2.2mm, width: 1.5mm, line: 1.0461pt))
      node((1.05, -1.55), [#strong[2\.] swap with parent \
  $95>90$: still violated], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((9.2, 0))
      node((1.05, 1), [95], name: "r3", font: font("small"), ..utpnodedone, min-size: 0.75)
      node((0.15, 0.05), [70], name: "l3", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.95, 0.05), [90], name: "q3", font: font("small"), ..utpnode, min-size: 0.75)
      node((2.55, -0.9), [60], name: "x3", font: font("small"), ..utpnode, min-size: 0.75)
      connect("r3", "l3", ..utpedge)
      connect("r3", "q3", ..utpedge)
      connect("q3", "x3", ..utpedge)
      curve("q3.east", "r3.east", (2.8, 0.28), (2.35, 1.2), shorten-start: 2.4907pt, shorten-end: 2.4907pt, draw: white, line-width: 2.9888pt, end: arrow-tip("Stealth", length: 2.2mm, width: 1.5mm, line: 2.9888pt))
      curve("q3.east", "r3.east", (2.8, 0.28), (2.35, 1.2), draw: green, line-width: 1.0461pt, shorten-start: 2.4907pt, shorten-end: 2.4907pt, end: arrow-tip("Stealth", length: 2.2mm, width: 1.5mm, line: 1.0461pt))
      node((1.05, -1.55), [#strong[3\.] swap again \
  root reached: done], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

== Height-balancing trees

The slides define a height-balancing tree by requiring the height difference between a node’s left and right subtrees to be no more than 1. If insertion makes that difference exceed 1, an appropriate balancing action is taken immediately.

#utpfigure[
  #canvas({
    let node-style = (shape: "circle", draw: blue, fill: pale-blue, min-size: 0.7, font: font("script", weight: "bold"))
    let edge = (line-width: widths.thick, draw: teal)
    node((0, 0), [A], name: "a", ..node-style)
    node(below-left-of("a", 0.75, 0.8), [B], name: "b", ..node-style)
    node(below-right-of("a", 0.75, 0.8), [C], name: "c", ..node-style)
    node(below-of("b", 0.75), [D], name: "d", ..node-style)
    node(below-right-of("d", 0.65, 0.25), [E], name: "e", ..node-style)
    connect("a", "b", ..edge)
    connect("a", "c", ..edge)
    connect("b", "d", ..edge)
    connect("d", "e", ..edge)
    node(right-of("a", 2.1), [If one side grows too deep, \
  the tree no longer satisfies \
  the slide’s balance condition.], align: left, font: font("small", fill: muted))
  })
]

The slide deck names AVL trees and B-trees as examples associated with height balancing and states that the advantage is $O(log N)$ worst-case searching when height is controlled.

#note[
  The supplied Trees II deck names AVL and B-tree concepts but does not teach rotations, B-tree node-order rules, split/merge operations, or full B-tree algorithms. The notes therefore keep those structures at the conceptual level and preserve B-tree creation/add/remove as lab-directed practice rather than inventing a detailed lecture that was not present.
]

#questions[
  What additional condition turns a binary tree into a BST? What two independent properties define a heap: its shape and its ordering rule?
]
