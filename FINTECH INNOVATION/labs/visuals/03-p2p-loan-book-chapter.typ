#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let p = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 2.6, min-height: 1.15, align: center, font: font("small", weight: "bold", fill: navy))
      let mid = (draw: navy, fill: white, rounded: 2mm, text-width: 3.4, min-height: 1.4, align: center, font: font("small", weight: "bold", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2.1mm, line: widths.thick))
      let head = (font: font("small", weight: "bold", fill: navy),)
      let risk = (font: font("script", fill: red), align: center, text-width: 4.4)
      let ring = (draw: red, dash: "dashed", rounded: 2.5mm, line-width: 0.797pt)
      node((0, 1.55), [Traditional intermediation], ..head)
      node((-4.6, 0), [Savers], name: "s1", ..p)
      node((0, 0), [Bank \
    own balance sheet], name: "k1", ..mid)
      node((4.6, 0), [Borrowers], name: "b1", ..p)
      connect("s1", "k1", ..arr)
      node(along("s1", "k1", t: 50%), [deposits], font: font("script"), anchor: "south")
      connect("k1", "b1", ..arr)
      node(along("k1", "b1", t: 50%), [loans], font: font("script"), anchor: "south")
      rectangle((-1.85, -0.78), (1.85, 0.78), ..ring)
      node((0, -1.2), [a default is absorbed here, behind reserves and deposit insurance], ..risk)
      node((0, -2.55), [Marketplace funding], ..head)
      node((-4.6, -4.05), [Lenders], name: "s2", ..p)
      node((0, -4.05), [Platform \
    matches, scores, services], name: "k2", ..mid)
      node((4.6, -4.05), [Borrowers], name: "b2", ..p)
      connect("s2", "k2", ..arr)
      node(along("s2", "k2", t: 50%), [capital], font: font("script"), anchor: "south")
      connect("k2", "b2", ..arr)
      node(along("k2", "b2", t: 50%), [loans], font: font("script"), anchor: "south")
      rectangle((-6, -4.83), (-3.2, -3.27), ..ring)
      node((-4.6, -5.25), [a default is absorbed here, by the individual lender], ..risk)
    })
  ]
]
