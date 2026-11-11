#import "/.shared/typst/utp.typ": *
#unit("labs", "01-foundations")

#lab("1")[Programming foundations and structured records] <sec:lab01>

#callout("sourcealignment", title: [Official Lab Manual --- Lab I])[Structures, unions, pointers, and 1D arrays; build a small record application.]

#callout("labproject", title: [Build a small record-based application])[#strong[Goal.] Store, search, and update five student records.

#strong[Recall first.] Review the #link(label("ch:introduction"))[Introduction to Data Structures] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab01` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/student_records.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/union_review.typ"
]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
