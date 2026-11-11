#import "/.shared/typst/utp.typ": *
#unit("labs", "06-queues")

#lab("6")[Linear, linked, circular, and priority queues] <sec:lab06>

#callout("sourcealignment", title: [Official Lab Manual --- Lab VI])[Linear, linked, circular, and priority queues.]

#callout("labproject", title: [Implement queues and demonstrate wrap-around])[#strong[Goal.] Preserve FIFO order across array wrap-around.

#strong[Recall first.] Review the #link(label("ch:queues"))[Queues] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab06` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/linear_queue.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/linked_queue.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/circular_queue.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/priority_queue.typ"
]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
