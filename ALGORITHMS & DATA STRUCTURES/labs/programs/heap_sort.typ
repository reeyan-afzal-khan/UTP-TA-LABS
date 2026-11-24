#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 4: Heap sort with an active prefix])

#strong[File:] `heap_sort.cpp`.

#strong[Chapter connection:] Heap sort.

Build a max-heap, swap its root into the sorted suffix, and repair only the remaining prefix. The prefix length decreases on each extraction. main checks ordering and the heap invariant and reports comparisons and swaps.

#include "../visuals/program-heap_sort.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `heap_sort.cpp` --- lines 14--29.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/heap_sort.cpp", first: 14, last: 29, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement isMaxHeap, show, heapSort.]
  ]

  `heap_sort.cpp` --- lines 30--58.
]

#include "../visuals/complete-heapsort.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/heap_sort.cpp", first: 30, last: 58, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `heap_sort.cpp` --- lines 59--97.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/heap_sort.cpp", first: 59, last: 97, lang: "cpp")

#strong[The heap shrinks, the sorted tail grows.] Everything left of the bar is still a max-heap; everything right of it is already in its final place.

```terminal
== Heap sort on the common dataset (heap | sorted tail) ==
  start: 29 10 14 37 13
  after building the max-heap: 37 29 14 10 13
  extract 37 -> 29 13 14 10 | 37
  extract 29 -> 14 13 10 | 29 37
  extract 14 -> 13 10 | 14 29 37
  extract 13 -> 10 | 13 14 29 37
  result: 10 13 14 29 37
  comparisons: 12, swaps: 9
  [ok]   the result is in ascending order
  [ok]   the heap property held in the unsorted region after every extraction
== More inputs ==
  [ok]   duplicates: 5 3 5 1 5 9 3
  [ok]   already sorted: 1 2 3 4 5 6
  [ok]   reverse sorted: 6 5 4 3 2 1
  [ok]   one element and empty input
```

Building the heap brings 37 to the front. Each extraction swaps the root with the last value in the heap and sifts the new root down, so the largest remaining value joins the tail; heap and tail share the one array, and nothing is copied. On these five values heap sort used 12 comparisons to quick sort's 6. The real difference lies in the guarantee: heap sort is O(n log n) on every input, while quick sort is faster on average but can degrade to O(n²).

#strong[Trace it by hand first.] Sort `9 4 7 1 8 2` with heap sort on paper, writing the array the way the program prints it. After the heap is built it must read `9 8 7 1 4 2`, and after the first extraction `8 4 7 1 2 | 9`. Finish the trace, then add the input to `main` and compare line by line.
