#import "/.shared/typst/utp.typ": *

#strong[Program 3: Complete infix-to-postfix converter.]

#strong[File:] `infix_to_postfix.cpp`.

#strong[Chapter connection:] Lab-manual application: infix to postfix.

Implement the chapter token rules with a stack of operators. precedence and rightAssociative decide when to pop. The trace records the stack and output after each token. Operands are single letters/digits; this is not a full expression grammar validator.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-infix_to_postfix.typ"


+ #strong[Headers and initial definitions.]

`infix_to_postfix.cpp` --- lines 14--25.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 14, last: 25, lang: "text")

+ #strong[Implement isOperator, rightAssociative, toPostfix.]

`infix_to_postfix.cpp` --- lines 26--61.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/infix-trace.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 26, last: 61, lang: "text")

+ #strong[Connect the test cases in main.]

`infix_to_postfix.cpp` --- lines 62--97.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 62, last: 97, lang: "text")

+ #strong[Connect the test cases in main.]

`infix_to_postfix.cpp` --- lines 98--109. Continue in the same file; do not add another header or opening brace.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 98, last: 109, lang: "text")

#strong[Build, run, and inspect infix\_to\_postfix.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra infix_to_postfix.cpp -o infix_to_postfix.exe\n\n.\\infix_to_postfix.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Trace of A+B*C-D (the Chapter 5 figure) ==\n  read A   stack []   output A\n  read +   stack [+]   output A\n  read B   stack [+]   output AB\n  read *   stack [+*]   output AB\n  read C   stack [+*]   output ABC\n  read -   stack [-]   output ABC*+\n  read D   stack [-]   output ABC*+D\nresult: ABC*+D-\n\n== Test expressions ==\n  [ok]   A+B*C  ->  ABC*+   (expected ABC*+)\n  [ok]   (A+B)*C  ->  AB+C*   (expected AB+C*)\n  [ok]   A+B*C-D  ->  ABC*+D-   (expected ABC*+D-)\n  [ok]   A*(B+C)/D  ->  ABC+*D/   (expected ABC+*D/)", lang: "text")

The complete captured run is in `labs/outputs/infix_to_postfix.txt`.

#callout("tryit", title: [Try it yourself])[Compare A-B-C with A^B^C: expect AB-C- and ABC^^. Test (A+B and A+B) and check that failure is reported; do not use their incomplete outputs.]
