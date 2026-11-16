#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 15.06cm, {
      let card = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.5978pt, text-width: 0.26 * 15.06, min-height: 1.45, inner-xsep: 2.5mm, inner-ysep: 2mm, align: center, font: font("script", fill: navy))
      let connector = (line-width: 0.797pt, draw: teal, rounded: 1.5mm)
      let flow = (..connector, end: arrow-tip("Stealth", length: 2mm, width: 1.5mm, line: 0.4pt))
      node((0, 0), [#strong[Population] \ #v(3.9851pt)
     Cases of interest \
    Unknown parameter], name: "pop", ..card)
      node((0.335, 1.05), [#strong[Sample A] \ #v(3.9851pt)
     Observed subset \
    Estimate A], name: "s1", ..card)
      node((0.335, -1.05), [#strong[Sample B] \ #v(3.9851pt)
     Observed subset \
    Estimate B], name: "s2", ..card)
      node((0.67, 0), [#strong[Sampling distribution] \ #v(3.9851pt)
     Estimates across samples \
    Sampling uncertainty], name: "dist", ..card, draw: mix(teal, 80%), fill: pale-teal)
      coordinate("split", (0.1675, 0))
      coordinate("merge", (0.5025, 0))
      connect("pop.east", "split", ..connector)
      connect("split", "|-", "s1.west", ..flow)
      connect("split", "|-", "s2.west", ..flow)
      connect("s1.east", "-|", "merge", ..connector)
      connect("s2.east", "-|", "merge", ..connector)
      connect("merge", "dist.west", ..flow)
      node((0.335, 2.05), [Illustrative repeated samples], font: font("script", fill: muted), align: center, text-width: 0.3 * 15.06)
    })
  ]
]
