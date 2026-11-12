#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-sales-order-process")

= Marketing Information Systems and the Sales Order Process <ch:sales-order>

#chapterguide[You should understand functional integration and the idea of shared transaction data.][describe an end-to-end sales order process, diagnose problems caused by disconnected systems, explain the order-to-cash sequence, and show how sales, inventory, and finance are linked.]

#sourcebasis[
  This chapter uses Tutorial 5 and Chapter 3 of #emph[Concepts in Enterprise Resource Planning]. The Fitter Snacker case is retained as the main example of
  an inefficient, unintegrated sales process; the Odoo sections map the same
  concepts onto the West End Bicycles practical.
]

== What the sales order process includes

The #term[sales order process] runs from a customer’s request through fulfilment
and payment. It is much broader than entering an order: quotation, order
capture, credit terms, availability checking, picking and delivery, invoicing,
payment, and sometimes returns.

Each step is owned by a different function and each produces information the
next step depends on.

#utpfig([The sales order process with the owner of each step and the record it creates. Reading down the third row shows why no single department can be held responsible for the customer’s experience.], label: <fig:order-to-cash-lanes>)[
  #canvas({
    let tight = (line-width: widths.semithick, draw: teal, end: tip("Stealth", length: 1.6mm, line: widths.semithick))
    node((1.05, 2.15), [#strong[Step]], ..proccap, anchor: "east", align: right)
    node((1.05, 1.12), [#strong[Owner]], ..proccap, anchor: "east", align: right)
    node((1.05, 0.12), [#strong[Creates]], ..proccap, anchor: "east", align: right)
    for (i, s, o, r, c) in ((0, "Quotation", "Sales", "offer, price", blue), (1, "Sales order", "Sales", "commitment", blue), (2, "Availability, credit", "Inventory, Finance", "reservation", teal), (3, "Pick, pack, deliver", "Inventory", "shipped qty", teal), (4, "Invoice", "Finance", "receivable", green), (5, "Payment", "Finance", "settlement", green)) {
      let x = 2.2 + i * 2.35
      node((x, 2.15), [#s], name: "s" + str(i), ..procstep, min-width: 2, min-height: 0.86, draw: c, fill: mix(c, 12%), text-width: 1.75)
      node((x, 1.12), [#o], name: "o" + str(i), ..procdoc, min-width: 2, min-height: 0.66, draw: mix(c, 60%), text-width: 1.75)
      node((x, 0.12), [#r], name: "r" + str(i), ..procchip, text-width: 1.6, align: center)
      connect((x, 1.72), (x, 1.45), ..proclink)
      connect((x, 0.79), (x, 0.42), ..proclink)
    }
    for i in range(0, 5) {
      let j = int(i + 1)
      connect("s" + str(i), "s" + str(j), ..tight)
    }
    connect("s5.north", "s0.north", out-angle: 105deg, in-angle: 75deg, ..procback, name: "curve-1")
    node((name: "curve-1", anchor: 50%), [payment status returns to Sales], ..procnote, anchor: "south")
  })
]

== Fitter Snacker: what goes wrong without integration

Fitter Snacker runs separate sales, warehouse, and accounting systems. Data
crosses between them by fax, paper report, and periodic file transfer. Every
recurring problem traces back to one structural fact: #strong[each department holds its own copy of the order, and the copies drift apart.]

#utpfig([The same three departments, two ways. On the left, each holds a copy and the copies disagree between transfers; on the right, one record serves all three.], label: <fig:fitter-snacker-silos>)[
  #canvas({
    node((2.6, 3.3), [Separate systems], ..prochead, text: red)
    node((2.6, 2.2), [Sales \
  #fsize("tiny")[#text(weight: "regular")[own order copy]]], name: "s1", ..procbad, min-width: 2.6, min-height: 0.95)
    node((2.6, 0.75), [Warehouse \
  #fsize("tiny")[#text(weight: "regular")[own stock copy]]], name: "s2", ..procbad, min-width: 2.6, min-height: 0.95)
    node((2.6, -0.7), [Accounting \
  #fsize("tiny")[#text(weight: "regular")[own invoice copy]]], name: "s3", ..procbad, min-width: 2.6, min-height: 0.95)
    connect("s1", "s2", ..procslow)
    node(along("s1", "s2", t: 50%), [fax, batch transfer \
   #emph[hours or days]], ..procnote, xshift: 1mm, text-width: 2.5, align: left, anchor: "west")
    connect("s2", "s3", ..procslow)
    node(along("s2", "s3", t: 50%), [re-keyed by hand \
   #emph[may not match]], ..procnote, xshift: 1mm, text-width: 2.5, align: left, anchor: "west")
    node((11.6, 3.3), [One shared record], ..prochead, text: green)
    node((11.6, 0.75), [Shared \
  #fsize("script")[#strong[transaction \
  #fsize("script")[#strong[data]]]]], name: "h", ..procstore, draw: blue, min-width: 2.6, min-height: 1.35)
    node((8.4, 2.2), [Sales], name: "g1", ..procgood, min-width: 2.3, min-height: 0.75)
    node((8.4, -0.7), [Warehouse], name: "g2", ..procgood, min-width: 2.3, min-height: 0.75)
    node((14.7, 0.75), [Accounting], name: "g3", ..procgood, min-width: 2.3, min-height: 0.75)
    connect("g1", "h", ..procflow)
    connect("g2", "h", ..procflow)
    connect("h", "g3", ..procflow)
    node((11.6, -1.35), [every function reads and writes the #emph[same] order], ..procnote, text-width: 4.6)
  })
]

Read the five textbook symptoms as one cause seen from five desks.

#utptable[
  #tabularx(
    columns: (20%, 1fr, 26%),
    styles: (navy-bold, none, (style: "italic")),
    header: ([Symptom], [What actually happens], [The stale copy]),
    [Quotation and pricing], [Arithmetic slips, discounts combined wrongly, terms the office has not seen; faxes misread into duplicate orders.], [price],
    [Availability and dates], [The clerk asks the warehouse for a ship date built on stock figures that are already out of date.], [stock],
    [Credit], [The customer is judged against a periodic printed report, so a recent payment is invisible --- good customers refused, over-exposed ones approved.], [receivables],
    [Order filling], [Paper picking lists travel in batches; stock moves nobody writes down never reach the records.], [inventory],
    [Invoicing], [Order data transfers to accounting on a schedule, so fulfilment changes after the transfer are billed wrongly.], [shipped quantity],
  )
]

The cost shows up as elapsed time. Most of an unintegrated order’s life is spent
waiting for a transfer, not being worked on.

#utpfig([The same order under both processes. The shaded blocks are work; the gaps are waiting for a batch, a fax, or a report. Integration removes the gaps rather than making anyone type faster.], label: <fig:fitter-timeline>)[
  #canvas({
    connect((0, -1.55), (14.6, -1.55), draw: mix(muted, 45%))
    for d in range(0, 8) {
      let x = d * 1.82
      connect((x, -1.62), (x, -1.48), draw: mix(muted, 45%))
      node((x, -1.55), [day #d], ..procnote, yshift: -1mm, anchor: "north")
    }
    node((0, 1.15), [#strong[Fitter Snacker (unintegrated)]], ..proccap, anchor: "west", text: red)
    for (a, b, t) in ((0, 1.1, "Quote"), (3.3, 4.4, "Order entered"), (6.6, 8.1, "Credit checked"), (9.6, 11, "Picked"), (12.4, 14.2, "Invoiced")) {
      rectangle((a, 0.05), (b, 0.75), draw: red, fill: pale-red, rounded: 1mm)
      node(((a + b) / 2, 0.4), [#t], ..procnote, anchor: "center")
    }
    for (a, b) in ((1.1, 3.3), (4.4, 6.6), (8.1, 9.6), (11, 12.4)) {
      connect((a, 0.4), (b, 0.4), draw: mix(red, 55%), dash: "dashed")
      node(((a + b) / 2, 0.4), [wait], ..procnote, yshift: 0.5mm, text: red, anchor: "south")
    }
    node((0, -0.05), [#strong[Integrated (one shared record)]], ..proccap, anchor: "west", text: green)
    for (a, b, t) in ((0, 1.1, "Quote"), (1.1, 2.1, "Order"), (2.1, 3.3, "Credit"), (3.3, 4.5, "Picked"), (4.5, 5.7, "Invoiced")) {
      rectangle((a, -1.15), (b, -0.45), draw: green, fill: pale-teal, rounded: 1mm)
      node(((a + b) / 2, -0.8), [#t], ..procnote, anchor: "center")
    }
    node((6.1, -0.8), [same work, no transfers to wait for], ..procchip, anchor: "west")
  })
]

#pitfall[
  None of this is careless staff; it is process design. A process that requires
  people to copy, fax, re-key, and reconcile the same fact across systems produces
  errors and delays no matter how conscientious they are. Fix the structure.
]

== What an integrated ERP changes

An integrated system replaces separate copies with a linked document flow. The
value is not that the documents exist --- Fitter Snacker had documents too ---
but that each one inherits its data from the one before it.

#utpfig([What each document carries forward. Nothing in the lower row is re-typed; it is inherited. The return arrow is the answer Sales can give a customer without telephoning another department.], label: <fig:document-lineage>)[
  #canvas({
    for (i, d, c) in ((0, "Quotation", blue), (1, "Sales Order", blue), (2, "Delivery", teal), (3, "Invoice", green), (4, "Payment", green)) {
      let x = i * 3.15
      node((x, 1.5), [#d], name: "d" + str(i), ..procstep, min-width: 2.75, min-height: 0.8, draw: c, fill: mix(c, 12%))
    }
    for i in range(0, 4) {
      let j = int(i + 1)
      connect("d" + str(i), "d" + str(j), ..procflow)
    }
    for (i, t) in ((0, [customer \
   product \
   quantity \
   unit price]), (1, [$+$ confirmed \
   commitment \
   $+$ salesperson]), (2, [$+$ what actually \
   left the \
   warehouse]), (3, [$+$ amount due \
   $+$ terms \
   $+$ tax]), (4, [$+$ cash received \
   $+$ settlement \
   date])) {
      let x = i * 3.15
      node((x, -0.35), [#t], name: "c" + str(i), ..procdoc, min-width: 2.75, text-width: 2.4, align: center, min-height: 1.5)
      connect((x, 1.1), (x, 0.42), ..proclink)
    }
    node((6.3, -1.55), [#strong[what each document carries forward]], ..proccap, text: green)
    connect("d4.north", "d1.north", out-angle: 120deg, in-angle: 60deg, ..procback, name: "curve-1")
    node((name: "curve-1", anchor: 50%), [“has the customer paid?” answered without leaving Sales], ..procnote, anchor: "south")
  })
]

A strong sales-order system therefore validates master data at entry, applies
configured pricing, checks availability and credit, creates fulfilment documents
from the order, passes billing data to Finance, and records status changes so
Sales can answer customer questions.

== Order-to-cash as a cross-functional cycle

#term[Order-to-cash] emphasises that the process is not complete when the sales
order is confirmed. The business has not achieved what it wanted until the
product is fulfilled and the money is collected.

#utptable[
  #tabularx(
    columns: (19%, 24%, 1fr),
    styles: (navy-bold,),
    header: ([Stage], [Primary owner], [Information created or consumed]),
    [Opportunity / quotation], [Sales / Marketing], [Customer need, product, quantity, expected price, proposed terms.],
    [Sales order], [Sales], [Confirmed demand and commercial commitment.],
    [Availability and delivery], [Inventory / Operations], [Stock reservation, picking, actual shipped quantity, delivery status.],
    [Invoice], [Finance], [Amount due, tax and payment terms, receivable record.],
    [Payment], [Finance], [Cash received and settlement status, visible back to Sales.],
  )
]

== Integration of Sales and Accounting

In an ERP system accounting consequences are created from operational events
rather than reconstructed later. Management reporting, customer balances, and
profitability analysis all depend on that same source transaction.

If a customer receives a discount, Sales and Finance need the same final price.
Re-entering the invoice manually creates an unnecessary opportunity to disagree.

#keyidea[
  A reliable sales process preserves document lineage: the quotation explains how
  the order was formed, the delivery explains what was physically fulfilled, the
  invoice explains what was billed, and the payment explains what was settled.
]

== Document states matter

Business records move through a lifecycle. A draft is editable; a confirmed or
posted record is a commitment; a done or paid state records completion of the
real-world event. Knowing which state a record is in explains almost every
“the button is missing” problem in the labs.

#utpfig([The three lifecycles used throughout the practicals. An action is available only when the record is in the state that permits it, which is why troubleshooting runs backwards.], label: <fig:document-states>)[
  #canvas({
    for (i, lbl, a, b, c, ta, tb) in ((0, "Sales document", "Quotation", "Sales Order", "Locked", "Confirm", "Fulfilled"), (1, "Delivery", "Draft", "Ready — reserved", "Done", "Check availability", "Validate"), (2, "Customer invoice", "Draft", "Posted", "Paid / In Payment", "Post", "Pay")) {
      let y = -i * 1.62
      node((-0.1, y), [#strong[#lbl]], ..proccap, anchor: "west", align: left, text-width: 2.2)
      node((3.7, y), [#a], name: "a" + str(i), ..procquiet, min-width: 3, min-height: 0.8)
      node((8.5, y), [#b], name: "b" + str(i), ..procstep, min-width: 3.2, min-height: 0.8)
      node((13.1, y), [#c], name: "c" + str(i), ..procgood, min-width: 3.2, min-height: 0.8)
      connect("a" + str(i), "b" + str(i), ..procflow)
      node(along("a" + str(i), "b" + str(i), t: 50%), [#ta], ..procnote, fill: white, inner-sep: 0.9963pt, anchor: "south")
      connect("b" + str(i), "c" + str(i), ..procflow)
      node(along("b" + str(i), "c" + str(i), t: 50%), [#tb], ..procnote, fill: white, inner-sep: 0.9963pt, anchor: "south")
    }
    node((2.6, 1.05), [#strong[editable]], ..proccap, anchor: "west", text: muted)
    node((7.4, 1.05), [#strong[committed]], ..proccap, anchor: "west", text: blue)
    node((12.1, 1.05), [#strong[complete]], ..proccap, anchor: "west", text: green)
  })
]

If a button is missing, the first diagnostic question is: #emph[is the preceding business event complete?]

== Company-wide sales analysis

Tutorial 5 asks how management could analyse the whole relationship with a
customer such as Delicious Foods when each sales division keeps its own data.
In a fragmented environment this requires collecting data from every division,
reconciling customer identities and product names, standardising terms, removing
duplicates, and combining the results --- and divisions may be reluctant to
share performance data at all.

#utpfig([Why fragmented data resists consolidation. The three divisions each hold a valid record; only controlled master data makes them the same customer.], label: <fig:customer-identity>)[
  #canvas({
    node((3.5, 2.6), [Divisional records], ..prochead, text: red)
    node((3.5, 1.65), [“Delicious Foods”], name: "x1", ..procbad, min-width: 3.6, min-height: 0.72)
    node((3.5, 0.7), [“Delicious Foods Co.”], name: "x2", ..procbad, min-width: 3.6, min-height: 0.72)
    node((3.5, -0.25), [“DELICIOUS FOODS CO”], name: "x3", ..procbad, min-width: 3.6, min-height: 0.72)
    node((8.4, 0.7), [Manual roll-up \
  #fsize("tiny")[#text(weight: "regular")[counts three customers]]], name: "agg", ..procwarn, min-width: 3.3, min-height: 1.05)
    for n in ("x1", "x2", "x3") {
      connect(n, "agg", ..procslow)
    }
    node((13.3, 0.7), [One controlled \
  #fsize("script")[#strong[customer identity]]], name: "gov", ..procstore, min-width: 3.7, min-height: 1.05, draw: green, fill: pale-teal)
    connect("agg", "gov", ..procflow)
    node(along("agg", "gov", t: 50%), [master-data governance], ..procnote, text-width: 1.9, anchor: "south")
    node((13.3, -0.7), [transactions reference the identity, so the roll-up is automatic], ..procnote, text-width: 4)
  })
]

ERP reduces the technical burden by storing comparable data centrally. It does
not remove organisational reluctance, but it makes a unified view possible where
governance and management expectations support one.

== How the sequence appears in Odoo 19 Community

#applicationbox[
  For the Road Bike example, the practical sequence is:

  + create a CRM opportunity for Seri Iskandar Cycling Club;
  + create a quotation for 5 Road Bikes at RM 1,000 each;
  + confirm the quotation so it becomes a Sales Order;
  + open the linked Delivery and validate shipment of 5 bikes;
  + return to the Sales Order and create a customer invoice;
  + post the invoice;
  + register the payment so the invoice becomes Paid or In Payment.

  The price is set in Sales and flows into the invoice rather than being typed
  again in Finance.
]

#tryit[
  Take the old Fitter Snacker process and label every point where information is
  copied, delayed, estimated, or re-entered. Map each problem to one ERP
  mechanism: shared master data, automatic document creation, real-time status,
  configured pricing, availability checking, or integrated accounting.
]

#quickcheck[
  + Why can a quotation error later become an invoicing problem?
  + What is the difference between a Sales Order and a Delivery in the process model?
  + Why is payment status useful to Sales even though Finance records the payment?
]
