#import "/.shared/typst/utp.typ": *

#labvisual[Synthetic scorecard: all four criteria have equal weight][
  #labgraphic[
    #canvas({
      node((-0.2, 0), [fx], anchor: "east", font: font("script"))
      rectangle((0, -0.16), (7, 0.16), fill: pale-blue, draw: none)
      rectangle((0, -0.16), (5.25, 0.16), fill: teal, draw: none)
      node((7.15, 0), [3.8 / 5], anchor: "west", font: font("script"))
      node((-0.2, -0.55), [wealth], anchor: "east", font: font("script"))
      rectangle((0, -0.71), (7, -0.39), fill: pale-blue, draw: none)
      rectangle((0, -0.71), (4.9, -0.39), fill: teal, draw: none)
      node((7.15, -0.55), [3.5 / 5], anchor: "west", font: font("script"))
      node((-0.2, -1.1), [sme services], anchor: "east", font: font("script"))
      rectangle((0, -1.26), (7, -0.94), fill: pale-blue, draw: none)
      rectangle((0, -1.26), (4.9, -0.94), fill: teal, draw: none)
      node((7.15, -1.1), [3.5 / 5], anchor: "west", font: font("script"))
      node((-0.2, -1.65), [payments], anchor: "east", font: font("script"))
      rectangle((0, -1.81), (7, -1.49), fill: pale-blue, draw: none)
      rectangle((0, -1.81), (4.2, -1.49), fill: teal, draw: none)
      node((7.15, -1.65), [3.0 / 5], anchor: "west", font: font("script"))
      node((-0.2, -2.2), [lending], anchor: "east", font: font("script"))
      rectangle((0, -2.36), (7, -2.04), fill: pale-blue, draw: none)
      rectangle((0, -2.36), (3.5, -2.04), fill: teal, draw: none)
      node((7.15, -2.2), [2.5 / 5], anchor: "west", font: font("script"))
      node((-0.2, -2.75), [deposits], anchor: "east", font: font("script"))
      rectangle((0, -2.91), (7, -2.59), fill: pale-blue, draw: none)
      rectangle((0, -2.91), (2.8, -2.59), fill: teal, draw: none)
      node((7.15, -2.75), [2.0 / 5], anchor: "west", font: font("script"))
      node((-0.2, -3.3), [trust compliance], anchor: "east", font: font("script"))
      rectangle((0, -3.46), (7, -3.14), fill: pale-blue, draw: none)
      rectangle((0, -3.46), (2.1, -3.14), fill: teal, draw: none)
      node((7.15, -3.3), [1.5 / 5], anchor: "west", font: font("script"))
    })
  ]
]
