#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 15.06cm, {
      let foldcell = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1mm, line-width: 0.5978pt, text-width: 0.13 * 15.06, min-height: 0.62, inner-xsep: 1mm, inner-ysep: 1mm, align: center, font: font("script", fill: navy))
      let heldout = (..foldcell, draw: mix(teal, 80%), fill: pale-teal, font: font("script", weight: "bold", fill: navy))
      let heading-style = (font: font("script", weight: "bold", fill: navy), inner-sep: 0pt)
      node((0.095, 0.65), [Run], ..heading-style, anchor: "east")
      for c in range(0, 5) {
        let foldnumber = int(c + 1)
        node((0.2 + c * 0.16, 0.65), [Fold #foldnumber], ..heading-style)
      }
      for r in range(0, 5) {
        let runnumber = int(r + 1)
        node((0.095, -r * 0.78), [#runnumber], ..heading-style, anchor: "east")
        for c in range(0, 5) {
          if r == c {
            node((0.2 + c * 0.16, -r * 0.78), [Validate], ..heldout)
          } else {
            node((0.2 + c * 0.16, -r * 0.78), [Train], ..foldcell)
          }
        }
      }
      node((0.5, -3.85), [Each run uses four training folds and one held-out validation fold.], font: font("script", fill: muted), align: center, text-width: 0.86 * 15.06)
    })
  ]
]
