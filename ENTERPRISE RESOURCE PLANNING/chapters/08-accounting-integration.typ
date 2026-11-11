#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-accounting-integration")


#heading(level: 1)[Accounting and Finance in an ERP System]
 <ch:accounting>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand the order-to-cash, procure-to-pay, and manufacturing flows.

*By the end, you can:* explain how operational transactions create financial information, distinguish financial and managerial accounting, describe receivables and credit information, and connect inventory and sales events to management reporting.]

#callout("sourcebasis", title: [Source basis])[The tutorial set does not contain a separate Accounting tutorial, but Accounting and Finance appears repeatedly in Tutorial 1, Tutorial 5, and the Odoo build guide. This chapter therefore uses Chapter 5 of the textbook to supply the missing conceptual foundation and maps it to Odoo Invoicing in the practical scenario.]


#heading(level: 2)[Why Accounting is embedded in every ERP process]


Accounting is not an activity that happens only at the end of the month. Every sale, purchase, receipt, production event, delivery, invoice, payment, payroll run, and expense can have financial consequences.

In an unintegrated environment, accountants must collect and reconcile data from operational systems. In an ERP environment, the objective is to record the business event once and reuse that event to produce the accounting information required by Finance.

#callout("keyidea", title: [Key idea])[Operational data and financial data are two views of the same business event. "Five Road Bikes delivered" is an inventory event, a customer-service event, and part of the evidence behind the financial transaction.]


#heading(level: 2)[Financial accounting versus managerial accounting]


#strong[Financial accounting] focuses on formal records and statements for external and stewardship purposes. Two core statements introduced in the textbook are the balance sheet and the income statement.

#strong[Managerial accounting] focuses on internal decision-making: product cost, profitability, budgets, performance, and resource use.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Dimension], [Financial accounting], [Managerial accounting],),
    table.hline(),
    [Primary users], [Owners, creditors, regulators, external stakeholders, management], [Internal managers and process owners],
    [Main questions], [What is the company's financial position and performance?], [Which product, customer, activity, or process is profitable and why?],
    [Typical outputs], [Balance sheet, income statement, cash-related reports], [Cost reports, budgets, variance analysis, product/customer profitability],
    [Data need], [Accurate and controlled transaction records], [Detailed operational and financial data with useful dimensions],
  )]
  , kind: table
  )

An ERP system helps because the same central transaction data can support both views.


#heading(level: 2)[Accounts receivable and customer credit]


When a company sells on credit, it creates an #strong[account receivable]: an amount the customer owes. Sales needs current receivable and payment information when deciding whether a new order should be accepted under the customer's credit terms.

The Fitter Snacker case shows why stale data is dangerous. A weekly printed credit report may ignore a recent payment or a recent sale. In an integrated ERP, Sales and Finance can use the current customer balance and open transactions instead of waiting for the next report.


#heading(level: 2)[Inventory has both quantity and value]


When components are received, Inventory sees a quantity increase. Accounting needs the monetary consequence of that event as well. Similarly, when manufacturing consumes materials and produces finished goods, the system needs to preserve both physical and value information so managers can understand product cost.

The textbook notes that product-cost analysis can use data already maintained in production planning---for example BOM quantities---together with cost information. This reduces the need for accountants to rebuild the material structure manually.

#callout("workedexample", title: [Worked example])[The Road Bike BOM contains one Aluminium Frame at a guide cost of RM 200, two Rubber Tires at RM 40 each, one Brake Set at RM 70, one Gear Set at RM 90, and one Bicycle Chain at RM 30. Ignoring labour and overhead, the direct material guide cost is: $ 200 + 2 \( 40 \) + 70 + 90 + 30 = upright("RM ") 470 . $ If the selling price is RM 1,000, RM 530 is #emph[not] automatically profit because labour, overhead, selling costs, taxes, discounts, and other costs have not yet been considered.]


#heading(level: 2)[The accounting document flow]


A useful ERP principle is #strong[document flow]: users should be able to trace a transaction through related records rather than search several disconnected systems.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/f88f993a328dbf92.svg")], caption: [The accounting document flow. Each document is created from the one before it, and the invoice and the payment both feed financial and management reporting, so a transaction can be traced end to end.]) <fig:accounting-document-flow>

This lineage supports customer service. A salesperson can answer "Has the customer paid?" without asking Finance to search a separate system, assuming the user has appropriate access rights.


#heading(level: 2)[Closing the books and reporting]


A company must periodically prepare financial statements and management reports. If source transactions are fragmented and late, accountants spend time finding missing data and posting adjustments. A central ERP database makes it easier to produce current reports because operational events are already stored in a controlled structure.

This does not eliminate accounting judgement or controls. It reduces the mechanical work of gathering inconsistent copies of transactions.


#heading(level: 2)[Controls and authorisation]


Integration increases the importance of access control. If one system touches Sales, Inventory, Purchasing, and Finance, users should receive only the permissions required for their roles.

Typical controls include:

- approval limits;

- separation of duties;

- authorised user roles;

- audit trails and document history;

- tolerances for quantity or price differences;

- controlled master-data changes.

#callout("pitfall", title: [Common mistake])[A shared database does not mean every employee should see or edit everything. Integration and authorisation are separate design concerns: data can be connected while access remains role-based.]


#heading(level: 2)[Finance in the Odoo Community workflow]


The supplied guide explicitly states that the course uses #strong[Invoicing] in Odoo 19 Community rather than the broader Enterprise Accounting feature set.

#callout("applicationbox", title: [Application walkthrough])[For the Road Bike order:

+ the Sales Order contains 5 Road Bikes at RM 1,000 each;

+ #strong[Create Invoice] generates a draft invoice from the Sales Order;

+ posting the invoice changes it from Draft to Posted;

+ #strong[Register Payment] records the customer payment in Bank or Cash using the manual method for the demo;

+ the invoice becomes Paid or In Payment depending on configuration.

The important information-flow lesson is that product, quantity, customer, and price come from the linked sales transaction instead of being re-entered.]


#heading(level: 2)[Management reporting]


The Odoo guide recommends Graph and Pivot views after the end-to-end transaction is complete. The point is not merely to create a chart: the report is generated from the transaction history built by Sales, Inventory, Manufacturing, and Invoicing.

Useful management questions include:

- How much was sold and invoiced?

- Which products generated revenue?

- Which invoices remain unpaid?

- What inventory remains on hand?

- What was manufactured during the period?

- Which customer opportunities are still open?

#callout("tryit", title: [Try it yourself])[Trace one West End Bicycles transaction from Sales Order to payment. At each step write two columns: "operational fact" and "financial/management meaning." For example, "5 bikes delivered" is the operational fact; "customer order fulfilled and inventory reduced" is one management meaning.]

#callout("quickcheck", title: [Check your understanding])[+ Why does Sales need current Accounts Receivable information?

+ What is the difference between direct material cost and profit?

+ Why is document flow useful for both accountants and customer-facing staff?]
