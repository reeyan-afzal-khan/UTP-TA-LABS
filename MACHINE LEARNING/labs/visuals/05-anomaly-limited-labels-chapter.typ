#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      draw.scope({
        rectangle((0, 0), (4.2, 2.9), draw: muted, fill: white)
        for p in ((1.5, 1.4), (1.8, 1.6), (1.6, 1.1), (2, 1.3), (1.3, 1.7), (2.2, 1.6), (1.9, 0.9), (1.4, 1.25), (2.1, 1.1), (1.7, 1.45), (2.3, 1.35), (1.55, 0.85), (2.05, 1.65)) {
          circle-at(p, 2.391pt, fill: blue, draw: none)
        }
        circle-at((1.8, 1.32), 0.95, line-width: widths.thick, dash: "dashed", draw: teal)
        circle-at((3.5, 2.4), 2.7895pt, fill: red, draw: none)
        circle-at((0.5, 0.4), 2.7895pt, fill: red, draw: none)
        node((4.15, 2.72), [anomalies], font: font("script"), anchor: "east", text: red)
        node((1.8, -0.35), [the \"normal\" region], font: font("script"), text: teal)
        node((2.1, 3.25), [Distance / density view], font: font("small", weight: "bold", fill: navy))
      })
      draw.scope({
        draw.translate((5.6, 0))
        rectangle((0, 0), (4.6, 2.9), draw: muted, fill: white)
        connect((0.3, 0.45), (4.35, 0.45), draw: muted, end: tip("Stealth", length: 2mm, line: 0.4pt))
        node((2.3, 0.4), [anomaly score], font: font("script"), anchor: "north", inner-sep: 0.9963pt, text: muted)
        smooth-path(..range(60).map(k => { let x = 0.4 + k * (4.3 - (0.4)) / 59; (x, 0.45 + 2 * calc.exp(-(calc.pow((x - 1.3), 2)) / 0.28)) }), line-width: widths.very-thick, draw: blue)
        connect((2.85, 0.45), (2.85, 2.6), line-width: widths.very-thick, dash: "dashed", draw: red)
        node((2.95, 2.2), [threshold \
    you choose], font: font("script"), anchor: "west", align: left, text: red)
        node((1.3, 2.68), [normal], font: font("script"), text: green)
        node((3.1, 0.85), [flagged], font: font("script"), anchor: "west", text: red)
        node((2.3, 3.25), [Score-and-threshold view], font: font("small", weight: "bold", fill: navy))
      })
    })
  ]
]
