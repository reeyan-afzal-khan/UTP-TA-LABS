#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      let seg = (draw: blue, fill: pale-blue, min-width: 3, min-height: 0.8, font: font("script", fill: navy))
      let shared = (..seg, fill: pale-orange, draw: orange)
      let stk = (draw: teal, fill: pale-teal, min-width: 1.7, min-height: 0.8, font: font("script", fill: navy))
      let lab = (font: font("script", fill: muted), align: center)
      let warn = (font: font("script", fill: orange), align: center)
      rectangle((-2.1, -2.75), (8.7, 1.75), draw: navy, rounded: 2mm, line-width: 0.8966pt)
      node((-2, 1.65), [one process], font: font("small", weight: "bold", fill: navy), anchor: "north-west")
      node((-0.4, 0.85), [code (text)], ..seg)
      node((-0.4, -0.35), [globals], ..shared)
      node((-0.4, -1.55), [heap], ..shared)
      node((-0.4, -2.3), [one copy, seen by every thread], ..lab, text-width: 2.6)
      for (i, x) in ((1, 2.9), (2, 5.2), (3, 7.5)) {
        node((x, 0.85), [stack #i], ..stk)
        node((x, -0.35), [registers #i], ..stk)
        node((x, -1.08), [thread #i], ..lab)
      }
      node((5.2, -2.05), [private to each thread --- no synchronisation needed], ..lab, text-width: 5.6)
      node((3.3, -3.55), [The orange region is the whole reason a mutex exists. Two threads writing a global without one is a data race, and the outcome depends on scheduling --- which is why such a bug reproduces only sometimes.], ..warn, text-width: 11)
    })
  ]
]
