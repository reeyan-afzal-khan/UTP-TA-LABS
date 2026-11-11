#import "/.shared/typst/utp.typ": *
#unit("chapters", "07-supply-chain-mrp")


#heading(level: 1)[Supply Chain Management, MRP, Purchasing, and Inventory]
 <ch:scm>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand forecasts, production plans, and bills of materials.

*By the end, you can:* explain supply-chain integration, calculate basic material requirements, distinguish gross from net requirements, connect lead time and lot sizing to purchasing, and evaluate supply-chain performance with operational metrics.]

#callout("sourcebasis", title: [Source basis])[This chapter follows Tutorial 7 and Chapter 4 of the textbook. Tutorial 7 asks students to research a manufacturing company that implemented SCM and to compare CRM with SCM. The textbook adds MRP, supplier integration, and performance metrics such as cash-to-cash cycle time, fill rate, lead time, and on-time performance.]


#heading(level: 2)[What Supply Chain Management coordinates]


#strong[Supply Chain Management (SCM)] coordinates the organisations and activities that move materials, information, and products from suppliers through production and distribution to the customer. Three different things flow along the same chain, and they do not all flow the same way.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/3263be0ecbeea17e.svg")], caption: [Materials move downstream, money moves upstream, and information must move both ways. A chain that passes only goods and invoices --- with no demand signal --- forces every party to guess and hold its own buffer.]) <fig:three-flows>

A traditional view treats each company as an isolated optimiser: the buyer pressures the supplier, the supplier withholds information, and everyone carries inventory to protect itself. An integrated view recognises that poor coordination creates cost for all parties.


#heading(level: 2)[From production requirements to material requirements]


A sales forecast does not tell Purchasing how many tyres to buy. Production planning first fixes the finished-product quantities; the BOM then converts them into component quantities. For component $j$ used in products $i$:

$ upright("Gross Requirement")_j = sum_i #scale(x: 120%, y: 120%)[\(] upright("Planned Quantity")_i times upright("BOM Quantity")_(i j) #scale(x: 120%, y: 120%)[\)] . $

That is a #strong[gross requirement] --- the amount needed before considering what is already available.


#heading(level: 2)[MRP: gross requirements are not purchase orders]


#strong[Material Requirements Planning (MRP)] determines the quantity #emph[and] timing of supply. It takes the gross requirement and reduces it by what already exists or is already coming, then adjusts what remains to a purchasable quantity.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/08a4c90ba87c691e.svg")], caption: [The three adjustments between what production needs and what Purchasing actually orders. Skipping any of them produces either a stockout or excess stock, and the order quantity usually matches the net requirement only by coincidence.]) <fig:gross-to-net>

$ upright("Net Requirement") = max #scale(x: 120%, y: 120%)[\(] 0 \, #h(0em) upright("Gross") + upright("Desired Ending Stock") - upright("Available Supply") #scale(x: 120%, y: 120%)[\)] . $


#heading(level: 2)[MRP is time-phased, not a single sum]


Availability in one week cannot satisfy a requirement in an earlier week. MRP is therefore a grid: rows for each quantity, columns for each period.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/6d0c892d5b11c2dc.svg")], caption: [The standard MRP record for Rubber Tires: 12 on hand, a scheduled receipt of 10 in Week 2, requirements of 20 in Weeks 3 and 5, a two-week purchasing lead time, and boxes of 10. Note the two diagonals --- the net requirement of 18 is rounded up to a receipt of 20, and that receipt must be released two weeks earlier.]) <fig:mrp-record>

#strong[Lead time] is the elapsed time between initiating supply and having the material usable. If a component is needed in Week 5 with a two-week lead time, the order must be released in Week 3. MRP therefore answers both #emph[how much] and #emph[when].


#heading(level: 2)[Lot sizing changes the quantity]


Suppliers sell in fixed packs, pallets, minimum quantities, or economic batches. A net requirement of 28 tyres bought in boxes of 10 becomes a purchase of 30. The ordered quantity is a step function of the requirement, not a copy of it.

#callout("workedexample", title: [Worked example])[West End Bicycles plans 20 Road Bikes. The BOM needs 1 Aluminium Frame and 2 Rubber Tires per bike. On hand: 7 frames, 12 tyres. Ignoring safety stock and scheduled receipts, $ upright("Frames net") = 20 - 7 = 13 \, #h(2em) upright("Tyres net") = 40 - 12 = 28 . $ If tyres come in boxes of 10, the procurement quantity is 30 even though the net requirement is 28. The extra 2 become next period's opening stock.]


#heading(level: 2)[Purchasing and receiving are separate business events]


A purchase order records a commitment to buy. A receipt records what physically arrived. They can differ in date and in quantity, and only one of them creates usable stock.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/084350be53e66d98.svg")], caption: [The two events and what each proves. The gap between them is where supplier performance is measured --- and where a planner who treats an open order as available inventory releases production that cannot start.]) <fig:po-vs-receipt>


#heading(level: 2)[Supplier integration]


Sharing realistic forecasts and status data helps suppliers prepare capacity and materials; in return the buyer gains visibility of lead time and availability. This does not mean giving every supplier unrestricted ERP access --- it means designing controlled exchange so both sides plan around the same signals.


#heading(level: 2)[SCM measures of success]


#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Metric], [Meaning],),
    table.hline(),
    [Cash-to-cash cycle time], [Time between paying for inputs and collecting cash from the customer. Shorter cycles tie up less working capital.],
    [Total SCM cost], [Cost of buying and handling inventory, processing orders, and supporting the supply chain's information systems.],
    [Initial fill rate], [Percentage of an order supplied in the first shipment.],
    [Initial order lead time], [Time the supplier needs to fill the order.],
    [On-time performance], [How often the supplier meets the agreed delivery date.],
  )]
  , kind: table
  )

The cash-to-cash cycle is the one worth drawing, because it is the metric that connects supply-chain decisions to the finance chapter.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/54752d3b1a3c4a0d.svg")], caption: [Cash leaves when the supplier is paid and returns when the customer pays. The gap is financed by the company. Shortening inventory days or collection days shrinks it; paying suppliers later shrinks it too, but at the cost of the supplier relationship.]) <fig:cash-to-cash>

Metrics must be read together. A supplier can post high on-time performance and a poor fill rate by delivering punctually but short every time.


#heading(level: 2)[CRM versus SCM]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Aspect], [CRM], [SCM],),
    table.hline(),
    [Primary relationship], [Prospects and customers], [Suppliers, production, logistics partners],
    [Primary signal], [Customer interest and demand], [Material requirements and fulfilment],
    [Typical records], [Leads, opportunities, contacts, campaigns, service history], [Purchase orders, receipts, inventory, production plans, supplier performance],
    [Shared objective], table.cell(colspan: 2)[Deliver customer value efficiently by coordinating information rather than optimising one department in isolation.],
    [Where they meet], table.cell(colspan: 2)[Demand captured by CRM/Sales becomes a planning requirement for SCM; SCM status returns to Sales so customers receive accurate promises.],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/b78b74f560c0716f.svg")], caption: [The two halves of the enterprise face opposite directions and touch at exactly two points: the demand signal going upstream, and the availability answer coming back. Those two arrows are what integration buys.]) <fig:crm-vs-scm>


#heading(level: 2)[SCM in Odoo 19 Community]


#callout("applicationbox", title: [Application walkthrough])[The West End Bicycles guide uses this procure-and-receive sequence:

+ create vendors and raw-material products;

+ link each vendor to the material it supplies and the vendor price;

+ create one RFQ per vendor and assign the Purchasing Officer as Buyer;

+ confirm each RFQ into a Purchase Order;

+ open the linked Receipt and validate it;

+ verify that on-hand raw-material stock rises;

+ use those materials in the Road Bike manufacturing order;

+ validate the customer delivery, reducing finished-goods stock.]

#callout("pitfall", title: [Common mistake])[An open Purchase Order is not available inventory. A planner who treats ordered material as on hand releases production that cannot start (#ref(label("fig:po-vs-receipt"), supplement: [Figure])).]

#callout("tryit", title: [Try it yourself])[For the Road Bike BOM, take a production plan of 50 bikes with on-hand inventory of 12 frames, 70 tyres, 18 brake sets, 20 gear sets, and 15 chains. Calculate the net requirement for each component, then add one realistic lot-size rule and recalculate the purchase quantity.]

#callout("quickcheck", title: [Check your understanding])[+ What is the difference between gross and net material requirements?

+ Why must lead time appear in MRP rather than only the required quantity?

+ How do CRM and SCM interact in a customer-order process?]
