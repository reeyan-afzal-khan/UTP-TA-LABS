#import "/.shared/typst/utp.typ": *
#unit("chapters", "11-exam-map-and-capstone")

#chapter-star[Revision Map and Capstone Practice]

#heading(depth: 2, numbering: none)[The five exam-solving habits]

Most Operating Systems questions become manageable if you use a repeatable method:

+ #strong[Name the state.] Write the queue, matrices, frame contents, free blocks, or directory nodes before applying a policy.
+ #strong[Name the event.] Arrival, dispatch, quantum expiry, resource request, memory request, page reference, or file-block allocation.
+ #strong[Name the policy.] FCFS, SJF, Priority, RR, Banker’s safety rule, first/best/worst fit, FIFO/LRU/LFU.
+ #strong[Update exactly once.] Change the state according to the event and policy; do not mentally skip intermediate states.
+ #strong[Compute metrics last.] Waiting time, turnaround, page faults, fragmentation, or safe sequence should follow from the completed trace.

#utptable[
  #tabularx(
    columns: (24%, 30%, 1fr),
    styles: (navy-bold,),
    header: ([Question type], [State to draw], [Final evidence]),
    [CPU scheduling], [Ready queue + Gantt chart], [Completion, turnaround, waiting, response],
    [Banker’s algorithm], [Allocation, Max, Need, Work, Finish], [Safe sequence or reason none exists],
    [Memory fit], [Free-block table], [Chosen block + fragment for each request],
    [Page replacement], [Frame table after every reference], [Hit/fault count and victim sequence],
    [File allocation], [Free/used block map], [Valid block mapping with conflicts rejected],
  )
]

#heading(depth: 2, numbering: none)[Capstone practical]

Build one command-line simulator that lets a user choose between CPU scheduling, memory allocation, or page replacement. Separate #emph[policy] from #emph[state]: for example, one common frame-state representation can be reused with FIFO, LRU, and LFU victim-selection functions.

#miniproject[
  #strong[Minimum features.]

  - Scheduling: FCFS, SJF, Priority, RR with a printed Gantt trace and average waiting/turnaround time.
  - Memory: first, best, worst fit with fragmentation results.
  - Virtual memory: FIFO, LRU, LFU with per-reference frames, hits, and faults.
  - Input validation and deterministic tie-breaking rules.
  - A short README explaining assumptions and how to compile/run the program.
]

#decisionmemo[
  When two algorithms give different answers, do not ask only “which is better?” Ask which objective matters: responsiveness, throughput, fairness, memory utilization, implementation overhead, locality, or predictable behavior.
]

#heading(depth: 2, numbering: none)[Final checklist]

#quickcheck[
  + Can you explain the parent/child return values of `fork()` without running code?
  + Can you derive waiting and turnaround time from a Gantt chart?
  + Can you distinguish a race condition from deadlock?
  + Can you compute Need and search for a Banker’s safe sequence?
  + Can you distinguish internal from external fragmentation?
  + Can you trace FIFO, LRU, and LFU one reference at a time?
  + Can you explain why directory hierarchy is not the same thing as physical disk layout?
  + Can you compare text/binary records and contiguous/linked/indexed allocation?
]
