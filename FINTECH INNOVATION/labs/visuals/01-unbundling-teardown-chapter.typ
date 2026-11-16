#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let p = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3.2, min-height: 1.25, align: center, font: font("small", weight: "bold", fill: navy))
      let bank = (draw: navy, fill: navy, text: white, rounded: 2mm, min-width: 3.5, min-height: 1.55, align: center, font: font("small", weight: "bold"))
      let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
      node((0, 0), [Savers \
    deposits], name: "s", ..p)
      node(right-of("s", 1.1), [Traditional bank \
    intermediary], name: "b", ..bank)
      node(right-of("b", 1.1), [Borrowers \
    loans], name: "r", ..p)
      connect("s", "b", ..arr)
      node(along("s", "b", t: 50%), [funds], font: font("script"), anchor: "south")
      connect("b", "r", ..arr)
      node(along("b", "r", t: 50%), [credit], font: font("script"), anchor: "south")
      connect("r", "b", bend: 24deg, ..arr, name: "curve-1")
      node((name: "curve-1", anchor: 50%), [interest + repayment], font: font("script"), anchor: "north")
      connect("b", "s", bend: 24deg, ..arr, name: "curve-2")
      node((name: "curve-2", anchor: 50%), [interest], font: font("script"), anchor: "north")
    })
  ]
]
