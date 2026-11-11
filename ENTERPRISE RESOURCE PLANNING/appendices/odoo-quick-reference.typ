#import "/.shared/typst/utp.typ": *
#unit("appendices", "odoo-quick-reference")


#heading(level: 1, numbering: none)[Appendix A: Odoo 19 Community Quick Reference]


This appendix condenses the terminology and troubleshooting rules in the supplied West End Bicycles guide.


#heading(level: 2, numbering: none)[Navigation and record behaviour]


#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Term], [Meaning],),
    table.hline(),
    [App grid], [Main launcher for Sales, Purchase, Inventory, Manufacturing, CRM, Employees, and other installed apps.],
    [Breadcrumb], [Clickable trail showing the current app/record path; use it to return to earlier records.],
    [Smart button], [Button above a record that jumps to related records such as Receipt, Delivery, or Invoices.],
    [New], [Starts a new record. Existing records are already editable in the Odoo 19 workflow described by the guide.],
    [Cloud/save indicator], [Appears when changes are unsaved; navigating away also auto-saves in the guide's workflow.],
    [Graph / Pivot], [Reporting views that summarise transaction data for analysis.],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Important Odoo 19 product rule]


The supplied guide states that older "Storable Product" terminology should be translated to:

#block[
#strong[Product Type = Goods] + #strong[Track Inventory = enabled]

]
If Track Inventory is not enabled, Odoo will not maintain the stock count expected by the course workflow.


#heading(level: 2, numbering: none)[Core transaction vocabulary]


#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Term], [Course meaning],),
    table.hline(),
    [RFQ], [Draft purchasing document before supplier commitment.],
    [Purchase Order], [Confirmed order to a vendor; creates/links a Receipt.],
    [Receipt], [Inventory transfer bringing purchased goods into stock.],
    [BOM], [Component recipe for one finished product.],
    [Manufacturing Order], [Instruction to produce a quantity; consumes components and produces finished stock.],
    [Opportunity], [Potential sale in CRM.],
    [Quotation], [Draft commercial offer to a customer.],
    [Sales Order], [Confirmed customer order; links to fulfilment and billing.],
    [Delivery], [Inventory transfer sending goods to the customer.],
    [Invoice], [Customer billing document; Draft before posting, then Posted, then Paid/In Payment after settlement.],
    [On Hand], [Quantity physically recorded in stock at the current moment.],
    [Validate], [Complete an inventory transfer and update stock.],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Troubleshooting by process state]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Problem], [Likely cause], [What to check],),
    table.hline(),
    [No Track Inventory option / stock not moving], [Product setup or Inventory app issue], [Confirm Inventory is installed, Product Type is Goods, and Track Inventory is enabled.],
    [No New Quotation from CRM], [Opportunity/customer/app state incomplete], [Save opportunity, set customer, confirm Sales is installed; otherwise create quotation from Sales.],
    [Vendor does not appear on product purchasing], [Vendor record exists but is not linked to product], [Product Purchase tab, vendor line, price, and Can be Purchased.],
    [Cannot receive goods], [RFQ not yet confirmed], [Confirm RFQ into Purchase Order, then open Receipt.],
    [Cannot manufacture], [Components are not actually on hand], [Validate supplier receipts and check component On Hand.],
    [Cannot deliver], [Finished product is unavailable], [Complete Manufacturing Order and verify Road Bike On Hand.],
    [Cannot register payment], [Invoice still Draft], [Post/confirm the invoice before Register Payment.],
    [Expected button missing], [Record is in the wrong lifecycle state], [Check whether the prior business event is Draft, Confirmed/Posted, or Done.],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[When troubleshooting, follow the process backwards. A downstream action is usually unavailable because an upstream business event has not been confirmed or completed.]
