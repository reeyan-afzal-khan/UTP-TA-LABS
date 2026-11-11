#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-business-processes")


#heading(level: 1)[Business Functions, Business Processes, and ERP Integration]
 <ch:business-processes>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You only need a basic idea of what departments such as Sales, Finance, Supply Chain, and HR do.

*By the end, you can:* distinguish a functional area from a business function and a business process, trace cross-functional information flows, and explain why a shared ERP database improves coordination.]

#callout("sourcebasis", title: [Source basis])[This chapter follows Tutorial 1 on Business Process / Business Functions and Chapter 1 of #emph[Concepts in Enterprise Resource Planning]. The West End Bicycles scenario and the four functional areas are preserved from the course materials; the explanations and diagrams reorganise those ideas into a study sequence.]


#heading(level: 2)[Start with the organisation, not the software]


An ERP system exists to support how a business works. Before learning menus and modules, identify the work the organisation actually performs.

A #strong[functional area] is a broad part of the organisation responsible for a family of activities. A #strong[business function] is one activity inside such an area --- "taking a sales order." A #strong[business process] is broader: a connected set of activities that turns an input into an output someone values. The three are often confused because they sit at different levels.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/654c6c0c8cf8ef62.cetz.json")], caption: [The three levels. Functional areas are vertical containers of responsibility; business functions are the individual activities inside them; a business process runs horizontally across the containers. The mismatch between the vertical structure and the horizontal flow is the problem ERP exists to solve.]) <fig:area-function-process>

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Functional area], [Typical business functions],),
    table.hline(),
    [Marketing and Sales], [Product promotion, pricing, quotations, sales orders, customer support, CRM, and sales forecasting.],
    [Supply Chain Management], [Purchasing, receiving, inventory, production planning, manufacturing, logistics, and delivery.],
    [Accounting and Finance], [Recording transactions, receivables and payables, budgeting, cash management, financial reporting, and profitability analysis.],
    [Human Resources], [Recruiting, hiring, training, payroll-related administration, benefits, employee records, and compliance.],
  )]
  , kind: table
  )

#callout("intuition", title: [Plain idea])[A department is an organisational box. A process is a journey. The customer sees one experience; the company sees several departments.]


#heading(level: 2)[Why business processes cross functional boundaries]


Suppose West End Bicycles receives an order for 1,000 bicycles. A sales employee can capture the request, but Sales alone cannot complete it. Six questions must be answered, and each belongs to a different desk.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/486ebc29a0461535.cetz.json")], caption: [One customer order, six questions, four owners. No single functional area can answer all of them, which is what makes this a cross-functional process rather than a departmental task.]) <fig:cross-functional-order>

HR may not touch an individual order, yet it supports the process by ensuring the company has trained salespeople, buyers, planners, accountants, and warehouse staff.


#heading(level: 2)[The information each area needs from the others]


A process fails when information moves slowly or inconsistently, even if every department works hard. Each area is simultaneously a producer and a consumer of the others' data.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/c35090dfeab1c4ad.cetz.json")], caption: [What each functional area produces, and what it must receive from the others. Every labelled arrow is a dependency that a silo turns into a delay.]) <fig:info-exchange>

#callout("keyidea", title: [Key idea])[The quality of a decision is limited by the quality, timeliness, and consistency of the data available when the decision is made. ERP integration is valuable because it removes the delay and disagreement created by several disconnected copies of the same business fact.]


#heading(level: 2)[Silos versus an integrated information system]


A #strong[silo] is a departmental system that keeps its own data and does not automatically stay synchronised with the others. Silos are not inherently bad. The problem appears when a cross-functional process depends on a fact that now exists in several different versions.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[], caption: [The same three departments, twice. On the left each holds its own copy and the copies drift apart between transfers; on the right one record serves all three, so there is nothing to reconcile.]) <fig:silo-vs-erp>

The structural cost of silos is easiest to see at the keyboard: the same fact gets typed once per system, and each retype is an opportunity to disagree.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[], caption: [Where errors enter. Every manual hand-off is a chance for the copies to diverge; the integrated path has one entry point and no reconciliation step.]) <fig:duplicate-entry>

With a shared database one business event updates several views at once. When a delivery is validated, Inventory sees stock leave, Sales sees fulfilment progress, and Finance gains the evidence needed to bill.


#heading(level: 2)[West End Bicycles as the running example]


The tutorial scenario describes West End Bicycles as a manufacturer of road, mountain, and city bicycles plus accessories. It is useful precisely because it requires all four functional areas at once.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/ae609b78fabb29b0.cetz.json")], caption: [The whole course in one picture. The buying cycle fills the warehouse, the selling cycle empties it, and manufacturing is the hinge between them. Every later chapter deepens one segment of this loop.]) <fig:two-cycles>


#heading(level: 2)[What Odoo adds to this picture]


The supplied Odoo 19 Community guide implements the same concepts with eight applications. Reading the app grid as an architecture rather than a menu is the fastest way to see where each chapter lands.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/d18a5eff32428335.cetz.json")], caption: [The eight course applications grouped by the functional area each serves. Contacts sits underneath all of them because customer and vendor identity is shared master data.]) <fig:odoo-app-map>

#callout("applicationbox", title: [Application walkthrough])[Three ideas recur throughout the practicals:

- Records are linked. A purchase order leads to a receipt; a sales order leads to a delivery and an invoice.

- Documents move through states such as draft, confirmed/posted, and done/paid.

- Smart buttons expose those relationships, making the information flow visible instead of requiring manual reconciliation.]

#callout("pitfall", title: [Common mistake])[Do not define ERP as "software that combines departments." The point is process integration: one business event should be visible consistently to the functions that need it, when they need it.]

#callout("quickcheck", title: [Check your understanding])[+ Explain the difference between a functional area, a business function, and a business process using West End Bicycles.

+ Why can a weekly printed credit report cause a sales-order problem even if the Accounting data was correct when it was printed?

+ Name three pieces of information that must move between Sales and Supply Chain when fulfilling a bicycle order.]
