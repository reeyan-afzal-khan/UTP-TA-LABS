#import "/.shared/typst/utp.typ": *

#chapter-star[Course Map]

Start with the command-line environment, then follow the operating system from
#strong[processes] to #strong[CPU time], #strong[shared resources], #strong[memory],
and finally #strong[persistent storage]. Each numbered chapter is followed by the
lab that puts that chapter’s ideas into practice, and the capstone brings the five
stages together.

#utpfigure[
  #canvas({
    node((0, 0), [#coursemapcard([STAGE 01], [Orientation], [Linux, the terminal, and the OS])], name: "a", ..card)
    node(right-of("a", 0.66), [#coursemapcard([STAGE 02], [Processes], [Processes, files, and the shell])], name: "b", ..card)
    node(right-of("b", 0.66), [#coursemapcard([STAGE 03], [CPU and concurrency], [Scheduling, IPC, and deadlock])], name: "c", ..card)
    node(below-of("c", 0.58), [#coursemapcard([STAGE 04], [Memory], [Allocation, paging, and replacement])], name: "d", ..card)
    node(left-of("d", 0.66), [#coursemapcard([STAGE 05], [Storage], [Directories, records, and blocks])], name: "e", ..card)
    node(left-of("e", 0.66), [#coursemapcard([CAPSTONE], [Exam map], [Trace state across the course])], name: "f", ..finalcard)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
    connect("d", "e", ..arr)
    connect("e", "f", ..arr)
  })
]

#utptable[
  #tabularx(
    columns: (8%, 31%, 1fr),
    align: (center, left, left),
    styles: (navy-bold,),
    header: ([Stage], [Focus], [Key question]),
    [1], [Linux, the toolchain, and the OS’s role], [Where does the OS sit between a program and the hardware?],
    [2], [Processes, files, and shell automation], [How is live OS state inspected and reported reliably?],
    [3], [Scheduling, IPC, threads, and deadlock], [Why does a policy or a lock change the outcome?],
    [4], [Contiguous allocation, paging, and replacement], [Which placement or victim choice does each policy make, and why?],
    [5], [Directories, records, and block allocation], [How do the names an application sees map to storage below?],
  )
]

#note[
  Learn the idea first, then test it. In every lab, keep three questions visible:
  #strong[What state exists? What event changes it? What rule decides the next state?]
]

#pagebreak()

#heading(depth: 2, numbering: none)[Chapters, labs, and checkpoints]

#utptable[
  #tabularx(
    columns: (8%, 20%, 1fr),
    align: (center, center, left),
    styles: (navy-bold,),
    header: ([Stage], [Where], [Checkpoint]),
    [1], [Setup and the OS primer], [Open, edit, compile, run, and explain where the OS sits between a program and hardware.],
    [2], [Chapters 1--3, Labs 1--3], [Inspect live OS state and build small tools that report it reliably.],
    [3], [Chapters 4--6, Labs 4--6], [Trace state changes and explain why a policy or lock changes the outcome.],
    [4], [Chapters 7--8, Labs 7--8], [Compare policies on the same workload and justify every placement or victim choice.],
    [5], [Chapters 9--10, Labs 9--10], [Separate the names and records seen by applications from the storage structures managed below them.],
  )
]
