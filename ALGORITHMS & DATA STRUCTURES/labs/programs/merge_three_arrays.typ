#import "/.shared/typst/utp.typ": *

#strong[Program 3: Merge three sorted arrays safely.]

#strong[File:] `merge_three_arrays.cpp`.

#strong[Chapter connection:] Merge sort: compare the current heads.

Extend two input cursors to three. Select the smallest live head and advance only its cursor. Skip an exhausted input before reading it; no integer value is used as a sentinel. The driver checks empty inputs, duplicates, and the largest integer.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-merge_three_arrays.typ"


+ #strong[Headers and initial definitions.]

`merge_three_arrays.cpp` --- lines 11--23.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/merge_three_arrays.cpp", first: 11, last: 23, lang: "text")

+ #strong[Implement mergeTwo, show, check.]

`merge_three_arrays.cpp` --- lines 24--56.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-merge.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/merge_three_arrays.cpp", first: 24, last: 56, lang: "text")

+ #strong[Connect the test cases in main.]

`merge_three_arrays.cpp` --- lines 57--88.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/merge_three_arrays.cpp", first: 57, last: 88, lang: "text")

#strong[Build, run, and inspect merge\_three\_arrays.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra merge_three_arrays.cpp -o merge_three_arrays.exe\n\n.\\merge_three_arrays.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Three sorted arrays ==\n  A: 1 4 9\n  B: 2 4 7 10\n  C: 3 5\n  merged: 1 2 3 4 4 5 7 9 10\n  [ok]   the result is sorted\n  [ok]   every input value appears exactly once (no loss, no duplication)\n  [ok]   it equals two successive two-way merges\n\n== With duplicates across arrays ==\n  A: 2 2 8\n  B: 2 6\n  C: 1 2 9\n  merged: 1 2 2 2 2 6 8 9\n  [ok]   the result is sorted", lang: "text")

The complete captured run is in `labs/outputs/merge_three_arrays.txt`.

#callout("tryit", title: [Try it yourself])[Test three empty arrays, one exhausted input beside INT\_MAX, and equal values in all three inputs. Confirm sorted order and exactly the original number of copies of every value.]
