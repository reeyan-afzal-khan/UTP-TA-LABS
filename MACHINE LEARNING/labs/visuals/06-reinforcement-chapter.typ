#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3, min-height: 1.2, align: center, font: font("normal", weight: "bold", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2.4mm, line: widths.thick))
      node((0, 0), [Agent \
    chooses an action], name: "agent", ..box-style)
      node(right-of("agent", 3.5), [Environment \
    changes state], name: "env", ..box-style)
      connect("agent.north-east", "env.north-west", bend: 18deg, ..arr, name: "curve-1")
      node((name: "curve-1", anchor: 50%), [action $a_t$], font: font("small"), anchor: "south")
      connect("env.south-west", "agent.south-east", bend: 18deg, ..arr, name: "curve-2")
      node((name: "curve-2", anchor: 50%), [state $s_(t+1)$, reward $r_(t+1)$], font: font("small"), anchor: "north")
    })
  ]
]
