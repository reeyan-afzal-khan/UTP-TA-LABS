#import "/.shared/typst/utp.typ": *
#unit("labs", "02-erp-development-odoo")

#labsection(2, label: <sec:lab02>)[ERP Benefits, Challenges, and Modular Integration]

#labproject[Teach one ERP benefit and one ERP challenge using the system you just built][
  #strong[Coverage.] Tutorial 2 + Chapter 2. \

  #strong[Core system.] Odoo 19 Community app structure. \

  #strong[Goal.] Move from generic statements such as “ERP improves efficiency” to evidence-based explanations of how integration creates benefits and why implementation is difficult.

  #include "visuals/02-flow.typ"

  #labmode[
    Tutorial 2 uses Team Benefit and Team Challenge. Odoo is used here as a concrete reference architecture: each team must point to at least one app-to-app connection or setup choice that demonstrates the selected benefit/challenge.
  ]

  #v(6pt)
  #strong[Part A --- Team Benefit.]

  Choose one ERP benefit such as shared data, faster process flow, management visibility, reduced duplicate entry, better inventory accuracy, or integrated reporting. Explain:

  + the old fragmented problem;
  + the ERP mechanism that changes it;
  + the Odoo record or connection that demonstrates the mechanism;
  + one metric that could show the benefit.

  Example structure: “A Sales Order creates a linked Delivery and can create an Invoice. This reduces repeated entry of product, quantity, customer, and price. Measure the percentage of invoices requiring manual correction.”

  #include "visuals/02-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:erp-development>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Use those concrete records to explain integration. If a benefit is proposed rather than measured, name the metric and baseline needed to test it. Sharing a customer name alone does not prove the records are actually linked.

  #include "visuals/02-worked-case.typ"

  #v(6pt)
  #strong[Part B --- Team Challenge.]

  Choose one challenge such as data migration, training, change resistance, scope creep, poor process design, weak sponsorship, role/permission design, or excessive customisation. Explain:

  + why it is difficult;
  + which users/processes are affected;
  + what could happen if it is ignored;
  + how the implementation team should reduce the risk.

  #v(6pt)
  #strong[Part C --- Inspect modularity in Odoo.]

  Open the app grid and identify which app owns each of these records: customer, opportunity, quotation, purchase order, receipt, BOM, manufacturing order, delivery, invoice, employee. Then draw arrows showing which records create or feed the next record.

  #keyidea[
    The point is to see modularity without silos. The records live in different apps because the workflows differ, but they remain connected through shared master data and document relationships.
  ]

  #v(6pt)
  #strong[Part D --- Teach the other subgroup.]

  Follow Tutorial 2: explain your selected topic, listen to the other subgroup, take notes, and write the required paragraph demonstrating what you learned.
]

#strong[Chapter connection.] Revisit #link(<ch:erp-development>)[the chapter explanation] and map its states to the steps below.

#include "visuals/02-erp-development-odoo-chapter.typ"

#include "walkthroughs/02-records.typ"

#verification[
  #strong[Explain and extend your result.] Choose one process delay and define a baseline measure, data source and proposed improvement. State what observation would support or contradict the claimed ERP benefit.

  - The chosen benefit names the old problem, the ERP mechanism, an Odoo record that shows it, and one metric.
  - The chosen challenge names who it affects, what happens if it is ignored, and how to reduce the risk.
  - Each of the ten listed records is assigned to the app that owns it, with arrows for the connections between them.
  - The paragraph on the other subgroup’s topic is written in your own words.
]
