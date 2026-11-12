#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Inorder, preorder and postorder compared][
  #labgraphic[
    #canvas(compact: true, {
      draw.scope({
        draw.translate((0, 0))
        node((0, 1.35), [Inorder], font: font("normal", weight: "bold", fill: navy))
        node((0, 0.55), [A], name: "n1", font: font("small"), ..utpnode, min-size: 0.75)
        node((-0.95, -0.45), [B], name: "n2", font: font("small"), ..utpnode, min-size: 0.75)
        node((0.95, -0.45), [C], name: "n3", font: font("small"), ..utpnode, min-size: 0.75)
        node((-1.5, -1.45), [D], name: "n4", font: font("small"), ..utpnode, min-size: 0.75)
        node((-0.4, -1.45), [E], name: "n5", font: font("small"), ..utpnode, min-size: 0.75)
        connect("n1", "n2", ..utpedge)
        connect("n1", "n3", ..utpedge)
        connect("n2", "n4", ..utpedge)
        connect("n2", "n5", ..utpedge)
        for (nd, ord) in (("n4", 1), ("n2", 2), ("n5", 3), ("n1", 4), ("n3", 5)) {
          node((rel: (0.055, 0.055), to: nd + ".north-east"), [#ord], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
        }
        node((0, -2.05), [left, #strong[root], right], font: font("small"), ..utplabel, anchor: "north", align: center, text: muted)
        node((0, -2.42), [D B E A C], font: font("small"), ..utplabel, anchor: "north", align: center)
      })
      draw.scope({
        draw.translate((5.6, 0))
        node((0, 1.35), [Preorder], font: font("normal", weight: "bold", fill: navy))
        node((0, 0.55), [A], name: "n1", font: font("small"), ..utpnode, min-size: 0.75)
        node((-0.95, -0.45), [B], name: "n2", font: font("small"), ..utpnode, min-size: 0.75)
        node((0.95, -0.45), [C], name: "n3", font: font("small"), ..utpnode, min-size: 0.75)
        node((-1.5, -1.45), [D], name: "n4", font: font("small"), ..utpnode, min-size: 0.75)
        node((-0.4, -1.45), [E], name: "n5", font: font("small"), ..utpnode, min-size: 0.75)
        connect("n1", "n2", ..utpedge)
        connect("n1", "n3", ..utpedge)
        connect("n2", "n4", ..utpedge)
        connect("n2", "n5", ..utpedge)
        for (nd, ord) in (("n1", 1), ("n2", 2), ("n4", 3), ("n5", 4), ("n3", 5)) {
          node((rel: (0.055, 0.055), to: nd + ".north-east"), [#ord], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
        }
        node((0, -2.05), [#strong[root], left, right], font: font("small"), ..utplabel, anchor: "north", align: center, text: muted)
        node((0, -2.42), [A B D E C], font: font("small"), ..utplabel, anchor: "north", align: center)
      })
      draw.scope({
        draw.translate((11.2, 0))
        node((0, 1.35), [Postorder], font: font("normal", weight: "bold", fill: navy))
        node((0, 0.55), [A], name: "n1", font: font("small"), ..utpnode, min-size: 0.75)
        node((-0.95, -0.45), [B], name: "n2", font: font("small"), ..utpnode, min-size: 0.75)
        node((0.95, -0.45), [C], name: "n3", font: font("small"), ..utpnode, min-size: 0.75)
        node((-1.5, -1.45), [D], name: "n4", font: font("small"), ..utpnode, min-size: 0.75)
        node((-0.4, -1.45), [E], name: "n5", font: font("small"), ..utpnode, min-size: 0.75)
        connect("n1", "n2", ..utpedge)
        connect("n1", "n3", ..utpedge)
        connect("n2", "n4", ..utpedge)
        connect("n2", "n5", ..utpedge)
        for (nd, ord) in (("n4", 1), ("n5", 2), ("n2", 3), ("n3", 4), ("n1", 5)) {
          node((rel: (0.055, 0.055), to: nd + ".north-east"), [#ord], shape: "circle", fill: orange, text: white, font: font("tiny", weight: "bold"), inner-sep: 1.0959pt)
        }
        node((0, -2.05), [left, right, #strong[root]], font: font("small"), ..utplabel, anchor: "north", align: center, text: muted)
        node((0, -2.42), [D E B C A], font: font("small"), ..utplabel, anchor: "north", align: center)
      })
    })
  ]
]
