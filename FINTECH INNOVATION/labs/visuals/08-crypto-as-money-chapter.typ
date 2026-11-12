#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let p = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 2.5, min-height: 1, align: center, font: font("script", weight: "bold", fill: navy))
      let net = (draw: teal, fill: pale-teal, rounded: 2mm, text-width: 3.1, min-height: 1.3, align: center, font: font("script", weight: "bold", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
      let bad = (line-width: widths.thick, dash: "dashed", draw: red, end: tip("Stealth", length: 2mm, line: widths.thick))
      node((-4.5, 0), [Alice], name: "a", ..p)
      node((0, 0), [Shared network \
    validates spend history], name: "n", ..net)
      node((4.5, 1.2), [Bob], name: "b", ..p)
      node((4.5, -1.2), [Charlie], name: "c", ..p)
      connect("a", "n", ..arr)
      node(along("a", "n", t: 50%), [signed spend], font: font("script"), anchor: "south")
      connect("n", "b", ..arr)
      connect("a", "n", bend: -18deg, ..bad, name: "curve-1")
      node((name: "curve-1", anchor: 50%), [conflicting second spend?], font: font("script"), anchor: "north")
      connect("n", "c", ..bad)
    })
  ]
]
