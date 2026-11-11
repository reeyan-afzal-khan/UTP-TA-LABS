#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-operating-systems-at-a-glance")


#heading(level: 1, numbering: none)[Where to Begin: What an Operating System Does]
<ch:overview> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* No operating-systems background is required. Be comfortable opening a terminal and running a command.

*By the end, you can:* explain what an operating system manages, distinguish kernel and user space, and connect processes, files, memory, and devices to the labs that follow.]


#heading(level: 2, numbering: none)[Start with something you have already done]
 Open a terminal and type `ls`. A list of filenames appears. Nothing about that is obvious once you look closely:

- Your shell was running. It had to #emph[stop] doing that and start a different program.

- `ls` needed memory --- but so does every other program currently running, and none of them interfered.

- The filenames live as magnetic or flash state on a disk. Something turned that into text.

- The output reached your screen, which `ls` does not own and cannot address directly.

Four different subsystems cooperated, and you typed two letters. The #strong[operating system (OS)] is the software that made all four happen.

#callout("keyidea", title: [Key idea])[An OS does two jobs at once. It is an #emph[abstraction layer], turning awkward hardware into workable objects like processes, files, and memory addresses. It is also a #emph[resource manager], deciding who gets what, for how long, and with what permission.

Nearly every design decision in this course comes from those two jobs pulling in different directions.]


#heading(level: 2, numbering: none)[The layers involved]
 Your program sits at the top. The hardware sits at the bottom. Everything between is the OS's responsibility.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/OPERATING SYSTEMS/figures/diagrams/962128a05f1b066e.svg")], caption: [The layers of a running system, from applications through the system interface and the kernel down to the hardware. Every downward step goes through the interface directly beneath it.]) <fig:os-layers>

Read the diagram as a rule about #emph[reach]. An application cannot skip a layer. It cannot address the disk controller, and it cannot read another process's memory. Every downward step goes through the interface directly beneath it.


#heading(level: 2, numbering: none)[Kernel mode and user mode]
 That restriction is enforced by the CPU itself, not by good manners.

Modern processors run in at least two privilege levels. Your programs run in #strong[user mode], where privileged instructions and direct hardware access are simply unavailable --- attempting them traps instead of executing. The kernel runs in #strong[kernel mode], where everything is permitted.

Control crosses that boundary in exactly three ways, and it is worth memorising them now because the rest of the course keeps returning to them:

/ System call: #block[
The program #emph[asks]. It wants something only the kernel can do.
]

/ Exception: #block[
The current instruction #emph[cannot proceed] --- divide by zero, bad memory access, page fault.
]

/ Interrupt: #block[
Hardware #emph[demands attention] --- a timer tick, a keypress, a disk finishing a read.
]

#callout("intuition", title: [Plain idea])[User mode is a blast wall. A buggy program should be free to crash itself, and unable to take down the machine, corrupt another process's memory, or reprogram a disk controller on its way out.

This is why an infinite loop in your code does not freeze the whole computer. The timer interrupt fires regardless of what your program is doing, and control returns to the kernel whether your program likes it or not.]


#heading(level: 2, numbering: none)[System calls are the operating-system API]
 A #strong[system call] is a request for a service that needs kernel authority. They group into a handful of families:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Family], [What it does], [Seen in this course],),
    table.hline(),
    [Process control], [Create, terminate, wait for, or replace a running program], [`fork()`, `waitpid()` in Lab 1],
    [File management], [Open, read, write, seek, close, inspect metadata], [`fopen()`, `fgetc()` in Lab 2],
    [Device management], [Read and write devices, configure device state], [Chapters 9--10],
    [Information], [Process identifiers, time, resource limits], [`getpid()` in Lab 1],
    [Communication], [Pipes, shared memory, message queues, sockets, signals], [Lab 5],
    [Protection], [Permissions, identities, access checks], [Chapter 2],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[`printf()` is not a system call. It is a C library function that formats your text and then calls `write()`, which is the system call.

The distinction matters more than it sounds. The library buffers output, so `printf()` may return long before anything reaches the screen. In Lab 1 you fork a process, and both parent and child inherit a copy of that buffer --- which is how a single `printf()` can produce output twice. Add `fflush(stdout)` before `fork()` and the duplicate disappears.]


#heading(level: 2, numbering: none)[One command, every subsystem]
 Return to `ls`, and trace it properly. The shell creates a process. The scheduler decides when it runs. Virtual memory hands it an address space that appears to start at zero regardless of where it physically sits. The file system turns the pathname into a location. The storage stack reads blocks. An interrupt announces the read finished. The terminal driver receives the output.

#callout("keyidea", title: [Key idea])[The topics in this course are not a list of separate features. They are cooperating subsystems, and almost every non-trivial program execution needs all of them at once.

Each later chapter zooms in on one of the steps above.]


#heading(level: 2, numbering: none)[Program, process, and thread]
 These three words get used loosely in conversation and precisely in operating systems. The difference is worth getting right early.

A #strong[program] is passive: instructions and data sitting in a file. It does nothing. A #strong[process] is a running instance of a program, with state --- registers, program counter, address space, open files, scheduling information, credentials. A #strong[thread] is a single flow of execution inside a process.

#callout("analogy", title: [Analogy])[A program is a recipe. A process is one cook actually working from it, with their own bench space, ingredients, and half-finished pan. A thread is a pair of hands.

Two cooks working from the same recipe do not share a bench --- that is two processes. Two pairs of hands belonging to one cook share everything on that bench --- that is two threads, and it is exactly why threads need locks and processes usually do not.]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Concept], [Owns / represents], [Typical question],),
    table.hline(),
    [Program], [Executable instructions and static data], [What code could run?],
    [Process], [Resource container plus execution state], [Which running instance is this?],
    [Thread], [Schedulable execution flow], [Which sequence of instructions runs now?],
  )]
  , kind: table
  )

Running the same program twice gives two processes. They have different process IDs, separate memory, and no ability to see each other's variables. You will observe this directly in Lab 1: after `fork()`, parent and child both continue from the same line with the same variables --- and changing a variable in one has no effect on the other.


#heading(level: 2, numbering: none)[The process-state model]
 A process is not always running. Most of the time it is waiting for something. The standard five-state model captures that:

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/OPERATING SYSTEMS/figures/diagrams/cf418f32f038ed7f.svg")], caption: [The five-state process model. Running to Ready is preemption; Running to Waiting is blocking.]) <fig:process-states>

Two arrows deserve attention, because students routinely confuse them.

#emph[Running to Ready] is #strong[preemption]. The process was perfectly able to continue; the OS stopped it anyway, usually because its time slice expired. This is the arrow Round Robin in Chapter 4 depends on.

#emph[Running to Waiting] is #strong[blocking]. The process cannot continue --- it asked for data from disk and the data is not there yet. No scheduling policy can help; only the event can.

#callout("pitfall", title: [Common mistake])["Ready" does not mean idle. A ready process wants the CPU right now and cannot have it, because another process is using it. On a busy machine, the ready queue is where processes spend most of their existence.]

#callout("quickcheck", title: [Check your understanding])[+ Why does an application need a system call to create another process?

+ What do threads in one process share, and what stays private to each?

+ Name one event that moves a running process into the waiting state.

+ A process sits in Ready for 200 ms. Is it blocked? What is it waiting for?

#strong[Answers.]

+ Creating a process means allocating an address space, a process-table entry, and an identity. All of those are kernel-owned structures, and letting user code write them directly would remove every protection guarantee the OS makes.

+ Shared: address space, open-file table, code, globals, and the heap. Private: registers, program counter, and stack. Sharing the heap is exactly why two threads writing one variable need a lock.

+ A read from disk, waiting on a child with `waitpid()`, or blocking on a semaphore --- anything where the process cannot proceed until an external event occurs.

+ Not blocked. Ready means it is able to run and is waiting only for a turn on the CPU. A blocked process waits for an event; a ready one waits for the scheduler.]
