#import "/.shared/typst/utp.typ": *

#labvisual[Synthetic series: largest observed peak-to-trough loss][
  #labgraphic[
    #canvas({
      node((-0.2, 0), [high volatility], anchor: "east", font: font("script"))
      rectangle((0, -0.16), (7, 0.16), fill: pale-blue, draw: none)
      rectangle((0, -0.16), (3.6685, 0.16), fill: teal, draw: none)
      node((7.15, 0), [52.4% loss], anchor: "west", font: font("script"))
      node((-0.2, -0.55), [medium volatility], anchor: "east", font: font("script"))
      rectangle((0, -0.71), (7, -0.39), fill: pale-blue, draw: none)
      rectangle((0, -0.71), (2.5959, -0.39), fill: teal, draw: none)
      node((7.15, -0.55), [37.1% loss], anchor: "west", font: font("script"))
      node((-0.2, -1.1), [low volatility], anchor: "east", font: font("script"))
      rectangle((0, -1.26), (7, -0.94), fill: pale-blue, draw: none)
      rectangle((0, -1.26), (0.5121, -0.94), fill: teal, draw: none)
      node((7.15, -1.1), [7.3% loss], anchor: "west", font: font("script"))
    })
  ]
]
