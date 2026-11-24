#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 2: Structure and union storage])

#strong[File:] `union_review.cpp`.

#strong[Chapter connection:] Primitive vs non-primitive structures; C++ practical: structures.

A structure retains all fields; a union shares storage. Write and read the same active union member. The second half of main scans a temperature array once for the maximum and average. Byte sizes depend on the compiler and platform.

#include "../visuals/program-union_review.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `union_review.cpp` --- lines 13--26.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/union_review.cpp", first: 13, last: 26, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Connect the test cases in main.]
  ]

  `union_review.cpp` --- lines 27--55.
]

#include "../visuals/complete-union.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/union_review.cpp", first: 27, last: 55, lang: "cpp")

#strong[Two sizes, one shared slot.] The first two lines of the run carry the lesson: the structure keeps all three members side by side, while the union keeps one at a time.

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
highest: 34, average: 31.4286
```

The members add up to 4~+~8~+~1~=~13 bytes, yet the structure takes 24. The compiler pads it so that the `double` starts on an 8-byte boundary and the whole structure is a multiple of 8; padding depends on the platform, so your figure may differ. The union needs room only for its largest member. Writing `u.reading` reuses the bytes that held `count`, which is why the program reads back only the member it wrote last. The final line divides the seven temperatures, 220 in total, by 7.

#strong[Change one temperature.] Set the last temperature to 28 and work out the new highest and average by hand before you run it: still 34, and 217~/~7~=~31. Then assign `u.grade = 'A'` and print `u.grade`. After that assignment `grade` is the only member worth reading; printing `count` or `reading` shows whatever bytes happen to be left over, and C++ does not define the result.
