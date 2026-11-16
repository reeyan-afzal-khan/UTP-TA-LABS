#import "/.shared/typst/utp.typ": *

#strong[Program 1: One binary tree, two complete implementations.]

#strong[File:] `binary_tree.cpp`.

#strong[Chapter connection:] Recursive traversal code; Array representation of a binary tree.

Translate left/right pointers into indexes 2i+1 and 2i+2. Compare shape and all traversals after update, insertion, and general-tree deletion. EMPTY is reserved for unused slots in this positive-valued dataset. Destroy linked nodes in postorder.

#include "../visuals/program-binary_tree.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`binary_tree.cpp` --- lines 14--30.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 14, last: 30, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement inorder, preorder, postorder and helpers.]
]

`binary_tree.cpp` --- lines 31--62.

#include "../visuals/traversals.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 31, last: 62, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Implement deleteValue, destroy.]
]

`binary_tree.cpp` --- lines 63--97.

#include "../visuals/walk-tree.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 63, last: 97, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Implement present, arrayInorder, arrayPreorder and helpers.]
]

`binary_tree.cpp` --- lines 98--124.

#include "../visuals/walk-tree-index.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 98, last: 124, lang: "cpp")

#colbreak()

#utpsteps[
  5. #strong[Implement arrayDeleteValue, printIndexTable, sameShape.]
]

`binary_tree.cpp` --- lines 125--162.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 125, last: 162, lang: "cpp")

#colbreak()

#utpsteps[
  6. #strong[Connect the test cases in main.]
]

`binary_tree.cpp` --- lines 163--199.

#strong[Trace checkpoint for the supplied main.] After inserting 10 as the left child of 12, its array position is 2 times 2 plus 1 = 5. Deleting value 4 uses the deepest rightmost node, 10, as replacement in this general binary-tree exercise. That is different from the BST successor rule in the next lab. Check linked and array traversals after every mutation, not only their initial shape.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 163, last: 199, lang: "cpp")

#colbreak()

#utpsteps[
  7. #strong[Connect the test cases in main.]
]

`binary_tree.cpp` --- lines 200--240. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 200, last: 240, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect binary\_tree.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra binary_tree.cpp -o binary_tree.exe

.\binary_tree.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/binary_tree.txt`.

#exercises[
  Delete a missing value and then the only node of a fresh tree in both representations. Compare traversal outputs and shape, and confirm all linked allocations are released.
]
