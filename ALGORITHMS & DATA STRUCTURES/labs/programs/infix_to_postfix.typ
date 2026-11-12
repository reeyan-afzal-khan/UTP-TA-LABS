#import "/.shared/typst/utp.typ": *

#strong[Program 3: Complete infix-to-postfix converter.]

#strong[File:] `infix_to_postfix.cpp`.

#strong[Chapter connection:] Lab-manual application: infix to postfix.

Implement the chapter token rules with a stack of operators. precedence and rightAssociative decide when to pop. The trace records the stack and output after each token. Operands are single letters/digits; this is not a full expression grammar validator.

#include "../visuals/program-infix_to_postfix.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`infix_to_postfix.cpp` --- lines 14--25.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 14, last: 25, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement isOperator, rightAssociative, toPostfix.]
]

`infix_to_postfix.cpp` --- lines 26--61.

#include "../visuals/infix-trace.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 26, last: 61, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`infix_to_postfix.cpp` --- lines 62--97.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 62, last: 97, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Connect the test cases in main.]
]

`infix_to_postfix.cpp` --- lines 98--109. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 98, last: 109, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect infix\_to\_postfix.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra infix_to_postfix.cpp -o infix_to_postfix.exe

.\infix_to_postfix.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

```terminal

== Trace of A+B*C-D (the Chapter 5 figure) ==
  read A   stack []   output A
  read +   stack [+]   output A
  read B   stack [+]   output AB
  read *   stack [+*]   output AB
  read C   stack [+*]   output ABC
  read -   stack [-]   output ABC*+
  read D   stack [-]   output ABC*+D
result: ABC*+D-

== Test expressions ==
  [ok]   A+B*C  ->  ABC*+   (expected ABC*+)
  [ok]   (A+B)*C  ->  AB+C*   (expected AB+C*)
  [ok]   A+B*C-D  ->  ABC*+D-   (expected ABC*+D-)
  [ok]   A*(B+C)/D  ->  ABC+*D/   (expected ABC+*D/)

```

The complete captured run is in `labs/outputs/infix_to_postfix.txt`.

#tryit[
  Compare A-B-C with A^B^C: expect AB-C- and ABC^^. Test (A+B and A+B) and check that failure is reported; do not use their incomplete outputs.
]
