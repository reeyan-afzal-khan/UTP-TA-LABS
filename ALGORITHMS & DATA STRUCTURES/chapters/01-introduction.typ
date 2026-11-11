#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-introduction")


#heading(level: 1)[Introduction to Data Structures]
<ch:introduction>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Basic C++ variables and control flow.

*By the end, you can:* classify data structures, explain core operations and efficiency, and model records with a C++ `struct`.]

#callout("keyidea", title: [Key idea])[The course summarizes the relationship as $ upright("Program") = upright("Algorithm") + upright("Data Structure") . $ An algorithm describes the steps. A data structure determines how the data used by those steps is arranged.]


#heading(level: 2)[From data to a data structure]


/ Data: #block[
A collection of raw facts and figures.
]

/ Data structure: #block[
A way to organize, store, and relate data in memory.
]


#heading(level: 2)[Classification of data structures]


The slides divide data structures into two broad categories: #strong[primitive] and #strong[non-primitive].

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/e0c981ab16a734e6.svg")], caption: [The course classification of data structures. Primitive types hold single values; non-primitive structures organise collections, and split further by whether the elements form a single sequence or a branching relationship.]) <fig:ds-classification>


#heading(level: 3)[Primitive data structures]


The course describes primitive data structures as basic structures directly manipulated by machine-level instructions. The slides list integers, floating-point numbers, character constants, string constants, and pointers as examples.

Typical operations highlighted for primitive structures are:

- create;

- select or access;

- update;

- destroy or delete.

#callout("clarification", title: [Clarification])[The Week I classification is the course framing. In modern C++, types such as `std::string` are library classes rather than built-in primitive machine types. Keep the slide classification for this course, but be aware that language-level terminology can be more precise.]


#heading(level: 3)[Non-primitive data structures]


Non-primitive structures are described as structures derived from primitive data structures. They can organize homogeneous items of the same type or heterogeneous items of different types, and they can represent relationships among items.


#heading(level: 3)[Linear data structures]


In a linear structure, elements form a sequence or linear series. The slides give stacks, queues, and linked lists as common examples. Arrays, introduced in the next chapter, are another central linear structure in the course.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/4bf67fd205bd9116.svg")], caption: [In a linear structure every element has at most one predecessor and one successor, so there is exactly one path through the data.]) <fig:linear-shape>


#heading(level: 3)[Non-linear data structures]


A non-linear structure allows one item to connect to several other items. The slides emphasize hierarchical or parent-child relationships and give #strong[trees] and #strong[graphs] as the main examples.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/f011cdd609308bfb.svg")], caption: [Two non-linear shapes. A tree imposes a strict hierarchy with one path between any two nodes; a graph allows cycles and several competing paths, which is why graph traversal must remember what it has already visited.]) <fig:nonlinear-shape>

#callout("intuition", title: [Plain idea])[Five student ages are data. Storing them as an array is a structural choice. Storing each student's ID, name, age, and course together in one record is a different structural choice. The values may be similar, but the relationships you need to preserve are different.]

Figures~#ref(label("fig:same-data-array"), supplement: none)--#ref(label("fig:same-data-tree"), supplement: none) make the point concrete. The five values never change, but each layout answers a different question cheaply and a different question expensively. Choosing the structure #emph[is] choosing which operations will be fast.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/f5c5c5983ef4ce7c.svg")], caption: [The values occupy indexed positions. Reaching a known index is constant time, while inserting in the middle requires shifting later values.]) <fig:same-data-array>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/139b09521e99d71f.svg")], caption: [The values are connected by links rather than indices. Reaching item 4 requires traversal, but insertion is constant time once the location is known.]) <fig:same-data-list>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/6e96e781fe05a6df.svg")], caption: [The same values form an ordered hierarchy. A balanced tree supports logarithmic search while an ordered traversal still visits every value.]) <fig:same-data-tree>


#heading(level: 2)[Common operations]


For non-primitive structures, the Week I slides list the following common operations:

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Operation], [Meaning in the course context],),
    table.hline(),
    [Traversal], [Visit elements systematically.],
    [Insertion], [Add a new element.],
    [Selection], [Access or choose a particular element.],
    [Searching], [Find an element that matches a condition or key.],
    [Sorting], [Rearrange elements into a specified order.],
    [Merging], [Combine structures or collections.],
    [Destroy/Delete], [Remove elements or release the structure.],
  )]
  , kind: table
  )

These operation names recur throughout the course. The important change from chapter to chapter is not the operation itself, but how the structure makes the operation easier or harder.


#heading(level: 2)[Primitive vs non-primitive structures]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Feature], [Primitive], [Non-primitive],),
    table.hline(),
    [Meaning], [Basic built-in or basic-value type in the course classification], [Built using primitive types],
    [Examples], [`int`, `float`, `char`, pointer], [array, linked list, tree, graph],
    [Structure], [Simple], [Can store groups or relationships],
    [Memory use], [Usually fixed/simple], [Can be static or dynamic],
    [Use case], [Single value], [Grouped or connected data],
  )]
  , kind: table
  )


#heading(level: 2)[Three characteristics of a good data-structure implementation]


The Week I slides highlight three characteristics.

/ Correctness: #block[
The implementation must implement its interface correctly.
]

/ Time complexity: #block[
The running or execution time of operations should be as small as possible for the problem.
]

/ Space complexity: #block[
The memory used by the operations should be as small as possible for the problem.
]

#callout("keyidea", title: [Key idea])[A data structure is useful because of the operations it supports. Saying "a linked list is dynamic" or "an array gives direct access" matters because those properties change the cost and behavior of insertion, deletion, searching, and traversal.]


#heading(level: 2)[C++ practical: structures (`struct`)]


The slides introduce `struct` as a user-defined C/C++ data type that groups items of different types into a single record.

#code-block("struct Student {\n    int id;\n    string name;\n    int age;\n    string course;\n};", lang: "text")

Each variable of type `Student` contains all four fields.

#callout("workedexample", title: [Worked example])[Suppose one student has ID 1001, name "Amina", age 20, and course "Computer Science". These values have different primitive or library types, but they belong to one logical record. A `struct` preserves that relationship.]

#code-block("Student s;\ns.id = 1001;\ns.name = \"Amina\";\ns.age = 20;\ns.course = \"Computer Science\";\n\ncout << s.id << \" \" << s.name << \" \"\n     << s.age << \" \" << s.course << '\\n';", lang: "text")


#heading(level: 2)[Putting records into an array]


The Week I lab asks for at least five student records, then display, search, and update operations. One direct representation is an array of `Student` records.

#code-block("const int N = 5;\nStudent students[N] = {\n    {1001, \"Amina\", 20, \"CS\"},\n    {1002, \"Ben\",   21, \"IT\"},\n    {1003, \"Chen\",  20, \"CS\"},\n    {1004, \"Devi\",  22, \"IS\"},\n    {1005, \"Ehsan\", 21, \"IT\"}\n};", lang: "text")

Searching by ID can be performed by examining records one by one.

#code-block("int target = 1003;\nfor (int i = 0; i < N; ++i) {\n    if (students[i].id == target) {\n        cout << \"Found: \" << students[i].name << '\\n';\n        break;\n    }\n}", lang: "text")

#callout("quickcheck", title: [Check your understanding])[Classify each as primitive or non-primitive using the course framing: an integer, a pointer, an array of integers, a linked list, a graph. Then name one operation whose efficiency could depend strongly on the chosen structure.]
