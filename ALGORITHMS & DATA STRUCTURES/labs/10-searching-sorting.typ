#import "/.shared/typst/utp.typ": *
#unit("labs", "10-searching-sorting")

#labsection(10, label: <sec:lab10>)[Searching and sorting experiments]

#labproject[Trace, implement, and compare algorithms][
  #note[
    #strong[Official Lab Manual --- Lab X.] Descending quick sort, binary search, three-array merge, and heap sort.
  ]

  #strong[Goal.] Implement four algorithms and compare results on controlled inputs.

  #strong[Recall first.] Review the #link(<ch:search-sort>)[Searching and Sorting] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Save each one in your `Lab10` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab10`.

  #include "programs/quick_sort_descending.typ"

  #include "programs/binary_search.typ"

  #include "programs/merge_three_arrays.typ"

  #include "programs/heap_sort.typ"
]

#element-head([One dataset through all four programs])

Run the lab's four programs as one pipeline on the common dataset, 29 10 14 37 13. Sort it in ascending order with heap sort and in descending order with quick sort; reverse the quick-sort result and check that the two arrays are equal. Binary search the ascending array for 13, which must be at index 1, and for 30, which must not be found. Merge it with `5 15` and an empty third array: the result is `5 10 13 14 15 29 37`. Finally, look again at the counts the two sorts printed, 6 comparisons for quick sort and 12 for heap sort, and explain why such counts cannot tell you which algorithm is faster on a million values.
