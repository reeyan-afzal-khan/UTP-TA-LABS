#import "/.shared/typst/utp.typ": *

#strong[Program 1: BST operations and height checks.]

#strong[File:] `bst.cpp`.

#strong[Chapter connection:] BST insertion; BST deletion; Height-balancing trees.

Reuse the chapter comparison rule for both insertion and search. Deletion returns the replacement subtree, so callers must assign its result. main covers leaf, one-child, and two-child deletion, then contrasts a chain with a shorter tree.

#include "../visuals/program-bst.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`bst.cpp` --- lines 14--30.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 14, last: 30, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement insertBST, contains, deleteBST.]
]

`bst.cpp` --- lines 31--65.

#include "../visuals/walk-bst.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 31, last: 65, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Implement inorder, height, isBST and helpers.]
]

`bst.cpp` --- lines 66--97.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 66, last: 97, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Implement draw, destroy, join and helpers.]
]

`bst.cpp` --- lines 98--131.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 98, last: 131, lang: "cpp")

#colbreak()

#utpsteps[
  5. #strong[Connect the test cases in main.]
]

`bst.cpp` --- lines 132--164.

#include "../visuals/walk-bst-case.typ"

#strong[Trace checkpoint for the supplied main.] Follow the three deletion cases in order: remove leaf 20; replace 30 by its only child 40; replace two-child root 50 by successor 60 and remove the successor from its former position. Assign the returned root after each call. Inorder must remain sorted, root must hold 60, and four live nodes must remain before destroy.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 132, last: 164, lang: "cpp")

#colbreak()

#utpsteps[
  6. #strong[Connect the test cases in main.]
]

`bst.cpp` --- lines 165--181. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 165, last: 181, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect bst.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra bst.cpp -o bst.exe

.\bst.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

```terminal

== Insert 50, 30, 70, 20, 40, 60, 80 ==
            80
        70
            60
    50
            40
        30
            20
after insertion
  inorder: 20 30 40 50 60 70 80   height: 2
  [ok]   inorder output is sorted
  [ok]   every node respects the BST rule

== Search ==
  contains(60): yes   contains(65): no

```

The complete captured run is in `labs/outputs/bst.txt`.

#exercises[
  Insert a duplicate key and verify that the inorder output is unchanged. Delete the root from a one-node tree; assign the returned pointer and confirm it is null.
]
