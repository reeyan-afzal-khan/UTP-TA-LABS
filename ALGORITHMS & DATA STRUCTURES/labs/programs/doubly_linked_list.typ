#import "/.shared/typst/utp.typ": *

#strong[Program 2: Doubly linked list in both directions.]

#strong[File:] `doubly_linked_list.cpp`.

#strong[Chapter connection:] Doubly linked lists.

Every edit must repair both next and prev. Keep head and tail consistent when a boundary node changes. The invariantsHold helper checks the structure after each operation; forward and backward displays reveal mismatched links.

#include "../visuals/program-doubly_linked_list.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`doubly_linked_list.cpp` --- lines 10--24.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 10, last: 24, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement append, pushFront, insertAt.]
]

`doubly_linked_list.cpp` --- lines 25--60.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/dll.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 25, last: 60, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Implement displayForward, displayBackward, search and helpers.]
]

`doubly_linked_list.cpp` --- lines 61--94.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 61, last: 94, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Implement destroy, invariantsHold, forwardContents and helpers.]
]

`doubly_linked_list.cpp` --- lines 95--130.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 95, last: 130, lang: "cpp")

#colbreak()

#utpsteps[
  5. #strong[Connect the test cases in main.]
]

`doubly_linked_list.cpp` --- lines 131--164.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 131, last: 164, lang: "cpp")

#colbreak()

#utpsteps[
  6. #strong[Connect the test cases in main.]
]

`doubly_linked_list.cpp` --- lines 165--177. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 165, last: 177, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect doubly\_linked\_list.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra doubly_linked_list.cpp -o doubly_linked_list.exe

.\doubly_linked_list.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

```terminal

== Insertions at several positions ==
append 20
  forward:  20
  backward: 20
  [ok]   next/prev invariants hold
append 40
  forward:  20 40
  backward: 40 20
  [ok]   next/prev invariants hold
insert 10 at the head
  forward:  10 20 40
  backward: 40 20 10
  [ok]   next/prev invariants hold
insert 30 at position 2 (middle)
  forward:  10 20 30 40

```

The complete captured run is in `labs/outputs/doubly_linked_list.txt`.

#tryit[
  Delete the first and last entries from a fresh three-node list. Check head-\>prev and tail-\>next are null, and that backward output is the reverse of forward output.
]
