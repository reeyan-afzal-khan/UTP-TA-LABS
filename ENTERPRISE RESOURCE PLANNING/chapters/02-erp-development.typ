#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-erp-development")


#heading(level: 1)[The Development of ERP Systems: Architecture, Benefits, and Challenges]
 <ch:erp-development>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand the idea of functional silos from Chapter 1.

*By the end, you can:* explain how MRP evolved into ERP, describe ERP modularity and shared data, evaluate major benefits and implementation challenges, and identify conditions that make an ERP project more likely to succeed.]

#callout("sourcebasis", title: [Source basis])[This chapter is based on Tutorial 2 and Chapter 2 of #emph[Concepts in Enterprise Resource Planning], with implementation ideas reinforced by Chapter 7. Tutorial 2 asks students to investigate one ERP benefit and one ERP challenge, support each with evidence, and teach the result to peers.]


#heading(level: 2)[Why ERP systems emerged]


Business computing did not begin with an integrated platform. Early systems were built to solve one department's immediate problem: a manufacturing system tracked materials, an accounting system recorded transactions, a sales system captured orders. Each was useful alone while leaving the company as a whole hard to coordinate.

The manufacturing lineage matters most. #strong[Material Requirements Planning (MRP)] calculated what materials were needed and when. Later systems added capacity, then extended past the factory into sales, purchasing, finance, HR, and logistics.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/69368464ec823861.cetz.json")], caption: [Each generation kept the previous scope and added a question it could not previously answer. ERP is the point at which the question stops being about the factory and starts being about the company.]) <fig:erp-evolution>


#heading(level: 2)[The core architectural idea: modules around shared data]


ERP products are modular because businesses perform different kinds of work. Sales needs quotations; manufacturing needs bills of materials; finance needs invoices and payments. Modularity lets specialised workflows exist while still drawing on the same underlying records.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/2056a824d848aa52.cetz.json")], caption: [The architecture in three layers. Users see specialised modules, but every module reads and writes the same master and transaction data underneath. Integration lives in the bottom layer, not in the screens.]) <fig:erp-layers>

Two kinds of data are worth separating, because they behave differently and fail differently.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/7490300cf239e3a0.cetz.json")], caption: [Master data is written rarely and read constantly; transaction data is written constantly and refers back to the master records. One bad master record therefore contaminates every transaction that points at it. The payment is RM 5,500 because Odoo adds its default 10% tax for Malaysia to the RM 5,000 order.]) <fig:master-vs-transaction>

#callout("keyidea", title: [Key idea])[ERP integration is not achieved by putting every task on one giant screen. It is achieved by letting specialised modules share master data and create linked transaction records from the same business events.]


#heading(level: 2)[Real time means one current version, not zero delay]


In the textbook, #strong[real time] means data is current rather than waiting for a periodic transfer. A confirmed order reaches the functions that need it without a clerk exporting a file or re-keying it.

This does not mean every metric updates instantly. The useful operational meaning is that authorised users work from the same current records instead of separately maintained departmental copies.


#heading(level: 2)[Major benefits of ERP]


The benefits described in the source all run through one of four mechanisms. Naming the mechanism is what turns "ERP improves efficiency" into an argument.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/d250ec325f2273cf.cetz.json")], caption: [Benefits are consequences, not features. Each chain runs from a structural change, through a change in what people actually do, to something that can be measured.]) <fig:benefit-chain>

Better customer service, lower inventory, shorter cycle times, and stronger control are downstream consequences of these four.

#callout("workedexample", title: [Worked example])[Suppose West End Bicycles keeps the Road Bike price in a salesperson's spreadsheet and again in Finance's invoice system. A price change must be made twice and may be missed once. With one integrated product record, the quotation and the later invoice read the same price.]


#heading(level: 2)[Why ERP projects are difficult]


ERP affects many departments at once, so implementation is an organisational change project as much as a technology project. Licence and hardware costs are the visible part; the costs that sink projects are mostly below the surface.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/438836cbf1b61021.cetz.json")], caption: [Software licences are the part budgeted first and the part that matters least to whether the project succeeds. Everything below the line is process and people work.]) <fig:cost-iceberg>

Failed implementations are usually traced to process and people problems: assuming software will repair a bad process, thin planning before configuration, inadequate training, treating the work as IT-only, weak executive sponsorship, poor change management, uncontrolled scope or customisation, and difficult migration of legacy data.

#callout("pitfall", title: [Common mistake])["Install ERP" is not a business objective. A project needs a process objective --- reduce order cycle time, improve inventory accuracy, shorten the financial close --- or the organisation can spend heavily and reproduce its old problems inside newer software.]


#heading(level: 2)[Standard processes versus customisation]


ERP packages embody a particular way of doing business. Every gap between the package and the company forces a decision, and the cheapest answer is not always the right one.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/8c86bba17c2ff632.cetz.json")], caption: [Work down the questions before writing code. Custom features are not forbidden, but each one is paid for again at every future upgrade.]) <fig:customisation-decision>


#heading(level: 2)[How to judge ERP success]


A successful implementation is not one that merely goes live. It should move measurable business outcomes: order-to-delivery cycle time, inventory accuracy and stockout frequency, invoice and payment processing time, days to close, forecast accuracy, share of transactions completed without re-entry, user adoption, service levels, and realised cost or revenue change.

Some benefits resist cash valuation. Better visibility, consistent data, and the capacity to support growth may still be strategically decisive.


#heading(level: 2)[Implementation success factors]


#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Success factor], [Why it matters],),
    table.hline(),
    [Executive sponsorship], [Gives the project authority, resources, and cross-functional priority.],
    [Clear scope and objectives], [Prevents uncontrolled expansion and makes benefits measurable.],
    [Process ownership], [Puts decisions with people who understand the work, not only the technology.],
    [Training and communication], [Helps users understand both the system and the new process.],
    [Change management], [Addresses resistance, role changes, and new responsibilities.],
    [Data preparation], [Poor master data undermines even correctly configured software.],
    [Testing and staged readiness], [Finds problems before live transactions depend on the system.],
  )]
  , kind: table
  )


#heading(level: 2)[How Odoo illustrates ERP modularity]


The West End Bicycles guide uses eight Odoo 19 Community applications. Each has a distinct job; the records are connected.

#callout("applicationbox", title: [Application walkthrough])[Read the Odoo app grid as a modular ERP architecture:

- #strong[Contacts]: shared customer and vendor identities.

- #strong[CRM] and #strong[Sales]: demand, opportunities, quotations, orders.

- #strong[Purchase], #strong[Inventory], #strong[Manufacturing]: sourcing, stock, production.

- #strong[Invoicing]: customer invoices and payments in the Community workflow.

- #strong[Employees]: departments and the people behind the processes.

The same product, customer, vendor, and order data is reused rather than rebuilt in each app.]

#callout("tryit", title: [Try it yourself])[Choose one ERP benefit and one implementation challenge from this chapter. For each write: (1) the mechanism, (2) one operational example at West End Bicycles, and (3) one metric that would show whether it improved. This mirrors Tutorial 2 while forcing the argument to be measurable.]

#callout("quickcheck", title: [Check your understanding])[+ What is the difference between master data and transaction data? Give two Odoo examples of each.

+ Why is top-management support important in a cross-functional ERP implementation?

+ Why can copying an inefficient legacy process exactly into an ERP system reduce the expected benefit?]
