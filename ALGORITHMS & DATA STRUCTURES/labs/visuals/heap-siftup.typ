#import "/.shared/typst/utp.typ": *

#utpfigure(title: [Sift-up during heap insertion])[
  #canvas({
    draw.scope({
      node((1.05, 1), [90], name: "r1", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.15, 0.05), [70], name: "l1", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.95, 0.05), [60], name: "q1", font: font("small"), ..utpnode, min-size: 0.75)
      node((2.55, -0.9), [95], name: "x1", font: font("small"), ..utpnodehot, min-size: 0.75)
      connect("r1", "l1", ..utpedge)
      connect("r1", "q1", ..utpedge)
      connect("q1", "x1", ..utpedge)
      node((1.05, -1.55), [#strong[1\.] append at index 6 \
  $95>60$: violation], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((4.6, 0))
      node((1.05, 1), [90], name: "r2", font: font("small"), ..utpnode, min-size: 0.75)
      node((0.15, 0.05), [70], name: "l2", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.95, 0.05), [95], name: "q2", font: font("small"), ..utpnodehot, min-size: 0.75)
      node((2.55, -0.9), [60], name: "x2", font: font("small"), ..utpnode, min-size: 0.75)
      connect("r2", "l2", ..utpedge)
      connect("r2", "q2", ..utpedge)
      connect("q2", "x2", ..utpedge)
      curve("x2.east", "q2.east", (3.2, -0.72), (3.05, 0.02), shorten-start: 2.4907pt, shorten-end: 2.4907pt, draw: white, line-width: 2.9888pt, end: tip("Stealth", length: 2.2mm, width: 1.5mm, line: 2.9888pt))
      curve("x2.east", "q2.east", (3.2, -0.72), (3.05, 0.02), draw: orange, line-width: 1.0461pt, shorten-start: 2.4907pt, shorten-end: 2.4907pt, end: tip("Stealth", length: 2.2mm, width: 1.5mm, line: 1.0461pt))
      node((1.05, -1.55), [#strong[2\.] swap with parent \
  $95>90$: still violated], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((9.2, 0))
      node((1.05, 1), [95], name: "r3", font: font("small"), ..utpnodedone, min-size: 0.75)
      node((0.15, 0.05), [70], name: "l3", font: font("small"), ..utpnode, min-size: 0.75)
      node((1.95, 0.05), [90], name: "q3", font: font("small"), ..utpnode, min-size: 0.75)
      node((2.55, -0.9), [60], name: "x3", font: font("small"), ..utpnode, min-size: 0.75)
      connect("r3", "l3", ..utpedge)
      connect("r3", "q3", ..utpedge)
      connect("q3", "x3", ..utpedge)
      curve("q3.east", "r3.east", (2.8, 0.28), (2.35, 1.2), shorten-start: 2.4907pt, shorten-end: 2.4907pt, draw: white, line-width: 2.9888pt, end: tip("Stealth", length: 2.2mm, width: 1.5mm, line: 2.9888pt))
      curve("q3.east", "r3.east", (2.8, 0.28), (2.35, 1.2), draw: green, line-width: 1.0461pt, shorten-start: 2.4907pt, shorten-end: 2.4907pt, end: tip("Stealth", length: 2.2mm, width: 1.5mm, line: 1.0461pt))
      node((1.05, -1.55), [#strong[3\.] swap again \
  root reached: done], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]
