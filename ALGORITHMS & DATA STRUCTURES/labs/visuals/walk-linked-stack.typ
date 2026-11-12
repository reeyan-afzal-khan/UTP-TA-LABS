#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Pop from the linked stack: save, advance, release][
  #labgraphic[
    #canvas(compact: true, {
      for (row, y) in ((0, 0), (1, -2.2)) {
        node((2, y), [20], name: "b" + str(row), font: font("small"), ..utpnode)
        node((4, y), [10], name: "c" + str(row), font: font("small"), ..utpnode)
        connect("b" + str(row), "c" + str(row), ..utparrow)
        node((4.5, y), [NULL], font: font("small"), ..utplabel, anchor: "west")
      }
      node((0, 0), [30], name: "a", font: font("small"), ..utpnodehot)
      connect("a", "b0", ..utparrow)
      node((0, 0.6), [top / old], font: font("small"), ..utptag, anchor: "south")
      node((0, -2.2), [30], name: "gone", font: font("small"), ..utpdim, shape: "circle")
      connect((-0.3, -2.5), (0.3, -1.9), draw: red)
      connect((-0.3, -1.9), (0.3, -2.5), draw: red)
      node((2, -1.6), [top], font: font("small"), ..utptag, anchor: "south")
      node((6, 0), [1\. `old = top` \
    2\. `value = old->data` (30)], font: font("small"), ..utplabel, anchor: "west", align: left)
      node((6, -2.2), [3\. `top = old->next` \
    4\. `delete old` \
    Return true; next pop returns 20.], font: font("small"), ..utplabel, anchor: "west", align: left)
    })
  ]
]
