#import "/.shared/typst/utp.typ": *

#strong[Program 2: Binary search with guards and duplicates.]

#strong[File:] `binary_search.cpp`.

#strong[Chapter connection:] Binary search.

searchSorted refuses an unsorted input before binary search is attempted. tracedBinarySearch prints shrinking intervals. firstOccurrence continues left after a match so duplicate keys have a deterministic answer.

#include "../visuals/program-binary_search.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`binary_search.cpp` --- lines 11--20.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 11, last: 20, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement tracedBinarySearch, firstOccurrence.]
]

`binary_search.cpp` --- lines 21--57.

#include "../visuals/complete-binary.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 21, last: 57, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`binary_search.cpp` --- lines 58--93.

#strong[Trace checkpoint for the supplied main.] Sort the supplied values to \[10, 13, 14, 29, 37\] before searching. For 29, mid first points to 14 at index 2, so low moves to 3; the next midpoint is index 3. For missing 15, the interval eventually becomes empty. The duplicate test requires firstOccurrence to continue searching left after a match rather than immediately returning it.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 58, last: 93, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Connect the test cases in main.]
]

`binary_search.cpp` --- lines 94--104. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 94, last: 104, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect binary\_search.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra binary_search.cpp -o binary_search.exe

.\binary_search.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

```terminal

common dataset: 29 10 14 37 13
  [ok]   searching the unsorted dataset is refused
sorted:         10 13 14 29 37   (indexes 0..4)

== Search for 29 (present) ==
    left=0 right=4 mid=2 a[mid]=14  target larger: discard the left half
    left=3 right=4 mid=3 a[mid]=29  found
  result: index 3
  [ok]   29 is found at index 3

== Search for 15 (missing) ==
    left=0 right=4 mid=2 a[mid]=14  target larger: discard the left half
    left=3 right=4 mid=3 a[mid]=29  target smaller: discard the right half
    left > right: the range is empty, not found
  result: -1

```

The complete captured run is in `labs/outputs/binary_search.txt`.

#tryit[
  Test 29 at index 3, missing 15, and an array containing repeated 29s. Ordinary binary search may find any matching index; firstOccurrence must return the earliest.
]
