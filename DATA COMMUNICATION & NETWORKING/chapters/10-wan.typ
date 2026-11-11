#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-wan")


#heading(level: 1)[WAN Links: HDLC, PPP, PAP, and CHAP]
<ch:wan> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Routing, OSPF, IPv4 interface addressing, and basic AAA concepts from earlier labs.

*By the end, you can:* Configure serial addressing, apply HDLC and PPP encapsulation, identify a DCE and set its baud rate, run OSPF across WAN links, configure PAP and CHAP authentication, and use PPP debugging to investigate negotiation.]


#heading(level: 2)[Scenario: connect headquarters and branches]
 R2 represents headquarters and R1/R3 the branches. Two serial links share one routing domain; the lab moves from HDLC to PPP, then adds PAP and CHAP.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/wan-topology.png", width: 90%)], caption: [The serial WAN topology from the supplied Lab~9 slide. R2 is headquarters; R1 and R3 are the branches.]) <fig:wan-topology>

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Link], [Interfaces], [Network], [Addressing shown],),
    table.hline(),
    [R1--R2], [S1/0/0 -- S1/0/0], [`10.0.12.0/24`], [R1 .1, R2 .2],
    [R2--R3], [S2/0/0 -- S2/0/0], [`10.0.23.0/24`], [R2 .2, R3 .3],
  )]
  , kind: table
  )


#heading(level: 2)[HDLC and PPP in the source material]
 HDLC and PPP are serial link encapsulations that must match at both ends. PPP also supports network-layer negotiation and authentication through PAP or CHAP.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Feature], [HDLC portion], [PPP portion],),
    table.hline(),
    [Role in lab], [Establish the serial Layer-2 link], [Replace HDLC and add authentication capability],
    [End agreement], [Both ends use HDLC], [Both ends use PPP],
    [Authentication], [Not used in the HDLC section], [PAP between R1--R2 and CHAP between R2--R3],
  )]
  , kind: table
  )


#heading(level: 2)[Step 1: configure serial IP addressing]
 #code-block("[R1] interface Serial 1/0/0\n[R1-Serial1/0/0] ip address 10.0.12.1 24\n\n[R2] interface Serial 1/0/0\n[R2-Serial1/0/0] ip address 10.0.12.2 24\n[R2] interface Serial 2/0/0\n[R2-Serial2/0/0] ip address 10.0.23.2 24\n\n[R3] interface Serial 2/0/0\n[R3-Serial2/0/0] ip address 10.0.23.3 24", lang: "text")


#heading(level: 2)[Step 2: enable HDLC on both serial links]
 #code-block("[R1] interface Serial 1/0/0\n[R1-Serial1/0/0] link-protocol hdlc\n[R2] interface Serial 1/0/0\n[R2-Serial1/0/0] link-protocol hdlc\n[R2] interface Serial 2/0/0\n[R2-Serial2/0/0] link-protocol hdlc\n[R3] interface Serial 2/0/0\n[R3-Serial2/0/0] link-protocol hdlc", lang: "text") Verify that each serial interface is physically and logically up before adding routing.


#heading(level: 2)[Step 3: run OSPF across the WAN links]
 Advertise both /24 serial networks in area 0. #code-block("[R1] ospf 1\n[R1-ospf-1] area 0\n[R1-ospf-1-area-0.0.0.0] network 10.0.12.0 0.0.0.255\n\n[R2] ospf 1\n[R2-ospf-1] area 0\n[R2-ospf-1-area-0.0.0.0] network 10.0.12.0 0.0.0.255\n[R2-ospf-1-area-0.0.0.0] network 10.0.23.0 0.0.0.255\n\n[R3] ospf 1\n[R3-ospf-1] area 0\n[R3-ospf-1-area-0.0.0.0] network 10.0.23.0 0.0.0.255", lang: "text") After convergence, inspect learned routes and ping from R1 to R3.


#heading(level: 2)[Step 4: identify the DCE and change the clock rate]
 One side of a synchronous serial link provides clocking. Here R1 Serial1/0/0 is the DCE; change its baud rate from 64,000 to 128,000 bit/s.

#callout("vrpbox", title: [])[\<R1\> display interface Serial 1/0/0 #code-block("Serial1/0/0 current state : (*\\higreen{UP}*)\nLine protocol current state : (*\\higreen{UP}*)\nDescription:HUAWEI, AR Series, Serial1/0/0 Interface\nRoute Port,The Maximum Transmit Unit is 1500, Hold timer is 10(sec)\nInternet Address is 10.0.12.1/24\n(*\\hi{Link layer protocol is nonstandard HDLC}*)\nPhysical layer is synchronous, (*\\hi{Baudrate is 64000 bps}*)\n(*\\hi{Interface is DCE}*), Cable type is V35, Clock mode is DCECLK\n    Last 300 seconds input rate 3 bytes/sec 24 bits/sec 0 packets/sec\n    Last 300 seconds output rate 3 bytes/sec 24 bits/sec 0 packets/sec", lang: "text")] three lines answer three different questions. `Link layer protocol` is the encapsulation, and it must match the far end. `Interface is DCE` identifies which router owns the clock. `Baudrate` is the rate you are about to change --- and it is only settable on the line that says DCE.

A synchronous serial link has no separate clock wire, so one end must generate the timing the other end samples against. That end is the DCE. The DTE takes whatever rate it is given, which is why `baudrate` is rejected or ignored on that side.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/3f2ae32ff793de6d.svg")], caption: [Clocking on a synchronous serial link. In eNSP the DCE is the end the cable was dragged #emph[from], and `display interface Serial1/0/0` names it explicitly.]) <fig:dte-dce>

#code-block("[R1] interface Serial 1/0/0\n[R1-Serial1/0/0] baudrate 128000", lang: "text")

#callout("keyidea", title: [Key idea])[Set the baud rate only on the DCE side, identified from the interface output.]


#heading(level: 2)[Step 5: replace HDLC with PPP]


PPP brings a link up in stages, and each stage must finish before the next begins. The verification order used throughout this chapter is simply this diagram read left to right.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/51c7e6e757ed47ef.svg")], caption: [How a PPP link comes up. Authentication sits between link establishment and IP, which is why enabling PAP or CHAP can take down a link whose cabling and addressing never changed.]) <fig:ppp-phases>

Change both ends of each serial link to PPP. #code-block("[R1] interface Serial 1/0/0\n[R1-Serial1/0/0] link-protocol ppp\n[R2] interface Serial 1/0/0\n[R2-Serial1/0/0] link-protocol ppp\n[R2] interface Serial 2/0/0\n[R2-Serial2/0/0] link-protocol ppp\n[R3] interface Serial 2/0/0\n[R3-Serial2/0/0] link-protocol ppp", lang: "text") An encapsulation mismatch leaves the line protocol down; configure both ends before testing.


#heading(level: 2)[Step 6: configure PAP on R1--R2]
 R1 authenticates R2 with PAP. #code-block("[R1] interface Serial 1/0/0\n[R1-Serial1/0/0] ppp authentication-mode pap\n[R1] aaa\n[R1-aaa] local-user huawei password cipher huawei123\n[R1-aaa] local-user huawei service-type ppp\n\n[R2] interface Serial 1/0/0\n[R2-Serial1/0/0] ppp pap local-user huawei password cipher huawei123", lang: "text") Then retest the R1--R2 link.


#heading(level: 2)[Step 7: configure CHAP on R2--R3]
 The source text names R1 here, but its topology and commands identify R3 as the authenticator and R2 as the CHAP peer. The sequence below follows the commands.

#code-block("[R3] interface Serial 2/0/0\n[R3-Serial2/0/0] ppp authentication-mode chap\n[R3] aaa\n[R3-aaa] local-user huawei password cipher huawei123\n[R3-aaa] local-user huawei service-type ppp\n\n[R2] interface Serial 2/0/0\n[R2-Serial2/0/0] ppp chap user huawei\n[R2-Serial2/0/0] ppp chap password cipher huawei123", lang: "text")


#heading(level: 2)[Step 8: observe CHAP negotiation with debugging]


The two schemes differ in a way the debug output makes visible. PAP sends the password across the link; CHAP never does, sending instead a hash of a challenge the authenticator chose. That is why the CHAP debug shows a Challenge/Response/Success triple rather than a single request.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/b7f1278015097f26.svg")], caption: [PAP's two messages against CHAP's three. The password crosses the link in the left-hand exchange and never crosses it in the right-hand one.]) <fig:pap-chap>

#callout("keyidea", title: [Key idea])[The direction of the first message tells you which router is the authenticator. In PAP the peer speaks first; in CHAP the authenticator does. Reading that from a debug trace identifies immediately which end holds the wrong configuration.]

Cycle the serial interface and enable PPP CHAP debugging to regenerate negotiation messages and locate authentication failure.

#callout("vrpbox", title: [])[\<R2\> terminal debugging + debugging ppp chap all #code-block("PPP State Change:\n  Serial2/0/0 CHAP : ListenChallenge --> (*\\hi{SendResponse}*)\nPPP Packet:\n  Serial2/0/0 Input  CHAP(c223) Pkt, Len 20\n  State SendResponse, code (*\\hi{Challenge(01)}*), id 1, len 16\n  Message: Welcome to ...\nPPP Packet:\n  Serial2/0/0 Output CHAP(c223) Pkt, Len 33\n  State SendResponse, code (*\\hi{Response(02)}*), id 1, len 29\nPPP Event:\n  Serial2/0/0 CHAP Receive Success Event\n  State SendResponse --> (*\\higreen{ClientOpen}*)\nPPP Packet:\n  Serial2/0/0 Input  CHAP(c223) Pkt, Len 16\n  State ClientOpen, code (*\\higreen{Success(03)}*), id 1, len 12", lang: "text")] the three CHAP codes appear in order --- `Challenge(01)` inbound, `Response(02)` outbound, `Success(03)` inbound --- which is #ref(label("fig:pap-chap"), supplement: [Figure]) playing out on the wire. A failure stops after the response, with `Failure(04)` instead of `Success(03)`, and that single code tells you the password is wrong rather than the link.

#callout("pitfall", title: [Common mistake])[Run `terminal debugging` first, or the messages are generated and never displayed. Turn it off with `undo terminal debugging` when finished --- debug output on a busy interface makes the console unusable.]

#callout("verification", title: [Verification checklist])[Verify in order: #strong[physical state $arrow.r$ DCE clocking $arrow.r$ encapsulation $arrow.r$ IP $arrow.r$ OSPF $arrow.r$ authentication $arrow.r$ ping].]


#heading(level: 2)[Troubleshooting matrix]
 #figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Symptom], [First evidence to inspect],),
    table.hline(),
    [Physical state down], [Cabling/serial connection and device/interface state.],
    [Physical up, protocol down], [HDLC/PPP encapsulation match, DCE clocking, and PPP authentication if enabled.],
    [Direct ping works, remote ping fails], [OSPF neighbor/routes and the destination routing table.],
    [PPP works until authentication is added], [PAP/CHAP mode, username, password, AAA local user and service type.],
    [CHAP result unclear], [Reinitialize the interface as directed and inspect PPP CHAP debug output.],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[An authentication problem can make the link protocol fail even when the cable and IP address appear correct. Once PAP or CHAP is enabled, the username/password/AAA configuration becomes part of Layer-2 link establishment and must be checked alongside encapsulation.]

#callout("tryit", title: [Try it yourself])[Complete the source assignment: create a three-router WAN using PPP, configure PAP and CHAP authentication on the required links, verify connectivity, and capture command-prompt evidence that demonstrates the working links.]

#callout("quickcheck", title: [Check your understanding])[+ Why must both ends of a serial link agree on HDLC or PPP encapsulation?

+ What is the purpose of the DCE side in the supplied serial exercise?

+ Which link uses PAP and which uses CHAP in the lab?

+ Why does the debugging procedure cycle the interface before observing CHAP messages?]
