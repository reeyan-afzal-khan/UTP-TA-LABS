#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.7, min-height: 0.9, align: center, font: font("small", weight: "bold", fill: navy))
      let policy = (draw: mix(orange, 70%, other: black), fill: pale-orange, rounded: 1.5mm, min-width: 1.55, min-height: 0.65, align: center, font: font("script", weight: "bold", fill: mix(orange, 85%, other: black)))
      let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
      node((0, 0), [State \
    representation], name: "state", ..box-style)
      node(right-of("state", 0.7), [Successor \
    function], name: "succ", ..box-style)
      node(right-of("succ", 0.7), [Frontier \
    policy], name: "frontier", ..box-style)
      node(right-of("frontier", 0.7), [Goal test \
    and result], name: "result", ..box-style)
      connect("state", "succ", ..arr)
      connect("succ", "frontier", ..arr)
      connect("frontier", "result", ..arr)
      node(below-of("frontier", 0.75), [BFS: depth], name: "bfs", ..policy, xshift: -3.2cm)
      node(right-of("bfs", 0.18), [DFS: recency], name: "dfs", ..policy)
      node(right-of("dfs", 0.18), [UCS: $g$], name: "ucs", ..policy)
      node(right-of("ucs", 0.18), [GBFS: $h$], name: "gbfs", ..policy)
      node(right-of("gbfs", 0.18), [A\*: $g+h$], name: "astar", ..policy)
      connect("ucs.north", "frontier.south", ..arr)
      node((0.55, -2.35), [swap one line $arrow.r$ different algorithm], font: font("script", fill: muted))
    })
  ]
]
