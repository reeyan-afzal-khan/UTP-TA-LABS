#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let dir = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.6, min-height: 0.75, font: font("small", weight: "bold", fill: navy))
      let file = (draw: teal, fill: pale-teal, rounded: 1mm, min-width: 1.9, min-height: 0.65, font: font("script", fill: navy))
      node((0, 0), [root], name: "tree-1", ..dir)
      node((rel: (-4.2, -1.55), to: "tree-1"), [home], name: "tree-2", ..dir)
      connect("tree-1", "tree-2", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
      node((rel: (-1.175, -1.55), to: "tree-2"), [notes.txt], name: "tree-3", ..file)
      connect("tree-2", "tree-3", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
      node((rel: (1.175, -1.55), to: "tree-2"), [code.c], name: "tree-4", ..file)
      connect("tree-2", "tree-4", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
      node((rel: (0, -1.55), to: "tree-1"), [etc], name: "tree-5", ..dir)
      connect("tree-1", "tree-5", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
      node((rel: (0, -1.55), to: "tree-5"), [config], name: "tree-6", ..file)
      connect("tree-5", "tree-6", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
      node((rel: (4.2, -1.55), to: "tree-1"), [tmp], name: "tree-7", ..dir)
      connect("tree-1", "tree-7", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    })
  ]
]
