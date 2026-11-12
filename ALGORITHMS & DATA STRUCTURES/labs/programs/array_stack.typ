#import "/.shared/typst/utp.typ": *

#strong[Program 1: Bounded array stack.]

#strong[File:] `array_stack.cpp`.

#strong[Chapter connection:] Array-based stack.

Keep topIndex at -1 when empty. push checks capacity before incrementing; pop checks emptiness before reading. main demonstrates LIFO, fills the capacity, and drains the stack to test underflow.

#include "../visuals/program-array_stack.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`array_stack.cpp` --- lines 10--23.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/array_stack.cpp", first: 10, last: 23, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement push, pop, peek and helpers.]
]

`array_stack.cpp` --- lines 24--53.

#include "../visuals/stack-trace.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/array_stack.cpp", first: 24, last: 53, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`array_stack.cpp` --- lines 54--82.

#strong[Trace checkpoint for the supplied main.] After pushing 10, 20 and 30, peek returns 30 without changing the stack. pop returns the same value and moves the top back one position. The overflow test must refuse a write before indexing beyond capacity; the underflow test must refuse a read before using an empty top. Trace the boolean result separately from the output parameter value.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/array_stack.cpp", first: 54, last: 82, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect array\_stack.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra array_stack.cpp -o array_stack.exe

.\array_stack.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/array_stack.txt`.

#tryit[
  Fill the five slots, attempt a sixth push, then pop six times. The failed push and final failed pop must not change stored values or the top index.
]
