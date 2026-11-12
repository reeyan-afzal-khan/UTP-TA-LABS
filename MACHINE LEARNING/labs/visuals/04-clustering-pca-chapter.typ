#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let bx = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 4.4, min-height: 1.2, align: center, font: font("small", weight: "bold", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.2mm, line: widths.thick))
      node((-4.3, 0), [Supervised \
    $X+y arrow.r.long$ predict $y$], name: "s", ..bx)
      node((4.3, 0), [Unsupervised \
    $X arrow.r.long$ discover structure], name: "u", ..bx)
      connect("s.east", "u.west", ..arr)
      node(along("s.east", "u.west", t: 50%), [remove the supplied label], font: font("script", fill: muted), anchor: "south")
    })
  ]
]
