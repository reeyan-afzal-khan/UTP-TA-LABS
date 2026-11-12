#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      connect((-0.2, 0), (15.2, 0), draw: mix(muted, 45%), line-width: 0.6974pt)
      for x in (0.9, 4.6, 8.3, 12.9) {
        connect((x, -0.12), (x, 0.12), draw: mix(muted, 45%))
      }
      for (x, era) in ((0.9, "1960s"), (4.6, "1970s"), (8.3, "1980s"), (12.9, "1990s onward")) {
        node((x, 0), [#era], ..procnote, yshift: -1.5mm, anchor: "north")
      }
      node((0.9, 1.35), [#strong[Inventory control \ #v(-0.15em)
    #fsize("tiny")[What do we have \
    #fsize("tiny")[in the store?]]]], name: "a", ..procquiet, min-width: 3.1, min-height: 1.35, align: center)
      node((4.6, 1.35), [MRP \ #v(-0.15em)
    #fsize("tiny")[#text(weight: "regular")[Which materials, \
    #fsize("tiny")[#text(weight: "regular")[and by when?]]]]], name: "b", ..procstep, min-width: 3.1, min-height: 1.35)
      node((8.3, 1.35), [MRP II \ #v(-0.15em)
    #fsize("tiny")[#text(weight: "regular")[Materials #emph[and] \
    #fsize("tiny")[#text(weight: "regular")[capacity, cost, labour]]]]], name: "c", ..procstep, min-width: 3.1, min-height: 1.35, draw: teal, fill: pale-teal)
      node((12.9, 1.35), [ERP \ #v(-0.15em)
    #fsize("tiny")[#text(weight: "regular")[Company-wide processes \
    #fsize("tiny")[#text(weight: "regular")[on shared data]]]]], name: "d", ..procstep, min-width: 4.1, min-height: 1.35, draw: green, fill: pale-teal)
      connect("a", "b", ..procflow)
      connect("b", "c", ..procflow)
      connect("c", "d", ..procflow)
      node((-0.2, 3.05), [#strong[scope: one store room #h(1em)$arrow.r.long$#h(1em)one factory]], ..proccap, anchor: "west", text-width: 7, align: left)
      node((15.2, 3.05), [#strong[$arrow.r.long$#h(1em)one enterprise]], ..proccap, anchor: "east", text-width: 5, align: right)
      connect((-0.2, 2.6), (15.2, 2.6), draw: mix(blue, 35%), line-width: 1.9925pt, end: tip("Stealth", length: 3mm, line: 1.9925pt))
    })
  ]
]
