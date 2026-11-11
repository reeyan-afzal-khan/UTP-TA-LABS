// Shared cover for every course. Edit this one file to change all covers.
#import "palette.typ": *
#import "../packages/fletcher/0.5.8/src/exports.typ": diagram, node, edge

#let cover(title: [], summary: []) = {
  set page(header: none, footer: none, background: {
    place(top, rect(width: 100%, height: 1.2mm, fill: gold, stroke: none))
    place(bottom, rect(width: 100%, height: 1.2mm, fill: gold, stroke: none))
  })
  align(center)[
    #image("/.shared/assets/logos/logo-UTP.png", height: 28.5mm)
    #v(5mm)
    #text(size: 29pt, weight: "bold", fill: navy, title)
    #v(2.4mm)
    #text(size: 17pt, fill: muted)[Teaching Assistant Guide]
    #v(4.2mm)
    #line(length: 26%, stroke: 1.3pt + gold)
    #v(8mm)
    #diagram(spacing: 9mm, node-stroke: 0.7pt + blue, node-fill: pale-blue,
      node((1, 0), [SESSION\ PLANNING], width: 35mm, height: 15mm, corner-radius: 1.5mm),
      node((2, 1), [INSTRUCTIONAL\ SUPPORT], width: 35mm, height: 15mm, corner-radius: 1.5mm),
      node((1, 2), [STUDENT\ ENGAGEMENT], width: 35mm, height: 15mm, corner-radius: 1.5mm),
      node((0, 1), [LEARNING\ ASSESSMENT], width: 35mm, height: 15mm, corner-radius: 1.5mm),
      node((1, 1), text(size: 10pt, hyphenate: false, fill: white, weight: "bold")[TA\ WORKFLOW], fill: navy, stroke: gold, radius: 11mm),
      edge((1, 0), (2, 1), "-|>"), edge((2, 1), (1, 2), "-|>"), edge((1, 2), (0, 1), "-|>"), edge((0, 1), (1, 0), "-|>"),
    )
    #v(7mm)
    #block(width: 82%, stroke: 0.5pt + blue.lighten(80%), inset: 6mm, radius: 1.5mm)[
      #text(size: 14pt, fill: blue, weight: "bold")[COURSE OUTLINE]
      #v(3mm)
      #summary
    ]
  ]
  v(1fr)
  grid(columns: (1fr, 1fr), align: (left, right),
    [#text(fill: blue, weight: "bold")[PREPARED BY]\ #text(size: 17pt, fill: navy, weight: "bold")[Reeyan Afzal Khan]\ #text(size: 10pt, fill: muted)[Graduate Research Assistant]],
    image("/.shared/assets/logos/logo-DC.png", height: 21mm))
  pagebreak()
}
