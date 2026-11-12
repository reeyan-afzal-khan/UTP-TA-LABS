#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 0.95cm, y: 0.7cm, {
      rectangle((0, 0), (5, 1), fill: pale-blue, draw: none)
      node((2.5, 0.5), [#fsize("small")[#strong[P1]]])
      rectangle((5, 0), (8, 1), fill: pale-teal, draw: none)
      node((6.5, 0.5), [#fsize("small")[#strong[P2]]])
      rectangle((8, 0), (9, 1), fill: pale-orange, draw: none)
      node((8.5, 0.5), [#fsize("small")[#strong[P3]]])
      for x in (0, 5, 8, 9) {
        connect((x, 0), (x, -0.25), draw: muted)
        node((x, -0.25), [#x], font: font("script"), anchor: "north")
      }
    })
  ]
]
