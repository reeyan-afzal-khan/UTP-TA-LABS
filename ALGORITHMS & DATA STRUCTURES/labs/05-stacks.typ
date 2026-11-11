#import "/.shared/typst/utp.typ": *
#unit("labs", "05-stacks")

#lab("5")[Stack ADT and expression processing] <sec:lab05>

#callout("sourcealignment", title: [Official Lab Manual --- Lab V])[Array stack, linked stack, and infix-to-postfix conversion.]

#callout("labproject", title: [Implement the stack ADT twice])[#strong[Goal.] Build two LIFO stacks, then use a stack to convert expressions.

#strong[Recall first.] Review the #link(label("ch:stacks"))[Stacks] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab05` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/array_stack.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/linked_stack.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/infix_to_postfix.typ"
]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
