#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 15.06cm, {
      let sourcecard = (draw: mix(blue, 75%), fill: pale-blue, rounded: 1.8mm, line-width: 0.7472pt, text-width: 0.15 * 15.06, min-width: 0.19 * 15.06, min-height: 1.15, inner-xsep: 3mm, inner-ysep: 2.5mm, align: center, font: font("script", fill: navy))
      let taskcard = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.21 * 15.06, min-width: 0.255 * 15.06, min-height: 1.05, inner-xsep: 3.5mm, inner-ysep: 2mm, align: left, font: font("script", fill: navy))
      let qualityflow = (line-width: 0.8468pt, draw: teal, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.8468pt))
      node((0.12, 0), [#text(fill: blue)[#strong[SHARED INPUT]] \ #v(2.9888pt)
     The same dataset], name: "data", ..sourcecard)
      node((0.43, 0.8), [#text(fill: blue)[#strong[QUESTION A]] \ #v(2.9888pt)
     Requires a complete target.], name: "q1", ..taskcard)
      node((0.43, -0.8), [#text(fill: blue)[#strong[QUESTION B]] \ #v(2.9888pt)
     Requires reliable dates.], name: "q2", ..taskcard)
      node((0.78, 0.8), [#text(fill: teal)[#strong[QUALITY CHECK]] \ #v(2.9888pt)
     Is the target complete and reliable?], name: "a1", ..taskcard, draw: mix(teal, 80%), fill: pale-teal)
      node((0.78, -0.8), [#text(fill: teal)[#strong[QUALITY CHECK]] \ #v(2.9888pt)
     Are the dates complete and valid?], name: "a2", ..taskcard, draw: mix(teal, 80%), fill: pale-teal)
      coordinate("split", (0.275, 0))
      connect("data.east", "split", draw: teal, line-width: 0.8468pt)
      connect("split", "|-", "q1.west", ..qualityflow)
      connect("split", "|-", "q2.west", ..qualityflow)
      connect("q1.east", "a1.west", ..qualityflow)
      connect("q2.east", "a2.west", ..qualityflow)
      circle-at("split", 1.2951pt, fill: teal, draw: none)
    })
  ]
]
