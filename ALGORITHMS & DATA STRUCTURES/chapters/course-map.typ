#import "/.shared/typst/utp.typ": *


#heading(level: 1, numbering: none)[Course Map]


The course progresses from data organization to algorithm selection. Five stages build core skills; the final project compares algorithms with evidence.

#callout("utpfigure", title: [])[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/fcb9b86b5d63f2ff.cetz.json")]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Focus], [Key question],),
    table.hline(),
    [1], [Arrays and memory], [How is data stored and accessed?],
    [2], [Lists, stacks, and queues], [How do links and access rules organize data?],
    [3], [Trees, BSTs, and heaps], [How does hierarchy improve searching?],
    [4], [Graphs, BFS, and DFS], [How are relationships represented and traversed?],
    [5], [Searching, sorting, and hashing], [How does algorithm choice affect performance?],
    [6], [Comparison project], [How can algorithms be compared fairly?],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Complexity vocabulary used across the course]
 The table summarizes eight common Big-O classes, their representative growth functions, and typical algorithm examples.

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Class], [Figure label], [Growth function], [Typical examples],),
    table.hline(),
    [$O \( 1 \)$], [Constant], [$f \( n \) = 1$], [Array access; hash computation.],
    [$O \( log n \)$], [Logarithmic], [$f \( n \) = log_2 n$], [Binary search; balanced-BST lookup.],
    [$O \( n \)$], [Linear], [$f \( n \) = n$], [Linear search; linked-list traversal.],
    [$O \( n log n \)$], [Log-linear], [$f \( n \) = n log_2 n$], [Merge sort; heap sort.],
    [$O \( n^2 \)$], [Quadratic], [$f \( n \) = n^2$], [Bubble sort; selection sort.],
    [$O \( n^3 \)$], [Cubic], [$f \( n \) = n^3$], [Triple-nested loops; Floyd--Warshall.],
    [$O \( 2^n \)$], [Exponential], [$f \( n \) = 2^n$], [Subset enumeration; exhaustive include/exclude search.],
    [$O \( n ! \)$], [Factorial], [$f \( n \) = n !$], [Permutation enumeration; brute-force traveling salesperson search.],
  )]
  , kind: table
  )

#block[
\*

\*

]
