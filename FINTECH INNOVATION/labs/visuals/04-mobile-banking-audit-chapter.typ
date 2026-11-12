#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let b = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 2.6, min-height: 1.1, align: center, font: font("script", weight: "bold", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
      node((-4.5, 0), [Reactive \
    “show my balance”], name: "a", ..b)
      node((-1.5, 0), [Contextual \
    “show my spending”], name: "b", ..b)
      node((1.5, 0), [Predictive \
    “warn me early”], name: "c", ..b)
      node((4.5, 0), [Assistive \
    “help me act”], name: "d", ..b)
      connect("a", "b", ..arr)
      connect("b", "c", ..arr)
      connect("c", "d", ..arr)
    })
  ]
]
