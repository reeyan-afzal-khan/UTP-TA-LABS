#import "/.shared/typst/utp.typ": *

#strong[Program 1: Singly linked list with all operations.]

#strong[File:] `singly_linked_list.cpp`.

#strong[Chapter connection:] Singly linked lists: traversal, insert at the beginning, delete by value.

Build nodes with new, link before losing the successor, and delete only after bypassing a node. insertAt adds position handling to the chapter pattern. The driver tests empty, one-node, middle, head, and tail cases, then destroys the remaining list.

#include "../visuals/program-singly_linked_list.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`singly_linked_list.cpp` --- lines 10--24.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 10, last: 24, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement display, pushFront, append and helpers.]
]

`singly_linked_list.cpp` --- lines 25--62.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/sll-anatomy.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 25, last: 62, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Implement search, deleteValue.]
]

`singly_linked_list.cpp` --- lines 63--94.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/sll-delete.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 63, last: 94, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Connect the test cases in main.]
]

`singly_linked_list.cpp` --- lines 95--128.

#strong[Trace checkpoint for the supplied main.] Trace insertAt(head, 1, 15) between nodes 10 and 20: the new node must point to the old successor before its predecessor points to it. Later deletion of 20 must reconnect 15 directly to 30 and release only node 20. Use Node::live to check ownership as well as contents; a correct-looking printout can still conceal a leak.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 95, last: 128, lang: "cpp")

#colbreak()

#utpsteps[
  5. #strong[Connect the test cases in main.]
]

`singly_linked_list.cpp` --- lines 129--159. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 129, last: 159, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect singly\_linked\_list.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra singly_linked_list.cpp -o singly_linked_list.exe

.\singly_linked_list.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

```terminal

== Build 10 15 20 30 40 ==
10 15 20 30 40
  [ok]   insertion at head, middle and tail gives 10 15 20 30 40
  [ok]   insert beyond the end is refused

== Search ==
search(30) -> position 3
search(99) -> -1 (not found)
  [ok]   a stored value is found at its position
  [ok]   a missing value reports not found

== Delete by value ==
delete 10 (head):   15 20 30 40
  [ok]   deleting the head moves head to the next node
delete 20 (middle): 15 30 40

```

The complete captured run is in `labs/outputs/singly_linked_list.txt`.

#tryit[
  Build 10,20,30; remove the head, tail, and final node in sequence. Confirm head becomes null, a missing value returns false, and no allocated node remains.
]
