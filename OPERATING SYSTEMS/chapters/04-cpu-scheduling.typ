#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-cpu-scheduling")

= CPU Scheduling <ch:scheduling>

#chapterguide[Chapter 1: processes, plus comfort reading simple tables and timelines.][calculate waiting, turnaround, response, and completion time; trace FCFS, SJF, Priority, and Round Robin; and compare them fairly in Lab 4.]

== The decision the scheduler makes

Three processes are ready. One CPU is free. Which one runs?

The OS answers this repeatedly. The #term[scheduler] chooses a process; the
#term[dispatcher] gives it the CPU.

There is no single best choice. Short jobs reduce average waiting, small turns
improve responsiveness, and priorities favour important work.

== Five quantities, and what each one means to a user

Use $A$ for arrival, $B$ for CPU burst, $S$ for first start, and $C$ for
completion. The three rules are: $T=C-A$, $W=T-B$, and $R=S-A$.

Each measures a different delay.

#utptable[
  #tabularx(
    columns: (19%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Quantity], [What it measures], [What the user notices]),
    [Turnaround $T$], [Total time in the system, start to finish], [“My batch job took 9 seconds”],
    [Waiting $W$], [Time sat in the ready queue doing nothing], [Pure overhead --- the part a better policy can reduce],
    [Response $R$], [Delay before #emph[any] progress is visible], [“The window froze when I clicked”],
  )
]

#note[
  Waiting and turnaround are closely related because the burst time is fixed.
  Response time is different: it measures how quickly a process starts, not how
  quickly it finishes.
]

#example[
  A process arrives at time 2, first receives the CPU at time 5, needs 4 CPU units in total, and finishes at time 11.

  $R=3$, $T=9$, and $W=5$. A negative waiting time always signals an error.
]

== One workload, four policies

Everything below uses the same three processes, all arriving at time 0. Using one workload throughout is what makes the policies comparable.

#utptable[
  #tabularx(
    columns: (16%, 16%, 16%, 1fr),
    align: (center, center, center, center),
    styles: (navy-bold,),
    header: ([Process], [Arrival $A$], [Burst $B$], [Priority (lower = more urgent)]),
    [P1], [0], [5], [3],
    [P2], [0], [3], [1],
    [P3], [0], [1], [2],
  )
]

=== First-Come, First-Served

#term[FCFS] is non-preemptive and runs processes in arrival order. Here that is P1, P2, P3.

#utpfig([The FCFS schedule: P1, P2, then P3 in arrival order.], label: <fig:gantt-fcfs>)[
  #canvas(x: 0.95cm, y: 0.7cm, {
    rectangle((0, 0), (5, 1), fill: pale-blue, draw: none)
    node((2.5, 0.5), [#fsize("small")[#strong[P1]]])
    rectangle((5, 0), (8, 1), fill: pale-teal, draw: none)
    node((6.5, 0.5), [#fsize("small")[#strong[P2]]])
    rectangle((8, 0), (9, 1), fill: pale-orange, draw: none)
    node((8.5, 0.5), [#fsize("small")[#strong[P3]]])
    for x in (0, 5, 8, 9) {
      connect((x, 0), (x, -0.25), draw: muted)
      node((x, -0.25), [#x], font: font("script"), anchor: "north")
    }
  })
]

#utptable[
  #tabularx(
    columns: (13%, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (center, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Process], [$bold(B)$], [$bold(C)$], [$bold(T=C-A)$], [$bold(W=T-B)$], [$bold(R=S-A)$]),
    [P1], [5], [5], [5], [0], [0],
    [P2], [3], [8], [8], [5], [5],
    [P3], [1], [9], [9], [8], [8],
    table.hline(stroke: 0.55pt + rule-color),
    multicolumn(3, left)[#strong[Average]], [#strong[7.33]], [#strong[4.33]], [#strong[4.33]],
  )
]

P3 needs one unit of CPU and waits eight to get it. That is the #term[convoy effect]: short jobs stuck behind a long one, like cars behind a lorry on a single-lane road.

=== Shortest Job First

#term[SJF] picks the smallest remaining burst: P3, then P2, then P1.

#utpfig([The SJF schedule: the shortest burst first, P3, then P2, then P1.], label: <fig:gantt-sjf>)[
  #canvas(x: 0.95cm, y: 0.7cm, {
    rectangle((0, 0), (1, 1), fill: pale-orange, draw: none)
    node((0.5, 0.5), [#fsize("small")[#strong[P3]]])
    rectangle((1, 0), (4, 1), fill: pale-teal, draw: none)
    node((2.5, 0.5), [#fsize("small")[#strong[P2]]])
    rectangle((4, 0), (9, 1), fill: pale-blue, draw: none)
    node((6.5, 0.5), [#fsize("small")[#strong[P1]]])
    for x in (0, 1, 4, 9) {
      connect((x, 0), (x, -0.25), draw: muted)
      node((x, -0.25), [#x], font: font("script"), anchor: "north")
    }
  })
]

#utptable[
  #tabularx(
    columns: (13%, 1fr, 1fr, 1fr, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Process], [$bold(B)$], [$bold(C)$], [$bold(T)$], [$bold(W)$], [$bold(R)$]),
    [P3], [1], [1], [1], [0], [0],
    [P2], [3], [4], [4], [1], [1],
    [P1], [5], [9], [9], [4], [4],
    table.hline(stroke: 0.55pt + rule-color),
    multicolumn(3, left)[#strong[Average]], [#strong[4.67]], [#strong[1.67]], [#strong[1.67]],
  )
]

Average waiting fell from 4.33 to 1.67 --- and no work was done faster. The CPU was busy for exactly nine units in both schedules. Only the #emph[order] changed.

#note[
  For a fixed set of jobs all available at once, SJF provably minimises average waiting time. Running a short job early delays only that short job’s successors briefly; running a long job early delays everyone behind it.

  The catch is that $B_i$ is the burst the process is #emph[about to] need, which the OS cannot know. Real systems estimate it from recent history, and the estimate is often wrong.
]

=== Priority scheduling

Highest priority first. With the convention that a lower number is more urgent, the order is P2, P3, P1.

#utpfig([The priority schedule, with a lower number more urgent: P2, P3, then P1.], label: <fig:gantt-priority>)[
  #canvas(x: 0.95cm, y: 0.7cm, {
    rectangle((0, 0), (3, 1), fill: pale-teal, draw: none)
    node((1.5, 0.5), [#fsize("small")[#strong[P2]]])
    rectangle((3, 0), (4, 1), fill: pale-orange, draw: none)
    node((3.5, 0.5), [#fsize("small")[#strong[P3]]])
    rectangle((4, 0), (9, 1), fill: pale-blue, draw: none)
    node((6.5, 0.5), [#fsize("small")[#strong[P1]]])
    for x in (0, 3, 4, 9) {
      connect((x, 0), (x, -0.25), draw: muted)
      node((x, -0.25), [#x], font: font("script"), anchor: "north")
    }
  })
]

Averages: $T = 5.33$, $W = 2.33$. Better than FCFS, worse than SJF --- because priority happens to correlate with burst length here, but is not chosen to optimise it.

#warning[
  State your priority convention before you compute anything. “Priority 1” means #emph[most] urgent in most textbooks and lab manuals, and #emph[least] urgent in some real systems --- Linux `nice` values run from $-20$ (most favourable) to $19$.

  Half of all lost marks on scheduling questions come from silently assuming the wrong direction. Write the convention at the top of your answer.
]

Priority scheduling can starve a low-priority process indefinitely if urgent work keeps arriving. The standard remedy is #term[aging]: gradually raise the priority of anything that has waited a long time, so every process eventually becomes urgent enough to run.

=== Round Robin

#term[Round Robin] is preemptive. Each process gets at most a #term[time quantum] $q$, then goes to the back of the queue if unfinished. With $q = 2$ and queue order P1, P2, P3:

#utpfig([The Round Robin schedule with quantum $q=2$. P3 needs one unit, less than the quantum, so it finishes in its first turn at time~5.], label: <fig:gantt-rr>)[
  #canvas(x: 0.95cm, y: 0.7cm, {
    rectangle((0, 0), (2, 1), fill: pale-blue, draw: none)
    node((1, 0.5), [#fsize("small")[#strong[P1]]])
    rectangle((2, 0), (4, 1), fill: pale-teal, draw: none)
    node((3, 0.5), [#fsize("small")[#strong[P2]]])
    rectangle((4, 0), (5, 1), fill: pale-orange, draw: none)
    node((4.5, 0.5), [#fsize("small")[#strong[P3]]])
    rectangle((5, 0), (7, 1), fill: pale-blue, draw: none)
    node((6, 0.5), [#fsize("small")[#strong[P1]]])
    rectangle((7, 0), (8, 1), fill: pale-teal, draw: none)
    node((7.5, 0.5), [#fsize("small")[#strong[P2]]])
    rectangle((8, 0), (9, 1), fill: pale-blue, draw: none)
    node((8.5, 0.5), [#fsize("small")[#strong[P1]]])
    for x in (0, 2, 4, 5, 7, 8, 9) {
      connect((x, 0), (x, -0.25), draw: muted)
      node((x, -0.25), [#x], font: font("script"), anchor: "north")
    }
  })
]

Note that P3 finishes early at time 5 despite only getting the CPU third: it needed one unit, which is less than the quantum, so it ran to completion in its first turn.

#utptable[
  #tabularx(
    columns: (13%, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (center, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Process], [$bold(B)$], [$bold(C)$], [$bold(T)$], [$bold(W)$], [$bold(R)$]),
    [P1], [5], [9], [9], [4], [0],
    [P2], [3], [8], [8], [5], [2],
    [P3], [1], [5], [5], [4], [4],
    table.hline(stroke: 0.55pt + rule-color),
    multicolumn(3, left)[#strong[Average]], [#strong[7.33]], [#strong[4.33]], [#strong[2.00]],
  )
]

== Reading the comparison honestly

#utptable[
  #tabularx(
    columns: (26%, 1fr, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Policy], [Avg turnaround], [Avg waiting], [Avg response]),
    [FCFS], [7.33], [4.33], [4.33],
    [SJF], [#strong[4.67]], [#strong[1.67]], [1.67],
    [Priority], [5.33], [2.33], [2.33],
    [Round Robin ($q=2$)], [7.33], [4.33], [#strong[2.00]],
  )
]

Round Robin improves first response without making the CPU faster; it changes
how waiting is shared. SJF performs best here, but it needs future burst lengths
and can delay long jobs indefinitely.

#note[
  The quantum controls the trade-off. A large quantum makes Round Robin behave
  like FCFS. A very small quantum improves response but causes more context
  switches.
]

== Drawing a Gantt chart that survives checking

Work in this order, every time:

#utpsteps[
  + Draw the timeline first, marking every instant the CPU changes hands. Do not compute anything yet.
  + Read the completion time $C_i$ off the chart --- the right-hand edge of that process’s #emph[last] block.
  + Compute $T_i = C_i - A_i$.
  + Compute $W_i = T_i - B_i$. Never count queue intervals by hand; the subtraction is what stops you double-counting.
  + Read $S_i$ off the chart for $R_i$ --- the left edge of that process’s #emph[first] block.
]

#warning[
  The most common Round Robin error is computing waiting time by adding up gaps in the chart. With several preemptions there are several gaps per process, and one is always missed.

  Use $W = T - B$. It cannot miss a gap, because it never looks at them.
]

#exercises[
  Redo the same workload with $q = 1$, then with $q = 5$. Confirm that $q = 5$ reproduces the FCFS chart exactly, and explain in one sentence why.

  Then change the arrivals to $A_1 = 0$, $A_2 = 1$, $A_3 = 2$ and redo FCFS. The chart now contains idle time if a process has not arrived yet --- make sure your $C$ values account for it.
]

#questions[
  + Why can Round Robin have the same average waiting time as FCFS but much better response time?
  + A process has $T = 12$ and $B = 15$. What went wrong?
  + Why does SJF need an estimate rather than a measurement?
  + What does aging fix, and which policy needs it?
]

#answers[
  + Waiting time depends only on total time queued, which the same total work distributes similarly. Response time depends on the #emph[first] turn, and RR guarantees every process one within $n times q$ of arriving.
  + An arithmetic error. Waiting time would be $-3$, and a process cannot exist for less time than it spent running. Recheck $C$, or check that $B$ is total burst rather than remaining burst.
  + $B_i$ is the burst the process is about to request. It is only measurable after the fact, so schedulers predict it from recent history --- typically an exponential average of previous bursts.
  + Starvation. Priority scheduling needs it: without aging, a steady stream of urgent work means a low-priority process may never run at all.
]
