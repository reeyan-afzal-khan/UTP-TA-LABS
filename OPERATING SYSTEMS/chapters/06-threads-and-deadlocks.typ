#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-threads-and-deadlocks")

= Threads, Resource Allocation, and Deadlocks <ch:deadlock>

#chapterguide[Chapter 5: shared state, race conditions, and synchronization.][distinguish processes from threads, use a mutex to protect a critical section, identify the four deadlock conditions, and reason about safe states in Lab 6.]

== POSIX threads

The POSIX threads API creates multiple execution streams inside one process. `pthread_create()` starts a thread, `pthread_self()` identifies the calling thread, `pthread_equal()` compares thread identifiers, and `pthread_join()` waits for completion.

```c
pthread_t t;
int err = pthread_create(&t, NULL, worker, NULL);
if (err != 0) {
    /* handle error */
}
pthread_join(t, NULL);
```

#warning[
  Thread identifiers are opaque values. Portable code compares them with `pthread_equal()` rather than assuming they are ordinary integers with a specific representation.
]

== Mutexes

A #term[mutex] protects a critical section so only one thread owns the lock at a time. The normal lifecycle is initialize, lock, access shared state, unlock, then destroy after all users are finished.

#utpfig([What the threads of one process share. Code, globals, and the heap exist once and are seen by every thread; each thread has its own stack and registers, which need no synchronization.], label: <fig:thread-memory>)[
  #canvas({
    let seg = (draw: blue, fill: pale-blue, min-width: 3, min-height: 0.8, font: font("script", fill: navy))
    let shared = (..seg, fill: pale-orange, draw: orange)
    let stk = (draw: teal, fill: pale-teal, min-width: 1.7, min-height: 0.8, font: font("script", fill: navy))
    let lab = (font: font("script", fill: muted), align: center)
    let warn = (font: font("script", fill: orange), align: center)
    rectangle((-2.1, -2.75), (8.7, 1.75), draw: navy, rounded: 2mm, line-width: 0.8966pt)
    node((-2, 1.65), [one process], font: font("small", weight: "bold", fill: navy), anchor: "north-west")
    node((-0.4, 0.85), [code (text)], ..seg)
    node((-0.4, -0.35), [globals], ..shared)
    node((-0.4, -1.55), [heap], ..shared)
    node((-0.4, -2.3), [one copy, seen by every thread], ..lab, text-width: 2.6)
    for (i, x) in ((1, 2.9), (2, 5.2), (3, 7.5)) {
      node((x, 0.85), [stack #i], ..stk)
      node((x, -0.35), [registers #i], ..stk)
      node((x, -1.08), [thread #i], ..lab)
    }
    node((5.2, -2.05), [private to each thread --- no synchronisation needed], ..lab, text-width: 5.6)
    node((3.3, -3.55), [The orange region is the whole reason a mutex exists. Two threads writing a global without one is a data race, and the outcome depends on scheduling --- which is why such a bug reproduces only sometimes.], ..warn, text-width: 11)
  })
]

== What deadlock means

A #term[deadlock] is a state in which a set of processes or threads are permanently blocked because each waits for an event that only another member of the set can cause.

Four Coffman conditions must hold simultaneously for resource deadlock:

+ #strong[Mutual exclusion]: at least one resource cannot be shared concurrently.
+ #strong[Hold and wait]: a process holds resources while requesting more.
+ #strong[No preemption]: resources cannot simply be taken away.
+ #strong[Circular wait]: a cycle of processes each waits for a resource held by the next.

Breaking any one condition prevents this class of deadlock.

#utpfig([A circular wait. P1 holds R1 and requests R2, while P2 holds R2 and requests R1, so neither can proceed.], label: <fig:circular-wait>)[
  #canvas({
    let proc = (shape: "circle", draw: blue, fill: pale-blue, min-size: 1.05, font: font("small", weight: "bold", fill: navy))
    let res = (draw: navy, fill: white, min-width: 1.05, min-height: 0.9, font: font("small", weight: "bold", fill: navy))
    let cyc = (line-width: 0.9963pt, draw: red, end: arrow-tip("Stealth", length: 2.3mm, line: 0.9963pt))
    let lab = (font: font("script", fill: muted),)
    let note = (font: font("script", fill: ink), align: center)
    node((0, 2.5), [P1], name: "p1", ..proc)
    node((5, 2.5), [R2], name: "r2", ..res)
    node((5, 0), [P2], name: "p2", ..proc)
    node((0, 0), [R1], name: "r1", ..res)
    connect("p1", "r2", ..cyc)
    node(along("p1", "r2", t: 50%), [requests], ..lab, anchor: "south")
    connect("r2", "p2", ..cyc)
    node(along("r2", "p2", t: 50%), [assigned to], ..lab, anchor: "west")
    connect("p2", "r1", ..cyc)
    node(along("p2", "r1", t: 50%), [requests], ..lab, anchor: "north")
    connect("r1", "p1", ..cyc)
    node(along("r1", "p1", t: 50%), [assigned to], ..lab, anchor: "east")
    node((2.5, 1.25), [the cycle #emph[is] the circular wait --- neither process can move, and nothing outside the cycle will move them], ..note, text-width: 4.2)
    node((2.5, -1.15), [Each resource has one instance, so this cycle is a deadlock. Remove any one arrow --- by preemption, by releasing before requesting, or by ordering the resources --- and the cycle opens.], ..note, text-width: 11, text: muted)
  })
]

== Prevention, avoidance, and detection

#utptable[
  #tabularx(
    columns: (22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Strategy], [Core idea], [Trade-off]),
    [Prevention], [Design the protocol so a Coffman condition cannot hold], [Can reduce utilization or flexibility],
    [Avoidance], [Grant a request only if the resulting state remains safe], [Requires future maximum-demand information],
    [Detection/recovery], [Allow deadlock, detect it later, then recover], [Detection and recovery can be expensive],
  )
]

== Banker’s algorithm

Banker’s algorithm avoids unsafe allocations. First calculate
`Need = Max - Allocation`. Start with `Work = Available`, then
find a process whose needs fit within Work. Assume it finishes and returns its
allocation to Work. If every process can finish in some order, the state is
#term[safe].

#example[
  Suppose Available is $(1,1)$, P1 has Need $(1,0)$ and Allocation $(1,1)$, while P2 has Need $(2,1)$ and Allocation $(1,0)$. P1 can finish first because $(1,0) <= (1,1)$. Work becomes $(2,2)$, allowing P2 to finish. Therefore a safe sequence is P1, P2.
]

#utpfig([The Banker’s safety check for the worked example. P1’s need fits within Work, so it can finish and release its allocation; the larger Work then lets P2 finish, so P1, P2 is a safe sequence.], label: <fig:bankers>)[
  #canvas({
    let wk = (draw: teal, fill: pale-teal, rounded: 1.5mm, min-width: 1.5, min-height: 0.75, font: font("small", weight: "bold", fill: navy))
    let test = (draw: blue, fill: pale-blue, rounded: 1.5mm, text-width: 3, min-height: 1.15, align: center, font: font("script", fill: navy))
    let go = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
    let wcap = (font: font("script", weight: "bold", fill: muted),)
    let rel = (font: font("script", fill: green), align: center)
    node((0, 1.15), [Work = Available], ..wcap)
    node((0, 0.35), [(1, 1)], name: "w0", ..wk)
    node((3.5, 0.35), [P1 needs (1, 0) \
  $(1,0) <= (1,1)$ --- P1 can finish], name: "t1", ..test)
    node((7, 0.35), [(2, 2)], name: "w1", ..wk)
    node((7, -0.62), [P1 releases (1, 1)], ..rel)
    node((10.5, 0.35), [P2 needs (2, 1) \
  $(2,1) <= (2,2)$ --- P2 can finish], name: "t2", ..test)
    node((14, 0.35), [(3, 2)], name: "w2", ..wk)
    connect("w0", "t1", ..go)
    connect("t1", "w1", ..go)
    connect("w1", "t2", ..go)
    connect("t2", "w2", ..go)
    node((7, -1.55), [Every process fits into the order, so the state is #strong[safe] and the safe sequence is P1, P2. Had P1 failed its test as well, no order would exist and the request would be refused --- not because deadlock had happened, but because it could no longer be ruled out.], font: font("script", fill: ink), align: center, text-width: 13)
  })
]

#warning[
  An #term[unsafe state] is not identical to an already existing deadlock. Unsafe means the OS can no longer guarantee that every future maximum claim can be satisfied in some order. Deadlock is an actual circular waiting condition.
]

== Detection versus the supplied exercise

A textbook deadlock-detection algorithm normally uses current outstanding requests rather than each process’s declared future maximum. The supplied lab calculates `Need = Max - Allocation`; this is close to a safety/avoidance test. Treat the code as a useful matrix exercise, but keep the conceptual distinction clear.
