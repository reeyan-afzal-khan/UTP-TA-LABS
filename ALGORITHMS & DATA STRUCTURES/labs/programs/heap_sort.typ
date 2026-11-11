#import "/.shared/typst/utp.typ": *

#strong[Program 4: Heap sort with an active prefix.]

#strong[File:] `heap_sort.cpp`.

#strong[Chapter connection:] Heap sort.

Build a max-heap, swap its root into the sorted suffix, and repair only the remaining prefix. The prefix length decreases on each extraction. main checks ordering and the heap invariant and reports comparisons and swaps.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-heap_sort.typ"


+ #strong[Headers and initial definitions.]

`heap_sort.cpp` --- lines 14--29.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/heap_sort.cpp", first: 14, last: 29, lang: "text")

+ #strong[Implement isMaxHeap, show, heapSort.]

`heap_sort.cpp` --- lines 30--58.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/complete-heapsort.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/heap_sort.cpp", first: 30, last: 58, lang: "text")

+ #strong[Connect the test cases in main.]

`heap_sort.cpp` --- lines 59--97.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/heap_sort.cpp", first: 59, last: 97, lang: "text")

#strong[Build, run, and inspect heap\_sort.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra heap_sort.cpp -o heap_sort.exe\n\n.\\heap_sort.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Heap sort on the common dataset (heap | sorted tail) ==\n  start: 29 10 14 37 13 \n  after building the max-heap: 37 29 14 10 13 \n  extract 37 -> 29 13 14 10 | 37 \n  extract 29 -> 14 13 10 | 29 37 \n  extract 14 -> 13 10 | 14 29 37 \n  extract 13 -> 10 | 13 14 29 37 \n  result: 10 13 14 29 37 \n  comparisons: 12, swaps: 9\n  [ok]   the result is in ascending order\n  [ok]   the heap property held in the unsorted region after every extraction\n\n== More inputs ==\n  [ok]   duplicates: 5 3 5 1 5 9 3\n  [ok]   already sorted: 1 2 3 4 5 6", lang: "text")

The complete captured run is in `labs/outputs/heap_sort.txt`.

#callout("tryit", title: [Try it yourself])[Run the same fresh input through heap sort and descending quick sort. Reverse one result before comparing equality. Exclude printing and setup if you measure execution time.]
