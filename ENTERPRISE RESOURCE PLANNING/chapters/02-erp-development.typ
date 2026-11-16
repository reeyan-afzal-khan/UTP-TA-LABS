#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-erp-development")

= The Development of ERP Systems: Architecture, Benefits, and Challenges <ch:erp-development>

#chapterguide[You should understand the idea of functional silos from Chapter 1.][explain how MRP evolved into ERP, describe ERP modularity and shared data, evaluate major benefits and implementation challenges, and identify conditions that make an ERP project more likely to succeed.]

#note[
  This chapter is based on Tutorial 2 and Chapter 2 of #emph[Concepts in Enterprise Resource Planning], with implementation ideas reinforced by Chapter 7.
  Tutorial 2 asks students to investigate one ERP benefit and one ERP challenge,
  support each with evidence, and teach the result to peers.
]

== Why ERP systems emerged

Business computing did not begin with an integrated platform. Early systems were
built to solve one department’s immediate problem: a manufacturing system
tracked materials, an accounting system recorded transactions, a sales system
captured orders. Each was useful alone while leaving the company as a whole hard
to coordinate.

The manufacturing lineage matters most. #term[Material Requirements Planning (MRP)] calculated what materials were needed and when. Later systems added
capacity, then extended past the factory into sales, purchasing, finance, HR,
and logistics.

#utpfig([Each generation kept the previous scope and added a question it could not previously answer. ERP is the point at which the question stops being about the factory and starts being about the company.], label: <fig:erp-evolution>)[
  #canvas({
    connect((-0.2, 0), (15.2, 0), draw: mix(muted, 45%), line-width: 0.6974pt)
    for x in (0.9, 4.6, 8.3, 12.9) {
      connect((x, -0.12), (x, 0.12), draw: mix(muted, 45%))
    }
    for (x, era) in ((0.9, "1960s"), (4.6, "1970s"), (8.3, "1980s"), (12.9, "1990s onward")) {
      node((x, 0), [#era], ..procnote, yshift: -1.5mm, anchor: "north")
    }
    node((0.9, 1.35), [#strong[Inventory control \ #v(-0.15em)
  #fsize("tiny")[What do we have \
  #fsize("tiny")[in the store?]]]], name: "a", ..procquiet, min-width: 3.1, min-height: 1.35, align: center)
    node((4.6, 1.35), [MRP \ #v(-0.15em)
  #fsize("tiny")[#text(weight: "regular")[Which materials, \
  #fsize("tiny")[#text(weight: "regular")[and by when?]]]]], name: "b", ..procstep, min-width: 3.1, min-height: 1.35)
    node((8.3, 1.35), [MRP II \ #v(-0.15em)
  #fsize("tiny")[#text(weight: "regular")[Materials #emph[and] \
  #fsize("tiny")[#text(weight: "regular")[capacity, cost, labour]]]]], name: "c", ..procstep, min-width: 3.1, min-height: 1.35, draw: teal, fill: pale-teal)
    node((12.9, 1.35), [ERP \ #v(-0.15em)
  #fsize("tiny")[#text(weight: "regular")[Company-wide processes \
  #fsize("tiny")[#text(weight: "regular")[on shared data]]]]], name: "d", ..procstep, min-width: 4.1, min-height: 1.35, draw: green, fill: pale-teal)
    connect("a", "b", ..procflow)
    connect("b", "c", ..procflow)
    connect("c", "d", ..procflow)
    node((-0.2, 3.05), [#strong[scope: one store room #h(1em)$arrow.r.long$#h(1em)one factory]], ..proccap, anchor: "west", text-width: 7, align: left)
    node((15.2, 3.05), [#strong[$arrow.r.long$#h(1em)one enterprise]], ..proccap, anchor: "east", text-width: 5, align: right)
    connect((-0.2, 2.6), (15.2, 2.6), draw: mix(blue, 35%), line-width: 1.9925pt, end: arrow-tip("Stealth", length: 3mm, line: 1.9925pt))
  })
]

== The core architectural idea: modules around shared data

ERP products are modular because businesses perform different kinds of work.
Sales needs quotations; manufacturing needs bills of materials; finance needs
invoices and payments. Modularity lets specialised workflows exist while still
drawing on the same underlying records.

#utpfig([The architecture in three layers. Users see specialised modules, but every module reads and writes the same master and transaction data underneath. Integration lives in the bottom layer, not in the screens.], label: <fig:erp-layers>)[
  #canvas({
    rectangle((0, 5.05), (14.6, 6.85), draw: mix(blue, 35%), fill: mix(pale-blue, 40%), rounded: 2.5mm)
    node((0.25, 6.52), [#strong[Users and roles]], ..proccap, anchor: "west", text: blue)
    for (x, r) in ((1.95, "Sales Manager"), (5.25, "Purchasing Officer"), (8.55, "Production Planner"), (11.85, "Accountant")) {
      node((x, 5.75), [#r], ..procdoc, min-width: 2.9, min-height: 0.72)
    }
    rectangle((0, 2.45), (14.6, 4.45), draw: mix(teal, 40%), fill: mix(pale-teal, 45%), rounded: 2.5mm)
    node((0.25, 4.12), [#strong[Modules --- specialised workflows]], ..proccap, anchor: "west", text: teal)
    for (x, m) in ((1.35, "CRM"), (3.35, "Sales"), (5.35, "Purchase"), (7.35, "Inventory"), (11.55, "Invoicing"), (13.5, "Employees")) {
      node((x, 3.15), [#m], ..procstep, min-width: 1.85, min-height: 0.9, draw: teal, fill: white)
    }
    node((9.45, 3.15), [Manu- \
  #fsize("script")[#strong[facturing]]], ..procstep, min-width: 1.85, min-height: 0.9, draw: teal, fill: white)
    rectangle((0, -0.35), (14.6, 1.55), draw: mix(navy, 45%), fill: mix(navy, 7%), rounded: 2.5mm)
    node((0.25, 1.26), [#strong[One database --- where the integration actually is]], ..proccap, anchor: "west", text: navy)
    node((3.75, 0.35), [#smallcaps[master data] \ #v(-0.15em)
  #fsize("tiny")[#text(weight: "regular")[customers, vendors, products, employees, prices]]], ..procstore, min-width: 6.5, min-height: 1.05)
    node((10.85, 0.35), [#smallcaps[transaction data] \ #v(-0.15em)
  #fsize("tiny")[#text(weight: "regular")[orders, receipts, MOs, deliveries, invoices]]], ..procstore, draw: green, fill: pale-teal, min-width: 6.5, min-height: 1.05)
    for x in (1.35, 3.35, 5.35, 7.35, 9.45, 11.55, 13.5) {
      connect((x, 2.45), (x, 1.55), ..proclink)
      connect((x, 4.45), (x, 5.05), ..proclink)
    }
  })
]

Two kinds of data are worth separating, because they behave differently and fail
differently.

#utpfig([Master data is written rarely and read constantly; transaction data is written constantly and refers back to the master records. One bad master record therefore contaminates every transaction that points at it. The payment is RM 5,500 because Odoo adds its default 10% tax for Malaysia to the RM 5,000 order.], label: <fig:master-vs-transaction>)[
  #canvas({
    node((0, 3.35), [Master data --- stable, reused], ..prochead, anchor: "west", text: blue)
    for (i, t) in ((0, [Customer: Seri Iskandar Cycling Club]), (1, [Product: Road Bike (Goods, tracked)]), (2, [Vendor: Ipoh Metal Supply]), (3, [Price: RM 1,000])) {
      let y = 2.55 - i * 0.78
      node((0, y), [#t], name: "m" + str(i), ..procdoc, anchor: "west", min-width: 5.5, text-width: 5.1, align: left, min-height: 0.62)
    }
    node((8.6, 3.35), [Transaction data --- one per event], ..prochead, anchor: "west", text: green)
    for (i, t) in ((0, [SO 001 --- 5 Road Bikes]), (1, [Delivery WH/OUT/001 --- Done]), (2, [Invoice INV/2024/001 --- Posted]), (3, [Payment --- RM 5,500 received])) {
      let y = 2.55 - i * 0.78
      node((8.6, y), [#t], name: "t" + str(i), ..procdoc, anchor: "west", min-width: 6, text-width: 5.6, align: left, min-height: 0.62, draw: green)
    }
    for i in range(0, 4) {
      connect("t" + str(i) + ".west", "m" + str(i) + ".east", ..proclink, end: arrow-tip("Stealth", length: 1.8mm, line: 0.4pt))
    }
    node((7.3, 3.35), [each transaction #emph[points at] a master record], ..procnote, anchor: "center", text-width: 3.1)
    node((0, -0.75), [change a price here $dots.h$], ..procchipwarn, anchor: "west")
    node((8.6, -0.75), [$dots.h$ and every later document follows], ..procchipwarn, anchor: "west")
  })
]

#note[
  ERP integration is not achieved by putting every task on one giant screen. It is
  achieved by letting specialised modules share master data and create linked
  transaction records from the same business events.
]

== Real time means one current version, not zero delay

In the textbook, #term[real time] means data is current rather than waiting for a
periodic transfer. A confirmed order reaches the functions that need it without
a clerk exporting a file or re-keying it.

This does not mean every metric updates instantly. The useful operational
meaning is that authorised users work from the same current records instead of
separately maintained departmental copies.

== Major benefits of ERP

The benefits described in the source all run through one of four mechanisms.
Naming the mechanism is what turns “ERP improves efficiency” into an argument.

#utpfig([Benefits are consequences, not features. Each chain runs from a structural change, through a change in what people actually do, to something that can be measured.], label: <fig:benefit-chain>)[
  #canvas({
    node((2.15, 3.05), [#strong[Mechanism]], ..proccap)
    node((7.3, 3.05), [#strong[What changes in the work]], ..proccap)
    node((12.7, 3.05), [#strong[What you can measure]], ..proccap)
    for (i, a, b, c) in ((0, "Data integration", "one record replaces departmental copies", "% invoices needing manual correction"), (1, "Process integration", "one transaction triggers the next step", "order-to-delivery cycle time"), (2, "Management visibility", "reports are read, not assembled", "days to close the books"), (3, "Standardisation", "units share processes and structures", "% transactions on the standard flow")) {
      let y = 2.35 - i * 0.9
      node((2.15, y), [#a], name: "a" + str(i), ..procstep, min-width: 4.3, min-height: 0.72)
      node((7.3, y), [#b], name: "b" + str(i), ..procdoc, min-width: 5.5, text-width: 5.1, min-height: 0.72)
      node((12.7, y), [#c], name: "c" + str(i), ..procgood, min-width: 4.8, text-width: 4.4, min-height: 0.72)
      connect("a" + str(i), "b" + str(i), ..procflow)
      connect("b" + str(i), "c" + str(i), ..procflow)
    }
  })
]

Better customer service, lower inventory, shorter cycle times, and stronger
control are downstream consequences of these four.

#example[
  Suppose West End Bicycles keeps the Road Bike price in a salesperson’s
  spreadsheet and again in Finance’s invoice system. A price change must be made
  twice and may be missed once. With one integrated product record, the quotation
  and the later invoice read the same price.
]

== Why ERP projects are difficult

ERP affects many departments at once, so implementation is an organisational
change project as much as a technology project. Licence and hardware costs are
the visible part; the costs that sink projects are mostly below the surface.

#utpfig([Software licences are the part budgeted first and the part that matters least to whether the project succeeds. Everything below the line is process and people work.], label: <fig:cost-iceberg>)[
  #canvas({
    rectangle((-0.4, 1.5), (14.8, 3.1), draw: mix(blue, 30%), fill: mix(pale-blue, 35%))
    node((-0.25, 2.82), [#strong[Budgeted first --- visible]], ..proccap, anchor: "west", text: blue)
    node((2, 2.05), [Software licences], ..procstep, min-width: 3.3, min-height: 0.8)
    node((5.9, 2.05), [Hardware / hosting], ..procstep, min-width: 3.3, min-height: 0.8)
    node((9.8, 2.05), [Consultants], ..procstep, min-width: 3.3, min-height: 0.8)
    node((13.2, 2.05), [Implementation], ..procstep, min-width: 2.9, min-height: 0.8)
    connect((-0.4, 1.35), (14.8, 1.35), draw: muted, line-width: 0.9963pt, dash: "dashed")
    node((14.7, 1.35), [waterline], ..procnote, anchor: "east", fill: white, inner-sep: 1.4944pt)
    rectangle((-0.4, -2.2), (14.8, 1.2), draw: mix(orange, 35%), fill: mix(pale-orange, 45%))
    node((-0.25, 0.92), [#strong[Discovered later --- where projects fail]], ..proccap, anchor: "west", text: orange)
    for (x, y, t) in ((2, 0.2, [Business process \
  redesign]), (5.9, 0.2, [Master-data cleaning \
  and migration]), (9.8, 0.2, [Training and \
  change management]), (13.2, 0.2, [Testing and \
  parallel running]), (2, -1.35, [Lost productivity \
  during transition]), (5.9, -1.35, [Process-owner \
  time]), (9.8, -1.35, [Customisation and \
  future upgrade debt]), (13.2, -1.35, [Post-go-live \
  support])) {
      node((x, y), [#t], ..procwarn, min-width: 3.3, min-height: 0.95)
    }
  })
]

Failed implementations are usually traced to process and people problems:
assuming software will repair a bad process, thin planning before configuration,
inadequate training, treating the work as IT-only, weak executive sponsorship,
poor change management, uncontrolled scope or customisation, and difficult
migration of legacy data.

#warning[
  “Install ERP” is not a business objective. A project needs a process objective
  --- reduce order cycle time, improve inventory accuracy, shorten the financial
  close --- or the organisation can spend heavily and reproduce its old problems
  inside newer software.
]

== Standard processes versus customisation

ERP packages embody a particular way of doing business. Every gap between the
package and the company forces a decision, and the cheapest answer is not always
the right one.

#utpfig([Work down the questions before writing code. Custom features are not forbidden, but each one is paid for again at every future upgrade.], label: <fig:customisation-decision>)[
  #canvas({
    node((1.6, 0), [Process gap found], name: "start", ..procterm, min-width: 3.1)
    node((5.5, 0), [Does standard \
  configuration cover it?], name: "d1", ..procdec, text-width: 2.4)
    node((10.2, 0), [Is it a real competitive or \
  legal need?], name: "d2", ..procdec, text-width: 2.5)
    node((5.5, -2.35), [Configure \
  #fsize("tiny")[#text(weight: "regular")[no code, upgrade-safe]]], name: "o1", ..procgood, min-width: 3, min-height: 0.9)
    node((10.2, 2.15), [Adopt the standard \
  #fsize("tiny")[#text(weight: "regular")[change the process]]], name: "o2", ..procgood, min-width: 3.2, min-height: 0.9)
    node((14, 0), [Customise \
  #fsize("tiny")[#text(weight: "regular")[log the upgrade cost]]], name: "o3", ..procwarn, min-width: 3.2, min-height: 0.9)
    connect("start", "d1", ..procflow)
    connect("d1", "d2", ..procflow)
    node(along("d1", "d2", t: 50%), [no], ..procnote, fill: white, inner-sep: 0.9963pt, anchor: "south")
    connect("d1", "o1", ..procflow)
    node(along("d1", "o1", t: 50%), [yes], ..procnote, fill: white, inner-sep: 0.9963pt, anchor: "west")
    connect("d2", "o2", ..procflow)
    node(along("d2", "o2", t: 50%), [no], ..procnote, fill: white, inner-sep: 0.9963pt, anchor: "west")
    connect("d2", "o3", ..procflow)
    node(along("d2", "o3", t: 50%), [yes], ..procnote, fill: white, inner-sep: 0.9963pt, anchor: "south")
    node((10.2, -1.6), [The useful test: does this process create advantage, or is it merely familiar?], ..procnote, text-width: 4.4, anchor: "north")
  })
]

== How to judge ERP success

A successful implementation is not one that merely goes live. It should move
measurable business outcomes: order-to-delivery cycle time, inventory accuracy
and stockout frequency, invoice and payment processing time, days to close,
forecast accuracy, share of transactions completed without re-entry, user
adoption, service levels, and realised cost or revenue change.

Some benefits resist cash valuation. Better visibility, consistent data, and
the capacity to support growth may still be strategically decisive.

#keepspace(325.2pt)

== Implementation success factors

#utptable[
  #tabularx(
    columns: (25%, 1fr),
    styles: (navy-bold,),
    header: ([Success factor], [Why it matters]),
    [Executive sponsorship], [Gives the project authority, resources, and cross-functional priority.],
    [Clear scope and objectives], [Prevents uncontrolled expansion and makes benefits measurable.],
    [Process ownership], [Puts decisions with people who understand the work, not only the technology.],
    [Training and communication], [Helps users understand both the system and the new process.],
    [Change management], [Addresses resistance, role changes, and new responsibilities.],
    [Data preparation], [Poor master data undermines even correctly configured software.],
    [Testing and staged readiness], [Finds problems before live transactions depend on the system.],
  )
]

== How Odoo illustrates ERP modularity

The West End Bicycles guide uses eight Odoo 19 Community applications. Each has
a distinct job; the records are connected.

#note[
  #strong[In Odoo 19 Community.] Read the Odoo app grid as a modular ERP architecture:

  - #utpapp[Contacts]: shared customer and vendor identities.
  - #utpapp[CRM] and #utpapp[Sales]: demand, opportunities, quotations, orders.
  - #utpapp[Purchase], #utpapp[Inventory], #utpapp[Manufacturing]: sourcing, stock, production.
  - #utpapp[Invoicing]: customer invoices and payments in the Community workflow.
  - #utpapp[Employees]: departments and the people behind the processes.

  The same product, customer, vendor, and order data is reused rather than rebuilt
  in each app.
]

#exercises[
  Choose one ERP benefit and one implementation challenge from this chapter. For
  each write: (1) the mechanism, (2) one operational example at West End Bicycles,
  and (3) one metric that would show whether it improved. This mirrors Tutorial 2
  while forcing the argument to be measurable.
]

#questions[
  + What is the difference between master data and transaction data? Give two Odoo examples of each.
  + Why is top-management support important in a cross-functional ERP implementation?
  + Why can copying an inefficient legacy process exactly into an ERP system reduce the expected benefit?
]
