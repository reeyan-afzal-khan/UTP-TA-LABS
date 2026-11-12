#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[One undirected graph, two stored directions per edge][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 1), [A], name: "A", font: font("small"), ..utpnode)
      node((2, 1), [B], name: "B", font: font("small"), ..utpnode)
      node((0, -1), [C], name: "C", font: font("small"), ..utpnode)
      node((2, -1), [D], name: "D", font: font("small"), ..utpnode)
      node((4, 0), [E], name: "E", font: font("small"), ..utpnode)
      for (u, w) in (("A", "B"), ("A", "C"), ("A", "D"), ("B", "D"), ("B", "E"), ("C", "D"), ("D", "E")) {
        connect(u, w, ..utpedge)
      }
      for (r, (vertex, neighbours)) in (("A", "B,C,D"), ("B", "A,D,E"), ("C", "A,D"), ("D", "A,B,C,E"), ("E", "B,D")).enumerate() {
        node((5.3, 1.5 - 0.9 * r), [#vertex], name: "x" + str(r), font: font("small"), ..utptag)
        node((7.5, 1.5 - 0.9 * r), [#neighbours], name: "y" + str(r), font: font("small"), ..utpcell, min-width: 3.2)
        connect("x" + str(r), "y" + str(r), ..utparrow)
      }
      node((1.8, -1.7), [Seven edges; fourteen neighbour entries.], font: font("small"), ..utplabel, anchor: "north")
    })
  ]
]
