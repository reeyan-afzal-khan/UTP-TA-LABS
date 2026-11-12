#import "/.shared/typst/utp.typ": *

#chapter-star[Course Map]

The course progresses from data organization to algorithm selection. Five stages build core skills; the final project compares algorithms with evidence.

#utpfigure[
  #canvas({
    node((0, 0), [#coursemapcard([STAGE 01], [Foundations], [Arrays and memory])], name: "a", ..card)
    node(right-of("a", 0.66), [#coursemapcard([STAGE 02], [Linear structures], [Lists, stacks, and queues])], name: "b", ..card)
    node(right-of("b", 0.66), [#coursemapcard([STAGE 03], [Hierarchies], [Trees, BSTs, and heaps])], name: "c", ..card)
    node(below-of("c", 0.58), [#coursemapcard([STAGE 04], [Networks], [Graph representation and traversal])], name: "d", ..card)
    node(left-of("d", 0.66), [#coursemapcard([STAGE 05], [Core algorithms], [Searching, sorting, and hashing])], name: "e", ..card)
    node(left-of("e", 0.66), [#coursemapcard([STAGE 06], [Synthesis], [Evidence-based comparison])], name: "f", ..finalcard)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
    connect("d", "e", ..arr)
    connect("e", "f", ..arr)
  })
]

#utptable[
  #tabularx(
    columns: (8%, 31%, 1fr),
    align: (center, left, left),
    styles: (navy-bold,),
    header: ([Stage], [Focus], [Key question]),
    [1], [Arrays and memory], [How is data stored and accessed?],
    [2], [Lists, stacks, and queues], [How do links and access rules organize data?],
    [3], [Trees, BSTs, and heaps], [How does hierarchy improve searching?],
    [4], [Graphs, BFS, and DFS], [How are relationships represented and traversed?],
    [5], [Searching, sorting, and hashing], [How does algorithm choice affect performance?],
    [6], [Comparison project], [How can algorithms be compared fairly?],
  )
]

#heading(depth: 2, numbering: none)[Complexity vocabulary used across the course]

The table summarizes eight common Big-O classes, their representative growth functions, and typical algorithm examples.

#utptable[
  #tabularx(
    columns: (11%, 20%, 18%, 1fr),
    styles: (navy-bold,),
    header: ([Class], [Figure label], [Growth function], [Typical examples]),
    [$O(1)$], [Constant], [$f(n)=1$], [Array access; hash computation.],
    [$O(log n)$], [Logarithmic], [$f(n)=log_2 n$], [Binary search; balanced-BST lookup.],
    [$O(n)$], [Linear], [$f(n)=n$], [Linear search; linked-list traversal.],
    [$O(n log n)$], [Log-linear], [$f(n)=n log_2 n$], [Merge sort; heap sort.],
    [$O(n^2)$], [Quadratic], [$f(n)=n^2$], [Bubble sort; selection sort.],
    [$O(n^3)$], [Cubic], [$f(n)=n^3$], [Triple-nested loops; Floyd--Warshall.],
    [$O(2^n)$], [Exponential], [$f(n)=2^n$], [Subset enumeration; exhaustive include/exclude search.],
    [$O(n!)$], [Factorial], [$f(n)=n!$], [Permutation enumeration; brute-force traveling salesperson search.],
  )
]

#pagebreak()

#landscape[
  #v(1fr)

  #resizebox(84%)[#canvas({
    let curve-style = (line-width: 1.6438pt, end: tip("Stealth", length: 2.2mm, width: 1.6mm, line: 1.6438pt))
    let directlabel = (font: font("footnote", weight: "bold"), inner-sep: 0.797pt)
    connect((0, 0), (12.1, 0), line-width: 1.0461pt, draw: mix(muted, 88%, other: black), end: tip("Stealth", length: 2.9mm, line: 1.0461pt))
    connect((0, 0), (0, 8.1), line-width: 1.0461pt, draw: mix(muted, 88%, other: black), end: tip("Stealth", length: 2.9mm, line: 1.0461pt))
    node((6.05, -0.43), [Input Size], font: font("small", weight: "bold", fill: navy), anchor: "north")
    node((-0.64, 4.05), [Computations], font: font("small", weight: "bold", fill: navy), rotate: (90) * 1deg, anchor: "south")
    coordinate("start", (0.38, 0.42))
    connect("start", (8.72, 0.42), ..curve-style, draw: blue)
    curve("start", (8.72, 1.64), (1.02, 1.25), (3.22, 1.48), ..curve-style, draw: mix(rgb("00ff00"), 48%, other: black))
    connect("start", (8.72, 2.86), ..curve-style, draw: mix(mix(rgb("ffff00"), 55%, other: rgb("ff8000")), 78%, other: black))
    curve("start", (8.28, 4.06), (3.4, 1.08), (6.65, 2.82), ..curve-style, draw: orange)
    curve("start", (7.88, 5.62), (3.95, 0.53), (7.02, 2.35), ..curve-style, draw: red)
    curve("start", (7.18, 7.2), (3.45, 0.44), (6.05, 1.48), ..curve-style, draw: mix(red, 55%, other: black))
    curve("start", (5.12, 7.45), (2.22, 0.41), (4.47, 0.89), ..curve-style, draw: mix(rgb("ff00ff"), 82%, other: rgb("ff0000")))
    curve("start", (2.72, 7.47), (1.34, 0.4), (2.49, 0.69), ..curve-style, draw: mix(rgb("bf0040"), 76%, other: black))
    node((2.3, 7.55), [Factorial -- $O(n!)$], ..directlabel, text: mix(rgb("bf0040"), 76%, other: black), anchor: "south")
    node((5.12, 7.55), [Exponential -- $O(2^n)$], ..directlabel, text: mix(rgb("ff00ff"), 82%, other: rgb("ff0000")), anchor: "south")
    node((7.34, 7.2), [Cubic -- $O(n^3)$], ..directlabel, text: mix(red, 55%, other: black), anchor: "west")
    node((8.1, 5.62), [Quadratic -- $O(n^2)$], ..directlabel, text: red, anchor: "west")
    node((8.5, 4.06), [Log-linear -- $O(n log n)$], ..directlabel, text: orange, anchor: "west")
    node((8.94, 2.86), [Linear -- $O(n)$], ..directlabel, text: mix(mix(rgb("ffff00"), 55%, other: rgb("ff8000")), 78%, other: black), anchor: "west")
    node((8.94, 1.64), [Logarithmic -- $O(log n)$], ..directlabel, text: mix(rgb("00ff00"), 48%, other: black), anchor: "west")
    node((8.94, 0.42), [Constant -- $O(1)$], ..directlabel, text: blue, anchor: "west")
  })]

  #v(6pt)

  #captionof[figure]

  #strong[Common asymptotic growth rates.] Lower curves scale more slowly as input size increases; exponential and factorial growth become impractical most quickly.

  #v(1fr)
]

#pagebreak()
