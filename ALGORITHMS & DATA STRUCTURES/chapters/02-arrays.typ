#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-arrays")

= Arrays and Two-Dimensional Arrays <ch:arrays>

#chapterguide[Know the basic distinction between primitive and non-primitive data structures from #chapref(<ch:introduction>).][define an array, explain contiguous storage and index-based access, distinguish 1D and 2D arrays, trace row/column access, and solve matrix-style tasks with nested loops.]

An #term[array] stores a collection of similar data items of the same type. The Week II slides emphasize three properties: same-type elements, contiguous memory locations, and random access through index positions.

#note[
  Remember the sequence #strong[Store $arrow.r$ Access $arrow.r$ Process]. Arrays make the access step simple because an index identifies the position directly.
]

== What is an array?

Consider the one-dimensional array

$ [12, space 25, space 18, space 30, space 22]. $

Its indexes are $0,1,2,3,4$ in normal C++ indexing.

#utpfig([A one-dimensional array. The index is a position, not a value: index 3 and the value 30 are different things stored in different places.], label: <fig:array-1d>)[
  #canvas({
    for (i, vv) in (12, 25, 18, 30, 22).enumerate() {
      node((1.55 * i, 0), [#vv], name: "c" + str(i), ..utpcell, min-width: 1.5, min-height: 0.95)
      node((1.55 * i, -0.78), [index #i], ..utplabel)
    }
    node((-0.95, 0), [`A`], ..utplabel, anchor: "east")
    connect((-0.78, 0.62), (6.98, 0.62), ..utpbrace)
    node((3.1, 0.86), [5 elements, all `int`, stored back to back], ..utplabel, anchor: "south")
  })
]

=== Array properties from the slides

- Every element has the same data type and therefore the same element size.
- Elements are stored at contiguous memory locations.
- The first element occupies the smallest memory location in the block.
- An element can be accessed directly from its index because its address can be calculated from the base address and element size.

== Address calculation

The slides state that the address of an array element can be calculated from the base address and element size. A standard expression for a one-dimensional, zero-based array is

$ op("address")(A[i]) = op("base")(A) + i times op("sizeof")(A[0]). $

#example[
  If the base address is 1000 and each integer occupies 4 bytes, then the address of `A[3]` is

  $ 1000 + 3(4) = 1012. $

  This arithmetic is the reason direct index access does not require traversing the earlier elements.
]

#figref(<fig:array-memory>) shows why that single multiplication is the whole story. The
machine never looks at `A[0]`, `A[1]`, or `A[2]` on the way to
`A[3]`; it computes one address and reads it.

#utpfig([Contiguous storage turns indexing into arithmetic. Because every element is the same size, the address of any element is one multiply-and-add away from the base address --- so reaching `A[3]` costs the same as reaching `A[0]`.], label: <fig:array-memory>)[
  #canvas({
    for (i, vv) in (12, 25, 18, 30, 22).enumerate() {
      let addr = int(1000 + 4 * i)
      if i == 3 {
        node((1.68 * i, 0), [#vv], name: "m" + str(i), ..utphot, min-width: 1.62, min-height: 0.9)
      } else {
        node((1.68 * i, 0), [#vv], name: "m" + str(i), ..utpcell, min-width: 1.62, min-height: 0.9)
      }
      node((1.68 * i, -0.72), [#mono[#addr]], ..utplabel)
      node((1.68 * i, 0.75), [#mono[A\[#i\]]], ..utplabel)
    }
    node((-1.05, -0.72), [byte \
  address], ..utplabel, anchor: "east", align: right)
    brace((-0.86, -1.05), (5.9, -1.05), mirror: true, amplitude: 3.9851pt, raise: 1.9925pt, draw: orange, line-width: widths.semithick)
    node((2.5, -1.5), [offset $=3 times 4=12$ bytes#h(2em)address $=1000+12=1012$], ..utptag, anchor: "north", align: center)
  })
]

#note[
  The formula above is an explanatory expansion of the slide statement about base address and element size. The slides themselves do not provide a numeric address formula.
]

== One-dimensional vs two-dimensional arrays

A 1D array forms a single indexed sequence. A 2D array stores values in rows and columns and is commonly used for tables, grids, and matrices.

#utpfig([A $3 times 3$ array. The first index selects the row, the second selects the column, so `matrix[1][2]` is row~1, column~2 --- the value~6.], label: <fig:array-2d>)[
  #canvas({
    for r in range(0, 3) {
      for c in range(0, 3) {
        let vv = int(3 * r + c + 1)
        if r == 1 {
          if c == 2 {
            node((1.15 * c, -0.85 * r), [#vv], ..utphot, min-width: 1.15, min-height: 0.85)
          } else {
            node((1.15 * c, -0.85 * r), [#vv], ..utpcell, min-width: 1.15, min-height: 0.85)
          }
        } else {
          node((1.15 * c, -0.85 * r), [#vv], ..utpcell, min-width: 1.15, min-height: 0.85)
        }
      }
    }
    for c in range(0, 3) {
      node((1.15 * c, 0.68), [col #c], ..utplabel)
    }
    for r in range(0, 3) {
      node((-0.72, -0.85 * r), [row #r], ..utplabel, anchor: "east")
    }
    node((2.9, -0.85), [$arrow.l$ `matrix[1][2]` $=6$], ..utptag, anchor: "west", align: left)
  })
]

#note[
  A 2D array is a convenient #emph[notation]; memory itself is still one flat sequence of
  bytes. C++ stores the rows one after another, an arrangement called #term[row-major order]
  (#figref(<fig:row-major>)). This is why `matrix[r][c]` can still be resolved with
  arithmetic, and why walking a matrix row by row is friendlier to the cache than walking it
  column by column.
]

#utpfig([Row-major order: the rows of a two-dimensional array are laid end to end in linear memory. The element `matrix[r][c]` sits at flat offset $r times 3+c$, which is how two indices collapse back into one address.], label: <fig:row-major>)[
  #canvas({
    for i in range(0, 9) {
      let vv = int(i + 1)
      let r = int(int(i / 3))
      let st = none
      if r == 0 {
        st = utpcell
      }
      if r == 1 {
        st = utpdone
      }
      if r == 2 {
        st = utphot
      }
      node((0.94 * i, 0), [#vv], name: "f" + str(i), ..st, min-width: 0.92, min-height: 0.8)
      node((0.94 * i, -0.66), [#i], ..utplabel)
    }
    brace((-0.45, 0.44), (2.33, 0.44), amplitude: 3.4869pt, raise: 1.9925pt, draw: blue, line-width: widths.semithick)
    brace((2.37, 0.44), (5.15, 0.44), amplitude: 3.4869pt, raise: 1.9925pt, draw: green, line-width: widths.semithick)
    brace((5.19, 0.44), (7.97, 0.44), amplitude: 3.4869pt, raise: 1.9925pt, draw: orange, line-width: widths.semithick)
    node((0.94, 0.72), [row 0], ..utplabel, anchor: "south", text: blue)
    node((3.76, 0.72), [row 1], ..utplabel, anchor: "south", text: green)
    node((6.58, 0.72), [row 2], ..utplabel, anchor: "south", text: orange)
    node((3.76, -1), [flat offset $=r times "(number of columns)"+c$], ..utplabel, anchor: "north", align: center)
  })
]

In C++:

```cpp
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9}
};

cout << matrix[1][2];   // 6
```

The first index chooses the row; the second chooses the column.

== Processing a 2D array with nested loops

The Week II summary explicitly connects 2D arrays with nested loops.

```cpp
    for (int c = 0; c < 3; ++c) {
        cout << matrix[r][c] << ' ';
    }
    cout << '\n';
}
```

The outer loop changes rows, while the inner loop visits the columns within the current row.

#example[
  To compute the sum of every element in a $3 times 3$ matrix, initialize `sum = 0`, visit each pair `[r][c]`, and add the value. The traversal touches each matrix cell once.
]

== Why arrays are useful

The Week II slides give three practical motivations:

- multiple values can be stored under one variable name;
- multiple values can be processed quickly and systematically;
- searching and sorting operations can be applied naturally to the indexed sequence.

Arrays are especially useful when the number of elements is known and direct index access is important.

== The cost of an insertion

Contiguity is what makes access cheap, and it is also what makes insertion expensive.
To place a value in the middle of a full-to-the-left array, every element from that
position onwards must move up one slot to open a gap
(#figref(<fig:array-insert>)). Deletion is the mirror image: the survivors must close the gap.

#utpfig([Inserting 99 at index 2. Because the elements must stay contiguous, the tail of the array shifts right one position before the new value can be written. Insertion near the front of a large array therefore costs #cxr[$O(n)$] moves, even though #emph[finding] index 2 costs nothing.], label: <fig:array-insert>)[
  #canvas({
    node((-0.7, 0), [before], ..utplabel, anchor: "east")
    for (i, vv) in (12, 25, 18, 30, 22).enumerate() {
      node((1.05 * i, 0), [#vv], name: "b" + str(i), ..utpcell, min-width: 1, min-height: 0.8)
    }
    node((5.25, 0), [], ..utpdim, min-width: 1, min-height: 0.8)
    for i in range(0, 6) {
      node((1.05 * i, -0.62), [#i], ..utplabel)
    }
    for i in range(2, 5) {
      let x = 1.05 * i
      connect((x, -1.15), (rel: (1.05, 0), to: (x, -1.15)), ..utparrow)
    }
    node((1.6, -1.15), [shift $arrow.r$], ..utptag, anchor: "east")
    draw.scope({
      draw.translate((0, -2.3))
      node((-0.7, 0), [after], ..utplabel, anchor: "east")
      node((0, 0), [12], ..utpcell, min-width: 1, min-height: 0.8)
      node((1.05, 0), [25], ..utpcell, min-width: 1, min-height: 0.8)
      node((2.1, 0), [99], ..utphot, min-width: 1, min-height: 0.8)
      node((3.15, 0), [18], ..utpdone, min-width: 1, min-height: 0.8)
      node((4.2, 0), [30], ..utpdone, min-width: 1, min-height: 0.8)
      node((5.25, 0), [22], ..utpdone, min-width: 1, min-height: 0.8)
      for i in range(0, 6) {
        node((1.05 * i, -0.62), [#i], ..utplabel)
      }
      node((6, 0), [3 elements moved], ..utptag, anchor: "west")
    })
  })
]

== Array access vs later pointer-based access

The next chapter introduces linked lists. The contrast begins here.

#utptable[
  #tabularx(
    columns: (22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Question], [Array], [Linked-list preview]),
    [How do I reach item 4?], [Use an index directly.], [Start at the head and follow links.],
    [Memory layout], [Contiguous.], [Non-contiguous is allowed.],
    [Size], [Typically fixed for a raw C++ array.], [Nodes can be allocated dynamically.],
    [Extra pointer memory], [Not needed per element.], [Required for links.],
  )
]

== Matrix multiplication as a lab-style problem

The Week II material explicitly points to multi-dimensional array problems such as matrix multiplication. If $A$ is $m times k$ and $B$ is $k times n$, then the product $C$ is $m times n$ with

$ C[i][j] = sum _(t=0)^(k-1) A[i][t]B[t][j]. $

```cpp
    for (int j = 0; j < n; ++j) {
        C[i][j] = 0;
        for (int t = 0; t < k; ++t) {
            C[i][j] += A[i][t] * B[t][j];
        }
    }
}
```

#note[
  The matrix-multiplication formula and loop structure are an implementation expansion of the Week II lab prompt, which asks for multidimensional-array problems such as matrix multiplication but does not spell out the algorithm.
]

#warning[
  Do not confuse an index with the stored value. In the array `[12,25,18,30,22]`, index 3 is the position and 30 is the value at that position.
]

#questions[
  For a $4 times 5$ integer matrix, what do the two indexes in `A[2][4]` represent? Why can a raw array element be accessed directly without walking through earlier elements?
]
