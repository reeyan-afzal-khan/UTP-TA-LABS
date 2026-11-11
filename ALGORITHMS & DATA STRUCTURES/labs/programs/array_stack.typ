#import "/.shared/typst/utp.typ": *

#strong[Program 1: Bounded array stack.]

#strong[File:] `array_stack.cpp`.

#strong[Chapter connection:] Array-based stack.

Keep topIndex at -1 when empty. push checks capacity before incrementing; pop checks emptiness before reading. main demonstrates LIFO, fills the capacity, and drains the stack to test underflow.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-array_stack.typ"


+ #strong[Headers and initial definitions.]

`array_stack.cpp` --- lines 10--23.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/array_stack.cpp", first: 10, last: 23, lang: "text")

+ #strong[Implement push, pop, peek and helpers.]

`array_stack.cpp` --- lines 24--53.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/stack-trace.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/array_stack.cpp", first: 24, last: 53, lang: "text")

+ #strong[Connect the test cases in main.]

`array_stack.cpp` --- lines 54--82.

#strong[Trace checkpoint for the supplied main.] After pushing 10, 20 and 30, peek returns 30 without changing the stack. pop returns the same value and moves the top back one position. The overflow test must refuse a write before indexing beyond capacity; the underflow test must refuse a read before using an empty top. Trace the boolean result separately from the output parameter value.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/array_stack.cpp", first: 54, last: 82, lang: "text")

#strong[Build, run, and inspect array\_stack.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra array_stack.cpp -o array_stack.exe\n\n.\\array_stack.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Suggested trace ==\npeek()    -> 30\npop()     -> removes 30\ndisplay() -> 20 10 \n  [ok]   LIFO: the last value pushed (30) was the first removed\n\n== Overflow (capacity 5) ==\npush(40) -> ok\npush(50) -> ok\npush(60) -> ok\npush(70) -> refused: stack is full\ndisplay() -> 60 50 40 20 10 \n  [ok]   the push after the stack is full is refused\n\n== Underflow ==", lang: "text")

The complete captured run is in `labs/outputs/array_stack.txt`.

#callout("tryit", title: [Try it yourself])[Fill the five slots, attempt a sixth push, then pop six times. The failed push and final failed pop must not change stored values or the top index.]
