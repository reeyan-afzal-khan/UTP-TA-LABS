#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-cpu-scheduling")


#heading(level: 1)[CPU Scheduling]
<ch:scheduling> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Chapter 1: processes, plus comfort reading simple tables and timelines.

*By the end, you can:* calculate waiting, turnaround, response, and completion time; trace FCFS, SJF, Priority, and Round Robin; and compare them fairly in Lab 4.]


#heading(level: 2)[The decision the scheduler makes]
 Three processes are ready. One CPU is free. Which one runs?

The OS answers this repeatedly. The #strong[scheduler] chooses a process; the #strong[dispatcher] gives it the CPU.

There is no single best choice. Short jobs reduce average waiting, small turns improve responsiveness, and priorities favour important work.


#heading(level: 2)[Five quantities, and what each one means to a user]
 Use $A$ for arrival, $B$ for CPU burst, $S$ for first start, and $C$ for completion. The three rules are: $T = C - A$, $W = T - B$, and $R = S - A$.

Each measures a different delay.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Quantity], [What it measures], [What the user notices],),
    table.hline(),
    [Turnaround $T$], [Total time in the system, start to finish], ["My batch job took 9 seconds"],
    [Waiting $W$], [Time sat in the ready queue doing nothing], [Pure overhead --- the part a better policy can reduce],
    [Response $R$], [Delay before #emph[any] progress is visible], ["The window froze when I clicked"],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Waiting and turnaround are closely related because the burst time is fixed. Response time is different: it measures how quickly a process starts, not how quickly it finishes.]

#callout("workedexample", title: [Worked example])[A process arrives at time 2, first receives the CPU at time 5, needs 4 CPU units in total, and finishes at time 11.

$R = 3$, $T = 9$, and $W = 5$. A negative waiting time always signals an error.]


#heading(level: 2)[One workload, four policies]
 Everything below uses the same three processes, all arriving at time 0. Using one workload throughout is what makes the policies comparable.

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Process], [Arrival $A$], [Burst $B$], [Priority (lower = more urgent)],),
    table.hline(),
    [P1], [0], [5], [3],
    [P2], [0], [3], [1],
    [P3], [0], [1], [2],
  )]
  , kind: table
  )


#heading(level: 3)[First-Come, First-Served]
 #strong[FCFS] is non-preemptive and runs processes in arrival order. Here that is P1, P2, P3.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/145c034c41af3004.cetz.json")], caption: [The FCFS schedule: P1, P2, then P3 in arrival order.]) <fig:gantt-fcfs>

#block[
l \*5l

Process & $bold(B)$ & $bold(C)$ & $bold(T = C - A)$ & $bold(W = T - B)$ & $bold(R = S - A)$ \
P1 & 5 & 5 & 5 & 0 & 0 \
P2 & 3 & 8 & 8 & 5 & 5 \
P3 & 1 & 9 & 9 & 8 & 8 \
& #strong[7.33 & #strong[4.33 & #strong[4.33 \
]]]

]

P3 needs one unit of CPU and waits eight to get it. That is the #strong[convoy effect]: short jobs stuck behind a long one, like cars behind a lorry on a single-lane road.


#heading(level: 3)[Shortest Job First]
 #strong[SJF] picks the smallest remaining burst: P3, then P2, then P1.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/bb5f2f4afd62696b.cetz.json")], caption: [The SJF schedule: the shortest burst first, P3, then P2, then P1.]) <fig:gantt-sjf>

#block[
l \*5l

Process & $bold(B)$ & $bold(C)$ & $bold(T)$ & $bold(W)$ & $bold(R)$ \
P3 & 1 & 1 & 1 & 0 & 0 \
P2 & 3 & 4 & 4 & 1 & 1 \
P1 & 5 & 9 & 9 & 4 & 4 \
& #strong[4.67 & #strong[1.67 & #strong[1.67 \
]]]

]

Average waiting fell from 4.33 to 1.67 --- and no work was done faster. The CPU was busy for exactly nine units in both schedules. Only the #emph[order] changed.

#callout("keyidea", title: [Key idea])[For a fixed set of jobs all available at once, SJF provably minimises average waiting time. Running a short job early delays only that short job's successors briefly; running a long job early delays everyone behind it.

The catch is that $B_i$ is the burst the process is #emph[about to] need, which the OS cannot know. Real systems estimate it from recent history, and the estimate is often wrong.]


#heading(level: 3)[Priority scheduling]
 Highest priority first. With the convention that a lower number is more urgent, the order is P2, P3, P1.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/83f99f8a58758410.cetz.json")], caption: [The priority schedule, with a lower number more urgent: P2, P3, then P1.]) <fig:gantt-priority>

Averages: $T = 5.33$, $W = 2.33$. Better than FCFS, worse than SJF --- because priority happens to correlate with burst length here, but is not chosen to optimise it.

#callout("pitfall", title: [Common mistake])[State your priority convention before you compute anything. "Priority 1" means #emph[most] urgent in most textbooks and lab manuals, and #emph[least] urgent in some real systems --- Linux `nice` values run from $- 20$ (most favourable) to $19$.

Half of all lost marks on scheduling questions come from silently assuming the wrong direction. Write the convention at the top of your answer.]

Priority scheduling can starve a low-priority process indefinitely if urgent work keeps arriving. The standard remedy is #strong[aging]: gradually raise the priority of anything that has waited a long time, so every process eventually becomes urgent enough to run.


#heading(level: 3)[Round Robin]
 #strong[Round Robin] is preemptive. Each process gets at most a #strong[time quantum] $q$, then goes to the back of the queue if unfinished. With $q = 2$ and queue order P1, P2, P3:

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/8e7ccd4588c03826.cetz.json")], caption: [The Round Robin schedule with quantum $q = 2$. P3 needs one unit, less than the quantum, so it finishes in its first turn at time~5.]) <fig:gantt-rr>

Note that P3 finishes early at time 5 despite only getting the CPU third: it needed one unit, which is less than the quantum, so it ran to completion in its first turn.

#block[
l \*5l

Process & $bold(B)$ & $bold(C)$ & $bold(T)$ & $bold(W)$ & $bold(R)$ \
P1 & 5 & 9 & 9 & 4 & 0 \
P2 & 3 & 8 & 8 & 5 & 2 \
P3 & 1 & 5 & 5 & 4 & 4 \
& #strong[7.33 & #strong[4.33 & #strong[2.00 \
]]]

]


#heading(level: 2)[Reading the comparison honestly]
 #figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Policy], [Avg turnaround], [Avg waiting], [Avg response],),
    table.hline(),
    [FCFS], [7.33], [4.33], [4.33],
    [SJF], [#strong[4.67]], [#strong[1.67]], [1.67],
    [Priority], [5.33], [2.33], [2.33],
    [Round Robin ($q = 2$)], [7.33], [4.33], [#strong[2.00]],
  )]
  , kind: table
  )

Round Robin improves first response without making the CPU faster; it changes how waiting is shared. SJF performs best here, but it needs future burst lengths and can delay long jobs indefinitely.

#callout("intuition", title: [Plain idea])[The quantum controls the trade-off. A large quantum makes Round Robin behave like FCFS. A very small quantum improves response but causes more context switches.]


#heading(level: 2)[Drawing a Gantt chart that survives checking]
 Work in this order, every time:

+ Draw the timeline first, marking every instant the CPU changes hands. Do not compute anything yet.

+ Read the completion time $C_i$ off the chart --- the right-hand edge of that process's #emph[last] block.

+ Compute $T_i = C_i - A_i$.

+ Compute $W_i = T_i - B_i$. Never count queue intervals by hand; the subtraction is what stops you double-counting.

+ Read $S_i$ off the chart for $R_i$ --- the left edge of that process's #emph[first] block.

#callout("pitfall", title: [Common mistake])[The most common Round Robin error is computing waiting time by adding up gaps in the chart. With several preemptions there are several gaps per process, and one is always missed.

Use $W = T - B$. It cannot miss a gap, because it never looks at them.]

#callout("tryit", title: [Try it yourself])[Redo the same workload with $q = 1$, then with $q = 5$. Confirm that $q = 5$ reproduces the FCFS chart exactly, and explain in one sentence why.

Then change the arrivals to $A_1 = 0$, $A_2 = 1$, $A_3 = 2$ and redo FCFS. The chart now contains idle time if a process has not arrived yet --- make sure your $C$ values account for it.]

#callout("quickcheck", title: [Check your understanding])[+ Why can Round Robin have the same average waiting time as FCFS but much better response time?

+ A process has $T = 12$ and $B = 15$. What went wrong?

+ Why does SJF need an estimate rather than a measurement?

+ What does aging fix, and which policy needs it?

#strong[Answers.]

+ Waiting time depends only on total time queued, which the same total work distributes similarly. Response time depends on the #emph[first] turn, and RR guarantees every process one within $n times q$ of arriving.

+ An arithmetic error. Waiting time would be $- 3$, and a process cannot exist for less time than it spent running. Recheck $C$, or check that $B$ is total burst rather than remaining burst.

+ $B_i$ is the burst the process is about to request. It is only measurable after the fact, so schedulers predict it from recent history --- typically an exponential average of previous bursts.

+ Starvation. Priority scheduling needs it: without aging, a steady stream of urgent work means a low-priority process may never run at all.]
