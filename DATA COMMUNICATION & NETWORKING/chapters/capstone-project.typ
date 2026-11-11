#import "/.shared/typst/utp.typ": *
#unit("chapters", "capstone-project")


#heading(level: 1, numbering: none)[Group Project: Integrated eNSP Network]


#callout("sourcebasis", title: [Source basis])[Based on #strong[Group Project - Template DCN.ppt].]


#heading(level: 2, numbering: none)[What the project asks you to demonstrate]
 Build a client-server scenario in eNSP and explain it through #strong[two or three OSI/TCP-IP layers].

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Layer/theme], [Project task from the supplied template],),
    table.hline(),
    [Application], [Configure a client-server service in eNSP.],
    [Transport], [Demonstrate TCP connection setup, rate limiting, packet loss, and retransmission.],
    [Network], [Build 2--3 routers with multiple hosts, IPv4 addressing, static routing, and packet forwarding.],
    [Data Link (optional)], [Explain how frames cross the selected physical or logical link.],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[A build sequence that reuses the lab workflow]


+ Draw the topology and write the addressing plan before entering any CLI commands.

+ Configure host/router interfaces and prove every directly connected link.

+ Add static routes and verify each remote destination in the routing table.

+ Prove end-to-end forwarding before adding the client-server service.

+ Add the chosen application/TCP behavior and collect packet or command evidence.

+ If using Data Link, show its effect on the end-to-end flow.

+ Label each readable screenshot and tie it to a technical claim.


#heading(level: 2, numbering: none)[Recommended evidence matrix]
 #figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Claim in presentation/report], [Strong evidence],),
    table.hline(),
    ["The topology is addressed correctly"], [Addressing table plus `display ip interface brief`/host IP configuration.],
    ["Routers can forward between networks"], [Routing-table entries and successful end-to-end ping.],
    ["TCP provides reliable transfer"], [Capture of connection setup and retransmission after loss.],
    ["Rate limiting affects the flow"], [Before/after measurements tied to the configured limit.],
    ["The design uses a specific layer/protocol"], [Configuration excerpt plus a packet/state observation that proves the protocol is active.],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Deliverables]
 The project has three outputs:

- #strong[eNSP demo:] a working network explained while it runs.

- #strong[Presentation:] design, key configuration, protocol choices, and evidence.

- #strong[Report:] a record of the implementation. The source states Week 12 submission through uLearn and to the lab instructor.


#heading(level: 2, numbering: none)[Evaluation criteria]
 The rubric weights are: #figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Criterion], [Weight],),
    table.hline(),
    [Design & Implementation], [40%],
    [Functionality & Demo], [30%],
    [Presentation & Explanation], [20%],
    [Report Quality], [10%],
  )]
  , kind: table
  ) Bands are Excellent (90--100), Good (75--89), Satisfactory (60--74), and Needs Improvement (\<60).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/project-evaluation.png", width: 90%)], caption: [The evaluation-criteria table from the supplied project template, summarised in the table above.]) <fig:project-evaluation>

#callout("keyidea", title: [Key idea])[Pair each claim with evidence: interface state, a route, a packet trace, an application result, or a connectivity test.]
