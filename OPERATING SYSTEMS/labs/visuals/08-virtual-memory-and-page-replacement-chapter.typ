#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let cell = (draw: blue, fill: pale-blue, min-width: 1.6, min-height: 0.7, font: font("small", fill: navy), align: center)
      let off = (draw: orange, fill: pale-orange, min-width: 1.6, min-height: 0.7, font: font("small", fill: navy), align: center)
      let pte = (draw: teal, fill: pale-teal, min-width: 1.2, min-height: 0.58, font: font("script", fill: navy))
      let lab = (font: font("script", fill: muted), align: center)
      let ar = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.2mm, line: widths.thick))
      node((0, 3.5), [#strong[Virtual address] \
     $v = 9 thin 000$,  $P = 4 thin 096$], ..lab)
      node((4.9, 4), [#strong[Page table]], ..lab)
      node((9.6, 3.5), [#strong[Physical address]], ..lab)
      node((4.9, 3.2), [0 $arrow.r$ 7], name: "p0", ..pte)
      node((4.9, 2.6), [1 $arrow.r$ 3], name: "p1", ..pte)
      node((4.9, 2), [2 $arrow.r$ 5], name: "p2", ..pte, draw: red, fill: pale-red, line-width: widths.very-thick)
      node((4.9, 1.4), [3 $arrow.r$ 1], name: "p3", ..pte)
      node((0, 2), [page 2], name: "vp", ..cell)
      node((0, 0.5), [offset 808], name: "vo", ..off)
      node((9.6, 2), [frame 5], name: "pf", ..cell)
      node((9.6, 0.5), [offset 808], name: "po", ..off)
      node((0, -0.35), [$floor.l 9000\/4096 floor.r = 2$ \
     $9000 mod 4096 = 808$], ..lab)
      node((9.6, -0.35), [$5 times 4096 + 808$ \
     $= 21 thin 288$], ..lab)
      connect("vp.east", "p2.west", ..ar)
      node(along("vp.east", "p2.west", t: 50%), [look up], ..lab, anchor: "south")
      connect("p2.east", "pf.west", ..ar)
      node(along("p2.east", "pf.west", t: 50%), [gives frame], ..lab, anchor: "south")
      connect("vo.east", "po.west", ..ar, draw: orange)
      node(along("vo.east", "po.west", t: 50%), [copied unchanged --- it never enters the page table], ..lab, anchor: "south")
    })
  ]
]
