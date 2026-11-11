#import "/.shared/typst/utp.typ": *

#strong[Program 2: Linked stack with cleanup.]

#strong[File:] `linked_stack.cpp`.

#strong[Chapter connection:] Linked-list stack.

The top pointer replaces the array index. push links a new node at the front; pop advances top before deleting the old node. The driver grows beyond the array example capacity, then removes all nodes.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-linked_stack.typ"


+ #strong[Headers and initial definitions.]

`linked_stack.cpp` --- lines 14--21.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/linked_stack.cpp", first: 14, last: 21, lang: "text")

+ #strong[Implement isEmpty, isFull, size and helpers.]

`linked_stack.cpp` --- lines 22--58.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/walk-linked-stack.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/linked_stack.cpp", first: 22, last: 58, lang: "text")

+ #strong[Connect the test cases in main.]

`linked_stack.cpp` --- lines 59--95.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/linked_stack.cpp", first: 59, last: 95, lang: "text")

#strong[Build, run, and inspect linked\_stack.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra linked_stack.cpp -o linked_stack.exe\n\n.\\linked_stack.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Suggested trace ==\npeek()    -> 30\npop()     -> removes 30\ndisplay() -> 20 10 \n  [ok]   LIFO: the last value pushed (30) was the first removed\n\n== Growth past the array version's capacity of 5 ==\ndisplay() -> 90 80 70 60 50 40 20 10 \n  [ok]   eight values stored with no overflow (isFull() is always false)\n\n== Underflow ==\n90 80 70 60 50 40 20 10 \npop() on an empty stack -> refused: stack is empty\n  [ok]   pop on an empty stack is refused before reading the top\n  [ok]   peek on an empty stack is refused", lang: "text")

The complete captured run is in `labs/outputs/linked_stack.txt`.

#callout("tryit", title: [Try it yourself])[Push 10,20,30, then pop all three values. Expect 30,20,10 and a null top. Push once more to confirm reuse after draining.]
