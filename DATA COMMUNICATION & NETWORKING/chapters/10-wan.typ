#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-wan")

= WAN Links: HDLC, PPP, PAP, and CHAP <ch:wan>

#chapterguide[Routing, OSPF, IPv4 interface addressing, and basic AAA concepts from earlier labs.][Configure serial addressing, apply HDLC and PPP encapsulation, identify a DCE and set its baud rate, run OSPF across WAN links, configure PAP and CHAP authentication, and use PPP debugging to investigate negotiation.]

== Scenario: connect headquarters and branches

R2 represents headquarters and R1/R3 the branches. Two serial links share one routing domain; the lab moves from HDLC to PPP, then adds PAP and CHAP.

#utpfig([The serial WAN topology from the supplied Lab~9 slide. R2 is headquarters; R1 and R3 are the branches.], label: <fig:wan-topology>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/wan-topology.png", width: 84%, height: 404.7848pt)
]

#utptable[
  #tabularx(
    columns: (auto, auto, auto, auto),
    header: ([Link], [Interfaces], [Network], [Addressing shown]),
    [R1--R2], [S1/0/0 -- S1/0/0], [`10.0.12.0/24`], [R1 .1, R2 .2],
    [R2--R3], [S2/0/0 -- S2/0/0], [`10.0.23.0/24`], [R2 .2, R3 .3],
  )
]

== HDLC and PPP in the source material

HDLC and PPP are serial link encapsulations that must match at both ends. PPP also supports network-layer negotiation and authentication through PAP or CHAP.

#utptable[
  #tabularx(
    columns: (22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Feature], [HDLC portion], [PPP portion]),
    [Role in lab], [Establish the serial Layer-2 link], [Replace HDLC and add authentication capability],
    [End agreement], [Both ends use HDLC], [Both ends use PPP],
    [Authentication], [Not used in the HDLC section], [PAP between R1--R2 and CHAP between R2--R3],
  )
]

== Step 1: configure serial IP addressing

```terminal
[R1] interface Serial 1/0/0
[R1-Serial1/0/0] ip address 10.0.12.1 24

[R2] interface Serial 1/0/0
[R2-Serial1/0/0] ip address 10.0.12.2 24
[R2] interface Serial 2/0/0
[R2-Serial2/0/0] ip address 10.0.23.2 24

[R3] interface Serial 2/0/0
[R3-Serial2/0/0] ip address 10.0.23.3 24
```

== Step 2: enable HDLC on both serial links

```terminal
[R1] interface Serial 1/0/0
[R1-Serial1/0/0] link-protocol hdlc
[R2] interface Serial 1/0/0
[R2-Serial1/0/0] link-protocol hdlc
[R2] interface Serial 2/0/0
[R2-Serial2/0/0] link-protocol hdlc
[R3] interface Serial 2/0/0
[R3-Serial2/0/0] link-protocol hdlc
```

Verify that each serial interface is physically and logically up before adding routing.

== Step 3: run OSPF across the WAN links

Advertise both /24 serial networks in area 0.

```terminal
[R1] ospf 1
[R1-ospf-1] area 0
[R1-ospf-1-area-0.0.0.0] network 10.0.12.0 0.0.0.255

[R2] ospf 1
[R2-ospf-1] area 0
[R2-ospf-1-area-0.0.0.0] network 10.0.12.0 0.0.0.255
[R2-ospf-1-area-0.0.0.0] network 10.0.23.0 0.0.0.255

[R3] ospf 1
[R3-ospf-1] area 0
[R3-ospf-1-area-0.0.0.0] network 10.0.23.0 0.0.0.255
```

After convergence, inspect learned routes and ping from R1 to R3.

== Step 4: identify the DCE and change the clock rate

One side of a synchronous serial link provides clocking. Here R1 Serial1/0/0 is the DCE; change its baud rate from 64,000 to 128,000 bit/s.

#vrpbox[\<R1\> display interface Serial 1/0/0][
  #vrp(
    (raw("Serial1/0/0 current state : "), [#higreen[UP]]),
    (raw("Line protocol current state : "), [#higreen[UP]]),
    (raw("Description:HUAWEI, AR Series, Serial1/0/0 Interface"),),
    (raw("Route Port,The Maximum Transmit Unit is 1500, Hold timer is 10(sec)"),),
    (raw("Internet Address is 10.0.12.1/24"),),
    ([#hi[Link layer protocol is nonstandard HDLC]],),
    (raw("Physical layer is synchronous, "), [#hi[Baudrate is 64000 bps]]),
    ([#hi[Interface is DCE]], raw(", Cable type is V35, Clock mode is DCECLK")),
    (raw("    Last 300 seconds input rate 3 bytes/sec 24 bits/sec 0 packets/sec"),),
    (raw("    Last 300 seconds output rate 3 bytes/sec 24 bits/sec 0 packets/sec"),),
  )
]

#vrpread[three lines answer three different questions. `Link layer protocol` is the encapsulation, and it must match the far end. `Interface is DCE` identifies which router owns the clock. `Baudrate` is the rate you are about to change --- and it is only settable on the line that says DCE.]

A synchronous serial link has no separate clock wire, so one end must
generate the timing the other end samples against. That end is the DCE.
The DTE takes whatever rate it is given, which is why `baudrate` is
rejected or ignored on that side.

#utpfig([Clocking on a synchronous serial link. In eNSP the DCE is the end the cable was dragged #emph[from], and `display interface Serial1/0/0` names it explicitly.], label: <fig:dte-dce>)[
  #canvas({
    node((0, 0), [R1], name: "r1", ..router)
    node((7, 0), [R2], name: "r2", ..router)
    node(above-of("r1", 0.1), [DCE], font: font("script", weight: "bold", fill: teal))
    node(above-of("r2", 0.1), [DTE], font: font("script", weight: "bold", fill: muted))
    connect((0.55, 0), (6.45, 0), line-width: 1.594pt, draw: muted)
    node(below-of(("r1", 50%, "r2"), 0.1), [S1/0/0 #h(1em)10.0.12.0/24], ..netlabel)
    connect((1.3, 0.55), (1.3, 0.85), (1.7, 0.85), (1.7, 0.55), (2.1, 0.55), (2.1, 0.85), (2.5, 0.85), (2.5, 0.55), (2.9, 0.55), (2.9, 0.85), (3.3, 0.85), (3.3, 0.55), draw: teal, line-width: widths.thick)
    connect((3.45, 0.7), (5.6, 0.7), draw: teal, line-width: widths.thick, end: tip("Stealth", length: 2.2mm, line: widths.thick))
    node((1.3, 1.15), [clock generated here], font: font("script", fill: teal), anchor: "west")
    node((4.6, 1.15), [and followed here], font: font("script", fill: muted), anchor: "west")
    node((-0.6, -1.15), [`baudrate 128000` is set on #strong[R1 only]. Setting it on the DTE changes nothing.], anchor: "west", font: font("script", fill: ink), align: left, text-width: 5)
    node((5.3, -1.15), [A missing clock leaves the physical state up and the protocol state down --- the same symptom as an encapsulation mismatch.], anchor: "west", font: font("script", fill: muted), align: left, text-width: 4.6)
  })
]

```terminal
[R1] interface Serial 1/0/0
[R1-Serial1/0/0] baudrate 128000
```

#keyidea[
  Set the baud rate only on the DCE side, identified from the interface output.
]

== Step 5: replace HDLC with PPP

PPP brings a link up in stages, and each stage must finish before the
next begins. The verification order used throughout this chapter is
simply this diagram read left to right.

#utpfig([How a PPP link comes up. Authentication sits between link establishment and IP, which is why enabling PAP or CHAP can take down a link whose cabling and addressing never changed.], label: <fig:ppp-phases>)[
  #canvas({
    node((0, 0), [Dead], name: "d", ..statebad)
    node((2.9, 0), [Establish], name: "e", ..netstate)
    node((5.8, 0), [Authenticate], name: "a", ..statewait)
    node((8.9, 0), [Network], name: "n", ..netstate)
    node((11.6, 0), [Open], name: "o", ..stategood)
    connect("d", "e", ..stedge)
    node(along("d", "e", t: 50%), [carrier], ..stlabel, anchor: "south")
    connect("e", "a", ..stedge)
    node(along("e", "a", t: 50%), [LCP ok], ..stlabel, anchor: "south")
    connect("a", "n", ..stedge)
    node(along("a", "n", t: 50%), [PAP/CHAP ok], ..stlabel, anchor: "south")
    connect("n", "o", ..stedge)
    node(along("n", "o", t: 50%), [IPCP ok], ..stlabel, anchor: "south")
    node(below-of("e", 0.15), [LCP agrees MTU \
   and options], ..stlabel, text-width: 2.5)
    node(below-of("a", 0.15), [optional --- skipped \
   until Step 6], ..stlabel, text-width: 2.6, text: orange)
    node(below-of("n", 0.15), [IPCP exchanges \
   IP parameters], ..stlabel, text-width: 2.5)
    node(below-of("o", 0.15), [protocol up, \
   ping works], ..stlabel, text-width: 2.3, text: green)
    connect("a.north", "d.north", bend: -38deg, ..stedge, draw: red, dash: "dashed", name: "curve-1")
    node((name: "curve-1", anchor: 50%), [bad credentials], ..stlabel, anchor: "south")
  })
]

Change both ends of each serial link to PPP.

```terminal
[R1] interface Serial 1/0/0
[R1-Serial1/0/0] link-protocol ppp
[R2] interface Serial 1/0/0
[R2-Serial1/0/0] link-protocol ppp
[R2] interface Serial 2/0/0
[R2-Serial2/0/0] link-protocol ppp
[R3] interface Serial 2/0/0
[R3-Serial2/0/0] link-protocol ppp
```

An encapsulation mismatch leaves the line protocol down; configure both ends before testing.

== Step 6: configure PAP on R1--R2

R1 authenticates R2 with PAP.

```terminal
[R1] interface Serial 1/0/0
[R1-Serial1/0/0] ppp authentication-mode pap
[R1] aaa
[R1-aaa] local-user huawei password cipher huawei123
[R1-aaa] local-user huawei service-type ppp

[R2] interface Serial 1/0/0
[R2-Serial1/0/0] ppp pap local-user huawei password cipher huawei123
```

Then retest the R1--R2 link.

== Step 7: configure CHAP on R2--R3

The source text names R1 here, but its topology and commands identify R3 as the authenticator and R2 as the CHAP peer. The sequence below follows the commands.

```terminal
[R3] interface Serial 2/0/0
[R3-Serial2/0/0] ppp authentication-mode chap
[R3] aaa
[R3-aaa] local-user huawei password cipher huawei123
[R3-aaa] local-user huawei service-type ppp

[R2] interface Serial 2/0/0
[R2-Serial2/0/0] ppp chap user huawei
[R2-Serial2/0/0] ppp chap password cipher huawei123
```

== Step 8: observe CHAP negotiation with debugging

The two schemes differ in a way the debug output makes visible. PAP
sends the password across the link; CHAP never does, sending instead a
hash of a challenge the authenticator chose. That is why the CHAP debug
shows a Challenge/Response/Success triple rather than a single request.

#utpfig([PAP’s two messages against CHAP’s three. The password crosses the link in the left-hand exchange and never crosses it in the right-hand one.], label: <fig:pap-chap>)[
  #canvas({
    node((2.1, 0.85), [PAP --- 2-way], font: font("small", weight: "bold", fill: red))
    seqactor("p2", 0, [R2 (peer)], ..host)
    seqactor("p1", 4.2, [R1 (auth)], ..server)
    seqlife("p2", -2.3)
    seqlife("p1", -2.3)
    seqmsg("p2", "p1", -0.85, [#fsize("tiny")[username + password]], "risk")
    seqmsg("p1", "p2", -1.65, [#fsize("tiny")[Authenticate-Ack]], "arrowb")
    node((2.1, -3.05), [Password sent in the clear, once, at the peer’s initiative.], font: font("tiny", fill: red), align: center, text-width: 4.4)
    draw.scope({
      draw.translate((8, 0))
      node((2.1, 0.85), [CHAP --- 3-way], font: font("small", weight: "bold", fill: green))
      seqactor("c2", 0, [R2 (peer)], ..host)
      seqactor("c3", 4.2, [R3 (auth)], ..server)
      seqlife("c2", -2.3)
      seqlife("c3", -2.3)
      seqmsg("c3", "c2", -0.7, [#fsize("tiny")[Challenge]], "arrowb")
      seqmsg("c2", "c3", -1.35, [#fsize("tiny")[hash(challenge + password)]], "arrow")
      seqmsg("c3", "c2", -2, [#fsize("tiny")[Success]], "arrowb")
      node((2.1, -3.05), [Only a hash crosses. The authenticator starts the exchange and can repeat it.], font: font("tiny", fill: green), align: center, text-width: 4.6)
    })
  })
]

#keyidea[
  The direction of the first message tells you which router is the
  authenticator. In PAP the peer speaks first; in CHAP the authenticator
  does. Reading that from a debug trace identifies immediately which end
  holds the wrong configuration.
]

Cycle the serial interface and enable PPP CHAP debugging to regenerate negotiation messages and locate authentication failure.

#vrpbox[\<R2\> terminal debugging #h(1em)+ #h(1em)debugging ppp chap all][
  #vrp(
    (raw("PPP State Change:"),),
    (raw("  Serial2/0/0 CHAP : ListenChallenge --> "), [#hi[SendResponse]]),
    (raw("PPP Packet:"),),
    (raw("  Serial2/0/0 Input  CHAP(c223) Pkt, Len 20"),),
    (raw("  State SendResponse, code "), [#hi[Challenge(01)]], raw(", id 1, len 16")),
    (raw("  Message: Welcome to ..."),),
    (raw("PPP Packet:"),),
    (raw("  Serial2/0/0 Output CHAP(c223) Pkt, Len 33"),),
    (raw("  State SendResponse, code "), [#hi[Response(02)]], raw(", id 1, len 29")),
    (raw("PPP Event:"),),
    (raw("  Serial2/0/0 CHAP Receive Success Event"),),
    (raw("  State SendResponse --> "), [#higreen[ClientOpen]]),
    (raw("PPP Packet:"),),
    (raw("  Serial2/0/0 Input  CHAP(c223) Pkt, Len 16"),),
    (raw("  State ClientOpen, code "), [#higreen[Success(03)]], raw(", id 1, len 12")),
  )
]

#vrpread[the three CHAP codes appear in order --- `Challenge(01)` inbound, `Response(02)` outbound, `Success(03)` inbound --- which is #figref(<fig:pap-chap>) playing out on the wire. A failure stops after the response, with `Failure(04)` instead of `Success(03)`, and that single code tells you the password is wrong rather than the link.]

#pitfall[
  Run `terminal debugging` first, or the messages are generated and never
  displayed. Turn it off with `undo terminal debugging` when finished ---
  debug output on a busy interface makes the console unusable.
]

#verification[
  Verify in order: #strong[physical state $arrow.r$ DCE clocking $arrow.r$ encapsulation $arrow.r$ IP $arrow.r$ OSPF $arrow.r$ authentication $arrow.r$ ping].
]

== Troubleshooting matrix

#utptable[
  #tabularx(
    columns: (25%, 1fr),
    styles: (navy-bold,),
    header: ([Symptom], [First evidence to inspect]),
    [Physical state down], [Cabling/serial connection and device/interface state.],
    [Physical up, protocol down], [HDLC/PPP encapsulation match, DCE clocking, and PPP authentication if enabled.],
    [Direct ping works, remote ping fails], [OSPF neighbor/routes and the destination routing table.],
    [PPP works until authentication is added], [PAP/CHAP mode, username, password, AAA local user and service type.],
    [CHAP result unclear], [Reinitialize the interface as directed and inspect PPP CHAP debug output.],
  )
]

#pitfall[
  An authentication problem can make the link protocol fail even when the cable and IP address appear correct. Once PAP or CHAP is enabled, the username/password/AAA configuration becomes part of Layer-2 link establishment and must be checked alongside encapsulation.
]

#tryit[
  Complete the source assignment: create a three-router WAN using PPP, configure PAP and CHAP authentication on the required links, verify connectivity, and capture command-prompt evidence that demonstrates the working links.
]

#quickcheck[
  + Why must both ends of a serial link agree on HDLC or PPP encapsulation?
  + What is the purpose of the DCE side in the supplied serial exercise?
  + Which link uses PAP and which uses CHAP in the lab?
  + Why does the debugging procedure cycle the interface before observing CHAP messages?
]
