#import "/.shared/typst/utp.typ": *
#unit("labs", "06-queues")

#labsection(6, label: <sec:lab06>)[Linear, linked, circular, and priority queues]

#labproject[Implement queues and demonstrate wrap-around][
  #note[
    #strong[Official Lab Manual --- Lab VI.] Linear, linked, circular, and priority queues.
  ]

  #strong[Goal.] Preserve FIFO order across array wrap-around.

  #strong[Recall first.] Review the #link(<ch:queues>)[Queues] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Build one program at a time from its `all_experiments/Lab06` folder.

  #include "programs/linear_queue.typ"

  #colbreak()

  #include "programs/linked_queue.typ"

  #colbreak()

  #include "programs/circular_queue.typ"

  #colbreak()

  #include "programs/priority_queue.typ"
]

#checklist[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
