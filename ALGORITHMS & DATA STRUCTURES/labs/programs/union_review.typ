#import "/.shared/typst/utp.typ": *

#strong[Program 2: Structure and union storage.]

#strong[File:] `union_review.cpp`.

#strong[Chapter connection:] Primitive vs non-primitive structures; C++ practical: structures.

A structure retains all fields; a union shares storage. Write and read the same active union member. The second half of main scans a temperature array once for the maximum and average. Byte sizes depend on the compiler and platform.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-union_review.typ"


+ #strong[Headers and initial definitions.]

`union_review.cpp` --- lines 13--26.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/union_review.cpp", first: 13, last: 26, lang: "text")

+ #strong[Connect the test cases in main.]

`union_review.cpp` --- lines 27--55.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/complete-union.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/union_review.cpp", first: 27, last: 55, lang: "text")

#strong[Build, run, and inspect union\_review.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra union_review.cpp -o union_review.exe\n\n.\\union_review.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Structure versus union ==\nsizeof(MeasurementStruct) = 24 bytes\nsizeof(MeasurementUnion)  = 8 bytes (the size of its largest member, double = 8)\n\nAfter u.count = 42:     u.count   = 42\nAfter u.reading = 3.75: u.reading = 3.75  (count was overwritten; read only the member written last)\n\n== A 1D array: daily temperatures ==\nday 1: 31\nday 2: 33\nday 3: 30\nday 4: 29\nday 5: 34\nday 6: 32\nday 7: 31", lang: "text")

The complete captured run is in `labs/outputs/union_review.txt`.

Reported byte sizes depend on the platform; compare the storage relationships rather than requiring these exact sizes.

#callout("tryit", title: [Try it yourself])[Change the last temperature to 28 and recompute the maximum and average by hand. For the union, write grade last and read grade; do not read the older inactive members.]
