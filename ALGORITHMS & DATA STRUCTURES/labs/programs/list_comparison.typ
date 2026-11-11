#import "/.shared/typst/utp.typ": *

#strong[Program 2: Compare three complete list representations.]

#strong[File:] `list_comparison.cpp`.

#strong[Chapter connection:] Singly and Doubly Linked Lists; Circular Linked Lists.

Build all three structures from the same four values. The loops differ in their stopping conditions, not their logical contents. The final part frees each representation using its own termination rule. Node byte sizes are platform-dependent.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-list_comparison.typ"


+ #strong[Headers and initial definitions.]

`list_comparison.cpp` --- lines 10--20.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/list_comparison.cpp", first: 10, last: 20, lang: "text")

+ #strong[Connect the test cases in main.]

`list_comparison.cpp` --- lines 21--48. Continue in the same file; do not add another header or opening brace.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/complete-list-stop.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/list_comparison.cpp", first: 21, last: 48, lang: "text")

+ #strong[Connect the test cases in main.]

`list_comparison.cpp` --- lines 49--79. Continue in the same file; do not add another header or opening brace.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab04/list_comparison.cpp", first: 49, last: 79, lang: "text")

#strong[Build, run, and inspect list\_comparison.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra list_comparison.cpp -o list_comparison.exe\n\n.\\list_comparison.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("Input sequence: 10 20 30 40\n\nSingly, head forward to nullptr:   10 20 30 40 \nDoubly, head forward to nullptr:   10 20 30 40 \nDoubly, tail backward to nullptr:  40 30 20 10 \nCircular, head round to head:      10 20 30 40 \nCircular, two laps, no stop test:  10 20 30 40 10 20 30 40 \n\n                          Singly            Doubly            Circular\npointer fields per node   1 (next)          2 (prev, next)    1 (next)\nbytes per node here       16                24                16\nlast node's next          nullptr           nullptr           the head\ntraversal stops when      p == nullptr      p == nullptr      p == head again\nwalk backwards?           no                yes, via prev     no\nreach head from the end   no                via prev          one step: last->next", lang: "text")

The complete captured run is in `labs/outputs/list_comparison.txt`.

Reported byte sizes depend on the platform; compare the storage relationships rather than requiring these exact sizes.

#callout("tryit", title: [Try it yourself])[Repeat with an empty input and then one value. Predict how each loop terminates, including the circular one-node self-link. Check all cleanup paths finish.]
