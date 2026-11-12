#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let method = (rounded: 2mm, text-width: 2.75, min-height: 1.02, align: center, font: font("script", fill: navy), inner-sep: 1.5mm, line-width: 0.7472pt)
      node((0, 0), [S], name: "S", font: font("small"), ..utpnodedone, min-size: 0.9)
      node((4, 0), [$n$], name: "N", font: font("small"), ..utpnodehot, min-size: 0.9)
      node((8, 0), [G], name: "G", font: font("small"), ..utpnode, min-size: 0.9, fill: pale-teal, draw: green)
      connect("S", (1.15, 0.48), (2.55, -0.32), "N", ..utpedge, draw: blue, line-width: 1.2951pt)
      connect("N", "G", ..utpedge, draw: mix(muted, 55%), line-width: 1.1955pt, dash: "dashed")
      connect((-0.3, 0.92), (4, 0.92), ..utpbrace, draw: blue)
      connect((4, 0.92), (8.3, 0.92), ..utpbrace, draw: orange)
      node((1.85, 1.22), [$g(n)$ --- exact cost \
    from start to $n$], font: font("small"), ..utplabel, anchor: "south", align: center, text: blue)
      node((6.15, 1.22), [$h(n)$ --- estimated cost \
    from $n$ to goal], font: font("small"), ..utplabel, anchor: "south", align: center, text: orange)
      node((0.75, -1.65), [#strong[UCS] \
    priority $g(n)$ \
    actual cost only], name: "ucs", font: font("small"), ..method, draw: blue, fill: pale-blue)
      node((4, -1.65), [#strong[GBFS] \
    priority $h(n)$ \
    estimate only], name: "gbfs", font: font("small"), ..method, draw: orange, fill: pale-orange)
      node((7.25, -1.65), [#strong[A\*] \
    priority $f(n)=g(n)+h(n)$ \
    combines both], name: "astar", font: font("small"), ..method, draw: green, fill: pale-teal)
    })
  ]
]
