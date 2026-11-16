#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3.5, min-height: 1, align: center, font: font("small", fill: navy))
      let live = (..box-style, draw: teal, fill: pale-teal)
      let kern = (..box-style, draw: navy, fill: mix(navy, 10%))
      let ar = (line-width: widths.thick, draw: orange, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
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
]
