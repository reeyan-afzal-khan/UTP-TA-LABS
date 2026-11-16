#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-crm")

= Customer Relationship Management <ch:crm>

#chapterguide[You should know the sales-order process and the difference between a potential sale and a confirmed order.][explain the purpose of CRM, distinguish operational CRM activities, connect CRM to ERP data, and evaluate how CRM supports acquisition, retention, sales, marketing, and service.]

#note[
  This chapter follows Tutorial 4 and the CRM section of Chapter 3 in the
  textbook. Tutorial 4 uses Luna Electronics and asks students to justify CRM,
  propose a CRM system, explain its features, and support the proposal with a case
  study.
]

== CRM is a relationship process, not just a contact list

#term[Customer Relationship Management (CRM)] is a set of processes and systems
for managing interactions with prospects and customers across the whole
relationship. A contact database answers “Who is this customer?” A CRM system
must also answer what happens next, and who owns it.

#utpfig([The same customer record, two levels of ambition. Everything in the right-hand column is a question about action; a contact list cannot answer any of them.], label: <fig:contact-vs-crm>)[
  #canvas({
    rectangle((0, -0.55), (6.4, 3.6), draw: mix(muted, 45%), fill: pale-gray, rounded: 2.5mm)
    node((3.2, 3.25), [#strong[Contact list]], ..proccap, text: muted)
    node((3.2, 2.5), [Name and address], ..procquiet, min-width: 5.4, min-height: 0.7)
    node((3.2, 1.65), [Telephone and email], ..procquiet, min-width: 5.4, min-height: 0.7)
    node((3.2, 0.8), [Contact person], ..procquiet, min-width: 5.4, min-height: 0.7)
    node((3.2, 0), [answers #emph[who]], ..procnote, text: muted)
    rectangle((7.6, -0.55), (14.6, 3.6), draw: mix(blue, 45%), fill: mix(pale-blue, 45%), rounded: 2.5mm)
    node((11.1, 3.25), [#strong[CRM]], ..proccap, text: blue)
    for (i, t) in ((0, "Which opportunities are open, and worth how much?"), (1, "Who owns the next action, and by when?"), (2, "What has this customer bought, been promised, complained about?")) {
      let y = 2.5 - i * 0.85
      node((11.1, y), [#t], ..procstep, min-width: 6.4, text-width: 6, min-height: 0.7)
    }
    node((11.1, 0), [answers #emph[what next]], ..procnote, text: blue)
    connect((6.6, 1.5), (7.4, 1.5), ..procflow)
  })
]

#note[
  CRM gives the organisation a “single face to the customer.” The customer should
  not receive three contradictory prices from Sales, Marketing, and an executive
  simply because those people do not share interaction history.
]

== Core CRM activities

#utptable[
  #tabularx(
    columns: (25%, 1fr),
    styles: (navy-bold,),
    header: ([CRM activity], [Purpose]),
    [One-to-one marketing], [Tailor offers and communication to a customer’s profile or history; supports cross-selling and up-selling.],
    [Sales force automation], [Record contacts, assign leads, track opportunities, manage follow-ups, and forecast sales activity.],
    [Campaign management], [Organise marketing campaigns and analyse their outcomes.],
    [Marketing content / knowledge], [Give staff consistent product and promotional information.],
    [Service and call-centre support], [Provide representatives with customer and product history so issues can be resolved without starting from zero.],
  )
]

== Lead, opportunity, quotation, and order are different states

A common beginner mistake is to treat every prospect as a sales order. CRM
exists partly because sales work begins long before a customer commits --- and
because most prospects never do.

#utpfig([Each stage is a smaller, better-qualified set. The illustrative counts show why a pipeline cannot be read as revenue: only the last two stages are commitments.], label: <fig:sales-funnel>)[
  #canvas({
    for (i, w, lbl, n, c) in ((0, 11.4, "Lead — an expression of interest", 200, muted), (1, 9.4, "Qualified opportunity — actively pursued", 60, blue), (2, 7.4, "Quotation — a commercial offer", 25, blue), (3, 5.4, "Sales order — customer commitment", 12, green), (4, 5.4, "Ongoing relationship — service, repeat, referral", 12, green)) {
      let y = -i * 1.02
      node((6.2, y), [#lbl], name: "f" + str(i), draw: c, fill: mix(c, 12%), rounded: 2mm, min-width: w, min-height: 0.8, font: font("script", weight: "bold", fill: navy))
      node((12.8, y), [#n deals], ..procchip, anchor: "west")
    }
    for i in range(0, 4) {
      let j = int(i + 1)
      connect("f" + str(i), "f" + str(j), ..procflow)
    }
    brace((0, 0.42), (0, -2.5), amplitude: 3.9851pt, mirror: true, draw: muted, line-width: widths.semithick)
    node((-0.25, -1), [#strong[CRM \
   owns these]], ..proccap, anchor: "east", text-width: 1.5, align: right)
    brace((0, -2.65), (0, -4.5), amplitude: 3.9851pt, mirror: true, draw: green, line-width: widths.semithick)
    node((-0.25, -3.6), [#strong[Sales \
   and ERP]], ..proccap, anchor: "east", text-width: 1.5, align: right, text: green)
  })
]

A #term[lead] is a potential contact. An #term[opportunity] is a deal being
actively pursued. A #term[quotation] is a commercial offer. A #term[sales order]
is a confirmed commitment. After the sale, service and marketing continue the
relationship.

== Why CRM becomes more valuable when integrated with ERP

CRM holds customer-facing information; ERP holds operational and financial
information. Connected, the salesperson never has to guess whether a customer
was delivered, invoiced, or paid.

#utpfig([What a salesperson can see when CRM and ERP share master data. The left column is relationship history; the right column is operational truth that would otherwise require a phone call to another department.], label: <fig:customer-360>)[
  #canvas({
    node((7.3, 0.9), [Seri Iskandar \
  #fsize("script")[#strong[Cycling Club]]], name: "cust", ..procstore, min-width: 3.4, min-height: 1.3, draw: navy, fill: mix(navy, 8%))
    for (i, t) in ((0, "Opportunities and pipeline stage"), (1, "Campaigns and offers received"), (2, "Service history and complaints")) {
      let y = 2.2 - i * 1.3
      node((2.7, y), [#t], name: "l" + str(i), ..procstep, min-width: 5.2, text-width: 4.8, min-height: 0.85)
      connect("l" + str(i), "cust", ..procflow)
    }
    for (i, t) in ((0, "Open orders and delivery status"), (1, "Invoices, payments, receivable balance"), (2, "Purchase history, product mix, discounts")) {
      let y = 2.2 - i * 1.3
      node((11.9, y), [#t], name: "r" + str(i), ..procgood, min-width: 5.2, text-width: 4.8, min-height: 0.85)
      connect("cust", "r" + str(i), ..procflow)
    }
    node((2.7, 3.25), [#strong[from CRM]], ..proccap, text: blue)
    node((11.9, 3.25), [#strong[from ERP]], ..proccap, text: green)
    node((7.3, -0.35), [one identity, so both halves describe the same customer], ..procnote, text-width: 5)
  })
]

This supports better decisions: which customers to prioritise, which products to
cross-sell, which accounts need service attention, and whether a discount is
commercially sensible.

== The Luna Electronics problem

Tutorial 4 asks how CRM could help Luna Electronics grow its customer base,
retain existing customers, and improve service. A convincing answer connects
each business problem to a mechanism rather than asserting that “CRM improves
customer relationships.”

#example[
  Suppose Luna Electronics loses repeat customers because complaints are handled
  through personal email inboxes. A CRM process logs the interaction against the
  customer, assigns responsibility, stores the response, and makes the history
  visible to the next employee. The benefit is not the database; it is faster,
  more consistent service and less dependence on one person’s memory.
]

#utptable[
  #tabularx(
    columns: (23%, 31%, 1fr),
    styles: (navy-bold,),
    header: ([Business goal], [CRM mechanism], [Possible evidence of success]),
    [Acquire customers], [Lead capture, campaign tracking, opportunity pipeline, follow-up activities.], [Lead-to-opportunity and opportunity-to-order conversion.],
    [Retain customers], [Interaction history, segmentation, targeted offers, proactive follow-up.], [Repeat-purchase rate, churn rate, customer lifetime value trend.],
    [Improve service], [Shared case history, knowledge base, ownership and escalation.], [Response time, resolution time, repeated-contact rate, satisfaction score.],
    [Improve sales productivity], [Pipeline visibility, next activities, opportunity value, automated document hand-off.], [Sales cycle length, win rate, forecast accuracy.],
  )
]

== CRM data quality and governance

CRM is only useful if staff record interactions consistently. The common failures
are duplicate customers, opportunities with no next activity, optimistic expected
revenue, inconsistent stages, and missing contact details.

The consequence is a pipeline that looks convincing and forecasts badly.

#utpfig([One pipeline, two readings. The disciplined forecast weights each stage by a realistic win probability and lands close to actual; reading the raw value as if every open deal will close over-forecasts by more than double.], label: <fig:pipeline-quality>)[
  #canvas({
    axis(width: 13.4cm, height: 5.6cm, ybar: 2.4907pt, bar-width: 8.9664pt, ymin: 0, ymax: 430, ylabel: [RM thousand], symbolic-x: ("Qualified", "Proposition", "Negotiation", "Won", "Forecast", "Actual"), xtick: "data", x-tick-label-style: font("script", fill: muted), enlarge-x-limits: 0.11, legend-style: (at: (0.5, 1.19), anchor: "north", columns: 2), ymajorgrids: true, grid-style: (draw: mix(muted, 22%)), nodes-near-coords: true, node-near-coord-style: (font: font("tiny", fill: muted),),
      addplot(draw: green, fill: pale-teal, coords: (("Qualified", 30), ("Proposition", 48), ("Negotiation", 60), ("Won", 45), ("Forecast", 183), ("Actual", 176)), legend: [weighted by stage probability (30%, 40%, 60%, 100%)]),
      addplot(draw: red, fill: pale-red, coords: (("Qualified", 100), ("Proposition", 120), ("Negotiation", 100), ("Won", 45), ("Forecast", 365), ("Actual", 176)), legend: [raw pipeline value]),
    )
  })
]

A good CRM process therefore defines what counts as a lead and an opportunity,
when a stage should change, who owns the record, which fields are mandatory, how
duplicates are prevented, what “won” and “lost” mean, and how lost reasons
are recorded.

#warning[
  A colourful pipeline is not automatically a reliable sales forecast. If users
  move opportunities between stages inconsistently or enter unrealistic expected
  revenue, management gets an attractive but misleading report.
]

== CRM in the West End Bicycles Odoo flow

#utpfig([The opportunity from the supplied guide moving across the pipeline, and the point at which it becomes an operational document. Expected revenue exists from the first stage; committed revenue does not exist until the Sales Order is confirmed.], label: <fig:odoo-pipeline>)[
  #canvas({
    for (i, st, c) in ((0, "New", muted), (1, "Qualified", blue), (2, "Proposition", blue), (3, "Won", green)) {
      let x = 1.7 + i * 3.6
      rectangle((x - 1.55, 0), (x + 1.55, 2.55), draw: mix(c, 55%), fill: mix(c, 8%), rounded: 2mm)
      node((x, 2.28), [#strong[#st]], ..proccap, text: c)
    }
    node((1.7, 1.05), [Road Bike Order \
   --- Seri Iskandar], name: "o0", ..procdoc, min-width: 2.7, text-width: 2.4, min-height: 1.35)
    node((5.3, 1.05), [$+$ customer confirmed], name: "o1", ..procdoc, min-width: 2.7, text-width: 2.4, min-height: 1.35, draw: blue)
    node((8.9, 1.05), [$+$ quantity and price agreed], name: "o2", ..procdoc, min-width: 2.7, text-width: 2.4, min-height: 1.35, draw: blue)
    node((12.5, 1.05), [opportunity marked Won], name: "o3", ..procdoc, min-width: 2.7, text-width: 2.4, min-height: 1.35, draw: green)
    for i in range(0, 3) {
      let j = int(i + 1)
      connect("o" + str(i), "o" + str(j), ..procflow)
    }
    node((0.15, -0.45), [expected revenue RM 5,000 --- a forecast, not income], ..procchipwarn, anchor: "west")
    node((8.9, -1.85), [Quotation \
  #fsize("tiny")[#text(weight: "regular")[5 Road Bikes at RM 1,000]]], name: "q", ..procstep, min-width: 3.4, min-height: 0.95, draw: green, fill: pale-teal)
    node((13.2, -1.85), [Sales Order \
  #fsize("tiny")[#text(weight: "regular")[RM 5,000 committed]]], name: "so", ..procstep, min-width: 3.4, min-height: 0.95, draw: green, fill: pale-teal)
    connect("o2.south", "q.north", ..procflow)
    node(along("o2.south", "q.north", t: 50%), [create quotation from the opportunity], ..procnote, text-width: 2.4, anchor: "west")
    connect("q", "so", ..procflow)
    node(along("q", "so", t: 50%), [confirm], ..procnote, anchor: "south")
    connect("so.north", "o3.south", ..procflow)
  })
]

#note[
  #strong[In Odoo 19 Community.] The supplied guide creates an opportunity called #strong[Road Bike Order --- Seri Iskandar Cycling Club] with expected revenue of RM 5,000, assigns the Sales
  Manager, moves it through the pipeline, and then creates the quotation for 5 Road
  Bikes. Three CRM principles are on display: the deal is owned by a named person,
  expected revenue exists before the sale is confirmed, and the opportunity creates
  the quotation so relationship history survives the hand-off.
]

== How to evaluate a CRM proposal

For the Tutorial 4 proposal, six questions make a strong evaluation framework:

+ #strong[Fit:] Does the system support the required sales, marketing, and service processes?
+ #strong[Integration:] Can customer, order, delivery, and financial data be connected?
+ #strong[Usability:] Will staff actually record and update interactions?
+ #strong[Reporting:] Can management see conversion, pipeline, campaigns, and service performance?
+ #strong[Governance and security:] Can access, ownership, and customer-data handling be controlled?
+ #strong[Cost and scalability:] Is the system affordable and able to grow with the business?

#exercises[
  For Luna Electronics, choose one customer problem and write a chain in this
  format: #emph[problem $arrow.r$ CRM feature $arrow.r$ changed employee behaviour $arrow.r$ measurable business outcome]. If one link is vague, the
  proposal needs more detail.
]

#questions[
  + Why is an opportunity different from a sales order?
  + Give one example of cross-selling and one of up-selling for Luna Electronics.
  + Why does CRM data quality affect sales forecasting?
]
