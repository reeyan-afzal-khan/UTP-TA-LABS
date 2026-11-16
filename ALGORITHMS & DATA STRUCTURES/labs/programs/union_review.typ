#import "/.shared/typst/utp.typ": *

#strong[Program 2: Structure and union storage.]

#strong[File:] `union_review.cpp`.

#strong[Chapter connection:] Primitive vs non-primitive structures; C++ practical: structures.

A structure retains all fields; a union shares storage. Write and read the same active union member. The second half of main scans a temperature array once for the maximum and average. Byte sizes depend on the compiler and platform.

#include "../visuals/program-union_review.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`union_review.cpp` --- lines 13--26.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/union_review.cpp", first: 13, last: 26, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Connect the test cases in main.]
]

`union_review.cpp` --- lines 27--55.

#include "../visuals/complete-union.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/union_review.cpp", first: 27, last: 55, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect union\_review.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra union_review.cpp -o union_review.exe

.\union_review.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

```terminal

== Structure versus union ==
sizeof(MeasurementStruct) = 24 bytes
sizeof(MeasurementUnion)  = 8 bytes (the size of its largest member, double = 8)

After u.count = 42:     u.count   = 42
After u.reading = 3.75: u.reading = 3.75  (count was overwritten; read only the member written last)

== A 1D array: daily temperatures ==
day 1: 31
day 2: 33
day 3: 30
day 4: 29
day 5: 34
day 6: 32
day 7: 31

```

The complete captured run is in `labs/outputs/union_review.txt`.

Reported byte sizes depend on the platform; compare the storage relationships rather than requiring these exact sizes.

#exercises[
  Change the last temperature to 28 and recompute the maximum and average by hand. For the union, write grade last and read grade; do not read the older inactive members.
]
