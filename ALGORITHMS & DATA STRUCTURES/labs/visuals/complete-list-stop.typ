#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Same values; three traversal stopping rules][
  #labgraphic[
    #canvas(compact: true, {
      for (r, label-v, stop) in ((0, "Singly", [`p == nullptr`]), (1, "Doubly", [`p == nullptr`]), (2, "Circular", [`p == head` again])) {
        node((-0.8, -1.3 * r), [#label-v], font: font("small"), ..utplabel, anchor: "east")
        for (i, n) in range(10, 41, step: 10).enumerate() {
          node((1.3 * i, -1.3 * r), [#n], name: "r" + str(r) + "n" + str(i), font: font("small"), ..utpnode)
          if i > 0 {
            let j = int(i - 1)
            if r == 1 {
              connect("r" + str(r) + "n" + str(j) + ".shape.20deg", "r" + str(r) + "n" + str(i) + ".shape.160deg", ..utparrow)
              connect("r" + str(r) + "n" + str(i) + ".shape.200deg", "r" + str(r) + "n" + str(j) + ".shape.340deg", ..utparrow)
            } else {
              connect("r" + str(r) + "n" + str(j), "r" + str(r) + "n" + str(i), ..utparrow)
            }
          }
        }
        node((4.8, -1.3 * r), [#stop], font: font("small"), ..utplabel, anchor: "west")
      }
      connect("r2n3.south", (rel: (0, -0.45), to: "r2n3.south"), "-|", "r2n0.south", ..utparrow)
      node((2, -3.65), [Circular traversal: print the node, advance, then test for head.], font: font("small"), ..utplabel, align: center)
    })
  ]
]
