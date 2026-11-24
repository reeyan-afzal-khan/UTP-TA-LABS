#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: BST operations and height checks])

#strong[File:] `bst.cpp`.

#strong[Chapter connection:] BST insertion; BST deletion; Height-balancing trees.

Reuse the chapter comparison rule for both insertion and search. Deletion returns the replacement subtree, so callers must assign its result. main covers leaf, one-child, and two-child deletion, then contrasts a chain with a shorter tree.

#include "../visuals/program-bst.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `bst.cpp` --- lines 14--30.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 14, last: 30, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement insertBST, contains, deleteBST.]
  ]

  `bst.cpp` --- lines 31--65.
]

#include "../visuals/walk-bst.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 31, last: 65, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Implement inorder, height, isBST and helpers.]
  ]

  `bst.cpp` --- lines 66--97.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 66, last: 97, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Implement draw, destroy, join and helpers.]
  ]

  `bst.cpp` --- lines 98--131.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 98, last: 131, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    5. #strong[Connect the test cases in main.]
  ]

  `bst.cpp` --- lines 132--164.
]

#include "../visuals/walk-bst-case.typ"

#strong[Trace checkpoint for the supplied main.] Follow the three deletion cases in order: remove leaf 20; replace 30 by its only child 40; replace two-child root 50 by successor 60 and remove the successor from its former position. Assign the returned root after each call. Inorder must remain sorted, root must hold 60, and four live nodes must remain before destroy.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 132, last: 164, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    6. #strong[Connect the test cases in main.]
  ]

  `bst.cpp` --- lines 165--181. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/bst.cpp", first: 165, last: 181, lang: "cpp")

#strong[A tree printed on its side.] The display draws the root at the left edge, with each right subtree above its parent and each left subtree below. Turn the page a quarter turn clockwise to see the usual picture.

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
  [ok]   a stored key is found and a missing key is not
  [ok]   inserting a duplicate (40) is ignored
== Deletions ==
delete 20 (a leaf)
  inorder: 30 40 50 60 70 80   height: 2
...
delete 50 (two children; successor 60 replaces it)
  inorder: 40 60 70 80   height: 2
  [ok]   inorder output is sorted
  [ok]   every node respects the BST rule
            80
        70
    60
        40
  [ok]   the root now holds the successor 60
  [ok]   deleted nodes were released
== Try it: the same five keys, two insertion orders ==
inserted 10, 20, 30, 40, 50 (sorted):
                    50
                40
            30
        20
    10
  height 4, height-balanced: no
inserted 30, 20, 40, 10, 50:
            50
        40
    30
        20
            10
  height 2, height-balanced: yes
  [ok]   sorted insertion degrades to a chain of height n-1 = 4
  [ok]   the other order keeps height 2 and is height-balanced
  A search walks at most height+1 nodes: 5 in the chain, 3 in the balanced tree.
  [ok]   every node was released
```

An inorder walk of a binary search tree visits the keys in sorted order, so the first check can test the whole tree by testing one line. Deleting 50 is the hard case, because it has two children. Its inorder successor, 60, the smallest key in its right subtree, is copied into the root, and the old 60 node is deleted from the right subtree instead. The last section is the reason height balancing exists: the same five keys inserted in sorted order make a chain of height 4, and a search may walk all five nodes.

#strong[Insert a key that is already there.] Insert 40 again into the first tree and print the inorder walk: it must still be 20 30 40 50 60 70 80, with one 40. Then build a tree holding only 50 and delete it with `root = deleteBST(root, 50)`. Afterwards `root` must be `nullptr`. Call `deleteBST(root, 50)` without the assignment and `root` is left pointing at a deleted node: the function frees the node, but only its return value can change the caller's pointer.
