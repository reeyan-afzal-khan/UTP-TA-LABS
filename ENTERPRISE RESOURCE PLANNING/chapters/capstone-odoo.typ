#import "/.shared/typst/utp.typ": *
#unit("chapters", "capstone-odoo")


#heading(level: 1, numbering: none)[Capstone: West End Bicycles End-to-End ERP Story]


The supplied Odoo guide is designed as one connected storyline. The strongest final demonstration is therefore not eight isolated screenshots, but one narrative showing how information and stock move across the company.

#callout("sourcebasis", title: [Source basis])[This capstone follows the 21-step West End Bicycles Odoo 19 Community build guide supplied with Tutorial 1. It preserves the guide's company, roles, products, vendors, customer, Road Bike BOM, and RM 5,000 customer order.]


#heading(level: 2, numbering: none)[The two connected business cycles]


#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/f83eee897d908f0b.cetz.json")], caption: [The two connected business cycles of the capstone. The buying cycle fills the warehouse and the selling cycle empties it; manufacturing turns received materials into the finished bikes that are delivered and invoiced.]) <fig:capstone-two-cycles>

The buying cycle fills the warehouse; the selling cycle empties it. Manufacturing connects raw materials to finished goods. Finance closes the loop when money is received.


#heading(level: 2, numbering: none)[Capstone data set]


#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Master data], [Values used in the guide],),
    table.hline(),
    [Company], [West End Bicycles, Ipoh, Perak, Malaysia],
    [Finished product], [Road Bike, Goods, Track Inventory, selling price RM 1,000],
    [Road Bike BOM], [1 Aluminium Frame, 2 Rubber Tires, 1 Brake Set, 1 Gear Set, 1 Bicycle Chain],
    [Customer], [Seri Iskandar Cycling Club],
    [Customer order], [5 Road Bikes, expected and untaxed order value RM 5,000; RM 5,500 invoiced and paid with the default 10% tax],
    [Key operational roles], [Sales Manager, Purchasing Officer, Production Planner, Accountant],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[The 21-step build roadmap]


+ Create or access the Odoo database.

+ Install the eight required apps.

+ Set up West End Bicycles company profile.

+ Create departments, employees, managers, and selected operational users.

+ Create finished products.

+ Create raw-material products.

+ Create suppliers/vendors.

+ Link vendors to the raw materials they supply.

+ Create RFQs and confirm Purchase Orders.

+ Validate receipts so raw-material stock increases.

+ Create the Road Bike BOM.

+ Complete a Manufacturing Order for 5 Road Bikes.

+ Create Seri Iskandar Cycling Club as customer.

+ Create the CRM opportunity.

+ Move the opportunity through the pipeline.

+ Create and confirm the quotation/Sales Order for 5 Road Bikes.

+ Validate the Delivery so finished-bike stock decreases.

+ Create and post the customer invoice.

+ Register the customer payment.

+ Create/describe the cross-functional customer-order team.

+ Explain the information flow and show management reporting.


#heading(level: 2, numbering: none)[What should happen to stock]


The physical logic is simple enough to use as a diagnostic tool.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Event], [Raw-material stock], [Road Bike stock],),
    table.hline(),
    [Validate vendor receipts], [Increases], [No change],
    [Complete MO for 5 bikes], [Decreases according to BOM], [Increases by 5],
    [Validate customer delivery], [No change], [Decreases by 5],
  )]
  , kind: table
  )

If the stock movement does not follow this pattern, trace the document states upstream. A Purchase Order that was never received cannot supply Manufacturing; an MO that is not Done cannot create finished stock; a Sales Order cannot deliver bikes that do not exist on hand.


#heading(level: 2, numbering: none)[Who owns what]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Role], [Odoo ownership field], [Business meaning],),
    table.hline(),
    [Sales Manager], [Salesperson / Team Leader], [Owns customer opportunity and commercial order],
    [Purchasing Officer], [Buyer], [Owns vendor sourcing and purchase documents],
    [Production Planner], [Responsible], [Owns the Manufacturing Order],
    [Accountant], [Finance/payment activity], [Owns or supports invoicing and payment recording],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[The information-flow narrative]


A polished demonstration can use this sequence:

+ #strong[Customer demand enters CRM.] The opportunity records who wants what and the expected value.

+ #strong[Sales formalises the deal.] The quotation records product, quantity, customer, price, and salesperson.

+ #strong[Sales Order creates operational demand.] Inventory can now see the fulfilment requirement.

+ #strong[Inventory confirms physical movement.] Delivery status proves whether goods actually left the warehouse.

+ #strong[Finance reuses the sales data.] The invoice is generated from the order rather than typed from scratch.

+ #strong[Payment closes the loop.] Sales and management can see settlement status.

+ #strong[Reports aggregate the history.] Graph, list, and pivot views turn transaction records into management information.

#callout("keyidea", title: [Key idea])[The capstone is successful when you can explain #emph[why] each record exists, what event changes its state, what downstream record it enables, and which department needs the resulting information. A sequence of screenshots without that explanation is not yet an ERP demonstration.]


#heading(level: 2, numbering: none)[Recommended final screenshots]


The supplied guide recommends evidence across the entire process. A compact final set is:

+ installed apps and company profile;

+ departments/employees/users;

+ Road Bike product with Goods + Track Inventory;

+ raw material with linked vendor;

+ confirmed Purchase Order;

+ Done Receipt;

+ Road Bike BOM;

+ Done Manufacturing Order;

+ CRM opportunity;

+ confirmed Sales Order;

+ Done Delivery;

+ Posted invoice;

+ Paid/In Payment invoice;

+ one Graph or Pivot report.

#callout("quickcheck", title: [Check your understanding])[+ If Road Bike stock remains zero after the MO, which upstream records should you inspect?

+ If the invoice price is different from the Sales Order, what ERP integration principle has failed?

+ Which capstone steps demonstrate the link between CRM, SCM, and Finance?]
