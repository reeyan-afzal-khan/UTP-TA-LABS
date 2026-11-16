#import "/.shared/typst/utp.typ": *
#unit("labs", "05-stacks")

#labsection(5, label: <sec:lab05>)[Stack ADT and expression processing]

#labproject[Implement the stack ADT twice][
  #note[
    #strong[Official Lab Manual --- Lab V.] Array stack, linked stack, and infix-to-postfix conversion.
  ]

  #strong[Goal.] Build two LIFO stacks, then use a stack to convert expressions.

  #strong[Recall first.] Review the #link(<ch:stacks>)[Stacks] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Build one program at a time from its `all_experiments/Lab05` folder.

  #include "programs/array_stack.typ"

  #colbreak()

  #include "programs/linked_stack.typ"

  #colbreak()

  #include "programs/infix_to_postfix.typ"
]

#checklist[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
