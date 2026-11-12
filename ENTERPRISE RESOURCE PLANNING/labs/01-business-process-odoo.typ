#import "/.shared/typst/utp.typ": *
#unit("labs", "01-business-process-odoo")

#labsection(1, label: <sec:lab01>)[Business Process and Odoo Environment Setup]

#labproject[West End Bicycles: map the organisation, then build the ERP foundation][
  #strong[Coverage.] Tutorial 1 + Chapters 1--2. \

  #strong[Core system.] Odoo 19 Community Edition. \

  #strong[Goal.] Connect functional-area theory to a real ERP structure by creating the company, required apps, departments, employees, and operational users.

  #include "visuals/01-flow.typ"

  #labmode[
    The tutorial asks students to identify business functions, discuss cross-functional Sales teams, describe information flow between Sales and Finance, and draw a purchasing process. The Odoo build makes those abstract boxes concrete: departments become records, employees become owners, and later transactions will be assigned to them.
  ]

  #v(6pt)
  #strong[Part A --- Odoo 19 orientation.]

  Use the navigation conventions from the supplied guide:

  - main app grid at the top-left;
  - app-specific menu bar across the top;
  - breadcrumb trail for moving back through linked records;
  - smart buttons for jumping to related documents;
  - new records through #strong[New]; existing records are directly editable;
  - cloud/save indicator for unsaved changes, with auto-save when navigating away.

  #pitfall[
    Older Odoo tutorials may refer to a separate Edit button or the old “Storable Product” type. The supplied Odoo 19 guide states that physical stock items use #strong[Product Type = Goods] plus #strong[Track Inventory].
  ]

  #include "visuals/01-trace.typ"

  #strong[Follow the supplied implementation.] Employee identity, reporting structure and login permission are distinct records or settings. Reuse the provided account instead of creating a duplicate person. Capture the fields that prove the relationship, not only a menu screenshot.

  #include "visuals/01-worked-case.typ"

  #v(6pt)
  #strong[Part B --- Create or access the database.]

  For a local Community installation, use the Database Manager route described in the guide and create a database such as `west_end_bicycles`. Use Malaysia as country so the company context matches the supplied build. If the class deployment is already provisioned, use the assigned database instead.

  #v(6pt)
  #strong[Part C --- Install the course apps.]

  Install or confirm these eight apps:

  #utptable[
    #tabularx(
      columns: (22%, 1fr),
      styles: (navy-bold,),
      header: ([App], [Role in the course]),
      [Contacts], [Shared customer and vendor records.],
      [CRM], [Opportunities and pipeline.],
      [Employees], [Departments, people, managers, and organisation structure.],
      [Inventory], [Receipts, deliveries, and on-hand stock.],
      [Invoicing], [Customer invoices and payments in the Community workflow.],
      [Manufacturing], [BOMs and Manufacturing Orders.],
      [Purchase], [RFQs, Purchase Orders, and vendor receipts.],
      [Sales], [Quotations and Sales Orders.],
    )
  ]

  #v(6pt)
  #strong[Part D --- Create the company and organisation.]

  Set the company to #strong[West End Bicycles], Ipoh, Perak, Malaysia. Then create four departments:

  - Sales and Marketing;
  - Accounting and Finance;
  - Supply Chain;
  - Human Resources.

  Add the sample employees from the supplied guide and set department heads. At minimum, ensure Sales Manager, Purchasing Officer, Production Planner, Accountant/Finance role, and HR Officer are present.

  #v(6pt)
  #strong[Part E --- Create operational users.]

  The guide distinguishes HR employee records from login users. Create and link user accounts for the operational roles needed later so they can appear in fields such as Salesperson, Buyer, and Responsible.

  #v(6pt)
  #strong[Part F --- Answer the Tutorial 1 concept questions.]

  Using West End Bicycles, prepare:

  + at least three business functions for each of the four functional areas;
  + a reasoned choice about whether the customer-order Sales team should include only Sales/Marketing staff or cross-functional members;
  + a description of information flowing between Marketing/Sales and Accounting/Finance;
  + a business-process diagram for ordering 1,000 bicycles from a supplier.

  #tryit[
    For Question 3, do not write only “Sales sends order data to Finance.” Include the reverse flow too: customer credit/payment status and invoice/payment information must return to Sales so the customer can receive an accurate answer.
  ]

  #v(6pt)
  #strong[Evidence to capture.]

  - installed-apps screen;
  - completed company profile;
  - departments view with managers;
  - one organisation-chart view;
  - user list showing the operational logins.
]

#include "walkthroughs/01-records.typ"

#verification[
  #strong[Explain and extend your result.] Trace one employee to department and user account. Demonstrate the intended user’s access using the permitted classroom account and record which business task the assigned role supports.

  - The database runs Odoo 19 Community with the company set to West End Bicycles, Ipoh, Malaysia.
  - All eight course apps are installed.
  - The four departments exist with their heads, and the sample employees are assigned to them.
  - The operational roles have linked login users, so they can appear as Salesperson, Buyer, and Responsible.
  - Your process diagram shows the flow back to Sales as well as the flow from Sales to Finance.
]
