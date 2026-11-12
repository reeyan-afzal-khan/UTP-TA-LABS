#import "/.shared/typst/utp.typ": *

#utpfigure(title: [Row and column indexing])[
  #canvas({
    for r in range(0, 3) {
      for c in range(0, 3) {
        let vv = int(3 * r + c + 1)
        if r == 1 {
          if c == 2 {
            node((1.15 * c, -0.85 * r), [#vv], ..utphot, min-width: 1.15, min-height: 0.85)
          } else {
            node((1.15 * c, -0.85 * r), [#vv], ..utpcell, min-width: 1.15, min-height: 0.85)
          }
        } else {
          node((1.15 * c, -0.85 * r), [#vv], ..utpcell, min-width: 1.15, min-height: 0.85)
        }
      }
    }
    for c in range(0, 3) {
      node((1.15 * c, 0.68), [col #c], ..utplabel)
    }
    for r in range(0, 3) {
      node((-0.72, -0.85 * r), [row #r], ..utplabel, anchor: "east")
    }
    node((2.9, -0.85), [$arrow.l$ `matrix[1][2]` $=6$], ..utptag, anchor: "west", align: left)
  })
]
