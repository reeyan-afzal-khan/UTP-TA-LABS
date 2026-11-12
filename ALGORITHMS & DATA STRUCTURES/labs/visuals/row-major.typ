#import "/.shared/typst/utp.typ": *

#utpfigure(title: [Row-major memory layout])[
  #canvas({
    for i in range(0, 9) {
      let vv = int(i + 1)
      let r = int(int(i / 3))
      let st = none
      if r == 0 {
        st = utpcell
      }
      if r == 1 {
        st = utpdone
      }
      if r == 2 {
        st = utphot
      }
      node((0.94 * i, 0), [#vv], name: "f" + str(i), ..st, min-width: 0.92, min-height: 0.8)
      node((0.94 * i, -0.66), [#i], ..utplabel)
    }
    brace((-0.45, 0.44), (2.33, 0.44), amplitude: 3.4869pt, raise: 1.9925pt, draw: blue, line-width: widths.semithick)
    brace((2.37, 0.44), (5.15, 0.44), amplitude: 3.4869pt, raise: 1.9925pt, draw: green, line-width: widths.semithick)
    brace((5.19, 0.44), (7.97, 0.44), amplitude: 3.4869pt, raise: 1.9925pt, draw: orange, line-width: widths.semithick)
    node((0.94, 0.72), [row 0], ..utplabel, anchor: "south", text: blue)
    node((3.76, 0.72), [row 1], ..utplabel, anchor: "south", text: green)
    node((6.58, 0.72), [row 2], ..utplabel, anchor: "south", text: orange)
    node((3.76, -1), [flat offset $=r times "(number of columns)"+c$], ..utplabel, anchor: "north", align: center)
  })
]
