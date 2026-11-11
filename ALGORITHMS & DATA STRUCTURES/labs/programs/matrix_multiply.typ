#import "/.shared/typst/utp.typ": *

#strong[Program 1: A complete matrix multiplication program.]

#strong[File:] `matrix_multiply.cpp`.

#strong[Chapter connection:] Arrays and Two-Dimensional Arrays: nested loops and matrix multiplication.

The output has one cell per row of A and column of B. multiply rejects incompatible shapes before indexing. Its inner loop accumulates matching products; main prints all cells and separately expands cell P\[1\]\[0\].


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-matrix_multiply.typ"


+ #strong[Headers and initial definitions.]

`matrix_multiply.cpp` --- lines 9--17.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_multiply.cpp", first: 9, last: 17, lang: "text")

+ #strong[Implement printMatrix, multiply.]

`matrix_multiply.cpp` --- lines 18--43.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-matrix.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_multiply.cpp", first: 18, last: 43, lang: "text")

+ #strong[Connect the test cases in main.]

`matrix_multiply.cpp` --- lines 44--84.

#strong[Trace checkpoint for the supplied main.] For P\[1\]\[0\], keep i = 1 and j = 0 fixed while t takes 0, 1 and 2. The running sums are 28, 73 and 139. P must start this cell at zero; carrying a previous cell's sum would corrupt the product. In the rejected A-times-A call, the incompatible inner dimensions are detected before any output cell is written.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab02/matrix_multiply.cpp", first: 44, last: 84, lang: "text")

#strong[Build, run, and inspect matrix\_multiply.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra matrix_multiply.cpp -o matrix_multiply.exe\n\n.\\matrix_multiply.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("A (2 x 3)\n  row 0:    1    2    3\n  row 1:    4    5    6\nB (3 x 2)\n  row 0:    7    8\n  row 1:    9   10\n  row 2:   11   12\nP = A x B (2 x 2)\n  row 0:   58   64\n  row 1:  139  154\n\n== Trace of one output cell ==\nP[1][0] = A[1][0]*B[0][0] + A[1][1]*B[1][0] + A[1][2]*B[2][0]\n        = 4*7 + 5*9 + 6*11\n        = 28 + 45 + 66 = 139", lang: "text")

The complete captured run is in `labs/outputs/matrix_multiply.txt`.

#callout("tryit", title: [Try it yourself])[Replace B with a compatible identity matrix in a separate test and predict the unchanged result. Pass incompatible dimensions to multiply and verify that it returns false before writing the output.]
