#import "/.shared/typst/utp.typ": *
#unit("labs", "06-threads-and-deadlocks")

#labsection(6, label: <sec:lab06>)[Threads, mutexes, and resource safety]

#labproject[See a race condition, protect it, then trace a safe-state test][
  #strong[Coverage.] Chapter~#ref(<ch:deadlock>): threads, critical sections, mutexes, safe resource states. \

  #strong[Goal.] Run the same increment loop with and without a lock, then inspect a Banker trace. \

  #strong[Explain.] Explain why a race is timing-dependent and why “unsafe” is not identical to “deadlocked now”.

  #include "visuals/06-flow.typ"

  #heading(depth: 2, numbering: none)[Source code]

  #labsourcecard[`threads_demo.c`][Two threads increment one shared counter.][The read-increment-write sequence is protected only when the mutex is enabled.]

  #strong[Start the file.] `threads_demo.c`, lines 1--33.

  #include "visuals/06-trace.typ"

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab06/threads_demo.c", first: 1, last: 33, lang: "c")]

  #strong[Continue the same file.] `threads_demo.c`, lines 34--58.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab06/threads_demo.c", first: 34, last: 58, lang: "c")]

  #labsourcecard[`banker.c`][Compute `Need = Maximum - Allocation` and search for a safe sequence.][A process may finish only when every resource in its Need vector is no larger than current Work.]

  #strong[Start the file.] `banker.c`, lines 1--30.

  #strong[Use the chapter while coding.] Revisit #link(<ch:deadlock>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Process numbering in this example is zero-based. Work is the simulated available vector. Releasing allocation, rather than maximum or need, is the critical update. In --unsafe mode work starts at zero; check the no-progress exit.

  #include "visuals/06-worked-case.typ"

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab06/banker.c", first: 1, last: 30, lang: "c")]

  #strong[Continue the same file.] `banker.c`, lines 31--63.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab06/banker.c", first: 31, last: 63, lang: "c")]

  #strong[Continue the same file.] `banker.c`, lines 64--94.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab06/banker.c", first: 64, last: 94, lang: "c")]

  #heading(depth: 2, numbering: none)[Task 1 --- Repeat the race, do not trust one run]

  ```bash
  cd all_experiments/Lab06
  gcc -Wall -Wextra -std=c11 -pthread threads_demo.c -o threads_demo
  for i in 1 2 3 4 5; do ./threads_demo --no-lock; done
  ```

  Record all five Actual values. A race condition means the result is not protected by a correctness guarantee; it does #emph[not] mean every run must fail differently.

  #heading(depth: 2, numbering: none)[Task 2 --- Enable the mutex]

  ```bash
  for i in 1 2 3; do ./threads_demo; done
  ```

  The locked runs should reach the Expected count. On paper, mark the critical section: read counter $arrow.r$ increment $arrow.r$ write counter.

  #heading(depth: 2, numbering: none)[Task 3 --- Safe and unsafe resource states]

  ```bash
  gcc -Wall -Wextra -std=c11 banker.c -o banker
  ./banker
  ./banker --unsafe
  ```

  For the safe run, copy the sequence and verify the first selected process by comparing its Need with the initial Work vector. For the unsafe run, identify the first point at which no unfinished process can satisfy `Need <= Work`.

  #utptable[
    #tabularx(
      columns: (38%, 1fr),
      styles: (navy-bold,),
      header: ([Observation], [Interpretation]),
      [Unlocked counter loses updates], [timing allowed two threads to overlap a non-atomic update],
      [Locked counter reaches expected value], [one thread at a time enters the protected update],
      [Banker finds full sequence], [there exists an order in which all declared needs can complete],
      [Banker cannot find full sequence], [the state is unsafe for the declared maximum claims],
    )
  ]

  #questions[
    + What memory do threads in one process share?
    + What does a mutex guarantee when used correctly around a critical section?
    + What is the difference between a deadlocked state and an unsafe state?
  ]

  #strong[Chapter connection.] Revisit #link(<ch:deadlock>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/06-threads-and-deadlocks-chapter.typ"

  #checklist[
    #strong[Explain and extend your result.] Trace one safe sequence and one unsafe case. For the counter, repeat locked and unlocked runs and explain the critical section rather than relying on one observed wrong total.

    - Five unlocked runs are recorded, not one.
    - All three locked runs reach the Expected count.
    - The critical section is marked as read, increment, write.
    - The Banker’s check identifies one safe and one unsafe state, and an unsafe state is distinguished from an actual deadlock.
  ]
]
