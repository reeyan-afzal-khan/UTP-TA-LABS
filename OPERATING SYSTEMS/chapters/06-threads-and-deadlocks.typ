#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-threads-and-deadlocks")


#heading(level: 1)[Threads, Resource Allocation, and Deadlocks]
<ch:deadlock> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Chapter 5: shared state, race conditions, and synchronization.

*By the end, you can:* distinguish processes from threads, use a mutex to protect a critical section, identify the four deadlock conditions, and reason about safe states in Lab 6.]


#heading(level: 2)[POSIX threads]
 The POSIX threads API creates multiple execution streams inside one process. `pthread_create()` starts a thread, `pthread_self()` identifies the calling thread, `pthread_equal()` compares thread identifiers, and `pthread_join()` waits for completion.

#code-block("pthread_t t;\nint err = pthread_create(&t, NULL, worker, NULL);\nif (err != 0) {\n    /* handle error */\n}\npthread_join(t, NULL);", lang: "c")

#callout("pitfall", title: [Common mistake])[Thread identifiers are opaque values. Portable code compares them with `pthread_equal()` rather than assuming they are ordinary integers with a specific representation.]


#heading(level: 2)[Mutexes]
 A #strong[mutex] protects a critical section so only one thread owns the lock at a time. The normal lifecycle is initialize, lock, access shared state, unlock, then destroy after all users are finished.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/27e67442bf1fa9a5.cetz.json")], caption: [What the threads of one process share. Code, globals, and the heap exist once and are seen by every thread; each thread has its own stack and registers, which need no synchronization.]) <fig:thread-memory>


#heading(level: 2)[What deadlock means]
 A #strong[deadlock] is a state in which a set of processes or threads are permanently blocked because each waits for an event that only another member of the set can cause.

Four Coffman conditions must hold simultaneously for resource deadlock:

+ #strong[Mutual exclusion]: at least one resource cannot be shared concurrently.

+ #strong[Hold and wait]: a process holds resources while requesting more.

+ #strong[No preemption]: resources cannot simply be taken away.

+ #strong[Circular wait]: a cycle of processes each waits for a resource held by the next.

Breaking any one condition prevents this class of deadlock.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/7e08644ea28e49f4.cetz.json")], caption: [A circular wait. P1 holds R1 and requests R2, while P2 holds R2 and requests R1, so neither can proceed.]) <fig:circular-wait>


#heading(level: 2)[Prevention, avoidance, and detection]
 #figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Strategy], [Core idea], [Trade-off],),
    table.hline(),
    [Prevention], [Design the protocol so a Coffman condition cannot hold], [Can reduce utilization or flexibility],
    [Avoidance], [Grant a request only if the resulting state remains safe], [Requires future maximum-demand information],
    [Detection/recovery], [Allow deadlock, detect it later, then recover], [Detection and recovery can be expensive],
  )]
  , kind: table
  )


#heading(level: 2)[Banker's algorithm]
 Banker's algorithm avoids unsafe allocations. First calculate `Need = Max - Allocation`. Start with `Work = Available`, then find a process whose needs fit within Work. Assume it finishes and returns its allocation to Work. If every process can finish in some order, the state is #strong[safe].

#callout("workedexample", title: [Worked example])[Suppose Available is $\( 1 \, 1 \)$, P1 has Need $\( 1 \, 0 \)$ and Allocation $\( 1 \, 1 \)$, while P2 has Need $\( 2 \, 1 \)$ and Allocation $\( 1 \, 0 \)$. P1 can finish first because $\( 1 \, 0 \) lt.eq \( 1 \, 1 \)$. Work becomes $\( 2 \, 2 \)$, allowing P2 to finish. Therefore a safe sequence is P1, P2.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/78e9420fdf7451b4.cetz.json")], caption: [The Banker's safety check for the worked example. P1's need fits within Work, so it can finish and release its allocation; the larger Work then lets P2 finish, so P1, P2 is a safe sequence.]) <fig:bankers>

#callout("pitfall", title: [Common mistake])[An #strong[unsafe state] is not identical to an already existing deadlock. Unsafe means the OS can no longer guarantee that every future maximum claim can be satisfied in some order. Deadlock is an actual circular waiting condition.]


#heading(level: 2)[Detection versus the supplied exercise]
 A textbook deadlock-detection algorithm normally uses current outstanding requests rather than each process's declared future maximum. The supplied lab calculates `Need = Max - Allocation`; this is close to a safety/avoidance test. Treat the code as a useful matrix exercise, but keep the conceptual distinction clear.
