#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      node((0, 0), [PC1], name: "pc1", ..host)
      node(right-of("pc1", 1.5), [SW1], name: "sw1", ..switch)
      node(right-of("sw1", 2.9), [SW2], name: "sw2", ..switch)
      node(right-of("sw2", 1.5), [PC3], name: "pc3", ..host)
      connect("pc1", "sw1", ..flowarrow)
      node(along("pc1", "sw1", t: 50%), [access], ..netlabel, anchor: "south")
      connect("sw1", "sw2", ..flowarrow)
      node(along("sw1", "sw2", t: 50%), [trunk], ..netlabel, anchor: "south")
      connect("sw2", "pc3", ..flowarrow)
      node(along("sw2", "pc3", t: 50%), [access], ..netlabel, anchor: "south")
      node(below-of("pc1", 0.8), [#strong[no tag] \
     #fsize("tiny")[the host has no idea VLANs exist]], ..netframe, text-width: 1.9, align: center)
      node(below-of(("sw1", 50%, "sw2"), 0.8), [#strong[tag = VLAN 10] \
     #fsize("tiny")[added on entry, so the far switch knows]], ..netframe, text-width: 2.5, align: center, draw: blue, fill: pale-blue)
      node(below-of("pc3", 0.8), [#strong[no tag] \
     #fsize("tiny")[stripped again on the way out]], ..netframe, text-width: 1.9, align: center)
      connect((rel: (0, -0.35), to: "pc1"), (rel: (0, -0.75), to: "pc1"), draw: muted, dash: "dotted", end: arrow-tip("to", line: 0.4pt))
      connect((rel: (0, -0.2), to: ("sw1", 50%, "sw2")), (rel: (0, -0.68), to: ("sw1", 50%, "sw2")), draw: muted, dash: "dotted", end: arrow-tip("to", line: 0.4pt))
      connect((rel: (0, -0.35), to: "pc3"), (rel: (0, -0.75), to: "pc3"), draw: muted, dash: "dotted", end: arrow-tip("to", line: 0.4pt))
    })
  ]
]
