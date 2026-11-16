#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 15.06cm, {
      let encoding = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.14 * 15.06, min-width: 0.18 * 15.06, min-height: 1.7, inner-xsep: 2.5mm, inner-ysep: 2.5mm, align: center, font: font("script", fill: navy))
      let precision = (line-width: 0.9963pt, draw: teal, end: arrow-tip("Stealth", length: 2.2mm, width: 1.6mm, line: 0.9963pt))
      node((0.1, 0), [#text(fill: teal)[#strong[01]] \ #v(3.9851pt)
     #strong[POSITION] \ #v(4.9813pt)
     Location on a \
    common axis], name: "p", ..encoding, draw: mix(teal, 80%), fill: pale-teal)
      node((0.3, 0), [#text(fill: blue)[#strong[02]] \ #v(3.9851pt)
     #strong[LENGTH] \ #v(4.9813pt)
     Extent along \
    one dimension], name: "l", ..encoding)
      node((0.5, 0), [#text(fill: blue)[#strong[03]] \ #v(3.9851pt)
     #strong[ANGLE / SLOPE] \ #v(4.9813pt)
     Angle or \
    inclination], name: "a", ..encoding)
      node((0.7, 0), [#text(fill: blue)[#strong[04]] \ #v(3.9851pt)
     #strong[AREA] \ #v(4.9813pt)
     Size in \
    two dimensions], name: "ar", ..encoding)
      node((0.9, 0), [#text(fill: mix(orange, 85%, other: black))[#strong[05]] \ #v(3.9851pt)
     #strong[COLOUR] \ #v(4.9813pt)
     Variation in \
    intensity], name: "c", ..encoding, draw: mix(orange, 75%), fill: pale-orange)
      connect((0.08, -1.12), (0.92, -1.12), ..precision)
      for x in (0.1, 0.3, 0.5, 0.7, 0.9) {
        connect((x, -1.04), (x, -1.2), draw: mix(muted, 75%), line-width: 0.6476pt)
      }
      node((0.08, -1.27), [HIGHER PRECISION], anchor: "north-west", font: font("script", weight: "bold", fill: teal))
      node((0.92, -1.27), [LOWER PRECISION], anchor: "north-east", font: font("script", weight: "bold", fill: mix(orange, 85%, other: black)))
    })
  ]
]
