#import "/.shared/typst/utp.typ": *


#heading(level: 1, numbering: none)[Course Map]


ERP becomes much easier once you stop treating each module as an isolated topic. The course follows the same logic as a real business: understand the organisation, capture demand, plan and obtain resources, fulfil the order, record the financial consequences, and improve the process. Each stage consumes what the previous one produced, which is also the order in which information moves through a real company.

#callout("utpfigure", title: [])[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/aca39af66f39ad1f.cetz.json")]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Focus], [Key question],),
    table.hline(),
    [1], [Business processes and ERP systems], [Why does a company need one shared record?],
    [2], [CRM and the sales order process], [How does a customer's order become revenue?],
    [3], [Production, forecasting, and MRP], [How does demand become a plan, and the plan become purchases?],
    [4], [Accounting, HR, and process modelling], [How are financial and people consequences recorded and improved?],
    [5], [Integrated Odoo practicals], [Can one business story be traced through every module?],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[What each stage covers]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Where], [Topics],),
    table.hline(),
    [1], [Chapters 1--2], [Functional areas, processes, silos, shared databases, ERP evolution, benefits, and challenges.],
    [2], [Chapters 3--4], [CRM, quotations, sales orders, availability, delivery, invoicing, and payment.],
    [3], [Chapters 5--7], [Production approaches, forecasting, S&OP, demand management, BOMs, MRP, purchasing, and inventory.],
    [4], [Chapters 8--10], [Accounting integration, HR processes, flowcharts, swimlanes, change management, and go-live.],
    [5], [Labs 1--8 and the capstone], [Build West End Bicycles in Odoo 19 Community and trace one story from setup through purchasing, manufacturing, CRM, sales, delivery, invoicing, and reporting.],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[The question behind every chapter]


One business event --- a customer confirming an order --- has to reach four different desks, each of which needs a different part of it.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/96aaf54ae3de1a9c.cetz.json")], caption: [The recurring pattern of the course. A single business event is written once and read four ways. Chapters 1--10 work through the areas clockwise; the labs rebuild the whole loop in Odoo.]) <fig:one-event-four-readings>
