#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Linear probing and clustering][
  #labgraphic[
    #canvas(compact: true, {
      for (r, (row, hot, lbl)) in ((("10", "", "12", "", "14"), 9, [10, 12, 14 land directly: 1 probe each]), (("10", "15", "12", "", "14"), 1, [$15 mod 5=0$ taken $arrow.r$ probe 1: free]), (("10", "15", "12", "20", "14"), 3, [$20 mod 5=0$ taken $arrow.r$ probes 1, 2, 3])).enumerate() {
        draw.scope({
          draw.translate((0, -1.35 * r))
          for (i, vv) in row.enumerate() {
            node((1.2 * i, 0.58), [#i], font: font("small"), ..utplabel)
            if i == hot {
              node((1.2 * i, 0), [#vv], font: font("small"), ..utphot, min-width: 1.12, min-height: 0.72)
            } else {
              if vv == none or vv == "" {
                node((1.2 * i, 0), [], font: font("small"), ..utpdim, min-width: 1.12, min-height: 0.72)
              } else {
                node((1.2 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 1.12, min-height: 0.72)
              }
            }
          }
          node((5.4, 0), [#lbl], font: font("small"), ..utplabel, anchor: "west", align: left)
        })
      }
      brace((-0.62, -3.11), (4.42, -3.11), mirror: true, amplitude: 3.9851pt, raise: 2.9888pt, draw: red, line-width: widths.semithick)
      node((1.9, -3.55), [a cluster: no free slot until the table wraps], font: font("small"), ..utplabel, anchor: "north", text: red)
    })
  ]
]
