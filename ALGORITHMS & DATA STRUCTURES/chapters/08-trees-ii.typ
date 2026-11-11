#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-trees-ii")


#heading(level: 1)[Trees II: BSTs, Heaps, and Height Balancing]
<ch:trees-ii>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Understand binary trees, node height, and the array/linked representations from #ref(label("ch:trees-i"), supplement: [Chapter]).

*By the end, you can:* state the BST ordering rule, distinguish almost-complete and heap structures, compare max-heaps and min-heaps, and explain the purpose of height balancing.]

The Trees II slides specialize the general binary-tree idea into structures that impose additional rules. Those rules are valuable because they constrain where values can appear.


#heading(level: 2)[Binary search tree (BST)]


A #strong[binary search tree] is a binary tree with an ordering restriction. In the slide wording, the root value is larger than any value in its left subtree and smaller than any value in its right subtree. The same ordering idea is applied recursively at each node.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/a08174f9360f9aa3.cetz.json")], caption: [The BST ordering rule, and the search path it produces. Every comparison discards an entire subtree, so searching for 6 touches three nodes rather than seven.]) <fig:bst-search>

Searching compares the target with the current node and chooses one subtree.

#code-block("bool contains(TreeNode* root, int target) {\n    while (root != nullptr) {\n        if (target == root->data) return true;\n        if (target < root->data) root = root->left;\n        else root = root->right;\n    }\n    return false;\n}", lang: "text")

#callout("clarification", title: [Clarification])[The slide states that BST searching is reduced to $O \( log N \)$. That is the expected/balanced-tree behavior. A plain BST can become highly unbalanced (for example, inserting already sorted keys), in which case search can degrade to $O \( N \)$. The later height-balancing concept explains why keeping height controlled matters.]

#ref(label("fig:bst-degenerate"), supplement: [Figure]) makes that failure concrete. Inserting the same seven keys in sorted order produces a tree that is really a linked list: every node has one child, the height grows with $N$ rather than $log N$, and the search advantage disappears entirely.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/6dc82e3179c079ab.cetz.json")], caption: [The same seven keys, two insertion orders. Balanced insertion gives height~2 and at most three comparisons; sorted insertion gives height~6 and up to seven. The BST ordering rule is satisfied in both cases --- only the shape differs, and the shape is what determines the cost.]) <fig:bst-degenerate>


#heading(level: 2)[BST insertion]


Insertion follows the same comparisons used by search.

#code-block("TreeNode* insertBST(TreeNode* root, int value) {\n    if (root == nullptr) {\n        return new TreeNode{value, nullptr, nullptr};\n    }\n\n    if (value < root->data)\n        root->left = insertBST(root->left, value);\n    else if (value > root->data)\n        root->right = insertBST(root->right, value);\n\n    return root;\n}", lang: "text")

The slide deck does not specify how duplicate keys should be handled, so the example above simply ignores duplicates.


#heading(level: 2)[BST deletion]


Deletion is the one BST operation with genuinely distinct cases, because removing a node must leave the ordering rule intact for everything below it (#ref(label("fig:bst-delete"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/eca75e350e17e8b5.cetz.json")], caption: [The three deletion cases. A leaf simply goes. A node with one child is replaced by that child. A node with two children keeps its position in the tree but takes the value of its #emph[inorder successor] --- the smallest key in its right subtree --- which is then deleted from below, where it is guaranteed to have at most one child.]) <fig:bst-delete>

#callout("clarification", title: [Clarification])[Deletion is not spelled out in the supplied Trees II material. The three-case treatment above is the standard formulation, included so the operation can be implemented for the lab and the final project.]


#heading(level: 2)[Almost complete binary tree]


The slides define an #strong[almost complete binary tree] as a binary tree where all levels are full except possibly the last, and the last level is filled from the left as far as possible.

This shape is important for heaps because it allows a compact array representation without arbitrary gaps.


#heading(level: 2)[Heaps]


A #strong[heap] is a tree-based structure whose shape is a complete/almost-complete binary tree and whose values satisfy a heap-order rule.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Heap type], [Rule from the slides],),
    table.hline(),
    [Max-heap], [The root key is maximum among its children, and the same property holds recursively in every subtree.],
    [Min-heap], [The root key is minimum among its children, and the same property holds recursively in every subtree.],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/2516650cc2837bd6.cetz.json")], caption: [A max-heap and its array. The heap-order rule constrains each parent against its own children only --- it says nothing about left-to-right order, which is why 50 may sit to the left of 60. Because the shape is almost complete, the tree packs into the array with no gaps.]) <fig:max-heap>


#heading(level: 2)[Array representation of a heap]


Using zero-based indexing, the binary-tree relationships are $ upright("left") \( i \) = 2 i + 1 \, #h(2em) upright("right") \( i \) = 2 i + 2 \, #h(2em) upright("parent") \( i \) = ⌊frac(i - 1, 2)⌋ . $ The nearly complete shape makes these formulas practical.


#heading(level: 2)[Insertion into a max-heap]


A standard implementation inserts at the next available array position and then moves the new value upward while the heap-order property is violated.

#code-block("void pushMaxHeap(vector<int>& heap, int value) {\n    heap.push_back(value);\n    int i = static_cast<int>(heap.size()) - 1;\n\n    while (i > 0) {\n        int p = (i - 1) / 2;\n        if (heap[p] >= heap[i]) break;\n        swap(heap[p], heap[i]);\n        i = p;\n    }\n}", lang: "text")

#callout("clarification", title: [Clarification])[The Trees II slides require heap creation plus insertion and deletion in the lab, but they do not spell out heapify-up/heapify-down algorithms. The code here is an implementation expansion of that lab requirement.]

#ref(label("fig:heap-siftup"), supplement: [Figure]) traces that loop. The new value enters at the only position the shape allows --- the next free array slot --- and then climbs, swapping with its parent until a larger parent stops it. Because the tree's height is $log n$, the climb is bounded by $O \( log n \)$ swaps.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/4ac478ca3aa5ca9a.cetz.json")], caption: [Inserting 95 into the max-heap. The value is appended at index 6, then swapped upward past 60 and 90 until the heap-order rule holds again. Only nodes on the path from the insertion point to the root are ever touched.]) <fig:heap-siftup>


#heading(level: 2)[Height-balancing trees]


The slides define a height-balancing tree by requiring the height difference between a node's left and right subtrees to be no more than 1. If insertion makes that difference exceed 1, an appropriate balancing action is taken immediately.

#callout("utpfigure", title: [])[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/becb737a11a954d9.cetz.json")]

The slide deck names AVL trees and B-trees as examples associated with height balancing and states that the advantage is $O \( log N \)$ worst-case searching when height is controlled.

#callout("clarification", title: [Clarification])[The supplied Trees II deck names AVL and B-tree concepts but does not teach rotations, B-tree node-order rules, split/merge operations, or full B-tree algorithms. The notes therefore keep those structures at the conceptual level and preserve B-tree creation/add/remove as lab-directed practice rather than inventing a detailed lecture that was not present.]

#callout("quickcheck", title: [Check your understanding])[What additional condition turns a binary tree into a BST? What two independent properties define a heap: its shape and its ordering rule?]
