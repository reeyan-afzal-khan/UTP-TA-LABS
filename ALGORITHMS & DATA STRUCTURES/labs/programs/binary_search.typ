#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 2: Binary search with guards and duplicates])

#strong[File:] `binary_search.cpp`.

#strong[Chapter connection:] Binary search.

searchSorted refuses an unsorted input before binary search is attempted. tracedBinarySearch prints shrinking intervals. firstOccurrence continues left after a match so duplicate keys have a deterministic answer.

#include "../visuals/program-binary_search.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `binary_search.cpp` --- lines 11--20.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 11, last: 20, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement tracedBinarySearch, firstOccurrence.]
  ]

  `binary_search.cpp` --- lines 21--57.
]

#include "../visuals/complete-binary.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 21, last: 57, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `binary_search.cpp` --- lines 58--93.
]

#strong[Trace checkpoint for the supplied main.] Sort the supplied values to \[10, 13, 14, 29, 37\] before searching. For 29, mid first points to 14 at index 2, so low moves to 3; the next midpoint is index 3. For missing 15, the interval eventually becomes empty. The duplicate test requires firstOccurrence to continue searching left after a match rather than immediately returning it.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 58, last: 93, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Connect the test cases in main.]
  ]

  `binary_search.cpp` --- lines 94--104. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab10/binary_search.cpp", first: 94, last: 104, lang: "cpp")

#strong[Halving, one line per probe.] Each indented line is one pass of the loop: the current range, its middle, and the half that is thrown away.

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
  [ok]   a missing target returns -1
== Duplicates ==
data: 3 5 5 5 9
  binarySearch(5) -> index 2,  firstOccurrence(5) -> index 1
  [ok]   binary search finds an occurrence of a duplicated value
  [ok]   the first-occurrence variant returns index 1
  [ok]   a missing value between duplicates is still not found
```

The program refuses the unsorted dataset first, because binary search on unsorted data can return a wrong answer without any error. On the sorted copy, 29 is found in two probes and 15 is ruled out in two, after which `left`, 3, has passed `right`, 2, and the range is empty. With `3 5 5 5 9`, the plain search stops at the first 5 it probes, index 2; `firstOccurrence` keeps searching to the left after a match and returns index 1.

#strong[Search at the edges.] Search the sorted dataset for 10 and 37, its first and last values, and for 5 and 40, which lie outside it. Predict the probes before you run it: 10 is found in two and 37 in three; 5 is ruled out in two and 40 in three. Then search `29 29 29` for 29 with both functions. The plain search returns index 1, the middle, and `firstOccurrence` must return 0.
