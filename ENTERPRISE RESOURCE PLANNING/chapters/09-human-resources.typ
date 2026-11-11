#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-human-resources")


#heading(level: 1)[Human Resources Processes and Recruitment]
 <ch:hr>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand master data, process ownership, and why cross-functional information must be current.

*By the end, you can:* describe an end-to-end recruitment process, identify information problems that harm candidate experience, explain how ERP-supported HR records improve coordination, and distinguish an employee record from an operational system user.]

#callout("sourcebasis", title: [Source basis])[This chapter follows Tutorial 8 and Chapter 6 of the textbook. The tutorial uses the ABC Company recruitment scenario and asks students to identify information-system problems and draw both a flowchart and a swimlane diagram. The Odoo guide adds department, employee, manager, and user-role setup for West End Bicycles.]


#heading(level: 2)[Human Resources is a business process partner]


HR is often introduced through administrative tasks, but its information flows support every functional area. Departments need people with the right skills; HR needs accurate vacancy, job, salary, and reporting information from those departments.

Typical HR processes include recruiting, hiring, onboarding, training, compensation administration, benefits, performance management, compliance, and workforce planning.


#heading(level: 2)[Recruitment as an end-to-end process]


The ABC Company scenario in Tutorial 8 can be expressed as a sequence of business events:

+ a department identifies a staffing need;

+ the manager submits a hiring request and position requirements;

+ HR performs job analysis and prepares the posting;

+ the vacancy is advertised;

+ applications are received and screened;

+ shortlisted candidates are interviewed;

+ top candidates complete a skills assessment;

+ references and background checks are completed;

+ stakeholders review the evidence and select a candidate;

+ HR issues the offer with salary, benefits, and start date.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/830bb8d6179eeb1c.svg")], caption: [The eleven events of the ABC Company scenario, each drawn in the lane of whoever performs it. The value of the lane form is in the crossings: every arrow that changes column is a handover, and every handover is a place where a paper process loses a form, stalls a decision, or leaves the candidate without news.]) <fig:hr-swimlane>

The textbook's Fitter Snacker example shows how a paper-based version of this process can fail: forms may be inconsistent or lost, applications can be misfiled, reviews happen sequentially because paper copies must circulate, interview scheduling is slow, and promising candidates can accept another offer while the company is still coordinating internally.


#heading(level: 2)[Candidate experience is an information-flow problem]


Tutorial 8 asks which problems could create a negative candidate impression. Useful categories include:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Problem], [What the candidate experiences], [Information-system response],),
    table.hline(),
    [Slow scheduling], [Long silence between stages], [Shared calendars, workflow tasks, status tracking, reminders],
    [Lost or duplicated documents], [Candidate asked to resend information], [Central applicant record and document control],
    [Inconsistent requirements], [Different interviewers describe the job differently], [Controlled job description and competency profile],
    [Missing feedback], [Repeated delays while decision-makers chase comments], [Structured evaluation forms and completion status],
    [Poor communication], [Candidate does not know whether the application is active], [Standardised stage/status communication],
    [Incorrect offer details], [Salary, role, or start date conflicts], [Approved master data and controlled offer workflow],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[A candidate experiences the organisation as one process. They do not care that scheduling belongs to HR, technical evaluation belongs to the hiring manager, and approval belongs to senior management. ERP/process integration should hide that internal fragmentation from the candidate.]


#heading(level: 2)[Job information should be treated as controlled data]


A job vacancy should not be a hurried free-text note. The organisation benefits from maintaining structured information such as:

- job title and department;

- reporting line;

- responsibilities;

- required and preferred skills;

- qualifications and experience;

- employment type;

- location;

- compensation range or grade where appropriate;

- required approvals;

- planned start date.

This makes candidate screening more consistent and later supports onboarding, training, performance evaluation, and workforce planning.


#heading(level: 2)[The "dream job" activity as a data-design exercise]


Tutorial 8 asks students to choose a desired role and identify the information needed to judge candidates. The point is not merely to list attractive skills. A good answer distinguishes:

/ Evidence: #block[
Degree, certifications, portfolio, previous roles, project outcomes, technical tests, references.
]

/ Competencies: #block[
Technical knowledge, communication, problem solving, teamwork, leadership, domain knowledge.
]

/ Constraints: #block[
Work authorisation, location, availability, salary expectations, required schedule.
]

/ Selection criteria: #block[
Which attributes are essential, which are preferred, and how each is evaluated.
]

That structure turns recruitment into a repeatable business process rather than an informal impression.


#heading(level: 2)[Employee master data and organisational structure]


Once someone is hired, HR records become master data reused throughout the organisation: employee identity, department, manager, role, work contact information, and possibly compensation or training information subject to authorisation.

#callout("applicationbox", title: [Application walkthrough])[The West End Bicycles Odoo guide creates four departments:

- Sales and Marketing;

- Accounting and Finance;

- Supply Chain;

- Human Resources.

It then creates employees such as Sales Manager, Purchasing Officer, Production Planner, Accountant, and HR Officer, assigns managers, and builds a simple organisation chart.]


#heading(level: 2)[Employee record versus system user]


The Odoo guide makes an important systems distinction: an #strong[Employee] record and a #strong[User] login are different objects.

An employee record describes a person in the organisation. A user account gives the person authenticated access and permissions in Odoo. Operational document fields such as Salesperson, Buyer, and Responsible may reference users because the system needs to know who can own or act on a transaction.

The guide therefore creates user accounts for selected operational roles and links them back to the corresponding employee records.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Role], [Operational ownership], [Example in the Odoo guide],),
    table.hline(),
    [Sales Manager], [Salesperson / team leadership], [CRM opportunity, quotation, Sales Order],
    [Purchasing Officer], [Buyer], [RFQ and Purchase Order],
    [Production Planner], [Responsible], [Manufacturing Order],
    [Accountant], [Finance activity], [Customer payment and invoice follow-up],
  )]
  , kind: table
  )


#heading(level: 2)[HR data and access control]


HR information can be sensitive. ERP integration must therefore combine availability with authorisation. A production manager may need an employee's skills or availability without needing access to private compensation or personal information.

This is a good example of why "one shared database" does not mean "one unrestricted database."

#callout("pitfall", title: [Common mistake])[Do not solve HR integration by giving everyone broad access. A well-designed ERP system shares the right data with the right role while preserving confidentiality and accountability.]


#heading(level: 2)[From recruitment to the rest of ERP]


After hiring, HR information supports other processes:

- training records determine whether staff are qualified for specialised work;

- department and manager relationships support approvals and responsibility;

- workforce forecasts support production and sales plans;

- payroll and benefit expenses feed financial reporting;

- access rights connect employee responsibilities to system permissions.

#callout("tryit", title: [Try it yourself])[Choose one role from the Tutorial 8 "dream job" activity. Create a compact selection matrix with five criteria, the evidence used to judge each criterion, and an importance rating. Then identify which fields belong in long-term employee master data and which belong only in the recruitment transaction.]

#callout("quickcheck", title: [Check your understanding])[+ Name three ways a paper-based recruitment process can lose a strong candidate.

+ Why are an Odoo Employee and an Odoo User conceptually different?

+ Give one example of HR information needed by another functional area and one example of information HR needs from that area.]
