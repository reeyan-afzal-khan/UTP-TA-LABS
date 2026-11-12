#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      node((0, 0), [#strong[Sense] \
    24 ultrasonic distances], name: "sense", font: font("small"), ..utpbox, min-width: 2.9, min-height: 1.1)
      node((4.6, 0), [#strong[Think] \
    readings $arrow.r$ action], name: "think", font: font("small"), ..utpbox, min-width: 2.9, min-height: 1.1, fill: pale-orange, draw: orange, line-width: 0.9963pt)
      node((9.2, 0), [#strong[Act] \
    one of four motions], name: "act", font: font("small"), ..utpbox, min-width: 2.9, min-height: 1.1)
      node((4.6, -2.2), [the room: walls, corners, doorways], name: "world", font: font("small"), ..utpbox, min-width: 3.4, min-height: 0.9, fill: pale-gray, draw: muted)
      connect("sense", "think", ..utparrow)
      connect("think", "act", ..utparrow)
      connect("act.south", "|-", "world.east", ..utparrow)
      connect("world.west", "-|", "sense.south", ..utparrow, dash: "dashed")
      node((4.6, 0.75), [Lab~5: this box is learned from 5,456 logged pairs], font: font("small"), ..utplabel, anchor: "south", text: orange)
      node((4.6, -2.72), [dashed arrow: feedback --- the next reading depends on this action], font: font("small"), ..utplabel, anchor: "north", text: muted)
    })
  ]
]
