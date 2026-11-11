#import "/.shared/typst/utp.typ": *
#unit("labs", "05-sales-order-odoo")

#lab("5")[Sales Order Process: Order-to-Cash in Odoo] <sec:lab05>

#callout("labproject", title: [Complete the Road Bike order from quotation to payment])[#strong[Coverage.] Tutorial 5 + Chapters 3 and 8. \
#strong[Core system.] Odoo CRM, Sales, Inventory, and Invoicing. \
#strong[Goal.] Demonstrate a clean order-to-cash document flow and contrast it with the problems in Fitter Snacker's old process.


#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/05-flow.typ"


#callout("labmode", title: [How the practical connects to the concept])[Tutorial 5 focuses on the problems of an unintegrated sales process. This lab deliberately makes the same information move through linked Odoo records so you can point to what ERP integration changes.]

#strong[Part A --- Confirm the quotation.]

Open the quotation for Seri Iskandar Cycling Club with 5 Road Bikes at RM 1,000 each. Confirm it. The status becomes Sales Order and linked fulfilment/billing actions become available.


#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/05-trace.typ"


#strong[Follow the supplied implementation.] A posted invoice can exist before payment is settled. Use the state shown by the classroom database and explain In Payment versus Paid where applicable. Compare the quantities delivered and invoiced instead of assuming they must always match automatically. 
#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/05-worked-case.typ"


#strong[Part B --- Deliver the bikes.]

Open the Delivery smart button from the Sales Order. Check availability, confirm that 5 Road Bikes are reserved, and Validate the delivery. The delivery status becomes Done and Road Bike on-hand stock should fall by 5.

If Odoo cannot reserve the bikes, diagnose the upstream process: the Manufacturing Order may not be Done or finished stock may be insufficient.

#strong[Part C --- Create and post the invoice.]

Return to the Sales Order and choose Create Invoice. Create the regular invoice, review the Road Bike line, and post/confirm the invoice so it moves from Draft to Posted.

Observe that customer, product, quantity, and price were carried forward from Sales.

#strong[Part D --- Register payment.]

From the posted invoice, choose Register Payment. Use Bank or Cash, Manual method, full amount, and the current date. Create the payment. The invoice should become Paid or In Payment depending on configuration.

With Malaysia as the country, Odoo applies its default 10% sales tax to the Road Bike line, so the full amount is RM 5,500: the RM 5,000 order plus RM 500 tax. Revenue is still RM 5,000, because the tax is collected for the government.

#strong[Part E --- Compare old process versus ERP process.]

Use Tutorial 5 Question 1 to compare the salesperson experience: #figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Issue], [Old Fitter Snacker process], [Integrated Odoo process],),
    table.hline(),
    [Price and terms], [Handwritten/faxed quotation, possible arithmetic or discount errors], [Product/order lines preserve the commercial terms in the linked document flow],
    [Availability], [Warehouse estimate based on incomplete visibility], [Delivery reservation uses current stock state],
    [Fulfilment status], [Sales may need to call warehouse], [Sales Order links directly to Delivery status],
    [Invoice data], [Periodic transfer / re-entry to accounting], [Invoice created from the Sales Order],
    [Payment status], [Delayed visibility], [Payment status shown on linked invoice],
  )]
  , kind: table
  )

#strong[Part F --- Answer Tutorial 5 Questions 3 and 5.]

For the company-wide Delicious Foods analysis, describe the data consolidation and governance problems created by divisional systems. For the CIO memo activity, focus on the information-flow problem and explain how integrated order, fulfilment, invoice, and payment records change management visibility.]


#include "/ENTERPRISE RESOURCE PLANNING/labs/walkthroughs/05-records.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Trace order, delivery, invoice and payment references for one sale. Reconcile quantities and amounts, and explain any difference between delivery status and invoice payment status.

- The quotation is confirmed and its status is Sales Order.

- The delivery is Done and Road Bike on-hand stock fell by 5.

- The invoice was created from the Sales Order and is Posted, with customer, product, quantity and price carried forward.

- The invoice shows RM 5,000 untaxed, RM 500 tax and RM 5,500 total, or you can explain any different tax setting in your database.

- The invoice is Paid or In Payment after the payment is registered.]
