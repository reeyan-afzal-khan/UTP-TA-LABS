#import "/.shared/typst/utp.typ": *
#unit("labs", "08-trees-ii")

#labsection(8, label: <sec:lab08>)[BSTs, heaps, and balancing structures]

#labproject[Compare ordering rules across specialized trees][
  #note[
    #strong[Official Lab Manual --- Lab VIII.] BST operations, min/max heaps, height balancing, and instructor-led B-tree practice.
  ]

  #strong[Goal.] Compare BST ordering, heap ordering, and the effect of tree height.

  #strong[Recall first.] Review the #link(<ch:trees-ii>)[BSTs, Heaps, and Height Balancing] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Save each one in your `Lab08` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab08`.

  #include "programs/bst.typ"

  #include "programs/heap.typ"

  #strong[Instructor-led B-tree extension.] Use the degree and occupancy rules specified in class to draw split, borrow, and merge. The complete programs here cover BSTs, height checks, and min/max heaps; B-tree implementation is outside these supplied program files.
]

#element-head([The k-th smallest key])

Because inorder visits the keys of a binary search tree in ascending order, the k-th key it visits is the k-th smallest. Write `kthSmallest(root, k)`: walk inorder, count the nodes as you visit them, and stop as soon as the count reaches k, without visiting the rest of the tree. On the first tree of Program 1, k = 3 must give 40 and k = 7 must give 80, and k = 8 must report that no such key exists. Then answer two questions. How would you find the same key with the min-heap of Program 2? What does each method cost on a tree of height h holding n keys?
