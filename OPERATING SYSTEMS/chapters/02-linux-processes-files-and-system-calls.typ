#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-linux-processes-files-and-system-calls")

= Processes and the Linux Process Namespace <ch:processes>

#chapterguide[The OS primer and the basic terminal workflow.][distinguish a program from a process, read PID/PPID relationships, explain what `fork()` creates, and relate directory names to the Linux namespace before Lab 1.]

== The picture to remember

A #term[program] is code stored in a file. A #term[process] is a running instance of that code with its own PID, memory, open resources, and execution state.

#utpfig([A program is code in a file; a process is a running instance of it, with a PID, and the kernel keeps its state, PID, and PPID in the process table.], label: <fig:program-process>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3.5, min-height: 1, align: center, font: font("small", fill: navy))
    let live = (..box-style, draw: teal, fill: pale-teal)
    let kern = (..box-style, draw: navy, fill: mix(navy, 10%))
    let ar = (line-width: widths.thick, draw: orange, end: tip("Stealth", length: 2.2mm, line: widths.thick))
    node((-4.2, 0), [Executable file \
  `fork_demo`], name: "file", ..box-style)
    node((0, 0), [Running process \
  PID 4200], name: "proc", ..live)
    node((4.2, 0), [Kernel process table \
  state, PID, PPID], name: "os", ..kern)
    connect("file", "proc", ..ar)
    node(along("file", "proc", t: 50%), [run], font: font("script"), anchor: "south")
    connect("proc", "os", ..ar)
  })
]

== PID and PPID: the minimum process identity

Linux assigns every process a #term[process identifier (PID)]. A process also has a #term[parent process identifier (PPID)]. The shell that launches a command is normally its parent.

```bash
ps -o pid,ppid,state,comm
```

The exact numbers are temporary. The relationship matters more than the number itself.

== What `fork()` changes

`fork()` asks the kernel to create a child process. Both parent and child continue after the call, but the return value tells them which role they are in.

#utpfig([What `fork()` creates. One running process becomes two; parent and child both continue after the call, and its return value tells each which role it has.], label: <fig:fork>)[
  #canvas({
    let processnode = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 4.2, min-height: 1.65, inner-sep: 3mm, align: center, font: font("small", fill: navy))
    let childnode = (..processnode, draw: orange, fill: pale-orange)
    let branch = (line-width: 0.8966pt, draw: teal, rounded: 2mm, end: tip("Stealth", length: 2.3mm, width: 1.8mm, line: 0.8966pt))
    let connector = (line-width: 0.8966pt, draw: teal)
    node((0, 2.8), [#strong[Before fork] \ #v(2.9888pt)
   PID 4200 \ #v(1.9925pt)
  #fsize("script")[one running process]], name: "before", ..processnode)
    node((-3.4, -0.8), [#strong[Parent process] \ #v(2.9888pt)
   PID 4200 (unchanged) \ #v(1.9925pt)
  #fsize("script")[`fork()` returns child PID: 4201]], name: "parent", ..processnode)
    node((3.4, -0.8), [#strong[Child process] \ #v(2.9888pt)
   PID 4201 (new) \ #v(1.9925pt)
  #fsize("script")[`fork()` returns 0]], name: "child", ..childnode)
    coordinate("forkpoint", (0, 1))
    connect("before.south", "forkpoint", ..connector)
    node(along("before.south", "forkpoint", t: 50%), [`fork()`], xshift: 2.9888pt, font: font("script", fill: navy), anchor: "west")
    connect("forkpoint", "-|", "parent.north", ..branch)
    connect("forkpoint", "-|", "child.north", ..branch)
  })
]

#keyidea[
  After a successful `fork()`, there are two independently scheduled processes. Output order can change from run to run unless the program adds synchronization.
]

== Waiting for a child

A parent can use `waitpid()` to wait for a specific child. This is both synchronization and cleanup: the parent can collect the child’s exit status instead of leaving a finished child uncollected.

```c
pid_t child = fork();
if (child > 0) {
    int status;
    waitpid(child, &status, 0);
}
```

== Directories are part of the Linux namespace

A directory is not just a graphical folder. It is a file-system object that maps names to underlying objects. C programs can inspect directory entries with `opendir()`, `readdir()`, and `closedir()`.

#utpfig([A directory maps names to underlying file-system objects. Creating, renaming, or deleting a file changes these names, which is what Lab~1 observes.], label: <fig:directory-names>)[
  #canvas({
    let d = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3.2, min-height: 0.8, font: font("small", weight: "bold", fill: navy))
    let f = (draw: teal, fill: pale-teal, rounded: 1mm, min-width: 2.6, min-height: 0.65, font: font("script", fill: navy))
    let ar = (line-width: widths.thick, draw: muted, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    node((0, 1.5), [Lab01 directory], name: "dir", ..d)
    node((-3.2, -0.2), [`fork_demo.c`], name: "a", ..f)
    node((0, -0.2), [`directory_list.c`], name: "b", ..f)
    node((3.2, -0.2), [`observation.txt`], name: "c", ..f)
    connect("dir", "a", ..ar)
    connect("dir", "b", ..ar)
    connect("dir", "c", ..ar)
  })
]

Creating, renaming, or deleting a file changes these names. That is exactly what Lab 1 will observe.

== Chapter-to-lab bridge

#utptable[
  #tabularx(
    columns: (24%, 1fr, 25%),
    styles: (navy-bold,),
    header: ([Concept], [Commands], [Evidence in Lab 1]),
    [Process identity], [`getpid()`, `getppid()`, `ps`], [PID/PPID table],
    [Process creation], [`fork()`, `waitpid()`], [parent/child output],
    [Directory namespace], [`opendir()`, `readdir()`], [before/after names],
  )
]
