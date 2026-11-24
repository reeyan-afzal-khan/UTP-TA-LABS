#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 2: Max-heap and min-heap from start to finish])

#strong[File:] `heap.cpp`.

#strong[Chapter connection:] Array representation of a heap; Insertion into a max-heap.

Insertion sifts up; root removal replaces the root with the last value and sifts down. Check child bounds before reading them. The min-heap uses the opposite comparisons, and both implementations are verified after mutations.

#include "../visuals/program-heap.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `heap.cpp` --- lines 14--30.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 14, last: 30, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement popMaxHeap, pushMinHeap.]
  ]

  `heap.cpp` --- lines 31--61.
]

#include "../visuals/walk-heap.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 31, last: 61, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Implement popMinHeap, isMaxHeap, isMinHeap and helpers.]
  ]

  `heap.cpp` --- lines 62--98.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 62, last: 98, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Connect the test cases in main.]
  ]

  `heap.cpp` --- lines 99--135.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 99, last: 135, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    5. #strong[Connect the test cases in main.]
  ]

  `heap.cpp` --- lines 136--148. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 136, last: 148, lang: "cpp")

#strong[Watch 50 climb.] Inserting 50 into `[30 10]` places it at index 2 first. It is larger than its parent, 30, so the two swap and 50 reaches the root in one step.

```terminal
== Max-heap: insert 30, 10, 50, 20, 40 ==
  insert 30 -> [30]
  insert 10 -> [30 10]
  insert 50 -> [50 10 30]
  insert 20 -> [50 20 30 10]
  insert 40 -> [50 40 30 10 20]
  [ok]   after every insertion no parent is smaller than a child
  [ok]   final max-heap is [50 40 30 10 20]
== Max-heap: delete the root twice ==
  removed 50 -> [40 20 30 10]
  [ok]   heap property restored after deletion
  removed 40 -> [30 20 10]
  [ok]   heap property restored after deletion
== Min-heap from the same keys ==
  insert 30 -> [30]
  insert 10 -> [10 30]
  insert 50 -> [10 30 50]
  insert 20 -> [10 20 50 30]
  insert 40 -> [10 20 50 30 40]
  [ok]   after every insertion no parent is larger than a child
== Min-heap: delete the root until empty ==
  removed in order: 10 20 30 40 50
  [ok]   roots come out in ascending order: 10 20 30 40 50
  [ok]   deleting from an empty heap is refused
The same keys give different arrays: a max-heap puts the largest key at
index 0, a min-heap the smallest. Neither array is sorted; only each parent
is ordered against its own children. Insertion and deletion each move a
value along one root-to-leaf path, so they cost O(height) = O(log n).
```

Insertion sifts a key up; deletion sifts one down. Removing 50 moves the last key, 20, into the root and swaps it with its larger child, 40, giving `[40 20 30 10]`. As the program's closing lines say, neither array is sorted, yet removing the root over and over always yields the keys in order: 10 20 30 40 50 from the min-heap. Heap sort, in Lab 10, is built on exactly that.

#strong[Empty both heaps.] Extend the max-heap section so that it removes the root until the heap is empty. The keys must come out as 50 40 30 20 10, and `isMaxHeap` must hold after every removal. Then remove once more from the empty heap. `popMaxHeap` must refuse, not read index 0.
