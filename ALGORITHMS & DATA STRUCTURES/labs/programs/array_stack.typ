#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: Bounded array stack])

#strong[File:] `array_stack.cpp`.

#strong[Chapter connection:] Array-based stack.

Keep topIndex at -1 when empty. push checks capacity before incrementing; pop checks emptiness before reading. main demonstrates LIFO, fills the capacity, and drains the stack to test underflow.

#include "../visuals/program-array_stack.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `array_stack.cpp` --- lines 10--23.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/array_stack.cpp", first: 10, last: 23, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement push, pop, peek and helpers.]
  ]

  `array_stack.cpp` --- lines 24--53.
]

#include "../visuals/stack-trace.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/array_stack.cpp", first: 24, last: 53, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `array_stack.cpp` --- lines 54--82.
]

#strong[Trace checkpoint for the supplied main.] After pushing 10, 20 and 30, peek returns 30 without changing the stack. pop returns the same value and moves the top back one position. The overflow test must refuse a write before indexing beyond capacity; the underflow test must refuse a read before using an empty top. Trace the boolean result separately from the output parameter value.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/array_stack.cpp", first: 54, last: 82, lang: "cpp")

#strong[Both ends of a fixed array.] The program pushes 10, 20 and 30 before it prints anything, so the run opens with 30 on top.

```terminal
== Suggested trace ==
peek()    -> 30
pop()     -> removes 30
display() -> 20 10
  [ok]   LIFO: the last value pushed (30) was the first removed
== Overflow (capacity 5) ==
push(40) -> ok
push(50) -> ok
push(60) -> ok
push(70) -> refused: stack is full
display() -> 60 50 40 20 10
  [ok]   the push after the stack is full is refused
== Underflow ==
pop() -> 60
pop() -> 50
pop() -> 40
pop() -> 20
pop() -> 10
pop() on an empty stack -> refused: stack is empty
  [ok]   pop on an empty stack is refused before reading the top
  [ok]   peek on an empty stack is refused
```

After 40, 50 and 60 the five slots are full and `topIndex` is 4, so 70 is refused. The pops then return the values in exactly the reverse of the order they went in, and the sixth pop is refused before it reads any slot. Both refusals are tests made before the array is touched: `isFull()` before a push, `isEmpty()` before a pop or a peek.

#strong[Hit both walls on purpose.] On an empty stack, push 1 to 5, then 6, then pop six times, and watch `topIndex` in the debugger after every call. Predict the values first: 0 to 4 for the pushes, 4 again after the refused push, then 3 down to -1, and -1 again after the refused pop. A refused call must leave both the array and `topIndex` exactly as they were.
