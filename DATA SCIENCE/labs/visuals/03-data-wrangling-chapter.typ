#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 15.06cm, {
      let stage = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.14 * 15.06, min-width: 0.18 * 15.06, min-height: 1.7, inner-xsep: 2.5mm, inner-ysep: 2.5mm, align: center, font: font("script", fill: navy))
      let endpoint = (..stage, draw: mix(teal, 80%), fill: pale-teal)
      let flow = (line-width: 0.8966pt, draw: teal, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8966pt))
      node((0.1, 0), [#text(fill: teal)[#strong[01 INPUT]] \ #v(4.9813pt)
     #strong[Raw table] \ #v(2.9888pt)
     Original records \
    and variables], name: "raw", ..endpoint)
      node((0.3, 0), [#text(fill: blue)[#strong[02 SCOPE]] \ #v(4.9813pt)
     #strong[Select and filter] \ #v(2.9888pt)
     Relevant rows \
    and columns], name: "sel", ..stage)
      node((0.5, 0), [#text(fill: blue)[#strong[03 DERIVE]] \ #v(4.9813pt)
     #strong[Create features] \ #v(2.9888pt)
     Interpretable \
    derived variables], name: "feat", ..stage)
      node((0.7, 0), [#text(fill: blue)[#strong[04 SUMMARISE]] \ #v(4.9813pt)
     #strong[Aggregate] \ #v(2.9888pt)
     Summaries at \
    the required grain], name: "grp", ..stage)
      node((0.9, 0), [#text(fill: teal)[#strong[05 OUTPUT]] \ #v(4.9813pt)
     #strong[Analysis table] \ #v(2.9888pt)
     Evidence for \
    the question], name: "ana", ..endpoint)
      connect("raw.east", "sel.west", ..flow)
      connect("sel.east", "feat.west", ..flow)
      connect("feat.east", "grp.west", ..flow)
      connect("grp.east", "ana.west", ..flow)
    })
  ]
]
