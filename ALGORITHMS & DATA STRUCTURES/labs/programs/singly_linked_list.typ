#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: Singly linked list with all operations])

#strong[File:] `singly_linked_list.cpp`.

#strong[Chapter connection:] Singly linked lists: traversal, insert at the beginning, delete by value.

Build nodes with new, link before losing the successor, and delete only after bypassing a node. insertAt adds position handling to the chapter pattern. The driver tests empty, one-node, middle, head, and tail cases, then destroys the remaining list.

#include "../visuals/program-singly_linked_list.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `singly_linked_list.cpp` --- lines 10--24.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 10, last: 24, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement display, pushFront, append and helpers.]
  ]

  `singly_linked_list.cpp` --- lines 25--62.
]

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/sll-anatomy.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 25, last: 62, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Implement search, deleteValue.]
  ]

  `singly_linked_list.cpp` --- lines 63--94.
]

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/sll-delete.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 63, last: 94, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Connect the test cases in main.]
  ]

  `singly_linked_list.cpp` --- lines 95--128.
]

#strong[Trace checkpoint for the supplied main.] Trace insertAt(head, 1, 15) between nodes 10 and 20: the new node must point to the old successor before its predecessor points to it. Later deletion of 20 must reconnect 15 directly to 30 and release only node 20. Use Node::live to check ownership as well as contents; a correct-looking printout can still conceal a leak.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 95, last: 128, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    5. #strong[Connect the test cases in main.]
  ]

  `singly_linked_list.cpp` --- lines 129--159. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/singly_linked_list.cpp", first: 129, last: 159, lang: "cpp")

#strong[Edge cases first.] The run opens where linked-list bugs usually hide, with an empty list and a list of one node, before it builds the ordinary five-node list.

```terminal
== Empty list ==
(empty)
  [ok]   search on an empty list reports not found
  [ok]   delete on an empty list is refused without touching a null pointer
== One-node list ==
10
  [ok]   deleting the only node leaves an empty list
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
delete 40 (tail):   15 30
  [ok]   after head, middle and tail deletions the list is 15 30
  [ok]   deleting a missing value is refused
  [ok]   live nodes equal list length (deleted nodes were released)
  [ok]   destroying the list releases every node
```

`search(30)` answers 3 because positions count from 0, like array indexes. The three deletions each repair a different pointer: deleting 10 moves `head`, deleting 20 links 15 straight to 30, and deleting 40 sets the `next` of 30 to `nullptr`. The last two checks count allocations, so a node that was unlinked but never deleted would show up there as a leak.

#strong[Delete until nothing is left.] Build the list 10 20 30, then delete 10, 30 and 20 in that order (the head, the tail, then the only node left), displaying the list after each step. After the third deletion `head` must be `nullptr` and the display must print `(empty)`. Delete 20 once more: the call must return `false` without touching a null pointer.
