#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      node((0, 0), [R1], name: "r1", ..router)
      node(right-of("r1", 3), [R2], name: "r2", ..router)
      node(below-of(("r1", 50%, "r2"), 1.7), [R3], name: "r3", ..router)
      connect("r1", "r2", ..netlink)
      node(along("r1", "r2", t: 50%), [10.0.12.0/24], ..netlabel, anchor: "south")
      connect("r1", "r3", ..netlink)
      node(along("r1", "r3", t: 50%), [10.0.13.0/24], ..netlabel, xshift: -1mm, anchor: "east")
      connect("r2", "r3", ..netlink)
      node(along("r2", "r3", t: 50%), [10.0.23.0/24], ..netlabel, xshift: 1mm, anchor: "west")
      node(above-of("r1", 0.1), [Lo0 10.0.1.1], ..netlabel)
      node(above-of("r2", 0.1), [Lo0 10.0.2.2], ..netlabel)
      node(below-of("r3", 0.1), [Lo0 10.0.3.3], ..netlabel)
    })
  ]
]
