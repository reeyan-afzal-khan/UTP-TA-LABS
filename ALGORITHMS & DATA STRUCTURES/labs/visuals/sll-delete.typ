#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Deletion by pointer bypass][
  #labgraphic[
    #canvas(compact: true, {
      node((-0.6, 0), [before], font: font("small"), ..utplabel, anchor: "east", align: right)
      node((0, 0), [10], name: "x0", font: font("small"), ..utpnode, min-size: 0.85)
      node((2.1, 0), [20], name: "x1", font: font("small"), ..utpnodehot, min-size: 0.85)
      node((4.2, 0), [30], name: "x2", font: font("small"), ..utpnode, min-size: 0.85)
      connect("x0", "x1", ..utparrow)
      connect("x1", "x2", ..utparrow)
      node((rel: (0.15, 0), to: "x2.east"), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
      node((0, -0.6), [`current`], font: font("small"), ..utplabel, anchor: "north", text: blue)
      node((2.1, -0.6), [target], font: font("small"), ..utptag, anchor: "north")
      draw.scope({
        draw.translate((0, -2.35))
        node((-0.6, 0), [after], font: font("small"), ..utplabel, anchor: "east", align: right)
        node((0, 0), [10], name: "y0", font: font("small"), ..utpnode, min-size: 0.85)
        node((2.1, 0), [20], name: "y1", font: font("small"), ..utpdim, shape: "circle", min-size: 0.85)
        node((4.2, 0), [30], name: "y2", font: font("small"), ..utpnode, min-size: 0.85)
        connect("y0", "y2", bend: 42deg, ..utparrow, draw: green, line-width: 0.9963pt, name: "curve-1")
        node((rel: (0.15, 0), to: "y2.east"), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
        node((2.1, -0.62), [`current->next = old->next` \
    then `delete old`], font: font("small"), ..utplabel, anchor: "north", align: center, text: green)
        connect((1.72, -0.38), (2.48, 0.38), draw: red, line-width: 0.797pt)
        connect((1.72, 0.38), (2.48, -0.38), draw: red, line-width: 0.797pt)
      })
    })
  ]
]
