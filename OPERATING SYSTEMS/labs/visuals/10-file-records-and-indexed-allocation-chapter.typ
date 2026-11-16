#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let b = (draw: blue, fill: pale-blue, rounded: 1mm, min-width: 2.2, min-height: 0.7, font: font("small", weight: "bold", fill: navy))
      let d = (draw: teal, fill: pale-teal, rounded: 1mm, min-width: 1.7, min-height: 0.65, font: font("script", fill: navy))
      let arr = (draw: muted, line-width: widths.thick, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
      node((0, 0), [Index block 7], name: "idx", ..b)
      node(right-of("idx", 2.2), [block 12], name: "d1", ..d, yshift: 1cm)
      node(right-of("idx", 2.2), [block 19], name: "d2", ..d)
      node(right-of("idx", 2.2), [block 31], name: "d3", ..d, yshift: -1cm)
      connect("idx", "d1", ..arr)
      connect("idx", "d2", ..arr)
      connect("idx", "d3", ..arr)
    })
  ]
]
