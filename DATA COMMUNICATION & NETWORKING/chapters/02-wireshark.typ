#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-wireshark")


#heading(level: 1)[Packet Sniffing and Wireshark]
<ch:wireshark> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* A basic understanding of hosts, switches, IP traffic, and why packets move through an interface.

*By the end, you can:* Define packet sniffing and a network traffic trace, navigate the Wireshark interface, capture packets, and connect a packet-list entry to protocol details and raw bytes.]


#heading(level: 2)[Purpose and core terms]
 Before configuring a network, you need a way to observe its traffic. This chapter introduces three linked ideas:

/ Packet sniffing: #block[
observing packets as they cross a network.
]

/ Network traffic trace: #block[
a time-ordered record of packets seen by an interface.
]

/ Wireshark: #block[
a graphical analyzer for inspecting and troubleshooting packet traffic.
]

#callout("conceptmap", title: [Concept map])[#strong[Generate traffic] $arrow.r$ #strong[capture on the correct interface] $arrow.r$ #strong[find the relevant packet] $arrow.r$ #strong[decode protocol fields] $arrow.r$ #strong[relate the packet to the action that produced it].]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/wireshark-sniffing.png", width: 90%)], caption: [Packet sniffing, as illustrated in the supplied Lab~1 slide. A sniffer records only the traffic that reaches the interface it captures on.]) <fig:wireshark-sniffing>


#heading(level: 2)[Where you capture decides what you see]
 A sniffer records only what physically reaches its interface. On a switched network that is much less than beginners expect, because a switch forwards a frame to one port rather than all of them.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/cdc22af6d3b0318e.svg")], caption: [The same two-host conversation, watched from three places. Only the first and third see it; the middle case is the one that produces an empty capture and an hour of confusion.]) <fig:capture-placement>

#callout("keyidea", title: [Key idea])[In eNSP you start Wireshark by right-clicking a specific device interface, which puts you in the first case automatically. On real hardware you have to arrange the third case deliberately, with a port mirror or a network tap.]


#heading(level: 2)[A traffic trace is evidence, not just a screenshot]
 A trace records the sequence of events. If a ping, adjacency, or application session fails, it shows what was sent and whether a reply returned.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/wireshark-traffic-trace.png", width: 90%)], caption: [The network-traffic trace concept used in the source material. A trace keeps the order of events, so it shows what was sent and whether a reply came back.]) <fig:wireshark-traffic-trace>


#heading(level: 2)[The Wireshark workspace]
 Wireshark versions differ visually, but the three-pane workflow is consistent.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/wireshark-ui.png", width: 90%)], caption: [The Wireshark workspace: the packet list, packet details, and packet bytes panes. The table below says what each pane is for.]) <fig:wireshark-ui>

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Pane], [What you use it for],),
    table.hline(),
    [Packet list], [One row per frame, with time, endpoints, protocol, length, and summary.],
    [Packet details], [Decoded protocol layers, addresses, flags, and fields for the selected frame.],
    [Packet bytes], [Raw bytes in hexadecimal and ASCII.],
  )]
  , kind: table
  )


#heading(level: 2)[A disciplined capture workflow]


+ Identify the traffic you want to observe and the interface that should carry it.

+ Start packet capture on that interface.

+ Generate a small, known event such as a ping so you have a clear reference point.

+ Find the corresponding packet in the packet list using addresses, protocol, and timing.

+ Expand the relevant protocol layers in Packet Details.

+ Consult Packet Bytes only when byte-level evidence is needed.

+ Stop after collecting enough evidence; small traces are easier to analyze.

#callout("workedexample", title: [Worked configuration])[`ping 10.0.13.3` from R1 produces five request/reply pairs. In the packet list each pair shares an ICMP identifier and sequence number, and the source and destination columns swap between the two rows. Matching those two rows is the whole skill: it proves the request left and the reply came back.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/dea35fab9f7ae95b.svg")], caption: [One `ping` as it appears in a capture. The reply reverses both addresses and repeats the sequence number, which is how you pair the rows. A missing row on the right means the request arrived and was not answered; a missing row on the left means it never left.]) <fig:icmp-trace>


#heading(level: 2)[What to record in a lab submission]
 A useful screenshot shows the selected packet, relevant decoded fields, and filter expression. Explain what the evidence proves.

#callout("verification", title: [Verification checklist])[For this lab, convincing evidence is a capture in which you can point to a known traffic event and identify at least the source, destination, protocol, and the relevant request/reply relationship.]

#callout("pitfall", title: [Common mistake])[A capture from the wrong interface, or one buried in unrelated traffic, is poor evidence. Generate controlled traffic and filter by protocol or address.]

#callout("quickcheck", title: [Check your understanding])[+ What is the difference between the packet list and packet details panes?

+ Why is a traffic trace easier to interpret when you deliberately generate known traffic?

+ Which pane would you use when you need the exact bytes carried in a frame?

+ If no ping packet appears, which should you question first: the capture location or the packet bytes?]
