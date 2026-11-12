#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-human-resources")

= Human Resources Processes and Recruitment <ch:hr>

#chapterguide[You should understand master data, process ownership, and why cross-functional information must be current.][describe an end-to-end recruitment process, identify information problems that harm candidate experience, explain how ERP-supported HR records improve coordination, and distinguish an employee record from an operational system user.]

#sourcebasis[
  This chapter follows Tutorial 8 and Chapter 6 of the textbook. The tutorial uses the ABC Company recruitment scenario and asks students to identify information-system problems and draw both a flowchart and a swimlane diagram. The Odoo guide adds department, employee, manager, and user-role setup for West End Bicycles.
]

== Human Resources is a business process partner

HR is often introduced through administrative tasks, but its information flows support every functional area. Departments need people with the right skills; HR needs accurate vacancy, job, salary, and reporting information from those departments.

Typical HR processes include recruiting, hiring, onboarding, training, compensation administration, benefits, performance management, compliance, and workforce planning.

== Recruitment as an end-to-end process

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

#utpfig([The eleven events of the ABC Company scenario, each drawn in the lane of whoever performs it. The value of the lane form is in the crossings: every arrow that changes column is a handover, and every handover is a place where a paper process loses a form, stalls a decision, or leaves the candidate without news.], label: <fig:hr-swimlane>)[
  #canvas({
    let lane = (font: font("small", weight: "bold", fill: white), align: center)
    let act = (draw: blue, fill: pale-blue, rounded: 1.5mm, text-width: 3.1, min-height: 0.82, align: center, font: font("script", fill: navy), inner-sep: 1.9925pt)
    let hr = (..act, fill: pale-teal, draw: teal)
    let cd = (..act, fill: pale-orange, draw: orange)
    let pn = (..act, fill: white, draw: navy)
    let hand = (line-width: widths.semithick, draw: muted, end: tip("Stealth", length: 2mm, line: widths.semithick))
    let num = (font: font("tiny", weight: "bold", fill: muted),)
    for (t, x) in (("Department / manager", 0), ("Human Resources", 4), ("Candidate", 8), ("Selection panel", 12)) {
      rectangle((x - 1.65, 0.42), (x + 1.65, 1.12), rounded: 1.2mm, fill: navy, draw: none)
      node((x, 0.77), [#t], ..lane, text-width: 3.1)
    }
    for x in range(2, 11, step: 4) {
      connect((x, 0.3), (x, -10.15), dash: "dashed", draw: mix(muted, 35%))
    }
    node((0, -0.35), [identify a staffing need], name: "s1", ..act)
    node((0, -1.32), [raise a hiring request with requirements], name: "s2", ..act)
    node((4, -2.29), [perform job analysis, prepare the posting], name: "s3", ..hr)
    node((4, -3.26), [advertise the vacancy], name: "s4", ..hr)
    node((8, -4.23), [submit an application], name: "s5", ..cd)
    node((4, -5.2), [receive and screen applications], name: "s6", ..hr)
    node((12, -6.17), [interview the shortlist], name: "s7", ..pn)
    node((8, -7.14), [complete the skills assessment], name: "s8", ..cd)
    node((4, -8.11), [complete references and background checks], name: "s9", ..hr)
    node((12, -9.08), [review the evidence, select a candidate], name: "s10", ..pn)
    node((4, -10.05), [issue the offer: salary, benefits, start date], name: "s11", ..hr)
    for (a, b) in (("s1", "s2"), ("s2", "s3"), ("s3", "s4"), ("s4", "s5"), ("s5", "s6"), ("s6", "s7"), ("s7", "s8"), ("s8", "s9"), ("s9", "s10"), ("s10", "s11")) {
      connect(a, b, ..hand)
    }
    for (n, s) in ((1, "s1"), (2, "s2"), (3, "s3"), (4, "s4"), (5, "s5"), (6, "s6"), (7, "s7"), (8, "s8"), (9, "s9"), (10, "s10"), (11, "s11")) {
      node((rel: (-0.1, 0), to: s + ".west"), [#n], ..num, anchor: "east")
    }
  })
]

The textbook’s Fitter Snacker example shows how a paper-based version of this process can fail: forms may be inconsistent or lost, applications can be misfiled, reviews happen sequentially because paper copies must circulate, interview scheduling is slow, and promising candidates can accept another offer while the company is still coordinating internally.

== Candidate experience is an information-flow problem

Tutorial 8 asks which problems could create a negative candidate impression. Useful categories include:

#utptable[
  #tabularx(
    columns: (24%, 31%, 1fr),
    styles: (navy-bold,),
    header: ([Problem], [What the candidate experiences], [Information-system response]),
    [Slow scheduling], [Long silence between stages], [Shared calendars, workflow tasks, status tracking, reminders],
    [Lost or duplicated documents], [Candidate asked to resend information], [Central applicant record and document control],
    [Inconsistent requirements], [Different interviewers describe the job differently], [Controlled job description and competency profile],
    [Missing feedback], [Repeated delays while decision-makers chase comments], [Structured evaluation forms and completion status],
    [Poor communication], [Candidate does not know whether the application is active], [Standardised stage/status communication],
    [Incorrect offer details], [Salary, role, or start date conflicts], [Approved master data and controlled offer workflow],
  )
]

#keyidea[
  A candidate experiences the organisation as one process. They do not care that scheduling belongs to HR, technical evaluation belongs to the hiring manager, and approval belongs to senior management. ERP/process integration should hide that internal fragmentation from the candidate.
]

== Job information should be treated as controlled data

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

== The “dream job” activity as a data-design exercise

Tutorial 8 asks students to choose a desired role and identify the information needed to judge candidates. The point is not merely to list attractive skills. A good answer distinguishes:

/ Evidence: Degree, certifications, portfolio, previous roles, project outcomes, technical tests, references.
/ Competencies: Technical knowledge, communication, problem solving, teamwork, leadership, domain knowledge.
/ Constraints: Work authorisation, location, availability, salary expectations, required schedule.
/ Selection criteria: Which attributes are essential, which are preferred, and how each is evaluated.

That structure turns recruitment into a repeatable business process rather than an informal impression.

== Employee master data and organisational structure

Once someone is hired, HR records become master data reused throughout the organisation: employee identity, department, manager, role, work contact information, and possibly compensation or training information subject to authorisation.

#applicationbox[
  The West End Bicycles Odoo guide creates four departments:

  - Sales and Marketing;
  - Accounting and Finance;
  - Supply Chain;
  - Human Resources.

  It then creates employees such as Sales Manager, Purchasing Officer, Production Planner, Accountant, and HR Officer, assigns managers, and builds a simple organisation chart.
]

== Employee record versus system user

The Odoo guide makes an important systems distinction: an #term[Employee] record and a #term[User] login are different objects.

An employee record describes a person in the organisation. A user account gives the person authenticated access and permissions in Odoo. Operational document fields such as Salesperson, Buyer, and Responsible may reference users because the system needs to know who can own or act on a transaction.

The guide therefore creates user accounts for selected operational roles and links them back to the corresponding employee records.

#utptable[
  #tabularx(
    columns: (24%, 26%, 1fr),
    styles: (navy-bold,),
    header: ([Role], [Operational ownership], [Example in the Odoo guide]),
    [Sales Manager], [Salesperson / team leadership], [CRM opportunity, quotation, Sales Order],
    [Purchasing Officer], [Buyer], [RFQ and Purchase Order],
    [Production Planner], [Responsible], [Manufacturing Order],
    [Accountant], [Finance activity], [Customer payment and invoice follow-up],
  )
]

== HR data and access control

HR information can be sensitive. ERP integration must therefore combine availability with authorisation. A production manager may need an employee’s skills or availability without needing access to private compensation or personal information.

This is a good example of why “one shared database” does not mean “one unrestricted database.”

#pitfall[
  Do not solve HR integration by giving everyone broad access. A well-designed ERP system shares the right data with the right role while preserving confidentiality and accountability.
]

== From recruitment to the rest of ERP

After hiring, HR information supports other processes:

- training records determine whether staff are qualified for specialised work;
- department and manager relationships support approvals and responsibility;
- workforce forecasts support production and sales plans;
- payroll and benefit expenses feed financial reporting;
- access rights connect employee responsibilities to system permissions.

#tryit[
  Choose one role from the Tutorial 8 “dream job” activity. Create a compact selection matrix with five criteria, the evidence used to judge each criterion, and an importance rating. Then identify which fields belong in long-term employee master data and which belong only in the recruitment transaction.
]

#quickcheck[
  + Name three ways a paper-based recruitment process can lose a strong candidate.
  + Why are an Odoo Employee and an Odoo User conceptually different?
  + Give one example of HR information needed by another functional area and one example of information HR needs from that area.
]
