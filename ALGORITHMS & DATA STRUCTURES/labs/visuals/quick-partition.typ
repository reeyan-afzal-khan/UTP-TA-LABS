#import "/.shared/typst/utp.typ": *

#utpfigure(title: [Quick sort partitioning])[
  #canvas({
    for (r, (row, hot, lbl)) in (((7, 2, 9, 4, 6), 4, [pivot $=6$ (last element)]), ((2, 7, 9, 4, 6), 0, [$2<6$: swap into the small region]), ((2, 4, 9, 7, 6), 1, [$4<6$: swap into the small region]), ((2, 4, 6, 7, 9), 2, [place the pivot at the boundary])).enumerate() {
      draw.scope({
        draw.translate((0, -0.98 * r))
        for (i, vv) in row.enumerate() {
          if i == hot {
            node((0.87 * i, 0), [#vv], font: font("small"), ..utphot, min-width: 0.82, min-height: 0.68)
          } else {
            node((0.87 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 0.82, min-height: 0.68)
          }
        }
        node((4, 0), [#lbl], font: font("small"), ..utplabel, anchor: "west")
      })
    }
    draw.scope({
      draw.translate((0, -2.94))
      brace((-0.44, -0.38), (1.31, -0.38), mirror: true, amplitude: 3.4869pt, raise: 2.9888pt, draw: blue, line-width: widths.semithick)
      brace((2.19, -0.38), (3.93, -0.38), mirror: true, amplitude: 3.4869pt, raise: 2.9888pt, draw: red, line-width: widths.semithick)
      node((0.44, -0.78), [all $<6$], font: font("small"), ..utplabel, anchor: "north", text: blue)
      node((3.06, -0.78), [all $>6$], font: font("small"), ..utplabel, anchor: "north", text: red)
      node((1.74, -0.78), [6 is final], font: font("small"), ..utplabel, anchor: "north", text: green)
    })
  })
]
