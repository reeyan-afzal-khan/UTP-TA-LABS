#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: A complete matrix multiplication program])

#strong[File:] `matrix_multiply.cpp`.

#strong[Chapter connection:] Arrays and Two-Dimensional Arrays: nested loops and matrix multiplication.

The output has one cell per row of A and column of B. multiply rejects incompatible shapes before indexing. Its inner loop accumulates matching products; main prints all cells and separately expands cell P\[1\]\[0\].

#include "../visuals/program-matrix_multiply.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `matrix_multiply.cpp` --- lines 9--17.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_multiply.cpp", first: 9, last: 17, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement printMatrix, multiply.]
  ]

  `matrix_multiply.cpp` --- lines 18--43.
]

#include "../visuals/walk-matrix.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_multiply.cpp", first: 18, last: 43, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `matrix_multiply.cpp` --- lines 44--84.
]

#strong[Trace checkpoint for the supplied main.] For P\[1\]\[0\], keep i = 1 and j = 0 fixed while t takes 0, 1 and 2. The running sums are 28, 73 and 139. P must start this cell at zero; carrying a previous cell’s sum would corrupt the product. In the rejected A-times-A call, the incompatible inner dimensions are detected before any output cell is written.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_multiply.cpp", first: 44, last: 84, lang: "cpp")

#strong[Two shapes in, one shape out.] A 2 × 3 matrix times a 3 × 2 matrix gives a 2 × 2 result: the inner sizes, 3 and 3, must match, and they disappear from the product.

```terminal
A (2 x 3)
  row 0:    1    2    3
  row 1:    4    5    6
B (3 x 2)
  row 0:    7    8
  row 1:    9   10
  row 2:   11   12
P = A x B (2 x 2)
  row 0:   58   64
  row 1:  139  154
== Trace of one output cell ==
P[1][0] = A[1][0]*B[0][0] + A[1][1]*B[1][0] + A[1][2]*B[2][0]
        = 4*7 + 5*9 + 6*11
        = 28 + 45 + 66 = 139
Program P[1][0] = 139  (matches the hand calculation)
== Shape validation ==
A (2 x 3) times A (2 x 3): refused, columns of A (3) != rows of A (2)
What each loop controls:
  i chooses the row of A and the row of P being filled;
  j chooses the column of B and the column of P being filled;
  t walks along row i of A and down column j of B, adding one product per step.
== Verification ==
  [ok]   incompatible shapes are refused before any multiplication
  [ok]   the hand-traced cell P[1][0] matches the program
  [ok]   the whole product matches the expected [[58, 64], [139, 154]]
```

The trace adds by hand the same three products that the innermost loop adds for `P[1][0]`. Multiplying A by itself fails before any arithmetic happens. A has 3 columns but only 2 rows, and `multiply` compares the shapes first and returns `false`, so no half-filled product is ever printed.

#strong[Multiply by the identity.] Add a 3 × 3 identity matrix `I` and compute A × I in a separate test. Predict the result before you run it: A itself, unchanged. Then try I × A. It must be refused, because I has 3 columns and A has only 2 rows.
