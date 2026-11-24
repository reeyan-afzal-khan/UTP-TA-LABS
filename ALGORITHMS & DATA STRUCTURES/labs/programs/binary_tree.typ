#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: One binary tree, two complete implementations])

#strong[File:] `binary_tree.cpp`.

#strong[Chapter connection:] Recursive traversal code; Array representation of a binary tree.

Translate left/right pointers into indexes 2i+1 and 2i+2. Compare shape and all traversals after update, insertion, and general-tree deletion. EMPTY is reserved for unused slots in this positive-valued dataset. Destroy linked nodes in postorder.

#include "../visuals/program-binary_tree.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `binary_tree.cpp` --- lines 14--30.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 14, last: 30, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement inorder, preorder, postorder and helpers.]
  ]

  `binary_tree.cpp` --- lines 31--62.
]

#include "../visuals/traversals.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 31, last: 62, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Implement deleteValue, destroy.]
  ]

  `binary_tree.cpp` --- lines 63--97.
]

#include "../visuals/walk-tree.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 63, last: 97, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Implement present, arrayInorder, arrayPreorder and helpers.]
  ]

  `binary_tree.cpp` --- lines 98--124.
]

#include "../visuals/walk-tree-index.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 98, last: 124, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    5. #strong[Implement arrayDeleteValue, printIndexTable, sameShape.]
  ]

  `binary_tree.cpp` --- lines 125--162.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 125, last: 162, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    6. #strong[Connect the test cases in main.]
  ]

  `binary_tree.cpp` --- lines 163--199.
]

#strong[Trace checkpoint for the supplied main.] After inserting 10 as the left child of 12, its array position is 2 times 2 plus 1 = 5. Deleting value 4 uses the deepest rightmost node, 10, as replacement in this general binary-tree exercise. That is different from the BST successor rule in the next lab. Check linked and array traversals after every mutation, not only their initial shape.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 163, last: 199, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    7. #strong[Connect the test cases in main.]
  ]

  `binary_tree.cpp` --- lines 200--240. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 200, last: 240, lang: "cpp")

#strong[Predict first, then compare.] The program prints its own predictions before any traversal runs. Write yours down before you look; the third check compares them with the real traversals.

```terminal
== Predicted before running (write these down first) ==
  inorder   2 4 6 8 12
  preorder  8 4 2 6 12
  postorder 2 6 4 12 8
== Traversals ==
  inorder   linked: 2 4 6 8 12   array: 2 4 6 8 12
  preorder  linked: 8 4 2 6 12   array: 8 4 2 6 12
  postorder linked: 2 6 4 12 8   array: 2 6 4 12 8
  [ok]   both representations describe the same shape
  [ok]   all three traversals agree between the representations
  [ok]   the predictions match
  [ok]   each traversal visits every stored node exactly once
== Array index table ==
  0-based: index  left  right  parent   1-based: I  2I  2I+1    value
               0     1      2       -             1   2     3        8
               1     3      4       0             2   4     5        4
               2     -      -       0             3   -     -       12
               3     -      -       1             4   -     -        2
               4     -      -       1             5   -     -        6
== Update: change 6 to 7 ==
...
== Structural insertion: 10 becomes the left child of 12 ==
  0-based: index  left  right  parent   1-based: I  2I  2I+1    value
               0     1      2       -             1   2     3        8
               1     3      4       0             2   4     5        4
               2     5      -       0             3   6     -       12
               3     -      -       1             4   -     -        2
               4     -      -       1             5   -     -        7
               5     -      -       2             6   -     -       10
  inorder   linked: 2 4 7 8 10 12   array: 2 4 7 8 10 12
  preorder  linked: 8 4 2 7 12 10   array: 8 4 2 7 12 10
  postorder linked: 2 7 4 10 12 8   array: 2 7 4 10 12 8
  [ok]   both representations describe the same shape
  [ok]   all three traversals agree between the representations
== Deletion: remove 4 (replaced by the deepest, rightmost node, 10) ==
...
  inorder   linked: 2 10 7 8 12   array: 2 10 7 8 12
  preorder  linked: 8 10 2 7 12   array: 8 10 2 7 12
  postorder linked: 2 7 10 12 8   array: 2 7 10 12 8
  [ok]   both representations describe the same shape
  [ok]   all three traversals agree between the representations
  [ok]   deleting a value that is not in the tree is refused
== Empty tree ==
  [ok]   traversing an empty tree terminates and visits nothing
  [ok]   every node was released
```

Each traversal line carries two answers, one from the linked tree and one from the array, and they must agree after every change. The index table is the array version written out: the children of index `i` sit at `2i+1` and `2i+2`, and its parent at `(i-1)/2`, which is why 10, the new left child of 12 at index 2, lands at index 5. Deleting 4 shows what a general binary tree does. The deepest, rightmost node, 10, moves into the gap, and the inorder line becomes 2 10 7 8 12. Nothing requires it to be sorted; keeping keys in order is the rule of the binary search tree in the next lab.

#strong[Delete down to nothing.] Build a fresh tree that holds only 8, in both representations. Delete 5, which is not there: both versions must refuse and stay unchanged. Then delete 8. All three traversals must print nothing, slot 0 of the array must hold `EMPTY`, the linked root must be `nullptr`, and the last check must still report that every node was released.
