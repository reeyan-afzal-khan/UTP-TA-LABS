#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-process-modeling-implementation")

= Process Modeling, Process Improvement, and ERP Implementation <ch:process-modeling>

#chapterguide[You should understand end-to-end business processes and the implementation challenges introduced earlier.][draw basic flowcharts and swimlane diagrams, use process models to expose hand-offs and delays, distinguish current-state from future-state design, and explain the main phases and change-management needs of an ERP implementation.]

#sourcebasis[
  This chapter follows the process-modelling part of Tutorial 8 and Chapter 7 of the textbook. It also supports Tutorial 2 by expanding the implementation and change-management concepts behind ERP benefits and challenges.
]

== Why model a process before changing it

A process model turns a verbal description into a visible sequence of events, decisions, responsibilities, and hand-offs. This is useful because many ERP problems are not obvious until the process is drawn.

A model can reveal:

- repeated data entry;
- unnecessary approvals;
- unclear ownership;
- long queues or waiting points;
- hand-offs between departments;
- missing decision rules;
- steps that exist only because old systems were disconnected.

== Basic flowchart symbols

The textbook introduces flowcharts as a simple way to represent a process from beginning to end. For this course, four symbol roles are enough for most tutorial work.

#utptable[
  #tabularx(
    columns: (22%, 26%, 1fr),
    styles: (navy-bold,),
    header: ([Symbol role], [Typical shape], [Meaning]),
    [Start / end], [Rounded terminator], [Boundary of the process.],
    [Activity], [Rectangle], [Work performed, such as “Screen resumes.”],
    [Decision], [Diamond], [Branch based on a condition, such as “Candidate suitable?”],
    [Flow], [Arrow], [Direction and sequence of the process.],
  )
]

The most important rule is semantic clarity: every activity should use a verb and describe one meaningful piece of work.

== Swimlane diagrams add responsibility

A #term[swimlane] or deployment flowchart adds lanes for actors, departments, or roles. This makes cross-functional hand-offs explicit.

#utpfig([A swimlane diagram for recruitment. Each lane is an actor, so every arrow that crosses a lane boundary is a hand-off of responsibility.], label: <fig:swimlane-recruitment>)[
  #canvas({
    let act = (draw: blue, fill: pale-blue, rounded: 1.5mm, min-width: 3, min-height: 0.72, align: center, font: font("script", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    rectangle((0, 0), (14, 5.4), draw: mix(muted, 55%))
    connect((0, 3.6), (14, 3.6), draw: mix(muted, 55%))
    connect((0, 1.8), (14, 1.8), draw: mix(muted, 55%))
    node((0.2, 4.9), [Hiring Manager], anchor: "west", font: font("script", weight: "bold", fill: navy))
    node((0.2, 3.1), [Human Resources], anchor: "west", font: font("script", weight: "bold", fill: navy))
    node((0.2, 1.3), [Candidate], anchor: "west", font: font("script", weight: "bold", fill: navy))
    node((4.1, 4.5), [Submit hiring request], name: "a", ..act)
    node((7.2, 2.7), [Prepare and publish vacancy], name: "b", ..act)
    node((10.4, 0.9), [Apply / provide evidence], name: "c", ..act)
    node((12.5, 2.7), [Screen and schedule], name: "d", ..act)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
  })
]

A normal flowchart answers “What happens next?” A swimlane also answers “Who is responsible when it happens?”

== Current-state and future-state models

For ERP implementation, teams often need two versions:

/ As-is model: How the process operates today, including manual workarounds, delays, and system boundaries.
/ To-be model: How the process should operate after redesign and ERP configuration.

The goal is not simply to redraw the same process with Odoo or another ERP logo. The to-be process should remove waste where possible.

#pitfall[
  If an old process requires a clerk to retype a sales order into Finance because the systems are separate, reproducing that same step after ERP implementation defeats the purpose of integration.
]

== Process improvement before automation

A useful improvement sequence is:

+ identify the customer or internal user and the process outcome they value;
+ map the current process;
+ measure delay, rework, error, cost, and hand-offs;
+ challenge steps that do not create value or control risk;
+ redesign the process;
+ configure the ERP workflow to support the redesigned process;
+ measure the outcome after implementation.

This prevents #emph[automating waste].

== ERP implementation as a staged project

The textbook presents a five-phase implementation roadmap associated with SAP Solution Manager. The names are useful even when another ERP product is used because they describe general project logic.

#utpfig([The five-phase ERP implementation roadmap the textbook associates with SAP Solution Manager. The phase names describe general project logic and apply to other ERP products too.], label: <fig:implementation-roadmap>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.55, min-height: 1.05, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [1\. Project \
  Preparation], name: "p1", ..box-style)
    node(right-of("p1", 0.28), [2\. Business \
  Blueprint], name: "p2", ..box-style)
    node(right-of("p2", 0.28), [3\. Realization], name: "p3", ..box-style)
    node(right-of("p3", 0.28), [4\. Final \
  Preparation], name: "p4", ..box-style)
    node(right-of("p4", 0.28), [5\. Go Live \
  & Support], name: "p5", ..box-style)
    connect("p1", "p2", ..arr)
    connect("p2", "p3", ..arr)
    connect("p3", "p4", ..arr)
    connect("p4", "p5", ..arr)
  })
]

=== Project Preparation

Define scope, objectives, governance, team, technical landscape, high-level schedule, and success measures.

=== Business Blueprint

Document business requirements and the intended process design. Process mapping is critical here because the team must agree how the company will operate in the ERP system.

=== Realization

Configure the ERP system, build required interfaces or controlled extensions, prepare data, and develop supporting materials.

=== Final Preparation

Test critical processes and transaction volume, prepare support, migrate data, train users, and set the go-live date.

=== Go Live and Support

Move into production, stabilise the system, resolve issues, and continue improvement.

== Scope creep

#term[Scope creep] is the unplanned expansion of project goals. It increases time, cost, complexity, and risk. The most dangerous form occurs when the project adds new features faster than it completes testing, training, and process readiness.

A practical defence is a change-control rule: every new requirement should state the business value, impact, cost, owner, and whether it is essential for go-live or can wait for a later phase.

== Organisational change management

ERP implementation changes roles, responsibilities, information visibility, and sometimes staffing. The textbook emphasises that people often resist being changed, especially when they feel the project is imposed on them.

Good #term[organisational change management (OCM)] includes:

- involving process owners and end users in design;
- communicating why the process is changing;
- explaining role and responsibility changes;
- training for both system use and new business procedures;
- providing support during the transition;
- measuring adoption rather than assuming it.

#keyidea[
  ERP implementation succeeds when the organisation changes how work is done, not when the technical team merely installs software. Process ownership, training, testing, data quality, and executive sponsorship are therefore core implementation work.
]

== The ABC recruitment process as a modelling exercise

Tutorial 8 is ideal for a swimlane because responsibility moves among the hiring manager, HR, candidate, interviewers, and approval stakeholders. The model should expose waiting points such as scheduling interviews, collecting feedback, and conducting checks.

A future-state information system could reduce waiting by making status, documents, interview feedback, and ownership visible in one workflow.

#tryit[
  Draw the ABC recruitment process twice: first as a simple flowchart and then as a swimlane. In the swimlane version, mark every arrow that crosses a lane. Those crossings are the hand-offs most likely to suffer from delay or missing information.
]

#quickcheck[
  + What extra information does a swimlane provide compared with a basic flowchart?
  + Why is an as-is process model necessary before configuring an ERP workflow?
  + What is scope creep and why can it indirectly reduce testing or training quality?
]
