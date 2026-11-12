#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[Why circular traversal uses do--while][
  #labgraphic[
    #canvas(compact: true, {
      for (i, (vv, ang)) in ((10, 90), (20, 0), (30, 270), (40, 180)).enumerate() {
        node((angle: (ang) * 1deg, radius: 1.6), [#vv], name: "t" + str(i), font: font("small"), ..utpnode, min-size: 0.9)
      }
      connect("t0", "t1", bend: 22deg, ..utparrow, name: "curve-1")
      connect("t1", "t2", bend: 22deg, ..utparrow, name: "curve-2")
      connect("t2", "t3", bend: 22deg, ..utparrow, name: "curve-3")
      connect("t3", "t0", bend: 22deg, ..utparrow, name: "curve-4")
      node((angle: (90) * 1deg, radius: 2.3), [start & stop here], font: font("small"), ..utptag, anchor: "south")
      node((0, 0), [visit order \
    10, 20, 30, 40], font: font("small"), ..utplabel, align: center, text: muted)
      draw.scope({
        draw.translate((5.3, 0))
        draw.translate((0, 0.35))
        node((0, 0.9), [#text(fill: red)[#strong[Wrong]] \ #v(0.9963pt)
     `while (current != head) {...}` \
     condition false immediately $arrow.r$ prints nothing], name: "bad", font: font("small"), ..utpstep, fill: pale-red, draw: red, text-width: 5.8, inner-xsep: 3mm, inner-ysep: 2.3mm, align: left, anchor: "north-west")
        node((0, -0.75), [#text(fill: green)[#strong[Right]] \ #v(0.9963pt)
     `do {...} while (current != head);` \
     body runs first, then the test ends the lap], name: "good", font: font("small"), ..utpstep, fill: pale-teal, draw: green, text-width: 5.8, inner-xsep: 3mm, inner-ysep: 2.3mm, align: left, anchor: "north-west")
      })
    })
  ]
]
