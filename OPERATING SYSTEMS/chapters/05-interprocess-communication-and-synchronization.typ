#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-interprocess-communication-and-synchronization")

= Interprocess Communication and Synchronization <ch:ipc>

#chapterguide[Chapter 1: processes and Chapter 3: standard input/output and pipelines.][compare pipes and shared memory, identify a critical section and race condition, and explain why shared state requires synchronization before Lab 5.]

== Concurrency creates more than one valid execution order

When two activities can make progress at the same time, their individual instructions may interleave in several valid ways. The operating system may preempt one process or thread, run another, and later return to the first.

If the activities touch only private state, this may not matter. If they both read and update the same state, the exact interleaving can change the result.

== Race conditions and critical sections

A #term[race condition] occurs when correctness depends on timing that the program has not controlled. Suppose two workers both execute “read counter, add one, write counter.” If both read the same old value before either writes, one increment is lost.

The code that must behave as one indivisible logical action is called a #term[critical section]. A synchronization mechanism prevents unsafe overlap.

#keyidea[
  Synchronization is not about forcing the whole program to run one step at a time. It protects only the state transition that must not be interleaved incorrectly.
]

== Mutexes and semaphores in plain language

A #term[mutex] is commonly used to give one thread at a time exclusive access to a critical section. A #term[semaphore] maintains a count that can represent available units of a resource or coordinate producer-consumer conditions.

#utptable[
  #tabularx(
    columns: (22%, 32%, 1fr),
    styles: (navy-bold,),
    header: ([Mechanism], [Think of it as], [Typical use]),
    [Mutex], [one key to a protected region], [protect a shared counter or data structure],
    [Counting semaphore], [a controlled count of available units], [free slots, queued items, limited resources],
  )
]

== Producer-consumer and the bounded buffer

A bounded buffer with capacity $N$ can be reasoned about using two counts:

$ mono("empty") + mono("full") = N. $

A producer requires an empty slot before adding an item. A consumer requires a full slot before removing one. In a real concurrent implementation, checking and changing these synchronization values must itself be performed safely.

#workedexample[
  For capacity 3, the initial state may be `empty=3, full=0`. After one successful production it becomes `empty=2, full=1`. A fourth production without any intervening consumption must wait because no empty slot remains.
]

== Communication and synchronization are different questions

Processes have separate address spaces, so they need an interprocess communication (IPC) mechanism to exchange data. Common models include:

#utptable[
  #tabularx(
    columns: (19%, 35%, 1fr),
    styles: (navy-bold,),
    header: ([IPC model], [Main idea], [Introductory trade-off]),
    [Pipe], [ordered byte stream between endpoints], [simple flow, usually directional],
    [Message queue], [discrete messages managed by the kernel], [message boundaries are preserved],
    [Shared memory], [multiple processes map the same memory region], [fast sharing, but concurrent writers need coordination],
    [Socket], [endpoint-based communication], [works locally or across networks],
  )
]

== A pipe moves data; shared memory exposes common data

With a pipe, one process writes bytes and another reads them. Data conceptually travels through a kernel-managed channel.

With shared memory, processes attach the same kernel-managed memory object into their separate address spaces. The bytes do not need to be copied through a read/write stream each time, but the processes must agree on when data is ready and who may modify it.

#pitfall[
  Shared memory solves the “where can both processes see the data?” problem. It does not by itself solve the “who may update it now?” problem.
]

== System V shared-memory lifecycle

The lab uses System V shared memory because its lifecycle is visible:

+ create or locate a key;
+ create/find a segment with `shmget`;
+ attach it with `shmat`;
+ read or write the shared bytes;
+ detach with `shmdt`;
+ remove the segment with `shmctl(..., IPC_RMID, ...)`.

The `ipcs -m` command lets students observe these kernel-managed objects while they exist.

== How to reason about synchronization problems

For an introductory problem, ask four questions:

+ What state is shared?
+ What invariant should always remain true?
+ Which operation changes that state?
+ What must wait when the required condition is not available?

This approach is more reliable than memorising a sequence of `wait()` and `signal()` calls without understanding the state they protect.

#quickcheck[
  + Why can shared memory require synchronization even after both processes attach successfully?
  + What invariant holds for `empty` and `full` in a fixed-capacity buffer?
  + What is one conceptual difference between a pipe and shared memory?
]
