#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-arrays")


#heading(level: 1)[Arrays and Two-Dimensional Arrays]
<ch:arrays>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know the basic distinction between primitive and non-primitive data structures from #ref(label("ch:introduction"), supplement: [Chapter]).

*By the end, you can:* define an array, explain contiguous storage and index-based access, distinguish 1D and 2D arrays, trace row/column access, and solve matrix-style tasks with nested loops.]

An #strong[array] stores a collection of similar data items of the same type. The Week II slides emphasize three properties: same-type elements, contiguous memory locations, and random access through index positions.

#callout("firstread", title: [Core path])[Remember the sequence #strong[Store $arrow.r$ Access $arrow.r$ Process]. Arrays make the access step simple because an index identifies the position directly.]


#heading(level: 2)[What is an array?]


Consider the one-dimensional array $ \[ 12 \, med 25 \, med 18 \, med 30 \, med 22 \] . $ Its indexes are $0 \, 1 \, 2 \, 3 \, 4$ in normal C++ indexing.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/86c7a68d587db810.cetz.json")], caption: [A one-dimensional array. The index is a position, not a value: index 3 and the value 30 are different things stored in different places.]) <fig:array-1d>


#heading(level: 3)[Array properties from the slides]


- Every element has the same data type and therefore the same element size.

- Elements are stored at contiguous memory locations.

- The first element occupies the smallest memory location in the block.

- An element can be accessed directly from its index because its address can be calculated from the base address and element size.


#heading(level: 2)[Address calculation]


The slides state that the address of an array element can be calculated from the base address and element size. A standard expression for a one-dimensional, zero-based array is $ "address" \( A \[ i \] \) = "base" \( A \) + i times "sizeof" \( A \[ 0 \] \) . $

#callout("workedexample", title: [Worked example])[If the base address is 1000 and each integer occupies 4 bytes, then the address of `A[3]` is $ 1000 + 3 \( 4 \) = 1012 . $ This arithmetic is the reason direct index access does not require traversing the earlier elements.]

#ref(label("fig:array-memory"), supplement: [Figure]) shows why that single multiplication is the whole story. The machine never looks at `A[0]`, `A[1]`, or `A[2]` on the way to `A[3]`; it computes one address and reads it.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/85dcecd81ed51663.cetz.json")], caption: [Contiguous storage turns indexing into arithmetic. Because every element is the same size, the address of any element is one multiply-and-add away from the base address --- so reaching `A[3]` costs the same as reaching `A[0]`.]) <fig:array-memory>

#callout("clarification", title: [Clarification])[The formula above is an explanatory expansion of the slide statement about base address and element size. The slides themselves do not provide a numeric address formula.]


#heading(level: 2)[One-dimensional vs two-dimensional arrays]


A 1D array forms a single indexed sequence. A 2D array stores values in rows and columns and is commonly used for tables, grids, and matrices.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/5bd9e18391ea58ca.cetz.json")], caption: [A $3 times 3$ array. The first index selects the row, the second selects the column, so `matrix[1][2]` is row~1, column~2 --- the value~6.]) <fig:array-2d>

#callout("clarification", title: [Clarification])[A 2D array is a convenient #emph[notation]; memory itself is still one flat sequence of bytes. C++ stores the rows one after another, an arrangement called #strong[row-major order] (#ref(label("fig:row-major"), supplement: [Figure])). This is why `matrix[r][c]` can still be resolved with arithmetic, and why walking a matrix row by row is friendlier to the cache than walking it column by column.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/28e1ed11cb8c633e.cetz.json")], caption: [Row-major order: the rows of a two-dimensional array are laid end to end in linear memory. The element `matrix[r][c]` sits at flat offset $r times 3 + c$, which is how two indices collapse back into one address.]) <fig:row-major>

In C++:

#code-block("int matrix[3][3] = {\n    {1, 2, 3},\n    {4, 5, 6},\n    {7, 8, 9}\n};\n\ncout << matrix[1][2];   // 6", lang: "text")

The first index chooses the row; the second chooses the column.


#heading(level: 2)[Processing a 2D array with nested loops]


The Week II summary explicitly connects 2D arrays with nested loops.

#code-block("for (int r = 0; r < 3; ++r) {\n    for (int c = 0; c < 3; ++c) {\n        cout << matrix[r][c] << ' ';\n    }\n    cout << '\\n';\n}", lang: "text")

The outer loop changes rows, while the inner loop visits the columns within the current row.

#callout("workedexample", title: [Worked example])[To compute the sum of every element in a $3 times 3$ matrix, initialize `sum = 0`, visit each pair `[r][c]`, and add the value. The traversal touches each matrix cell once.]


#heading(level: 2)[Why arrays are useful]


The Week II slides give three practical motivations:

- multiple values can be stored under one variable name;

- multiple values can be processed quickly and systematically;

- searching and sorting operations can be applied naturally to the indexed sequence.

Arrays are especially useful when the number of elements is known and direct index access is important.


#heading(level: 2)[The cost of an insertion]


Contiguity is what makes access cheap, and it is also what makes insertion expensive. To place a value in the middle of a full-to-the-left array, every element from that position onwards must move up one slot to open a gap (#ref(label("fig:array-insert"), supplement: [Figure])). Deletion is the mirror image: the survivors must close the gap.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/7a140d4e4a516857.cetz.json")], caption: [Inserting 99 at index 2. Because the elements must stay contiguous, the tail of the array shifts right one position before the new value can be written. Insertion near the front of a large array therefore costs $O \( n \)$ moves, even though #emph[finding] index 2 costs nothing.]) <fig:array-insert>


#heading(level: 2)[Array access vs later pointer-based access]


The next chapter introduces linked lists. The contrast begins here.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Question], [Array], [Linked-list preview],),
    table.hline(),
    [How do I reach item 4?], [Use an index directly.], [Start at the head and follow links.],
    [Memory layout], [Contiguous.], [Non-contiguous is allowed.],
    [Size], [Typically fixed for a raw C++ array.], [Nodes can be allocated dynamically.],
    [Extra pointer memory], [Not needed per element.], [Required for links.],
  )]
  , kind: table
  )


#heading(level: 2)[Matrix multiplication as a lab-style problem]


The Week II material explicitly points to multi-dimensional array problems such as matrix multiplication. If $A$ is $m times k$ and $B$ is $k times n$, then the product $C$ is $m times n$ with $ C \[ i \] \[ j \] = sum_(t = 0)^(k - 1) A \[ i \] \[ t \] B \[ t \] \[ j \] . $

#code-block("for (int i = 0; i < m; ++i) {\n    for (int j = 0; j < n; ++j) {\n        C[i][j] = 0;\n        for (int t = 0; t < k; ++t) {\n            C[i][j] += A[i][t] * B[t][j];\n        }\n    }\n}", lang: "text")

#callout("clarification", title: [Clarification])[The matrix-multiplication formula and loop structure are an implementation expansion of the Week II lab prompt, which asks for multidimensional-array problems such as matrix multiplication but does not spell out the algorithm.]

#callout("pitfall", title: [Common mistake])[Do not confuse an index with the stored value. In the array `[12,25,18,30,22]`, index 3 is the position and 30 is the value at that position.]

#callout("quickcheck", title: [Check your understanding])[For a $4 times 5$ integer matrix, what do the two indexes in `A[2][4]` represent? Why can a raw array element be accessed directly without walking through earlier elements?]
