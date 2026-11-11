#import "/.shared/typst/utp.typ": *
#unit("labs", "04-circular-list")

#lab("4")[Circular linked-list operations] <sec:lab04>

#callout("sourcealignment", title: [Official Lab Manual --- Lab IV])[Circular linked-list insertion/deletion; compare list representations.]

#callout("labproject", title: [Maintain a circular list without breaking the loop])[#strong[Goal.] Insert, delete, and traverse without breaking the ring.

#strong[Recall first.] Review the #link(label("ch:circular-list"))[Circular Linked Lists] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab04` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/circular_linked_list.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/list_comparison.typ"
]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
