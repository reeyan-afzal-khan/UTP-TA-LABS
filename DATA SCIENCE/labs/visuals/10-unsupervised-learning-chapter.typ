#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 15.06cm, {
      let stage = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.5978pt, text-width: 0.26 * 15.06, min-height: 1.55, inner-xsep: 2.5mm, inner-ysep: 2mm, align: center, font: font("script", fill: navy))
      let flow = (line-width: 0.797pt, draw: teal, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.797pt))
      let repeatflow = (..flow, draw: muted, rounded: 2mm)
      node((0, 0), [#strong[1\. Initialise] \ #v(3.9851pt)
     Choose $k$ \
    initial centres], name: "init", ..stage)
      node((0.335, 0), [#strong[2\. Assign] \ #v(3.9851pt)
     Assign each observation \
    to its nearest centre], name: "assign", ..stage)
      node((0.67, 0), [#strong[3\. Update] \ #v(3.9851pt)
     Recompute the \
    cluster centres], name: "update", ..stage, draw: mix(teal, 80%), fill: pale-teal)
      connect("init.east", "assign.west", ..flow)
      connect("assign.east", "update.west", ..flow)
      connect("update.south", (0.67, -1.4), (0.335, -1.4), "assign.south", ..repeatflow)
      node(along((0.67, -1.4), (0.335, -1.4), t: 50%), [Repeat until convergence], yshift: -2.9888pt, font: font("script", fill: muted), anchor: "north")
    })
  ]
]
