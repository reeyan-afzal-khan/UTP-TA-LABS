#import "/.shared/typst/utp.typ": *

#utpcompactlabfigure[How this program runs][
  #labgraphic[
    #canvas(compact: true, {
      node((0, 0), [#strong[1] \
    Store both directions], name: "s0", font: font("small"), ..utpstep, text-width: 2.5, min-height: 1.15)
      node((2.95, 0), [#strong[2] \
    BFS with queue], name: "s1", font: font("small"), ..utpstep, text-width: 2.5, min-height: 1.15)
      node((5.9, 0), [#strong[3] \
    DFS with call stack], name: "s2", font: font("small"), ..utpstep, text-width: 2.5, min-height: 1.15)
      node((8.85, 0), [#strong[4] \
    Backtrack exact path], name: "s3", font: font("small"), ..utpstep, text-width: 2.5, min-height: 1.15)
      connect("s0.east", "s1.west", ..utparrow)
      connect("s1.east", "s2.west", ..utparrow)
      connect("s2.east", "s3.west", ..utparrow)
    })
  ]
]
