#import "/.shared/typst/utp.typ": *
#unit("labs", "11-hashing")

#lab("11")[Hashing and collision resolution] <sec:lab11>

#callout("sourcealignment", title: [Official Lab Manual --- Lab XI])[Linear, quadratic, and double-hash collision resolution.]

#callout("labproject", title: [Resolve the same collision three ways])[#strong[Goal.] Resolve identical collisions using three probe rules.

#strong[Recall first.] Review the #link(label("ch:hashing"))[Hashing] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab11` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/hashing_collisions.typ"
]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
