#import "/.shared/typst/utp.typ": *

#strong[Program 3: Merge three sorted arrays safely.]

#strong[File:] `merge_three_arrays.cpp`.

#strong[Chapter connection:] Merge sort: compare the current heads.

Extend two input cursors to three. Select the smallest live head and advance only its cursor. Skip an exhausted input before reading it; no integer value is used as a sentinel. The driver checks empty inputs, duplicates, and the largest integer.

#include "../visuals/program-merge_three_arrays.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`merge_three_arrays.cpp` --- lines 11--23.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/merge_three_arrays.cpp", first: 11, last: 23, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement mergeTwo, show, check.]
]

`merge_three_arrays.cpp` --- lines 24--56.

#include "../visuals/walk-merge.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/merge_three_arrays.cpp", first: 24, last: 56, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`merge_three_arrays.cpp` --- lines 57--88.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/merge_three_arrays.cpp", first: 57, last: 88, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect merge\_three\_arrays.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra merge_three_arrays.cpp -o merge_three_arrays.exe

.\merge_three_arrays.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

```terminal

== Three sorted arrays ==
  A: 1 4 9
  B: 2 4 7 10
  C: 3 5
  merged: 1 2 3 4 4 5 7 9 10
  [ok]   the result is sorted
  [ok]   every input value appears exactly once (no loss, no duplication)
  [ok]   it equals two successive two-way merges

== With duplicates across arrays ==
  A: 2 2 8
  B: 2 6
  C: 1 2 9
  merged: 1 2 2 2 2 6 8 9
  [ok]   the result is sorted

```

The complete captured run is in `labs/outputs/merge_three_arrays.txt`.

#tryit[
  Test three empty arrays, one exhausted input beside INT\_MAX, and equal values in all three inputs. Confirm sorted order and exactly the original number of copies of every value.
]
