#import "/.shared/typst/utp.typ": *
#unit("labs", "04-crm-odoo")

#labsection(4, label: <sec:lab04>)[Customer Relationship Management in Odoo]

#labproject[Build a customer opportunity and convert relationship data into a quotation][
  #strong[Coverage.] Tutorial 4 + Chapter 4. \

  #strong[Core system.] Odoo CRM + Sales. \

  #strong[Goal.] Demonstrate that CRM manages the relationship before the sales order exists and preserves that context when the deal becomes a quotation.

  #include "visuals/04-flow.typ"

  #labmode[
    Tutorial 4 asks for a CRM proposal for Luna Electronics. The Odoo exercise gives you a working example of pipeline, ownership, expected revenue, stages, and conversion to quotation. Use that hands-on experience when explaining what CRM features actually do.
  ]

  #v(6pt)
  #strong[Part A --- Create the customer.]

  Create #strong[Seri Iskandar Cycling Club] as a company contact with the location and contact details from the supplied guide.

  #include "visuals/04-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:crm>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Opportunity expected value, quotation amount and accounting revenue are different states. Use the document references to follow the conversion. If quantities change, explain which amount is recalculated and which opportunity field still needs review.

  #include "visuals/04-worked-case.typ"

  #v(6pt)
  #strong[Part B --- Create the opportunity.]

  Open #utpapp[CRM] and create:

  - Opportunity: Road Bike Order -- Seri Iskandar Cycling Club;
  - Customer: Seri Iskandar Cycling Club;
  - Expected Revenue: RM 5,000;
  - Salesperson: Sales Manager.

  Explain why RM 5,000 is an expected amount rather than confirmed sales revenue at this stage.

  #v(6pt)
  #strong[Part C --- Move the deal through the pipeline.]

  Move the opportunity from New to Qualified and then to Proposition as appropriate. Add an internal note such as “Customer requested 5 Road Bikes.” After the sales order is later confirmed, mark the opportunity Won.

  #v(6pt)
  #strong[Part D --- Create the quotation from the opportunity.]

  Use the opportunity’s quotation action. Confirm the customer and salesperson, add 5 Road Bikes, and check RM 1,000 unit price. Save the quotation but do not rush past the CRM meaning: the customer, owner, expected revenue, and sales document are now linked.

  #v(6pt)
  #strong[Part E --- Use the experience in the Luna Electronics proposal.]

  For each proposal section, connect the claim to a CRM mechanism you saw:

  - customer acquisition: leads/opportunities and pipeline;
  - retention: shared interaction history and follow-up;
  - service: a common customer record and visible prior interactions;
  - sales productivity: ownership, stages, expected revenue, and conversion to quotation;
  - management visibility: pipeline and reporting views.

  #pitfall[
    Do not present expected revenue as money already earned. Pipeline value is a forecast of potential business and depends on stage quality, probability assumptions, and user discipline.
  ]
]

#strong[Chapter connection.] Revisit #link(<ch:crm>)[the chapter explanation] and map its states to the steps below.

#include "visuals/04-crm-odoo-chapter.typ"

#include "walkthroughs/04-records.typ"

#verification[
  #strong[Explain and extend your result.] Follow one opportunity into its quotation. Change quantity and reconcile the quote’s untaxed amount, then explain whether and how the opportunity’s expected value was updated.

  - Seri Iskandar Cycling Club exists as a company contact.
  - The opportunity carries the customer, the Sales Manager, and RM 5,000 expected revenue.
  - The opportunity moves through the pipeline stages with an internal note recorded.
  - The quotation is created from the opportunity, for 5 Road Bikes at RM 1,000 each, and stays linked to it.
]
