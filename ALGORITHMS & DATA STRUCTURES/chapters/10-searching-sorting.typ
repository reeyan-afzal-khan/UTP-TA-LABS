#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-searching-sorting")

= Searching and Sorting <ch:search-sort>

#chapterguide[Know arrays, tree/heap concepts, and the Big-O notation used throughout earlier chapters.][trace linear and binary search, distinguish internal and external sorting, explain bubble/insertion/selection/merge/quick/heap sort at the level of the slides, and compare their stated running-time behavior.]

Searching retrieves an element from a data structure. Sorting rearranges data into a specified order. The Searching & Sorting deck places these topics together because sorted order can make some searches much faster.

== Linear search

Linear search checks elements one by one until the target is found or the sequence ends.

```cpp
    for (int i = 0; i < static_cast<int>(a.size()); ++i) {
        if (a[i] == target) return i;
    }
    return -1;
}
```

The slides give linear search time complexity as $O(n)$ because the whole array may need to be traversed.

#example[
  Search for 30 in $[12,25,18,30,22]$. Compare with 12, 25, 18, then 30. The target is found at index 3 after four comparisons.
]

== Binary search

Binary search requires the array to be sorted. It compares the target with the middle element, then discards the half that cannot contain the target.

```cpp
    int left = 0;
    int right = static_cast<int>(a.size()) - 1;

    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (a[mid] == target) return mid;
        if (target < a[mid]) right = mid - 1;
        else left = mid + 1;
    }
    return -1;
}
```

The slides give binary search time complexity as $O(log n)$.

#note[
  Binary search gains speed by using sorted order. Without sorted order, the “discard half” decision is not valid.
]

#figref(<fig:binary-search>) traces the collapse of the search window. Each comparison removes
half of what remains, so a 16-element array needs at most 4 comparisons and a million-element
array at most 20. That is the whole difference between #cxr[$O(n)$] and #cxg[$O(log n)$].

#utpfig([Binary search for 23 in a sorted 10-element array. Greyed cells have been eliminated without ever being examined --- three comparisons rule out nine of the ten positions.], label: <fig:binary-search>)[
  #canvas({
    let vals = (2, 5, 8, 12, 16, 23, 38, 56, 72, 91)
    draw.scope({
      node((-0.65, 0), [#strong[1\.]], font: font("small"), ..utplabel, anchor: "east", align: right)
      for (i, vv) in vals.enumerate() {
        if i == 4 {
          node((0.9 * i, 0), [#vv], font: font("small"), ..utphot, min-width: 0.86, min-height: 0.72)
        } else {
          node((0.9 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 0.86, min-height: 0.72)
        }
      }
      node((8.55, 0), [mid $=16$, $23>16$ $arrow.r.double$ keep right], font: font("small"), ..utplabel, anchor: "west", text: orange)
    })
    draw.scope({
      draw.translate((0, -1.15))
      node((-0.65, 0), [#strong[2\.]], font: font("small"), ..utplabel, anchor: "east", align: right)
      for (i, vv) in vals.enumerate() {
        if i < 5 {
          node((0.9 * i, 0), [#vv], font: font("small"), ..utpdim, min-width: 0.86, min-height: 0.72)
        } else {
          if i == 7 {
            node((0.9 * i, 0), [#vv], font: font("small"), ..utphot, min-width: 0.86, min-height: 0.72)
          } else {
            node((0.9 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 0.86, min-height: 0.72)
          }
        }
      }
      node((8.55, 0), [mid $=56$, $23<56$ $arrow.r.double$ keep left], font: font("small"), ..utplabel, anchor: "west", text: orange)
    })
    draw.scope({
      draw.translate((0, -2.3))
      node((-0.65, 0), [#strong[3\.]], font: font("small"), ..utplabel, anchor: "east", align: right)
      for (i, vv) in vals.enumerate() {
        if i == 5 {
          node((0.9 * i, 0), [#vv], font: font("small"), ..utpdone, min-width: 0.86, min-height: 0.72)
        } else {
          node((0.9 * i, 0), [#vv], font: font("small"), ..utpdim, min-width: 0.86, min-height: 0.72)
        }
      }
      node((8.55, 0), [mid $=23$: found at index 5], font: font("small"), ..utplabel, anchor: "west", text: green)
    })
  })
]

== Sorting categories

The slide deck distinguishes two broad contexts.

#describe-nextline(1.35in)[
  / Internal sorting: All data to be sorted is placed in memory.
  / External sorting: The full dataset cannot be placed in memory at once; the method must work with data that is partly external to memory.
]

The rest of the deck focuses on named sorting algorithms rather than external-sorting implementation details.

== Bubble sort

Bubble sort is comparison-based. Adjacent elements are compared and swapped when they are out of order.

```cpp
    int n = static_cast<int>(a.size());
    for (int pass = 0; pass < n - 1; ++pass) {
        for (int i = 0; i < n - 1 - pass; ++i) {
            if (a[i] > a[i + 1]) {
                swap(a[i], a[i + 1]);
            }
        }
    }
}
```

The slide states $O(n^2)$ time and notes that bubble sort is not suitable for large data sizes.

The name describes the motion: on each pass the largest remaining value is carried to the
right-hand end, the way a bubble rises (#figref(<fig:bubble>)). After pass $k$ the last $k$
positions are finished, which is why the inner loop shrinks each time.

#utpfig([One full pass of bubble sort over $[5,1,4,2]$. Each adjacent pair is compared and swapped when out of order; by the end of the pass the maximum, 5, has been pushed into its final position. Three more passes finish the array.], label: <fig:bubble>)[
  #canvas({
    for (r, (row, lbl)) in (((5, 1, 4, 2), [compare 5 & 1: swap]), ((1, 5, 4, 2), [compare 5 & 4: swap]), ((1, 4, 5, 2), [compare 5 & 2: swap]), ((1, 4, 2, 5), [pass complete])).enumerate() {
      draw.scope({
        draw.translate((0, -0.95 * r))
        for (i, vv) in row.enumerate() {
          if r == 3 {
            if i == 3 {
              node((0.85 * i, 0), [#vv], font: font("small"), ..utpdone, min-width: 0.8, min-height: 0.66)
            } else {
              node((0.85 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 0.8, min-height: 0.66)
            }
          } else {
            if i == r {
              node((0.85 * i, 0), [#vv], font: font("small"), ..utphot, min-width: 0.8, min-height: 0.66)
            } else {
              let nx = int(r + 1)
              if i == nx {
                node((0.85 * i, 0), [#vv], font: font("small"), ..utphot, min-width: 0.8, min-height: 0.66)
              } else {
                node((0.85 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 0.8, min-height: 0.66)
              }
            }
          }
        }
        node((3.05, 0), [#lbl], font: font("small"), ..utplabel, anchor: "west")
      })
    }
    node((6.1, -2.85), [5 is now in place], font: font("small"), ..utplabel, anchor: "west", text: green)
  })
]

== Insertion sort

Insertion sort maintains a sorted subarray and inserts the next element into its proper location in that sorted part.

```cpp
    for (int i = 1; i < static_cast<int>(a.size()); ++i) {
        int key = a[i];
        int j = i - 1;

        while (j >= 0 && a[j] > key) {
            a[j + 1] = a[j];
            --j;
        }
        a[j + 1] = key;
    }
}
```

The slides state worst-case $O(n^2)$ and give $O(n)$ comparisons in the best case versus $O(n^2)$ in the worst case.

#utpfig([Insertion sort on $[5,1,4,2]$. The green region on the left is always sorted; each step lifts the next value out and slides it back until it lands in order. The lifted value is shown above the array while the gap it left is being shifted.], label: <fig:insertion>)[
  #canvas({
    for (r, (sorted, rest, key, lbl)) in ((("5",), ("1", "4", "2"), "1", "take 1, slide 5 right"), (("1", "5"), ("4", "2"), "4", "take 4, slide 5 right"), (("1", "4", "5"), ("2",), "2", "take 2, slide 5 and 4 right"), (("1", "2", "4", "5"), (), none, "sorted")).enumerate() {
      draw.scope({
        draw.translate((0, -1.82 * r))
        let ns = int(r + 1)
        for (i, vv) in sorted.enumerate() {
          node((0.85 * i, 0), [#vv], font: font("small"), ..utpdone, min-width: 0.8, min-height: 0.66)
        }
        if rest == none or rest == "" {
        } else {
          for (j, vv) in rest.enumerate() {
            let pos = int(ns + j)
            node((0.85 * pos, 0), [#vv], font: font("small"), ..utpcell, min-width: 0.8, min-height: 0.66)
          }
        }
        if key == none or key == "" {
        } else {
          node((0.85 * ns, 1.02), [#key], font: font("small"), ..utphot, min-width: 0.8, min-height: 0.66)
          connect((0.85 * ns, 0.38), (0.85 * ns, 0.65), ..utpptr, draw: orange)
        }
        node((3.05, 0), [#lbl], font: font("small"), ..utplabel, anchor: "west")
      })
    }
    node((5.3, -5.46), [green $=$ sorted region, \
  which grows by one each step], font: font("small"), ..utplabel, anchor: "west", align: left, text: green)
  })
]

#figref(<fig:insertion>) shows why the best case is so much better than the worst. The inner `while` loop stops as soon as it meets a smaller value, so on already-sorted input it never executes at all and the algorithm makes a single sweep. This is the same reason insertion sort is the method of choice for small or nearly-sorted arrays.

== Selection sort

Selection sort divides the list into a sorted part on the left and an unsorted part on the right. At each step, it finds the smallest element in the unsorted region and swaps it into the next sorted position.

```cpp
    int n = static_cast<int>(a.size());
    for (int i = 0; i < n - 1; ++i) {
        int minPos = i;
        for (int j = i + 1; j < n; ++j) {
            if (a[j] < a[minPos]) minPos = j;
        }
        swap(a[i], a[minPos]);
    }
}
```

The slide gives average and worst-case complexity $O(n^2)$ and says the method is not suitable for large datasets.

Insertion and selection sort both grow a sorted region on the left, but they pay for it
differently (#figref(<fig:selection>)). Selection sort scans the whole unsorted region to find
the minimum, then performs exactly one swap; insertion sort takes whatever value comes next
and pays with shifts. Selection sort therefore always makes $n-1$ swaps regardless of the
input, which matters when a swap is expensive.

#utpfig([Selection sort on $[5,1,4,2]$. Each pass scans the unsorted region for its smallest value and swaps it into the boundary position. Unlike insertion sort, the number of comparisons is the same whether the input is sorted or reversed.], label: <fig:selection>)[
  #canvas({
    for (r, (row, ndone, minpos, lbl)) in (((5, 1, 4, 2), 0, 1, "min of all four is 1: swap into slot 0"), ((1, 5, 4, 2), 1, 3, "min of the rest is 2: swap into slot 1"), ((1, 2, 4, 5), 2, 2, "min of the rest is 4: already in place"), ((1, 2, 4, 5), 4, 9, "sorted")).enumerate() {
      draw.scope({
        draw.translate((0, -0.95 * r))
        for (i, vv) in row.enumerate() {
          if i < ndone {
            node((0.85 * i, 0), [#vv], font: font("small"), ..utpdone, min-width: 0.8, min-height: 0.66)
          } else {
            if i == minpos {
              node((0.85 * i, 0), [#vv], font: font("small"), ..utphot, min-width: 0.8, min-height: 0.66)
            } else {
              node((0.85 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 0.8, min-height: 0.66)
            }
          }
        }
        node((3.05, 0), [#lbl], font: font("small"), ..utplabel, anchor: "west")
      })
    }
  })
]

== Merge sort

Merge sort follows divide and conquer. The slide description repeatedly divides the array into two halves until subarrays contain one element, then merges sorted subarrays to build the complete sorted array.

#utpfig([Merge sort on $[8,3,6,2,7,1,5,4]$. The array is halved until every piece has one element --- which is trivially sorted --- and the pieces are then merged back in order. The tree has $log n$ levels and each level does $O(n)$ work merging, which is where $O(n log n)$ comes from.], label: <fig:merge-sort>)[
  #canvas(x: 1.35cm, {
    let msb = (draw: blue, fill: pale-blue, rounded: 1mm, min-width: 0.72, min-height: 0.62, font: font("script", weight: "bold", fill: navy), inner-xsep: 3.9851pt, inner-ysep: 2.9888pt)
    let msg = (draw: green, fill: pale-teal, rounded: 1mm, min-width: 0.72, min-height: 0.62, font: font("script", weight: "bold", fill: navy), inner-xsep: 3.9851pt, inner-ysep: 2.9888pt)
    node((0, 0), [8 3 6 2 7 1 5 4], name: "l0", font: font("small"), ..msb)
    node((-2.3, -1), [8 3 6 2], name: "l1a", font: font("small"), ..msb)
    node((2.3, -1), [7 1 5 4], name: "l1b", font: font("small"), ..msb)
    node((-3.45, -2), [8 3], name: "l2a", font: font("small"), ..msb)
    node((-1.15, -2), [6 2], name: "l2b", font: font("small"), ..msb)
    node((1.15, -2), [7 1], name: "l2c", font: font("small"), ..msb)
    node((3.45, -2), [5 4], name: "l2d", font: font("small"), ..msb)
    for (x, vv) in ((-4.02, 8), (-2.88, 3), (-1.72, 6), (-0.58, 2), (0.58, 7), (1.72, 1), (2.88, 5), (4.02, 4)) {
      node((x, -3), [#vv], font: font("small"), ..msb)
    }
    connect("l0", "l1a", ..utparrow)
    connect("l0", "l1b", ..utparrow)
    connect("l1a", "l2a", ..utparrow)
    connect("l1a", "l2b", ..utparrow)
    connect("l1b", "l2c", ..utparrow)
    connect("l1b", "l2d", ..utparrow)
    for (p, x) in (("l2a", -4.02), ("l2a", -2.88), ("l2b", -1.72), ("l2b", -0.58), ("l2c", 0.58), ("l2c", 1.72), ("l2d", 2.88), ("l2d", 4.02)) {
      connect(p, (x, -2.75), ..utparrow)
    }
    node((0, 1.05), [DIVIDE], font: font("small"), ..utptag, align: center, text: blue)
    node((0, 0.68), [$log_2 n$ levels], font: font("small"), ..utplabel, align: center, text: blue)
    draw.scope({
      draw.translate((0, -8.1))
      for (x, vv) in ((-4.02, 8), (-2.88, 3), (-1.72, 6), (-0.58, 2), (0.58, 7), (1.72, 1), (2.88, 5), (4.02, 4)) {
        node((x, 0), [#vv], font: font("small"), ..msg)
      }
      node((-3.45, 1), [3 8], name: "m2a", font: font("small"), ..msg)
      node((-1.15, 1), [2 6], name: "m2b", font: font("small"), ..msg)
      node((1.15, 1), [1 7], name: "m2c", font: font("small"), ..msg)
      node((3.45, 1), [4 5], name: "m2d", font: font("small"), ..msg)
      node((-2.3, 2), [2 3 6 8], name: "m1a", font: font("small"), ..msg)
      node((2.3, 2), [1 4 5 7], name: "m1b", font: font("small"), ..msg)
      node((0, 3), [1 2 3 4 5 6 7 8], name: "m0", font: font("small"), ..msg)
      for (p, x) in (("m2a", -4.02), ("m2a", -2.88), ("m2b", -1.72), ("m2b", -0.58), ("m2c", 0.58), ("m2c", 1.72), ("m2d", 2.88), ("m2d", 4.02)) {
        connect((x, 0.28), p, line-width: widths.thick, draw: green, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
      }
      connect("m2a", "m1a", line-width: widths.thick, draw: green, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m2b", "m1a", line-width: widths.thick, draw: green, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m2c", "m1b", line-width: widths.thick, draw: green, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m2d", "m1b", line-width: widths.thick, draw: green, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m1a", "m0", line-width: widths.thick, draw: green, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m1b", "m0", line-width: widths.thick, draw: green, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
      node((0, 3.95), [MERGE], font: font("small"), ..utptag, align: center, text: green)
      node((0, 3.58), [$O(n)$ work per level], font: font("small"), ..utplabel, align: center, text: green)
    })
  })
]

#note[
  The supplied merge-sort slide explains the divide-and-conquer process but does not state a time complexity. Standard analysis gives $O(n log n)$ time; that value is additional context rather than text copied from the slide.
]

== Quick sort

Quick sort also follows divide and conquer. The deck describes partitioning the array around a #term[pivot]: values smaller than the pivot go to one side, values greater than the pivot to the other, then the resulting subarrays are sorted recursively.

```cpp
    int pivot = a[high];
    int i = low - 1;

    for (int j = low; j < high; ++j) {
        if (a[j] <= pivot) {
            ++i;
            swap(a[i], a[j]);
        }
    }
    swap(a[i + 1], a[high]);
    return i + 1;
}

void quickSort(vector<int>& a, int low, int high) {
    if (low >= high) return;
    int p = partition(a, low, high);
    quickSort(a, low, p - 1);
    quickSort(a, p + 1, high);
}
```

#figref(<fig:quick-partition>) traces one partition step. The pivot ends up at the index that
splits the array into “everything smaller” and “everything larger”, so the pivot is
placed correctly and never moves again. Quick sort then recurses on the two sides.

#utpfig([Partitioning $[7,2,9,4,6]$ around the pivot 6. The pointer `i` marks the end of the “smaller than pivot” region; each value at `j` that is smaller is swapped up into it. The final swap drops the pivot into the boundary, at which point index~2 holds its permanently correct value.], label: <fig:quick-partition>)[
  #canvas({
    for (r, (row, hot, lbl)) in (((7, 2, 9, 4, 6), 4, [pivot $=6$ (last element)]), ((2, 7, 9, 4, 6), 0, [$2<6$: swap into the small region]), ((2, 4, 9, 7, 6), 1, [$4<6$: swap into the small region]), ((2, 4, 6, 7, 9), 2, [place the pivot at the boundary])).enumerate() {
      draw.scope({
        draw.translate((0, -0.98 * r))
        for (i, vv) in row.enumerate() {
          if i == hot {
            node((0.87 * i, 0), [#vv], font: font("small"), ..utphot, min-width: 0.82, min-height: 0.68)
          } else {
            node((0.87 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 0.82, min-height: 0.68)
          }
        }
        node((4, 0), [#lbl], font: font("small"), ..utplabel, anchor: "west")
      })
    }
    draw.scope({
      draw.translate((0, -2.94))
      brace((-0.44, -0.38), (1.31, -0.38), mirror: true, amplitude: 3.4869pt, raise: 2.9888pt, draw: blue, line-width: widths.semithick)
      brace((2.19, -0.38), (3.93, -0.38), mirror: true, amplitude: 3.4869pt, raise: 2.9888pt, draw: red, line-width: widths.semithick)
      node((0.44, -0.78), [all $<6$], font: font("small"), ..utplabel, anchor: "north", text: blue)
      node((3.06, -0.78), [all $>6$], font: font("small"), ..utplabel, anchor: "north", text: red)
      node((1.74, -0.78), [6 is final], font: font("small"), ..utplabel, anchor: "north", text: green)
    })
  })
]

#note[
  The quick-sort slide says its “average and worst-case complexities are $O(n^2)$, respectively,” and gives best-case $O(n log n)$. Standard algorithm analysis is: best $O(n log n)$, average $O(n log n)$, and worst $O(n^2)$. The discrepancy is surfaced explicitly here rather than silently changing the source.
]

== Heap sort

The heap-sort slide connects sorting with the heap from Trees II. It describes building a min-heap or max-heap from the array, then repeatedly eliminating elements from the heap portion and inserting them into the sorted portion.

The slide states that heap sort is in-place and has time complexity $O(n log n)$.

```cpp
    int largest = i;
    int left = 2 * i + 1;
    int right = 2 * i + 2;

    if (left < n && a[left] > a[largest]) largest = left;
    if (right < n && a[right] > a[largest]) largest = right;

    if (largest != i) {
        swap(a[i], a[largest]);
        heapify(a, n, largest);
    }
}

void heapSort(vector<int>& a) {
    int n = static_cast<int>(a.size());
    for (int i = n / 2 - 1; i >= 0; --i)
        heapify(a, n, i);

    for (int end = n - 1; end > 0; --end) {
        swap(a[0], a[end]);
        heapify(a, end, 0);
    }
}
```

#pagebreak()

== Why the growth rate is what matters

Complexity classes are easy to treat as labels attached to algorithms. #figref(<fig:bigo>)
shows what they actually claim. For a handful of items the difference is invisible --- at
$n=10$ every one of these curves is small. The classes separate as $n$ grows, and they
separate violently.

#utpfig([Operation counts for the complexity classes in this chapter. At $n=100$ a quadratic algorithm already does roughly 15 times the work of an $n log n$ one; at $n=1000$ it does about 100 times as much. This is why bubble sort and merge sort are not interchangeable even though both sort correctly.], label: <fig:bigo>)[
  #canvas({
    axis(width: 11.2cm, height: 6.4cm, xlabel: [input size $n$], ylabel: [operations], xlabel-style: font("small", fill: muted), ylabel-style: font("small", fill: muted), tick-label-style: font("script", fill: muted), xmin: 1, xmax: 100, ymin: 0, ymax: 1000, axis-lines: "left", axis-line-style: (draw: mix(muted, 60%)), grid: "major", grid-style: (draw: pale-blue), legend-style: (size: font("script").size, draw: mix(blue, 30%), fill: white, at: (1.02, 1), anchor: "north-west"), legend-cell-align: "left", samples: 100, domain: (1, 100),
      addplot(line-width: widths.very-thick, draw: green, x => calc.ln(x) / calc.ln(2), legend: [$O(log n)$ binary search]),
      addplot(line-width: widths.very-thick, draw: blue, x => x, legend: [$O(n)$ linear search]),
      addplot(line-width: widths.very-thick, draw: teal, x => x * calc.ln(x) / calc.ln(2), legend: [$O(n log n)$ merge, heap]),
      addplot(line-width: widths.very-thick, draw: red, x => calc.pow(x, 2), legend: [$O(n^2)$ bubble, insertion]),
    )
  })
]

#note[
  Constant factors and hardware speed shift these curves up or down; they do not change their
  shape. A faster computer running an $O(n^2)$ sort still loses to a slower computer running an
  $O(n log n)$ sort once $n$ is large enough --- and “large enough” arrives sooner than most
  people expect.
]

== Algorithm comparison

#utptable[
  #tabularx(
    columns: (18%, 24%, 1fr),
    styles: (navy-bold,),
    header: ([Algorithm], [#shortstack[Complexity stated \
    in slides]], [Main slide idea]),
    [Linear search], [$O(n)$], [Check items one by one.],
    [Binary search], [$O(log n)$], [Sorted input; repeatedly choose one half.],
    [Bubble sort], [$O(n^2)$], [Swap adjacent out-of-order elements.],
    [Insertion sort], [Best comparisons $O(n)$; worst $O(n^2)$], [Insert into a growing sorted subarray.],
    [Selection sort], [Average/worst $O(n^2)$], [Select smallest remaining item.],
    [Merge sort], [Not stated], [Divide, sort halves, merge.],
    [Quick sort], [Slide wording has a complexity inconsistency], [Partition around a pivot and recurse.],
    [Heap sort], [$O(n log n)$], [Use heap ordering to extract elements.],
  )
]

=== Standard analysis for reference

The table above records what the slides state. The one below gives the conventional
textbook analysis of the same algorithms, including two properties the slides do not
discuss: extra space, and #term[stability] --- whether equal elements keep their original
relative order, which matters when sorting records by a secondary key.

#utptable[
  #tabularx(
    columns: (15.5%, 13.5%, 13.5%, 13.5%, 10%, 1fr),
    align: (left, center, center, center, center, left),
    styles: (navy-bold,),
    header: ([Algorithm], [Best], [Average], [Worst], [Space], [Stable]),
    [Bubble sort], [$O(n)$], [$O(n^2)$], [$O(n^2)$], [$O(1)$], [yes],
    [Insertion sort], [$O(n)$], [$O(n^2)$], [$O(n^2)$], [$O(1)$], [yes],
    [Selection sort], [$O(n^2)$], [$O(n^2)$], [$O(n^2)$], [$O(1)$], [no],
    [Merge sort], [$O(n log n)$], [$O(n log n)$], [$O(n log n)$], [$O(n)$], [yes],
    [Quick sort], [$O(n log n)$], [$O(n log n)$], [$O(n^2)$], [$O(log n)$], [no],
    [Heap sort], [$O(n log n)$], [$O(n log n)$], [$O(n log n)$], [$O(1)$], [no],
  )
]

#note[
  This table is standard algorithm analysis, not slide content. It is included because the
  slide deck states complexities inconsistently for quick sort and omits merge sort entirely.
  Where the two tables disagree, the discrepancy is the point: check which convention your
  assessment expects.

  Bubble and insertion sort reach $O(n)$ in the best case only because they can detect that
  the data is already ordered and stop early. Selection sort cannot: it must scan the entire
  unsorted region to be sure it has found the minimum, so its best case is no better than its
  worst.
]

#questions[
  Why does binary search require sorted data? Explain in one sentence how insertion sort and selection sort differ in the way they grow the sorted portion.
]
