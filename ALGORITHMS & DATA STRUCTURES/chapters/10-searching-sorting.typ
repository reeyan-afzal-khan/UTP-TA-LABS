#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-searching-sorting")


#heading(level: 1)[Searching and Sorting]
<ch:search-sort>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know arrays, tree/heap concepts, and the Big-O notation used throughout earlier chapters.

*By the end, you can:* trace linear and binary search, distinguish internal and external sorting, explain bubble/insertion/selection/merge/quick/heap sort at the level of the slides, and compare their stated running-time behavior.]

Searching retrieves an element from a data structure. Sorting rearranges data into a specified order. The Searching & Sorting deck places these topics together because sorted order can make some searches much faster.


#heading(level: 2)[Linear search]


Linear search checks elements one by one until the target is found or the sequence ends.

#code-block("int linearSearch(const vector<int>& a, int target) {\n    for (int i = 0; i < static_cast<int>(a.size()); ++i) {\n        if (a[i] == target) return i;\n    }\n    return -1;\n}", lang: "text")

The slides give linear search time complexity as $O \( n \)$ because the whole array may need to be traversed.

#callout("workedexample", title: [Worked example])[Search for 30 in $\[ 12 \, 25 \, 18 \, 30 \, 22 \]$. Compare with 12, 25, 18, then 30. The target is found at index 3 after four comparisons.]


#heading(level: 2)[Binary search]


Binary search requires the array to be sorted. It compares the target with the middle element, then discards the half that cannot contain the target.

#code-block("int binarySearch(const vector<int>& a, int target) {\n    int left = 0;\n    int right = static_cast<int>(a.size()) - 1;\n\n    while (left <= right) {\n        int mid = left + (right - left) / 2;\n        if (a[mid] == target) return mid;\n        if (target < a[mid]) right = mid - 1;\n        else left = mid + 1;\n    }\n    return -1;\n}", lang: "text")

The slides give binary search time complexity as $O \( log n \)$.

#callout("keyidea", title: [Key idea])[Binary search gains speed by using sorted order. Without sorted order, the "discard half" decision is not valid.]

#ref(label("fig:binary-search"), supplement: [Figure]) traces the collapse of the search window. Each comparison removes half of what remains, so a 16-element array needs at most 4 comparisons and a million-element array at most 20. That is the whole difference between $O \( n \)$ and $O \( log n \)$.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/fd2b418e295d41e2.cetz.json")], caption: [Binary search for 23 in a sorted 10-element array. Greyed cells have been eliminated without ever being examined --- three comparisons rule out nine of the ten positions.]) <fig:binary-search>


#heading(level: 2)[Sorting categories]


The slide deck distinguishes two broad contexts.

/ Internal sorting: #block[
All data to be sorted is placed in memory.
]

/ External sorting: #block[
The full dataset cannot be placed in memory at once; the method must work with data that is partly external to memory.
]

The rest of the deck focuses on named sorting algorithms rather than external-sorting implementation details.


#heading(level: 2)[Bubble sort]


Bubble sort is comparison-based. Adjacent elements are compared and swapped when they are out of order.

#code-block("void bubbleSort(vector<int>& a) {\n    int n = static_cast<int>(a.size());\n    for (int pass = 0; pass < n - 1; ++pass) {\n        for (int i = 0; i < n - 1 - pass; ++i) {\n            if (a[i] > a[i + 1]) {\n                swap(a[i], a[i + 1]);\n            }\n        }\n    }\n}", lang: "text")

The slide states $O \( n^2 \)$ time and notes that bubble sort is not suitable for large data sizes.

The name describes the motion: on each pass the largest remaining value is carried to the right-hand end, the way a bubble rises (#ref(label("fig:bubble"), supplement: [Figure])). After pass $k$ the last $k$ positions are finished, which is why the inner loop shrinks each time.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/c08bfca4b3982114.cetz.json")], caption: [One full pass of bubble sort over $\[ 5 \, 1 \, 4 \, 2 \]$. Each adjacent pair is compared and swapped when out of order; by the end of the pass the maximum, 5, has been pushed into its final position. Three more passes finish the array.]) <fig:bubble>


#heading(level: 2)[Insertion sort]


Insertion sort maintains a sorted subarray and inserts the next element into its proper location in that sorted part.

#code-block("void insertionSort(vector<int>& a) {\n    for (int i = 1; i < static_cast<int>(a.size()); ++i) {\n        int key = a[i];\n        int j = i - 1;\n\n        while (j >= 0 && a[j] > key) {\n            a[j + 1] = a[j];\n            --j;\n        }\n        a[j + 1] = key;\n    }\n}", lang: "text")

The slides state worst-case $O \( n^2 \)$ and give $O \( n \)$ comparisons in the best case versus $O \( n^2 \)$ in the worst case.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/d6ec59eab732ba3d.cetz.json")], caption: [Insertion sort on $\[ 5 \, 1 \, 4 \, 2 \]$. The green region on the left is always sorted; each step lifts the next value out and slides it back until it lands in order. The lifted value is shown above the array while the gap it left is being shifted.]) <fig:insertion>

#ref(label("fig:insertion"), supplement: [Figure]) shows why the best case is so much better than the worst. The inner `while` loop stops as soon as it meets a smaller value, so on already-sorted input it never executes at all and the algorithm makes a single sweep. This is the same reason insertion sort is the method of choice for small or nearly-sorted arrays.


#heading(level: 2)[Selection sort]


Selection sort divides the list into a sorted part on the left and an unsorted part on the right. At each step, it finds the smallest element in the unsorted region and swaps it into the next sorted position.

#code-block("void selectionSort(vector<int>& a) {\n    int n = static_cast<int>(a.size());\n    for (int i = 0; i < n - 1; ++i) {\n        int minPos = i;\n        for (int j = i + 1; j < n; ++j) {\n            if (a[j] < a[minPos]) minPos = j;\n        }\n        swap(a[i], a[minPos]);\n    }\n}", lang: "text")

The slide gives average and worst-case complexity $O \( n^2 \)$ and says the method is not suitable for large datasets.

Insertion and selection sort both grow a sorted region on the left, but they pay for it differently (#ref(label("fig:selection"), supplement: [Figure])). Selection sort scans the whole unsorted region to find the minimum, then performs exactly one swap; insertion sort takes whatever value comes next and pays with shifts. Selection sort therefore always makes $n - 1$ swaps regardless of the input, which matters when a swap is expensive.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/086aa461ad861387.cetz.json")], caption: [Selection sort on $\[ 5 \, 1 \, 4 \, 2 \]$. Each pass scans the unsorted region for its smallest value and swaps it into the boundary position. Unlike insertion sort, the number of comparisons is the same whether the input is sorted or reversed.]) <fig:selection>


#heading(level: 2)[Merge sort]


Merge sort follows divide and conquer. The slide description repeatedly divides the array into two halves until subarrays contain one element, then merges sorted subarrays to build the complete sorted array.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/0dbba20feae54e31.cetz.json")], caption: [Merge sort on $\[ 8 \, 3 \, 6 \, 2 \, 7 \, 1 \, 5 \, 4 \]$. The array is halved until every piece has one element --- which is trivially sorted --- and the pieces are then merged back in order. The tree has $log n$ levels and each level does $O \( n \)$ work merging, which is where $O \( n log n \)$ comes from.]) <fig:merge-sort>

#callout("clarification", title: [Clarification])[The supplied merge-sort slide explains the divide-and-conquer process but does not state a time complexity. Standard analysis gives $O \( n log n \)$ time; that value is additional context rather than text copied from the slide.]


#heading(level: 2)[Quick sort]


Quick sort also follows divide and conquer. The deck describes partitioning the array around a #strong[pivot]: values smaller than the pivot go to one side, values greater than the pivot to the other, then the resulting subarrays are sorted recursively.

#code-block("int partition(vector<int>& a, int low, int high) {\n    int pivot = a[high];\n    int i = low - 1;\n\n    for (int j = low; j < high; ++j) {\n        if (a[j] <= pivot) {\n            ++i;\n            swap(a[i], a[j]);\n        }\n    }\n    swap(a[i + 1], a[high]);\n    return i + 1;\n}\n\nvoid quickSort(vector<int>& a, int low, int high) {\n    if (low >= high) return;\n    int p = partition(a, low, high);\n    quickSort(a, low, p - 1);\n    quickSort(a, p + 1, high);\n}", lang: "text")

#ref(label("fig:quick-partition"), supplement: [Figure]) traces one partition step. The pivot ends up at the index that splits the array into "everything smaller" and "everything larger", so the pivot is placed correctly and never moves again. Quick sort then recurses on the two sides.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/03e2a81b8f3b5de0.cetz.json")], caption: [Partitioning $\[ 7 \, 2 \, 9 \, 4 \, 6 \]$ around the pivot 6. The pointer `i` marks the end of the "smaller than pivot" region; each value at `j` that is smaller is swapped up into it. The final swap drops the pivot into the boundary, at which point index~2 holds its permanently correct value.]) <fig:quick-partition>

#callout("clarification", title: [Clarification])[The quick-sort slide says its "average and worst-case complexities are $O \( n^2 \)$, respectively," and gives best-case $O \( n log n \)$. Standard algorithm analysis is: best $O \( n log n \)$, average $O \( n log n \)$, and worst $O \( n^2 \)$. The discrepancy is surfaced explicitly here rather than silently changing the source.]


#heading(level: 2)[Heap sort]


The heap-sort slide connects sorting with the heap from Trees II. It describes building a min-heap or max-heap from the array, then repeatedly eliminating elements from the heap portion and inserting them into the sorted portion.

The slide states that heap sort is in-place and has time complexity $O \( n log n \)$.

#code-block("void heapify(vector<int>& a, int n, int i) {\n    int largest = i;\n    int left = 2 * i + 1;\n    int right = 2 * i + 2;\n\n    if (left < n && a[left] > a[largest]) largest = left;\n    if (right < n && a[right] > a[largest]) largest = right;\n\n    if (largest != i) {\n        swap(a[i], a[largest]);\n        heapify(a, n, largest);\n    }\n}\n\nvoid heapSort(vector<int>& a) {\n    int n = static_cast<int>(a.size());\n    for (int i = n / 2 - 1; i >= 0; --i)\n        heapify(a, n, i);\n\n    for (int end = n - 1; end > 0; --end) {\n        swap(a[0], a[end]);\n        heapify(a, end, 0);\n    }\n}", lang: "text")


#heading(level: 2)[Why the growth rate is what matters]


Complexity classes are easy to treat as labels attached to algorithms. #ref(label("fig:bigo"), supplement: [Figure]) shows what they actually claim. For a handful of items the difference is invisible --- at $n = 10$ every one of these curves is small. The classes separate as $n$ grows, and they separate violently.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/59b6a7154433c414.cetz.json")], caption: [Operation counts for the complexity classes in this chapter. At $n = 100$ a quadratic algorithm already does roughly 15 times the work of an $n log n$ one; at $n = 1000$ it does about 100 times as much. This is why bubble sort and merge sort are not interchangeable even though both sort correctly.]) <fig:bigo>

#callout("keyidea", title: [Key idea])[Constant factors and hardware speed shift these curves up or down; they do not change their shape. A faster computer running an $O \( n^2 \)$ sort still loses to a slower computer running an $O \( n log n \)$ sort once $n$ is large enough --- and "large enough" arrives sooner than most people expect.]


#heading(level: 2)[Algorithm comparison]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    [Algorithm], [], [],
    [in slides], [Main slide idea], [],
    [Linear search], [$O \( n \)$], [Check items one by one.],
    [Binary search], [$O \( log n \)$], [Sorted input; repeatedly choose one half.],
    [Bubble sort], [$O \( n^2 \)$], [Swap adjacent out-of-order elements.],
    [Insertion sort], [Best comparisons $O \( n \)$; worst $O \( n^2 \)$], [Insert into a growing sorted subarray.],
    [Selection sort], [Average/worst $O \( n^2 \)$], [Select smallest remaining item.],
    [Merge sort], [Not stated], [Divide, sort halves, merge.],
    [Quick sort], [Slide wording has a complexity inconsistency], [Partition around a pivot and recurse.],
    [Heap sort], [$O \( n log n \)$], [Use heap ordering to extract elements.],
  )]
  , kind: table
  )


#heading(level: 3)[Standard analysis for reference]


The table above records what the slides state. The one below gives the conventional textbook analysis of the same algorithms, including two properties the slides do not discuss: extra space, and #strong[stability] --- whether equal elements keep their original relative order, which matters when sorting records by a secondary key.

#figure(
  align(center)[#table(
    columns: 6,
    align: (left,left,left,left,left,left,),
    table.header([Algorithm], [Best], [Average], [Worst], [Space], [Stable],),
    table.hline(),
    [Bubble sort], [$O \( n \)$], [$O \( n^2 \)$], [$O \( n^2 \)$], [$O \( 1 \)$], [yes],
    [Insertion sort], [$O \( n \)$], [$O \( n^2 \)$], [$O \( n^2 \)$], [$O \( 1 \)$], [yes],
    [Selection sort], [$O \( n^2 \)$], [$O \( n^2 \)$], [$O \( n^2 \)$], [$O \( 1 \)$], [no],
    [Merge sort], [$O \( n log n \)$], [$O \( n log n \)$], [$O \( n log n \)$], [$O \( n \)$], [yes],
    [Quick sort], [$O \( n log n \)$], [$O \( n log n \)$], [$O \( n^2 \)$], [$O \( log n \)$], [no],
    [Heap sort], [$O \( n log n \)$], [$O \( n log n \)$], [$O \( n log n \)$], [$O \( 1 \)$], [no],
  )]
  , kind: table
  )

#callout("clarification", title: [Clarification])[This table is standard algorithm analysis, not slide content. It is included because the slide deck states complexities inconsistently for quick sort and omits merge sort entirely. Where the two tables disagree, the discrepancy is the point: check which convention your assessment expects.]

#callout("intuition", title: [Plain idea])[Bubble and insertion sort reach $O \( n \)$ in the best case only because they can detect that the data is already ordered and stop early. Selection sort cannot: it must scan the entire unsorted region to be sure it has found the minimum, so its best case is no better than its worst.]

#callout("quickcheck", title: [Check your understanding])[Why does binary search require sorted data? Explain in one sentence how insertion sort and selection sort differ in the way they grow the sorted portion.]
