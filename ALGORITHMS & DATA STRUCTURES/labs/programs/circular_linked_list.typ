#import "/.shared/typst/utp.typ": *

#strong[Program 1: Circular list with insertion, deletion, and cleanup.]

#strong[File:] `circular_linked_list.cpp`.

#strong[Chapter connection:] Circular Linked Lists: last pointer and one-lap traversal.

last-\>next is the head. Empty, singleton, and multi-node rings need different deletion handling. The program includes beginning/end/value deletion, a structural ring check, and cleanup that terminates without following freed storage.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-circular_linked_list.typ"


+ #strong[Headers and initial definitions.]

`circular_linked_list.cpp` --- lines 11--24.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 11, last: 24, lang: "text")

+ #strong[Implement displayCircular, insertBeginning, insertEnd.]

`circular_linked_list.cpp` --- lines 25--62.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`. 
#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/cll-traverse.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 25, last: 62, lang: "text")

+ #strong[Implement deleteBeginning, deleteEnd.]

`circular_linked_list.cpp` --- lines 63--98.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 63, last: 98, lang: "text")

+ #strong[Implement deleteValue, destroy.]

`circular_linked_list.cpp` --- lines 99--127.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 99, last: 127, lang: "text")

+ #strong[Implement ringIntact, contents, check and helpers.]

`circular_linked_list.cpp` --- lines 128--163.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 128, last: 163, lang: "text")

+ #strong[Connect the test cases in main.]

`circular_linked_list.cpp` --- lines 164--202.

#strong[Trace checkpoint for the supplied main.] Track last separately from the head last-\>next. Deleting the last remaining node must set last to nullptr, whereas deleting the tail of a longer ring must move last to its predecessor and preserve the link to the head. In main, deleting 25 at the end leaves node 20 pointing to itself. The traversal stops on returning to the head, not on a null link.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/circular_linked_list.cpp", first: 164, last: 202, lang: "text")

#strong[Build, run, and inspect circular\_linked\_list.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra circular_linked_list.cpp -o circular_linked_list.exe\n\n.\\circular_linked_list.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Insertions ==\ninsert 20 at the end: 20 \n  [ok]   last node still points to the head\ninsert 30 at the end: 20 30 \n  [ok]   last node still points to the head\ninsert 10 at the beginning: 10 20 30 \n  [ok]   last node still points to the head\ninsert 40 at the end: 10 20 30 40 \n  [ok]   last node still points to the head\ninsert 5 at the beginning: 5 10 20 30 40 \n  [ok]   last node still points to the head\n  [ok]   the ring holds 5 10 20 30 40\n\n== Deletions ==\ndelete from the beginning: 10 20 30 40", lang: "text")

The complete captured run is in `labs/outputs/circular_linked_list.txt`.

#callout("tryit", title: [Try it yourself])[Build a one-node ring, delete that node, then insert again. Check the singleton self-link and the empty last pointer before attempting another traversal.]
