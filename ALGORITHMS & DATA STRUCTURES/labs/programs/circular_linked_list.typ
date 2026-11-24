#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: Circular list with insertion, deletion, and cleanup])

#strong[File:] `circular_linked_list.cpp`.

#strong[Chapter connection:] Circular Linked Lists: last pointer and one-lap traversal.

last-\>next is the head. Empty, singleton, and multi-node rings need different deletion handling. The program includes beginning/end/value deletion, a structural ring check, and cleanup that terminates without following freed storage.

#include "../visuals/program-circular_linked_list.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `circular_linked_list.cpp` --- lines 11--24.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 11, last: 24, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement displayCircular, insertBeginning, insertEnd.]
  ]

  `circular_linked_list.cpp` --- lines 25--62.
]

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/cll-traverse.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 25, last: 62, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Implement deleteBeginning, deleteEnd.]
  ]

  `circular_linked_list.cpp` --- lines 63--98.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 63, last: 98, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Implement deleteValue, destroy.]
  ]

  `circular_linked_list.cpp` --- lines 99--127.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 99, last: 127, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    5. #strong[Implement ringIntact, contents, check and helpers.]
  ]

  `circular_linked_list.cpp` --- lines 128--163.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 128, last: 163, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    6. #strong[Connect the test cases in main.]
  ]

  `circular_linked_list.cpp` --- lines 164--202.
]

#strong[Trace checkpoint for the supplied main.] Track last separately from the head last-\>next. Deleting the last remaining node must set last to nullptr, whereas deleting the tail of a longer ring must move last to its predecessor and preserve the link to the head. In main, deleting 25 at the end leaves node 20 pointing to itself. The traversal stops on returning to the head, not on a null link.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 164, last: 202, lang: "cpp")

#strong[One check after every change.] Every operation is followed by the same test, `last node still points to the head`, because a single wrong pointer turns the ring into a line, or into a loop that never ends.

```terminal
== Empty and one-node lists ==
empty: (empty)
  [ok]   last node still points to the head
  [ok]   deleting from an empty list is refused
insert 1 at the end: 1
  [ok]   last node still points to the head
  [ok]   a single node points to itself
delete from the end (one node): (empty)
  [ok]   last node still points to the head
== Insertions ==
insert 20 at the end: 20
  [ok]   last node still points to the head
...
insert 5 at the beginning: 5 10 20 30 40
  [ok]   last node still points to the head
  [ok]   the ring holds 5 10 20 30 40
== Deletions ==
delete from the beginning: 10 20 30 40
  [ok]   last node still points to the head
delete from the end: 10 20 30
  [ok]   last node still points to the head
delete value 10 (the head): 20 30
  [ok]   last node still points to the head
insert 25 at the end: 20 30 25
  [ok]   last node still points to the head
delete value 30 (a middle node): 20 25
  [ok]   last node still points to the head
delete value 25 (the last node): 20
  [ok]   last node still points to the head
  [ok]   last moved back to 20 when the last node was deleted
  [ok]   deleting a missing value is refused
Traversal stops when it comes back to the head (do ... while p != head),
never at nullptr: a circular list has no null pointer to stop at.
  [ok]   destroying the list releases every node
```

The list keeps one pointer, `last`, and finds the head as `last->next`. That is why `insertBeginning` and `insertEnd` both cost a single step: each splices the new node in after `last`, and only `insertEnd` then moves `last` on to it. Deleting 25, the last node, needs the opposite repair: the program walks round the ring to 20 and makes it the new `last`.

#strong[Empty the ring, then refill it.] Insert 7 into an empty list, delete it, and insert 7 again. Before each display, check two things in the debugger: with one node, `last->next == last`; with none, `last == nullptr`. A traversal must test for `nullptr` before it reads `last->next`; find that test at the top of `displayCircular`.
