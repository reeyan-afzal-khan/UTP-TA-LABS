#import "/.shared/typst/utp.typ": *

#utpfigure(title: [Merge sort: divide and merge])[
  #canvas(x: 1.35cm, {
    let msb = (draw: blue, fill: pale-blue, rounded: 1mm, min-width: 0.72, min-height: 0.62, font: font("script", weight: "bold", fill: navy), inner-xsep: 3.9851pt, inner-ysep: 2.9888pt)
    let msg = (draw: green, fill: pale-teal, rounded: 1mm, min-width: 0.72, min-height: 0.62, font: font("script", weight: "bold", fill: navy), inner-xsep: 3.9851pt, inner-ysep: 2.9888pt)
    node((0, 0), [8 3 6 2 7 1 5 4], name: "l0", font: font("small"), ..msb)
    node((-2.3, -1), [8 3 6 2], name: "l1a", font: font("small"), ..msb)
    node((2.3, -1), [7 1 5 4], name: "l1b", font: font("small"), ..msb)
    node((-3.45, -2), [8 3], name: "l2a", font: font("small"), ..msb)
    node((-1.15, -2), [6 2], name: "l2b", font: font("small"), ..msb)
    node((1.15, -2), [7 1], name: "l2c", font: font("small"), ..msb)
    node((3.45, -2), [5 4], name: "l2d", font: font("small"), ..msb)
    for (x, vv) in ((-4.02, 8), (-2.88, 3), (-1.72, 6), (-0.58, 2), (0.58, 7), (1.72, 1), (2.88, 5), (4.02, 4)) {
      node((x, -3), [#vv], font: font("small"), ..msb)
    }
    connect("l0", "l1a", ..utparrow)
    connect("l0", "l1b", ..utparrow)
    connect("l1a", "l2a", ..utparrow)
    connect("l1a", "l2b", ..utparrow)
    connect("l1b", "l2c", ..utparrow)
    connect("l1b", "l2d", ..utparrow)
    for (p, x) in (("l2a", -4.02), ("l2a", -2.88), ("l2b", -1.72), ("l2b", -0.58), ("l2c", 0.58), ("l2c", 1.72), ("l2d", 2.88), ("l2d", 4.02)) {
      connect(p, (x, -2.75), ..utparrow)
    }
    node((0, 1.05), [DIVIDE], font: font("small"), ..utptag, align: center, text: blue)
    node((0, 0.68), [$log_2 n$ levels], font: font("small"), ..utplabel, align: center, text: blue)
    draw.scope({
      draw.translate((0, -8.1))
      for (x, vv) in ((-4.02, 8), (-2.88, 3), (-1.72, 6), (-0.58, 2), (0.58, 7), (1.72, 1), (2.88, 5), (4.02, 4)) {
        node((x, 0), [#vv], font: font("small"), ..msg)
      }
      node((-3.45, 1), [3 8], name: "m2a", font: font("small"), ..msg)
      node((-1.15, 1), [2 6], name: "m2b", font: font("small"), ..msg)
      node((1.15, 1), [1 7], name: "m2c", font: font("small"), ..msg)
      node((3.45, 1), [4 5], name: "m2d", font: font("small"), ..msg)
      node((-2.3, 2), [2 3 6 8], name: "m1a", font: font("small"), ..msg)
      node((2.3, 2), [1 4 5 7], name: "m1b", font: font("small"), ..msg)
      node((0, 3), [1 2 3 4 5 6 7 8], name: "m0", font: font("small"), ..msg)
      for (p, x) in (("m2a", -4.02), ("m2a", -2.88), ("m2b", -1.72), ("m2b", -0.58), ("m2c", 0.58), ("m2c", 1.72), ("m2d", 2.88), ("m2d", 4.02)) {
        connect((x, 0.28), p, line-width: widths.thick, draw: green, end: tip("Stealth", length: 2.2mm, line: widths.thick))
      }
      connect("m2a", "m1a", line-width: widths.thick, draw: green, end: tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m2b", "m1a", line-width: widths.thick, draw: green, end: tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m2c", "m1b", line-width: widths.thick, draw: green, end: tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m2d", "m1b", line-width: widths.thick, draw: green, end: tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m1a", "m0", line-width: widths.thick, draw: green, end: tip("Stealth", length: 2.2mm, line: widths.thick))
      connect("m1b", "m0", line-width: widths.thick, draw: green, end: tip("Stealth", length: 2.2mm, line: widths.thick))
      node((0, 3.95), [MERGE], font: font("small"), ..utptag, align: center, text: green)
      node((0, 3.58), [$O(n)$ work per level], font: font("small"), ..utplabel, align: center, text: green)
    })
  })
]
