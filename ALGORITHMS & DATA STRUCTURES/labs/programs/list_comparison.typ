#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 2: Compare three complete list representations])

#strong[File:] `list_comparison.cpp`.

#strong[Chapter connection:] Singly and Doubly Linked Lists; Circular Linked Lists.

Build all three structures from the same four values. The loops differ in their stopping conditions, not their logical contents. The final part frees each representation using its own termination rule. Node byte sizes are platform-dependent.

#include "../visuals/program-list_comparison.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `list_comparison.cpp` --- lines 10--20.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/list_comparison.cpp", first: 10, last: 20, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Connect the test cases in main.]
  ]

  `list_comparison.cpp` --- lines 21--48. Continue in the same file; do not add another header or opening brace.
]

#include "../visuals/complete-list-stop.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/list_comparison.cpp", first: 21, last: 48, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `list_comparison.cpp` --- lines 49--79. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/list_comparison.cpp", first: 49, last: 79, lang: "cpp")

#strong[Same four values, three structures.] The traversal lines show where each loop stops; the table underneath records why it stops there.

```terminal
Input sequence: 10 20 30 40
Singly, head forward to nullptr:   10 20 30 40
Doubly, head forward to nullptr:   10 20 30 40
Doubly, tail backward to nullptr:  40 30 20 10
Circular, head round to head:      10 20 30 40
Circular, two laps, no stop test:  10 20 30 40 10 20 30 40
                          Singly            Doubly            Circular
pointer fields per node   1 (next)          2 (prev, next)    1 (next)
bytes per node here       16                24                16
last node's next          nullptr           nullptr           the head
traversal stops when      p == nullptr      p == nullptr      p == head again
walk backwards?           no                yes, via prev     no
reach head from the end   no                via prev          one step: last->next
```

The two-lap line drops the stop test on purpose and simply counts eight steps: a circular list has no end, so a loop that never compares `p` with the head would print 10 20 30 40 forever. The byte counts come from `sizeof` on this computer. An `int` and one pointer take 16 bytes rather than 12, because the pointer must start on an 8-byte boundary, and a second pointer adds 8 more. Your numbers may differ, but the doubly linked node is always one pointer larger.

#strong[Run the loops on nothing.] Change the input to an empty sequence and predict which line fails before you run it. The singly and doubly linked loops test `p != nullptr` before they touch a node, so they print nothing. The circular part starts from `last->next` while `last` is still `nullptr`, so the program crashes there, and the clean-up at the end makes the same mistake. Guard both places with `if (last != nullptr)` and run it again. Then try the single value 10: the round trip prints 10 once, and the two-lap line prints `10 10`, because that node's `next` is itself.
