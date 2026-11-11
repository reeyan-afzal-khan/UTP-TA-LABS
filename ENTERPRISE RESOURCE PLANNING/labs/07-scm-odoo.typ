#import "/.shared/typst/utp.typ": *
#unit("labs", "07-scm-odoo")

#lab("7")[Supply Chain Management: Procure, Receive, and Measure] <sec:lab07>

#callout("labproject", title: [Build the upstream supply chain for Road Bikes and connect it to SCM performance])[#strong[Coverage.] Tutorial 7 + Chapter 7. \
#strong[Core system.] Odoo Purchase + Inventory + Manufacturing. \
#strong[Goal.] Demonstrate supplier master data, purchase orders, receipts, inventory availability, and the link between supplier performance and production readiness.


#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/07-flow.typ"


#callout("labmode", title: [How the practical connects to the concept])[Tutorial 7 asks students to research an SCM implementation and compare CRM with SCM. The Odoo work gives a concrete supply-chain process you can analyse using metrics such as lead time, fill rate, and on-time performance.]

#strong[Part A --- Create vendors and vendor-product links.]

Create the supplied vendors and link them to raw materials on the product Purchase tab:

- Ipoh Metal Supply $arrow.r$ Aluminium Frame;

- RubberWheel Co. $arrow.r$ Rubber Tires;

- BikeParts Supplier $arrow.r$ Brake Set, Gear Set, Bicycle Chain;

- CarbonTech Components $arrow.r$ Carbon Fiber Frame if used in your extended catalogue.

Set vendor prices from the guide and record a delivery lead time if the field is present.


#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/07-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:scm"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Use the supplier mapping in the walkthrough rather than replacing all vendors with one contact. A receipt updates stock; a supplier bill records the financial obligation. Explain each mismatch before closing the procurement task. 
#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/07-worked-case.typ"


#strong[Part B --- Raise RFQs and confirm Purchase Orders.]

Use one RFQ per vendor. Assign the Purchasing Officer as Buyer. Use the guide's example quantities or quantities approved by the tutor. Confirm each RFQ so the document becomes a Purchase Order and a Receipt smart button appears.

#strong[Part C --- Receive materials.]

Open the linked Receipt, check quantities, and Validate. Repeat for each supplier. Verify on-hand stock for one component before and after validation.

#strong[Part D --- Explain why receipt is not the same as order.]

Record one sentence for each:

- what the Purchase Order proves;

- what the Receipt proves;

- which event makes components usable by Manufacturing;

- which event should supplier on-time/fill-rate analysis compare against.

#strong[Part E --- Build a supplier scorecard concept.]

For each supplier, define:

- initial fill rate;

- order lead time;

- on-time performance;

- one quality-related measure of your own.

You do not need a large history in the demo database. The purpose is to define how repeated Odoo Purchase/Receipt transactions could generate the metric over time.

#strong[Part F --- Complete Tutorial 7 research.]

Group 1: research a manufacturing company that successfully implemented SCM, whether ERP existed before SCM, the challenges, and how success was measured. \
Group 2: compare CRM and SCM, including similarities, differences, interaction points, and technologies.

Use the SCM metrics from Chapter 7 to strengthen the Group 1 analysis and the demand-to-fulfilment hand-off to strengthen the Group 2 comparison.]

#strong[Chapter connection.] Revisit #link(label("ch:scm"))[the chapter explanation] and map its states to the steps below. 
#include "/ENTERPRISE RESOURCE PLANNING/labs/visuals/07-scm-odoo-chapter.typ"



#include "/ENTERPRISE RESOURCE PLANNING/labs/walkthroughs/07-records.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Trace a partial receipt and its remaining quantity. Compare ordered, received and billed quantities and explain any difference without silently forcing them to agree.

- Each vendor is linked to the products it supplies.

- One RFQ per vendor is confirmed into a Purchase Order, with the Purchasing Officer as Buyer.

- Each Receipt is validated, and one component's on-hand stock is recorded before and after.

- You can explain why the receipt, not the order, is the event to measure supplier performance against.]
