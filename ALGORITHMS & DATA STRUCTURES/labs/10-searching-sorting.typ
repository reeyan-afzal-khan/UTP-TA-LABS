#import "/.shared/typst/utp.typ": *
#unit("labs", "10-searching-sorting")

#labsection(10, label: <sec:lab10>)[Searching and sorting experiments]

#sourcealignment[Official Lab Manual --- Lab X][
  Descending quick sort, binary search, three-array merge, and heap sort.
]

#labproject[Trace, implement, and compare algorithms][
  #strong[Goal.] Implement four algorithms and compare results on controlled inputs.

  #strong[Recall first.] Review the #link(<ch:search-sort>)[Searching and Sorting] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Build one program at a time from its `all_experiments/Lab10` folder.

  #include "programs/quick_sort_descending.typ"

  #colbreak()

  #include "programs/binary_search.typ"

  #colbreak()

  #include "programs/merge_three_arrays.typ"

  #colbreak()

  #include "programs/heap_sort.typ"
]

#verification[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
