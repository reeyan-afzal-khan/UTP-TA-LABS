#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 2: Matrix operations in one program])

#strong[File:] `matrix_operations.cpp`.

#strong[Chapter connection:] Arrays and Two-Dimensional Arrays: row/column indexing.

Use the same 3 by 3 input for row sums, column sums, transpose, maximum, diagonal sum, and symmetry. Each function states its traversal through its loop bounds. main also supplies symmetric and nonsymmetric examples.

#include "../visuals/program-matrix_operations.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `matrix_operations.cpp` --- lines 11--23.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_operations.cpp", first: 11, last: 23, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement rowSums, columnSums, transpose and helpers.]
  ]

  `matrix_operations.cpp` --- lines 24--59.
]

#include "../visuals/complete-transpose.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_operations.cpp", first: 24, last: 59, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `matrix_operations.cpp` --- lines 60--99.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_operations.cpp", first: 60, last: 99, lang: "cpp")

#strong[Rows, columns and the mirror line.] Each result below is a short loop over `M`. What changes from one to the next is which index moves and which one stays still.

```terminal
M
    1    2    3
    4    5    6
    7    8    9
Row sums:
  row 0 sum = 6
  row 1 sum = 15
  row 2 sum = 24
Column sums:
  column 0 sum = 12
  column 1 sum = 15
  column 2 sum = 18
Transpose of M
    1    4    7
    2    5    8
    3    6    9
Largest element of M: 9
Diagonal sum of M:    15  (1 + 5 + 9)
S
    2    7    1
    7    4    5
    1    5    9
Is M symmetric? no   (M[0][1] = 2 but M[1][0] = 4)
Is S symmetric? yes  (S[r][c] == S[c][r] everywhere)
```

The column sums of M are the row sums of its transpose, because transposing swaps the roles of `r` and `c`. The diagonal sum is the only result that needs a single index, `M[i][i]`. M fails the symmetry test at its first mismatch, `M[0][1]` = 2 against `M[1][0]` = 4; S passes because every cell equals its mirror image across the diagonal.

#strong[Feed it the identity.] Replace M with the 3 × 3 identity matrix and predict every line before you run it. Each row and each column sums to 1, the largest element is 1, the diagonal sum is 3, the transpose is the matrix itself, and the symmetry test answers yes.
