#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let laddercard = (draw: mix(blue, 70%), fill: pale-blue, rounded: 1.5mm, line-width: 0.6974pt, text-width: 0.78 * 15.06, min-height: 1.1, inner-xsep: 9mm, inner-ysep: 2.5mm, align: left, font: font("footnote", fill: navy))
      let badge = (shape: "circle", fill: blue, draw: white, line-width: 0.6974pt, min-size: 0.65, inner-sep: 0pt, font: font("script", weight: "bold", fill: white))
      let flow = (line-width: 0.797pt, draw: teal, end: tip("Stealth", length: 2mm, width: 1.5mm, line: 0.797pt))
      node((0, 0), [#strong[Context and purpose] \ #v(1.9925pt)
     Identify the decision, scientific concern, or operational need.], name: "context", ..laddercard)
      node(below-of("context", 0.28), [#strong[Answerable question] \ #v(1.9925pt)
     State exactly what should be learned, compared, predicted, or discovered.], name: "question", ..laddercard)
      node(below-of("question", 0.28), [#strong[Unit and population] \ #v(1.9925pt)
     Define what one row represents and where the conclusion should apply.], name: "unit", ..laddercard)
      node(below-of("unit", 0.28), [#strong[Variables and estimand] \ #v(1.9925pt)
     Select the measurements and target quantity that answer the question.], name: "vars", ..laddercard)
      node(below-of("vars", 0.28), [#strong[Method and validation] \ #v(1.9925pt)
     Choose an analysis and specify how uncertainty or error will be checked.], name: "method", ..laddercard)
      node(below-of("method", 0.28), [#strong[Evidence-supported claim] \ #v(1.9925pt)
     Report only what the design supports, with uncertainty and limitations.], name: "claim", ..laddercard, draw: mix(teal, 80%), fill: pale-teal)
      for (target, labelnum) in (("context", 1), ("question", 2), ("unit", 3), ("vars", 4), ("method", 5), ("claim", 6)) {
        node((rel: (0.45, 0), to: target + ".west"), [#labelnum], ..badge)
      }
      connect("context.south", "question.north", ..flow)
      connect("question.south", "unit.north", ..flow)
      connect("unit.south", "vars.north", ..flow)
      connect("vars.south", "method.north", ..flow)
      connect("method.south", "claim.north", ..flow)
    })
  ]
]
