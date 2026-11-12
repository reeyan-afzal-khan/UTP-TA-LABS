#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(scale: 1.05, {
      for p in ((1, 1), (1.5, 2), (2, 1.2), (0.8, 2.2)) {
        circle-at(p, 2.406pt, fill: auto, draw: none)
      }
      for p in ((3.5, 3), (4, 2.5), (3, 3.6), (4.3, 3.4)) {
        circle-at(p, 2.406pt, line-width: widths.thick, fill: pale-orange)
      }
      node((2.6, 2.4), [], name: "q", font: font("small"), shape: "star", star-points: 5, star-point-ratio: 2.4, fill: black, inner-sep: 1.594pt)
      circle-at((2.6, 2.4), 1.32, dash: "dashed")
      node((2.6, 2.3), [new point], font: font("small"), yshift: -1.9925pt, anchor: "north")
      node((0.55, 3.5), [$bullet$ = class A], font: font("small"), align: left)
      node((4.6, 1.5), [$compose$ = class B], font: font("small"), align: left)
      node((2.6, 0.3), [$k=3$ neighborhood: two of the three \
    nearest points are class B $arrow.r$ predict B], font: font("small"), align: center)
    })
  ]
]
