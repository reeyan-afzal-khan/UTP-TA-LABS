#import "/.shared/typst/utp.typ": *
#unit("labs", "08-trees-ii")

#lab("8")[BSTs, heaps, and balancing structures] <sec:lab08>

#callout("sourcealignment", title: [Official Lab Manual --- Lab VIII])[BST operations, min/max heaps, height balancing, and instructor-led B-tree practice.]

#callout("labproject", title: [Compare ordering rules across specialized trees])[#strong[Goal.] Compare BST ordering, heap ordering, and the effect of tree height.

#strong[Recall first.] Review the #link(label("ch:trees-ii"))[BSTs, Heaps, and Height Balancing] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab08` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/bst.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/heap.typ"
 #strong[Instructor-led B-tree extension.] Use the degree and occupancy rules specified in class to draw split, borrow, and merge. The complete programs here cover BSTs, height checks, and min/max heaps; B-tree implementation is outside these supplied program files.]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
