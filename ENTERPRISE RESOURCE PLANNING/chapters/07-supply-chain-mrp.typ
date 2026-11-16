#import "/.shared/typst/utp.typ": *
#unit("chapters", "07-supply-chain-mrp")

= Supply Chain Management, MRP, Purchasing, and Inventory <ch:scm>

#chapterguide[You should understand forecasts, production plans, and bills of materials.][explain supply-chain integration, calculate basic material requirements, distinguish gross from net requirements, connect lead time and lot sizing to purchasing, and evaluate supply-chain performance with operational metrics.]

#note[
  This chapter follows Tutorial 7 and Chapter 4 of the textbook. Tutorial 7 asks
  students to research a manufacturing company that implemented SCM and to compare
  CRM with SCM. The textbook adds MRP, supplier integration, and performance
  metrics such as cash-to-cash cycle time, fill rate, lead time, and on-time
  performance.
]

== What Supply Chain Management coordinates

#term[Supply Chain Management (SCM)] coordinates the organisations and activities
that move materials, information, and products from suppliers through production
and distribution to the customer. Three different things flow along the same
chain, and they do not all flow the same way.

#utpfig([Materials move downstream, money moves upstream, and information must move both ways. A chain that passes only goods and invoices --- with no demand signal --- forces every party to guess and hold its own buffer.], label: <fig:three-flows>)[
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
      connect("n" + str(i), "n" + str(j), line-width: widths.semithick, draw: teal, end: arrow-tip("Stealth", length: 1.8mm, line: widths.semithick))
    }
    node((6.8, -0.6), [#strong[materials --- physical goods, one direction only]], ..proccap, anchor: "north", text: teal)
    connect((13.4, -1.6), (0.2, -1.6), draw: green, line-width: 1.0959pt, end: arrow-tip("Stealth", length: 2.2mm, line: 1.0959pt))
    node((6.8, -1.76), [#strong[money --- payment, back up the chain]], ..proccap, anchor: "north", text: green)
    connect((0.2, -0.5), (0.2, -1.6), ..proclink)
    connect((13.4, -0.5), (13.4, -1.6), ..proclink)
  })
]

A traditional view treats each company as an isolated optimiser: the buyer
pressures the supplier, the supplier withholds information, and everyone carries
inventory to protect itself. An integrated view recognises that poor coordination
creates cost for all parties.

== From production requirements to material requirements

A sales forecast does not tell Purchasing how many tyres to buy. Production
planning first fixes the finished-product quantities; the BOM then converts them
into component quantities. For component $j$ used in products $i$:

$ "Gross Requirement"_j = sum _i ("Planned Quantity"_i times "BOM Quantity"_(i j)). $

That is a #term[gross requirement] --- the amount needed before considering what
is already available.

== MRP: gross requirements are not purchase orders

#term[Material Requirements Planning (MRP)] determines the quantity #emph[and]
timing of supply. It takes the gross requirement and reduces it by what already
exists or is already coming, then adjusts what remains to a purchasable quantity.

#utpfig([The three adjustments between what production needs and what Purchasing actually orders. Skipping any of them produces either a stockout or excess stock, and the order quantity usually matches the net requirement only by coincidence.], label: <fig:gross-to-net>)[
  #canvas({
    node((1.5, 0), [Gross requirement \
  #fsize("tiny")[#text(weight: "regular")[40 tyres]]], name: "g", ..procstep, min-width: 2.9, min-height: 1)
    node((5.3, 0), [$-$ on hand \
  #fsize("tiny")[#text(weight: "regular")[12 in stock]]], name: "a", ..procquiet, min-width: 2.9, min-height: 1)
    node((9.1, 0), [$-$ scheduled receipts \
  #fsize("tiny")[#text(weight: "regular")[0 on order]]], name: "b", ..procquiet, min-width: 2.9, min-height: 1)
    node((12.9, 0), [$=$ net requirement \
  #fsize("tiny")[#text(weight: "regular")[28 tyres]]], name: "c", ..procwarn, min-width: 2.9, min-height: 1)
    connect("g", "a", ..procflow)
    connect("a", "b", ..procflow)
    connect("b", "c", ..procflow)
    node((12.9, -2.15), [Planned order \
  #fsize("tiny")[#text(weight: "regular")[30 tyres --- 3 boxes of 10]]], name: "d", ..procgood, min-width: 4.2, min-height: 1)
    connect("c", "d", ..procflow)
    node(along("c", "d", t: 50%), [round up to the supplier’s lot size], ..procnote, text-width: 2.4, anchor: "west")
    node((0, -2.15), [#emph[Safety stock] is added to the requirement before netting; #emph[lead time] then decides how many weeks earlier the order must be released. Neither changes what production needs --- only what Purchasing does about it.], ..procnote, anchor: "west", text-width: 8.4, align: left)
  })
]

$ "Net Requirement" = max(0, med "Gross"+"Desired Ending Stock"-"Available Supply"). $

== MRP is time-phased, not a single sum

Availability in one week cannot satisfy a requirement in an earlier week. MRP is
therefore a grid: rows for each quantity, columns for each period.

#utpfig([The standard MRP record for Rubber Tires: 12 on hand, a scheduled receipt of 10 in Week 2, requirements of 20 in Weeks 3 and 5, a two-week purchasing lead time, and boxes of 10. Note the two diagonals --- the net requirement of 18 is rounded up to a receipt of 20, and that receipt must be released two weeks earlier.], label: <fig:mrp-record>)[
  #canvas({
    for (k, w) in ((0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6)) {
      let x = 5.1 + k * 1.72
      node((x, 0.62), [#strong[Week #w]], ..proccap, text: navy)
    }
    for (r, lbl, va, vb, vc, vd, ve, vf, clr) in ((0, "Gross requirement", "–", "–", "20", "–", "20", "–", blue), (1, "Scheduled receipts", "–", "10", "–", "–", "–", "–", muted), (2, "Projected on hand", "12", "22", "2", "2", "2", "2", teal), (3, "Net requirement", "–", "–", "–", "–", "18", "–", orange), (4, "Planned receipt", "–", "–", "–", "–", "20", "–", green), (5, "Planned order release", "–", "–", "20", "–", "–", "–", green)) {
      let y = -r * 0.68
      node((0, y), [#strong[#lbl]], ..proccap, anchor: "west", align: left, text-width: 4.2)
      for (k, vv) in ((0, [#va]), (1, [#vb]), (2, [#vc]), (3, [#vd]), (4, [#ve]), (5, [#vf])) {
        let x = 5.1 + k * 1.72
        node((x, y), [#vv], draw: mix(clr, 55%), fill: mix(clr, 8%), rounded: 1mm, min-width: 1.55, min-height: 0.54, font: font("script", fill: navy))
      }
    }
    connect((9.4, -3.4), (11.9, -2.98), out-angle: -25deg, in-angle: -155deg, ..procback, line-width: 0.9963pt, end: arrow-tip("Stealth", length: 2mm, line: 0.9963pt), name: "curve-1")
    node((7, -3.95), [Week 5 is short by 18, but tyres come in boxes of 10, so the planned receipt is 20. The two-week lead time then places the order release in Week 3.], ..procnote, anchor: "north", text-width: 13.6)
  })
]

#term[Lead time] is the elapsed time between initiating supply and having the
material usable. If a component is needed in Week 5 with a two-week lead time,
the order must be released in Week 3. MRP therefore answers both #emph[how much]
and #emph[when].

== Lot sizing changes the quantity

Suppliers sell in fixed packs, pallets, minimum quantities, or economic batches.
A net requirement of 28 tyres bought in boxes of 10 becomes a purchase of 30. The
ordered quantity is a step function of the requirement, not a copy of it.

#example[
  West End Bicycles plans 20 Road Bikes. The BOM needs 1 Aluminium Frame and 2
  Rubber Tires per bike. On hand: 7 frames, 12 tyres. Ignoring safety stock and
  scheduled receipts,

  $ "Frames net"=20-7=13, wide "Tyres net"=40-12=28. $

  If tyres come in boxes of 10, the procurement quantity is 30 even though the net
  requirement is 28. The extra 2 become next period’s opening stock.
]

== Purchasing and receiving are separate business events

A purchase order records a commitment to buy. A receipt records what physically
arrived. They can differ in date and in quantity, and only one of them creates
usable stock.

#utpfig([The two events and what each proves. The gap between them is where supplier performance is measured --- and where a planner who treats an open order as available inventory releases production that cannot start.], label: <fig:po-vs-receipt>)[
  #canvas({
    node((2.4, 1.5), [Purchase Order \
  #fsize("tiny")[#text(weight: "regular")[confirmed 1 March]]], name: "po", ..procstep, min-width: 3.6, min-height: 1.05)
    node((11.4, 1.5), [Receipt validated \
  #fsize("tiny")[#text(weight: "regular")[14 March, 28 of 30 accepted]]], name: "rc", ..procgood, min-width: 3.6, min-height: 1.05)
    connect("po", "rc", ..procflow)
    node(along("po", "rc", t: 50%), [supplier lead time], ..procnote, anchor: "south")
    node((2.4, -0.15), [proves: what we asked for, at what price, by when], ..procdoc, min-width: 3.9, text-width: 3.5, min-height: 1.15)
    node((11.4, -0.15), [proves: what we can actually use, and when], ..procdoc, min-width: 3.9, text-width: 3.5, min-height: 1.15, draw: green)
    connect((2.4, 0.95), (2.4, 0.45), ..proclink)
    connect((11.4, 0.95), (11.4, 0.45), ..proclink)
    node((6.9, 0.9), [13 days: on-time performance], ..procchipwarn, anchor: "north")
    node((6.9, 0.2), [28 of 30: initial fill rate], ..procchipwarn, anchor: "north")
    node((6.9, -0.7), [stock rises #emph[here], not at the order --- manufacturing cannot start before this], ..procchipbad, anchor: "north", text-width: 4.8, align: center)
  })
]

== Supplier integration

Sharing realistic forecasts and status data helps suppliers prepare capacity and
materials; in return the buyer gains visibility of lead time and availability.
This does not mean giving every supplier unrestricted ERP access --- it means
designing controlled exchange so both sides plan around the same signals.

== SCM measures of success

#utptable[
  #tabularx(
    columns: (24%, 1fr),
    styles: (navy-bold,),
    header: ([Metric], [Meaning]),
    [Cash-to-cash cycle time], [Time between paying for inputs and collecting cash from the customer. Shorter cycles tie up less working capital.],
    [Total SCM cost], [Cost of buying and handling inventory, processing orders, and supporting the supply chain’s information systems.],
    [Initial fill rate], [Percentage of an order supplied in the first shipment.],
    [Initial order lead time], [Time the supplier needs to fill the order.],
    [On-time performance], [How often the supplier meets the agreed delivery date.],
  )
]

The cash-to-cash cycle is the one worth drawing, because it is the metric that
connects supply-chain decisions to the finance chapter.

#utpfig([Cash leaves when the supplier is paid and returns when the customer pays. The gap is financed by the company. Shortening inventory days or collection days shrinks it; paying suppliers later shrinks it too, but at the cost of the supplier relationship.], label: <fig:cash-to-cash>)[
  #canvas({
    connect((0, 0), (14.4, 0), draw: mix(muted, 45%))
    for (x, lbl) in ((0.6, [materials \
  received]), (3.6, [supplier \
  paid]), (8.4, [bikes \
  delivered]), (13.2, [customer \
  pays])) {
      connect((x, -0.16), (x, 0.16), draw: mix(muted, 55%))
      node((x, -0.28), [#lbl], ..procnote, anchor: "north", text-width: 1.9)
    }
    connect((3.6, 1.15), (13.2, 1.15), draw: red, line-width: 5.9776pt, opacity: 28%)
    node((8.4, 1.15), [cash-to-cash cycle --- financed by the company], ..procchipbad)
    connect((0.6, 2.15), (8.4, 2.15), draw: blue, line-width: 4.9813pt, opacity: 30%)
    node((4.5, 2.15), [inventory days], ..procchip, draw: blue, fill: pale-blue)
    connect((8.4, 2.85), (13.2, 2.85), draw: green, line-width: 4.9813pt, opacity: 30%)
    node((10.8, 2.85), [collection days], ..procchip)
    connect((0.6, 3.55), (3.6, 3.55), draw: orange, line-width: 4.9813pt, opacity: 30%)
    node((2.1, 3.55), [payment days], ..procchipwarn)
  })
]

Metrics must be read together. A supplier can post high on-time performance and a
poor fill rate by delivering punctually but short every time.

== CRM versus SCM

#utptable[
  #tabularx(
    columns: (18%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Aspect], [CRM], [SCM]),
    [Primary relationship], [Prospects and customers], [Suppliers, production, logistics partners],
    [Primary signal], [Customer interest and demand], [Material requirements and fulfilment],
    [Typical records], [Leads, opportunities, contacts, campaigns, service history], [Purchase orders, receipts, inventory, production plans, supplier performance],
    [Shared objective], multicolumn(2, left)[Deliver customer value efficiently by coordinating information rather than optimising one department in isolation.],
    [Where they meet], multicolumn(2, left)[Demand captured by CRM/Sales becomes a planning requirement for SCM; SCM status returns to Sales so customers receive accurate promises.],
  )
]

#utpfig([The two halves of the enterprise face opposite directions and touch at exactly two points: the demand signal going upstream, and the availability answer coming back. Those two arrows are what integration buys.], label: <fig:crm-vs-scm>)[
  #canvas({
    rectangle((0, -1.35), (6.4, 2.35), draw: mix(teal, 45%), fill: mix(pale-teal, 45%), rounded: 2.5mm)
    node((3.2, 2.05), [#strong[SCM --- upstream]], ..proccap, text: teal)
    node((3.2, 1.35), [Suppliers and lead times], ..procstep, min-width: 5.4, min-height: 0.62, draw: teal)
    node((3.2, 0.6), [Purchase orders and receipts], ..procstep, min-width: 5.4, min-height: 0.62, draw: teal)
    node((3.2, -0.15), [Inventory and production], ..procstep, min-width: 5.4, min-height: 0.62, draw: teal)
    node((3.2, -0.95), [optimises #emph[supply]], ..procnote)
    rectangle((8.2, -1.35), (14.6, 2.35), draw: mix(blue, 45%), fill: mix(pale-blue, 45%), rounded: 2.5mm)
    node((11.4, 2.05), [#strong[CRM --- downstream]], ..proccap, text: blue)
    node((11.4, 1.35), [Leads and opportunities], ..procstep, min-width: 5.4, min-height: 0.62)
    node((11.4, 0.6), [Quotations and orders], ..procstep, min-width: 5.4, min-height: 0.62)
    node((11.4, -0.15), [Service history], ..procstep, min-width: 5.4, min-height: 0.62)
    node((11.4, -0.95), [optimises #emph[demand]], ..procnote)
    connect((8.1, 1), (6.5, 1), ..procback)
    node(along((8.1, 1), (6.5, 1), t: 50%), [demand signal], ..procnote, text-width: 1.6, anchor: "south")
    connect((6.5, 0.2), (8.1, 0.2), ..procflow)
    node(along((6.5, 0.2), (8.1, 0.2), t: 50%), [availability answer], ..procnote, text-width: 1.6, anchor: "north")
  })
]

== SCM in Odoo 19 Community

#note[
  #strong[In Odoo 19 Community.] The West End Bicycles guide uses this procure-and-receive sequence:

  + create vendors and raw-material products;
  + link each vendor to the material it supplies and the vendor price;
  + create one RFQ per vendor and assign the Purchasing Officer as Buyer;
  + confirm each RFQ into a Purchase Order;
  + open the linked Receipt and validate it;
  + verify that on-hand raw-material stock rises;
  + use those materials in the Road Bike manufacturing order;
  + validate the customer delivery, reducing finished-goods stock.
]

#warning[
  An open Purchase Order is not available inventory. A planner who treats ordered
  material as on hand releases production that cannot start
  (#figref(<fig:po-vs-receipt>)).
]

#exercises[
  For the Road Bike BOM, take a production plan of 50 bikes with on-hand inventory
  of 12 frames, 70 tyres, 18 brake sets, 20 gear sets, and 15 chains. Calculate the
  net requirement for each component, then add one realistic lot-size rule and
  recalculate the purchase quantity.
]

#questions[
  + What is the difference between gross and net material requirements?
  + Why must lead time appear in MRP rather than only the required quantity?
  + How do CRM and SCM interact in a customer-order process?
]
