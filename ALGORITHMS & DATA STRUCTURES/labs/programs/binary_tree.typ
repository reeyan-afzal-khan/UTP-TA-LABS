#import "/.shared/typst/utp.typ": *

#strong[Program 1: One binary tree, two complete implementations.]

#strong[File:] `binary_tree.cpp`.

#strong[Chapter connection:] Recursive traversal code; Array representation of a binary tree.

Translate left/right pointers into indexes 2i+1 and 2i+2. Compare shape and all traversals after update, insertion, and general-tree deletion. EMPTY is reserved for unused slots in this positive-valued dataset. Destroy linked nodes in postorder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-binary_tree.typ"


+ #strong[Headers and initial definitions.]

`binary_tree.cpp` --- lines 14--30.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 14, last: 30, lang: "text")

+ #strong[Implement inorder, preorder, postorder and helpers.]

`binary_tree.cpp` --- lines 31--62.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/traversals.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 31, last: 62, lang: "text")

+ #strong[Implement deleteValue, destroy.]

`binary_tree.cpp` --- lines 63--97.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-tree.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 63, last: 97, lang: "text")

+ #strong[Implement present, arrayInorder, arrayPreorder and helpers.]

`binary_tree.cpp` --- lines 98--124.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-tree-index.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 98, last: 124, lang: "text")

+ #strong[Implement arrayDeleteValue, printIndexTable, sameShape.]

`binary_tree.cpp` --- lines 125--162.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 125, last: 162, lang: "text")

+ #strong[Connect the test cases in main.]

`binary_tree.cpp` --- lines 163--199.

#strong[Trace checkpoint for the supplied main.] After inserting 10 as the left child of 12, its array position is 2 times 2 plus 1 = 5. Deleting value 4 uses the deepest rightmost node, 10, as replacement in this general binary-tree exercise. That is different from the BST successor rule in the next lab. Check linked and array traversals after every mutation, not only their initial shape.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 163, last: 199, lang: "text")

+ #strong[Connect the test cases in main.]

`binary_tree.cpp` --- lines 200--240. Continue in the same file; do not add another header or opening brace.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab07/binary_tree.cpp", first: 200, last: 240, lang: "text")

#strong[Build, run, and inspect binary\_tree.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra binary_tree.cpp -o binary_tree.exe\n\n.\\binary_tree.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Predicted before running (write these down first) ==\n  inorder   2 4 6 8 12\n  preorder  8 4 2 6 12\n  postorder 2 6 4 12 8\n\n== Traversals ==\n  inorder   linked: 2 4 6 8 12   array: 2 4 6 8 12 \n  preorder  linked: 8 4 2 6 12   array: 8 4 2 6 12 \n  postorder linked: 2 6 4 12 8   array: 2 6 4 12 8 \n  [ok]   both representations describe the same shape\n  [ok]   all three traversals agree between the representations\n  [ok]   the predictions match\n  [ok]   each traversal visits every stored node exactly once\n\n== Array index table ==", lang: "text")

The complete captured run is in `labs/outputs/binary_tree.txt`.

#callout("tryit", title: [Try it yourself])[Delete a missing value and then the only node of a fresh tree in both representations. Compare traversal outputs and shape, and confirm all linked allocations are released.]
