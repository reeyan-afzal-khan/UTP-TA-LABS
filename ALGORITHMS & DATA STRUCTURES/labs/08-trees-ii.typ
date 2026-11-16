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
  Build one program at a time from its `all_experiments/Lab08` folder.

  #include "programs/bst.typ"

  #colbreak()

  #include "programs/heap.typ"

  #strong[Instructor-led B-tree extension.] Use the degree and occupancy rules specified in class to draw split, borrow, and merge. The complete programs here cover BSTs, height checks, and min/max heaps; B-tree implementation is outside these supplied program files.
]

#checklist[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
