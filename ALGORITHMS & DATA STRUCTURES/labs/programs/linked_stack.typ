#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 2: Linked stack with cleanup])

#strong[File:] `linked_stack.cpp`.

#strong[Chapter connection:] Linked-list stack.

The top pointer replaces the array index. push links a new node at the front; pop advances top before deleting the old node. The driver grows beyond the array example capacity, then removes all nodes.

#include "../visuals/program-linked_stack.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `linked_stack.cpp` --- lines 14--21.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/linked_stack.cpp", first: 14, last: 21, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement isEmpty, isFull, size and helpers.]
  ]

  `linked_stack.cpp` --- lines 22--58.
]

#include "../visuals/walk-linked-stack.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/linked_stack.cpp", first: 22, last: 58, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `linked_stack.cpp` --- lines 59--95.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/linked_stack.cpp", first: 59, last: 95, lang: "cpp")

#strong[Same trace, no ceiling.] The first section matches the array stack line for line; the second shows what the linked version adds.

```terminal
== Suggested trace ==
peek()    -> 30
pop()     -> removes 30
display() -> 20 10
  [ok]   LIFO: the last value pushed (30) was the first removed
== Growth past the array version's capacity of 5 ==
display() -> 90 80 70 60 50 40 20 10
  [ok]   eight values stored with no overflow (isFull() is always false)
== Underflow ==
90 80 70 60 50 40 20 10
pop() on an empty stack -> refused: stack is empty
  [ok]   pop on an empty stack is refused before reading the top
  [ok]   peek on an empty stack is refused
```

Eight values fit where the array held five, because each push allocates one node and links it in front of the old top. The line under `Underflow` lists the values in the order the pops returned them, 90 first; the ninth pop finds `top` equal to `nullptr` and is refused. `isFull()` still exists and always answers `false`, so the two stacks offer exactly the same operations and either can replace the other.

#strong[Drain it and reuse it.] On an empty stack, push 10, 20 and 30, pop all three, and check that they come back as 30 20 10 and that `top` is `nullptr` afterwards. Then push 40. The stack must accept it as if it were new, with 40 on top and nothing below it.
