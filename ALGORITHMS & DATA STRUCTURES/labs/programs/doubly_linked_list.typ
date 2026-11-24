#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 2: Doubly linked list in both directions])

#strong[File:] `doubly_linked_list.cpp`.

#strong[Chapter connection:] Doubly linked lists.

Every edit must repair both next and prev. Keep head and tail consistent when a boundary node changes. The invariantsHold helper checks the structure after each operation; forward and backward displays reveal mismatched links.

#include "../visuals/program-doubly_linked_list.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `doubly_linked_list.cpp` --- lines 10--24.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 10, last: 24, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement append, pushFront, insertAt.]
  ]

  `doubly_linked_list.cpp` --- lines 25--60.
]

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/dll.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 25, last: 60, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Implement displayForward, displayBackward, search and helpers.]
  ]

  `doubly_linked_list.cpp` --- lines 61--94.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 61, last: 94, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Implement destroy, invariantsHold, forwardContents and helpers.]
  ]

  `doubly_linked_list.cpp` --- lines 95--130.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 95, last: 130, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    5. #strong[Connect the test cases in main.]
  ]

  `doubly_linked_list.cpp` --- lines 131--164.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 131, last: 164, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    6. #strong[Connect the test cases in main.]
  ]

  `doubly_linked_list.cpp` --- lines 165--177. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 165, last: 177, lang: "cpp")

#strong[Forward and backward must agree.] After every change the program prints the list twice, once from `head` along `next` and once from `tail` along `prev`. The second line must always be the first one reversed.

```terminal
== Empty and one-node lists ==
empty list
  forward:  (empty)
  backward: (empty)
  [ok]   next/prev invariants hold
  [ok]   search on an empty list reports not found
  [ok]   delete on an empty list is refused
...
== Insertions at several positions ==
...
insert 30 at position 2 (middle)
  forward:  10 20 30 40
  backward: 40 30 20 10
  [ok]   next/prev invariants hold
insert 50 at position 4 (tail)
  forward:  10 20 30 40 50
  backward: 50 40 30 20 10
  [ok]   next/prev invariants hold
  [ok]   the list is 10 20 30 40 50
== Search ==
search(40) -> position 3
search(99) -> -1 (not found)
  [ok]   found and not-found cases are both reported
== Deletions ==
delete 10 (head)
  forward:  20 30 40 50
  backward: 50 40 30 20
  [ok]   next/prev invariants hold
  [ok]   deleting the head updates head
delete 50 (tail)
  forward:  20 30 40
  backward: 40 30 20
  [ok]   next/prev invariants hold
  [ok]   deleting the tail updates tail
delete 30 (middle)
  forward:  20 40
  backward: 40 20
  [ok]   next/prev invariants hold
  [ok]   deleting a missing value is refused
  [ok]   live nodes equal list length (deleted nodes were released)
  [ok]   destroying the list releases every node
```

A forward print alone would look right even if a deletion forgot to repair a `prev` pointer; the backward walk is what exposes it. The invariant check after each step goes further: `head->prev` and `tail->next` are `nullptr`, `x->next->prev == x` for every node `x`, and the walks in both directions count the same number of nodes. Deleting 30 is the case with the most work, because both of its neighbours, 20 and 40, need a new link.

#strong[Peel a three-node list.] Start a fresh list 1 2 3 and delete 1, then 3. After each deletion check, in the debugger or from the display lines, that `head->prev` and `tail->next` are both `nullptr` and that the backward line is the forward line reversed. With a single node left, `head` and `tail` must point to the same node.
