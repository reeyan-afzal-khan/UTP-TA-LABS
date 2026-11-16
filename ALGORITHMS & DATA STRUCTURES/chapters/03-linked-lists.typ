#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-linked-lists")

= Linked Lists I: Singly and Doubly Linked Lists <ch:linked-lists>

#chapterguide[Know how arrays store data contiguously and provide direct index access.][explain nodes, head pointers, and address fields; compare arrays and linked lists; distinguish singly and doubly linked lists; and trace insertion, deletion, and traversal.]

A linked list is a linear data structure made of a sequence of #term[nodes]. Each node stores data and one or more addresses that connect it to adjacent nodes. Unlike an array, the nodes do not need to occupy one contiguous block of memory.

== The basic node model

The Week III slides describe a node as having two conceptual parts: a data field and an address field. The address field stores where an adjacent node can be found.

#utpfig([Anatomy of a singly linked list. Each node is split into a data field and a `next` field holding the address of its successor. Note the addresses: the nodes are scattered across memory, and the list holds together only because each one records where the next lives.], label: <fig:sll-anatomy>)[
  #canvas({
    let nw = 1.15
    for (i, (vv, addr, nxt)) in ((10, 2040, "3160"), (20, 3160, "1004"), (30, 1004, none)).enumerate() {
      let x = 4.3 * i
      node((x, 0), [#vv], name: "d" + str(i), font: font("small"), ..utpcell, min-width: nw, min-height: 0.9)
      if nxt == none or nxt == "" {
        node((x + nw, 0), [NULL], name: "p" + str(i), ..utpcell, min-width: nw, min-height: 0.9, fill: pale-gray, font: font("script", fill: muted))
      } else {
        node((x + nw, 0), [#nxt], name: "p" + str(i), ..utpcell, min-width: nw, min-height: 0.9, fill: white, font: font("script", fill: blue))
      }
      node((x + 0.575 * nw, -0.58), [node at #mono[#addr]], font: font("small"), ..utplabel, anchor: "north", align: center)
    }
    node((0, 0.52), [data], font: font("small"), ..utplabel, anchor: "south")
    node((nw, 0.52), [next], font: font("small"), ..utplabel, anchor: "south")
    for i in (0, 1) {
      let j = int(i + 1)
      connect("p" + str(i) + ".east", "d" + str(j) + ".west", ..utpptr)
    }
    node((-0.85, 0), [HEAD], font: font("small"), ..utptag, anchor: "east")
    connect((-0.8, 0), "d0.west", ..utpptr, draw: orange)
  })
]

The #term[head] identifies the first node. From the head, the remaining nodes are reached by repeatedly following the stored links.

#note[
  An array answers “where is item $i$?” by index arithmetic. A linked list answers it by following a chain of pointers from the head.
]

== Why use a linked list?

The Week III slides give four advantages.

#utptable[
  #tabularx(
    columns: (24%, 1fr),
    styles: (navy-bold,),
    header: ([Advantage], [Meaning]),
    [Dynamic size], [Memory can be allocated when a new node is needed.],
    [Easy insertion/deletion], [Nodes can be added or removed by changing pointers rather than shifting a whole block of elements.],
    [Flexible memory use], [Nodes do not need to occupy contiguous addresses.],
    [Useful for ADTs], [Linked nodes can support stacks, queues, and graph representations later in the course.],
  )
]

== Limitations of linked lists

The slide deck also emphasizes three disadvantages:

- #term[No random access.] Reaching a node normally starts from the head.
- #term[Search is slower than direct array access.] A sequential search takes $O(n)$ in the stated model.
- #term[Extra memory is required.] Every node stores one or more pointer fields.

#utpfigure[
  #canvas({
    node((0, 0), [Array: `A[3]` $arrow.r$ direct access], name: "a", font: font("small"), draw: blue, fill: pale-blue, rounded: 1mm, min-width: 5.3, min-height: 0.8, align: center)
    node(below-of("a", 0.45), [Linked list: Head $arrow.r$ Node1 $arrow.r$ Node2 $arrow.r$ Node3], name: "b", font: font("small"), draw: teal, fill: pale-teal, rounded: 1mm, min-width: 9.4, min-height: 0.8, align: center)
  })
]

== Singly linked lists

A singly linked list node contains a data field and a `next` pointer. From a given node, the list can move forward to the next node, but there is no direct link back to the previous one.

```cpp
    int data;
    Node* next;
};
```

The slide deck names three basic operations: insertion, deletion, and traversal.

=== Traversal

```cpp
    Node* current = head;
    while (current != nullptr) {
        cout << current->data << ' ';
        current = current->next;
    }
    cout << '\n';
}
```

Every visited node advances the pointer one link. If the desired element is near the end, most of the list may need to be visited.

=== Insert at the beginning

#utpsteps[
  + Allocate a new node.
  + Point the new node’s `next` to the current head.
  + Move `head` to the new node.
]

```cpp
    Node* n = new Node{value, head};
    head = n;
}
```

#figref(<fig:sll-insert-head>) shows why the order of those two assignments matters. The new
node must be told about the old first node #emph[before] `head` is moved. Reversing
the steps overwrites the only reference to the rest of the list.

#utpfig([Inserting 5 at the front. Step~2 must happen before step~3: once `head` has been reassigned, nothing else points at node 10, and the remainder of the list is unreachable.], label: <fig:sll-insert-head>)[
  #canvas({
    let dx = 1.62
    node((-1.15, 0), [#strong[1\.] allocate \
  the new node], font: font("small"), ..utplabel, anchor: "east", align: right)
    node((-0.35, 0), [5], name: "n5", font: font("small"), ..utpnode, min-size: 0.85, draw: mix(muted, 60%), fill: white)
    node((-0.35, -0.52), [`next` = ?], font: font("small"), ..utplabel, anchor: "north", text: muted)
    for (i, vv) in range(10, 31, step: 10).enumerate() {
      node((1.35 + dx * i, 0), [#vv], name: "a" + str(i), font: font("small"), ..utpnode, min-size: 0.85)
    }
    connect("a0", "a1", ..utparrow)
    connect("a1", "a2", ..utparrow)
    node((rel: (0.15, 0), to: "a2.east"), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
    node((1.35, 0.72), [HEAD], font: font("small"), ..utptag, anchor: "south")
    connect((1.35, 0.68), "a0.north", ..utpptr, draw: orange)
    draw.scope({
      draw.translate((0, -2.75))
      node((-1.15, 0), [#strong[2\.] link it to \
  the old head], font: font("small"), ..utplabel, anchor: "east", align: right)
      node((-0.35, 0), [5], name: "m5", font: font("small"), ..utpnodehot, min-size: 0.85)
      for (i, vv) in range(10, 31, step: 10).enumerate() {
        node((1.35 + dx * i, 0), [#vv], name: "b" + str(i), font: font("small"), ..utpnode, min-size: 0.85)
      }
      connect("b0", "b1", ..utparrow)
      connect("b1", "b2", ..utparrow)
      node((rel: (0.15, 0), to: "b2.east"), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
      connect("m5", "b0", line-width: 0.9963pt, draw: orange, end: arrow-tip("Stealth", length: 2.2mm, line: 0.9963pt))
      node((1.35, 0.72), [HEAD], font: font("small"), ..utptag, anchor: "south")
      connect((1.35, 0.68), "b0.north", ..utpptr, draw: orange)
      node((0.5, -0.42), [`n->next = head`], font: font("small"), ..utplabel, anchor: "north", text: orange)
    })
    draw.scope({
      draw.translate((0, -5.5))
      node((-1.15, 0), [#strong[3\.] move the \
  head pointer], font: font("small"), ..utplabel, anchor: "east", align: right)
      node((-0.35, 0), [5], name: "c5", font: font("small"), ..utpnodedone, min-size: 0.85)
      for (i, vv) in range(10, 31, step: 10).enumerate() {
        node((1.35 + dx * i, 0), [#vv], name: "c" + str(i), font: font("small"), ..utpnode, min-size: 0.85)
      }
      connect("c0", "c1", ..utparrow)
      connect("c1", "c2", ..utparrow)
      node((rel: (0.15, 0), to: "c2.east"), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
      connect("c5", "c0", line-width: 0.9963pt, draw: green, end: arrow-tip("Stealth", length: 2.2mm, line: 0.9963pt))
      node((-0.35, 0.72), [HEAD], font: font("small"), ..utptag, anchor: "south", text: green)
      connect((-0.35, 0.68), "c5.north", ..utpptr, draw: green)
      node((0.5, -0.42), [`head = n`], font: font("small"), ..utplabel, anchor: "north", text: green)
      connect((1.35, 0.68), "c0.north", ..utpptr, draw: mix(muted, 45%), dash: "dashed")
      node((1.35, 0.72), [#fsize("script")[was]], font: font("small"), ..utplabel, anchor: "south", text: mix(muted, 70%))
    })
  })
]

=== Delete by value

The Week III lab asks for deletion by value. A singly linked list must preserve access to the previous node so its `next` link can bypass the deleted node.

#figref(<fig:sll-delete>) shows the reason. Deleting node 20 means node 10 must be made to
point at node 30 --- but from node 20 there is no way back to node 10. The traversal must
therefore stop one node #emph[early], which is why the loop above tests
`current->next->data` rather than `current->data`.

#utpfig([Deleting the node holding 20. The predecessor is redirected past the target, and only then is the target freed. Deleting before relinking would leave `current->next` pointing into released memory.], label: <fig:sll-delete>)[
  #canvas({
    node((-0.6, 0), [before], font: font("small"), ..utplabel, anchor: "east", align: right)
    node((0, 0), [10], name: "x0", font: font("small"), ..utpnode, min-size: 0.85)
    node((2.1, 0), [20], name: "x1", font: font("small"), ..utpnodehot, min-size: 0.85)
    node((4.2, 0), [30], name: "x2", font: font("small"), ..utpnode, min-size: 0.85)
    connect("x0", "x1", ..utparrow)
    connect("x1", "x2", ..utparrow)
    node((rel: (0.15, 0), to: "x2.east"), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
    node((0, -0.6), [`current`], font: font("small"), ..utplabel, anchor: "north", text: blue)
    node((2.1, -0.6), [target], font: font("small"), ..utptag, anchor: "north")
    draw.scope({
      draw.translate((0, -2.35))
      node((-0.6, 0), [after], font: font("small"), ..utplabel, anchor: "east", align: right)
      node((0, 0), [10], name: "y0", font: font("small"), ..utpnode, min-size: 0.85)
      node((2.1, 0), [20], name: "y1", font: font("small"), ..utpdim, shape: "circle", min-size: 0.85)
      node((4.2, 0), [30], name: "y2", font: font("small"), ..utpnode, min-size: 0.85)
      connect("y0", "y2", bend: 42deg, ..utparrow, draw: green, line-width: 0.9963pt, name: "curve-1")
      node((rel: (0.15, 0), to: "y2.east"), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
      node((2.1, -0.62), [`current->next = old->next` \
  then `delete old`], font: font("small"), ..utplabel, anchor: "north", align: center, text: green)
      connect((1.72, -0.38), (2.48, 0.38), draw: red, line-width: 0.797pt)
      connect((1.72, 0.38), (2.48, -0.38), draw: red, line-width: 0.797pt)
    })
  })
]

```cpp
    if (head == nullptr) return false;

    if (head->data == value) {
        Node* old = head;
        head = head->next;
        delete old;
        return true;
    }

    Node* current = head;
    while (current->next != nullptr &&
           current->next->data != value) {
        current = current->next;
    }

    if (current->next == nullptr) return false;

    Node* old = current->next;
    current->next = old->next;
    delete old;
    return true;
}
```

== Doubly linked lists

A doubly linked list stores two links in every node: `prev` and `next`. This supports both forward and backward traversal.

#utpfig([A doubly linked list. Every node carries a backward link as well as a forward one, so the list can be walked from either end and a node can be removed without first locating its predecessor. The price is one extra pointer per node.], label: <fig:dll>)[
  #canvas({
    let fw = 0.78
    for (i, vv) in range(10, 31, step: 10).enumerate() {
      let x = 3.55 * i
      if i == 0 {
        node((x, 0), [NULL], name: "pv" + str(i), ..utpcell, min-width: fw, min-height: 0.9, fill: pale-gray, font: font("script", fill: muted))
      } else {
        node((x, 0), [], name: "pv" + str(i), font: font("small"), ..utpcell, min-width: fw, min-height: 0.9, fill: white)
      }
      node((x + 0.89, 0), [#vv], name: "dt" + str(i), font: font("small"), ..utpcell, min-width: 1, min-height: 0.9)
      if i == 2 {
        node((x + 1.78, 0), [NULL], name: "nx" + str(i), ..utpcell, min-width: fw, min-height: 0.9, fill: pale-gray, font: font("script", fill: muted))
      } else {
        node((x + 1.78, 0), [], name: "nx" + str(i), font: font("small"), ..utpcell, min-width: fw, min-height: 0.9, fill: white)
      }
    }
    node((0, 0.52), [prev], font: font("small"), ..utplabel, anchor: "south")
    node((0.89, 0.52), [data], font: font("small"), ..utplabel, anchor: "south")
    node((1.78, 0.52), [next], font: font("small"), ..utplabel, anchor: "south")
    for i in (0, 1) {
      let j = int(i + 1)
      connect("nx" + str(i) + ".north", "dt" + str(j) + ".north", bend: 38deg, ..utparrow, name: "curve-1")
    }
    for i in (1, 2) {
      let j = int(i - 1)
      connect("pv" + str(i) + ".south", "dt" + str(j) + ".south", bend: 38deg, line-width: widths.thick, draw: orange, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick), name: "curve-2")
    }
    node((7.6, 1.05), [forward: `next`], font: font("small"), ..utplabel, anchor: "west", text: teal)
    node((7.6, -1.05), [backward: `prev`], font: font("small"), ..utplabel, anchor: "west", text: orange)
  })
]

```cpp
    int data;
    DNode* prev;
    DNode* next;
};
```

== Singly vs doubly linked lists

#utptable[
  #tabularx(
    columns: (22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Feature], [Singly linked list], [Doubly linked list]),
    [Pointers per node], [One: `next`], [Two: `prev`, `next`],
    [Direction], [Forward only], [Forward and backward],
    [Memory use], [Lower], [Higher],
    [Deletion], [Often needs previous-node tracking], [Easier when the target node is already known],
    [Complexity of representation], [Simpler], [More flexible],
  )
]

== Array vs linked list

#utptable[
  #tabularx(
    columns: (20%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Feature], [Array], [Linked list]),
    [Memory layout], [Contiguous], [Non-contiguous allowed],
    [Size], [Fixed for a raw array or resized manually], [Dynamic through node allocation],
    [Access], [Direct using index], [Sequential from head],
    [Insertion/deletion], [Can require shifting elements], [Pointer updates can avoid shifting],
    [Extra memory], [No per-element pointer overhead], [Pointer fields are stored in each node],
  )
]

#warning[
  “Insertion is easy in a linked list” does not mean “finding the insertion position is always fast.” If the program must first search through $n$ nodes to locate the position, that search still costs traversal time.
]

#questions[
  Why can a doubly linked list move backward while a singly linked list cannot? If you already have a pointer to a middle node, which representation stores more information that can help with deletion?
]
