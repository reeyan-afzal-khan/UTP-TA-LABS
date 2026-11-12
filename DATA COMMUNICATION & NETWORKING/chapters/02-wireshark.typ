#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-wireshark")

= Packet Sniffing and Wireshark <ch:wireshark>

#chapterguide[A basic understanding of hosts, switches, IP traffic, and why packets move through an interface.][Define packet sniffing and a network traffic trace, navigate the Wireshark interface, capture packets, and connect a packet-list entry to protocol details and raw bytes.]

== Purpose and core terms

Before configuring a network, you need a way to observe its traffic. This chapter introduces three linked ideas:

/ Packet sniffing: observing packets as they cross a network.
/ Network traffic trace: a time-ordered record of packets seen by an interface.
/ Wireshark: a graphical analyzer for inspecting and troubleshooting packet traffic.

#conceptmap[
  #strong[Generate traffic] $arrow.r$ #strong[capture on the correct interface] $arrow.r$ #strong[find the relevant packet] $arrow.r$ #strong[decode protocol fields] $arrow.r$ #strong[relate the packet to the action that produced it].
]

#utpfig([Packet sniffing, as illustrated in the supplied Lab~1 slide. A sniffer records only the traffic that reaches the interface it captures on.], label: <fig:wireshark-sniffing>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/wireshark-sniffing.png", width: 64%, height: 404.7848pt)
]

== Where you capture decides what you see

A sniffer records only what physically reaches its interface. On a
switched network that is much less than beginners expect, because a
switch forwards a frame to one port rather than all of them.

#utpfig([The same two-host conversation, watched from three places. Only the first and third see it; the middle case is the one that produces an empty capture and an hour of confusion.], label: <fig:capture-placement>)[
  #canvas({
    node((1.7, 1.75), [On the host], font: font("script", weight: "bold", fill: green))
    node((0.6, 0.9), [PC1], name: "a1", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
    node((2.8, 0.9), [SW], name: "a2", ..switch, min-width: 1.1, min-height: 0.6, font: font("tiny"))
    connect("a1", "a2", ..activepath)
    node((1.7, 0.05), [capture here \
   sees all of PC1’s traffic], font: font("tiny", fill: green), align: center)
    node((1.7, -0.62), [works], font: font("script", weight: "bold", fill: green))
    node((6.2, 1.75), [On a bystander port], font: font("script", weight: "bold", fill: red))
    node((5.1, 0.9), [PC1], name: "b1", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
    node((7.3, 0.9), [SW], name: "b2", ..switch, min-width: 1.1, min-height: 0.6, font: font("tiny"))
    node((7.3, -0.15), [PC3], name: "b3", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
    connect("b1", "b2", ..activepath)
    connect("b2", "b3", ..deadpath)
    node((6, -0.85), [capture on PC3 \
   sees nothing], font: font("tiny", fill: red), align: center)
    node((6.2, -1.5), [empty], font: font("script", weight: "bold", fill: red))
    node((10.7, 1.75), [On a mirrored port], font: font("script", weight: "bold", fill: blue))
    node((9.6, 0.9), [PC1], name: "c1", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
    node((11.8, 0.9), [SW], name: "c2", ..switch, min-width: 1.1, min-height: 0.6, font: font("tiny"))
    node((11.8, -0.15), [PC3], name: "c3", ..host, min-width: 1.1, min-height: 0.6, font: font("tiny"))
    connect("c1", "c2", ..activepath)
    connect("c2", "c3", ..flowarrow, dash: "dashed")
    node((10.5, -0.85), [switch copies frames \
   to the analyser], font: font("tiny", fill: blue), align: center)
    node((10.7, -1.5), [works], font: font("script", weight: "bold", fill: blue))
  })
]

#keyidea[
  In eNSP you start Wireshark by right-clicking a specific device
  interface, which puts you in the first case automatically. On real
  hardware you have to arrange the third case deliberately, with a port
  mirror or a network tap.
]

== A traffic trace is evidence, not just a screenshot

A trace records the sequence of events. If a ping, adjacency, or application session fails, it shows what was sent and whether a reply returned.

#utpfig([The network-traffic trace concept used in the source material. A trace keeps the order of events, so it shows what was sent and whether a reply came back.], label: <fig:wireshark-traffic-trace>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/wireshark-traffic-trace.png", width: 64%, height: 303.5886pt)
]

== The Wireshark workspace

Wireshark versions differ visually, but the three-pane workflow is consistent.

#utpfig([The Wireshark workspace: the packet list, packet details, and packet bytes panes. The table below says what each pane is for.], label: <fig:wireshark-ui>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/wireshark-ui.png", width: 94%, height: 404.7848pt)
]

#utptable[
  #tabularx(
    columns: (22%, 1fr),
    styles: (navy-bold,),
    header: ([Pane], [What you use it for]),
    [Packet list], [One row per frame, with time, endpoints, protocol, length, and summary.],
    [Packet details], [Decoded protocol layers, addresses, flags, and fields for the selected frame.],
    [Packet bytes], [Raw bytes in hexadecimal and ASCII.],
  )
]

== A disciplined capture workflow

#utpsteps[
  + Identify the traffic you want to observe and the interface that should carry it.
  + Start packet capture on that interface.
  + Generate a small, known event such as a ping so you have a clear reference point.
  + Find the corresponding packet in the packet list using addresses, protocol, and timing.
  + Expand the relevant protocol layers in Packet Details.
  + Consult Packet Bytes only when byte-level evidence is needed.
  + Stop after collecting enough evidence; small traces are easier to analyze.
]

#workedexample[
  `ping 10.0.13.3` from R1 produces five request/reply pairs. In the
  packet list each pair shares an ICMP identifier and sequence number, and
  the source and destination columns swap between the two rows. Matching
  those two rows is the whole skill: it proves the request left and the
  reply came back.
]

#utpfig([One `ping` as it appears in a capture. The reply reverses both addresses and repeats the sequence number, which is how you pair the rows. A missing row on the right means the request arrived and was not answered; a missing row on the left means it never left.], label: <fig:icmp-trace>)[
  #canvas({
    seqactor("r1", 0, [R1 (10.0.13.1)], ..host)
    seqactor("r3", 7.2, [R3 (10.0.13.3)], ..server)
    seqlife("r1", -3.3)
    seqlife("r3", -3.3)
    seqmsg("r1", "r3", -0.85, [Echo request  #fsize("tiny")[seq=1]], "arrow")
    seqmsg("r3", "r1", -1.5, [Echo reply  #fsize("tiny")[seq=1]], "arrowb")
    seqmsg("r1", "r3", -2.25, [Echo request  #fsize("tiny")[seq=2]], "arrow")
    seqmsg("r3", "r1", -2.9, [Echo reply  #fsize("tiny")[seq=2]], "arrowb")
    node((7.9, -1.18), [one round trip], font: font("tiny", fill: muted), anchor: "west")
    brace((7.75, -0.8), (7.75, -1.55), amplitude: 2.9888pt, draw: muted)
  })
]

== What to record in a lab submission

A useful screenshot shows the selected packet, relevant decoded fields, and filter expression. Explain what the evidence proves.

#verification[
  For this lab, convincing evidence is a capture in which you can point to a known traffic event and identify at least the source, destination, protocol, and the relevant request/reply relationship.
]

#pitfall[
  A capture from the wrong interface, or one buried in unrelated traffic, is poor evidence. Generate controlled traffic and filter by protocol or address.
]

#quickcheck[
  + What is the difference between the packet list and packet details panes?
  + Why is a traffic trace easier to interpret when you deliberately generate known traffic?
  + Which pane would you use when you need the exact bytes carried in a frame?
  + If no ping packet appears, which should you question first: the capture location or the packet bytes?
]
