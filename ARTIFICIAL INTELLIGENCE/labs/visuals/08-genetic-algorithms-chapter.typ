#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let b = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.4, min-height: 0.9, align: center, font: font("script", fill: navy))
      let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
      node((0, 0), [Population], name: "p", ..b)
      node(right-of("p", 0.35), [Evaluate \
    fitness], name: "fit", ..b)
      node(right-of("fit", 0.35), [Select \
    parents], name: "sel", ..b)
      node(right-of("sel", 0.35), [Crossover], name: "cross", ..b)
      node(right-of("cross", 0.35), [Mutation], name: "mut", ..b)
      node(below-of("sel", 1), [New generation \
    \= elites + children], name: "rep", ..b, fill: pale-teal, draw: green)
      connect("p", "fit", ..arr)
      connect("fit", "sel", ..arr)
      connect("sel", "cross", ..arr)
      connect("cross", "mut", ..arr)
      connect("mut.south", "|-", "rep.east", ..arr)
      connect("rep.west", "-|", "p.south", ..arr)
      connect("fit.south", (rel: (0, -0.55), to: "fit.south"), "-|", "rep.north", ..arr, draw: green, dash: "dashed")
      node(along((rel: (0, -0.55), to: "fit.south"), ((rel: (0, -0.55), to: "fit.south"), "-|", "rep.north"), t: 50%), [best few copied unchanged (elitism)], xshift: -1cm, ..utplabel, text: green, anchor: "north")
    })
  ]
]
