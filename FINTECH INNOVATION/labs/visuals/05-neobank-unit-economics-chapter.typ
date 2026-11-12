#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let b = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 2.65, min-height: 1.25, align: center, font: font("script", weight: "bold", fill: navy))
      let g = (draw: green, fill: pale-teal, rounded: 2mm, text-width: 2.65, min-height: 1.25, align: center, font: font("script", weight: "bold", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
      node((-4.5, 0), [Modern modular \
    technology], name: "a", ..b)
      node((-1.5, 0), [Lower servicing \
    cost], name: "b", ..b)
      node((1.5, 0), [Fast product and \
    CX iteration], name: "c", ..b)
      node((4.5, 0), [Scale + customer \
    engagement], name: "d", ..g)
      connect("a", "b", ..arr)
      connect("b", "c", ..arr)
      connect("c", "d", ..arr)
    })
  ]
]
