#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas(x: 15.06cm, {
      let card = (draw: mix(blue, 65%), fill: pale-blue, rounded: 1.8mm, line-width: 0.6974pt, text-width: 0.27 * 15.06, min-width: 0.34 * 15.06, min-height: 1.18, inner-xsep: 4mm, inner-ysep: 2mm, align: center, font: font("script", fill: navy))
      let flow = (line-width: 0.8966pt, draw: teal, end: arrow-tip("Stealth", length: 2.2mm, width: 1.6mm, line: 0.8966pt))
      let testflow = (line-width: 0.8966pt, draw: mix(orange, 85%, other: black), end: arrow-tip("Stealth", length: 2.2mm, width: 1.6mm, line: 0.8966pt))
      let targetflow = (line-width: 0.797pt, draw: mix(orange, 85%, other: black), dash: "dashed", end: arrow-tip("Stealth", length: 2.2mm, width: 1.6mm, line: 0.797pt))
      let flowlabel = (fill: white, rounded: 1mm, inner-xsep: 2.5mm, inner-ysep: 1mm, font: font("tiny", weight: "bold"))
      node((0.5, 4.2), [#text(fill: teal)[#strong[01 AVAILABLE DATA]] \ #v(3.9851pt)
     Features and target \
    before splitting], name: "all", ..card, draw: mix(teal, 80%), fill: pale-teal)
      node((0.28, 0.85), [#text(fill: blue)[#strong[02A TRAINING PARTITION]] \ #v(3.9851pt)
     Used to learn \
    model parameters], name: "train", ..card)
      node((0.72, 0.85), [#text(fill: mix(orange, 85%, other: black))[#strong[02B TEST PARTITION]] \ #v(3.9851pt)
     Held out from \
    model fitting], name: "test", ..card, draw: mix(orange, 80%), fill: pale-orange)
      node((0.28, -1.15), [#text(fill: blue)[#strong[03A FIT + FREEZE]] \ #v(3.9851pt)
     Model and preprocessing \
    are now fixed], name: "model", ..card)
      node((0.72, -1.15), [#text(fill: mix(orange, 85%, other: black))[#strong[03B TEST FEATURES]] \ #v(3.9851pt)
     Apply frozen \
    preprocessing only], name: "features", ..card, draw: mix(orange, 80%), fill: pale-orange)
      node((0.5, -3.15), [#text(fill: teal)[#strong[04 TEST PREDICTIONS]] \ #v(3.9851pt)
     Fixed model applied \
    to test features], name: "pred", ..card, draw: mix(teal, 80%), fill: pale-teal)
      node((0.5, -5.05), [#text(fill: teal)[#strong[05 EVALUATE]] \ #v(3.9851pt)
     MAE, RMSE, and \
    residual diagnostics], name: "eval", ..card, draw: mix(teal, 80%), fill: pale-teal)
      coordinate("branch", (0.5, 2.45))
      connect("all.south", "branch", draw: teal, line-width: 0.8966pt)
      circle-at("branch", 1.1955pt, fill: teal, draw: none)
      node((0.5, 2.95), [TRAIN / TEST SPLIT], ..flowlabel, text: teal)
      connect("branch", "-|", "train.north", ..flow)
      connect("branch", "-|", "test.north", ..testflow)
      connect("train.south", "model.north", ..flow)
      connect("test.south", "features.north", ..testflow)
      coordinate("merge", (0.5, -2.15))
      connect("model.south", "|-", "merge", draw: teal, line-width: 0.8966pt)
      connect("features.south", "|-", "merge", draw: mix(orange, 85%, other: black), line-width: 0.8966pt)
      circle-at("merge", 1.1457pt, fill: teal, draw: none)
      connect("merge", "pred.north", ..flow)
      connect("pred.south", "eval.north", ..flow)
      connect("test.east", (rel: (0.09 * 15.06, 0), to: "test.east"), "|-", "eval.east", ..targetflow)
      node((0.82, -4.78), [HELD-OUT TARGETS], ..flowlabel, text: mix(orange, 85%, other: black))
    })
  ]
]
