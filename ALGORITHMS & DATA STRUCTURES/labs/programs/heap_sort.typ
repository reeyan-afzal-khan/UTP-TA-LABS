#import "/.shared/typst/utp.typ": *

#strong[Program 4: Heap sort with an active prefix.]

#strong[File:] `heap_sort.cpp`.

#strong[Chapter connection:] Heap sort.

Build a max-heap, swap its root into the sorted suffix, and repair only the remaining prefix. The prefix length decreases on each extraction. main checks ordering and the heap invariant and reports comparisons and swaps.

#include "../visuals/program-heap_sort.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`heap_sort.cpp` --- lines 14--29.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/heap_sort.cpp", first: 14, last: 29, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement isMaxHeap, show, heapSort.]
]

`heap_sort.cpp` --- lines 30--58.

#include "../visuals/complete-heapsort.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/heap_sort.cpp", first: 30, last: 58, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`heap_sort.cpp` --- lines 59--97.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/heap_sort.cpp", first: 59, last: 97, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect heap\_sort.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra heap_sort.cpp -o heap_sort.exe

.\heap_sort.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/heap_sort.txt`.

#exercises[
  Run the same fresh input through heap sort and descending quick sort. Reverse one result before comparing equality. Exclude printing and setup if you measure execution time.
]
