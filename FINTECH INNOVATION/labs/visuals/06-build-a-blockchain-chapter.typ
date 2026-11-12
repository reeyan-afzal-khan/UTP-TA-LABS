#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let c = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.2, min-height: 0.95, align: center, font: font("script", weight: "bold", fill: navy))
      let auth = (draw: navy, fill: navy, text: white, rounded: 2mm, min-width: 2.7, min-height: 1.15, align: center, font: font("script", weight: "bold"))
      let peer = (draw: teal, fill: pale-teal, shape: "circle", min-size: 1.2, align: center, font: font("script", weight: "bold", fill: navy))
      let arr = (line-width: widths.thick, draw: muted, end: tip("Stealth", length: 1.8mm, line: widths.thick))
      node((-4.3, 0), [Central \
    authoritative ledger], name: "a", ..auth)
      node((-4.3, 2), [User], name: "u1", ..c)
      node((-4.3, -2), [User], name: "u2", ..c)
      connect("u1", "a", ..arr)
      connect("u2", "a", ..arr)
      node((1.7, 1.7), [P1], name: "p1", ..peer)
      node((4.3, 1.7), [P2], name: "p2", ..peer)
      node((1.7, -1.7), [P3], name: "p3", ..peer)
      node((4.3, -1.7), [P4], name: "p4", ..peer)
      connect("p1", "p2", ..arr)
      connect("p2", "p4", ..arr)
      connect("p4", "p3", ..arr)
      connect("p3", "p1", ..arr)
      connect("p1", "p4", ..arr)
      connect("p2", "p3", ..arr)
      node((3, 0), [Distributed copies \
    \+ consensus rules], font: font("script", fill: muted), align: center)
    })
  ]
]
