#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      connect((13.4, 1.5), (0.2, 1.5), ..procback, line-width: 1.0959pt)
      node((6.8, 1.66), [#strong[information --- forecasts, orders, and status, both ways]], ..proccap, anchor: "south", text: orange)
      connect((0.2, 1.5), (0.2, 0.5), ..proclink)
      connect((13.4, 1.5), (13.4, 0.5), ..proclink)
      for (i, n) in ((0, "Supplier"), (1, "Purchase"), (2, "Receive, store"), (3, "Manufacture"), (4, "Deliver"), (5, "Customer")) {
        let x = 0.2 + i * 2.64
        node((x, 0), [#n], name: "n" + str(i), ..procstep, min-width: 2.35, min-height: 0.85, text-width: 2.1)
      }
      for i in range(0, 5) {
        let j = int(i + 1)
        connect("n" + str(i), "n" + str(j), line-width: widths.semithick, draw: teal, end: tip("Stealth", length: 1.8mm, line: widths.semithick))
      }
      node((6.8, -0.6), [#strong[materials --- physical goods, one direction only]], ..proccap, anchor: "north", text: teal)
      connect((13.4, -1.6), (0.2, -1.6), draw: green, line-width: 1.0959pt, end: tip("Stealth", length: 2.2mm, line: 1.0959pt))
      node((6.8, -1.76), [#strong[money --- payment, back up the chain]], ..proccap, anchor: "north", text: green)
      connect((0.2, -0.5), (0.2, -1.6), ..proclink)
      connect((13.4, -0.5), (13.4, -1.6), ..proclink)
    })
  ]
]
