#import "/.shared/typst/utp.typ": *

#labvisual[Recall the chapter model][
  #labgraphic[
    #canvas({
      for (i, lvl, q, hh, d) in ((0, "Sales forecast", "What will customers want?", "12 months", "product family"), (1, "Sales & Operations Planning", "How much can we make, and when?", "monthly", "product family"), (2, "Demand management", "How much of each product, each week?", "weekly", "single product"), (3, "Detailed scheduling", "Which product runs on which day?", "daily", "one run")) {
        let y = -i * 1.12
        let w = 10.6 - i * 0.9
        let tw = w - 0.55
        node((6, y), [#lvl --- #emph[#q]], name: "p" + str(i), ..procstep, min-width: w, min-height: 0.9, text-width: tw)
        node((11.6, y), [#hh], ..procchip, anchor: "west")
        node((13.5, y), [#d], ..procnote, anchor: "west", text-width: 2.3)
      }
      for i in range(0, 3) {
        let j = int(i + 1)
        connect("p" + str(i), "p" + str(j), ..procflow)
      }
      node((3.5, -4.6), [Production], name: "prod", ..procgood, min-width: 3.3, min-height: 0.8)
      node((8.5, -4.6), [MRP $arrow.r$ Purchasing], name: "mrp", ..procgood, min-width: 3.3, min-height: 0.8)
      connect("p3.south", (rel: (0, -0.28), to: "p3.south"), "-|", "prod.north", ..procflow)
      connect("p3.south", (rel: (0, -0.28), to: "p3.south"), "-|", "mrp.north", ..procflow)
      node((11.6, 0.78), [#strong[horizon]], ..proccap, anchor: "west")
      node((13.5, 0.78), [#strong[detail]], ..proccap, anchor: "west")
    })
  ]
]
