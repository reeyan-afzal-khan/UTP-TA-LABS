#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 15.06cm, {
      let lens = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.235 * 15.06, min-width: 0.29 * 15.06, min-height: 2.2, inner-xsep: 4mm, inner-ysep: 3mm, align: center, font: font("script", fill: navy))
      let flow = (line-width: 0.8966pt, draw: teal, end: arrow-tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8966pt))
      node((0.17, 0), [#text(fill: blue)[#strong[01 DESCRIBE]] \ #v(4.9813pt)
     #fsize("footnote")[#strong[UNIVARIATE]] \ #v(3.9851pt)
     #strong[One variable] \ #v(4.9813pt)
     Shape, centre, and spread], name: "u", ..lens)
      node((0.5, 0), [#text(fill: blue)[#strong[02 RELATE]] \ #v(4.9813pt)
     #fsize("footnote")[#strong[BIVARIATE]] \ #v(3.9851pt)
     #strong[Two variables] \ #v(4.9813pt)
     Differences and relationships], name: "b", ..lens)
      node((0.83, 0), [#text(fill: teal)[#strong[03 CONDITION]] \ #v(4.9813pt)
     #fsize("footnote")[#strong[MULTIVARIATE]] \ #v(3.9851pt)
     #strong[Multiple variables] \ #v(4.9813pt)
     Patterns within groups \
    and joint structure], name: "m", ..lens, draw: mix(teal, 80%), fill: pale-teal)
      connect("u.east", "b.west", ..flow)
      connect("b.east", "m.west", ..flow)
    })
  ]
]
