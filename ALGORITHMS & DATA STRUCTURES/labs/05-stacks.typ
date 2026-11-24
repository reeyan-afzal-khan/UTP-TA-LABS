#import "/.shared/typst/utp.typ": *
#unit("labs", "05-stacks")

#labsection(5, label: <sec:lab05>)[Stack ADT and expression processing]

#labproject[Implement the stack ADT twice][
  #note[
    #strong[Official Lab Manual --- Lab V.] Array stack, linked stack, and infix-to-postfix conversion.
  ]

  #strong[Goal.] Build two LIFO stacks, then use a stack to convert expressions.

  #strong[Recall first.] Review the #link(<ch:stacks>)[Stacks] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Save each one in your `Lab05` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab05`.

  #include "programs/array_stack.typ"

  #include "programs/linked_stack.typ"

  #include "programs/infix_to_postfix.typ"
]

#element-head([Evaluate what you converted])

A postfix expression needs no parentheses and no precedence rules, only a stack. Write `evaluatePostfix` for single-digit operands: push each digit; for an operator, pop the right operand first, then the left one, and push the result. Convert `2+3*4-5` with Program 3, which gives `234*+5-`, and evaluate that: the answer must be 9, the same as working out the infix expression by hand. Then do `(8-2)/3`, whose postfix form is `82-3/` and whose value is 2. Use either of your stacks, and say why the order of the two pops matters for `-` and `/` but not for `+`.
