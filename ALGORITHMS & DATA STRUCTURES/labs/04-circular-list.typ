#import "/.shared/typst/utp.typ": *
#unit("labs", "04-circular-list")

#labsection(4, label: <sec:lab04>)[Circular linked-list operations]

#labproject[Maintain a circular list without breaking the loop][
  #note[
    #strong[Official Lab Manual --- Lab IV.] Circular linked-list insertion/deletion; compare list representations.
  ]

  #strong[Goal.] Insert, delete, and traverse without breaking the ring.

  #strong[Recall first.] Review the #link(<ch:circular-list>)[Circular Linked Lists] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Save each one in your `Lab04` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab04`.

  #include "programs/circular_linked_list.typ"

  #include "programs/list_comparison.typ"
]

#element-head([The Josephus circle])

Seven people stand in a circle, numbered 1 to 7. Counting starts at person 1, every third person leaves, and the count goes on from the next person until one is left. Simulate it with the circular list from Program 1: build the ring 1 to 7, start from the last node (person 7), and repeat two steps forward followed by deleting the node after you. The program must print the leaving order 3 6 2 7 5 1 and the survivor, 4. Then explain where the ring saved you work: what would a list ending in `nullptr` need at every step?
