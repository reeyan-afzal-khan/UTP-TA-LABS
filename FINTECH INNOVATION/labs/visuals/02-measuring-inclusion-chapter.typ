#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let side = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 5.4, min-height: 3, align: left, inner-sep: 3mm, font: font("script", fill: navy))
      let side2 = (draw: orange, fill: pale-orange, rounded: 2mm, text-width: 5.4, min-height: 3, align: left, inner-sep: 3mm, font: font("script", fill: navy))
      let center = (draw: navy, fill: navy, text: white, rounded: 2mm, text-width: 2.4, min-height: 1.2, align: center, font: font("small", weight: "bold"))
      let arr = (line-width: widths.thick, draw: muted, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
      node((-4, 0), [#strong[Demand side] #parbreak() #v(3pt)small/volatile income #parbreak() distance #parbreak() missing documents #parbreak() low literacy #parbreak() distrust #parbreak() negative history], name: "d", ..side)
      node((0, 0), [FINANCIAL \
    EXCLUSION], name: "x", ..center)
      node((4, 0), [#strong[Supply side] #parbreak() #v(3pt)high branch cost #parbreak() legacy IT #parbreak() manual processes #parbreak() standardized products #parbreak() weak competition #parbreak() limited innovation], name: "s", ..side2)
      connect("d.east", "x.west", ..arr)
      connect("s.west", "x.east", ..arr)
    })
  ]
]
