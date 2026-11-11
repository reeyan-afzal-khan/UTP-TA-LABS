#import "/.shared/typst/utp.typ": *

#strong[Program 2: Matrix operations in one program.]

#strong[File:] `matrix_operations.cpp`.

#strong[Chapter connection:] Arrays and Two-Dimensional Arrays: row/column indexing.

Use the same 3 by 3 input for row sums, column sums, transpose, maximum, diagonal sum, and symmetry. Each function states its traversal through its loop bounds. main also supplies symmetric and nonsymmetric examples.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-matrix_operations.typ"


+ #strong[Headers and initial definitions.]

`matrix_operations.cpp` --- lines 11--23.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_operations.cpp", first: 11, last: 23, lang: "text")

+ #strong[Implement rowSums, columnSums, transpose and helpers.]

`matrix_operations.cpp` --- lines 24--59.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/complete-transpose.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_operations.cpp", first: 24, last: 59, lang: "text")

+ #strong[Connect the test cases in main.]

`matrix_operations.cpp` --- lines 60--99.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_operations.cpp", first: 60, last: 99, lang: "text")

#strong[Build, run, and inspect matrix\_operations.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra matrix_operations.cpp -o matrix_operations.exe\n\n.\\matrix_operations.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("M\n    1    2    3\n    4    5    6\n    7    8    9\n\nRow sums:\n  row 0 sum = 6\n  row 1 sum = 15\n  row 2 sum = 24\nColumn sums:\n  column 0 sum = 12\n  column 1 sum = 15\n  column 2 sum = 18\n\nTranspose of M", lang: "text")

The complete captured run is in `labs/outputs/matrix_operations.txt`.

#callout("tryit", title: [Try it yourself])[Replace M with the identity matrix. Predict row/column sums of 1, diagonal sum of 3, maximum 1, and a true symmetry result.]
