#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[General binary-tree deletion: copy the last level-order value, then remove its leaf][
  #labgraphic[
    #canvas(compact: true, {
      draw.scope({
        draw.translate((0, 0))
        draw.translate((0, 0))
        node((0, 0.65), [Updated 6 to 7; inserted 10], font: font("small"), ..utplabel, anchor: "south", text: navy)
        node((0, 0), [8], name: "n0", font: font("small"), ..utpnode, min-size: 0.7)
        node((-1.4, -1), [4], name: "n1", font: font("small"), ..utpnode, min-size: 0.7)
        node((1.4, -1), [12], name: "n2", font: font("small"), ..utpnode, min-size: 0.7)
        node((-2.1, -2), [2], name: "n3", font: font("small"), ..utpnode, min-size: 0.7)
        node((-0.7, -2), [7], name: "n4", font: font("small"), ..utpnodehot, min-size: 0.7)
        node((0.7, -2), [10], name: "n5", font: font("small"), ..utpnodehot, min-size: 0.7)
        connect("n0", "n1", ..utpedge)
        connect("n0", "n2", ..utpedge)
        connect("n1", "n3", ..utpedge)
        connect("n1", "n4", ..utpedge)
        connect("n2", "n5", ..utpedge)
      })
      draw.scope({
        draw.translate((7, 0))
        draw.translate((0, 0))
        node((0, 0.65), [Deleted the value 4], font: font("small"), ..utplabel, anchor: "south", text: navy)
        node((0, 0), [8], name: "n0", font: font("small"), ..utpnode, min-size: 0.7)
        node((-1.4, -1), [10], name: "n1", font: font("small"), ..utpnodehot, min-size: 0.7)
        node((1.4, -1), [12], name: "n2", font: font("small"), ..utpnode, min-size: 0.7)
        node((-2.1, -2), [2], name: "n3", font: font("small"), ..utpnode, min-size: 0.7)
        node((-0.7, -2), [7], name: "n4", font: font("small"), ..utpnode, min-size: 0.7)
        connect("n0", "n1", ..utpedge)
        connect("n0", "n2", ..utpedge)
        connect("n1", "n3", ..utpedge)
        connect("n1", "n4", ..utpedge)
      })
      connect((2.5, -0.8), (4.3, -0.8), ..utparrow)
      node((3.5, -3), [`target->data = deepest->data`; clear the parent’s link; free deepest \
    Array: $[8,4,12,2,7,10] arrow.r.long [8,10,12,2,7,"empty"]$], font: font("small"), ..utplabel, align: center)
    })
  ]
]
