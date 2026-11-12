#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.75, min-height: 1.05, align: center, font: font("script", weight: "bold", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
      node((0, 0), [1\. Define meaning \
    rows, keys, units, timing], name: "meaning", ..box-style)
      node(right-of("meaning", 0.45), [2\. Apply fixed rules \
    parse, standardize, validate], name: "rules", ..box-style)
      node(right-of("rules", 0.45), [3\. Split honestly \
    groups, time, population], name: "split", ..box-style)
      node(right-of("split", 0.45), [4\. Learn preparation \
    from training data only], name: "learn", ..box-style)
      connect("meaning", "rules", ..arr)
      connect("rules", "split", ..arr)
      connect("split", "learn", ..arr)
    })
  ]
]
