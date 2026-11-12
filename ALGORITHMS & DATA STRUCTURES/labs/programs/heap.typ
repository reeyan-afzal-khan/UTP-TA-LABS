#import "/.shared/typst/utp.typ": *

#strong[Program 2: Max-heap and min-heap from start to finish.]

#strong[File:] `heap.cpp`.

#strong[Chapter connection:] Array representation of a heap; Insertion into a max-heap.

Insertion sifts up; root removal replaces the root with the last value and sifts down. Check child bounds before reading them. The min-heap uses the opposite comparisons, and both implementations are verified after mutations.

#include "../visuals/program-heap.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`heap.cpp` --- lines 14--30.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 14, last: 30, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement popMaxHeap, pushMinHeap.]
]

`heap.cpp` --- lines 31--61.

#include "../visuals/walk-heap.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 31, last: 61, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Implement popMinHeap, isMaxHeap, isMinHeap and helpers.]
]

`heap.cpp` --- lines 62--98.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 62, last: 98, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Connect the test cases in main.]
]

`heap.cpp` --- lines 99--135.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 99, last: 135, lang: "cpp")

#colbreak()

#utpsteps[
  5. #strong[Connect the test cases in main.]
]

`heap.cpp` --- lines 136--148. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 136, last: 148, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect heap.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra heap.cpp -o heap.exe

.\heap.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/heap.txt`.

#tryit[
  Drain both heaps completely. Max-heap removals must descend; min-heap removals must ascend. After each removal, check every parent-child pair, then test one more pop on empty.
]
