#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-linux-processes-files-and-system-calls")


#heading(level: 1)[Processes and the Linux Process Namespace]
<ch:processes> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* The OS primer and the basic terminal workflow.

*By the end, you can:* distinguish a program from a process, read PID/PPID relationships, explain what `fork()` creates, and relate directory names to the Linux namespace before Lab 1.]


#heading(level: 2)[The picture to remember]
 A #strong[program] is code stored in a file. A #strong[process] is a running instance of that code with its own PID, memory, open resources, and execution state.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/4c8063afacd6a941.cetz.json")], caption: [A program is code in a file; a process is a running instance of it, with a PID, and the kernel keeps its state, PID, and PPID in the process table.]) <fig:program-process>


#heading(level: 2)[PID and PPID: the minimum process identity]
 Linux assigns every process a #strong[process identifier (PID)]. A process also has a #strong[parent process identifier (PPID)]. The shell that launches a command is normally its parent.

#code-block("ps -o pid,ppid,state,comm", lang: "bash")

The exact numbers are temporary. The relationship matters more than the number itself.


#heading(level: 2)[What `fork()` changes]
 `fork()` asks the kernel to create a child process. Both parent and child continue after the call, but the return value tells them which role they are in.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/3bc065c93c1573de.cetz.json")], caption: [What `fork()` creates. One running process becomes two; parent and child both continue after the call, and its return value tells each which role it has.]) <fig:fork>

#callout("keyidea", title: [Key idea])[After a successful `fork()`, there are two independently scheduled processes. Output order can change from run to run unless the program adds synchronization.]


#heading(level: 2)[Waiting for a child]
 A parent can use `waitpid()` to wait for a specific child. This is both synchronization and cleanup: the parent can collect the child's exit status instead of leaving a finished child uncollected.

#code-block("pid_t child = fork();\nif (child > 0) {\n    int status;\n    waitpid(child, &status, 0);\n}", lang: "c")


#heading(level: 2)[Directories are part of the Linux namespace]
 A directory is not just a graphical folder. It is a file-system object that maps names to underlying objects. C programs can inspect directory entries with `opendir()`, `readdir()`, and `closedir()`.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/9069b9011d63bdb5.cetz.json")], caption: [A directory maps names to underlying file-system objects. Creating, renaming, or deleting a file changes these names, which is what Lab~1 observes.]) <fig:directory-names>

Creating, renaming, or deleting a file changes these names. That is exactly what Lab 1 will observe.


#heading(level: 2)[Chapter-to-lab bridge]
 #figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Concept], [Commands], [Evidence in Lab 1],),
    table.hline(),
    [Process identity], [`getpid()`, `getppid()`, `ps`], [PID/PPID table],
    [Process creation], [`fork()`, `waitpid()`], [parent/child output],
    [Directory namespace], [`opendir()`, `readdir()`], [before/after names],
  )]
  , kind: table
  )
