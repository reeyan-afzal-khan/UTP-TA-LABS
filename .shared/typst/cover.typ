// Shared cover for every course. Edit this one file to change all covers.
#import "palette.typ": *
#import "diagrams.typ": cover-workflow

#let cover(title: [], summary: []) = {
  set page(header: none, footer: none, background: {
    place(top, rect(width: 100%, height: 1.2mm, fill: gold, stroke: none))
    place(bottom, rect(width: 100%, height: 1.2mm, fill: gold, stroke: none))
  })
  v(6.4mm)
  align(center)[
    #image("/.shared/assets/logos/logo-UTP.png", height: 28.5mm)
    #v(9.81mm)
    #text(size: 28.89pt, weight: "bold", fill: navy, title)
    #v(5.34mm)
    #text(size: 14.35pt, fill: muted)[Teaching Assistant Guide]
    #v(11.4mm)
    #line(length: 26%, stroke: 1.3pt + gold)
    #v(7.2mm)
    #cover-workflow()
    #v(7mm)
    #block(width: 82%, stroke: (rest: .45pt + blue.lighten(82%), left: 1.6pt + gold), inset: (x: 6mm, y: 3.2mm), radius: 1.5mm)[
      #text(size: 11.96pt, fill: blue, weight: "bold")[COURSE OUTLINE]
      #v(3mm)
      #summary
    ]
  ]
  v(1fr)
  align(center, block(width: 82%)[
  #grid(columns: (1fr, 1fr), align: (left, right),
    [#text(fill: blue, weight: "bold")[PREPARED BY] #parbreak() #v(0.25em)
     #text(size: 14.35pt, fill: navy, weight: "bold")[Reeyan Afzal Khan] #parbreak() #v(0.12em)
     #text(size: 9.96pt, fill: muted)[Graduate Research Assistant]],
    image("/.shared/assets/logos/logo-DC.png", height: 21mm))
  ])
  v(5mm)
  pagebreak()
}
