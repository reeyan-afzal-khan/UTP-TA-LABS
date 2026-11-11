#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-sales-order-process")


#heading(level: 1)[Marketing Information Systems and the Sales Order Process]
 <ch:sales-order>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand functional integration and the idea of shared transaction data.

*By the end, you can:* describe an end-to-end sales order process, diagnose problems caused by disconnected systems, explain the order-to-cash sequence, and show how sales, inventory, and finance are linked.]

#callout("sourcebasis", title: [Source basis])[This chapter uses Tutorial 5 and Chapter 3 of #emph[Concepts in Enterprise Resource Planning]. The Fitter Snacker case is retained as the main example of an inefficient, unintegrated sales process; the Odoo sections map the same concepts onto the West End Bicycles practical.]


#heading(level: 2)[What the sales order process includes]


The #strong[sales order process] runs from a customer's request through fulfilment and payment. It is much broader than entering an order: quotation, order capture, credit terms, availability checking, picking and delivery, invoicing, payment, and sometimes returns.

Each step is owned by a different function and each produces information the next step depends on.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/0807d8300a2e9334.cetz.json")], caption: [The sales order process with the owner of each step and the record it creates. Reading down the third row shows why no single department can be held responsible for the customer's experience.]) <fig:order-to-cash-lanes>


#heading(level: 2)[Fitter Snacker: what goes wrong without integration]


Fitter Snacker runs separate sales, warehouse, and accounting systems. Data crosses between them by fax, paper report, and periodic file transfer. Every recurring problem traces back to one structural fact: #strong[each department holds its own copy of the order, and the copies drift apart.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/0ef3759111703209.cetz.json")], caption: [The same three departments, two ways. On the left, each holds a copy and the copies disagree between transfers; on the right, one record serves all three.]) <fig:fitter-snacker-silos>

Read the five textbook symptoms as one cause seen from five desks.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Symptom], [What actually happens], [The stale copy],),
    table.hline(),
    [Quotation and pricing], [Arithmetic slips, discounts combined wrongly, terms the office has not seen; faxes misread into duplicate orders.], [price],
    [Availability and dates], [The clerk asks the warehouse for a ship date built on stock figures that are already out of date.], [stock],
    [Credit], [The customer is judged against a periodic printed report, so a recent payment is invisible --- good customers refused, over-exposed ones approved.], [receivables],
    [Order filling], [Paper picking lists travel in batches; stock moves nobody writes down never reach the records.], [inventory],
    [Invoicing], [Order data transfers to accounting on a schedule, so fulfilment changes after the transfer are billed wrongly.], [shipped quantity],
  )]
  , kind: table
  )

The cost shows up as elapsed time. Most of an unintegrated order's life is spent waiting for a transfer, not being worked on.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/391bdfb26f4a00a5.cetz.json")], caption: [The same order under both processes. The shaded blocks are work; the gaps are waiting for a batch, a fax, or a report. Integration removes the gaps rather than making anyone type faster.]) <fig:fitter-timeline>

#callout("pitfall", title: [Common mistake])[None of this is careless staff; it is process design. A process that requires people to copy, fax, re-key, and reconcile the same fact across systems produces errors and delays no matter how conscientious they are. Fix the structure.]


#heading(level: 2)[What an integrated ERP changes]


An integrated system replaces separate copies with a linked document flow. The value is not that the documents exist --- Fitter Snacker had documents too --- but that each one inherits its data from the one before it.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/38eac2ebd22e0894.cetz.json")], caption: [What each document carries forward. Nothing in the lower row is re-typed; it is inherited. The return arrow is the answer Sales can give a customer without telephoning another department.]) <fig:document-lineage>

A strong sales-order system therefore validates master data at entry, applies configured pricing, checks availability and credit, creates fulfilment documents from the order, passes billing data to Finance, and records status changes so Sales can answer customer questions.


#heading(level: 2)[Order-to-cash as a cross-functional cycle]


#strong[Order-to-cash] emphasises that the process is not complete when the sales order is confirmed. The business has not achieved what it wanted until the product is fulfilled and the money is collected.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Primary owner], [Information created or consumed],),
    table.hline(),
    [Opportunity / quotation], [Sales / Marketing], [Customer need, product, quantity, expected price, proposed terms.],
    [Sales order], [Sales], [Confirmed demand and commercial commitment.],
    [Availability and delivery], [Inventory / Operations], [Stock reservation, picking, actual shipped quantity, delivery status.],
    [Invoice], [Finance], [Amount due, tax and payment terms, receivable record.],
    [Payment], [Finance], [Cash received and settlement status, visible back to Sales.],
  )]
  , kind: table
  )


#heading(level: 2)[Integration of Sales and Accounting]


In an ERP system accounting consequences are created from operational events rather than reconstructed later. Management reporting, customer balances, and profitability analysis all depend on that same source transaction.

If a customer receives a discount, Sales and Finance need the same final price. Re-entering the invoice manually creates an unnecessary opportunity to disagree.

#callout("keyidea", title: [Key idea])[A reliable sales process preserves document lineage: the quotation explains how the order was formed, the delivery explains what was physically fulfilled, the invoice explains what was billed, and the payment explains what was settled.]


#heading(level: 2)[Document states matter]


Business records move through a lifecycle. A draft is editable; a confirmed or posted record is a commitment; a done or paid state records completion of the real-world event. Knowing which state a record is in explains almost every "the button is missing" problem in the labs.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/480334a4e50dbaad.cetz.json")], caption: [The three lifecycles used throughout the practicals. An action is available only when the record is in the state that permits it, which is why troubleshooting runs backwards.]) <fig:document-states>

If a button is missing, the first diagnostic question is: #emph[is the preceding business event complete?]


#heading(level: 2)[Company-wide sales analysis]


Tutorial 5 asks how management could analyse the whole relationship with a customer such as Delicious Foods when each sales division keeps its own data. In a fragmented environment this requires collecting data from every division, reconciling customer identities and product names, standardising terms, removing duplicates, and combining the results --- and divisions may be reluctant to share performance data at all.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/da25917a61e04ab3.cetz.json")], caption: [Why fragmented data resists consolidation. The three divisions each hold a valid record; only controlled master data makes them the same customer.]) <fig:customer-identity>

ERP reduces the technical burden by storing comparable data centrally. It does not remove organisational reluctance, but it makes a unified view possible where governance and management expectations support one.


#heading(level: 2)[How the sequence appears in Odoo 19 Community]


#callout("applicationbox", title: [Application walkthrough])[For the Road Bike example, the practical sequence is:

+ create a CRM opportunity for Seri Iskandar Cycling Club;

+ create a quotation for 5 Road Bikes at RM 1,000 each;

+ confirm the quotation so it becomes a Sales Order;

+ open the linked Delivery and validate shipment of 5 bikes;

+ return to the Sales Order and create a customer invoice;

+ post the invoice;

+ register the payment so the invoice becomes Paid or In Payment.

The price is set in Sales and flows into the invoice rather than being typed again in Finance.]

#callout("tryit", title: [Try it yourself])[Take the old Fitter Snacker process and label every point where information is copied, delayed, estimated, or re-entered. Map each problem to one ERP mechanism: shared master data, automatic document creation, real-time status, configured pricing, availability checking, or integrated accounting.]

#callout("quickcheck", title: [Check your understanding])[+ Why can a quotation error later become an invoicing problem?

+ What is the difference between a Sales Order and a Delivery in the process model?

+ Why is payment status useful to Sales even though Finance records the payment?]
