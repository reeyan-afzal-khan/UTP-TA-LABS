#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let core = (draw: navy, fill: navy, text: white, rounded: 2mm, text-width: 3.1, min-height: 1.2, align: center, font: font("small", weight: "bold"))
      let b = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 2.5, min-height: 0.95, align: center, font: font("script", weight: "bold", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 1.9mm, line: widths.thick))
      node((0, 0), [Big Tech \
    platform], name: "p", ..core)
      node((-4, 1.8), [Existing users], name: "u", ..b)
      node((0, 2.5), [Behavioral data], name: "d", ..b)
      node((4, 1.8), [Technology + talent], name: "t", ..b)
      node((-4, -1.8), [Capital], name: "c", ..b)
      node((0, -2.5), [Daily engagement], name: "x", ..b)
      node((4, -1.8), [Ecosystem distribution], name: "e", ..b)
      for n in ("u", "d", "t", "c", "x", "e") {
        connect(n, "p", ..arr)
      }
    })
  ]
]
