#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-production-planning")


#heading(level: 1)[Production Planning: From Demand to a Feasible Production Plan]
 <ch:production-planning>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should know that Sales generates demand information and Supply Chain must turn that demand into physical products.

*By the end, you can:* explain the production-planning hierarchy, distinguish common production approaches, connect forecasts to capacity and inventory decisions, and explain the role of a bill of materials and manufacturing order.]

#callout("sourcebasis", title: [Source basis])[This chapter follows Tutorial 3 (Production Planning) and Chapter 4 of the textbook. The tutorial asks students to select a production-planning approach, calculate a sales forecast, and prepare an S&OP plan. The Odoo build guide provides the Road Bike bill of materials and manufacturing workflow.]


#heading(level: 2)[What production planning is trying to decide]


Production planning coordinates demand, inventory, materials, capacity, and time. The planner works down a hierarchy in which each level fixes a decision the level below must respect, and each level covers a shorter horizon in finer detail.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/a73ed11710c904c6.svg")], caption: [The planning hierarchy read as a pyramid. Moving down, the horizon shortens and the detail sharpens: a yearly forecast for a product family becomes a daily instruction for one product.]) <fig:planning-hierarchy>


#heading(level: 2)[Production approaches]


The most useful distinction is #emph[when] production happens relative to the customer order. The point where the customer's order first touches the process is called the decoupling point: everything upstream of it is driven by forecast, everything downstream by a real order.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/f962543d2e9aa133.svg")], caption: [The same four activities, three strategies. The orange marker is the decoupling point: work to its left is driven by forecast, work to its right by a real order. Moving it left cuts inventory risk and lengthens the customer's wait.]) <fig:decoupling-point>

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Approach], [Core idea], [Typical trade-off],),
    table.hline(),
    [Make-to-stock], [Produce finished goods before a specific customer order, based on expected demand.], [Fast fulfilment, but inventory risk if demand is wrong.],
    [Make-to-order], [Begin production after a customer order is received.], [Lower finished-goods inventory, but longer customer lead time.],
    [Engineer/configure-to-order], [Design or configure significant product details after the order.], [High customisation, but greater planning complexity and longer lead time.],
  )]
  , kind: table
  )


#heading(level: 2)[Sales forecasting]


A #strong[sales forecast] estimates future demand. It is neither a promise nor a confirmed order. Forecasts are needed because supply decisions require lead time.

The textbook's approach starts from last year's demand, removes the unusual effect of last year's promotion, applies expected underlying growth, then adds this year's planned promotion.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/195a4fc2b330c0ec.svg")], caption: [The four-step adjustment for a single month. Skipping the first step would treat a one-off promotion as permanent base demand and inflate every later number.]) <fig:forecast-build>

For month $t$, with expected growth rate $g$:

$ upright("Base")_t = upright("Prev. sales")_t - upright("Prev. promo")_t \, #h(2em) upright("Forecast")_t = upright("Base")_t \( 1 + g \) + upright("New promo")_t . $

#callout("keyidea", title: [Key idea])[Forecasting must separate the underlying demand pattern from one-off causes. Multiplying a promotion-inflated total by a growth rate compounds the error every year.]


#heading(level: 2)[Sales and Operations Planning]


#strong[Sales and Operations Planning (S&OP)] turns the forecast into a feasible aggregate production plan. Inventory is the buffer that lets production differ from demand in any single month.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/cff5ce1d4e5bc786.svg")], caption: [S&OP as a tank. Production fills it, demand drains it, and the level at the end of the month is the level at the start of the next. Capacity limits how fast the inlet can run.]) <fig:sop-balance>

A feasible plan must respect capacity:

$ C_t = r times h times D_t \, #h(2em) U_t = P_t / C_t times 100 % \, $

where $r$ is the production rate, $h$ the hours per day, and $D_t$ the working days in the month. The plan therefore balances three competing pressures: customer demand, inventory holding, and capacity.


#heading(level: 2)[Demand management and detailed scheduling]


S&OP is deliberately aggregate. #strong[Demand management] breaks the aggregate plan into individual products and shorter periods; #strong[detailed scheduling] then fixes the actual runs. Longer runs reduce changeovers but raise inventory; shorter runs cut inventory but spend capacity on setup.

#callout("intuition", title: [Plain idea])[S&OP decides "how much should the factory produce this month?" Detailed scheduling decides "which product runs on which day, in what sequence?"]


#heading(level: 2)[The bill of materials connects planning to materials]


A #strong[bill of materials (BOM)] is the product recipe: the components and quantities needed to make one finished unit. It is what converts a production quantity into a purchasing requirement.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/93c842dccc4173af.svg")], caption: [The supplied BOM, drawn as the tree it actually is. The right-hand column shows the same structure multiplied out for the manufacturing order of 5 bikes used throughout the practicals.]) <fig:road-bike-bom>

MRP later extends this multiplication by considering inventory, scheduled receipts, lot sizes, and lead times.


#heading(level: 2)[Manufacturing orders execute the plan]


A plan says what should happen. A #strong[manufacturing order (MO)] is the instruction to produce a specific quantity. In an integrated system, completing the MO is a stock event, not just a status change.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/1c71a8747d624d5f.svg")], caption: [Before and after the Manufacturing Order for 5 Road Bikes, starting from the components bought in Lab 7. This before/after pair is the evidence the labs ask you to capture, and the quickest way to prove the manufacturing event reached the shared inventory data.]) <fig:mo-stock-change>

#callout("applicationbox", title: [Application walkthrough])[In the West End Bicycles guide: create a Road Bike BOM for one unit; create a Manufacturing Order for 5; assign the Production Planner as responsible; confirm and check component availability; produce and mark the MO Done; then verify that component stock fell and Road Bike on-hand stock rose to 5.]


#heading(level: 2)[Safety stock and the cost of uncertainty]


#strong[Safety stock] is extra inventory held to reduce the risk of a stockout when demand or supply is uncertain. More safety stock buys service protection and costs holding expense and tied-up cash --- and the exchange rate between the two is not linear.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/91c6f9304751d3f8.svg")], caption: [Service level against safety stock for a representative demand distribution. The first units of buffer are cheap protection; the last few percent of service are very expensive, which is why 100% service is almost never the target.]) <fig:safety-stock-curve>

Forecast accuracy matters because a worse forecast needs a bigger buffer for the same service level. ERP does not remove uncertainty; it improves the information used to manage it.

#callout("pitfall", title: [Common mistake])[High capacity utilisation is not the same as good planning. A factory can keep machines busy producing goods nobody ordered. The objective is a sensible balance between demand, capacity, setup cost, and inventory cost.]

#callout("tryit", title: [Try it yourself])[Choose one of the ventures suggested in Tutorial 3 --- furniture, cookies, printing, or your own. Decide whether make-to-stock, make-to-order, or a more customised approach fits, then explain what would go wrong under one of the others. Mark where the decoupling point sits in each case.]

#callout("quickcheck", title: [Check your understanding])[+ Why can production differ from the sales forecast in a given month?

+ What information does a BOM provide that a sales forecast does not?

+ What stock changes should occur when a Manufacturing Order for 5 Road Bikes is completed?]
