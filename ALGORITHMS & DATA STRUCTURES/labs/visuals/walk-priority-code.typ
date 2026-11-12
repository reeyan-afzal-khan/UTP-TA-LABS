#import "/.shared/typst/utp.typ": *

#utpfigure(title: [Insert C without moving it ahead of B])[
  #canvas({
    node((0, 0), [B / 3], name: "b", font: font("small"), ..utpcell)
    node((2, 0), [A / 2], name: "a", font: font("small"), ..utphot)
    node((4, 0), [empty], font: font("small"), ..utpdim)
    node((6, 0), [C / 3 arrives: begin at pos = 2], font: font("small"), ..utplabel, anchor: "west")
    node((0, -1.2), [B / 3], font: font("small"), ..utpcell)
    node((2, -1.2), [C / 3], font: font("small"), ..utphot)
    node((4, -1.2), [A / 2], font: font("small"), ..utpcell)
    connect("a", (4, -0.8), ..utparrow)
    node((6, -1.2), [Shift A right: 2 $<$ 3 \
  Stop at B: 3 is not $<$ 3], font: font("small"), ..utplabel, anchor: "west", align: left)
  })
]
