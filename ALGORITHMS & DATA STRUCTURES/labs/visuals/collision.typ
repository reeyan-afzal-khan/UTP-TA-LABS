#import "/.shared/typst/utp.typ": *

#utpfigure(title: [A hash collision])[
  #canvas({
    node((0, 0.45), [10], name: "a", font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
    node((0, -0.45), [15], name: "b", font: font("small"), ..utphot, min-width: 1, min-height: 0.62)
    node((2.4, 0), [$x mod 5$], name: "h", ..utpstep, fill: pale-teal, draw: teal, min-width: 1.9, min-height: 0.95, font: font("small", weight: "bold", fill: navy))
    connect("a.east", "h.west", ..utpptr)
    connect("b.east", "h.west", ..utpptr, draw: red)
    draw.scope({
      draw.translate((5.4, 0))
      draw.translate((0, 0.7))
      for i in range(0, 5) {
        node((0, -0.66 * i), [], name: "t" + str(i), font: font("small"), ..utpdim, min-width: 1.1, min-height: 0.6)
        node((-0.68, -0.66 * i), [#i], font: font("small"), ..utplabel, anchor: "east")
      }
      node((0, 0), [10], font: font("small"), ..utphot, min-width: 1.1, min-height: 0.6)
    })
    connect("h.east", (4.65, 0.35), ..utpptr, draw: red, line-width: 0.9963pt)
    node((6.3, 0.4), [both want slot 0: \
  #strong[collision]], font: font("small"), ..utplabel, anchor: "west", align: left, text: red)
  })
]
