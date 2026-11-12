#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[A stack under push and pop][
  #labgraphic[
    #canvas(compact: true, {
      let cw = 1.5
      node((0, -0.35), [empty], font: font("small"), ..utplabel, anchor: "north", align: center)
      connect((-0.75, 0.34), (-0.75, -0.05), (0.75, -0.05), (0.75, 0.34), draw: mix(muted, 45%))
      node((0, 0.75), [top $=-1$], font: font("small"), ..utplabel, text: muted)
      draw.scope({
        draw.translate((2.3, 0))
        node((0, -0.35), [`push(10)`], font: font("small"), ..utplabel, anchor: "north", align: center)
        for (k, vv) in (10,).enumerate() {
          node((0, 0.66 * k), [#vv], name: "q" + str(k), font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
        }
      })
      node((3.15, 0), [top], font: font("small"), ..utptag, anchor: "west")
      draw.scope({
        draw.translate((5.2, 0))
        node((0, -0.35), [`push(20)`], font: font("small"), ..utplabel, anchor: "north", align: center)
        for (k, vv) in (10, 20).enumerate() {
          node((0, 0.66 * k), [#vv], name: "q" + str(k), font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
        }
      })
      node((6.05, 0.66), [top], font: font("small"), ..utptag, anchor: "west")
      draw.scope({
        draw.translate((8.1, 0))
        node((0, -0.35), [`push(30)`], font: font("small"), ..utplabel, anchor: "north", align: center)
        for (k, vv) in range(10, 31, step: 10).enumerate() {
          node((0, 0.66 * k), [#vv], name: "q" + str(k), font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
        }
      })
      node((8.95, 1.32), [top], font: font("small"), ..utptag, anchor: "west")
      draw.scope({
        draw.translate((11, 0))
        node((0, -0.35), [`pop()` $arrow.r 30$], font: font("small"), ..utplabel, anchor: "north", align: center)
        node((0, 0), [10], font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
        node((0, 0.66), [20], font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
        node((0, 1.32), [30], font: font("small"), ..utpdim, min-width: cw, min-height: 0.62)
        connect((-0.42, 1.05), (0.42, 1.59), draw: red, line-width: 0.6974pt)
        node((0.85, 0.66), [top], font: font("small"), ..utptag, anchor: "west")
      })
    })
  ]
]
