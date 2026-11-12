#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 15.06cm, {
      let stage = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.14 * 15.06, min-width: 0.19 * 15.06, min-height: 1.7, inner-xsep: 3mm, inner-ysep: 2.5mm, align: center, font: font("script", fill: navy))
      let flow = (line-width: 0.8966pt, draw: teal, end: tip("Stealth", length: 2.2mm, width: 1.6mm, line: 0.8966pt))
      node((0.11, 0), [#text(fill: teal)[#strong[01 SCORE]] \ #v(4.9813pt)
     #strong[Model outputs] \ #v(3.9851pt)
     Scores or probabilities], name: "p", ..stage, draw: mix(teal, 80%), fill: pale-teal)
      node((0.37, 0), [#text(fill: mix(orange, 85%, other: black))[#strong[02 THRESHOLD]] \ #v(4.9813pt)
     #strong[Choose cutoff] \ #v(3.9851pt)
     Set the decision rule], name: "t", ..stage, draw: mix(orange, 80%), fill: pale-orange)
      node((0.63, 0), [#text(fill: blue)[#strong[03 DECIDE]] \ #v(4.9813pt)
     #strong[Class decisions] \ #v(3.9851pt)
     Positive or negative], name: "d", ..stage)
      node((0.89, 0), [#text(fill: teal)[#strong[04 EVALUATE]] \ #v(4.9813pt)
     #strong[Measure errors] \ #v(3.9851pt)
     Confusion matrix and costs], name: "c", ..stage, draw: mix(teal, 80%), fill: pale-teal)
      connect("p.east", "t.west", ..flow)
      connect("t.east", "d.west", ..flow)
      connect("d.east", "c.west", ..flow)
    })
  ]
]
