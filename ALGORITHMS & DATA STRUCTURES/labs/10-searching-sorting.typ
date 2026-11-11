#import "/.shared/typst/utp.typ": *
#unit("labs", "10-searching-sorting")

#lab("10")[Searching and sorting experiments] <sec:lab10>

#callout("sourcealignment", title: [Official Lab Manual --- Lab X])[Descending quick sort, binary search, three-array merge, and heap sort.]

#callout("labproject", title: [Trace, implement, and compare algorithms])[#strong[Goal.] Implement four algorithms and compare results on controlled inputs.

#strong[Recall first.] Review the #link(label("ch:search-sort"))[Searching and Sorting] chapter.

#strong[Complete source files.] Each program below is a separate C++17 file. Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`. The line ranges refer to the supplied file; continued blocks preserve its braces and scope. Build one program at a time from its `all_experiments/Lab10` folder.


#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/quick_sort_descending.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/binary_search.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/merge_three_arrays.typ"



#include "/ALGORITHMS & DATA STRUCTURES/labs/programs/heap_sort.typ"
]

#callout("verification", title: [Verification checklist])[$square.stroked.tiny$ Every listed program compiles independently with its own `main()`. \
$square.stroked.tiny$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \
$square.stroked.tiny$ Explain one code-to-diagram state change and demonstrate one additional test.]
