#import "/.shared/typst/utp.typ": *

#strong[Program 1: Descending quick sort with trace and counts.]

#strong[File:] `quick_sort_descending.cpp`.

#strong[Chapter connection:] Quick sort.

Move the middle-index pivot to the end, partition larger values to its left, then recurse on the two remaining ranges. The trace highlights active indexes. Counted swaps and key comparisons are reported consistently across the test cases.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-quick_sort_descending.typ"


+ #strong[Headers and initial definitions.]

`quick_sort_descending.cpp` --- lines 17--26.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/quick_sort_descending.cpp", first: 17, last: 26, lang: "text")

+ #strong[Implement show, countedSwap, partitionDescending.]

`quick_sort_descending.cpp` --- lines 27--61.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-quick.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/quick_sort_descending.cpp", first: 27, last: 61, lang: "text")

+ #strong[Connect the test cases in main.]

`quick_sort_descending.cpp` --- lines 62--104.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/quick_sort_descending.cpp", first: 62, last: 104, lang: "text")

#strong[Build, run, and inspect quick\_sort\_descending.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra quick_sort_descending.cpp -o quick_sort_descending.exe\n\n.\\quick_sort_descending.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Trace on the common dataset ==\n  start: [29 10 14 37 13]   ([ ] marks the range being partitioned)\n  pivot 14 (middle of 0..4) -> [29 37 14 10 13]   pivot now at index 2\n  pivot 29 (middle of 0..1) -> [37 29] 14 10 13   pivot now at index 1\n  pivot 10 (middle of 3..4) -> 37 29 14 [13 10]   pivot now at index 4\n  result: [37 29 14 13 10]\n  comparisons: 6, swaps: 5\n  [ok]   the result is in descending order\n\n== More inputs ==\n  [ok]   duplicates: 5 3 5 1 5 9 3\n  [ok]   already ascending: 1 2 3 4 5 6\n  [ok]   already descending: 6 5 4 3 2 1\n  [ok]   all equal: 7 7 7 7\n  [ok]   one element and empty input", lang: "text")

The complete captured run is in `labs/outputs/quick_sort_descending.txt`.

#callout("tryit", title: [Try it yourself])[Use empty, one-value, all-equal, and reversed arrays. Predict which ranges end immediately, and verify descending order without losing duplicate values.]
