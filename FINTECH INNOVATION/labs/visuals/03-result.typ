#import "/.shared/typst/utp.typ": *

#labvisual[Synthetic IID portfolios: dispersion of net returns][
  #labgraphic[
    #canvas({
      node((-0.2, 0), [1 loans], anchor: "east", font: font("script"))
      rectangle((0, -0.16), (7, 0.16), fill: pale-blue, draw: none)
      rectangle((0, -0.16), (7, 0.16), fill: teal, draw: none)
      node((7.15, 0), [28.0% SD], anchor: "west", font: font("script"))
      node((-0.2, -0.55), [5 loans], anchor: "east", font: font("script"))
      rectangle((0, -0.71), (7, -0.39), fill: pale-blue, draw: none)
      rectangle((0, -0.71), (3.2201, -0.39), fill: teal, draw: none)
      node((7.15, -0.55), [12.9% SD], anchor: "west", font: font("script"))
      node((-0.2, -1.1), [20 loans], anchor: "east", font: font("script"))
      rectangle((0, -1.26), (7, -0.94), fill: pale-blue, draw: none)
      rectangle((0, -1.26), (1.5897, -0.94), fill: teal, draw: none)
      node((7.15, -1.1), [6.4% SD], anchor: "west", font: font("script"))
      node((-0.2, -1.65), [100 loans], anchor: "east", font: font("script"))
      rectangle((0, -1.81), (7, -1.49), fill: pale-blue, draw: none)
      rectangle((0, -1.81), (0.7113, -1.49), fill: teal, draw: none)
      node((7.15, -1.65), [2.8% SD], anchor: "west", font: font("script"))
      node((-0.2, -2.2), [500 loans], anchor: "east", font: font("script"))
      rectangle((0, -2.36), (7, -2.04), fill: pale-blue, draw: none)
      rectangle((0, -2.36), (0.3128, -2.04), fill: teal, draw: none)
      node((7.15, -2.2), [1.2% SD], anchor: "west", font: font("script"))
    })
  ]
]
