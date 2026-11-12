#import "/.shared/typst/utp.typ": *

#strong[Program 1: Circular list with insertion, deletion, and cleanup.]

#strong[File:] `circular_linked_list.cpp`.

#strong[Chapter connection:] Circular Linked Lists: last pointer and one-lap traversal.

last-\>next is the head. Empty, singleton, and multi-node rings need different deletion handling. The program includes beginning/end/value deletion, a structural ring check, and cleanup that terminates without following freed storage.

#include "../visuals/program-circular_linked_list.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`circular_linked_list.cpp` --- lines 11--24.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 11, last: 24, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement displayCircular, insertBeginning, insertEnd.]
]

`circular_linked_list.cpp` --- lines 25--62.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/cll-traverse.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 25, last: 62, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Implement deleteBeginning, deleteEnd.]
]

`circular_linked_list.cpp` --- lines 63--98.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 63, last: 98, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Implement deleteValue, destroy.]
]

`circular_linked_list.cpp` --- lines 99--127.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 99, last: 127, lang: "cpp")

#colbreak()

#utpsteps[
  5. #strong[Implement ringIntact, contents, check and helpers.]
]

`circular_linked_list.cpp` --- lines 128--163.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 128, last: 163, lang: "cpp")

#colbreak()

#utpsteps[
  6. #strong[Connect the test cases in main.]
]

`circular_linked_list.cpp` --- lines 164--202.

#strong[Trace checkpoint for the supplied main.] Track last separately from the head last-\>next. Deleting the last remaining node must set last to nullptr, whereas deleting the tail of a longer ring must move last to its predecessor and preserve the link to the head. In main, deleting 25 at the end leaves node 20 pointing to itself. The traversal stops on returning to the head, not on a null link.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 164, last: 202, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect circular\_linked\_list.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra circular_linked_list.cpp -o circular_linked_list.exe

.\circular_linked_list.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

```terminal

== Insertions ==
insert 20 at the end: 20
  [ok]   last node still points to the head
insert 30 at the end: 20 30
  [ok]   last node still points to the head
insert 10 at the beginning: 10 20 30
  [ok]   last node still points to the head
insert 40 at the end: 10 20 30 40
  [ok]   last node still points to the head
insert 5 at the beginning: 5 10 20 30 40
  [ok]   last node still points to the head
  [ok]   the ring holds 5 10 20 30 40

== Deletions ==
delete from the beginning: 10 20 30 40

```

The complete captured run is in `labs/outputs/circular_linked_list.txt`.

#tryit[
  Build a one-node ring, delete that node, then insert again. Check the singleton self-link and the empty last pointer before attempting another traversal.
]
