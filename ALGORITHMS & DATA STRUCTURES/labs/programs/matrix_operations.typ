#import "/.shared/typst/utp.typ": *

#strong[Program 2: Matrix operations in one program.]

#strong[File:] `matrix_operations.cpp`.

#strong[Chapter connection:] Arrays and Two-Dimensional Arrays: row/column indexing.

Use the same 3 by 3 input for row sums, column sums, transpose, maximum, diagonal sum, and symmetry. Each function states its traversal through its loop bounds. main also supplies symmetric and nonsymmetric examples.

#include "../visuals/program-matrix_operations.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`matrix_operations.cpp` --- lines 11--23.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_operations.cpp", first: 11, last: 23, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement rowSums, columnSums, transpose and helpers.]
]

`matrix_operations.cpp` --- lines 24--59.

#include "../visuals/complete-transpose.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_operations.cpp", first: 24, last: 59, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`matrix_operations.cpp` --- lines 60--99.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_operations.cpp", first: 60, last: 99, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect matrix\_operations.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra matrix_operations.cpp -o matrix_operations.exe

.\matrix_operations.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/matrix_operations.txt`.

#exercises[
  Replace M with the identity matrix. Predict row/column sums of 1, diagonal sum of 3, maximum 1, and a true symmetry result.
]
