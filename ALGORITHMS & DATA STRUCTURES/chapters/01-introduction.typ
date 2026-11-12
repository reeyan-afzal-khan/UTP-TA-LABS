#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-introduction")

= Introduction to Data Structures <ch:introduction>

#chapterguide[Basic C++ variables and control flow.][classify data structures, explain core operations and efficiency, and model records with a C++ `struct`.]

#keyidea[
  The course summarizes the relationship as

  $ "Program" = "Algorithm" + "Data Structure". $

  An algorithm describes the steps. A data structure determines how the data used by those steps is arranged.
]

== From data to a data structure

#describe-nextline(1.4in)[
  / Data: A collection of raw facts and figures.
  / Data structure: A way to organize, store, and relate data in memory.
]

== Classification of data structures

The slides divide data structures into two broad categories: #term[primitive] and #term[non-primitive].

#utpfig([The course classification of data structures. Primitive types hold single values; non-primitive structures organise collections, and split further by whether the elements form a single sequence or a branching relationship.], label: <fig:ds-classification>)[
  #canvas({
    let root = (draw: navy, fill: navy, text: white, rounded: 2mm, min-width: 4.2, min-height: 1, align: center, inner-sep: 3mm, font: font("normal", weight: "bold"))
    let category = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 4.4, min-height: 1.65, align: center, inner-xsep: 3.5mm, inner-ysep: 3mm, font: font("small", fill: navy))
    let branch = (draw: teal, fill: pale-teal, rounded: 2mm, text-width: 4, min-height: 1.75, align: center, inner-xsep: 3.5mm, inner-ysep: 3mm, font: font("small", fill: navy))
    let trunk = (line-width: 0.8468pt, draw: teal)
    let link-style = (..trunk, shorten-end: 0.5978pt, end: tip("Stealth", length: 2.3mm, width: 1.7mm, line: 0.4pt))
    node((0, 0), [Data Structures], name: "ds", ..root)
    node((-3.75, -2.2), [#strong[#text(fill: blue)[Primitive]] \ #v(3.9851pt)
   #fsize("script")[Basic values handled directly \ #v(1.9925pt)
   #strong[Examples:] integer, floating-point, \
  character, string constant, pointer]], name: "p", ..category)
    node((3.75, -2.2), [#strong[#text(fill: blue)[Non-Primitive]] \ #v(3.9851pt)
   #fsize("script")[Structures built from primitive values \ #v(1.9925pt)
   Store collections or relationships]], name: "np", ..category)
    node((1.25, -5.25), [#strong[#text(fill: teal)[Linear]] \ #v(3.9851pt)
   #fsize("script")[Elements form a single sequence \ #v(1.9925pt)
   #strong[Examples:] array, linked list, \
  stack, queue]], name: "lin", ..branch)
    node((6.25, -5.25), [#strong[#text(fill: teal)[Non-Linear]] \ #v(3.9851pt)
   #fsize("script")[Elements form hierarchical or \
  network relationships \ #v(1.9925pt)
   #strong[Examples:] tree, graph]], name: "nonlin", ..branch)
    coordinate("topfork", (0, -0.78))
    connect("ds.south", "topfork", ..trunk)
    connect("topfork", "-|", "p.north", ..link-style)
    connect("topfork", "-|", "np.north", ..link-style)
    circle-at("topfork", 0.9963pt, fill: teal, draw: none)
    coordinate("lowerfork", (3.75, -3.65))
    connect("np.south", "lowerfork", ..trunk)
    connect("lowerfork", "-|", "lin.north", ..link-style)
    connect("lowerfork", "-|", "nonlin.north", ..link-style)
    circle-at("lowerfork", 0.9963pt, fill: teal, draw: none)
  })
]

=== Primitive data structures

The course describes primitive data structures as basic structures directly manipulated by machine-level instructions. The slides list integers, floating-point numbers, character constants, string constants, and pointers as examples.

Typical operations highlighted for primitive structures are:

- create;
- select or access;
- update;
- destroy or delete.

#clarification[
  The Week I classification is the course framing. In modern C++, types such as `std::string` are library classes rather than built-in primitive machine types. Keep the slide classification for this course, but be aware that language-level terminology can be more precise.
]

=== Non-primitive data structures

Non-primitive structures are described as structures derived from primitive data structures. They can organize homogeneous items of the same type or heterogeneous items of different types, and they can represent relationships among items.

=== Linear data structures

In a linear structure, elements form a sequence or linear series. The slides give stacks, queues, and linked lists as common examples. Arrays, introduced in the next chapter, are another central linear structure in the course.

#utpfig([In a linear structure every element has at most one predecessor and one successor, so there is exactly one path through the data.], label: <fig:linear-shape>)[
  #canvas({
    for (i, vv) in ("A", "B", "C", "D").enumerate() {
      node((1.85 * i, 0), [#vv], name: "c" + str(i), ..utpcell, min-width: 1.3)
    }
    for i in range(0, 3) {
      let j = int(i + 1)
      connect("c" + str(i), "c" + str(j), ..utparrow)
    }
    node(below-of("c1", 0.5), [one predecessor, one successor: a single chain], ..utplabel, xshift: 0.9cm)
  })
]

=== Non-linear data structures

A non-linear structure allows one item to connect to several other items. The slides emphasize hierarchical or parent-child relationships and give #term[trees] and #term[graphs] as the main examples.

#utpfig([Two non-linear shapes. A tree imposes a strict hierarchy with one path between any two nodes; a graph allows cycles and several competing paths, which is why graph traversal must remember what it has already visited.], label: <fig:nonlinear-shape>)[
  #canvas({
    let figuretitle = (font: font("small", weight: "bold"), align: center, text: navy)
    draw.scope({
      node((0, 0), [A], name: "a", ..utpnode)
      node((-1.1, -1.15), [B], name: "b", ..utpnode)
      node((1.1, -1.15), [C], name: "c", ..utpnode)
      node((-1.75, -2.3), [D], name: "d", ..utpnode)
      node((-0.45, -2.3), [E], name: "e", ..utpnode)
      connect("a", "b", ..utpedge)
      connect("a", "c", ..utpedge)
      connect("b", "d", ..utpedge)
      connect("b", "e", ..utpedge)
      node((0, 0.92), [Rooted tree], ..figuretitle)
      node((0, -3.55), [#strong[Hierarchical structure] \ #v(0.9963pt)
   Unique path: $A arrow.r B arrow.r E$], ..utplabel, align: center)
    })
    draw.scope({
      draw.translate((6.1, 0))
      node((0, 0), [P], name: "p", ..utpnode)
      node((-1.15, -1.3), [Q], name: "q", ..utpnode)
      node((1.15, -1.3), [R], name: "r", ..utpnode)
      node((0, -2.45), [S], name: "s", ..utpnode)
      connect("p", "q", ..utpedge)
      connect("p", "r", ..utpedge)
      connect("q", "s", ..utpedge)
      connect("r", "s", ..utpedge)
      connect("q", "r", ..utpedge)
      node((0, 0.92), [Undirected graph], ..figuretitle)
      node((0, -3.55), [#strong[Network structure] \ #v(0.9963pt)
   Alternative paths: $P arrow.r Q arrow.r S$ or $P arrow.r R arrow.r S$], ..utplabel, align: center)
    })
  })
]

#intuition[
  Five student ages are data. Storing them as an array is a structural choice. Storing each student’s ID, name, age, and course together in one record is a different structural choice. The values may be similar, but the relationships you need to preserve are different.
]

Figures~#ref(<fig:same-data-array>)--@fig:same-data-tree make the point concrete. The five values never change, but each layout
answers a different question cheaply and a different question expensively. Choosing the
structure #emph[is] choosing which operations will be fast.

#utpfig([The values occupy indexed positions. Reaching a known index is constant time, while inserting in the middle requires shifting later values.], label: <fig:same-data-array>)[
  #canvas({
    node((-0.15, 0.95), [ARRAY], font: font("normal", weight: "bold", fill: navy))
    for (i, vv) in (12, 25, 18, 30, 22).enumerate() {
      node((0.9 * i, 0), [#vv], name: "a" + str(i), font: font("small"), ..utpcell, min-width: 0.9, min-height: 0.75)
      node((0.9 * i, -0.62), [#i], font: font("small"), ..utplabel)
    }
    node((5.9, 0), [reach item 4 #cxg[$O(1)$] \
   insert in middle #cxr[$O(n)$]], font: font("small"), ..utplabel, align: left, anchor: "west")
  })
]

#utpfig([The values are connected by links rather than indices. Reaching item 4 requires traversal, but insertion is constant time once the location is known.], label: <fig:same-data-list>)[
  #canvas({
    node((-0.15, 0.95), [LINKED LIST], font: font("normal", weight: "bold", fill: navy))
    for (i, vv) in (12, 25, 18, 30, 22).enumerate() {
      node((1.06 * i, 0), [#vv], name: "l" + str(i), font: font("small"), ..utpcell, min-width: 0.72, min-height: 0.75)
    }
    for i in range(0, 4) {
      let j = int(i + 1)
      connect("l" + str(i), "l" + str(j), ..utpptr)
    }
    node((rel: (0.2, 0), to: "l4.east"), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
    node((5.9, 0), [reach item 4 #cxr[$O(n)$] \
   insert once located #cxg[$O(1)$]], font: font("small"), ..utplabel, align: left, anchor: "west")
  })
]

#utpfig([The same values form an ordered hierarchy. A balanced tree supports logarithmic search while an ordered traversal still visits every value.], label: <fig:same-data-tree>)[
  #canvas({
    node((-0.75, 1.3), [SEARCH TREE], font: font("normal", weight: "bold", fill: navy))
    node((1.1, 0.75), [18], name: "t18", font: font("small"), ..utpnode, min-size: 0.7)
    node((0, -0.25), [12], name: "t12", font: font("small"), ..utpnode, min-size: 0.7)
    node((2.2, -0.25), [25], name: "t25", font: font("small"), ..utpnode, min-size: 0.7)
    node((1.5, -1.3), [22], name: "t22", font: font("small"), ..utpnode, min-size: 0.7)
    node((2.9, -1.3), [30], name: "t30", font: font("small"), ..utpnode, min-size: 0.7)
    connect("t18", "t12", ..utpedge)
    connect("t18", "t25", ..utpedge)
    connect("t25", "t22", ..utpedge)
    connect("t25", "t30", ..utpedge)
    node((5.3, -0.25), [search by value #cxg[$O(log n)$] \
   ordered scan #cxg[$O(n)$], sorted], font: font("small"), ..utplabel, align: left, anchor: "west")
  })
]

== Common operations

For non-primitive structures, the Week I slides list the following common operations:

#utptable[
  #tabularx(
    columns: (19%, 1fr),
    styles: (navy-bold,),
    header: ([Operation], [Meaning in the course context]),
    [Traversal], [Visit elements systematically.],
    [Insertion], [Add a new element.],
    [Selection], [Access or choose a particular element.],
    [Searching], [Find an element that matches a condition or key.],
    [Sorting], [Rearrange elements into a specified order.],
    [Merging], [Combine structures or collections.],
    [Destroy/Delete], [Remove elements or release the structure.],
  )
]

These operation names recur throughout the course. The important change from chapter to chapter is not the operation itself, but how the structure makes the operation easier or harder.

== Primitive vs non-primitive structures

#utptable[
  #tabularx(
    columns: (18%, 31%, 1fr),
    styles: (navy-bold,),
    header: ([Feature], [Primitive], [Non-primitive]),
    [Meaning], [Basic built-in or basic-value type in the course classification], [Built using primitive types],
    [Examples], [`int`, `float`, `char`, pointer], [array, linked list, tree, graph],
    [Structure], [Simple], [Can store groups or relationships],
    [Memory use], [Usually fixed/simple], [Can be static or dynamic],
    [Use case], [Single value], [Grouped or connected data],
  )
]

== Three characteristics of a good data-structure implementation

The Week I slides highlight three characteristics.

#describe-nextline(1.4in)[
  / Correctness: The implementation must implement its interface correctly.
  / Time complexity: The running or execution time of operations should be as small as possible for the problem.
  / Space complexity: The memory used by the operations should be as small as possible for the problem.
]

#keyidea[
  A data structure is useful because of the operations it supports. Saying “a linked list is dynamic” or “an array gives direct access” matters because those properties change the cost and behavior of insertion, deletion, searching, and traversal.
]

== C++ practical: structures (`struct`)

The slides introduce `struct` as a user-defined C/C++ data type that groups items of different types into a single record.

```cpp
    int id;
    string name;
    int age;
    string course;
};
```

Each variable of type `Student` contains all four fields.

#workedexample[
  Suppose one student has ID 1001, name “Amina”, age 20, and course “Computer Science”. These values have different primitive or library types, but they belong to one logical record. A `struct` preserves that relationship.
]

```cpp
s.id = 1001;
s.name = "Amina";
s.age = 20;
s.course = "Computer Science";

cout << s.id << " " << s.name << " "
     << s.age << " " << s.course << '\n';
```

== Putting records into an array

The Week I lab asks for at least five student records, then display, search, and update operations. One direct representation is an array of `Student` records.

```cpp
Student students[N] = {
    {1001, "Amina", 20, "CS"},
    {1002, "Ben",   21, "IT"},
    {1003, "Chen",  20, "CS"},
    {1004, "Devi",  22, "IS"},
    {1005, "Ehsan", 21, "IT"}
};
```

Searching by ID can be performed by examining records one by one.

```cpp
for (int i = 0; i < N; ++i) {
    if (students[i].id == target) {
        cout << "Found: " << students[i].name << '\n';
        break;
    }
}
```

#quickcheck[
  Classify each as primitive or non-primitive using the course framing: an integer, a pointer, an array of integers, a linked list, a graph. Then name one operation whose efficiency could depend strongly on the chosen structure.
]
