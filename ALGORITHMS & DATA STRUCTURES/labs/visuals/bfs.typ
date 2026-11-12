#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[BFS with queue states][
  #labgraphic[
    #canvas(compact: true, {
      draw.scope({
        node((0, 1.5), [A], name: "A", font: font("small"), ..utpnodedone)
        node((2.1, 1.5), [B], name: "B", font: font("small"), ..utpnodehot)
        node((0, 0), [C], name: "C", font: font("small"), ..utpnodehot)
        node((2.1, 0), [D], name: "D", font: font("small"), ..utpnodehot)
        node((3.9, 0.75), [E], name: "E", font: font("small"), ..utpnode)
        for (u, vv) in (("B", "E"), ("C", "D"), ("D", "E"), ("B", "D")) {
          connect(u, vv, ..utpedge, draw: mix(muted, 40%))
        }
        for (u, vv) in (("A", "B"), ("A", "C"), ("A", "D")) {
          connect(u, vv, ..utpedge, draw: orange, line-width: 1.0959pt)
        }
        connect("B", "E", ..utpedge, draw: green, line-width: 1.0959pt)
        node((0, 2.05), [level 0], font: font("small"), ..utplabel, anchor: "south", text: green)
        node((2.1, 2.05), [level 1], font: font("small"), ..utplabel, anchor: "south", text: orange)
        node((3.9, 1.35), [level 2], font: font("small"), ..utplabel, anchor: "south", text: blue)
      })
      draw.scope({
        draw.translate((6.9, 0))
        draw.translate((0, 1.35))
        for (i, (act, qs)) in (("visit A", "B C D"), ("pop B, find E", "C D E"), ("pop C", "D E"), ("pop D", "E"), ("pop E", "empty")).enumerate() {
          node((0, -0.56 * i), [#act], ..utplabel, anchor: "east", font: font("script", family: "mono"))
          node((1.35, -0.56 * i), [#qs], ..utpcell, min-width: 2.1, min-height: 0.44, font: font("script", fill: navy, family: "mono"))
        }
        node((1.35, 0.32), [#strong[queue after step]], font: font("small"), ..utplabel, anchor: "south", text: navy)
        node((0.9, -2.75), [output: A B C D E], font: font("small"), ..utplabel, anchor: "north", align: center)
      })
    })
  ]
]
