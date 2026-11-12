#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let n = (shape: "circle", draw: blue, fill: pale-blue, min-size: 0.65, inner-sep: 0pt, font: font("script", fill: navy))
      let h-style = (shape: "circle", draw: teal, fill: pale-teal, min-size: 0.65, inner-sep: 0pt, font: font("script", fill: navy))
      let o = (shape: "circle", draw: orange, fill: pale-orange, min-size: 0.65, inner-sep: 0pt, font: font("script", fill: navy))
      let e = (draw: mix(muted, 55%), line-width: widths.thin)
      for (i, y) in ((1, 1.6), (2, 0.8), (3, 0), (4, -0.8)) {
        node((0, y), [$x_(#(i))$], name: "x" + str(i), ..n)
      }
      for (j, y) in ((1, 1.6), (2, 0.8), (3, 0), (4, -0.8), (5, -1.6)) {
        node((2.6, y), [], name: "h" + str(j), ..h-style)
      }
      for (k, y) in ((1, 0.8), (2, 0), (3, -0.8)) {
        node((5.2, y), [], name: "g" + str(k), ..h-style)
      }
      node((7.8, 0), [$hat(y)$], name: "out", ..o)
      for i in range(1, 5) {
        for j in range(1, 6) {
          connect("x" + str(i), "h" + str(j), ..e)
        }
      }
      for j in range(1, 6) {
        for k in range(1, 4) {
          connect("h" + str(j), "g" + str(k), ..e)
        }
      }
      for k in range(1, 4) {
        connect("g" + str(k), "out", ..e)
      }
      node((0, -1.6), [inputs], font: font("script", fill: muted))
      node((2.6, -2.4), [hidden layer 1 \
    (5 weighted sums, each \
    passed through ReLU)], font: font("script", fill: muted), align: center)
      node((5.2, -1.6), [hidden layer 2], font: font("script", fill: muted))
      node((7.8, -1), [output], font: font("script", fill: muted))
    })
  ]
]
