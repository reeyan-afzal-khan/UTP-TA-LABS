#import "/.shared/typst/utp.typ": *

#strong[Program 2: Doubly linked list in both directions.]

#strong[File:] `doubly_linked_list.cpp`.

#strong[Chapter connection:] Doubly linked lists.

Every edit must repair both next and prev. Keep head and tail consistent when a boundary node changes. The invariantsHold helper checks the structure after each operation; forward and backward displays reveal mismatched links.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-doubly_linked_list.typ"


+ #strong[Headers and initial definitions.]

`doubly_linked_list.cpp` --- lines 10--24.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 10, last: 24, lang: "text")

+ #strong[Implement append, pushFront, insertAt.]

`doubly_linked_list.cpp` --- lines 25--60.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`. 
#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/dll.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 25, last: 60, lang: "text")

+ #strong[Implement displayForward, displayBackward, search and helpers.]

`doubly_linked_list.cpp` --- lines 61--94.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 61, last: 94, lang: "text")

+ #strong[Implement destroy, invariantsHold, forwardContents and helpers.]

`doubly_linked_list.cpp` --- lines 95--130.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 95, last: 130, lang: "text")

+ #strong[Connect the test cases in main.]

`doubly_linked_list.cpp` --- lines 131--164.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 131, last: 164, lang: "text")

+ #strong[Connect the test cases in main.]

`doubly_linked_list.cpp` --- lines 165--177. Continue in the same file; do not add another header or opening brace.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab03/doubly_linked_list.cpp", first: 165, last: 177, lang: "text")

#strong[Build, run, and inspect doubly\_linked\_list.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra doubly_linked_list.cpp -o doubly_linked_list.exe\n\n.\\doubly_linked_list.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Insertions at several positions ==\nappend 20\n  forward:  20 \n  backward: 20 \n  [ok]   next/prev invariants hold\nappend 40\n  forward:  20 40 \n  backward: 40 20 \n  [ok]   next/prev invariants hold\ninsert 10 at the head\n  forward:  10 20 40 \n  backward: 40 20 10 \n  [ok]   next/prev invariants hold\ninsert 30 at position 2 (middle)\n  forward:  10 20 30 40", lang: "text")

The complete captured run is in `labs/outputs/doubly_linked_list.txt`.

#callout("tryit", title: [Try it yourself])[Delete the first and last entries from a fresh three-node list. Check head-\>prev and tail-\>next are null, and that backward output is the reverse of forward output.]
