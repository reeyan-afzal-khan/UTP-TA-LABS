#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-production-planning")

= Production Planning: From Demand to a Feasible Production Plan <ch:production-planning>

#chapterguide[You should know that Sales generates demand information and Supply Chain must turn that demand into physical products.][explain the production-planning hierarchy, distinguish common production approaches, connect forecasts to capacity and inventory decisions, and explain the role of a bill of materials and manufacturing order.]

#note[
  This chapter follows Tutorial 3 (Production Planning) and Chapter 4 of the
  textbook. The tutorial asks students to select a production-planning approach,
  calculate a sales forecast, and prepare an S&OP plan. The Odoo build guide
  provides the Road Bike bill of materials and manufacturing workflow.
]

== What production planning is trying to decide

Production planning coordinates demand, inventory, materials, capacity, and
time. The planner works down a hierarchy in which each level fixes a decision
the level below must respect, and each level covers a shorter horizon in
finer detail.

#utpfig([The planning hierarchy read as a pyramid. Moving down, the horizon shortens and the detail sharpens: a yearly forecast for a product family becomes a daily instruction for one product.], label: <fig:planning-hierarchy>)[
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

== Production approaches

The most useful distinction is #emph[when] production happens relative to the
customer order. The point where the customer’s order first touches the process
is called the decoupling point: everything upstream of it is driven by forecast,
everything downstream by a real order.

#utpfig([The same four activities, three strategies. The orange marker is the decoupling point: work to its left is driven by forecast, work to its right by a real order. Moving it left cuts inventory risk and lengthens the customer’s wait.], label: <fig:decoupling-point>)[
  #canvas({
    for (x, t) in ((2, "Design"), (5, "Buy parts"), (8, "Manufacture"), (11, "Ship to customer")) {
      node((x, 3.05), [#strong[#t]], ..proccap)
    }
    for (i, nm, k) in ((0, "Make-to-stock", 4), (1, "Make-to-order", 3), (2, "Engineer-to-order", 1)) {
      let y = 2.2 - i * 1.55
      node((0.35, y), [#strong[#nm]], ..proccap, anchor: "east", align: right, text-width: 1.95)
      for s in range(1, 5) {
        let x = -1 + s * 3
        if s < k {
          node((x, y), [forecast], ..procquiet, min-width: 2.6, min-height: 0.72)
        } else {
          node((x, y), [customer order], ..procgood, min-width: 2.6, min-height: 0.72)
        }
      }
      let dx = -1 + k * 3 - 1.5
      connect((dx, y - 0.52), (dx, y + 0.52), draw: orange, line-width: 1.2951pt)
      node((dx, y - 0.6), [order enters here], ..procchipwarn, anchor: "north")
    }
    node((-0.3, -2.55), [#emph[Left] of the marker the company is guessing and carrying inventory risk. #emph[Right] of it the customer is waiting. West End Bicycles uses make-to-stock: Road Bikes are built before the customer order is delivered.], ..procnote, anchor: "west", text-width: 12.6, align: left)
  })
]

#utptable[
  #tabularx(
    columns: (21%, 31%, 1fr),
    styles: (navy-bold,),
    header: ([Approach], [Core idea], [Typical trade-off]),
    [Make-to-stock], [Produce finished goods before a specific customer order, based on expected demand.], [Fast fulfilment, but inventory risk if demand is wrong.],
    [Make-to-order], [Begin production after a customer order is received.], [Lower finished-goods inventory, but longer customer lead time.],
    [Engineer/configure-to-order], [Design or configure significant product details after the order.], [High customisation, but greater planning complexity and longer lead time.],
  )
]

== Sales forecasting

A #term[sales forecast] estimates future demand. It is neither a promise nor a
confirmed order. Forecasts are needed because supply decisions require lead time.

The textbook’s approach starts from last year’s demand, removes the unusual
effect of last year’s promotion, applies expected underlying growth, then adds
this year’s planned promotion.

#utpfig([The four-step adjustment for a single month. Skipping the first step would treat a one-off promotion as permanent base demand and inflate every later number.], label: <fig:forecast-build>)[
  #canvas({
    for (i, lbl, val, c) in ((0, [Last year’s sales], [5,500], muted), (1, [$-$ last year’s promotion], [$-$ 200], red), (2, [$=$ base demand], [5,300], blue), (3, [$times thin (1+g)$, $g=3 %$], [$+$ 159], green), (4, [$=$ base projection], [5,459], blue), (5, [$+$ this year’s promotion], [$+$ 0], green), (6, [$=$ forecast], [5,459], green)) {
      let y = -i * 0.78
      node((1.6, y), [#lbl], name: "b" + str(i), ..procdoc, anchor: "west", min-width: 7.4, text-width: 7, align: left, min-height: 0.66, draw: mix(c, 65%))
      node((9.3, y), [#val], ..procchip, anchor: "west", text-width: 1.5, align: center)
    }
    node((0, -0.4), [#strong[remove \
   the one-off]], ..proccap, anchor: "west", text-width: 1.5, align: left)
    node((0, -2.75), [#strong[grow the \
   base]], ..proccap, anchor: "west", text-width: 1.5, align: left)
    node((0, -4.5), [#strong[add the \
   new plan]], ..proccap, anchor: "west", text-width: 1.5, align: left)
    node((11.2, -2.35), [June for Footloose Sport Shoes: no promotion is planned this June, so the forecast equals the grown base.], ..procnote, anchor: "west", text-width: 4)
  })
]

For month $t$, with expected growth rate $g$:

$ "Base"_t = "Prev. sales"_t - "Prev. promo"_t, wide "Forecast"_t = "Base"_t(1+g) + "New promo"_t. $

#note[
  Forecasting must separate the underlying demand pattern from one-off causes.
  Multiplying a promotion-inflated total by a growth rate compounds the error every
  year.
]

== Sales and Operations Planning

#term[Sales and Operations Planning (S&OP)] turns the forecast into a feasible
aggregate production plan. Inventory is the buffer that lets production differ
from demand in any single month.

#utpfig([S&OP as a tank. Production fills it, demand drains it, and the level at the end of the month is the level at the start of the next. Capacity limits how fast the inlet can run.], label: <fig:sop-balance>)[
  #canvas({
    rectangle((5, -0.2), (9.6, 2.4), draw: blue, fill: mix(pale-blue, 55%), rounded: 1.5mm)
    rectangle((5.05, -0.15), (9.55, 1.15), draw: mix(blue, 35%), fill: pale-blue)
    node((7.3, 0.5), [Inventory], ..prochead)
    node((7.3, 1.75), [level at month end], ..procnote)
    node((1.4, 2.4), [Production $P_t$ \
  #fsize("tiny")[#text(weight: "regular")[what we choose to make]]], name: "prod", ..procstep, min-width: 3, min-height: 0.9)
    node((13.2, 2.4), [Demand $F_t$ \
  #fsize("tiny")[#text(weight: "regular")[what customers take]]], name: "dem", ..procgood, min-width: 3, min-height: 0.9)
    connect("prod.east", (5, 2.4), (5, 1.6), ..procflow)
    connect((9.6, 1.6), (9.6, 2.4), "dem.west", ..procflow)
    node((1.4, 0.6), [Capacity $C_t$ \
  #fsize("tiny")[#text(weight: "regular")[the ceiling on $P_t$]]], name: "cap", ..procwarn, min-width: 3, min-height: 0.8)
    connect("cap.north", "prod.south", ..procslow)
    node((7.3, -1.35), [$I_t = I_(t-1) + P_t - F_t$], ..procstore, min-width: 6.6, min-height: 0.85, draw: navy, fill: mix(navy, 7%))
    node((10.6, 0.5), [a positive balance is the buffer carried into next month], ..procnote, anchor: "west", text-width: 3.6)
  })
]

A feasible plan must respect capacity:

$ C_t = r times h times D_t, wide U_t = frac(P_t, C_t) times 100 % , $

where $r$ is the production rate, $h$ the hours per day, and $D_t$ the working
days in the month. The plan therefore balances three competing pressures:
customer demand, inventory holding, and capacity.

== Demand management and detailed scheduling

S&OP is deliberately aggregate. #term[Demand management] breaks the aggregate
plan into individual products and shorter periods; #term[detailed scheduling]
then fixes the actual runs. Longer runs reduce changeovers but raise inventory;
shorter runs cut inventory but spend capacity on setup.

#note[
  S&OP decides “how much should the factory produce this month?” Detailed
  scheduling decides “which product runs on which day, in what sequence?”
]

== The bill of materials connects planning to materials

A #term[bill of materials (BOM)] is the product recipe: the components and
quantities needed to make one finished unit. It is what converts a production
quantity into a purchasing requirement.

#utpfig([The supplied BOM, drawn as the tree it actually is. The right-hand column shows the same structure multiplied out for the manufacturing order of 5 bikes used throughout the practicals.], label: <fig:road-bike-bom>)[
  #canvas({
    node((3.2, 2.6), [Road Bike \
  #fsize("tiny")[#text(weight: "regular")[1 finished unit]]], name: "top", ..procstep, min-width: 3.4, min-height: 0.95, draw: green, fill: pale-teal)
    for (i, c, q) in ((0, "Aluminium Frame", 1), (1, "Rubber Tires", 2), (2, "Brake Set", 1), (3, "Gear Set", 1), (4, "Bicycle Chain", 1)) {
      let y = 1 - i * 0.82
      node((2.6, y), [#c], name: "c" + str(i), ..procdoc, anchor: "west", min-width: 3.4, text-width: 3, align: left, min-height: 0.68)
      node((6.2, y), [$times thin #(q)$], ..procchip, anchor: "west")
      connect((1.5, 2.15), "|-", "c" + str(i) + ".west", ..proclink)
    }
    connect((1.5, 2.15), (1.5, -2.28), ..proclink)
    node((0.2, -0.1), [#strong[per unit]], ..proccap, anchor: "west", text: muted)
    rectangle((8.4, -2.72), (14.6, 3.25), draw: mix(blue, 35%), fill: mix(pale-blue, 40%), rounded: 2.5mm)
    node((11.5, 2.95), [#strong[for a Manufacturing Order of 5]], ..proccap, text: blue)
    node((11.5, 2.2), [5 Road Bikes produced], ..procstep, min-width: 4.2, min-height: 0.8, draw: green, fill: pale-teal)
    for (i, c, q) in ((0, "Aluminium Frame", 5), (1, "Rubber Tires", 10), (2, "Brake Set", 5), (3, "Gear Set", 5), (4, "Bicycle Chain", 5)) {
      let y = 1 - i * 0.82
      node((8.8, y), [#c], ..procdoc, anchor: "west", min-width: 3.2, text-width: 2.8, align: left, min-height: 0.68)
      node((12.2, y), [$- thin #(q)$ from stock], ..procchipwarn, anchor: "west")
    }
    node((7.4, -3.05), [Completing the Manufacturing Order consumes the components on the left and creates the finished bikes on the right --- one event, two stock effects.], ..procnote, anchor: "north", text-width: 12.4)
  })
]

MRP later extends this multiplication by considering inventory, scheduled
receipts, lot sizes, and lead times.

== Manufacturing orders execute the plan

A plan says what should happen. A #term[manufacturing order (MO)] is the
instruction to produce a specific quantity. In an integrated system, completing
the MO is a stock event, not just a status change.

#utpfig([Before and after the Manufacturing Order for 5 Road Bikes, starting from the components bought in Lab 7. This before/after pair is the evidence the labs ask you to capture, and the quickest way to prove the manufacturing event reached the shared inventory data.], label: <fig:mo-stock-change>)[
  #canvas({
    axis(width: 13.6cm, height: 5.4cm, ybar: 2.9888pt, bar-width: 12.9514pt, ymin: 0, ymax: 14, ylabel: [units on hand], symbolic-x: ("Frame", "Tires", "Brake Set", "Gear Set", "Chain", "Road Bike"), xtick: "data", x-tick-label-style: font("script", fill: muted), enlarge-x-limits: 0.11, legend-style: (at: (0.5, 1.17), anchor: "north", columns: 2), ymajorgrids: true, grid-style: (draw: mix(muted, 22%)), nodes-near-coords: true, node-near-coord-style: (font: font("tiny", fill: muted),),
      addplot(draw: blue, fill: pale-blue, coords: (("Frame", 5), ("Tires", 10), ("Brake Set", 5), ("Gear Set", 5), ("Chain", 5), ("Road Bike", 0)), legend: [before the MO]),
      addplot(draw: green, fill: pale-teal, coords: (("Frame", 0), ("Tires", 0), ("Brake Set", 0), ("Gear Set", 0), ("Chain", 0), ("Road Bike", 5)), legend: [after the MO is marked Done]),
    )
  })
]

#note[
  #strong[In Odoo 19 Community.] In the West End Bicycles guide: create a Road Bike BOM for one unit; create a
  Manufacturing Order for 5; assign the Production Planner as responsible; confirm
  and check component availability; produce and mark the MO Done; then verify that
  component stock fell and Road Bike on-hand stock rose to 5.
]

== Safety stock and the cost of uncertainty

#term[Safety stock] is extra inventory held to reduce the risk of a stockout
when demand or supply is uncertain. More safety stock buys service protection
and costs holding expense and tied-up cash --- and the exchange rate between the
two is not linear.

#utpfig([Service level against safety stock for a representative demand distribution. The first units of buffer are cheap protection; the last few percent of service are very expensive, which is why 100% service is almost never the target.], label: <fig:safety-stock-curve>)[
  #canvas({
    axis(width: 12.8cm, height: 5.6cm, xlabel: [safety stock held (units)], ylabel: [service level (%)], xmin: 0, xmax: 100, ymin: 45, ymax: 102, ymajorgrids: true, grid-style: (draw: mix(muted, 22%)), legend-style: (at: (0.99, 0.03), anchor: "south-east"),
      addplot(draw: blue, smooth: true, domain: (0, 100), samples: 80, x => 50 + 50 * (1 - calc.exp(-x / 26)), legend: [service level achieved]),
      addplot(draw: orange, dash: "dashed", domain: (0, 100), samples: 2, x => 95, legend: [95% target]),
      {
        connect((78, 45), (78, 95), draw: green, line-width: 0.9963pt, dash: "dashed")
        node((16, 72), [cheap protection], ..procchip, anchor: "west", font: font("tiny"))
        node((76, 62), [expensive last few %], ..procchipwarn, anchor: "east", font: font("tiny"))
      },
    )
  })
]

Forecast accuracy matters because a worse forecast needs a bigger buffer for the
same service level. ERP does not remove uncertainty; it improves the information
used to manage it.

#warning[
  High capacity utilisation is not the same as good planning. A factory can keep
  machines busy producing goods nobody ordered. The objective is a sensible balance
  between demand, capacity, setup cost, and inventory cost.
]

#exercises[
  Choose one of the ventures suggested in Tutorial 3 --- furniture, cookies,
  printing, or your own. Decide whether make-to-stock, make-to-order, or a more
  customised approach fits, then explain what would go wrong under one of the
  others. Mark where the decoupling point sits in each case.
]

#questions[
  + Why can production differ from the sales forecast in a given month?
  + What information does a BOM provide that a sales forecast does not?
  + What stock changes should occur when a Manufacturing Order for 5 Road Bikes is completed?
]
