#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let cell = (draw: teal, fill: pale-teal, rounded: 1.5mm, min-width: 1.5, min-height: 0.9, font: font("script", weight: "bold", fill: navy))
      let inp = (draw: blue, fill: pale-blue, rounded: 1.2mm, min-width: 1.2, min-height: 0.6, font: font("script", fill: navy))
      let outp = (draw: orange, fill: pale-orange, rounded: 1.2mm, min-width: 1.5, min-height: 0.6, font: font("script", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 1.8mm, line: widths.thick))
      for (t, x) in ((1, 0), (2, 2.4), (3, 4.8), (24, 8.4)) {
        node((x, 0), [LSTM], name: "c" + str(t), ..cell)
        node((x, -1.4), [$x_(#(t))$], name: "i" + str(t), ..inp)
        connect("i" + str(t), "c" + str(t), ..arr)
      }
      node((6.6, 0), [$dots.c$], font: font("Large", fill: muted))
      connect("c1", "c2", ..arr)
      node(along("c1", "c2", t: 50%), [state], font: font("script", fill: muted), anchor: "south")
      connect("c2", "c3", ..arr)
      node(along("c2", "c3", t: 50%), [state], font: font("script", fill: muted), anchor: "south")
      connect("c3", (6.1, 0), ..arr)
      connect((7.1, 0), "c24", ..arr)
      node((8.4, 1.5), [$hat(y)_25$], name: "o", ..outp)
      connect("c24", "o", ..arr)
      node((4.2, -2.3), [24 hourly demand values go in, one step at a time; the same cell (same weights) is used at every step; \
    the final state predicts the next hour], font: font("script", fill: muted), align: center)
    })
  ]
]
