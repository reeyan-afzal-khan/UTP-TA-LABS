#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: Descending quick sort with trace and counts])

#strong[File:] `quick_sort_descending.cpp`.

#strong[Chapter connection:] Quick sort.

Move the middle-index pivot to the end, partition larger values to its left, then recurse on the two remaining ranges. The trace highlights active indexes. Counted swaps and key comparisons are reported consistently across the test cases.

#include "../visuals/program-quick_sort_descending.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `quick_sort_descending.cpp` --- lines 17--26.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/quick_sort_descending.cpp", first: 17, last: 26, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement show, countedSwap, partitionDescending.]
  ]

  `quick_sort_descending.cpp` --- lines 27--61.
]

#include "../visuals/walk-quick.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/quick_sort_descending.cpp", first: 27, last: 61, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `quick_sort_descending.cpp` --- lines 62--104.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/quick_sort_descending.cpp", first: 62, last: 104, lang: "cpp")

#strong[Three partitions sort five numbers.] Each trace line is one call of `partitionDescending`: the bracketed range, the pivot taken from its middle, and where the pivot ends up.

```terminal
== Trace on the common dataset ==
  start: [29 10 14 37 13]   ([ ] marks the range being partitioned)
  pivot 14 (middle of 0..4) -> [29 37 14 10 13]   pivot now at index 2
  pivot 29 (middle of 0..1) -> [37 29] 14 10 13   pivot now at index 1
  pivot 10 (middle of 3..4) -> 37 29 14 [13 10]   pivot now at index 4
  result: [37 29 14 13 10]
  comparisons: 6, swaps: 5
  [ok]   the result is in descending order
== More inputs ==
  [ok]   duplicates: 5 3 5 1 5 9 3
  [ok]   already ascending: 1 2 3 4 5 6
  [ok]   already descending: 6 5 4 3 2 1
  [ok]   all equal: 7 7 7 7
  [ok]   one element and empty input
The middle-index pivot keeps already-sorted input from producing the
worst case that a last-element pivot gives: each partition still splits
the range near its centre.
```

Sorting in descending order changes a single comparison: values larger than the pivot go to its left. After the first partition, 14 sits at index 2, its final place, and each side is sorted on its own. A range of one value needs no work, so three partitions finish the job, with 6 comparisons and 5 swaps for 5 values.

#strong[Trace a case with ties.] Sort `8 3 8 1` in descending order by hand before you run it. The middle of `0..3` is index 1, so the first pivot is 3: both 8s must end on its left and 1 on its right. Then add `check("ties: 8 3 8 1", sortsCorrectly({8, 3, 8, 1}));` beside the other inputs in `main`. It must print `[ok]`, which means the result was `8 8 3 1` with both 8s kept.
