#import "/.shared/typst/utp.typ": *

#strong[Program 2: Max-heap and min-heap from start to finish.]

#strong[File:] `heap.cpp`.

#strong[Chapter connection:] Array representation of a heap; Insertion into a max-heap.

Insertion sifts up; root removal replaces the root with the last value and sifts down. Check child bounds before reading them. The min-heap uses the opposite comparisons, and both implementations are verified after mutations.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-heap.typ"


+ #strong[Headers and initial definitions.]

`heap.cpp` --- lines 14--30.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 14, last: 30, lang: "text")

+ #strong[Implement popMaxHeap, pushMinHeap.]

`heap.cpp` --- lines 31--61.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-heap.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 31, last: 61, lang: "text")

+ #strong[Implement popMinHeap, isMaxHeap, isMinHeap and helpers.]

`heap.cpp` --- lines 62--98.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 62, last: 98, lang: "text")

+ #strong[Connect the test cases in main.]

`heap.cpp` --- lines 99--135.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 99, last: 135, lang: "text")

+ #strong[Connect the test cases in main.]

`heap.cpp` --- lines 136--148. Continue in the same file; do not add another header or opening brace.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab08/heap.cpp", first: 136, last: 148, lang: "text")

#strong[Build, run, and inspect heap.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra heap.cpp -o heap.exe\n\n.\\heap.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Max-heap: insert 30, 10, 50, 20, 40 ==\n  insert 30 -> [30]\n  insert 10 -> [30 10]\n  insert 50 -> [50 10 30]\n  insert 20 -> [50 20 30 10]\n  insert 40 -> [50 40 30 10 20]\n  [ok]   after every insertion no parent is smaller than a child\n  [ok]   final max-heap is [50 40 30 10 20]\n\n== Max-heap: delete the root twice ==\n  removed 50 -> [40 20 30 10]\n  [ok]   heap property restored after deletion\n  removed 40 -> [30 20 10]\n  [ok]   heap property restored after deletion", lang: "text")

The complete captured run is in `labs/outputs/heap.txt`.

#callout("tryit", title: [Try it yourself])[Drain both heaps completely. Max-heap removals must descend; min-heap removals must ascend. After each removal, check every parent-child pair, then test one more pop on empty.]
