#import "/.shared/typst/utp.typ": *
#unit("labs", "02-arrays")

#lab("2")[Arrays, multidimensional storage, and matrices] <sec:lab02>

#callout("sourcealignment", title: [Official Lab Manual --- Lab II])[1D/2D arrays, nested loops, and matrix operations.]

#callout("labproject", title: [Process and multiply matrices])[#strong[Goal.] Multiply compatible matrices and trace one result cell.

#strong[Recall first.] Review the #link(label("ch:arrays"))[Arrays and Two-Dimensional Arrays] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab02` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/matrix_multiply.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/matrix_operations.typ"
]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
