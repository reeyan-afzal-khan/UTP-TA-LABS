#import "/.shared/typst/utp.typ": *

#chapter-star[Course Map]

ERP becomes much easier once you stop treating each module as an isolated
topic. The course follows the same logic as a real business: understand the
organisation, capture demand, plan and obtain resources, fulfil the order,
record the financial consequences, and improve the process. Each stage
consumes what the previous one produced, which is also the order in which
information moves through a real company.

#utpfigure[
  #canvas({
    node((0, 0), [#coursemapcard([STAGE 01], [Foundations], [Business processes and ERP systems])], name: "a", ..card)
    node(right-of("a", 0.66), [#coursemapcard([STAGE 02], [Customer and sales], [CRM and the sales order process])], name: "b", ..card)
    node(right-of("b", 0.66), [#coursemapcard([STAGE 03], [Plan and supply], [Production, S&OP, and MRP])], name: "c", ..card)
    node(below-of("c", 0.58), [#coursemapcard([STAGE 04], [Finance and people], [Accounting, HR, and process change])], name: "d", ..card)
    node(left-of("d", 0.66), [#coursemapcard([STAGE 05], [Odoo practicals], [West End Bicycles, built end to end])], name: "e", ..finalcard)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
    connect("d", "e", ..arr)
  })
]

#utptable[
  #tabularx(
    columns: (8%, 31%, 1fr),
    align: (center, left, left),
    styles: (navy-bold,),
    header: ([Stage], [Focus], [Key question]),
    [1], [Business processes and ERP systems], [Why does a company need one shared record?],
    [2], [CRM and the sales order process], [How does a customer’s order become revenue?],
    [3], [Production, forecasting, and MRP], [How does demand become a plan, and the plan become purchases?],
    [4], [Accounting, HR, and process modelling], [How are financial and people consequences recorded and improved?],
    [5], [Integrated Odoo practicals], [Can one business story be traced through every module?],
  )
]

#heading(depth: 2, numbering: none)[What each stage covers]

#utptable[
  #tabularx(
    columns: (8%, 16%, 1fr),
    align: (center, center, left),
    styles: (navy-bold,),
    header: ([Stage], [Where], [Topics]),
    [1], [Chapters 1--2], [Functional areas, processes, silos, shared databases, ERP evolution, benefits, and challenges.],
    [2], [Chapters 3--4], [CRM, quotations, sales orders, availability, delivery, invoicing, and payment.],
    [3], [Chapters 5--7], [Production approaches, forecasting, S&OP, demand management, BOMs, MRP, purchasing, and inventory.],
    [4], [Chapters 8--10], [Accounting integration, HR processes, flowcharts, swimlanes, change management, and go-live.],
    [5], [Labs 1--8 and the capstone], [Build West End Bicycles in Odoo 19 Community and trace one story from setup through purchasing, manufacturing, CRM, sales, delivery, invoicing, and reporting.],
  )
]

#heading(depth: 2, numbering: none)[The question behind every chapter]

One business event --- a customer confirming an order --- has to reach four
different desks, each of which needs a different part of it.

#utpfig([The recurring pattern of the course. A single business event is written once and read four ways. Chapters 1--10 work through the areas clockwise; the labs rebuild the whole loop in Odoo.], label: <fig:one-event-four-readings>)[
  #canvas(scale: 0.98, transform-shape: true, {
    node((0, 0), [Shared \
  record], name: "db", ..procdb, min-width: 3.1, min-height: 1.5)
    node((-3.9, 1.55), [Marketing & Sales \ #v(-0.2em)
  #fsize("tiny")[#text(weight: "regular")[can we promise it?]]], name: "ms", ..procstep, min-width: 3)
    node((3.9, 1.55), [Supply Chain \ #v(-0.2em)
  #fsize("tiny")[#text(weight: "regular")[can we make it?]]], name: "scm", ..procstep, min-width: 3)
    node((3.9, -1.55), [Accounting & Finance \ #v(-0.2em)
  #fsize("tiny")[#text(weight: "regular")[what is owed?]]], name: "af", ..procstep, min-width: 3)
    node((-3.9, -1.55), [Human Resources \ #v(-0.2em)
  #fsize("tiny")[#text(weight: "regular")[who does the work?]]], name: "hr", ..procstep, min-width: 3)
    connect("ms", "db", ..procflow)
    connect("scm", "db", ..procflow)
    connect("db", "af", ..procflow)
    connect("hr", "db", ..procflow)
    node((0, 2.05), [Ch. 1--4], ..procchip)
    node((0, -2.05), [Ch. 8--9], ..procchip)
  })
]
