#import "/.shared/typst/utp.typ": *

#labvisual[Tampering changes a hash; it does not repair the next link][
  #labgraphic[
    #canvas({
      node((0, 0), [Block 0 \
    previous: zeros \
    hash: $H_0$], name: "a", font: font("small"), ..utpstep, text-width: 2.5, min-height: 1.25)
      node(right-of("a", 0.35), [Block 1 \
    previous: $H_0$ \
    hash: $H_1$], name: "b", font: font("small"), ..utpstep, text-width: 2.5, min-height: 1.25)
      node(right-of("b", 0.35), [Block 2 changed \
    previous: $H_1$ \
    new hash: $H'_2$], name: "c", font: font("small"), ..utpstep, fill: pale-orange, text-width: 2.5, min-height: 1.25)
      node(right-of("c", 0.35), [Block 3 \
    stored previous: $H_2$ \
    $H_2 != H'_2$], name: "d", font: font("small"), ..utpstep, text-width: 2.5, min-height: 1.25)
      connect("a", "b", ..utparrow)
      connect("b", "c", ..utparrow)
      connect("c", "d", ..utparrow, draw: orange)
    })
  ]
]
