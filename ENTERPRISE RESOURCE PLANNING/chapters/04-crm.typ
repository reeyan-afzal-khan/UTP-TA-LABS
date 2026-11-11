#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-crm")


#heading(level: 1)[Customer Relationship Management]
 <ch:crm>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should know the sales-order process and the difference between a potential sale and a confirmed order.

*By the end, you can:* explain the purpose of CRM, distinguish operational CRM activities, connect CRM to ERP data, and evaluate how CRM supports acquisition, retention, sales, marketing, and service.]

#callout("sourcebasis", title: [Source basis])[This chapter follows Tutorial 4 and the CRM section of Chapter 3 in the textbook. Tutorial 4 uses Luna Electronics and asks students to justify CRM, propose a CRM system, explain its features, and support the proposal with a case study.]


#heading(level: 2)[CRM is a relationship process, not just a contact list]


#strong[Customer Relationship Management (CRM)] is a set of processes and systems for managing interactions with prospects and customers across the whole relationship. A contact database answers "Who is this customer?" A CRM system must also answer what happens next, and who owns it.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/b87c4889d894c060.cetz.json")], caption: [The same customer record, two levels of ambition. Everything in the right-hand column is a question about action; a contact list cannot answer any of them.]) <fig:contact-vs-crm>

#callout("intuition", title: [Plain idea])[CRM gives the organisation a "single face to the customer." The customer should not receive three contradictory prices from Sales, Marketing, and an executive simply because those people do not share interaction history.]


#heading(level: 2)[Core CRM activities]


#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([CRM activity], [Purpose],),
    table.hline(),
    [One-to-one marketing], [Tailor offers and communication to a customer's profile or history; supports cross-selling and up-selling.],
    [Sales force automation], [Record contacts, assign leads, track opportunities, manage follow-ups, and forecast sales activity.],
    [Campaign management], [Organise marketing campaigns and analyse their outcomes.],
    [Marketing content / knowledge], [Give staff consistent product and promotional information.],
    [Service and call-centre support], [Provide representatives with customer and product history so issues can be resolved without starting from zero.],
  )]
  , kind: table
  )


#heading(level: 2)[Lead, opportunity, quotation, and order are different states]


A common beginner mistake is to treat every prospect as a sales order. CRM exists partly because sales work begins long before a customer commits --- and because most prospects never do.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/81ce3144163cb464.cetz.json")], caption: [Each stage is a smaller, better-qualified set. The illustrative counts show why a pipeline cannot be read as revenue: only the last two stages are commitments.]) <fig:sales-funnel>

A #strong[lead] is a potential contact. An #strong[opportunity] is a deal being actively pursued. A #strong[quotation] is a commercial offer. A #strong[sales order] is a confirmed commitment. After the sale, service and marketing continue the relationship.


#heading(level: 2)[Why CRM becomes more valuable when integrated with ERP]


CRM holds customer-facing information; ERP holds operational and financial information. Connected, the salesperson never has to guess whether a customer was delivered, invoiced, or paid.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/368bcb8dc0ddcefe.cetz.json")], caption: [What a salesperson can see when CRM and ERP share master data. The left column is relationship history; the right column is operational truth that would otherwise require a phone call to another department.]) <fig:customer-360>

This supports better decisions: which customers to prioritise, which products to cross-sell, which accounts need service attention, and whether a discount is commercially sensible.


#heading(level: 2)[The Luna Electronics problem]


Tutorial 4 asks how CRM could help Luna Electronics grow its customer base, retain existing customers, and improve service. A convincing answer connects each business problem to a mechanism rather than asserting that "CRM improves customer relationships."

#callout("workedexample", title: [Worked example])[Suppose Luna Electronics loses repeat customers because complaints are handled through personal email inboxes. A CRM process logs the interaction against the customer, assigns responsibility, stores the response, and makes the history visible to the next employee. The benefit is not the database; it is faster, more consistent service and less dependence on one person's memory.]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Business goal], [CRM mechanism], [Possible evidence of success],),
    table.hline(),
    [Acquire customers], [Lead capture, campaign tracking, opportunity pipeline, follow-up activities.], [Lead-to-opportunity and opportunity-to-order conversion.],
    [Retain customers], [Interaction history, segmentation, targeted offers, proactive follow-up.], [Repeat-purchase rate, churn rate, customer lifetime value trend.],
    [Improve service], [Shared case history, knowledge base, ownership and escalation.], [Response time, resolution time, repeated-contact rate, satisfaction score.],
    [Improve sales productivity], [Pipeline visibility, next activities, opportunity value, automated document hand-off.], [Sales cycle length, win rate, forecast accuracy.],
  )]
  , kind: table
  )


#heading(level: 2)[CRM data quality and governance]


CRM is only useful if staff record interactions consistently. The common failures are duplicate customers, opportunities with no next activity, optimistic expected revenue, inconsistent stages, and missing contact details.

The consequence is a pipeline that looks convincing and forecasts badly.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/cf56198f166bc661.cetz.json")], caption: [One pipeline, two readings. The disciplined forecast weights each stage by a realistic win probability and lands close to actual; reading the raw value as if every open deal will close over-forecasts by more than double.]) <fig:pipeline-quality>

A good CRM process therefore defines what counts as a lead and an opportunity, when a stage should change, who owns the record, which fields are mandatory, how duplicates are prevented, what "won" and "lost" mean, and how lost reasons are recorded.

#callout("pitfall", title: [Common mistake])[A colourful pipeline is not automatically a reliable sales forecast. If users move opportunities between stages inconsistently or enter unrealistic expected revenue, management gets an attractive but misleading report.]


#heading(level: 2)[CRM in the West End Bicycles Odoo flow]


#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/def72ae583e14cfc.cetz.json")], caption: [The opportunity from the supplied guide moving across the pipeline, and the point at which it becomes an operational document. Expected revenue exists from the first stage; committed revenue does not exist until the Sales Order is confirmed.]) <fig:odoo-pipeline>

#callout("applicationbox", title: [Application walkthrough])[The supplied guide creates an opportunity called #strong[Road Bike Order --- Seri Iskandar Cycling Club] with expected revenue of RM 5,000, assigns the Sales Manager, moves it through the pipeline, and then creates the quotation for 5 Road Bikes. Three CRM principles are on display: the deal is owned by a named person, expected revenue exists before the sale is confirmed, and the opportunity creates the quotation so relationship history survives the hand-off.]


#heading(level: 2)[How to evaluate a CRM proposal]


For the Tutorial 4 proposal, six questions make a strong evaluation framework:

+ #strong[Fit:] Does the system support the required sales, marketing, and service processes?

+ #strong[Integration:] Can customer, order, delivery, and financial data be connected?

+ #strong[Usability:] Will staff actually record and update interactions?

+ #strong[Reporting:] Can management see conversion, pipeline, campaigns, and service performance?

+ #strong[Governance and security:] Can access, ownership, and customer-data handling be controlled?

+ #strong[Cost and scalability:] Is the system affordable and able to grow with the business?

#callout("tryit", title: [Try it yourself])[For Luna Electronics, choose one customer problem and write a chain in this format: #emph[problem $arrow.r$ CRM feature $arrow.r$ changed employee behaviour $arrow.r$ measurable business outcome]. If one link is vague, the proposal needs more detail.]

#callout("quickcheck", title: [Check your understanding])[+ Why is an opportunity different from a sales order?

+ Give one example of cross-selling and one of up-selling for Luna Electronics.

+ Why does CRM data quality affect sales forecasting?]
