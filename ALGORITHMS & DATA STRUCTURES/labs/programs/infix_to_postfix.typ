#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 3: Complete infix-to-postfix converter])

#strong[File:] `infix_to_postfix.cpp`.

#strong[Chapter connection:] Lab-manual application: infix to postfix.

Implement the chapter token rules with a stack of operators. precedence and rightAssociative decide when to pop. The trace records the stack and output after each token. Operands are single letters/digits; this is not a full expression grammar validator.

#include "../visuals/program-infix_to_postfix.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `infix_to_postfix.cpp` --- lines 14--25.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 14, last: 25, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement isOperator, rightAssociative, toPostfix.]
  ]

  `infix_to_postfix.cpp` --- lines 26--61.
]

#include "../visuals/infix-trace.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 26, last: 61, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `infix_to_postfix.cpp` --- lines 62--97.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 62, last: 97, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Connect the test cases in main.]
  ]

  `infix_to_postfix.cpp` --- lines 98--109. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab05/infix_to_postfix.cpp", first: 98, last: 109, lang: "cpp")

#strong[Watch the stack decide.] Each trace line shows the character read, the operator stack after it, and the output so far. Study the line for `-`: reading it empties the stack before `-` goes on.

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
  [ok]   A-B-C  ->  AB-C-   (expected AB-C-)
  [ok]   A^B^C  ->  ABC^^   (expected ABC^^)
== Malformed input ==
  [ok]   unbalanced "(A+B" is rejected
  [ok]   unbalanced "A+B)" is rejected
```

When `-` arrives, `*` and `+` are both waiting, and both have at least its precedence, so both go to the output before `-` is pushed. `A-B-C` and `A^B^C` differ for one reason. Subtraction is left-associative: an equal operator already on the stack is popped first, which gives `AB-C-`. Exponentiation is right-associative: the waiting `^` stays, the new one goes on top, and both come off at the end, giving `ABC^^`.

#strong[Add two cases of your own.] Extend the test list with `A*B+C*D`, which must give `AB*CD*+`, and `((A+B)*C`, which has one opening parenthesis too many and must be rejected. For the rejected one, print the error and nothing else: the output string of a failed conversion is incomplete and must never be used.
