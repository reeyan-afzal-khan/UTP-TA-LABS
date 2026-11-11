#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-process-modeling-implementation")


#heading(level: 1)[Process Modeling, Process Improvement, and ERP Implementation]
 <ch:process-modeling>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* You should understand end-to-end business processes and the implementation challenges introduced earlier.

*By the end, you can:* draw basic flowcharts and swimlane diagrams, use process models to expose hand-offs and delays, distinguish current-state from future-state design, and explain the main phases and change-management needs of an ERP implementation.]

#callout("sourcebasis", title: [Source basis])[This chapter follows the process-modelling part of Tutorial 8 and Chapter 7 of the textbook. It also supports Tutorial 2 by expanding the implementation and change-management concepts behind ERP benefits and challenges.]


#heading(level: 2)[Why model a process before changing it]


A process model turns a verbal description into a visible sequence of events, decisions, responsibilities, and hand-offs. This is useful because many ERP problems are not obvious until the process is drawn.

A model can reveal:

- repeated data entry;

- unnecessary approvals;

- unclear ownership;

- long queues or waiting points;

- hand-offs between departments;

- missing decision rules;

- steps that exist only because old systems were disconnected.


#heading(level: 2)[Basic flowchart symbols]


The textbook introduces flowcharts as a simple way to represent a process from beginning to end. For this course, four symbol roles are enough for most tutorial work.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Symbol role], [Typical shape], [Meaning],),
    table.hline(),
    [Start / end], [Rounded terminator], [Boundary of the process.],
    [Activity], [Rectangle], [Work performed, such as "Screen resumes."],
    [Decision], [Diamond], [Branch based on a condition, such as "Candidate suitable?"],
    [Flow], [Arrow], [Direction and sequence of the process.],
  )]
  , kind: table
  )

The most important rule is semantic clarity: every activity should use a verb and describe one meaningful piece of work.


#heading(level: 2)[Swimlane diagrams add responsibility]


A #strong[swimlane] or deployment flowchart adds lanes for actors, departments, or roles. This makes cross-functional hand-offs explicit.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/1a367f4a5b602c93.svg")], caption: [A swimlane diagram for recruitment. Each lane is an actor, so every arrow that crosses a lane boundary is a hand-off of responsibility.]) <fig:swimlane-recruitment>

A normal flowchart answers "What happens next?" A swimlane also answers "Who is responsible when it happens?"


#heading(level: 2)[Current-state and future-state models]


For ERP implementation, teams often need two versions:

/ As-is model: #block[
How the process operates today, including manual workarounds, delays, and system boundaries.
]

/ To-be model: #block[
How the process should operate after redesign and ERP configuration.
]

The goal is not simply to redraw the same process with Odoo or another ERP logo. The to-be process should remove waste where possible.

#callout("pitfall", title: [Common mistake])[If an old process requires a clerk to retype a sales order into Finance because the systems are separate, reproducing that same step after ERP implementation defeats the purpose of integration.]


#heading(level: 2)[Process improvement before automation]


A useful improvement sequence is:

+ identify the customer or internal user and the process outcome they value;

+ map the current process;

+ measure delay, rework, error, cost, and hand-offs;

+ challenge steps that do not create value or control risk;

+ redesign the process;

+ configure the ERP workflow to support the redesigned process;

+ measure the outcome after implementation.

This prevents #emph[automating waste].


#heading(level: 2)[ERP implementation as a staged project]


The textbook presents a five-phase implementation roadmap associated with SAP Solution Manager. The names are useful even when another ERP product is used because they describe general project logic.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ENTERPRISE RESOURCE PLANNING/figures/diagrams/5a33aaa082dce0dd.svg")], caption: [The five-phase ERP implementation roadmap the textbook associates with SAP Solution Manager. The phase names describe general project logic and apply to other ERP products too.]) <fig:implementation-roadmap>


#heading(level: 3)[Project Preparation]
 Define scope, objectives, governance, team, technical landscape, high-level schedule, and success measures.


#heading(level: 3)[Business Blueprint]
 Document business requirements and the intended process design. Process mapping is critical here because the team must agree how the company will operate in the ERP system.


#heading(level: 3)[Realization]
 Configure the ERP system, build required interfaces or controlled extensions, prepare data, and develop supporting materials.


#heading(level: 3)[Final Preparation]
 Test critical processes and transaction volume, prepare support, migrate data, train users, and set the go-live date.


#heading(level: 3)[Go Live and Support]
 Move into production, stabilise the system, resolve issues, and continue improvement.


#heading(level: 2)[Scope creep]


#strong[Scope creep] is the unplanned expansion of project goals. It increases time, cost, complexity, and risk. The most dangerous form occurs when the project adds new features faster than it completes testing, training, and process readiness.

A practical defence is a change-control rule: every new requirement should state the business value, impact, cost, owner, and whether it is essential for go-live or can wait for a later phase.


#heading(level: 2)[Organisational change management]


ERP implementation changes roles, responsibilities, information visibility, and sometimes staffing. The textbook emphasises that people often resist being changed, especially when they feel the project is imposed on them.

Good #strong[organisational change management (OCM)] includes:

- involving process owners and end users in design;

- communicating why the process is changing;

- explaining role and responsibility changes;

- training for both system use and new business procedures;

- providing support during the transition;

- measuring adoption rather than assuming it.

#callout("keyidea", title: [Key idea])[ERP implementation succeeds when the organisation changes how work is done, not when the technical team merely installs software. Process ownership, training, testing, data quality, and executive sponsorship are therefore core implementation work.]


#heading(level: 2)[The ABC recruitment process as a modelling exercise]


Tutorial 8 is ideal for a swimlane because responsibility moves among the hiring manager, HR, candidate, interviewers, and approval stakeholders. The model should expose waiting points such as scheduling interviews, collecting feedback, and conducting checks.

A future-state information system could reduce waiting by making status, documents, interview feedback, and ownership visible in one workflow.

#callout("tryit", title: [Try it yourself])[Draw the ABC recruitment process twice: first as a simple flowchart and then as a swimlane. In the swimlane version, mark every arrow that crosses a lane. Those crossings are the hand-offs most likely to suffer from delay or missing information.]

#callout("quickcheck", title: [Check your understanding])[+ What extra information does a swimlane provide compared with a basic flowchart?

+ Why is an as-is process model necessary before configuring an ERP workflow?

+ What is scope creep and why can it indirectly reduce testing or training quality?]
