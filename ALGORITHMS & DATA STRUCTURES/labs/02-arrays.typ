#import "/.shared/typst/utp.typ": *
#unit("labs", "02-arrays")

#labsection(2, label: <sec:lab02>)[Arrays, multidimensional storage, and matrices]

#sourcealignment[Official Lab Manual --- Lab II][
  1D/2D arrays, nested loops, and matrix operations.
]

#labproject[Process and multiply matrices][
  #strong[Goal.] Multiply compatible matrices and trace one result cell.

  #strong[Recall first.] Review the #link(<ch:arrays>)[Arrays and Two-Dimensional Arrays] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Build one program at a time from its `all_experiments/Lab02` folder.

  #include "programs/matrix_multiply.typ"

  #colbreak()

  #include "programs/matrix_operations.typ"
]

#verification[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
