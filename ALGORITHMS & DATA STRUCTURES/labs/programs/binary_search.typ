#import "/.shared/typst/utp.typ": *

#strong[Program 2: Binary search with guards and duplicates.]

#strong[File:] `binary_search.cpp`.

#strong[Chapter connection:] Binary search.

searchSorted refuses an unsorted input before binary search is attempted. tracedBinarySearch prints shrinking intervals. firstOccurrence continues left after a match so duplicate keys have a deterministic answer.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-binary_search.typ"


+ #strong[Headers and initial definitions.]

`binary_search.cpp` --- lines 11--20.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 11, last: 20, lang: "text")

+ #strong[Implement tracedBinarySearch, firstOccurrence.]

`binary_search.cpp` --- lines 21--57.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/complete-binary.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 21, last: 57, lang: "text")

+ #strong[Connect the test cases in main.]

`binary_search.cpp` --- lines 58--93.

#strong[Trace checkpoint for the supplied main.] Sort the supplied values to \[10, 13, 14, 29, 37\] before searching. For 29, mid first points to 14 at index 2, so low moves to 3; the next midpoint is index 3. For missing 15, the interval eventually becomes empty. The duplicate test requires firstOccurrence to continue searching left after a match rather than immediately returning it.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 58, last: 93, lang: "text")

+ #strong[Connect the test cases in main.]

`binary_search.cpp` --- lines 94--104. Continue in the same file; do not add another header or opening brace.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 94, last: 104, lang: "text")

#strong[Build, run, and inspect binary\_search.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra binary_search.cpp -o binary_search.exe\n\n.\\binary_search.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("common dataset: 29 10 14 37 13\n  [ok]   searching the unsorted dataset is refused\nsorted:         10 13 14 29 37   (indexes 0..4)\n\n== Search for 29 (present) ==\n    left=0 right=4 mid=2 a[mid]=14  target larger: discard the left half\n    left=3 right=4 mid=3 a[mid]=29  found\n  result: index 3\n  [ok]   29 is found at index 3\n\n== Search for 15 (missing) ==\n    left=0 right=4 mid=2 a[mid]=14  target larger: discard the left half\n    left=3 right=4 mid=3 a[mid]=29  target smaller: discard the right half\n    left > right: the range is empty, not found\n  result: -1", lang: "text")

The complete captured run is in `labs/outputs/binary_search.txt`.

#callout("tryit", title: [Try it yourself])[Test 29 at index 3, missing 15, and an array containing repeated 29s. Ordinary binary search may find any matching index; firstOccurrence must return the earliest.]
