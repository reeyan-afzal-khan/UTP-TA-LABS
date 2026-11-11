#import "/.shared/typst/utp.typ": *
#unit("labs", "03-linked-lists")

#lab("3")[Singly and doubly linked lists] <sec:lab03>

#callout("sourcealignment", title: [Official Lab Manual --- Lab III])[Create, display, search, insert, and delete in singly and doubly linked lists.]

#callout("labproject", title: [Implement both pointer structures])[#strong[Goal.] Implement singly and doubly linked lists; preserve links after every change.

#strong[Recall first.] Review the #link(label("ch:linked-lists"))[Singly and Doubly Linked Lists] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab03` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/singly_linked_list.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/doubly_linked_list.typ"
]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
