#import "/.shared/typst/utp.typ": *

#strong[Program 2: Linked stack with cleanup.]

#strong[File:] `linked_stack.cpp`.

#strong[Chapter connection:] Linked-list stack.

The top pointer replaces the array index. push links a new node at the front; pop advances top before deleting the old node. The driver grows beyond the array example capacity, then removes all nodes.

#include "../visuals/program-linked_stack.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`linked_stack.cpp` --- lines 14--21.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/linked_stack.cpp", first: 14, last: 21, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement isEmpty, isFull, size and helpers.]
]

`linked_stack.cpp` --- lines 22--58.

#include "../visuals/walk-linked-stack.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/linked_stack.cpp", first: 22, last: 58, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`linked_stack.cpp` --- lines 59--95.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/linked_stack.cpp", first: 59, last: 95, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect linked\_stack.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra linked_stack.cpp -o linked_stack.exe

.\linked_stack.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

The complete captured run is in `labs/outputs/linked_stack.txt`.

#tryit[
  Push 10,20,30, then pop all three values. Expect 30,20,10 and a null top. Push once more to confirm reuse after draining.
]
