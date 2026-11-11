#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-circular-linked-list")


#heading(level: 1)[Linked Lists II: Circular Linked Lists]
<ch:circular-list>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Understand the node/head model and singly linked-list traversal from #ref(label("ch:linked-lists"), supplement: [Chapter]).

*By the end, you can:* explain the circular link, compare singly/doubly/circular lists, trace circular traversal, and implement beginning/end insertion and deletion plus deletion by value.]

A circular linked list changes one crucial link: the last node points back to the first node instead of pointing to `NULL`. The result is a sequence that can continue in a loop.


#heading(level: 2)[The circular structure]


#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/a159198906283280.cetz.json")], caption: [A circular linked list drawn as the ring it actually is. The single change from #ref(label("fig:sll-anatomy"), supplement: [Figure]) is the last node's `next` field: instead of `NULL` it stores the address of the head, so there is no end to stop at.]) <fig:cll-ring>

The Week IV slides emphasize four consequences:

- the last node points back to the head;

- there is no `NULL` at the end;

- traversal can continue indefinitely around the loop;

- therefore traversal needs an explicit stopping condition.


#heading(level: 2)[Traversal: stop when you return to the head]


A normal singly linked list often uses `current != nullptr` as the loop condition. That condition does not work for a non-empty circular list because the pointer never becomes null.

#code-block("void display(Node* head) {\n    if (head == nullptr) return;\n\n    Node* current = head;\n    do {\n        cout << current->data << ' ';\n        current = current->next;\n    } while (current != head);\n\n    cout << '\\n';\n}", lang: "text")

#callout("keyidea", title: [Key idea])[For a non-empty circular list, the natural traversal invariant is "keep moving until the pointer returns to the starting node."]

That invariant explains the unusual loop shape. The test `current != head` is #emph[already false] on the first iteration, because `current` starts at the head. A plain `while` loop would therefore print nothing at all. The `do` -- `while` form checks the condition only after the body has run once, which is exactly what a ring needs (#ref(label("fig:cll-traverse"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/1ca038eb8115ac3e.cetz.json")], caption: [Why circular traversal uses `do` -- `while`. The pointer starts on the head and returns to it, so the stopping condition is true at both the beginning and the end of the walk; only the second occurrence should end the loop.]) <fig:cll-traverse>


#heading(level: 2)[Singly vs doubly vs circular]


#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Feature], [Singly], [Doubly], [Circular],),
    table.hline(),
    [Last node points to], [`NULL`], [`NULL`], [head],
    [Direction], [Forward], [Forward and backward], [Usually forward circular in this course],
    [Pointers per node], [`next`], [`prev`, `next`], [`next`],
    [Traversal stop], [`NULL`], [`NULL`], [back at head],
    [Main use in slides], [Simple dynamic list], [Two-way navigation], [Repeated/cyclic processing],
  )]
  , kind: table
  )


#heading(level: 2)[Insertion at the beginning]


Assume `last` points to the final node. Then `last->next` is the head. This representation makes both the tail and head easy to identify.

+ Allocate the new node.

+ If the list is empty, point the node to itself and make it `last`.

+ Otherwise, point the new node to the current head.

+ Set `last->next` to the new node, making it the new head.

#code-block("void insertBeginning(Node*& last, int value) {\n    Node* n = new Node{value, nullptr};\n\n    if (last == nullptr) {\n        n->next = n;\n        last = n;\n        return;\n    }\n\n    n->next = last->next;\n    last->next = n;\n}", lang: "text")


#heading(level: 2)[Insertion at the end]


With the same `last` representation, insert at the beginning of the circle and then move `last` to the new node.

#code-block("void insertEnd(Node*& last, int value) {\n    Node* n = new Node{value, nullptr};\n\n    if (last == nullptr) {\n        n->next = n;\n        last = n;\n        return;\n    }\n\n    n->next = last->next;  // new node points to head\n    last->next = n;        // old last points to new node\n    last = n;              // new node becomes last\n}", lang: "text")


#heading(level: 2)[Deleting from the beginning]


There are three cases: empty list, one-node list, and a list with at least two nodes.

#code-block("bool deleteBeginning(Node*& last) {\n    if (last == nullptr) return false;\n\n    Node* head = last->next;\n    if (head == last) {\n        delete head;\n        last = nullptr;\n        return true;\n    }\n\n    last->next = head->next;\n    delete head;\n    return true;\n}", lang: "text")


#heading(level: 2)[Deleting from the end]


A singly circular list has no direct previous pointer, so deletion of the last node requires locating the node whose `next` is `last`.

#code-block("bool deleteEnd(Node*& last) {\n    if (last == nullptr) return false;\n\n    Node* head = last->next;\n    if (head == last) {\n        delete last;\n        last = nullptr;\n        return true;\n    }\n\n    Node* current = head;\n    while (current->next != last) {\n        current = current->next;\n    }\n\n    current->next = head;\n    delete last;\n    last = current;\n    return true;\n}", lang: "text")


#heading(level: 2)[Deletion by value]


The Week IV lab also requires deletion by value. Traversal must both detect the target and recognize when the full circle has been checked.

#code-block("bool deleteValue(Node*& last, int value) {\n    if (last == nullptr) return false;\n\n    Node* prev = last;\n    Node* current = last->next;  // head\n\n    do {\n        if (current->data == value) {\n            if (current == prev) {      // one-node list\n                delete current;\n                last = nullptr;\n            } else {\n                prev->next = current->next;\n                if (current == last) last = prev;\n                delete current;\n            }\n            return true;\n        }\n        prev = current;\n        current = current->next;\n    } while (current != last->next);\n\n    return false;\n}", lang: "text")

#callout("pitfall", title: [Common mistake])[The easiest circular-list bug is an infinite traversal. Every loop over the list must make progress and must have a condition tied to returning to the starting node.]

#callout("quickcheck", title: [Check your understanding])[Why does `while (current != nullptr)` fail as a normal stopping condition in a circular list? What special pointer updates are needed when the list contains only one node?]
