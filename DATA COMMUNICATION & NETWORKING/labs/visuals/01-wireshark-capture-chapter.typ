#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      node((1.7, 1.75), [On the host], font: font("script", weight: "bold", fill: green))
      node((0.6, 0.9), [PC1], name: "a1", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
      node((2.8, 0.9), [SW], name: "a2", ..switch, min-width: 1.1, min-height: 0.6, font: font("tiny"))
      connect("a1", "a2", ..activepath)
      node((1.7, 0.05), [capture here \
     sees all of PC1’s traffic], font: font("tiny", fill: green), align: center)
      node((1.7, -0.62), [works], font: font("script", weight: "bold", fill: green))
      node((6.2, 1.75), [On a bystander port], font: font("script", weight: "bold", fill: red))
      node((5.1, 0.9), [PC1], name: "b1", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
      node((7.3, 0.9), [SW], name: "b2", ..switch, min-width: 1.1, min-height: 0.6, font: font("tiny"))
      node((7.3, -0.15), [PC3], name: "b3", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
      connect("b1", "b2", ..activepath)
      connect("b2", "b3", ..deadpath)
      node((6, -0.85), [capture on PC3 \
     sees nothing], font: font("tiny", fill: red), align: center)
      node((6.2, -1.5), [empty], font: font("script", weight: "bold", fill: red))
      node((10.7, 1.75), [On a mirrored port], font: font("script", weight: "bold", fill: blue))
      node((9.6, 0.9), [PC1], name: "c1", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
      node((11.8, 0.9), [SW], name: "c2", ..switch, min-width: 1.1, min-height: 0.6, font: font("tiny"))
      node((11.8, -0.15), [PC3], name: "c3", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
      connect("c1", "c2", ..activepath)
      connect("c2", "c3", ..flowarrow, dash: "dashed")
      node((10.5, -0.85), [switch copies frames \
     to the analyser], font: font("tiny", fill: blue), align: center)
      node((10.7, -1.5), [works], font: font("script", weight: "bold", fill: blue))
    })
  ]
]
