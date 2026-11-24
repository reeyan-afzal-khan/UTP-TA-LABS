#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 3: Merge three sorted arrays safely])

#strong[File:] `merge_three_arrays.cpp`.

#strong[Chapter connection:] Merge sort: compare the current heads.

Extend two input cursors to three. Select the smallest live head and advance only its cursor. Skip an exhausted input before reading it; no integer value is used as a sentinel. The driver checks empty inputs, duplicates, and the largest integer.

#include "../visuals/program-merge_three_arrays.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `merge_three_arrays.cpp` --- lines 11--23.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/merge_three_arrays.cpp", first: 11, last: 23, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement mergeTwo, show, check.]
  ]

  `merge_three_arrays.cpp` --- lines 24--56.
]

#include "../visuals/walk-merge.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/merge_three_arrays.cpp", first: 24, last: 56, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `merge_three_arrays.cpp` --- lines 57--88.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/merge_three_arrays.cpp", first: 57, last: 88, lang: "cpp")

#strong[Three fronts, one output.] The merge keeps a position in each array and copies the smallest of the three front values at every step.

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
  [ok]   every input value appears exactly once (no loss, no duplication)
  [ok]   it equals two successive two-way merges
== One array empty ==
  A: 5 15
  B: (empty)
  C: 10 20 30
  merged: 5 10 15 20 30
...
== Largest integer and exhausted inputs ==
  A: (empty)
  B: 2147483647
  C: (empty)
  merged: 2147483647
...
  A: 2147483647
  B: 2147483647
  C: (empty)
  merged: 2147483647 2147483647
...
  A: (empty)
  B: (empty)
  C: (empty)
  merged: (empty)
  [ok]   the result is sorted
  [ok]   every input value appears exactly once (no loss, no duplication)
  [ok]   it equals two successive two-way merges
```

The first case has two 4s, one from A and one from B, and both survive: the second check counts every value in and out. The last section is about how the merge knows that an array is finished. It compares each position with that array's size and never uses `INT_MAX` as an end marker, so a real 2147483647, the largest `int`, is merged like any other value, and two copies of it both come through.

#strong[Merge unsorted input.] Merge `9 1`, `2` and `3`, and predict the output before you run it: `2 3 9 1`. The merge never reorders an array, it only chooses between fronts, so it cannot repair unsorted input, and the first check must print `[FAIL]`. Then merge `4 4`, `4` and `4 4 4`: the output must hold exactly six 4s.
