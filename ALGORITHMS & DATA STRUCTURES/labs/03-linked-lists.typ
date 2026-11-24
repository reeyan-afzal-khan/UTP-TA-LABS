#import "/.shared/typst/utp.typ": *
#unit("labs", "03-linked-lists")

#labsection(3, label: <sec:lab03>)[Singly and doubly linked lists]

#labproject[Implement both pointer structures][
  #note[
    #strong[Official Lab Manual --- Lab III.] Create, display, search, insert, and delete in singly and doubly linked lists.
  ]

  #strong[Goal.] Implement singly and doubly linked lists; preserve links after every change.

  #strong[Recall first.] Review the #link(<ch:linked-lists>)[Singly and Doubly Linked Lists] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Save each one in your `Lab03` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab03`.

  #include "programs/singly_linked_list.typ"

  #include "programs/doubly_linked_list.typ"
]

#element-head([Reverse both lists in place])

Write `reverse` for each list without allocating a single node. In the singly linked list, walk once with three pointers (the previous node, the current one and the next one) and point each node back at the one before it; finish by moving `head` to the old last node. In the doubly linked list, swap `next` and `prev` in every node, then swap `head` and `tail`. Test both on 10 20 30 40: the forward line must become 40 30 20 10, and the doubly linked list's invariant check must still print `[ok]`.
