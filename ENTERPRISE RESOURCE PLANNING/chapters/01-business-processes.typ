#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-business-processes")

= Business Functions, Business Processes, and ERP Integration <ch:business-processes>

#chapterguide[You only need a basic idea of what departments such as Sales, Finance, Supply Chain, and HR do.][distinguish a functional area from a business function and a business process, trace cross-functional information flows, and explain why a shared ERP database improves coordination.]

#sourcebasis[
  This chapter follows Tutorial 1 on Business Process / Business Functions and
  Chapter 1 of #emph[Concepts in Enterprise Resource Planning]. The West End
  Bicycles scenario and the four functional areas are preserved from the course
  materials; the explanations and diagrams reorganise those ideas into a study
  sequence.
]

== Start with the organisation, not the software

An ERP system exists to support how a business works. Before learning menus and
modules, identify the work the organisation actually performs.

A #term[functional area] is a broad part of the organisation responsible for a
family of activities. A #term[business function] is one activity inside such an
area --- “taking a sales order.” A #term[business process] is broader: a
connected set of activities that turns an input into an output someone values.
The three are often confused because they sit at different levels.

#utpfig([The three levels. Functional areas are vertical containers of responsibility; business functions are the individual activities inside them; a business process runs horizontally across the containers. The mismatch between the vertical structure and the horizontal flow is the problem ERP exists to solve.], label: <fig:area-function-process>)[
  #canvas({
    for (x, nm, c) in ((0, "Marketing & Sales", blue), (3.9, "Supply Chain", teal), (7.8, "Accounting & Finance", green), (11.7, "Human Resources", orange)) {
      rectangle((x, -0.15), (x + 3.45, 4.5), draw: mix(c, 55%), fill: mix(c, 7%), rounded: 2mm)
      node((x + 1.72, 4.12), [#nm], font: font("script", weight: "bold", fill: mix(c, 75%, other: black)), align: center, text-width: 3.2)
    }
    for (x, a, b, c) in ((0, "Quotation", "Sales order", "Forecast"), (3.9, "Purchasing", "Production", "Delivery"), (7.8, "Invoicing", "Receivables", "Reporting"), (11.7, "Recruiting", "Training", "Payroll admin.")) {
      node((x + 1.72, 3.42), [#a], ..procdoc, min-width: 2.9, min-height: 0.55)
      node((x + 1.72, 2.72), [#b], ..procdoc, min-width: 2.9, min-height: 0.55)
      node((x + 1.72, 2.02), [#c], ..procdoc, min-width: 2.9, min-height: 0.55)
    }
    node((-0.05, -0.75), [#strong[functional \
  areas]], ..proccap, anchor: "west", text-width: 2.6)
    node((2.9, -0.75), [each holds many #emph[business functions]], ..proccap, anchor: "west")
    rectangle((-0.35, 0.35), (15.5, 1.4), draw: navy, fill: mix(navy, 8%), rounded: 2mm)
    node((-0.15, 1.12), [Business process: #emph[order-to-cash]], font: font("script", weight: "bold", fill: navy), anchor: "west")
    for (x, t) in ((1.2, "Capture"), (4.3, "Reserve"), (7.3, "Ship"), (10.3, "Invoice"), (13.3, "Collect")) {
      node((x, 0.68), [#t], name: "c" + t, ..procchip)
    }
    connect("cCapture", "cReserve", ..procflow)
    connect("cReserve", "cShip", ..procflow)
    connect("cShip", "cInvoice", ..procflow)
    connect("cInvoice", "cCollect", ..procflow)
  })
]

#utptable[
  #tabularx(
    columns: (23%, 1fr),
    styles: (navy-bold,),
    header: ([Functional area], [Typical business functions]),
    [Marketing and Sales], [Product promotion, pricing, quotations, sales orders, customer support, CRM, and sales forecasting.],
    [Supply Chain Management], [Purchasing, receiving, inventory, production planning, manufacturing, logistics, and delivery.],
    [Accounting and Finance], [Recording transactions, receivables and payables, budgeting, cash management, financial reporting, and profitability analysis.],
    [Human Resources], [Recruiting, hiring, training, payroll-related administration, benefits, employee records, and compliance.],
  )
]

#intuition[
  A department is an organisational box. A process is a journey. The customer sees
  one experience; the company sees several departments.
]

== Why business processes cross functional boundaries

Suppose West End Bicycles receives an order for 1,000 bicycles. A sales employee
can capture the request, but Sales alone cannot complete it. Six questions must
be answered, and each belongs to a different desk.

#utpfig([One customer order, six questions, four owners. No single functional area can answer all of them, which is what makes this a cross-functional process rather than a departmental task.], label: <fig:cross-functional-order>)[
  #canvas({
    node((-0.2, 0.75), [Order for 1,000 bicycles --- who answers what?], ..prochead, anchor: "west")
    for (i, q, own, c) in ((0, [Is the order captured with the right product, quantity, and price?], "Marketing & Sales", blue), (1, [Is the customer allowed to buy on the requested credit terms?], "Accounting & Finance", green), (2, [Are 1,000 bicycles already in stock?], "Supply Chain", teal), (3, [If not, can production make them on time from available parts?], "Supply Chain", teal), (4, [When can the order be delivered?], "Supply Chain", teal), (5, [What is invoiced, and has the customer paid?], "Accounting & Finance", green)) {
      let y = -i * 0.92
      node((0, y), [#q], name: "q" + str(i), ..procdoc, anchor: "west", text-width: 8.5, min-width: 9, min-height: 0.74, align: left, draw: mix(c, 60%))
      node((9.6, y), [#own], ..procstep, anchor: "west", min-width: 3.7, min-height: 0.74, draw: c, fill: mix(c, 10%))
      connect((9.05, y), (9.6, y), ..proclink)
    }
    for i in range(0, 5) {
      let y = -i * 0.92 - 0.37
      connect((0.55, y), (0.55, y - 0.18), ..procflow)
    }
    connect((0, -5.05), (13.3, -5.05), draw: mix(muted, 35%))
    node((9.6, -5.55), [Human Resources], name: "hr", ..procstep, anchor: "west", min-width: 3.7, min-height: 0.74, draw: orange, fill: pale-orange)
    node((0, -5.55), [#emph[staffs every step above, owns none of them]], ..proccap, anchor: "west", text-width: 8.5, align: left)
    connect((9.05, -5.55), "hr", ..proclink)
  })
]

HR may not touch an individual order, yet it supports the process by ensuring
the company has trained salespeople, buyers, planners, accountants, and
warehouse staff.

== The information each area needs from the others

A process fails when information moves slowly or inconsistently, even if every
department works hard. Each area is simultaneously a producer and a consumer of
the others’ data.

#utpfig([What each functional area produces, and what it must receive from the others. Every labelled arrow is a dependency that a silo turns into a delay.], label: <fig:info-exchange>)[
  #canvas({
    node((0, 3.1), [Marketing & Sales \ #v(-0.2em)
  #fsize("tiny")[#text(weight: "regular")[produces orders, prices, demand]]], name: "ms", ..procstep, min-width: 3.6, min-height: 1.15)
    node((9.6, 3.1), [Supply Chain \ #v(-0.2em)
  #fsize("tiny")[#text(weight: "regular")[produces stock, output, shipments]]], name: "scm", ..procstep, min-width: 3.6, min-height: 1.15, draw: teal, fill: pale-teal)
    node((9.6, 0), [Accounting & Finance \ #v(-0.2em)
  #fsize("tiny")[#text(weight: "regular")[produces invoices, statements]]], name: "af", ..procstep, min-width: 3.6, min-height: 1.15, draw: green, fill: pale-teal)
    node((0, 0), [Human Resources \ #v(-0.2em)
  #fsize("tiny")[#text(weight: "regular")[produces staff, records, skills]]], name: "hr", ..procstep, min-width: 3.6, min-height: 1.15, draw: orange, fill: pale-orange)
    connect((rel: (0, 0.3), to: "ms.east"), (rel: (0, 0.3), to: "scm.west"), ..procflow)
    node(along((rel: (0, 0.3), to: "ms.east"), (rel: (0, 0.3), to: "scm.west"), t: 50%), [forecasts, confirmed orders], ..procnote, anchor: "south")
    connect((rel: (0, -0.3), to: "scm.west"), (rel: (0, -0.3), to: "ms.east"), ..procback)
    node(along((rel: (0, -0.3), to: "scm.west"), (rel: (0, -0.3), to: "ms.east"), t: 50%), [availability, promised dates], ..procnote, anchor: "north")
    connect("scm.south", "af.north", ..procflow)
    node(along("scm.south", "af.north", t: 50%), [receipts, production, shipments], ..procnote, text-width: 2.7, anchor: "west")
    connect((rel: (0, 0.3), to: "af.west"), (rel: (0, 0.3), to: "hr.east"), ..procback)
    node(along((rel: (0, 0.3), to: "af.west"), (rel: (0, 0.3), to: "hr.east"), t: 50%), [payroll and expense data], ..procnote, anchor: "south")
    connect("af.north-west", "ms.south-east", out-angle: 150deg, in-angle: -30deg, ..procflow, name: "curve-1")
    node((name: "curve-1", anchor: 50%), [credit status, payments], fill: white, inner-sep: 0.9963pt, ..procnote, text-width: 2.4, align: center)
    connect("hr.north", "ms.south", ..procflow)
    node(along("hr.north", "ms.south", t: 50%), [trained staff, skills], ..procnote, text-width: 2.2, anchor: "east")
    connect((rel: (0, -0.3), to: "hr.east"), (rel: (0, -0.3), to: "af.west"), ..procback)
    node(along((rel: (0, -0.3), to: "hr.east"), (rel: (0, -0.3), to: "af.west"), t: 50%), [headcount, staffing needs], ..procnote, anchor: "north")
  })
]

#keyidea[
  The quality of a decision is limited by the quality, timeliness, and consistency
  of the data available when the decision is made. ERP integration is valuable
  because it removes the delay and disagreement created by several disconnected
  copies of the same business fact.
]

== Silos versus an integrated information system

A #term[silo] is a departmental system that keeps its own data and does not
automatically stay synchronised with the others. Silos are not inherently bad.
The problem appears when a cross-functional process depends on a fact that now
exists in several different versions.

#utpfig([The same three departments, twice. On the left each holds its own copy and the copies drift apart between transfers; on the right one record serves all three, so there is nothing to reconcile.], label: <fig:silo-vs-erp>)[
  #resizebox(99%)[#canvas({
    node((3.6, 3.55), [Disconnected silos], ..prochead, text: red)
    node((0, 2.3), [Sales DB], name: "s1", ..procbad, min-width: 2.6)
    node((3.6, 2.3), [Warehouse DB], name: "s2", ..procbad, min-width: 2.6)
    node((7.2, 2.3), [Finance DB], name: "s3", ..procbad, min-width: 2.6)
    connect("s1", "s2", ..procslow)
    node(along("s1", "s2", t: 50%), [fax / batch], ..procnote, anchor: "south")
    connect("s2", "s3", ..procslow)
    node(along("s2", "s3", t: 50%), [re-keyed], ..procnote, anchor: "south")
    node((0, 0.85), [qty $=$ 40], name: "c1", ..procdoc, min-width: 2.4, min-height: 0.6, draw: red)
    node((3.6, 0.85), [qty $=$ 38], name: "c2", ..procdoc, min-width: 2.4, min-height: 0.6, draw: red)
    node((7.2, 0.85), [qty $=$ 40], name: "c3", ..procdoc, min-width: 2.4, min-height: 0.6, draw: red)
    for (a, b) in (("s1", "c1"), ("s2", "c2"), ("s3", "c3")) {
      connect(a, b, ..proclink)
    }
    node((3.6, 0.05), [three answers to one question], ..procchipbad)
    draw.scope({
      draw.translate((10.6, 0))
      node((3.1, 3.55), [Integrated ERP], ..prochead, text: teal)
      node((0, 2.3), [Sales], name: "i1", ..procgood, min-width: 2.6)
      node((3.1, 2.3), [Inventory], name: "i2", ..procgood, min-width: 2.6)
      node((6.2, 2.3), [Finance], name: "i3", ..procgood, min-width: 2.6)
      node((3.1, 0.7), [Shared record \
  qty $=$ 40], name: "db", ..procdb, min-width: 3, min-height: 1.2)
      for n in ("i1", "i2", "i3") {
        connect(n, "db", ..procflow)
      }
      node((3.1, -0.42), [one answer, read three ways], ..procchip)
    })
  })]
]

The structural cost of silos is easiest to see at the keyboard: the same fact
gets typed once per system, and each retype is an opportunity to disagree.

#utpfig([Where errors enter. Every manual hand-off is a chance for the copies to diverge; the integrated path has one entry point and no reconciliation step.], label: <fig:duplicate-entry>)[
  #resizebox(100%)[#canvas({
    node((-0.15, 1.5), [#strong[Siloed]], ..proccap, anchor: "east", text-width: 1.9)
    node((1.2, 1.5), [type], name: "a1", ..procbad, min-width: 2.1, min-height: 0.72)
    node((4.3, 1.5), [re-type], name: "a2", ..procbad, min-width: 2.1, min-height: 0.72)
    node((7.4, 1.5), [re-type], name: "a3", ..procbad, min-width: 2.1, min-height: 0.72)
    node((10.7, 1.5), [reconcile], name: "a4", ..procwarn, min-width: 2.4, min-height: 0.72)
    connect("a1", "a2", ..procslow)
    connect("a2", "a3", ..procslow)
    connect("a3", "a4", ..procslow)
    node((12.15, 1.5), [3 entries, 3 error points], ..procchipbad, anchor: "west")
    node((-0.15, 0), [#strong[Integrated]], ..proccap, anchor: "east", text-width: 1.9)
    node((1.2, 0), [type once], name: "b1", ..procgood, min-width: 2.1, min-height: 0.72)
    node((4.6, 0), [shared], name: "b2", ..procdb, min-width: 2.4, min-height: 0.9)
    node((7.9, 0), [read], name: "b3", ..procgood, min-width: 2.1, min-height: 0.72)
    node((10.7, 0), [read], name: "b4", ..procgood, min-width: 2.1, min-height: 0.72)
    connect("b1", "b2", ..procflow)
    connect("b2", "b3", ..procflow)
    connect("b3", "b4", ..procflow)
    node((12.2, 0), [1 entry, 0 error points], ..procchip, anchor: "west")
  })]
]

With a shared database one business event updates several views at once. When a
delivery is validated, Inventory sees stock leave, Sales sees fulfilment
progress, and Finance gains the evidence needed to bill.

== West End Bicycles as the running example

The tutorial scenario describes West End Bicycles as a manufacturer of road,
mountain, and city bicycles plus accessories. It is useful precisely because it
requires all four functional areas at once.

#utpfig([The whole course in one picture. The buying cycle fills the warehouse, the selling cycle empties it, and manufacturing is the hinge between them. Every later chapter deepens one segment of this loop.], label: <fig:two-cycles>)[
  #canvas({
    node((4.2, 2.35), [], draw: mix(blue, 35%), fill: mix(pale-blue, 45%), rounded: 2.5mm, min-width: 9.6, min-height: 1.8)
    node((-0.55, 3.05), [#strong[Procure-to-pay]], ..proccap, anchor: "west", text: blue)
    node((0.75, 2.25), [Need], name: "n1", ..procstep, min-width: 2.05)
    node((3.05, 2.25), [Purchase order], name: "n2", ..procstep, min-width: 2.05)
    node((5.35, 2.25), [Receipt], name: "n3", ..procstep, min-width: 2.05)
    node((7.85, 2.25), [Pay vendor], name: "n4", ..procstep, min-width: 2.05)
    connect("n1", "n2", ..procflow)
    connect("n2", "n3", ..procflow)
    connect("n3", "n4", ..procflow)
    node((12.1, 1.05), [Manufacturing \ #v(-0.15em)
  #fsize("tiny")[#text(weight: "regular")[components $arrow.r$ Road Bikes]]], name: "mfg", ..procwarn, min-width: 3.4, min-height: 1.05)
    node((4.2, -0.25), [], draw: mix(green, 35%), fill: mix(pale-teal, 55%), rounded: 2.5mm, min-width: 9.6, min-height: 1.8)
    node((-0.55, -1.15), [#strong[Order-to-cash]], ..proccap, anchor: "west", text: green)
    node((0.75, -0.35), [Opportunity], name: "m1", ..procgood, min-width: 2.05)
    node((3.05, -0.35), [Sales order], name: "m2", ..procgood, min-width: 2.05)
    node((5.35, -0.35), [Delivery], name: "m3", ..procgood, min-width: 2.05)
    node((7.85, -0.35), [Invoice / payment], name: "m4", ..procgood, min-width: 2.05)
    connect("m1", "m2", ..procflow)
    connect("m2", "m3", ..procflow)
    connect("m3", "m4", ..procflow)
    connect("n4", "mfg.north-west", bend: 16deg, ..procflow, name: "curve-1")
    node((name: "curve-1", anchor: 50%), [materials in], ..procnote, yshift: 0pt, xshift: 0.9963pt, anchor: "south-west")
    connect("mfg.south-west", "m4.north-east", bend: 16deg, ..procflow, name: "curve-2")
    node((name: "curve-2", anchor: 50%), [bikes out], ..procnote, yshift: 0pt, xshift: 0.9963pt, anchor: "north-west")
  })
]

== What Odoo adds to this picture

The supplied Odoo 19 Community guide implements the same concepts with eight
applications. Reading the app grid as an architecture rather than a menu is the
fastest way to see where each chapter lands.

#utpfig([The eight course applications grouped by the functional area each serves. Contacts sits underneath all of them because customer and vendor identity is shared master data.], label: <fig:odoo-app-map>)[
  #canvas({
    for (x, nm, c) in ((0, "Marketing & Sales", blue), (5, "Supply Chain", teal), (10, "Accounting & Finance", green)) {
      rectangle((x, 0.15), (x + 4.5, 2.75), draw: mix(c, 55%), fill: mix(c, 7%), rounded: 2mm)
      node((x + 2.25, 2.43), [#nm], font: font("script", weight: "bold", fill: mix(c, 75%, other: black)))
    }
    rectangle((10, -2.4), (14.5, -0.5), draw: mix(orange, 55%), fill: mix(orange, 7%), rounded: 2mm)
    node((12.25, -0.85), [Human Resources], font: font("script", weight: "bold", fill: mix(orange, 75%, other: black)))
    node((1.15, 1.65), [CRM], ..procstep, min-width: 1.85)
    node((3.35, 1.65), [Sales], ..procstep, min-width: 1.85)
    node((6.15, 1.65), [Purchase], ..procstep, min-width: 1.85, draw: teal, fill: pale-teal)
    node((8.35, 1.65), [Inventory], ..procstep, min-width: 1.85, draw: teal, fill: pale-teal)
    node((7.25, 0.72), [Manufacturing], ..procstep, min-width: 4, draw: teal, fill: pale-teal)
    node((12.25, 1.65), [Invoicing], ..procstep, min-width: 3.9, draw: green, fill: pale-teal)
    node((12.25, 0.75), [invoices and payments in the Community workflow], ..proccap, text-width: 3.9)
    node((12.25, -1.55), [Employees], ..procstep, min-width: 3.9, draw: orange, fill: pale-orange)
    node((4.6, -1.55), [Contacts --- shared customer and vendor identity], name: "ct", ..procstore, min-width: 8.4, min-height: 0.95)
    connect("ct", (1.15, 0.15), ..proclink)
    connect("ct", (7.25, 0.15), ..proclink)
    connect("ct", (10.6, 0.15), ..proclink)
  })
]

#applicationbox[
  Three ideas recur throughout the practicals:

  - Records are linked. A purchase order leads to a receipt; a sales order leads to a delivery and an invoice.
  - Documents move through states such as draft, confirmed/posted, and done/paid.
  - Smart buttons expose those relationships, making the information flow visible instead of requiring manual reconciliation.
]

#pitfall[
  Do not define ERP as “software that combines departments.” The point is
  process integration: one business event should be visible consistently to the
  functions that need it, when they need it.
]

#quickcheck[
  + Explain the difference between a functional area, a business function, and a business process using West End Bicycles.
  + Why can a weekly printed credit report cause a sales-order problem even if the Accounting data was correct when it was printed?
  + Name three pieces of information that must move between Sales and Supply Chain when fulfilling a bicycle order.
]
