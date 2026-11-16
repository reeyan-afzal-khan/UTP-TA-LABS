#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-circular-linked-list")

= Linked Lists II: Circular Linked Lists <ch:circular-list>

#chapterguide[Understand the node/head model and singly linked-list traversal from #chapref(<ch:linked-lists>).][explain the circular link, compare singly/doubly/circular lists, trace circular traversal, and implement beginning/end insertion and deletion plus deletion by value.]

A circular linked list changes one crucial link: the last node points back to the first node instead of pointing to `NULL`. The result is a sequence that can continue in a loop.

== The circular structure

#utpfig([A circular linked list drawn as the ring it actually is. The single change from #figref(<fig:sll-anatomy>) is the last node’s `next` field: instead of `NULL` it stores the address of the head, so there is no end to stop at.], label: <fig:cll-ring>)[
  #canvas({
    for (i, (vv, ang)) in ((10, 90), (20, 0), (30, 270), (40, 180)).enumerate() {
      node((angle: (ang) * 1deg, radius: 1.75), [#vv], name: "r" + str(i), font: font("small"), ..utpnode, min-size: 0.95)
    }
    connect("r0", "r1", bend: 22deg, ..utparrow, name: "curve-1")
    connect("r1", "r2", bend: 22deg, ..utparrow, name: "curve-2")
    connect("r2", "r3", bend: 22deg, ..utparrow, name: "curve-3")
    connect("r3", "r0", bend: 22deg, line-width: 0.9963pt, draw: orange, end: arrow-tip("Stealth", length: 2.4mm, line: 0.9963pt), name: "curve-4")
    node((angle: (90) * 1deg, radius: 2.45), [HEAD], font: font("small"), ..utptag, anchor: "south")
    node((angle: (180) * 1deg, radius: 2.5), [LAST \
  `last->next` \
  $=$ head], font: font("small"), ..utplabel, anchor: "east", align: right, text: orange)
    node((0, 0), [no `NULL` \
  anywhere], font: font("small"), ..utplabel, align: center)
    draw.scope({
      draw.translate((6.6, 0))
      for (i, vv) in range(10, 41, step: 10).enumerate() {
        node((1.35 * i, 0.55), [#vv], name: "s" + str(i), font: font("small"), ..utpcell, min-width: 0.95, min-height: 0.8)
      }
      for i in range(0, 3) {
        let j = int(i + 1)
        connect("s" + str(i), "s" + str(j), ..utpptr)
      }
      connect("s3.south", (rel: (0, -0.62), to: "s3.south"), "-|", "s0.south", line-width: 0.9963pt, draw: orange, end: arrow-tip("Stealth", length: 2.2mm, line: 0.9963pt))
      node((2.03, -0.85), [the same list drawn flat: \
  the wrap link is what makes it circular], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

The Week IV slides emphasize four consequences:

- the last node points back to the head;
- there is no `NULL` at the end;
- traversal can continue indefinitely around the loop;
- therefore traversal needs an explicit stopping condition.

== Traversal: stop when you return to the head

A normal singly linked list often uses `current != nullptr` as the loop condition. That condition does not work for a non-empty circular list because the pointer never becomes null.

```cpp
    if (head == nullptr) return;

    Node* current = head;
    do {
        cout << current->data << ' ';
        current = current->next;
    } while (current != head);

    cout << '\n';
}
```

#note[
  For a non-empty circular list, the natural traversal invariant is “keep moving until the pointer returns to the starting node.”
]

That invariant explains the unusual loop shape. The test `current != head` is
#emph[already false] on the first iteration, because `current` starts at the head.
A plain `while` loop would therefore print nothing at all. The `do` -- `while`
form checks the condition only after the body has run once, which is exactly what a ring
needs (#figref(<fig:cll-traverse>)).

#utpfig([Why circular traversal uses `do` -- `while`. The pointer starts on the head and returns to it, so the stopping condition is true at both the beginning and the end of the walk; only the second occurrence should end the loop.], label: <fig:cll-traverse>)[
  #canvas({
    for (i, (vv, ang)) in ((10, 90), (20, 0), (30, 270), (40, 180)).enumerate() {
      node((angle: (ang) * 1deg, radius: 1.6), [#vv], name: "t" + str(i), font: font("small"), ..utpnode, min-size: 0.9)
    }
    connect("t0", "t1", bend: 22deg, ..utparrow, name: "curve-1")
    connect("t1", "t2", bend: 22deg, ..utparrow, name: "curve-2")
    connect("t2", "t3", bend: 22deg, ..utparrow, name: "curve-3")
    connect("t3", "t0", bend: 22deg, ..utparrow, name: "curve-4")
    node((angle: (90) * 1deg, radius: 2.3), [start & stop here], font: font("small"), ..utptag, anchor: "south")
    node((0, 0), [visit order \
  10, 20, 30, 40], font: font("small"), ..utplabel, align: center, text: muted)
    draw.scope({
      draw.translate((5.3, 0))
      draw.translate((0, 0.35))
      node((0, 0.9), [#text(fill: red)[#strong[Wrong]] \ #v(0.9963pt)
   `while (current != head) {...}` \
   condition false immediately $arrow.r$ prints nothing], name: "bad", font: font("small"), ..utpstep, fill: pale-red, draw: red, text-width: 5.8, inner-xsep: 3mm, inner-ysep: 2.3mm, align: left, anchor: "north-west")
      node((0, -0.75), [#text(fill: green)[#strong[Right]] \ #v(0.9963pt)
   `do {...} while (current != head);` \
   body runs first, then the test ends the lap], name: "good", font: font("small"), ..utpstep, fill: pale-teal, draw: green, text-width: 5.8, inner-xsep: 3mm, inner-ysep: 2.3mm, align: left, anchor: "north-west")
    })
  })
]

== Singly vs doubly vs circular

#utptable[
  #tabularx(
    columns: (19%, 1fr, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Feature], [Singly], [Doubly], [Circular]),
    [Last node points to], [`NULL`], [`NULL`], [head],
    [Direction], [Forward], [Forward and backward], [Usually forward circular in this course],
    [Pointers per node], [`next`], [`prev`, `next`], [`next`],
    [Traversal stop], [`NULL`], [`NULL`], [back at head],
    [Main use in slides], [Simple dynamic list], [Two-way navigation], [Repeated/cyclic processing],
  )
]

== Insertion at the beginning

Assume `last` points to the final node. Then `last->next` is the head. This representation makes both the tail and head easy to identify.

#utpsteps[
  + Allocate the new node.
  + If the list is empty, point the node to itself and make it `last`.
  + Otherwise, point the new node to the current head.
  + Set `last->next` to the new node, making it the new head.
]

```cpp
    Node* n = new Node{value, nullptr};

    if (last == nullptr) {
        n->next = n;
        last = n;
        return;
    }

    n->next = last->next;
    last->next = n;
}
```

== Insertion at the end

With the same `last` representation, insert at the beginning of the circle and then move `last` to the new node.

```cpp
    Node* n = new Node{value, nullptr};

    if (last == nullptr) {
        n->next = n;
        last = n;
        return;
    }

    n->next = last->next;  // new node points to head
    last->next = n;        // old last points to new node
    last = n;              // new node becomes last
}
```

== Deleting from the beginning

There are three cases: empty list, one-node list, and a list with at least two nodes.

```cpp
    if (last == nullptr) return false;

    Node* head = last->next;
    if (head == last) {
        delete head;
        last = nullptr;
        return true;
    }

    last->next = head->next;
    delete head;
    return true;
}
```

== Deleting from the end

A singly circular list has no direct previous pointer, so deletion of the last node requires locating the node whose `next` is `last`.

```cpp
    if (last == nullptr) return false;

    Node* head = last->next;
    if (head == last) {
        delete last;
        last = nullptr;
        return true;
    }

    Node* current = head;
    while (current->next != last) {
        current = current->next;
    }

    current->next = head;
    delete last;
    last = current;
    return true;
}
```

== Deletion by value

The Week IV lab also requires deletion by value. Traversal must both detect the target and recognize when the full circle has been checked.

```cpp
    if (last == nullptr) return false;

    Node* prev = last;
    Node* current = last->next;  // head

    do {
        if (current->data == value) {
            if (current == prev) {      // one-node list
                delete current;
                last = nullptr;
            } else {
                prev->next = current->next;
                if (current == last) last = prev;
                delete current;
            }
            return true;
        }
        prev = current;
        current = current->next;
    } while (current != last->next);

    return false;
}
```

#warning[
  The easiest circular-list bug is an infinite traversal. Every loop over the list must make progress and must have a condition tied to returning to the starting node.
]

#questions[
  Why does `while (current != nullptr)` fail as a normal stopping condition in a circular list? What special pointer updates are needed when the list contains only one node?
]
