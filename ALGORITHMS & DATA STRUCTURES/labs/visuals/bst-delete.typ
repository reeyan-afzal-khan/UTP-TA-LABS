#import "/.shared/typst/utp.typ": *

#utpfigure(title: [The three BST deletion cases])[
  #canvas({
    draw.scope({
      node((0, 1.35), [#strong[1\. Leaf]], font: font("small"), ..utplabel, anchor: "south", align: center, text: navy)
      node((0, 0.55), [8], name: "a0", font: font("small"), ..utpnode, min-size: 0.7)
      node((-0.85, -0.45), [4], name: "a1", font: font("small"), ..utpnode, min-size: 0.7)
      node((0.85, -0.45), [12], name: "a2", font: font("small"), ..utpnode, min-size: 0.7)
      node((-1.5, -1.45), [2], name: "a3", font: font("small"), ..utpdim, shape: "circle", min-size: 0.7)
      connect("a0", "a1", ..utpedge)
      connect("a0", "a2", ..utpedge)
      connect("a1", "a3", ..utpedge, draw: mix(muted, 40%))
      connect((-1.75, -1.7), (-1.25, -1.2), draw: red, line-width: 0.6974pt)
      connect((-1.75, -1.2), (-1.25, -1.7), draw: red, line-width: 0.6974pt)
      node((0, -2), [delete it, \
  clear the parent link], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((5, 0))
      node((0, 1.35), [#strong[2\. One child]], font: font("small"), ..utplabel, anchor: "south", align: center, text: navy)
      node((0, 0.55), [8], name: "b0", font: font("small"), ..utpnode, min-size: 0.7)
      node((-0.85, -0.45), [4], name: "b1", font: font("small"), ..utpnodehot, min-size: 0.7)
      node((0.85, -0.45), [12], name: "b2", font: font("small"), ..utpnode, min-size: 0.7)
      node((-1.5, -1.45), [2], name: "b3", font: font("small"), ..utpnodedone, min-size: 0.7)
      connect("b0", "b1", ..utpedge)
      connect("b0", "b2", ..utpedge)
      connect("b1", "b3", ..utpedge)
      curve("b3.west", "b1.west", (-2.35, -1.35), (-2.35, -0.35), dash: (2.9888pt, 1.4944pt), shorten-start: 2.4907pt, shorten-end: 2.4907pt, draw: white, line-width: 2.9888pt, end: tip("Stealth", length: 2.7mm, width: 1.9mm, line: 2.9888pt))
      curve("b3.west", "b1.west", (-2.35, -1.35), (-2.35, -0.35), draw: green, line-width: 1.0461pt, dash: (2.9888pt, 1.4944pt), shorten-start: 2.4907pt, shorten-end: 2.4907pt, end: tip("Stealth", length: 2.7mm, width: 1.9mm, line: 1.0461pt))
      node((0, -2), [promote the child \
  into the gap], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((10.6, 0))
      node((0, 1.35), [#strong[3\. Two children]], font: font("small"), ..utplabel, anchor: "south", align: center, text: navy)
      node((0, 0.55), [8], name: "c0", font: font("small"), ..utpnodehot, min-size: 0.7)
      node((-0.9, -0.45), [4], name: "c1", font: font("small"), ..utpnode, min-size: 0.7)
      node((0.9, -0.45), [12], name: "c2", font: font("small"), ..utpnode, min-size: 0.7)
      node((0.25, -1.45), [10], name: "c3", font: font("small"), ..utpnodedone, min-size: 0.7)
      node((1.55, -1.45), [14], name: "c4", font: font("small"), ..utpnode, min-size: 0.7)
      connect("c0", "c1", ..utpedge)
      connect("c0", "c2", ..utpedge)
      connect("c2", "c3", ..utpedge)
      connect("c2", "c4", ..utpedge)
      curve("c3.south-west", "c0.west", (-1.9, -1.75), (-1.9, 0.85), dash: (2.9888pt, 1.4944pt), shorten-start: 2.4907pt, shorten-end: 2.4907pt, draw: white, line-width: 2.9888pt, end: tip("Stealth", length: 2.7mm, width: 1.9mm, line: 2.9888pt))
      curve("c3.south-west", "c0.west", (-1.9, -1.75), (-1.9, 0.85), draw: green, line-width: 1.0461pt, dash: (2.9888pt, 1.4944pt), shorten-start: 2.4907pt, shorten-end: 2.4907pt, end: tip("Stealth", length: 2.7mm, width: 1.9mm, line: 1.0461pt))
      node((0.2, -2), [copy up the inorder successor, \
  then delete it below], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]
