#import "/.shared/typst/utp.typ": *
#unit("labs", "04-circular-list")

#labsection(4, label: <sec:lab04>)[Circular linked-list operations]

#labproject[Maintain a circular list without breaking the loop][
  #note[
    #strong[Official Lab Manual --- Lab IV.] Circular linked-list insertion/deletion; compare list representations.
  ]

  #strong[Goal.] Insert, delete, and traverse without breaking the ring.

  #strong[Recall first.] Review the #link(<ch:circular-list>)[Circular Linked Lists] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Build one program at a time from its `all_experiments/Lab04` folder.

  #include "programs/circular_linked_list.typ"

  #colbreak()

  #include "programs/list_comparison.typ"
]

#checklist[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
