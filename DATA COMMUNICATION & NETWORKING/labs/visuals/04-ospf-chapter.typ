#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let db = (shape: "rectangle", rounded: 1mm, draw: teal, fill: pale-teal, min-width: 2.5, min-height: 0.95, align: center, font: font("script", fill: navy))
      let ml = (font: font("script", fill: muted), align: center)
      node((0, 0), [R1], name: "r1", ..router)
      node(right-of("r1", 2.2), [R2], name: "r2", ..router)
      node(right-of("r2", 2.2), [R3], name: "r3", ..router)
      connect("r1", "r2", ..netlink)
      connect("r2", "r3", ..netlink)
      connect("r1", "r3", bend: -32deg, ..netlink, name: "curve-1")
      node(below-of("r1", 1.15), [identical \
     link-state DB], name: "d1", ..db)
      node(below-of("r2", 1.15), [identical \
     link-state DB], name: "d2", ..db)
      node(below-of("r3", 1.15), [identical \
     link-state DB], name: "d3", ..db)
      connect("d1", "d2", line-width: widths.thick, draw: teal, start: arrow-tip("to", line: widths.thick), end: arrow-tip("to", line: widths.thick))
      node(along("d1", "d2", t: 50%), [flood], ..ml, anchor: "south")
      connect("d2", "d3", line-width: widths.thick, draw: teal, start: arrow-tip("to", line: widths.thick), end: arrow-tip("to", line: widths.thick))
      node(along("d2", "d3", t: 50%), [flood], ..ml, anchor: "south")
      node(below-of("d2", 0.45), [Same database everywhere. Each router then runs Dijkstra #strong[from itself], so the routing tables all differ --- and all agree.], ..ml, text-width: 9.5)
    })
  ]
]
