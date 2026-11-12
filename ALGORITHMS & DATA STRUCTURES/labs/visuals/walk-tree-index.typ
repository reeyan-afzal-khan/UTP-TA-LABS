#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[A binary tree stored in an array][
  #labgraphic[
    #canvas(compact: true, {
      node((2.55, 1.5), [8], name: "v0", font: font("small"), ..utpnode, min-size: 0.8)
      node((1.25, 0.45), [4], name: "v1", font: font("small"), ..utpnode, min-size: 0.8)
      node((3.85, 0.45), [12], name: "v2", font: font("small"), ..utpnode, min-size: 0.8)
      node((0.6, -0.6), [2], name: "v3", font: font("small"), ..utpnode, min-size: 0.8)
      node((1.9, -0.6), [6], name: "v4", font: font("small"), ..utpnode, min-size: 0.8)
      connect("v0", "v1", ..utpedge)
      connect("v0", "v2", ..utpedge)
      connect("v1", "v3", ..utpedge)
      connect("v1", "v4", ..utpedge)
      for (n, idx) in (("v0", 0), ("v1", 1), ("v2", 2), ("v3", 3), ("v4", 4)) {
        node((rel: (0.06, 0.06), to: n + ".north-east"), [#idx], shape: "circle", fill: blue, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
      }
      draw.scope({
        draw.translate((0, -2.35))
        for (i, vv) in (8, 4, 12, 2, 6).enumerate() {
          node((1.05 * i, 0), [#vv], name: "g" + str(i), font: font("small"), ..utpcell, min-width: 1, min-height: 0.82)
          node((1.05 * i, 0.55), [#i], name: "arrayindex" + str(i), shape: "circle", fill: blue, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
        }
        node((-0.65, 0), [array], font: font("small"), ..utplabel, anchor: "east")
      })
      curve("v1.east", (2.55, -0.35), (2.15, 0.45), (2.55, 0.22), ..utpptr, draw: orange, dash: "dashed")
      curve((2.55, -0.35), (2.55, -1.5), (2.55, -0.95), (2.55, -1.38), ..utpptr, draw: orange, dash: "dashed")
      curve((2.55, -1.5), (1.575, -1.55), (2.35, -1.62), (1.9, -1.55), ..utpptr, draw: orange, dash: "dashed")
      connect((1.575, -1.55), "arrayindex1.center", ..utpptr, draw: orange, dash: "dashed")
      node((6.6, -0.1), [index 1 holds 4 \
    children: $2(1)+1=3$ \
    #hide[children:]$2(1)+2=4$ \
    $arrow.r$ 2 and 6 ✓], font: font("small"), ..utptag, anchor: "west", align: left)
    })
  ]
]
