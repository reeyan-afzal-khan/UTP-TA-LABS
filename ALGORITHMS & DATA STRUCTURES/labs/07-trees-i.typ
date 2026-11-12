#import "/.shared/typst/utp.typ": *
#unit("labs", "07-trees-i")

#labsection(7, label: <sec:lab07>)[Tree representation and traversal]

#sourcealignment[Official Lab Manual --- Lab VII][
  Array/linked tree representations; traversal, update, insertion, and deletion.
]

#labproject[Represent the same binary tree two ways][
  #strong[Goal.] Represent one binary tree twice and compare traversal results.

  #strong[Recall first.] Review the #link(<ch:trees-i>)[Tree Representation and Traversal] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Build one program at a time from its `all_experiments/Lab07` folder.

  #include "programs/binary_tree.typ"
]

#verification[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
