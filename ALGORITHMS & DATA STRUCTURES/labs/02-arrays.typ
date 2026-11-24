#import "/.shared/typst/utp.typ": *
#unit("labs", "02-arrays")

#labsection(2, label: <sec:lab02>)[Arrays, multidimensional storage, and matrices]

#labproject[Process and multiply matrices][
  #note[
    #strong[Official Lab Manual --- Lab II.] 1D/2D arrays, nested loops, and matrix operations.
  ]

  #strong[Goal.] Multiply compatible matrices and trace one result cell.

  #strong[Recall first.] Review the #link(<ch:arrays>)[Arrays and Two-Dimensional Arrays] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Save each one in your `Lab02` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab02`.

  #include "programs/matrix_multiply.typ"

  #include "programs/matrix_operations.typ"
]

#element-head([A matrix times its own transpose])

Join the two programs. Build the transpose `T` of `A = [[1, 2, 3], [4, 5, 6]]` with the loop from Program 2, then compute A × T with `multiply` from Program 1. Predict the product first: it is 2 × 2 and comes out symmetric, `[[14, 32], [32, 77]]`. Confirm the symmetry with the test from Program 2, then explain why A × T is symmetric for every matrix A, not just this one. Look at what entry (i, j) of the product combines.
