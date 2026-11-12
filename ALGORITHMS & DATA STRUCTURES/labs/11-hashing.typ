#import "/.shared/typst/utp.typ": *
#unit("labs", "11-hashing")

#labsection(11, label: <sec:lab11>)[Hashing and collision resolution]

#sourcealignment[Official Lab Manual --- Lab XI][
  Linear, quadratic, and double-hash collision resolution.
]

#labproject[Resolve the same collision three ways][
  #strong[Goal.] Resolve identical collisions using three probe rules.

  #strong[Recall first.] Review the #link(<ch:hashing>)[Hashing] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Build one program at a time from its `all_experiments/Lab11` folder.

  #include "programs/hashing_collisions.typ"
]

#verification[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
