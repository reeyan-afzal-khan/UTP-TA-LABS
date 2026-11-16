#import "/.shared/typst/utp.typ": *
#unit("chapters", "capstone-odoo")

#chapter-star[Capstone: West End Bicycles End-to-End ERP Story]

The supplied Odoo guide is designed as one connected storyline. The strongest final demonstration is therefore not eight isolated screenshots, but one narrative showing how information and stock move across the company.

#note[
  This capstone follows the 21-step West End Bicycles Odoo 19 Community build guide supplied with Tutorial 1. It preserves the guide’s company, roles, products, vendors, customer, Road Bike BOM, and RM 5,000 customer order.
]

#heading(depth: 2, numbering: none)[The two connected business cycles]

#utpfig([The two connected business cycles of the capstone. The buying cycle fills the warehouse and the selling cycle empties it; manufacturing turns received materials into the finished bikes that are delivered and invoiced.], label: <fig:capstone-two-cycles>)[
  #canvas({
    let b = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.3, min-height: 0.75, align: center, font: font("script", weight: "bold", fill: navy))
    let g = (draw: green, fill: pale-teal, rounded: 2mm, min-width: 2.3, min-height: 0.75, align: center, font: font("script", weight: "bold", fill: navy))
    let m = (draw: orange, fill: pale-orange, rounded: 2mm, min-width: 3, min-height: 0.88, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 2.4), [Need materials], name: "need", ..b)
    node((3, 2.4), [Purchase Order], name: "po", ..b)
    node((6, 2.4), [Receipt], name: "rec", ..b)
    node((9.2, 2.4), [Inventory + Manufacturing], name: "make", ..m)
    node((0, 0), [Opportunity], name: "opp", ..g)
    node((3, 0), [Quotation / SO], name: "quote", ..g)
    node((6, 0), [Delivery], name: "del", ..g)
    node((9.2, 0), [Invoice / Payment], name: "pay", ..g)
    connect("need", "po", ..arr)
    connect("po", "rec", ..arr)
    connect("rec", "make", ..arr)
    connect("opp", "quote", ..arr)
    connect("quote", "del", ..arr)
    connect("del", "pay", ..arr)
    connect("make.south", "pay.north-west", ..arr)
    node(along("make.south", "pay.north-west", t: 50%), [finished bikes available], font: font("tiny", fill: muted), anchor: "west")
  })
]

The buying cycle fills the warehouse; the selling cycle empties it. Manufacturing connects raw materials to finished goods. Finance closes the loop when money is received.

#heading(depth: 2, numbering: none)[Capstone data set]

#utptable[
  #tabularx(
    columns: (24%, 1fr),
    styles: (navy-bold,),
    header: ([Master data], [Values used in the guide]),
    [Company], [West End Bicycles, Ipoh, Perak, Malaysia],
    [Finished product], [Road Bike, Goods, Track Inventory, selling price RM 1,000],
    [Road Bike BOM], [1 Aluminium Frame, 2 Rubber Tires, 1 Brake Set, 1 Gear Set, 1 Bicycle Chain],
    [Customer], [Seri Iskandar Cycling Club],
    [Customer order], [5 Road Bikes, expected and untaxed order value RM 5,000; RM 5,500 invoiced and paid with the default 10% tax],
    [Key operational roles], [Sales Manager, Purchasing Officer, Production Planner, Accountant],
  )
]

#heading(depth: 2, numbering: none)[The 21-step build roadmap]

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

#heading(depth: 2, numbering: none)[What should happen to stock]

The physical logic is simple enough to use as a diagnostic tool.

#utptable[
  #tabularx(
    columns: (28%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Event], [Raw-material stock], [Road Bike stock]),
    [Validate vendor receipts], [Increases], [No change],
    [Complete MO for 5 bikes], [Decreases according to BOM], [Increases by 5],
    [Validate customer delivery], [No change], [Decreases by 5],
  )
]

If the stock movement does not follow this pattern, trace the document states upstream. A Purchase Order that was never received cannot supply Manufacturing; an MO that is not Done cannot create finished stock; a Sales Order cannot deliver bikes that do not exist on hand.

#heading(depth: 2, numbering: none)[Who owns what]

#utptable[
  #tabularx(
    columns: (23%, 27%, 1fr),
    styles: (navy-bold,),
    header: ([Role], [Odoo ownership field], [Business meaning]),
    [Sales Manager], [Salesperson / Team Leader], [Owns customer opportunity and commercial order],
    [Purchasing Officer], [Buyer], [Owns vendor sourcing and purchase documents],
    [Production Planner], [Responsible], [Owns the Manufacturing Order],
    [Accountant], [Finance/payment activity], [Owns or supports invoicing and payment recording],
  )
]

#heading(depth: 2, numbering: none)[The information-flow narrative]

A polished demonstration can use this sequence:

+ #strong[Customer demand enters CRM.] The opportunity records who wants what and the expected value.
+ #strong[Sales formalises the deal.] The quotation records product, quantity, customer, price, and salesperson.
+ #strong[Sales Order creates operational demand.] Inventory can now see the fulfilment requirement.
+ #strong[Inventory confirms physical movement.] Delivery status proves whether goods actually left the warehouse.
+ #strong[Finance reuses the sales data.] The invoice is generated from the order rather than typed from scratch.
+ #strong[Payment closes the loop.] Sales and management can see settlement status.
+ #strong[Reports aggregate the history.] Graph, list, and pivot views turn transaction records into management information.

#note[
  The capstone is successful when you can explain #emph[why] each record exists, what event changes its state, what downstream record it enables, and which department needs the resulting information. A sequence of screenshots without that explanation is not yet an ERP demonstration.
]

#heading(depth: 2, numbering: none)[Recommended final screenshots]

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

#questions[
  + If Road Bike stock remains zero after the MO, which upstream records should you inspect?
  + If the invoice price is different from the Sales Order, what ERP integration principle has failed?
  + Which capstone steps demonstrate the link between CRM, SCM, and Finance?
]
