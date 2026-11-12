#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[The two ends of a queue][
  #labgraphic[
    #canvas(compact: true, {
      let queueout = (draw: teal, fill: pale-teal, rounded: 1mm, align: center, font: font("script", fill: navy), inner-xsep: 2mm, inner-ysep: 1.2mm)
      let queuein = (draw: orange, fill: pale-orange, rounded: 1mm, align: center, font: font("script", fill: navy), inner-xsep: 2mm, inner-ysep: 1.2mm)
      for (i, vv) in ("A", "B", "C", "D").enumerate() {
        node((1.5 * i, 0), [#vv], name: "c" + str(i), ..utpcell, min-width: 1.5, min-height: 0.82)
      }
      node((0, -0.6), [FRONT], ..utptag, anchor: "north")
      node((4.5, -0.6), [REAR], ..utptag, anchor: "north")
      node((-1.2, 0), [#strong[dequeue] \ #v(-0.15em)
    #fsize("tiny")[oldest leaves]], name: "deq", ..queueout, anchor: "east")
      connect("c0.west", "deq.east", ..utparrow)
      node((5.7, 0), [#strong[enqueue] \ #v(-0.15em)
    #fsize("tiny")[newest joins]], name: "enq", ..queuein, anchor: "west")
      connect("enq.west", "c3.east", ..utparrow)
    })
  ]
]
