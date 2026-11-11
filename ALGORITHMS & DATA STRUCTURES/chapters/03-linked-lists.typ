#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-linked-lists")


#heading(level: 1)[Linked Lists I: Singly and Doubly Linked Lists]
<ch:linked-lists>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know how arrays store data contiguously and provide direct index access.

*By the end, you can:* explain nodes, head pointers, and address fields; compare arrays and linked lists; distinguish singly and doubly linked lists; and trace insertion, deletion, and traversal.]

A linked list is a linear data structure made of a sequence of #strong[nodes]. Each node stores data and one or more addresses that connect it to adjacent nodes. Unlike an array, the nodes do not need to occupy one contiguous block of memory.


#heading(level: 2)[The basic node model]


The Week III slides describe a node as having two conceptual parts: a data field and an address field. The address field stores where an adjacent node can be found.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/754b129577204b3d.cetz.json")], caption: [Anatomy of a singly linked list. Each node is split into a data field and a `next` field holding the address of its successor. Note the addresses: the nodes are scattered across memory, and the list holds together only because each one records where the next lives.]) <fig:sll-anatomy>

The #strong[head] identifies the first node. From the head, the remaining nodes are reached by repeatedly following the stored links.

#callout("keyidea", title: [Key idea])[An array answers "where is item $i$?" by index arithmetic. A linked list answers it by following a chain of pointers from the head.]


#heading(level: 2)[Why use a linked list?]


The Week III slides give four advantages.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Advantage], [Meaning],),
    table.hline(),
    [Dynamic size], [Memory can be allocated when a new node is needed.],
    [Easy insertion/deletion], [Nodes can be added or removed by changing pointers rather than shifting a whole block of elements.],
    [Flexible memory use], [Nodes do not need to occupy contiguous addresses.],
    [Useful for ADTs], [Linked nodes can support stacks, queues, and graph representations later in the course.],
  )]
  , kind: table
  )


#heading(level: 2)[Limitations of linked lists]


The slide deck also emphasizes three disadvantages:

- #strong[No random access.] Reaching a node normally starts from the head.

- #strong[Search is slower than direct array access.] A sequential search takes $O \( n \)$ in the stated model.

- #strong[Extra memory is required.] Every node stores one or more pointer fields.

#callout("utpfigure", title: [])[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/59635f388c0e5be8.cetz.json")]


#heading(level: 2)[Singly linked lists]


A singly linked list node contains a data field and a `next` pointer. From a given node, the list can move forward to the next node, but there is no direct link back to the previous one.

#code-block("struct Node {\n    int data;\n    Node* next;\n};", lang: "text")

The slide deck names three basic operations: insertion, deletion, and traversal.


#heading(level: 3)[Traversal]


#code-block("void display(Node* head) {\n    Node* current = head;\n    while (current != nullptr) {\n        cout << current->data << ' ';\n        current = current->next;\n    }\n    cout << '\\n';\n}", lang: "text")

Every visited node advances the pointer one link. If the desired element is near the end, most of the list may need to be visited.


#heading(level: 3)[Insert at the beginning]


+ Allocate a new node.

+ Point the new node's `next` to the current head.

+ Move `head` to the new node.

#code-block("void pushFront(Node*& head, int value) {\n    Node* n = new Node{value, head};\n    head = n;\n}", lang: "text")

#ref(label("fig:sll-insert-head"), supplement: [Figure]) shows why the order of those two assignments matters. The new node must be told about the old first node #emph[before] `head` is moved. Reversing the steps overwrites the only reference to the rest of the list.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/38c7d6d82ae1decc.cetz.json")], caption: [Inserting 5 at the front. Step~2 must happen before step~3: once `head` has been reassigned, nothing else points at node 10, and the remainder of the list is unreachable.]) <fig:sll-insert-head>


#heading(level: 3)[Delete by value]


The Week III lab asks for deletion by value. A singly linked list must preserve access to the previous node so its `next` link can bypass the deleted node.

#ref(label("fig:sll-delete"), supplement: [Figure]) shows the reason. Deleting node 20 means node 10 must be made to point at node 30 --- but from node 20 there is no way back to node 10. The traversal must therefore stop one node #emph[early], which is why the loop above tests `current->next->data` rather than `current->data`.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/6ffc62ba979b5982.cetz.json")], caption: [Deleting the node holding 20. The predecessor is redirected past the target, and only then is the target freed. Deleting before relinking would leave `current->next` pointing into released memory.]) <fig:sll-delete>

#code-block("bool deleteValue(Node*& head, int value) {\n    if (head == nullptr) return false;\n\n    if (head->data == value) {\n        Node* old = head;\n        head = head->next;\n        delete old;\n        return true;\n    }\n\n    Node* current = head;\n    while (current->next != nullptr &&\n           current->next->data != value) {\n        current = current->next;\n    }\n\n    if (current->next == nullptr) return false;\n\n    Node* old = current->next;\n    current->next = old->next;\n    delete old;\n    return true;\n}", lang: "text")


#heading(level: 2)[Doubly linked lists]


A doubly linked list stores two links in every node: `prev` and `next`. This supports both forward and backward traversal.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/276302861f2a0d41.cetz.json")], caption: [A doubly linked list. Every node carries a backward link as well as a forward one, so the list can be walked from either end and a node can be removed without first locating its predecessor. The price is one extra pointer per node.]) <fig:dll>

#code-block("struct DNode {\n    int data;\n    DNode* prev;\n    DNode* next;\n};", lang: "text")


#heading(level: 2)[Singly vs doubly linked lists]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Feature], [Singly linked list], [Doubly linked list],),
    table.hline(),
    [Pointers per node], [One: `next`], [Two: `prev`, `next`],
    [Direction], [Forward only], [Forward and backward],
    [Memory use], [Lower], [Higher],
    [Deletion], [Often needs previous-node tracking], [Easier when the target node is already known],
    [Complexity of representation], [Simpler], [More flexible],
  )]
  , kind: table
  )


#heading(level: 2)[Array vs linked list]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Feature], [Array], [Linked list],),
    table.hline(),
    [Memory layout], [Contiguous], [Non-contiguous allowed],
    [Size], [Fixed for a raw array or resized manually], [Dynamic through node allocation],
    [Access], [Direct using index], [Sequential from head],
    [Insertion/deletion], [Can require shifting elements], [Pointer updates can avoid shifting],
    [Extra memory], [No per-element pointer overhead], [Pointer fields are stored in each node],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])["Insertion is easy in a linked list" does not mean "finding the insertion position is always fast." If the program must first search through $n$ nodes to locate the position, that search still costs traversal time.]

#callout("quickcheck", title: [Check your understanding])[Why can a doubly linked list move backward while a singly linked list cannot? If you already have a pointer to a middle node, which representation stores more information that can help with deletion?]
