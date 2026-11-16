#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      node((0, 0), [R1], name: "r1", ..router)
      node((7, 0), [R2], name: "r2", ..router)
      node(above-of("r1", 0.1), [DCE], font: font("script", weight: "bold", fill: teal))
      node(above-of("r2", 0.1), [DTE], font: font("script", weight: "bold", fill: muted))
      connect((0.55, 0), (6.45, 0), line-width: 1.594pt, draw: muted)
      node(below-of(("r1", 50%, "r2"), 0.1), [S1/0/0 #h(1em)10.0.12.0/24], ..netlabel)
      connect((1.3, 0.55), (1.3, 0.85), (1.7, 0.85), (1.7, 0.55), (2.1, 0.55), (2.1, 0.85), (2.5, 0.85), (2.5, 0.55), (2.9, 0.55), (2.9, 0.85), (3.3, 0.85), (3.3, 0.55), draw: teal, line-width: widths.thick)
      connect((3.45, 0.7), (5.6, 0.7), draw: teal, line-width: widths.thick, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
      node((1.3, 1.15), [clock generated here], font: font("script", fill: teal), anchor: "west")
      node((4.6, 1.15), [and followed here], font: font("script", fill: muted), anchor: "west")
      node((-0.6, -1.15), [`baudrate 128000` is set on #strong[R1 only]. Setting it on the DTE changes nothing.], anchor: "west", font: font("script", fill: ink), align: left, text-width: 5)
      node((5.3, -1.15), [A missing clock leaves the physical state up and the protocol state down --- the same symptom as an encapsulation mismatch.], anchor: "west", font: font("script", fill: muted), align: left, text-width: 4.6)
    })
  ]
]
