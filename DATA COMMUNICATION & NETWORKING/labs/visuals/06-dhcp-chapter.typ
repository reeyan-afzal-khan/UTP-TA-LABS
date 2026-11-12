#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      seqactor("c", 0, [Client (S1)], ..host)
      seqactor("s", 7.6, [Server (R1)], ..server)
      seqlife("c", -4.5)
      seqlife("s", -4.5)
      seqmsg("c", "s", -0.85, [#strong[D]iscover], "arrow")
      node((8.15, -0.85), [broadcast `255.255.255.255`], font: font("tiny", fill: orange), anchor: "west")
      seqmsg("s", "c", -1.75, [#strong[O]ffer], "arrowb")
      node((8.15, -1.75), [“you may have 10.0.12.20”], font: font("tiny", fill: muted), anchor: "west")
      seqmsg("c", "s", -2.65, [#strong[R]equest], "arrow")
      node((8.15, -2.65), [broadcast again --- see below], font: font("tiny", fill: orange), anchor: "west")
      seqmsg("s", "c", -3.55, [#strong[A]cknowledge], "arrowb")
      node((8.15, -3.55), [lease confirmed, clock starts], font: font("tiny", fill: green), anchor: "west")
      node((-0.35, -0.85), [src 0.0.0.0], font: font("tiny", fill: muted), anchor: "east", align: right)
      node((-0.35, -2.65), [src 0.0.0.0], font: font("tiny", fill: muted), anchor: "east", align: right)
      node((-0.35, -4.05), [now 10.0.12.20], font: font("tiny", fill: green), anchor: "east", align: right)
    })
  ]
]
