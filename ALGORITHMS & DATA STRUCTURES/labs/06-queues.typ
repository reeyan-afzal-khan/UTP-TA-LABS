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
  Save each one in your `Lab06` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab06`.

  #include "programs/linear_queue.typ"

  #include "programs/linked_queue.typ"

  #include "programs/circular_queue.typ"

  #include "programs/priority_queue.typ"
]

#element-head([Share a processor in turns])

An operating system shares one processor among waiting jobs with a circular queue, a policy called round robin. Each job runs for at most 2 time units, and a job that is not finished goes to the back of the queue. Simulate three jobs with your circular queue: A needs 5 units, B needs 2 and C needs 4, and all three arrive at time 0 in that order. Store each job as its name and its remaining time, and print a line each time a job runs. B must finish at time 4, C at 10 and A at 11. Which of the four queues in this lab would serve worst here, and what would go wrong?
