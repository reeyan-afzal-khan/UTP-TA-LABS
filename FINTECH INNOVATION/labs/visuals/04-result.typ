#import "/.shared/typst/utp.typ": *

#labvisual[Synthetic cohort: where users leave the funnel][
  #labgraphic[
    #canvas({
      node((-0.2, 0), [app open], anchor: "east", font: font("script"))
      rectangle((0, -0.16), (7, 0.16), fill: pale-blue, draw: none)
      rectangle((0, -0.16), (7, 0.16), fill: teal, draw: none)
      node((7.15, 0), [1000.0 users], anchor: "west", font: font("script"))
      node((-0.2, -0.55), [signup start], anchor: "east", font: font("script"))
      rectangle((0, -0.71), (7, -0.39), fill: pale-blue, draw: none)
      rectangle((0, -0.71), (5.215, -0.39), fill: teal, draw: none)
      node((7.15, -0.55), [745.0 users], anchor: "west", font: font("script"))
      node((-0.2, -1.1), [id upload], anchor: "east", font: font("script"))
      rectangle((0, -1.26), (7, -0.94), fill: pale-blue, draw: none)
      rectangle((0, -1.26), (4.41, -0.94), fill: teal, draw: none)
      node((7.15, -1.1), [630.0 users], anchor: "west", font: font("script"))
      node((-0.2, -1.65), [id verified], anchor: "east", font: font("script"))
      rectangle((0, -1.81), (7, -1.49), fill: pale-blue, draw: none)
      rectangle((0, -1.81), (2.723, -1.49), fill: teal, draw: none)
      node((7.15, -1.65), [389.0 users], anchor: "west", font: font("script"))
      node((-0.2, -2.2), [address entered], anchor: "east", font: font("script"))
      rectangle((0, -2.36), (7, -2.04), fill: pale-blue, draw: none)
      rectangle((0, -2.36), (2.457, -2.04), fill: teal, draw: none)
      node((7.15, -2.2), [351.0 users], anchor: "west", font: font("script"))
      node((-0.2, -2.75), [account funded], anchor: "east", font: font("script"))
      rectangle((0, -2.91), (7, -2.59), fill: pale-blue, draw: none)
      rectangle((0, -2.91), (2.03, -2.59), fill: teal, draw: none)
      node((7.15, -2.75), [290.0 users], anchor: "west", font: font("script"))
      node((-0.2, -3.3), [first payment], anchor: "east", font: font("script"))
      rectangle((0, -3.46), (7, -3.14), fill: pale-blue, draw: none)
      rectangle((0, -3.46), (1.841, -3.14), fill: teal, draw: none)
      node((7.15, -3.3), [263.0 users], anchor: "west", font: font("script"))
    })
  ]
]
