#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-operating-systems-at-a-glance")

#chapter-star[Where to Begin: What an Operating System Does]

 <ch:overview>

#chapterguide[No operating-systems background is required. Be comfortable opening a terminal and running a command.][explain what an operating system manages, distinguish kernel and user space, and connect processes, files, memory, and devices to the labs that follow.]

#heading(depth: 2, numbering: none)[Start with something you have already done]

Open a terminal and type `ls`. A list of filenames appears. Nothing about that is obvious once you look closely:

- Your shell was running. It had to #emph[stop] doing that and start a different program.
- `ls` needed memory --- but so does every other program currently running, and none of them interfered.
- The filenames live as magnetic or flash state on a disk. Something turned that into text.
- The output reached your screen, which `ls` does not own and cannot address directly.

Four different subsystems cooperated, and you typed two letters. The #term[operating system (OS)] is the software that made all four happen.

#keyidea[
  An OS does two jobs at once. It is an #emph[abstraction layer], turning awkward hardware into workable objects like processes, files, and memory addresses. It is also a #emph[resource manager], deciding who gets what, for how long, and with what permission.

  Nearly every design decision in this course comes from those two jobs pulling in different directions.
]

#heading(depth: 2, numbering: none)[The layers involved]

Your program sits at the top. The hardware sits at the bottom. Everything between is the OS’s responsibility.

#utpfig([The layers of a running system, from applications through the system interface and the kernel down to the hardware. Every downward step goes through the interface directly beneath it.], label: <fig:os-layers>)[
  #canvas({
    let layer-style = (draw: blue, rounded: 2mm, text-width: 12, min-height: 0.85, inner-xsep: 4mm, inner-ysep: 1mm, align: center, font: font("footnote", fill: navy))
    let flow = (line-width: widths.semithick, draw: muted, end: tip("Stealth", length: 1.6mm, width: 1.3mm, line: widths.semithick))
    node((0, 0), [#strong[Applications] \ #v(0.9963pt)
   shell, editor, browser, compiler, and user programs], name: "apps", ..layer-style, fill: pale-blue)
    node(below-of("apps", 0.25), [#strong[System interface] \ #v(0.9963pt)
   standard libraries and the system-call interface], name: "sys", ..layer-style, fill: pale-teal)
    node(below-of("sys", 0.25), [#strong[Kernel] \ #v(0.9963pt)
   process scheduling, memory, file systems, and device drivers], name: "kernel", ..layer-style, fill: pale-orange)
    node(below-of("kernel", 0.25), [#strong[Hardware] \ #v(0.9963pt)
   CPU, RAM, storage, timers, network, and I/O devices], name: "hw", ..layer-style, fill: pale-gray)
    connect("apps.south", "sys.north", ..flow)
    connect("sys.south", "kernel.north", ..flow)
    connect("kernel.south", "hw.north", ..flow)
  })
]

Read the diagram as a rule about #emph[reach]. An application cannot skip a layer. It cannot address the disk controller, and it cannot read another process’s memory. Every downward step goes through the interface directly beneath it.

#heading(depth: 2, numbering: none)[Kernel mode and user mode]

That restriction is enforced by the CPU itself, not by good manners.

Modern processors run in at least two privilege levels. Your programs run in #term[user mode], where privileged instructions and direct hardware access are simply unavailable --- attempting them traps instead of executing. The kernel runs in #term[kernel mode], where everything is permitted.

Control crosses that boundary in exactly three ways, and it is worth memorising them now because the rest of the course keeps returning to them:

/ System call: The program #emph[asks]. It wants something only the kernel can do.
/ Exception: The current instruction #emph[cannot proceed] --- divide by zero, bad memory access, page fault.
/ Interrupt: Hardware #emph[demands attention] --- a timer tick, a keypress, a disk finishing a read.

#intuition[
  User mode is a blast wall. A buggy program should be free to crash itself, and unable to take down the machine, corrupt another process’s memory, or reprogram a disk controller on its way out.

  This is why an infinite loop in your code does not freeze the whole computer. The timer interrupt fires regardless of what your program is doing, and control returns to the kernel whether your program likes it or not.
]

#heading(depth: 2, numbering: none)[System calls are the operating-system API]

A #term[system call] is a request for a service that needs kernel authority. They group into a handful of families:

#utptable[
  #tabularx(
    columns: (22%, 1fr, 26%),
    styles: (navy-bold,),
    header: ([Family], [What it does], [Seen in this course]),
    [Process control], [Create, terminate, wait for, or replace a running program], [`fork()`, `waitpid()` in Lab 1],
    [File management], [Open, read, write, seek, close, inspect metadata], [`fopen()`, `fgetc()` in Lab 2],
    [Device management], [Read and write devices, configure device state], [Chapters 9--10],
    [Information], [Process identifiers, time, resource limits], [`getpid()` in Lab 1],
    [Communication], [Pipes, shared memory, message queues, sockets, signals], [Lab 5],
    [Protection], [Permissions, identities, access checks], [Chapter 2],
  )
]

#pitfall[
  `printf()` is not a system call. It is a C library function that formats your text and then calls `write()`, which is the system call.

  The distinction matters more than it sounds. The library buffers output, so `printf()` may return long before anything reaches the screen. In Lab 1 you fork a process, and both parent and child inherit a copy of that buffer --- which is how a single `printf()` can produce output twice. Add `fflush(stdout)` before `fork()` and the duplicate disappears.
]

#heading(depth: 2, numbering: none)[One command, every subsystem]

Return to `ls`, and trace it properly. The shell creates a process. The scheduler decides when it runs. Virtual memory hands it an address space that appears to start at zero regardless of where it physically sits. The file system turns the pathname into a location. The storage stack reads blocks. An interrupt announces the read finished. The terminal driver receives the output.

#keyidea[
  The topics in this course are not a list of separate features. They are cooperating subsystems, and almost every non-trivial program execution needs all of them at once.

  Each later chapter zooms in on one of the steps above.
]

#heading(depth: 2, numbering: none)[Program, process, and thread]

These three words get used loosely in conversation and precisely in operating systems. The difference is worth getting right early.

A #term[program] is passive: instructions and data sitting in a file. It does nothing. A #term[process] is a running instance of a program, with state --- registers, program counter, address space, open files, scheduling information, credentials. A #term[thread] is a single flow of execution inside a process.

#analogy[
  A program is a recipe. A process is one cook actually working from it, with their own bench space, ingredients, and half-finished pan. A thread is a pair of hands.

  Two cooks working from the same recipe do not share a bench --- that is two processes. Two pairs of hands belonging to one cook share everything on that bench --- that is two threads, and it is exactly why threads need locks and processes usually do not.
]

#utptable[
  #tabularx(
    columns: (auto, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Concept], [Owns / represents], [Typical question]),
    [Program], [Executable instructions and static data], [What code could run?],
    [Process], [Resource container plus execution state], [Which running instance is this?],
    [Thread], [Schedulable execution flow], [Which sequence of instructions runs now?],
  )
]

Running the same program twice gives two processes. They have different process IDs, separate memory, and no ability to see each other’s variables. You will observe this directly in Lab 1: after `fork()`, parent and child both continue from the same line with the same variables --- and changing a variable in one has no effect on the other.

#heading(depth: 2, numbering: none)[The process-state model]

A process is not always running. Most of the time it is waiting for something. The standard five-state model captures that:

#utpfig([The five-state process model. Running to Ready is preemption; Running to Waiting is blocking.], label: <fig:process-states>)[
  #canvas({
    let st = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.1, min-height: 0.8, align: center, font: font("small", weight: "bold", fill: navy))
    let arr = (draw: teal, line-width: widths.thick, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [New], name: "new", ..st)
    node((3.6, 0), [Ready], name: "ready", ..st)
    node((7.2, 0), [Running], name: "run", ..st)
    node((11, 0), [Terminated], name: "term", ..st)
    node((7.2, -2.3), [Waiting], name: "wait", ..st)
    connect("new", "ready", ..arr)
    node(along("new", "ready", t: 50%), [admit], font: font("script"), anchor: "south")
    connect("ready", "run", ..arr)
    node(along("ready", "run", t: 50%), [dispatch], font: font("script"), anchor: "south")
    connect("run", "term", ..arr)
    node(along("run", "term", t: 50%), [exit], font: font("script"), anchor: "south")
    connect("run", "wait", ..arr)
    node(along("run", "wait", t: 50%), [wait for I/O], font: font("script"), anchor: "west")
    connect("run.south-west", "ready.south-east", bend: 38deg, ..arr, name: "curve-1")
    node((name: "curve-1", anchor: 50%), [preempt], font: font("script"), anchor: "north")
    coordinate("eventturn", (3.6, -2.3))
    connect("wait.west", "eventturn", "ready.south", ..arr)
    node(along("wait.west", "eventturn", t: 50%), [event done], font: font("script"), anchor: "north")
  })
]

Two arrows deserve attention, because students routinely confuse them.

#emph[Running to Ready] is #term[preemption]. The process was perfectly able to continue; the OS stopped it anyway, usually because its time slice expired. This is the arrow Round Robin in Chapter 4 depends on.

#emph[Running to Waiting] is #term[blocking]. The process cannot continue --- it asked for data from disk and the data is not there yet. No scheduling policy can help; only the event can.

#pitfall[
  “Ready” does not mean idle. A ready process wants the CPU right now and cannot have it, because another process is using it. On a busy machine, the ready queue is where processes spend most of their existence.
]

#quickcheck[
  + Why does an application need a system call to create another process?
  + What do threads in one process share, and what stays private to each?
  + Name one event that moves a running process into the waiting state.
  + A process sits in Ready for 200 ms. Is it blocked? What is it waiting for?

  #v(6pt)
  #strong[Answers.]

  + Creating a process means allocating an address space, a process-table entry, and an identity. All of those are kernel-owned structures, and letting user code write them directly would remove every protection guarantee the OS makes.
  + Shared: address space, open-file table, code, globals, and the heap. Private: registers, program counter, and stack. Sharing the heap is exactly why two threads writing one variable need a lock.
  + A read from disk, waiting on a child with `waitpid()`, or blocking on a semaphore --- anything where the process cannot proceed until an external event occurs.
  + Not blocked. Ready means it is able to run and is waiting only for a turn on the CPU. A blocked process waits for an event; a ready one waits for the scheduler.
]
