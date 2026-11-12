#import "/.shared/typst/utp.typ": *

#labvisual[Fictional Platform P: verify each rating with evidence][
  #labgraphic[
    #canvas({
      node((-0.2, 0), [customer access], anchor: "east", font: font("script"))
      rectangle((0, -0.16), (7, 0.16), fill: pale-blue, draw: none)
      rectangle((0, -0.16), (7, 0.16), fill: teal, draw: none)
      node((7.15, 0), [5.0 / 5], anchor: "west", font: font("script"))
      node((-0.2, -0.55), [data], anchor: "east", font: font("script"))
      rectangle((0, -0.71), (7, -0.39), fill: pale-blue, draw: none)
      rectangle((0, -0.71), (5.6, -0.39), fill: teal, draw: none)
      node((7.15, -0.55), [4.0 / 5], anchor: "west", font: font("script"))
      node((-0.2, -1.1), [brand trust], anchor: "east", font: font("script"))
      rectangle((0, -1.26), (7, -0.94), fill: pale-blue, draw: none)
      rectangle((0, -1.26), (4.2, -0.94), fill: teal, draw: none)
      node((7.15, -1.1), [3.0 / 5], anchor: "west", font: font("script"))
      node((-0.2, -1.65), [capital talent], anchor: "east", font: font("script"))
      rectangle((0, -1.81), (7, -1.49), fill: pale-blue, draw: none)
      rectangle((0, -1.81), (5.6, -1.49), fill: teal, draw: none)
      node((7.15, -1.65), [4.0 / 5], anchor: "west", font: font("script"))
      node((-0.2, -2.2), [regulatory position], anchor: "east", font: font("script"))
      rectangle((0, -2.36), (7, -2.04), fill: pale-blue, draw: none)
      rectangle((0, -2.36), (2.8, -2.04), fill: teal, draw: none)
      node((7.15, -2.2), [2.0 / 5], anchor: "west", font: font("script"))
    })
  ]
]
