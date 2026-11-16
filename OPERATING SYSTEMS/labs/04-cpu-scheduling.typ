#import "/.shared/typst/utp.typ": *
#unit("labs", "04-cpu-scheduling")

#labsection(4, label: <sec:lab04>)[CPU scheduling: compare policies on one workload]

#labproject[Make scheduling policy visible through order, response, and waiting time][
  #strong[Coverage.] Chapter~#ref(<ch:scheduling>): scheduling metrics and policy rules. \

  #strong[Goal.] Run four policies on the same bursts so only the policy changes. \

  #strong[Explain.] Use the trace to explain why order or time quantum changes a metric.

  #include "visuals/04-flow.typ"

  #heading(depth: 2, numbering: none)[Source code]

  #labsourcecard[`fcfs.c`][Run processes in the supplied order.][Waiting time is the accumulated burst time of earlier processes.]

  #strong[Start the file.] `fcfs.c`, lines 1--26.

  #include "visuals/04-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:scheduling>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] All processes arrive at zero in this program. The printed PID starts at 1 while the array index starts at 0. Check each row against the accumulators before comparing this scheduler with the other supplied policies.

  #include "visuals/04-worked-case.typ"

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab04/fcfs.c", first: 1, last: 26, lang: "c")]

  #labsourcecard[`sjf.c`][Sort the same workload by shortest burst first.][The sorting step changes execution order; the metric loop is otherwise very similar to FCFS.]

  #strong[Start the file.] `sjf.c`, lines 1--33.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab04/sjf.c", first: 1, last: 33, lang: "c")]

  #strong[Continue the same file.] `sjf.c`, lines 34--43.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab04/sjf.c", first: 34, last: 43, lang: "c")]

  #labsourcecard[`priority.c`][Sort by priority, where a smaller number means higher priority.][The code uses PID only as a tie-breaker so equal priorities are deterministic.]

  #strong[Start the file.] `priority.c`, lines 1--30.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab04/priority.c", first: 1, last: 30, lang: "c")]

  #strong[Continue the same file.] `priority.c`, lines 31--49.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab04/priority.c", first: 31, last: 49, lang: "c")]

  #labsourcecard[`round_robin.c`][Give each unfinished process a bounded time slice.][`remaining[]` tracks work left; `first_run[]` gives response time when all arrivals are 0.]

  #strong[Start the file.] `round_robin.c`, lines 1--30.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab04/round_robin.c", first: 1, last: 30, lang: "c")]

  #strong[Continue the same file.] `round_robin.c`, lines 31--53.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab04/round_robin.c", first: 31, last: 53, lang: "c")]

  #heading(depth: 2, numbering: none)[Task 1 --- Compile all policies]

  ```bash
  cd all_experiments/Lab04
  for f in fcfs sjf priority round_robin; do
    gcc -Wall -Wextra -std=c11 "$f.c" -o "$f"
  done
  ```

  #heading(depth: 2, numbering: none)[Task 2 --- Baseline comparison]

  ```bash
  ./fcfs
  ./sjf
  ./priority
  ./round_robin 2
  ```

  Complete a table with execution order, first process to finish, average waiting time when printed, and one observation about responsiveness.

  #utptable[
    #tabularx(
      columns: (18%, 1fr, 1fr, 1fr),
      styles: (navy-bold,),
      header: ([Policy], [First execution order], [Waiting/response evidence], [What the rule favours]),
      [FCFS], [], [], [],
      [SJF], [], [], [],
      [Priority], [], [], [],
      [RR, $q=2$], [], [], [],
    )
  ]

  #heading(depth: 2, numbering: none)[Task 3 --- Verify one result by hand]

  For FCFS, draw a one-line Gantt chart for bursts 8, 4, 2, 1. Compute the waiting time of each process before comparing your arithmetic with the program.

  #heading(depth: 2, numbering: none)[Task 4 --- Change only the Round Robin quantum]

  ```bash
  ./round_robin 1
  ./round_robin 2
  ./round_robin 4
  ```

  Record the first response time of each process for each quantum. Explain the trade-off visible in the Gantt output: smaller turns provide earlier rotation but create more slices.

  #questions[
    + Which scheduling metric measures time spent waiting in the ready queue?
    + Why can Round Robin improve response time while increasing the number of context switches?
    + Why must all policies be compared using the same workload?
  ]

  #strong[Chapter connection.] Revisit #link(<ch:scheduling>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/04-cpu-scheduling-chapter.typ"

  #checklist[
    #strong[Explain and extend your result.] Check every row of one scheduler trace using these identities. Change the round-robin quantum and explain both the response-time effect and the resulting context switches.

    - All four policies run on the same bursts, so only the policy differs.
    - The FCFS Gantt chart and its waiting times are checked by hand against the program.
    - The Round Robin first-response times are recorded for $q=1,2,4$.
    - Each explanation names the policy rule first and the metric consequence second.
  ]
]
